#!/bin/bash
#
# Setup Git Hooks for iclf_parser
# Installs pre-commit hook to run quick checks before each commit.
#
# Usage: ./scripts/setup-hooks.sh
#

set -e

HOOKS_DIR=".git/hooks"
PRE_COMMIT="$HOOKS_DIR/pre-commit"

# Check if we're in a git repo
if [ ! -d ".git" ]; then
    echo "Error: Not a git repository. Run from project root."
    exit 1
fi

# Create hooks directory if needed
mkdir -p "$HOOKS_DIR"

# Create pre-commit hook
cat > "$PRE_COMMIT" << 'EOF'
#!/bin/bash
#
# Pre-commit hook: runs quick CI checks before allowing commit
#

echo "Running pre-commit checks..."

# Run quick checks (format + analyze)
if ! ./scripts/ci.sh quick; then
    echo ""
    echo "Pre-commit checks failed. Please fix issues before committing."
    echo "To bypass (not recommended): git commit --no-verify"
    exit 1
fi

echo "Pre-commit checks passed!"
EOF

chmod +x "$PRE_COMMIT"

echo "Git hooks installed successfully!"
echo ""
echo "Pre-commit hook will run: ./scripts/ci.sh quick"
echo "This checks formatting and runs static analysis before each commit."
echo ""
echo "To skip hooks (not recommended): git commit --no-verify"
