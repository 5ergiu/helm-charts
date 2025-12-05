#!/usr/bin/env bash
# ============================================================================
# 📝 Generate Changelog
# ============================================================================
# Generates changelogs based on git history and PR information for Helm charts.
# Works for both PRs from forks and branches within the main repository.
# Updates CHANGELOG.md and Chart.yaml artifacthub.io/changes annotation.
# ============================================================================
# Usage:
#   ./scripts/generate-changelog.sh [OPTIONS]
#
# Examples:
#   ./scripts/generate-changelog.sh --chart my-chart
#   ./scripts/generate-changelog.sh --chart nginx --chart redis
#   ./scripts/generate-changelog.sh --all
#   ./scripts/generate-changelog.sh --chart my-chart --pr-title "Fix bug" --pr-number 123 --pr-url "https://github.com/org/repo/pull/123"
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CHART_NAMES=()
PR_TITLE=""
PR_NUMBER=""
PR_URL=""
GENERATE_ALL=false
COMMIT_LIMIT=8

# ============================================================================
# DEPENDENCY CHECKS
# ============================================================================

check_dependencies() {
    print_step "Checking dependencies..."
    
    local missing_deps=()
    
    command -v yq &> /dev/null || missing_deps+=("yq")
    command -v git &> /dev/null || missing_deps+=("git")
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        echo ""
        print_info "Install with:"
        for dep in "${missing_deps[@]}"; do
            case $dep in
                yq)
                    echo -e "  ${CYAN}brew install yq${RESET}"
                    echo "  Or visit: https://github.com/mikefarah/yq"
                    ;;
                git)
                    echo -e "  ${CYAN}brew install git${RESET}"
                    ;;
            esac
        done
        exit 1
    fi
    
    print_success "All dependencies found!"
}

# ============================================================================
# FORMAT CHANGES FOR ARTIFACTHUB
# ============================================================================

format_changes_for_chart_yaml() {
    local chart_name="$1"
    local pr_title="${2:-}"
    local pr_number="${3:-}"
    local pr_url="${4:-}"
    local chart_dir="${REPO_DIR}/charts/${chart_name}"

    # Create changes array - only include recent changes (latest version)
    local changes_yaml=""
    
    # Add new PR if provided
    if [ -n "$pr_title" ] && [ -n "$pr_number" ] && [ -n "$pr_url" ]; then
        changes_yaml="    - kind: added\n      description: \"${pr_title}\"\n      links:\n        - name: \"PR #${pr_number}\"\n          url: \"${pr_url}\""
    else
        # Get the latest tag for this chart
        local latest_tag
        latest_tag=$(git tag -l "${chart_name}-*" 2>/dev/null | sort -V -r | head -n 1 || true)
        
        if [ -n "$latest_tag" ]; then
            # Get the second latest tag to determine the range
            local prev_tag
            prev_tag=$(git tag -l "${chart_name}-*" 2>/dev/null | sort -V -r | sed -n '2p' || true)
            
            local commit_range
            if [ -n "$prev_tag" ]; then
                commit_range="${prev_tag}..${latest_tag}"
            else
                # If no previous tag, just get commits for the latest tag
                commit_range=$(git log --format=%H "$latest_tag" | tail -1)..${latest_tag}
            fi
            
            # Get recent commits for this chart
            local changes_found=false
            while IFS= read -r commit_line; do
                [ -z "$commit_line" ] && continue
                
                local commit_hash
                commit_hash=$(echo "$commit_line" | cut -d' ' -f1)
                local commit_msg
                commit_msg=$(echo "$commit_line" | cut -d' ' -f2-)
                
                # Skip commits that are clearly for other charts
                if echo "$commit_msg" | grep -qE '^\[[a-z]+\]'; then
                    if ! echo "$commit_msg" | grep -qiE '^\[('"${chart_name}"'|all)\]'; then
                        continue
                    fi
                fi

                # Skip commits that contain "chore", "docs", "typo", "bump" (case insensitive)
                if echo "$commit_msg" | grep -qiE '(chore|docs|typo|bump)'; then
                    continue
                fi
                
                # Clean up commit message
                commit_msg=$(echo "$commit_msg" | sed -E "s/^\[${chart_name}\] //i")
                commit_msg=$(echo "$commit_msg" | sed -E "s/^\[$(echo "${chart_name}" | tr '[:lower:]' '[:upper:]')\] //")
                commit_msg=$(echo "$commit_msg" | sed -E "s/^\[all\] //i")
                
                # Escape quotes in commit message for YAML
                commit_msg=$(echo "$commit_msg" | sed 's/"/\\"/g')
                
                # Add to changes (limit to first few)
                if [ "$changes_found" = false ]; then
                    changes_yaml="    - kind: changed\n      description: \"${commit_msg}\"\n      links:\n        - name: \"Commit ${commit_hash:0:8}\"\n          url: \"${GITHUB_REPOSITORY_URL:-https://github.com/${GITHUB_REPOSITORY:-5ergiu/helm-charts}}/commit/${commit_hash}\""
                    changes_found=true
                else
                    changes_yaml="${changes_yaml}\n    - kind: changed\n      description: \"${commit_msg}\"\n      links:\n        - name: \"Commit ${commit_hash:0:8}\"\n          url: \"${GITHUB_REPOSITORY_URL:-https://github.com/${GITHUB_REPOSITORY:-5ergiu/helm-charts}}/commit/${commit_hash}\""
                fi
                
                # Limit to recent changes to keep annotation reasonable
                local change_count
                change_count=$(echo -e "$changes_yaml" | grep -c "kind:" || echo "0")
                if [ "$change_count" -ge "$COMMIT_LIMIT" ]; then
                    break
                fi
            done < <(git log "$commit_range" --oneline --no-merges -- "$chart_dir" 2>/dev/null | head -3 || true)
            
            if [ "$changes_found" = false ]; then
                changes_yaml="    - kind: changed\n      description: \"Chart updated\""
            fi
        else
            # No tags found, create a basic entry
            changes_yaml="    - kind: added\n      description: \"Initial chart release\""
        fi
    fi
    
    echo -e "$changes_yaml"
}

