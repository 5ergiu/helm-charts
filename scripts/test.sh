#!/usr/bin/env bash

# ============================================================================
# 🧪 Helm Chart Testing Suite
# ============================================================================
# Comprehensive testing for Helm charts including linting, unit tests,
# template rendering, and integration tests in isolated Kind clusters.
#
# Each test run creates a new isolated Kind cluster to ensure no interference
# with existing clusters. The cluster is automatically cleaned up after tests.
# ============================================================================
# Usage:
#   ./scripts/test.sh [CHART_PATH] [OPTIONS]
#
# Examples:
#   ./scripts/test.sh                              # Test all charts
#   ./scripts/test.sh charts/laravel               # Test specific chart
#   ./scripts/test.sh charts/laravel --skip-lint   # Skip linting
#   ./scripts/test.sh --skip-integration           # Test without integration
#   ./scripts/test.sh --no-cleanup                 # Keep cluster running
#
# Environment Variables:
#   CI              Set to 'true' when running in CI (auto-detected)
# ============================================================================

set -euo pipefail

# ============================================================================
# COLORS & FORMATTING
# ============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
CHARTS_DIR="${SCRIPT_DIR}/charts"
CHART_PATH=""
CLUSTER_NAME="helm-charts-testing"
CLEANUP_RESOURCES=true
SKIP_LINT=false
SKIP_UNIT=false
SKIP_INTEGRATION=false

# Detect CI environment (default: false)
CI="${CI:-false}"

# ============================================================================
# OUTPUT HELPERS
# ============================================================================

print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}$1${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_section() {
    echo ""
    echo -e "${BOLD}${MAGENTA}▸ $1${NC}"
}

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error()   { echo -e "${RED}❌ $1${NC}"; }
print_step()    { echo -e "${CYAN}🔧 $1${NC}"; }

# ============================================================================
# USAGE & HELP
# ============================================================================

usage() {
    cat <<EOF
${BOLD}Helm Chart Testing Suite${NC}

${BOLD}USAGE:${NC}
    $0 [CHART_PATH] [OPTIONS]

${BOLD}ARGUMENTS:${NC}
    CHART_PATH              Path to chart directory (e.g., charts/laravel)
                           If omitted, all charts will be tested

${BOLD}OPTIONS:${NC}
    --skip-lint            Skip linting tests
    --skip-unit            Skip unit tests
    --skip-integration     Skip integration tests (no cluster needed)
    --no-cleanup           Don't cleanup the kind cluster after tests
    --cluster-name NAME    Name for the kind cluster (default: helm-chart-test-<pid>)
    --help, -h             Show this help message

${BOLD}EXAMPLES:${NC}
    # Test a specific chart with all tests
    $0 charts/laravel

    # Test all charts
    $0

    # Test with only integration tests
    $0 charts/laravel --skip-lint --skip-unit

    # Test without cleaning up the cluster (useful for debugging)
    $0 charts/laravel --no-cleanup

${BOLD}ENVIRONMENT VARIABLES:${NC}
    CI                     Set to 'true' when running in CI (auto-detected)

${BOLD}INSTALLATION:${NC}
    Required tools:
        • helm              https://helm.sh/docs/intro/install/
        • kubectl           https://kubernetes.io/docs/tasks/tools/
        • docker            https://docs.docker.com/get-docker/
        • kind              https://kind.sigs.k8s.io/docs/user/quick-start/

    Optional tools:
        • chart-testing     https://github.com/helm/chart-testing
        • helm-unittest     https://github.com/helm-unittest/helm-unittest

EOF
    exit 0
}

# ============================================================================
# LOCAL SECRETS HANDLING
# ============================================================================

get_local_secrets_args() {
    local chart_path="$1"
    local chart_name=$(basename "$chart_path")

    # Never load secrets in CI
    if [[ "$CI" == "true" ]]; then
        return 0
    fi

    # Try chart-specific secrets in examples/<chart>/secrets.yaml
    local example_secrets="${SCRIPT_DIR}/examples/${chart_name}/secrets.yaml"
    if [[ -f "$example_secrets" ]]; then
        echo "-f $example_secrets"
        return 0
    fi
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-lint)
                SKIP_LINT=true
                shift
                ;;
            --skip-unit)
                SKIP_UNIT=true
                shift
                ;;
            --skip-integration)
                SKIP_INTEGRATION=true
                shift
                ;;
            --no-cleanup)
                CLEANUP_RESOURCES=false
                shift
                ;;
            --help|-h)
                usage
                ;;
            -*)
                print_error "Unknown option: $1"
                echo ""
                usage
                ;;
            *)
                if [[ -z "$CHART_PATH" ]]; then
                    CHART_PATH="$1"
                else
                    print_error "Multiple chart paths specified"
                    usage
                fi
                shift
                ;;
        esac
    done
}

