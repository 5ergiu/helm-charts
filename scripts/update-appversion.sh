#!/usr/bin/env bash
# ============================================================================
# 📦 Update Chart AppVersion
# ============================================================================
# Updates the appVersion in Chart.yaml with the version extracted from
# image.tag in values.yaml. Designed to be run after generate-changelog.sh
# to keep appVersion in sync with image versions.
# ============================================================================
# Usage:
#   ./scripts/update-appversion.sh [OPTIONS]
#
# Examples:
#   ./scripts/update-appversion.sh --chart laravel
#   ./scripts/update-appversion.sh --chart nginx --chart redis
#   ./scripts/update-appversion.sh --all
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
# GLOBAL VARIABLES
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
UPDATE_ALL=false
CHART_NAMES=()

# ============================================================================
# DEPENDENCY CHECKS
# ============================================================================

check_dependencies() {
    print_step "Checking dependencies..."
    
    local missing_deps=()
    
    command -v yq &> /dev/null || missing_deps+=("yq")
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        echo ""
        print_info "Install with:"
        for dep in "${missing_deps[@]}"; do
            case $dep in
                yq)
                    echo "  ${CYAN}brew install yq${RESET}"
                    echo "  Or visit: https://github.com/mikefarah/yq"
                    ;;
            esac
        done
        exit 1
    fi
    
    print_success "All dependencies found!"
}

# ============================================================================
# VERSION EXTRACTION
# ============================================================================

