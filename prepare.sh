#!/bin/bash
# ==============================================================================
# Garbageman Nodes Manager - Build Environment Preparation Script
# ==============================================================================
# Prepares a Debian-based system for building the StartOS package
# This script is executed by Start9 Labs during the submission review process

set -e  # Exit on any error

echo "=========================================================================="
echo "Preparing build environment for Garbageman Nodes Manager"
echo "=========================================================================="
echo ""

# ==============================================================================
# System Package Dependencies
# ==============================================================================

echo "► Installing system packages..."
apt-get update
apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    ca-certificates \
    gnupg \
    lsb-release \
    openssl \
    libssl-dev \
    libc6-dev \
    clang \
    libclang-dev

echo "✓ System packages installed"
echo ""

# ==============================================================================
# yq - YAML processor
# ==============================================================================

echo "► Installing yq..."
if ! command -v yq &> /dev/null; then
    # Install yq for manifest parsing
    YQ_VERSION="v4.35.1"
    YQ_BINARY="yq_linux_amd64"
    wget "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}" -O /usr/local/bin/yq
    chmod +x /usr/local/bin/yq
    echo "✓ yq installed: $(yq --version)"
else
    echo "✓ yq already installed: $(yq --version)"
fi
echo ""

# ==============================================================================
# Docker
# ==============================================================================

echo "► Installing Docker..."
if ! command -v docker &> /dev/null; then
    # Install Docker
    curl -fsSL https://get.docker.com | bash
    
    # Add current user to docker group (for non-root builds)
    usermod -aG docker "$USER" || true
    
    echo "✓ Docker installed: $(docker --version)"
else
    echo "✓ Docker already installed: $(docker --version)"
fi
echo ""

# ==============================================================================
# Docker Buildx
# ==============================================================================

echo "► Setting up Docker Buildx..."
if ! docker buildx version &> /dev/null; then
    echo "Error: Docker buildx not available. Install Docker Desktop or enable buildx."
    exit 1
fi

# Create and use buildx builder
docker buildx create --use --name garbageman-builder 2>/dev/null || docker buildx use garbageman-builder || true
echo "✓ Docker buildx configured"
echo ""

# ==============================================================================
# Cross-Architecture Support
# ==============================================================================

echo "► Enabling cross-architecture emulation..."
docker run --privileged --rm linuxkit/binfmt:v0.8
echo "✓ Multi-arch builds enabled (amd64 + arm64)"
echo ""

# ==============================================================================
# Rust & Cargo
# ==============================================================================

echo "► Installing Rust and Cargo..."
if ! command -v cargo &> /dev/null; then
    # Install Rust toolchain
    curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable
    
    # Source cargo environment
    export PATH="$HOME/.cargo/bin:$PATH"
    source "$HOME/.cargo/env" 2>/dev/null || true
    
    echo "✓ Rust installed: $(rustc --version)"
    echo "✓ Cargo installed: $(cargo --version)"
else
    echo "✓ Rust already installed: $(rustc --version)"
    echo "✓ Cargo already installed: $(cargo --version)"
fi
echo ""

# ==============================================================================
# Start SDK
# ==============================================================================

echo "► Installing Start SDK..."
if ! command -v start-sdk &> /dev/null; then
    # Clone Start OS repository
    START_OS_DIR="/tmp/start-os-build-$$"
    git clone --depth 1 https://github.com/Start9Labs/start-os.git "$START_OS_DIR"
    cd "$START_OS_DIR"
    
    # Initialize submodules
    git submodule update --init --recursive
    
    # Build and install SDK
    make sdk
    
    # Clean up
    cd -
    rm -rf "$START_OS_DIR"
    
    # Verify installation
    start-sdk init || true
    echo "✓ Start SDK installed: $(start-sdk --version)"
else
    echo "✓ Start SDK already installed: $(start-sdk --version)"
fi
echo ""

# ==============================================================================
# Deno (for TypeScript scripting API)
# ==============================================================================

echo "► Installing Deno..."
if ! command -v deno &> /dev/null; then
    # Install Deno runtime
    curl -fsSL https://deno.land/x/install/install.sh | sh
    
    # Add to PATH
    export DENO_INSTALL="$HOME/.deno"
    export PATH="$DENO_INSTALL/bin:$PATH"
    
    # Ensure it's in the profile for future shells
    echo 'export DENO_INSTALL="$HOME/.deno"' >> "$HOME/.bashrc"
    echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> "$HOME/.bashrc"
    
    echo "✓ Deno installed: $(deno --version | head -1)"
else
    echo "✓ Deno already installed: $(deno --version | head -1)"
fi
echo ""

# ==============================================================================
# Verify Dependencies
# ==============================================================================

echo "=========================================================================="
echo "Verifying build environment..."
echo "=========================================================================="
echo ""

# Check all required commands
REQUIRED_COMMANDS="docker yq cargo start-sdk deno"
MISSING_COMMANDS=""

for cmd in $REQUIRED_COMMANDS; do
    if command -v "$cmd" &> /dev/null; then
        echo "✓ $cmd: $(command -v $cmd)"
    else
        echo "✗ $cmd: NOT FOUND"
        MISSING_COMMANDS="$MISSING_COMMANDS $cmd"
    fi
done

echo ""

if [ -n "$MISSING_COMMANDS" ]; then
    echo "✗ Missing required commands:$MISSING_COMMANDS"
    echo ""
    echo "Please install missing dependencies and try again."
    exit 1
fi

echo "=========================================================================="
echo "✓ Build environment ready!"
echo "=========================================================================="
echo ""
echo "Next steps:"
echo "  1. Run: make"
echo "  2. Output: garbageman-nm.s9pk"
echo ""
echo "Note: You may need to log out and back in for Docker group changes to take effect."
echo ""