# ============================================================================
# UPDATE CHART.YAML WITH CHANGES
# ============================================================================

update_chart_yaml_changes() {
    local chart_yaml="$1"
    local changes_content="$2"
    
    # Create a temporary file for the updated Chart.yaml
    local temp_chart_yaml
    temp_chart_yaml=$(mktemp)
    
    # Check if the file already has artifacthub.io/changes annotation
    if grep -q "artifacthub.io/changes:" "$chart_yaml"; then
        # Remove existing artifacthub.io/changes annotation and its content
        yq eval 'del(.annotations."artifacthub.io/changes")' "$chart_yaml" > "$temp_chart_yaml"
    else
        cp "$chart_yaml" "$temp_chart_yaml"
    fi
    
    # Add the new artifacthub.io/changes annotation
    local temp_changes
    temp_changes=$(mktemp)
    echo -e "$changes_content" > "$temp_changes"
    
    # Use yq to add the changes annotation
    yq eval '.annotations."artifacthub.io/changes" = load_str("'"$temp_changes"'")' "$temp_chart_yaml" > "${temp_chart_yaml}.new"
    mv "${temp_chart_yaml}.new" "$temp_chart_yaml"
    
    # Replace the original file
    mv "$temp_chart_yaml" "$chart_yaml"
    
    # Clean up temporary files
    rm -f "$temp_changes"
    
    print_info "Updated artifacthub.io/changes annotation in Chart.yaml"
}

# ============================================================================
# GENERATE CHANGELOG FOR SINGLE CHART
# ============================================================================