# Function to extract version from image tag
# This function handles various tag formats and ensures only semantic versions are returned:
# - "1.2.3" -> "1.2.3"
# - "1.2.3@sha256:..." -> "1.2.3"
# - "v1.2.3" -> "1.2.3"
# - "v1.2.3@sha256:..." -> "1.2.3"
# - "1.2.3-alpine" -> "1.2.3" (removes non-semver suffixes)
# - "1.2.3-alpha.1" -> "1.2.3-alpha.1" (keeps semver pre-release)
# - "RELEASE.2025-09-07T16-13-09Z" -> null (not semver)
# - "464e93ac" -> null (not semver)
extract_version_from_tag() {
    local tag="$1"
    
    # Remove quotes if present
    tag=$(echo "$tag" | sed 's/^"//;s/"$//')
    
    # Split by @ to remove digest if present
    tag=$(echo "$tag" | cut -d'@' -f1)
    
    # Remove 'v' prefix if present (but keep it for versions that start with v followed by number)
    if [[ "$tag" =~ ^v[0-9] ]]; then
        tag=$(echo "$tag" | sed 's/^v//')
    fi
    
    # Extract semantic version - prioritize core version (MAJOR.MINOR.PATCH)
    # Only keep pre-release if it follows strict semver rules
    
    # First, try to extract the core version (MAJOR.MINOR.PATCH or MAJOR.MINOR)
    local core_version
    core_version=$(echo "$tag" | grep -oE '^[0-9]+\.[0-9]+(\.[0-9]+)?' || echo "")
    
    if [ -z "$core_version" ]; then
        # No valid core version found
        echo ""
        return
    fi
    
    # If we only have MAJOR.MINOR, convert to MAJOR.MINOR.0 for strict semver compliance
    if [[ "$core_version" =~ ^[0-9]+\.[0-9]+$ ]]; then
        core_version="${core_version}.0"
    fi
    
    # Check if there's anything after the core version
    local remaining_part
    remaining_part=$(echo "$tag" | sed "s/^$(echo "$core_version" | sed 's/\.0$//')//")
    
    if [ -z "$remaining_part" ]; then
        # Just the core version, perfect
        echo "$core_version"
        return
    fi
    
    # Check if the remaining part is a valid semver pre-release/build
    # Valid pre-release: -alpha, -alpha.1, -rc.1, -beta.2 (alphanumeric + hyphen, no leading zeros in numeric parts)
    if [[ "$remaining_part" =~ ^-([a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*)(\+[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*)?$ ]]; then
        local prerelease_part="${BASH_REMATCH[1]}"
        
        # Validate each identifier in pre-release (no leading zeros in numeric identifiers)
        local valid_prerelease=true
        IFS='.' read -ra IDENTIFIERS <<< "$prerelease_part"
        for identifier in "${IDENTIFIERS[@]}"; do
            # Check if it's a numeric identifier with leading zero (invalid)
            if [[ "$identifier" =~ ^0[0-9]+$ ]]; then
                valid_prerelease=false
                break
            fi
            # Check for mixed patterns like "alpine3", "management", "pg17" which are not valid semver
            if [[ "$identifier" =~ [a-zA-Z][0-9] ]] || [[ "$identifier" =~ [0-9][a-zA-Z] ]]; then
                valid_prerelease=false
                break
            fi
            # Check for words like "management", "alpine" (common non-semver suffixes)
            if [[ "$identifier" =~ ^(alpine|management|ubuntu|debian|slim|fat)$ ]]; then
                valid_prerelease=false
                break
            fi
        done
        
        if [ "$valid_prerelease" = true ]; then
            # Valid semver pre-release, keep the full version
            echo "${core_version}${remaining_part}"
        else
            # Invalid pre-release, return just core version
            echo "$core_version"
        fi
    else
        # Not a valid semver pre-release format, return just core version
        echo "$core_version"
    fi
}

# ============================================================================
# CHART PROCESSING
# ============================================================================

update_chart_appversion() {
    local chart_name="$1"
    local chart_dir="${REPO_DIR}/charts/${chart_name}"
    local chart_yaml="${chart_dir}/Chart.yaml"
    local values_yaml="${chart_dir}/values.yaml"

    print_step "Processing chart: ${BOLD}${chart_name}${RESET}"

    # Validate chart directory exists
    if [ ! -d "$chart_dir" ]; then
        print_error "Chart directory not found: $chart_dir"
        return 1
    fi

    # Validate Chart.yaml exists
    if [ ! -f "$chart_yaml" ]; then
        print_error "Chart.yaml not found: $chart_yaml"
        return 1
    fi

    # Validate values.yaml exists
    if [ ! -f "$values_yaml" ]; then
        print_error "values.yaml not found: $values_yaml"
        return 1
    fi

    # Extract current appVersion from Chart.yaml
    local current_app_version
    current_app_version=$(yq eval '.appVersion' "$chart_yaml" 2>/dev/null || echo "null")

    if [ "$current_app_version" = "null" ]; then
        print_warning "No appVersion found in $chart_yaml"
        current_app_version="(not set)"
    fi

    # Extract image tag from values.yaml
    # Try different possible paths for the image tag
    local image_tag=""
    
    # Try image.tag first (most common)
    image_tag=$(yq eval '.image.tag' "$values_yaml" 2>/dev/null || echo "null")
    
    # If not found, try other common patterns
    if [ "$image_tag" = "null" ]; then
        # Try under different sections that might contain image configurations
        for path in \
            '.*.image.tag' \
            '.images.*.tag' \
            '.global.image.tag' \
            '.*.*.image.tag'; do
            
            local temp_tag
            temp_tag=$(yq eval "$path" "$values_yaml" 2>/dev/null | head -1 || echo "null")
            if [ "$temp_tag" != "null" ] && [ -n "$temp_tag" ]; then
                image_tag="$temp_tag"
                print_info "Found image tag at path: $path"
                break
            fi
        done
    fi

    if [ "$image_tag" = "null" ] || [ -z "$image_tag" ]; then
        print_warning "No image tag found in $values_yaml for chart $chart_name"
        print_warning "Skipping appVersion update"
        return 0
    fi

    print_info "Found image tag: ${BOLD}$image_tag${RESET}"

    # Extract version from the image tag
    local new_app_version
    new_app_version=$(extract_version_from_tag "$image_tag")

    if [ -z "$new_app_version" ]; then
        print_warning "Could not extract valid semantic version from image tag: $image_tag"
        print_warning "Skipping appVersion update for chart $chart_name"
        return 0
    fi

    print_info "Extracted semantic version: ${BOLD}$new_app_version${RESET}"

    # Check if appVersion needs to be updated
    if [ "$current_app_version" = "\"$new_app_version\"" ] || [ "$current_app_version" = "$new_app_version" ]; then
        print_success "appVersion is already up to date ($new_app_version)"
        return 0
    fi

    # Update appVersion in Chart.yaml
    print_step "Updating appVersion from ${YELLOW}$current_app_version${RESET} to ${GREEN}$new_app_version${RESET}"
    
    # Use yq to update the appVersion
    if yq eval ".appVersion = \"$new_app_version\"" -i "$chart_yaml"; then
        print_success "Successfully updated appVersion in $chart_yaml"
    else
        print_error "Failed to update appVersion in $chart_yaml"
        return 1
    fi

    return 0
}

# ============================================================================
# PROCESS MULTIPLE CHARTS
# ============================================================================

process_charts() {
    local chart_names=("$@")
    local success_count=0
    local fail_count=0
    local skip_count=0

    for chart_name in "${chart_names[@]}"; do
        # Skip the 'common' chart as it typically doesn't have an image
        if [ "$chart_name" = "common" ]; then
            print_info "Skipping 'common' chart (no image expected)"
            skip_count=$((skip_count + 1))
            continue
        fi

        echo ""
        if update_chart_appversion "$chart_name"; then
            success_count=$((success_count + 1))
        else
            fail_count=$((fail_count + 1))
        fi
    done

    # Summary
    echo ""
    print_header "📊 Summary"
    print_info "Total charts processed: ${BOLD}${#chart_names[@]}${RESET}"
    print_success "Successful: ${BOLD}$success_count${RESET}"
    
    if [ $skip_count -gt 0 ]; then
        print_info "Skipped: ${BOLD}$skip_count${RESET}"
    fi
    
    if [ $fail_count -gt 0 ]; then
        print_error "Failed: ${BOLD}$fail_count${RESET}"
        return 1
    fi

    return 0
}

# ============================================================================
# PARSE COMMAND LINE OPTIONS
# ============================================================================

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Description:"
    echo "  Updates the appVersion in Chart.yaml with the version extracted from image.tag in values.yaml"
    echo "  Designed to be run after generate-changelog.sh to keep appVersion in sync with image versions"
    echo ""
    echo "Options:"
    echo "  --chart CHART_NAME     Update appVersion for specific chart (can be specified multiple times)"
    echo "  --all                  Update appVersion for all charts"
    echo "  --help, -h             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --chart laravel"
    echo "  $0 --chart nginx --chart redis"
    echo "  $0 --all"
    echo ""
    echo "Version Extraction Logic:"
    echo "  - Removes SHA256 digest: '1.2.3@sha256:...' -> '1.2.3'"
    echo "  - Removes 'v' prefix: 'v1.2.3' -> '1.2.3'"
    echo "  - Extracts semantic version only: '1.2.3-alpine' -> '1.2.3'"
    echo "  - Preserves semver pre-release: '1.2.3-alpha.1' -> '1.2.3-alpha.1'"
    echo "  - Skips non-semver tags: 'RELEASE.2025-09-07' -> (skipped)"
    echo "  - Skips git hashes: '464e93ac' -> (skipped)"
    echo ""
    echo "Supported tag paths in values.yaml:"
    echo "  - image.tag (most common)"
    echo "  - *.image.tag"
    echo "  - images.*.tag"
    echo "  - global.image.tag"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --chart)
            CHART_NAMES+=("$2")
            shift 2
            ;;
        --all)
            UPDATE_ALL=true
            shift
            ;;
        --help|-h)
            usage
            ;;
        *)
            print_error "Unknown option: $1"
            echo ""
            usage
            ;;
    esac
done

# ============================================================================
# MAIN
# ============================================================================

main() {
    print_header "📦 Update Chart AppVersion"
    
    # Check dependencies
    check_dependencies
    
    # If --all flag is set, find all charts
    if [ "$UPDATE_ALL" = true ]; then
        print_step "Discovering all charts..."
        while IFS= read -r chart_dir; do
            local chart_name
            chart_name=$(basename "$chart_dir")
            CHART_NAMES+=("$chart_name")
        done < <(find "${REPO_DIR}/charts" -mindepth 1 -maxdepth 1 -type d)
    fi
    
    # Validate we have charts to process
    if [ ${#CHART_NAMES[@]} -eq 0 ]; then
        print_error "No charts specified. Use --chart, --all, or --help"
        exit 1
    fi
    
    print_info "Processing ${BOLD}${#CHART_NAMES[@]}${RESET} chart(s): ${YELLOW}${CHART_NAMES[*]}${RESET}"
    
    # Process charts
    if process_charts "${CHART_NAMES[@]}"; then
        echo ""
        print_success "All updates completed successfully!"
        echo ""
        exit 0
    else
        echo ""
        print_error "Some updates failed"
        echo ""
        exit 1
    fi
}

main
