#!/bin/bash

# SwiftMockGenerator Build Script

set -e

echo "🔨 Building SwiftMockGenerator..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build

# Build the project
echo "⚙️  Building executable..."
swift build -c release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "📦 Executable created at: .build/release/swift-mock-generator"
    echo ""
    echo "💡 To install globally, run:"
    echo "   sudo cp .build/release/swift-mock-generator /usr/local/bin/"
    echo ""
    echo "🚀 To test with example code:"
    echo "   ./.build/release/swift-mock-generator Examples/ExampleCode.swift --verbose"
else
    echo "❌ Build failed!"
    exit 1
fi