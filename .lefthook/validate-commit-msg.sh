#!/bin/sh
# ============================================================================
# 📝 Conventional Commit Message Checker
# ============================================================================
# Enforces the Conventional Commits format for all Git commit messages.
# Triggered by Lefthook via the `commit-msg` hook.
# ============================================================================
# Example format:
#   feat(auth): implement login flow
#
# Allowed types:
#   feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
# ============================================================================

# Read the commit message
commit_msg=$(cat "$1")

# Conventional Commit regex:
# type(scope?): description
regex='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-zA-Z0-9_-]+\))?: .+$'

if echo "$commit_msg" | grep -Eq "$regex"; then
  echo "✓ Commit message is valid."
  exit 0
else
  echo "✗ ERROR: Invalid commit message!"
  echo ""
  echo "Your commit must follow Conventional Commits:"
  echo "  type(scope?): description"
  echo ""
  echo "Accepted types:"
  echo "  feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert"
  echo ""
  echo "Example:"
  echo "  feat(api): add user lookup endpoint"
  echo ""
  exit 1
fi
