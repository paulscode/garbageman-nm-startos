# ==============================================================================
# Garbageman Nodes Manager - StartOS Build Makefile
# ==============================================================================
# Builds .s9pk package for StartOS 0.3.5.x
# Target architectures: x86_64 (amd64) and aarch64 (arm64)

PKG_ID := $(shell yq -r '.id' manifest.yaml 2>/dev/null || echo "garbageman-nm")
PKG_VERSION := $(shell yq -r '.version' manifest.yaml 2>/dev/null || echo "0.1.0.1")
TS_FILES := $(shell find ./scripts -name "*.ts" 2>/dev/null || echo "")

# Upstream Garbageman source directory (sibling to this wrapper)
GARBAGEMAN_SRC := ../garbageman-nm

# Delete target if recipe fails
.DELETE_ON_ERROR:

# Default target: build and verify package
all: verify

# ==============================================================================
# Verify Package
# ==============================================================================

verify: $(PKG_ID).s9pk
	@echo ""
	@echo "Verifying package with start-sdk..."
	@start-sdk verify s9pk $(PKG_ID).s9pk
	@echo ""
	@echo "✓ Package verified successfully!"
	@echo "  File: $(PKG_ID).s9pk"
	@echo "  Size: $(shell du -h $(PKG_ID).s9pk | cut -f1)"
	@echo ""
	@echo "To install:"
	@echo "  1. Open StartOS web UI → System → Sideload Service"
	@echo "  2. Upload $(PKG_ID).s9pk"
	@echo "  3. Or use: start-cli package install $(PKG_ID).s9pk"
	@echo ""

# ==============================================================================
# Install Package to StartOS
# ==============================================================================

install: $(PKG_ID).s9pk
	@if [ ! -f ~/.embassy/config.yaml ]; then \
		echo "Error: ~/.embassy/config.yaml not found"; \
		echo "Create it with: echo 'host: http://your-startos.local' > ~/.embassy/config.yaml"; \
		exit 1; \
	fi
	@echo ""
	@echo "Installing to $$(grep -v '^#' ~/.embassy/config.yaml | cut -d'/' -f3)..."
	@start-cli package install $(PKG_ID).s9pk
	@echo ""
	@echo "✓ Installation complete!"
	@echo ""

