#!/usr/bin/env bash
# ============================================================================
# 🧪 Helm Chart Testing Suite
# ============================================================================
# Comprehensive testing for Helm charts including linting, unit tests,
# template rendering, and integration tests in Kind clusters.
# ============================================================================
# Usage:
#   ./scripts/test.sh [CHART_NAME] [OPTIONS]
#
# Examples:
#   ./scripts/test.sh                    # Test all charts
#   ./scripts/test.sh my-chart            # Test specific chart
#   ./scripts/test.sh my-chart --no-kind  # Test without Kind cluster
# ============================================================================

set -euo pipefail

# ============================================================================
# IMPORT COMMON UTILITIES
# ============================================================================

COMMON_SCRIPT="${HOME}/scripts/common.sh"

if [[ ! -f "${COMMON_SCRIPT}" ]]; then
    echo "ERROR: common.sh not found at: ${COMMON_SCRIPT}" >&2
    echo "Please ensure common.sh exists in ~/scripts/ directory." >&2
    exit 1
fi

source "${COMMON_SCRIPT}"

# ============================================================================
# SCRIPT VARIABLES
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
CHART_NAME="${1:-}"
NO_KIND=false
NO_CLEANUP=false
VERBOSE=false

# ============================================================================
# PARSE COMMAND LINE OPTIONS
# ============================================================================

shift || true
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-kind)
            NO_KIND=true
            shift
            ;;
        --no-cleanup)
            NO_CLEANUP=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# ============================================================================
# DEPENDENCY CHECKS
# ============================================================================

check_dependencies() {
    print_step "Checking dependencies..."
    
    local missing_deps=()
    
    command -v helm &> /dev/null || missing_deps+=("helm")
    command -v kubectl &> /dev/null || missing_deps+=("kubectl")
    
    if [ "$NO_KIND" = false ]; then
        command -v kind &> /dev/null || missing_deps+=("kind")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        echo ""
        print_info "Install with:"
        for dep in "${missing_deps[@]}"; do
            case $dep in
                helm)
                    echo "  ${CYAN}brew install helm${RESET}"
                    ;;
                kubectl)
                    echo "  ${CYAN}brew install kubectl${RESET}"
                    ;;
                kind)
                    echo "  ${CYAN}brew install kind${RESET}"
                    ;;
            esac
        done
        exit 1
    fi
    
    # Check for helm-unittest plugin
    if ! helm plugin list | grep -q unittest; then
        print_warning "helm-unittest plugin not found"
        print_info "Installing helm-unittest plugin..."
        helm plugin install https://github.com/helm-unittest/helm-unittest
    fi
    
    print_success "All dependencies found!"
}

# ============================================================================
# CHART LINTING
# ============================================================================

lint_chart() {
    local chart_path=$1
    local chart_name=$(basename "$chart_path")
    
    print_step "Linting ${BOLD}${chart_name}${RESET}..."
    
    if helm lint "$chart_path" --strict; then
        print_success "${chart_name} passed linting"
        return 0
    else
        print_error "${chart_name} failed linting"
        return 1
    fi
}

# ============================================================================
# UNIT TESTS
# ============================================================================

unit_test_chart() {
    local chart_path=$1
    local chart_name=$(basename "$chart_path")
    
    print_step "Running unit tests for ${BOLD}${chart_name}${RESET}..."
    
    if [ ! -d "$chart_path/tests" ]; then
        print_warning "No tests directory found for ${chart_name}, skipping unit tests"
        return 0
    fi
    
    if helm unittest "$chart_path" ${VERBOSE:+--with-subchart}; then
        print_success "${chart_name} passed unit tests"
        return 0
    else
        print_error "${chart_name} failed unit tests"
        return 1
    fi
}

# ============================================================================
# TEMPLATE RENDERING TESTS
# ============================================================================

template_test_chart() {
    local chart_path=$1
    local chart_name=$(basename "$chart_path")
    
    print_step "Testing template rendering for ${BOLD}${chart_name}${RESET}..."
    
    local temp_dir=$(mktemp -d)
    
    if helm template test-release "$chart_path" --output-dir "$temp_dir" ${VERBOSE:+--debug}; then
        print_success "${chart_name} templates rendered successfully"
        [ "$VERBOSE" = true ] && ls -R "$temp_dir"
        rm -rf "$temp_dir"
        return 0
    else
        print_error "${chart_name} template rendering failed"
        rm -rf "$temp_dir"
        return 1
    fi
}

# ============================================================================
# INTEGRATION TESTS
# ============================================================================

integration_test_chart() {
    local chart_path=$1
    local chart_name=$(basename "$chart_path")
    
    print_step "Installing ${BOLD}${chart_name}${RESET} in Kind cluster..."
    
    local release_name="test-${chart_name}"
    local namespace="test-${chart_name}"
    
    # Create namespace
    kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -
    
    # Install chart with minimal values for testing
    if helm install "$release_name" "$chart_path" \
        --namespace "$namespace" \
        --wait \
        --timeout 5m \
        --set image.pullPolicy=IfNotPresent \
        ${VERBOSE:+--debug}; then
        
        print_success "${chart_name} installed successfully"
        
        # Show deployment status
        print_info "Deployment status:"
        kubectl get all -n "$namespace"
        
        # Check pod status
        if kubectl wait --for=condition=ready pod -l app.kubernetes.io/name="$chart_name" -n "$namespace" --timeout=300s 2>/dev/null; then
            print_success "Pods are ready"
        else
            print_warning "Pods not ready within timeout (this may be expected for some charts)"
        fi
        
        # Cleanup
        if [ "$NO_CLEANUP" = false ]; then
            print_step "Cleaning up ${chart_name}..."
            helm uninstall "$release_name" -n "$namespace" || true
            kubectl delete namespace "$namespace" --wait=false || true
        else
            print_info "Skipping cleanup (--no-cleanup flag)"
        fi
        
        return 0
    else
        print_error "${chart_name} installation failed"
        
        # Show logs on failure
        print_info "Pod status:"
        kubectl get pods -n "$namespace" || true
        
        print_info "Pod logs:"
        kubectl logs -l app.kubernetes.io/name="$chart_name" -n "$namespace" --tail=50 || true
        
        # Cleanup even on failure
        if [ "$NO_CLEANUP" = false ]; then
            helm uninstall "$release_name" -n "$namespace" || true
            kubectl delete namespace "$namespace" --wait=false || true
        fi
        
        return 1
    fi
}