generate_chart_changelog() {
    local chart_name="$1"
    local pr_title="${2:-}"
    local pr_number="${3:-}"
    local pr_url="${4:-}"

    print_step "Processing chart: ${BOLD}${chart_name}${RESET}"

    local chart_dir="${REPO_DIR}/charts/${chart_name}"
    local chart_yaml="${chart_dir}/Chart.yaml"
    local changelog_file="${chart_dir}/CHANGELOG.md"

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

    # Extract version from Chart.yaml
    local chart_version
    chart_version=$(yq eval '.version' "$chart_yaml")

    if [ -z "$chart_version" ]; then
        print_error "Could not extract version from $chart_yaml"
        return 1
    fi

    print_info "Chart version: ${BOLD}${chart_version}${RESET}"

    # Create temporary file for new changelog
    local temp_changelog
    temp_changelog=$(mktemp)

    # Start with header
    echo "# Changelog" > "$temp_changelog"
    echo "" >> "$temp_changelog"

    # Add new version entry if PR info is provided
    if [ -n "$pr_title" ] && [ -n "$pr_number" ] && [ -n "$pr_url" ]; then
        local current_date
        current_date=$(date +'%Y-%m-%d')

        echo "## $chart_version ($current_date)" >> "$temp_changelog"
        echo "" >> "$temp_changelog"
        echo "* ${pr_title} ([#${pr_number}](${pr_url}))" >> "$temp_changelog"

        print_info "Added new version entry: ${GREEN}$chart_version${RESET} ($current_date)"
    fi

    # Get all tags for this chart, sorted by version (newest first)
    local chart_tags
    chart_tags=$(git tag -l "${chart_name}-*" 2>/dev/null | sort -V -r || true)

    if [ -z "$chart_tags" ]; then
        print_warning "No tags found for chart: $chart_name"
    else
        print_info "Found tags for ${BOLD}$chart_name${RESET}"

        # Convert tags to array for easier processing
        local tags_array=()
        while IFS= read -r tag; do
            [ -n "$tag" ] && tags_array+=("$tag")
        done <<< "$chart_tags"

        # Process each tag to generate historical entries
        for i in "${!tags_array[@]}"; do
            local tag="${tags_array[$i]}"
            local prev_older_tag=""

            # Get the previous (older) tag - one position back in the array
            if [ $i -lt $((${#tags_array[@]} - 1)) ]; then
                prev_older_tag="${tags_array[$((i+1))]}"
            fi

            # Get the tag version (strip chart name prefix)
            local tag_version="${tag#${chart_name}-}"

            # Get tag date
            local tag_date
            tag_date=$(git log -1 --format=%ai "$tag" 2>/dev/null | cut -d' ' -f1 || echo "unknown")

            echo "" >> "$temp_changelog"
            echo "## $tag_version ($tag_date)" >> "$temp_changelog"
            echo "" >> "$temp_changelog"

            # Determine commit range
            local commit_range
            if [ -z "$prev_older_tag" ]; then
                # This is the oldest tag - don't show full history
                echo "* Initial tagged release" >> "$temp_changelog"
                continue
            else
                # Get commits between the previous older tag and this tag
                commit_range="${prev_older_tag}..${tag}"
            fi

            # Get commits that touched this chart's directory
            local commits_found=false
            while IFS= read -r commit_line; do
                [ -z "$commit_line" ] && continue
                commits_found=true

                local commit_hash
                commit_hash=$(echo "$commit_line" | cut -d' ' -f1)

                local commit_msg
                commit_msg=$(echo "$commit_line" | cut -d' ' -f2-)

                # Skip commits that are clearly for other charts
                if echo "$commit_msg" | grep -qE '^\[[a-z]+\]'; then
                    if ! echo "$commit_msg" | grep -qiE '^\[('"${chart_name}"'|all)\]'; then
                        continue
                    fi
                fi

                # Remove chart name prefix from commit message (case insensitive)
                commit_msg=$(echo "$commit_msg" | sed -E "s/^\[${chart_name}\] //i")
                commit_msg=$(echo "$commit_msg" | sed -E "s/^\[$(echo "${chart_name}" | tr '[:lower:]' '[:upper:]')\] //")
                commit_msg=$(echo "$commit_msg" | sed -E "s/^\[all\] //i")

                # Add commit to changelog with link
                local repo_url="${GITHUB_REPOSITORY_URL:-https://github.com/${GITHUB_REPOSITORY:-5ergiu/helm-charts}}"
                echo "* ${commit_msg} ([${commit_hash}](${repo_url}/commit/${commit_hash}))" >> "$temp_changelog"
            done < <(git log "$commit_range" --oneline --no-merges -- "$chart_dir" 2>/dev/null || true)

            if [ "$commits_found" = false ]; then
                # No commits found for this tag, add a placeholder
                echo "* No changes recorded" >> "$temp_changelog"
            fi
        done
    fi

    # Replace old changelog with new one
    mv "$temp_changelog" "$changelog_file"

    print_success "Changelog updated: ${BOLD}$changelog_file${RESET}"
    
    # Update Chart.yaml with artifacthub.io/changes annotation
    local changes_for_chart_yaml
    changes_for_chart_yaml=$(format_changes_for_chart_yaml "$chart_name" "$pr_title" "$pr_number" "$pr_url")
    
    if [ -n "$changes_for_chart_yaml" ]; then
        update_chart_yaml_changes "$chart_yaml" "$changes_for_chart_yaml"
        print_success "Chart.yaml updated with artifacthub.io/changes annotation"
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

    for chart_name in "${chart_names[@]}"; do
        echo ""
        if generate_chart_changelog "$chart_name" "$PR_TITLE" "$PR_NUMBER" "$PR_URL"; then
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
    echo "  Generates changelogs based on git history and PR information"
    echo "  Updates CHANGELOG.md and Chart.yaml artifacthub.io/changes annotation"
    echo ""
    echo "Options:"
    echo "  --chart CHART_NAME     Generate changelog for specific chart (can be specified multiple times)"
    echo "  --pr-title TITLE       PR title to add to changelog"
    echo "  --pr-number NUMBER     PR number for reference"
    echo "  --pr-url URL           PR URL for linking"
    echo "  --all                  Generate changelogs for all charts"
    echo "  --help, -h             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --chart my-chart"
    echo "  $0 --chart nginx --chart redis"
    echo "  $0 --chart my-chart --pr-title 'Fix bug' --pr-number 123 --pr-url 'https://github.com/org/repo/pull/123'"
    echo "  $0 --all"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --chart)
            CHART_NAMES+=("$2")
            shift 2
            ;;
        --pr-title)
            PR_TITLE="$2"
            shift 2
            ;;
        --pr-number)
            PR_NUMBER="$2"
            shift 2
            ;;
        --pr-url)
            PR_URL="$2"
            shift 2
            ;;
        --all)
            GENERATE_ALL=true
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
    print_header "📝 Changelog Generator"
    
    # Check dependencies
    check_dependencies
    
    # If --all flag is set, find all charts
    if [ "$GENERATE_ALL" = true ]; then
        print_step "Discovering all charts..."
        while IFS= read -r chart_dir; do
            local chart_name
            chart_name=$(basename "$chart_dir")
            # Skip 'common' chart
            if [ "$chart_name" != "common" ]; then
                CHART_NAMES+=("$chart_name")
            fi
        done < <(find "${REPO_DIR}/charts" -mindepth 1 -maxdepth 1 -type d ! -name 'common')
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
        print_success "All changelogs generated successfully!"
        echo ""
        exit 0
    else
        echo ""
        print_error "Some changelog generations failed"
        echo ""
        exit 1
    fi
}

main