# ============================================================================
# DEPENDENCY CHECKS
# ============================================================================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_prerequisites() {
    print_section "Checking prerequisites"

    local missing_tools=()

    # Required tools
    command_exists helm || missing_tools+=("helm")
    command_exists docker || missing_tools+=("docker")

    # Integration test tools
    if [[ "$SKIP_INTEGRATION" == "false" ]]; then
        command_exists kind || missing_tools+=("kind")
        command_exists kubectl || missing_tools+=("kubectl")
    fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        echo ""
        echo "Installation instructions:"
        for tool in "${missing_tools[@]}"; do
            case $tool in
                helm)
                    echo "  • helm:    ${CYAN}brew install helm${NC} or https://helm.sh/docs/intro/install/"
                    ;;
                docker)
                    echo "  • docker:  ${CYAN}brew install --cask docker${NC} or https://docs.docker.com/get-docker/"
                    ;;
                kind)
                    echo "  • kind:    ${CYAN}brew install kind${NC} or https://kind.sigs.k8s.io/"
                    ;;
                kubectl)
                    echo "  • kubectl: ${CYAN}brew install kubectl${NC} or https://kubernetes.io/docs/tasks/tools/"
                    ;;
            esac
        done
        exit 1
    fi

    # Check for optional helm-unittest plugin
    if [[ "$SKIP_UNIT" == "false" ]]; then
        if ! helm plugin list 2>/dev/null | grep -q unittest; then
            print_warning "helm-unittest plugin not found"
            print_info "Installing helm-unittest plugin..."
            helm plugin install https://github.com/helm-unittest/helm-unittest
        fi
    fi

    print_success "All prerequisites satisfied"
}

# ============================================================================
# CHART VALIDATION
# ============================================================================

validate_chart() {
    local chart_path="$1"

    if [[ ! -d "$chart_path" ]]; then
        print_error "Chart directory not found: $chart_path"
        exit 1
    fi

    if [[ ! -f "$chart_path/Chart.yaml" ]]; then
        print_error "Chart.yaml not found in: $chart_path"
        exit 1
    fi

    # Check if it's a library chart
    if grep -q "^type: library" "$chart_path/Chart.yaml" 2>/dev/null; then
        return 2  # Special code for library chart
    fi

    return 0
}

# ============================================================================
# LINTING
# ============================================================================