# ============================================================================
# SINGLE CHART TEST
# ============================================================================

test_single_chart() {
    local chart_path=$1
    local chart_name=$(basename "$chart_path")
    
    print_header "🧪 Testing Chart: ${chart_name}"
    
    local tests_passed=0
    local tests_failed=0
    
    # Check if .disable-unittest exists
    if [ -f "$chart_path/.disable-unittest" ]; then
        print_warning "${chart_name} has unittest disabled (.disable-unittest found)"
        return 0
    fi
    
    # Lint
    if lint_chart "$chart_path"; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    # Unit tests
    if unit_test_chart "$chart_path"; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    # Template rendering
    if template_test_chart "$chart_path"; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    # Integration tests (only if Kind cluster is available)
    if [ "$NO_KIND" = false ]; then
        if integration_test_chart "$chart_path"; then
            ((tests_passed++))
        else
            ((tests_failed++))
        fi
    fi
    
    echo ""
    print_info "Results for ${BOLD}${chart_name}${RESET}: ${GREEN}${tests_passed} passed${RESET}, ${RED}${tests_failed} failed${RESET}"
    
    return $tests_failed
}

# ============================================================================
# KIND CLUSTER SETUP
# ============================================================================

setup_kind_cluster() {
    if [ "$NO_KIND" = true ]; then
        print_info "Skipping Kind cluster setup (--no-kind flag)"
        return 0
    fi
    
    print_step "Checking for Kind cluster..."
    
    if kind get clusters | grep -q "^chart-testing$"; then
        print_info "Using existing ${BOLD}chart-testing${RESET} cluster"
        kind export kubeconfig --name chart-testing
    else
        print_step "Creating Kind cluster ${BOLD}chart-testing${RESET}..."
        
        cat <<EOF | kind create cluster --name chart-testing --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
EOF
        
        print_success "Kind cluster created"
    fi
    
    # Wait for cluster to be ready
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    print_success "Kind cluster is ready"
}

# ============================================================================
# KIND CLUSTER CLEANUP
# ============================================================================

cleanup_kind_cluster() {
    if [ "$NO_KIND" = true ] || [ "$NO_CLEANUP" = true ]; then
        return 0
    fi
    
    print_step "Cleaning up Kind cluster..."
    kind delete cluster --name chart-testing || true
    print_success "Kind cluster cleaned up"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    print_header "🧪 Helm Chart Testing Suite"
    
    check_dependencies
    
    # Determine which charts to test
    local charts_to_test=()
    
    if [ -n "$CHART_NAME" ]; then
        local chart_path="$SCRIPT_DIR/charts/$CHART_NAME"
        if [ ! -d "$chart_path" ]; then
            print_error "Chart not found: ${BOLD}${CHART_NAME}${RESET}"
            exit 1
        fi
        charts_to_test+=("$chart_path")
    else
        # Test all charts - use fd if available, otherwise fallback to find
        if command -v fd &> /dev/null; then
            # Using fd for better performance and usability
            while IFS= read -r chart_yaml; do
                local chart_dir=$(dirname "$chart_yaml")
                charts_to_test+=("$chart_dir")
            done < <(fd -t f '^Chart\.yaml$' "$SCRIPT_DIR/charts" --max-depth 2)
        else
            # Fallback to find if fd is not available
            for chart_dir in "$SCRIPT_DIR"/charts/*; do
                if [ -d "$chart_dir" ] && [ -f "$chart_dir/Chart.yaml" ]; then
                    charts_to_test+=("$chart_dir")
                fi
            done
        fi
    fi
    
    if [ ${#charts_to_test[@]} -eq 0 ]; then
        print_error "No charts found to test"
        exit 1
    fi
    
    print_info "Testing ${BOLD}${#charts_to_test[@]}${RESET} chart(s)"
    echo ""
    
    # Setup Kind cluster for integration tests
    setup_kind_cluster
    
    # Test each chart
    local total_failed=0
    local total_passed=0
    
    for chart_path in "${charts_to_test[@]}"; do
        if test_single_chart "$chart_path"; then
            ((total_passed++))
        else
            ((total_failed++))
        fi
    done
    
    # Cleanup
    cleanup_kind_cluster
    
    # Summary
    print_header "📊 Test Summary"
    print_info "Total charts tested: ${BOLD}${#charts_to_test[@]}${RESET}"
    print_success "Passed: ${BOLD}${total_passed}${RESET}"
    
    if [ $total_failed -gt 0 ]; then
        print_error "Failed: ${BOLD}${total_failed}${RESET}"
        exit 1
    else
        echo ""
        print_success "All tests passed! 🎉"
        echo ""
    fi
}

main "$@"
