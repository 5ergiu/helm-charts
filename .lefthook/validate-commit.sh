#!/bin/sh
# ============================================================================
# 📝 Conventional Commit Message Checker https://conventionalcommits.org
# ============================================================================
# Enforces the Conventional Commits format for all Git commit messages.
# Triggered by Lefthook via the `commit-msg` hook.
# ============================================================================
# Example format:
#   feat: implement login flow
#
# Allowed types:
#   feat, fix, refactor, perf, docs, test, build, style, chore, revert
# ============================================================================

# Read the commit message
commit_msg=$(cat "$1")

# Define your allowed types and scopes
types="feat|fix|refactor|perf|docs|test|build|style|chore|revert"
scopes="api|ui|core|deps|config|ci|security|ci|scripts"

# Regex breakdown:
# 1. Start with one of the types
# 2. Optional: (one of the scopes)
# 3. Mandatory: Colon and a space
# 4. Mandatory: Description text
regex="^($types)(\(($scopes)\))?: .+$"

if echo "$commit_msg" | grep -Eq "$regex"; then
  echo "✓ Commit message is valid."
  exit 0
else
  echo "✗ ERROR: Invalid commit message format or scope!"
  echo ""
  echo "Expected: type(scope?): description"
  echo ""
  echo "Allowed Types:  $types"
  echo "Allowed Scopes: $scopes"
  echo ""
  echo "Example: feat(api): add user lookup endpoint"
  echo ""
  exit 1
fi