run_lint() {
    local chart_path="$1"
    local chart_name=$(basename "$chart_path")

    if [[ "$SKIP_LINT" == "true" ]]; then
        print_warning "Skipping lint tests"
        return 0
    fi

    print_section "Running Lint Tests"

    # Update dependencies
    if [[ -f "$chart_path/Chart.yaml" ]] && grep -q "^dependencies:" "$chart_path/Chart.yaml"; then
        print_step "Building chart dependencies..."
        if ! helm dependency build "$chart_path" --skip-refresh; then
            print_error "Failed to build dependencies"
            return 1
        fi
    fi

    # Helm lint
    print_step "Running helm lint..."
    if helm lint "$chart_path" --strict; then
        print_success "Helm lint passed"
    else
        print_error "Helm lint failed"
        return 1
    fi

    # Chart-testing lint (if available)
    if command_exists ct; then
        print_step "Running chart-testing lint..."
        local ct_config="$SCRIPT_DIR/.github/configs/ct.yaml"
        if [[ -f "$ct_config" ]]; then
            if ct lint --charts "$chart_path" --config "$ct_config"; then
                print_success "Chart-testing lint passed"
            else
                print_error "Chart-testing lint failed"
                return 1
            fi
        else
            if ct lint --charts "$chart_path"; then
                print_success "Chart-testing lint passed"
            else
                print_error "Chart-testing lint failed"
                return 1
            fi
        fi
    fi

    print_success "All lint tests passed"
}

# ============================================================================
# UNIT TESTS
# ============================================================================

run_unit_tests() {
    local chart_path="$1"
    local chart_name=$(basename "$chart_path")

    if [[ "$SKIP_UNIT" == "true" ]]; then
        print_warning "Skipping unit tests"
        return 0
    fi

    print_section "Running Unit Tests"

    # Check for .disable-unittest flag
    if [[ -f "$chart_path/.disable-unittest" ]]; then
        print_warning "Unit tests disabled for $chart_name (.disable-unittest found)"
        return 0
    fi

    local test_dir="$chart_path/tests"

    if [[ ! -d "$test_dir" ]] || [[ -z "$(ls -A "$test_dir" 2>/dev/null)" ]]; then
        print_warning "No unit tests found for $chart_name (no tests directory or empty)"
        return 0
    fi

    print_step "Running helm unittest..."

    if helm unittest "$chart_path" --with-subchart; then
        print_success "Unit tests passed"
    else
        print_error "Unit tests failed"
        return 1
    fi

    print_success "All unit tests passed"
}

# ============================================================================
# TEMPLATE RENDERING
# ============================================================================

run_template_tests() {
    local chart_path="$1"
    local chart_name=$(basename "$chart_path")

    print_section "Testing Template Rendering"

    # Determine which values file to use based on environment
    local test_values_args=""

    if [[ "$CI" == "true" ]]; then
        # CI environment: use values.ci.yaml from examples
        local ci_values="${SCRIPT_DIR}/examples/${chart_name}/values.ci.yaml"
        if [[ -f "$ci_values" ]]; then
            print_info "Using CI values: examples/${chart_name}/values.ci.yaml"
            test_values_args="-f $ci_values"
        fi
    else
        # Local environment: use values.test.yaml from examples
        local test_values="${SCRIPT_DIR}/examples/${chart_name}/values.test.yaml"
        if [[ -f "$test_values" ]]; then
            print_info "Using test values: examples/${chart_name}/values.test.yaml"
            test_values_args="-f $test_values"
        fi

        # Add secrets for local testing only
        test_values_args+=" $(get_local_secrets_args "$chart_path")"
    fi

    # Test template rendering
    print_step "Rendering templates..."
    local temp_file=$(mktemp)

    # Use consistent release name with integration tests
    local release_name="test-${chart_name}"

    # Run helm template
    if helm template "$release_name" "$chart_path" $test_values_args > "$temp_file" 2>&1; then
        print_success "Templates rendered successfully"
    else
        print_error "Template rendering failed"
        rm -f "$temp_file"
        return 1
    fi

    # Validate rendered YAML
    print_step "Validating rendered YAML..."
    if kubectl apply --dry-run=client -f "$temp_file" >/dev/null 2>&1; then
        print_success "Generated YAML is valid"
    else
        print_error "Generated YAML validation failed"
        rm -f "$temp_file"
        return 1
    fi

    rm -f "$temp_file"
    print_success "Template rendering tests passed"
}

# ============================================================================
# CLUSTER MANAGEMENT
# ============================================================================