# ==============================================================================
# Clean Build Artifacts
# ==============================================================================

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf docker-images
	@rm -f $(PKG_ID).s9pk
	@rm -f image.tar
	@rm -f scripts/*.js
	@echo "✓ Clean complete"

# ==============================================================================
# Bundle TypeScript Scripts (if using Deno scripting API)
# ==============================================================================

scripts/embassy.js: $(TS_FILES)
	@if [ -n "$(TS_FILES)" ] && command -v deno >/dev/null 2>&1; then \
		echo "Bundling TypeScript scripts with Deno..."; \
		deno run --allow-read --allow-write --allow-env --allow-net scripts/bundle.ts; \
	else \
		echo "Skipping script bundling (no scripts or deno not installed)"; \
		touch scripts/embassy.js; \
	fi

# ==============================================================================
# Check Prerequisites
# ==============================================================================

check-prereqs:
	@echo "Checking build prerequisites..."
	@command -v docker >/dev/null 2>&1 || (echo "Error: docker not found" && exit 1)
	@command -v start-sdk >/dev/null 2>&1 || (echo "Error: start-sdk not found" && exit 1)
	@command -v yq >/dev/null 2>&1 || (echo "Warning: yq not found, using defaults")
	@docker buildx version >/dev/null 2>&1 || (echo "Error: docker buildx not available" && exit 1)
	@[ -d "$(GARBAGEMAN_SRC)" ] || (echo "Error: Garbageman source not found at $(GARBAGEMAN_SRC)" && exit 1)
	@echo "✓ Prerequisites OK"

# ==============================================================================
# Build Docker Images
# ==============================================================================

# Prepare build context (shared by both architectures)
.PHONY: prepare-build-context
prepare-build-context:
	@echo "Preparing build context..."
	@rm -rf garbageman-nm webui multi-daemon docker-images-copy seeds envfiles docker_entrypoint.sh supervisord.conf
	@mkdir -p docker-images
	@echo "Copying Garbageman source..."
	@cp -r $(GARBAGEMAN_SRC)/webui ./webui
	@cp -r $(GARBAGEMAN_SRC)/multi-daemon ./multi-daemon
	@cp -r $(GARBAGEMAN_SRC)/docker-images ./docker-images-copy
	@cp -r $(GARBAGEMAN_SRC)/seeds ./seeds
	@cp -r $(GARBAGEMAN_SRC)/envfiles ./envfiles
	@echo "Copying wrapper-specific files..."
	@cp $(GARBAGEMAN_SRC)/docker-images/docker-entrypoint.sh ./docker_entrypoint.sh
	@cp $(GARBAGEMAN_SRC)/docker-images/supervisord.startos.conf ./supervisord.conf

# Build x86_64 Docker image
docker-images/x86_64.tar: check-prereqs Dockerfile manifest.yaml
	@$(MAKE) prepare-build-context
	@echo ""
	@echo "=========================================================================="
	@echo "Building Docker image for x86_64..."
	@echo "=========================================================================="
	@echo ""
	@docker buildx build \
		--tag start9/$(PKG_ID)/main:$(PKG_VERSION) \
		--platform=linux/amd64 \
		--build-arg WRAPPER_TYPE=startos \
		--build-arg VERSION=$(PKG_VERSION) \
		--output type=docker,dest=docker-images/x86_64.tar \
		.
	@echo ""
	@echo "✓ x86_64 Docker image built successfully"
	@echo "  Size: $(shell du -h docker-images/x86_64.tar 2>/dev/null | cut -f1 || echo 'N/A')"
	@echo ""

# Build aarch64 Docker image
docker-images/aarch64.tar: check-prereqs Dockerfile manifest.yaml
	@$(MAKE) prepare-build-context
	@echo ""
	@echo "=========================================================================="
	@echo "Building Docker image for aarch64..."
	@echo "=========================================================================="
	@echo ""
	@docker buildx build \
		--tag start9/$(PKG_ID)/main:$(PKG_VERSION) \
		--platform=linux/arm64 \
		--build-arg WRAPPER_TYPE=startos \
		--build-arg VERSION=$(PKG_VERSION) \
		--output type=docker,dest=docker-images/aarch64.tar \
		.
	@echo ""
	@echo "✓ aarch64 Docker image built successfully"
	@echo "  Size: $(shell du -h docker-images/aarch64.tar 2>/dev/null | cut -f1 || echo 'N/A')"
	@echo ""

# Clean build context after building both images
.PHONY: clean-build-context
clean-build-context:
	@rm -rf webui multi-daemon docker-images-copy seeds envfiles docker_entrypoint.sh supervisord.conf

# ==============================================================================
# Package .s9pk
# ==============================================================================

$(PKG_ID).s9pk: manifest.yaml instructions.md icon.png LICENSE docker-images/x86_64.tar docker-images/aarch64.tar assets/compat/config_spec.yaml scripts/embassy.js
	@echo ""
	@echo "=========================================================================="
	@echo "Packaging $(PKG_ID).s9pk..."
	@echo "=========================================================================="
	@echo ""
	@echo "Package ID:      $(PKG_ID)"
	@echo "Version:         $(PKG_VERSION)"
	@echo "Architectures:   x86_64, aarch64"
	@echo ""
	@start-sdk pack
	@$(MAKE) clean-build-context
	@echo ""
	@echo "✓ Package created successfully: $(PKG_ID).s9pk"
	@echo ""

# ==============================================================================
# Quick Build (alias for main build - kept for compatibility)
# ==============================================================================

quick: $(PKG_ID).s9pk
	@echo "✓ Build complete: $(PKG_ID).s9pk (x86_64 + aarch64)"

# ==============================================================================
# Development Helpers
# ==============================================================================

# Show build info
info:
	@echo "Package Info:"
	@echo "  ID:         $(PKG_ID)"
	@echo "  Version:    $(PKG_VERSION)"
	@echo "  Source:     $(GARBAGEMAN_SRC)"
	@echo "  Platforms:  x86_64 (amd64), aarch64 (arm64)"
	@echo ""
	@echo "Targets:"
	@echo "  make         - Build and verify package (both architectures)"
	@echo "  make verify  - Verify package integrity"
	@echo "  make install - Install to StartOS (requires start-cli config)"
	@echo "  make clean   - Remove build artifacts"
	@echo "  make info    - Show this help"
	@echo ""

.PHONY: all verify install clean check-prereqs quick info prepare-build-context clean-build-context
