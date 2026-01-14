#!/bin/bash
#
# Local CI Script for iclf_parser
# Run before commits to catch issues early and save CI tokens.
#
# Usage:
#   ./scripts/ci.sh           # Run all checks
#   ./scripts/ci.sh format    # Check formatting only
#   ./scripts/ci.sh analyze   # Run analyzer only
#   ./scripts/ci.sh test      # Run tests with coverage
#   ./scripts/ci.sh coverage  # Check coverage threshold
#   ./scripts/ci.sh all       # Full suite (same as no args)
#   ./scripts/ci.sh quick     # Fast check: format + analyze only
#

set -e  # Exit on first error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COVERAGE_THRESHOLD=95
COVERAGE_DIR="coverage"

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check if dart is available
check_dart() {
    if ! command -v dart &> /dev/null; then
        print_error "Dart SDK not found. Please install Dart first."
        exit 1
    fi
}

# Get dependencies
get_deps() {
    print_header "Getting Dependencies"
    dart pub get
    print_success "Dependencies installed"
}

# Format check
check_format() {
    print_header "Checking Code Formatting"
    if dart format --set-exit-if-changed --output=none lib/ bin/ test/ example/ 2>/dev/null; then
        print_success "Code formatting is correct"
        return 0
    else
        print_error "Code formatting issues found. Run: dart format lib/ bin/ test/ example/"
        return 1
    fi
}

# Static analysis
run_analyze() {
    print_header "Running Static Analysis"
    if dart analyze --fatal-infos; then
        print_success "No analysis issues found"
        return 0
    else
        print_error "Analysis issues found"
        return 1
    fi
}

# Run tests with coverage
run_tests() {
    print_header "Running Tests"

    # Ensure coverage directory exists
    mkdir -p "$COVERAGE_DIR"

    # Run tests with coverage
    if dart test --coverage="$COVERAGE_DIR"; then
        print_success "All tests passed"
        return 0
    else
        print_error "Some tests failed"
        return 1
    fi
}

# Check coverage threshold
check_coverage() {
    print_header "Checking Code Coverage"

    # Check if coverage data exists
    if [ ! -d "$COVERAGE_DIR" ] || [ -z "$(ls -A $COVERAGE_DIR 2>/dev/null)" ]; then
        print_warning "No coverage data found. Run tests first: ./scripts/ci.sh test"
        return 1
    fi

    # Check if lcov is available for detailed report
    if command -v lcov &> /dev/null; then
        # Generate lcov report
        lcov --capture --directory . --output-file "$COVERAGE_DIR/lcov.info" 2>/dev/null || true

        if [ -f "$COVERAGE_DIR/lcov.info" ]; then
            # Extract coverage percentage
            COVERAGE=$(lcov --summary "$COVERAGE_DIR/lcov.info" 2>&1 | grep "lines" | grep -oP '\d+\.\d+' | head -1)

            if [ -n "$COVERAGE" ]; then
                COVERAGE_INT=${COVERAGE%.*}

                if [ "$COVERAGE_INT" -ge "$COVERAGE_THRESHOLD" ]; then
                    print_success "Coverage: ${COVERAGE}% (threshold: ${COVERAGE_THRESHOLD}%)"
                    return 0
                else
                    print_error "Coverage: ${COVERAGE}% is below threshold of ${COVERAGE_THRESHOLD}%"
                    return 1
                fi
            fi
        fi
    fi

    # Fallback: check if coverage package is available
    if dart pub deps 2>/dev/null | grep -q "coverage"; then
        print_warning "For detailed coverage, install lcov: brew install lcov (macOS) or apt install lcov (Linux)"
    else
        print_warning "Add 'coverage' package to dev_dependencies for coverage reports"
    fi

    print_warning "Coverage check skipped - install lcov for threshold enforcement"
    return 0
}

# Generate coverage report (optional)
generate_coverage_report() {
    print_header "Generating Coverage Report"

    if ! command -v genhtml &> /dev/null; then
        print_warning "genhtml not found. Install lcov for HTML reports."
        return 0
    fi

    if [ -f "$COVERAGE_DIR/lcov.info" ]; then
        genhtml "$COVERAGE_DIR/lcov.info" -o "$COVERAGE_DIR/html" 2>/dev/null
        print_success "Coverage report generated: $COVERAGE_DIR/html/index.html"
    else
        print_warning "No lcov.info found. Run tests with coverage first."
    fi
}

# Dry run pub publish
check_publish() {
    print_header "Checking Publish Readiness"
    if dart pub publish --dry-run; then
        print_success "Package is ready for publishing"
        return 0
    else
        print_error "Package has publishing issues"
        return 1
    fi
}

# Full CI suite
run_all() {
    local failed=0

    get_deps

    check_format || failed=1
    run_analyze || failed=1
    run_tests || failed=1
    check_coverage || failed=1

    print_header "Summary"

    if [ $failed -eq 0 ]; then
        print_success "All checks passed!"
        echo ""
        echo -e "${GREEN}Ready to commit.${NC}"
    else
        print_error "Some checks failed. Please fix issues before committing."
        exit 1
    fi
}

# Quick check (format + analyze only)
run_quick() {
    local failed=0

    get_deps
    check_format || failed=1
    run_analyze || failed=1

    print_header "Quick Check Summary"

    if [ $failed -eq 0 ]; then
        print_success "Quick checks passed!"
    else
        print_error "Quick checks failed."
        exit 1
    fi
}

# Main
check_dart

case "${1:-all}" in
    format)
        get_deps
        check_format
        ;;
    analyze)
        get_deps
        run_analyze
        ;;
    test)
        get_deps
        run_tests
        ;;
    coverage)
        check_coverage
        ;;
    report)
        generate_coverage_report
        ;;
    publish)
        check_publish
        ;;
    quick)
        run_quick
        ;;
    all|"")
        run_all
        ;;
    help|--help|-h)
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  format    - Check code formatting"
        echo "  analyze   - Run static analysis"
        echo "  test      - Run tests with coverage"
        echo "  coverage  - Check coverage threshold (${COVERAGE_THRESHOLD}%)"
        echo "  report    - Generate HTML coverage report"
        echo "  publish   - Dry-run pub publish"
        echo "  quick     - Fast check (format + analyze only)"
        echo "  all       - Run full CI suite (default)"
        echo "  help      - Show this help"
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Run '$0 help' for usage information."
        exit 1
        ;;
esac