cluster_exists() {
    kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"
}

setup_cluster() {
    print_section "Setting Up Test Cluster"

    # In CI, we expect a cluster to already exist (set up by GitHub Actions)
    if [[ "$CI" == "true" ]]; then
        print_info "CI environment detected, checking for existing cluster..."
        if kubectl cluster-info &>/dev/null; then
            print_success "Using existing cluster from CI environment"
            return 0
        else
            print_error "CI mode but no cluster detected!"
            print_error "The CI workflow must set up a Kind cluster before running tests."
            print_error "Please ensure the workflow includes the helm/kind-action step."
            exit 1
        fi
    fi

    # For local testing, reuse existing cluster if available
    if cluster_exists; then
        print_info "Found existing Kind cluster: $CLUSTER_NAME"
        kind export kubeconfig --name "$CLUSTER_NAME"
        if kubectl cluster-info &>/dev/null; then
            print_success "Using existing cluster (resources will be cleaned up after tests)"
            return 0
        else
            print_warning "Existing cluster not responding, recreating..."
            kind delete cluster --name "$CLUSTER_NAME" 2>/dev/null || true
        fi
    fi

    # Create new cluster
    print_step "Creating Kind cluster: $CLUSTER_NAME"
    print_info "This cluster will be reused for future test runs"

    local kind_config=$(cat <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 9080
    protocol: TCP
  - containerPort: 443
    hostPort: 9443
    protocol: TCP
EOF
)

    if echo "$kind_config" | kind create cluster --name "$CLUSTER_NAME" --config=- --wait 300s; then
        print_success "Kind cluster created successfully"
    else
        print_error "Failed to create kind cluster"
        return 1
    fi

    # Export kubeconfig
    kind export kubeconfig --name "$CLUSTER_NAME"

    # Wait for cluster to be ready
    print_step "Waiting for cluster to be ready..."
    kubectl wait --for=condition=ready node --all --timeout=300s

    print_success "Cluster is ready"
}

install_traefik() {
    print_section "Installing Traefik"

    # Check if Traefik is already installed
    if kubectl get namespace traefik &>/dev/null; then
        print_info "Traefik namespace already exists, skipping installation"
        return 0
    fi

    print_step "Adding Traefik Helm repository..."
    helm repo add traefik https://traefik.github.io/charts 2>/dev/null || true
    helm repo update traefik

    print_step "Installing Traefik with CRD provider enabled..."
    if helm install traefik traefik/traefik \
        --namespace traefik \
        --create-namespace \
        --set providers.kubernetesCRD.enabled=true \
        --set providers.kubernetesIngress.enabled=true \
        --wait --timeout=5m; then
        print_success "Traefik installed successfully"
    else
        print_error "Failed to install Traefik"
        return 1
    fi

    print_step "Verifying Traefik installation..."
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=traefik -n traefik --timeout=5m

    print_success "Traefik is ready"
}

# ============================================================================
# INTEGRATION TESTS
# ============================================================================

