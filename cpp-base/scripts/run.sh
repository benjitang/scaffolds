#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

# Handle --clean flag
if [ "$1" == "--clean" ]; then
    echo "Cleaning build directory..."
    rm -rf build
    shift
fi

# Handle --format flag
if [ "$1" == "--format" ]; then
    echo "Formatting source files..."
    find src -regex '.*\.\(cpp\|hpp\|h\)' -exec clang-format -i {} \;
    shift
fi

# Configure quietly, only if build dir doesn't exist yet
if [ ! -d "build" ]; then
    cmake -S . -B build > /dev/null
fi

# Build quietly, but show output if it fails
if ! cmake --build build > /tmp/cpprun-build.log 2>&1; then
    echo "Build failed:"
    cat /tmp/cpprun-build.log
    exit 1
fi

EXECUTABLE="bin/cpp-base"

if [ -f "$EXECUTABLE" ]; then
    "$EXECUTABLE" "$@"
else
    echo "Executable not found at $EXECUTABLE"
    exit 1
fi