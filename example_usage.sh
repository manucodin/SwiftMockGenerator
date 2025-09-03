#!/bin/bash

# SwiftMockGenerator Example Usage Script

set -e

echo "🧪 SwiftMockGenerator Example Usage"
echo ""

# Ensure the tool is built
if [ ! -f ".build/release/swift-mock-generator" ]; then
    echo "⚠️  Executable not found. Building first..."
    ./build.sh
fi

# Create Examples directory if it doesn't exist
mkdir -p Examples

# Run the mock generator on the example file
echo "🎯 Generating mocks from Examples/ExampleCode.swift..."
./.build/release/swift-mock-generator Examples/ExampleCode.swift --output Generated --verbose

echo ""
echo "✅ Mock generation completed!"
echo ""

# Show generated files
if [ -d "Generated" ]; then
    echo "📁 Generated mock files:"
    ls -la Generated/
    echo ""
    
    echo "🔍 Example of generated stub:"
    if ls Generated/*Stub*.swift 1> /dev/null 2>&1; then
        echo "--- Content of first stub file ---"
        head -20 Generated/*Stub*.swift | head -20
        echo ""
    fi
    
    echo "🔍 Example of generated spy:"
    if ls Generated/*Spy*.swift 1> /dev/null 2>&1; then
        echo "--- Content of first spy file ---"
        head -20 Generated/*Spy*.swift | head -20
        echo ""
    fi
else
    echo "⚠️  No Generated directory found. Check for errors above."
fi

echo "🎉 Done! Check the Generated/ directory for your mock files."