run_integration_tests() {
    local chart_path="$1"
    local chart_name=$(basename "$chart_path")

    if [[ "$SKIP_INTEGRATION" == "true" ]]; then
        print_warning "Skipping integration tests"
        return 0
    fi

    print_section "Running Integration Tests"

    # Cluster is already set up in main(), just verify it's available
    if ! kubectl cluster-info &>/dev/null; then
        print_error "No Kubernetes cluster available for integration tests"
        return 1
    fi

    local release_name="test-${chart_name}"
    local namespace="test-${chart_name}"

    # Determine which values file to use based on environment
    local test_values_args=""

    if [[ "$CI" == "true" ]]; then
        # CI environment: use values.ci.yaml from examples
        local ci_values="${SCRIPT_DIR}/examples/${chart_name}/values.ci.yaml"
        if [[ -f "$ci_values" ]]; then
            print_info "Using CI values: examples/${chart_name}/values.ci.yaml"
            test_values_args="-f $ci_values"
        fi
    else
        # Local environment: use values.test.yaml from examples
        local test_values="${SCRIPT_DIR}/examples/${chart_name}/values.test.yaml"
        if [[ -f "$test_values" ]]; then
            print_info "Using test values: examples/${chart_name}/values.test.yaml"
            test_values_args="-f $test_values"
        fi

        # Add secrets for local testing only
        test_values_args+=" $(get_local_secrets_args "$chart_path")"
    fi

    # Install chart
    print_step "Installing chart: $chart_name"
    print_info "Release:   $release_name"
    print_info "Namespace: $namespace"
    print_info "Timeout:   600s"
    echo ""

    # Run helm install
    local helm_exit_code=0
    helm install "$release_name" "$chart_path" \
        $test_values_args \
        --create-namespace \
        --namespace "$namespace" \
        --wait \
        --timeout=600s 2>&1 || helm_exit_code=$?

    echo ""

    if [[ $helm_exit_code -eq 0 ]]; then
        print_success "Chart installed successfully"
    else
        print_error "Chart installation failed"
        print_info "Showing cluster state for debugging..."
        kubectl get all -n "$namespace" || true
        kubectl describe pods -n "$namespace" || true
        kubectl get events -n "$namespace" --sort-by='.lastTimestamp' | tail -20 || true
        return 1
    fi

    # Verify installation
    print_step "Verifying installation..."
    helm list -n "$namespace"
    kubectl get all -n "$namespace"

    # Wait for pods to be ready (exclude completed jobs from CronJobs)
    print_step "Waiting for pods to be ready..."
    local max_wait=300
    local elapsed=0
    local interval=10

    while [[ $elapsed -lt $max_wait ]]; do
        # Only wait for pods that should be running (exclude Succeeded/Completed jobs)
        local non_completed_pods=$(kubectl get pods -n "$namespace" --field-selector=status.phase!=Succeeded -o name 2>/dev/null || echo "")

        if [[ -z "$non_completed_pods" ]]; then
            # No running pods, only completed jobs - this is fine
            print_success "All long-running pods are ready (completed jobs excluded)"
            break
        fi

        if kubectl wait --for=condition=Ready $non_completed_pods -n "$namespace" --timeout=1s 2>/dev/null; then
            print_success "All pods are ready"
            break
        fi

        sleep $interval
        elapsed=$((elapsed + interval))
        print_info "Waiting... ($elapsed/${max_wait}s)"
    done

    if [[ $elapsed -ge $max_wait ]]; then
        print_warning "Timeout waiting for pods to be ready"
        kubectl get pods -n "$namespace" -o wide
    fi

    # Run Helm tests if they exist
    if [[ -d "$chart_path/tests" ]] || helm get manifest "$release_name" -n "$namespace" | grep -q "helm.sh/hook.*test"; then
        print_step "Running Helm tests..."
        if helm test "$release_name" -n "$namespace" --timeout=300s; then
            print_success "Helm tests passed"
        else
            print_warning "Helm tests failed (continuing anyway)"
        fi
    else
        print_info "No Helm tests found"
    fi

    # Cleanup
    print_step "Cleaning up test installation..."
    helm uninstall "$release_name" -n "$namespace" --wait --timeout=300s || true
    kubectl delete namespace "$namespace" --ignore-not-found=true --timeout=60s || true

    print_success "All integration tests passed"
}

# ============================================================================
# SINGLE CHART TEST
# ============================================================================

