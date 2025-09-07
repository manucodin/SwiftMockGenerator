# SwiftMockGenerator Makefile
# Simple installation, testing, and uninstallation commands

# Configuration
TOOL_NAME = swift-mock-generator
INSTALL_PATH = /usr/local/bin
BUILD_PATH = .build/release/$(TOOL_NAME)
PROJECT_DIR = $(shell pwd)

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help install uninstall test build clean coverage demo

# Default target
help:
	@echo "$(GREEN)SwiftMockGenerator Makefile$(NC)"
	@echo "=================================="
	@echo ""
	@echo "Available commands:"
	@echo "  $(YELLOW)make install$(NC)     - Build and install swift-mock-generator to $(INSTALL_PATH)"
	@echo "  $(YELLOW)make uninstall$(NC)   - Remove swift-mock-generator from $(INSTALL_PATH)"
	@echo "  $(YELLOW)make test$(NC)        - Run all tests"
	@echo "  $(YELLOW)make coverage$(NC)    - Run tests with coverage report"
	@echo "  $(YELLOW)make build$(NC)       - Build the project in release mode"
	@echo "  $(YELLOW)make clean$(NC)       - Clean build artifacts"
	@echo "  $(YELLOW)make demo$(NC)        - Run demo with example files"
	@echo "  $(YELLOW)make help$(NC)        - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make install     # Install tool system-wide"
	@echo "  make test        # Run test suite"
	@echo "  make demo        # See the tool in action"

# Build the project in release mode
build:
	@echo "$(GREEN)🔨 Building SwiftMockGenerator in release mode...$(NC)"
	swift build -c release
	@echo "$(GREEN)✅ Build completed successfully!$(NC)"

# Install the tool system-wide
install: build
	@echo "$(GREEN)📦 Installing swift-mock-generator to $(INSTALL_PATH)...$(NC)"
	@if [ ! -f "$(BUILD_PATH)" ]; then \
		echo "$(RED)❌ Error: Build artifact not found at $(BUILD_PATH)$(NC)"; \
		echo "$(YELLOW)💡 Try running 'make build' first$(NC)"; \
		exit 1; \
	fi
	@if [ ! -w "$(INSTALL_PATH)" ]; then \
		echo "$(YELLOW)🔑 Installing with sudo (requires admin privileges)...$(NC)"; \
		sudo cp "$(BUILD_PATH)" "$(INSTALL_PATH)/$(TOOL_NAME)"; \
		sudo chmod +x "$(INSTALL_PATH)/$(TOOL_NAME)"; \
	else \
		cp "$(BUILD_PATH)" "$(INSTALL_PATH)/$(TOOL_NAME)"; \
		chmod +x "$(INSTALL_PATH)/$(TOOL_NAME)"; \
	fi
	@echo "$(GREEN)✅ Installation completed successfully!$(NC)"
	@echo "$(GREEN)🚀 You can now use: $(TOOL_NAME) --help$(NC)"

# Uninstall the tool
uninstall:
	@echo "$(YELLOW)🗑️  Uninstalling swift-mock-generator from $(INSTALL_PATH)...$(NC)"
	@if [ -f "$(INSTALL_PATH)/$(TOOL_NAME)" ]; then \
		if [ -w "$(INSTALL_PATH)" ]; then \
			rm -f "$(INSTALL_PATH)/$(TOOL_NAME)"; \
		else \
			echo "$(YELLOW)🔑 Uninstalling with sudo (requires admin privileges)...$(NC)"; \
			sudo rm -f "$(INSTALL_PATH)/$(TOOL_NAME)"; \
		fi; \
		echo "$(GREEN)✅ Uninstallation completed successfully!$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  $(TOOL_NAME) is not installed at $(INSTALL_PATH)$(NC)"; \
	fi

# Run all tests
test:
	@echo "$(GREEN)🧪 Running SwiftMockGenerator test suite...$(NC)"
	swift test
	@echo "$(GREEN)✅ All tests completed successfully!$(NC)"

# Run tests with coverage
coverage:
	@echo "$(GREEN)📊 Running tests with coverage analysis...$(NC)"
	swift test --enable-code-coverage
	@echo "$(GREEN)📈 Generating coverage report...$(NC)"
	@if [ -f ".build/arm64-apple-macosx/debug/SwiftMockGeneratorPackageTests.xctest/Contents/MacOS/SwiftMockGeneratorPackageTests" ]; then \
		xcrun llvm-cov report .build/arm64-apple-macosx/debug/SwiftMockGeneratorPackageTests.xctest/Contents/MacOS/SwiftMockGeneratorPackageTests \
			-instr-profile=.build/arm64-apple-macosx/debug/codecov/default.profdata \
			Sources/ Tests/ 2>/dev/null || echo "$(YELLOW)⚠️  Coverage report generation failed$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Test executable not found for coverage report$(NC)"; \
	fi
	@echo "$(GREEN)✅ Coverage analysis completed!$(NC)"

# Clean build artifacts
clean:
	@echo "$(YELLOW)🧹 Cleaning build artifacts...$(NC)"
	swift package clean
	rm -rf .build
	@echo "$(GREEN)✅ Clean completed successfully!$(NC)"

# Run demo with example files
demo: build
	@echo "$(GREEN)🚀 Running SwiftMockGenerator demo...$(NC)"
	@echo "$(GREEN)📋 Processing example files...$(NC)"
	swift run $(TOOL_NAME) --input ./Examples/Sources --output ./Examples/Mocks --verbose --clean
	@echo ""
	@echo "$(GREEN)📄 Generated mock files:$(NC)"
	@ls -la Examples/Mocks/ 2>/dev/null || echo "$(YELLOW)⚠️  No mock files found$(NC)"
	@echo ""
	@echo "$(GREEN)🔍 Sample generated mock:$(NC)"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@head -10 Examples/Mocks/*.swift 2>/dev/null | head -10 || echo "$(YELLOW)⚠️  No mock files to display$(NC)"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "$(GREEN)✅ Demo completed successfully!$(NC)"