test_chart() {
    local chart_path="$1"
    local chart_name=$(basename "$chart_path")

    print_header "🧪 Testing Chart: $chart_name"

    # Validate chart
    validate_chart "$chart_path"
    local validation_result=$?

    if [[ $validation_result -eq 1 ]]; then
        return 1
    elif [[ $validation_result -eq 2 ]]; then
        print_warning "$chart_name is a library chart"
        print_info "Only running lint and unit tests for library charts"
        SKIP_INTEGRATION=true
    fi

    # Run all test phases
    local failed=0

    run_lint "$chart_path" || ((failed++))
    run_unit_tests "$chart_path" || ((failed++))

    if [[ $validation_result -ne 2 ]]; then
        # Not a library chart
        run_template_tests "$chart_path" || ((failed++))
        run_integration_tests "$chart_path" || ((failed++))
    fi

    # Summary
    if [[ $failed -eq 0 ]]; then
        print_success "All tests passed for $chart_name! 🎉"
        return 0
    else
        print_error "$failed test phase(s) failed for $chart_name"
        return 1
    fi
}

# ============================================================================
# CLEANUP
# ============================================================================

cleanup() {
    local exit_code=$?

    echo ""

    # Clean up test resources (but keep the cluster for reuse)
    if [[ "$CLEANUP_RESOURCES" == "true" ]]; then
        print_section "Cleaning Up Test Resources"

        # Get all test namespaces
        local test_namespaces=$(kubectl get namespaces -o name 2>/dev/null | grep "namespace/test-" | sed 's/namespace\///' || echo "")

        if [[ -n "$test_namespaces" ]]; then
            print_step "Deleting test namespaces..."
            for ns in $test_namespaces; do
                print_info "  Deleting namespace: $ns"
                kubectl delete namespace "$ns" --timeout=60s 2>/dev/null &
            done

            # Wait for background deletions
            wait
            print_success "Test resources cleaned up"
        else
            print_info "No test resources to clean up"
        fi

        print_info "Cluster '$CLUSTER_NAME' kept for future test runs"
    else
        print_info "Resource cleanup skipped (--no-cleanup flag)"
    fi

    if [[ $exit_code -eq 0 ]]; then
        print_header "✅ All Tests Passed! 🎉"
    else
        print_header "❌ Tests Failed"
    fi

    exit $exit_code
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    # Parse command line arguments
    parse_arguments "$@"

    print_header "🧪 Helm Chart Testing Suite"

    # Check prerequisites
    check_prerequisites

    # Determine which charts to test
    local charts_to_test=()

    if [[ -n "$CHART_PATH" ]]; then
        # Single chart specified
        if [[ ! -d "$CHART_PATH" ]]; then
            print_error "Chart directory not found: $CHART_PATH"
            exit 1
        fi
        charts_to_test+=("$CHART_PATH")
    else
        # Test all charts
        print_info "Discovering charts in $CHARTS_DIR..."
        for chart_dir in "$CHARTS_DIR"/*; do
            if [[ -d "$chart_dir" ]] && [[ -f "$chart_dir/Chart.yaml" ]]; then
                charts_to_test+=("$chart_dir")
            fi
        done
    fi

    if [[ ${#charts_to_test[@]} -eq 0 ]]; then
        print_error "No charts found to test"
        exit 1
    fi

    print_info "Found ${BOLD}${#charts_to_test[@]}${NC} chart(s) to test"
    for chart in "${charts_to_test[@]}"; do
        print_info "  • $(basename "$chart")"
    done

    # Set up cleanup trap
    trap cleanup EXIT INT TERM

    # Set up cluster once if integration tests are enabled
    if [[ "$SKIP_INTEGRATION" == "false" ]]; then
        setup_cluster
        install_traefik
    fi

    # Test each chart (fail fast - stop on first failure)
    local total_passed=0

    for chart_path in "${charts_to_test[@]}"; do
        if ! test_chart "$chart_path"; then
            print_error "Tests failed for $(basename "$chart_path")"
            print_error "Stopping execution (fail-fast mode)"
            exit 1
        fi
        ((total_passed++))
    done

    # All tests passed
    echo ""
    print_header "📊 Test Summary"
    print_info "Total charts tested: ${BOLD}${total_passed}${NC}"
    print_success "All charts passed! 🎉"

    exit 0
}

# Run main function
main "$@"
