# Garbageman Nodes Manager - StartOS Wrapper

<p align="center">
  <img src="icon.png" alt="Garbageman Nodes Manager" width="21%">
</p>

<p align="center">
  <strong>Modern web-based control plane for managing multiple Bitcoin nodes on StartOS</strong>
</p>

---

## Overview

This repository contains the StartOS wrapper for [Garbageman Nodes Manager](https://github.com/paulscode/garbageman-nm), enabling easy installation and management of multiple Bitcoin daemon instances on Start9 devices.

**Garbageman Nodes Manager** provides a modern, containerized web application for managing multiple Bitcoin daemon instances (Garbageman or Bitcoin Knots) with:

- ✅ **Web-based dashboard** - Dark neon aesthetic with real-time updates
- ✅ **Instance management** - Create, start, stop, monitor multiple daemon instances
- ✅ **Real-time monitoring** - Block height, peer counts, sync progress, resource usage
- ✅ **Peer discovery** - Clearnet DNS seeds + Tor-based .onion discovery
- ✅ **Libre Relay detection** - Identify and track Libre Relay nodes on the network
- ✅ **Artifact management** - Import pre-built binaries and pre-synced blockchains
- ✅ **Tor integration** - Privacy-first design with Tor proxy support
- ✅ **Platform ready** - Optimized for StartOS server deployments

---

## For Users

If you want to **install and use** Garbageman on your StartOS device, see the comprehensive [User Guide](instructions.md) which covers:
- Installation steps
- Configuration options
- Creating and managing Bitcoin nodes
- Troubleshooting common issues

### Quick Start

1. Install via StartOS marketplace or sideload the `.s9pk` package
2. Configure the service (Config → adjust settings)
3. Start the service and wait for health check
4. Launch the web UI
5. Import an artifact (optional but recommended)
6. Create your first Bitcoin node instance

### Supported Platforms

**Currently supported:**
- ✅ x86_64 (Intel/AMD 64-bit)
- ✅ ARM64 (Raspberry Pi, Apple Silicon)

---

## For Developers

This section is for developers who want to **build the StartOS package** from source or contribute to the wrapper.

### Prerequisites

To build this package, you need:

- **Docker** 20.10+ with buildx support - [Install Docker](https://docs.docker.com/get-docker)
- **docker-buildx** - [Install buildx](https://docs.docker.com/buildx/working-with-buildx/)
- **yq** - YAML processor - [Install yq](https://mikefarah.gitbook.io/yq)
- **deno** - For SDK scripts - [Install deno](https://deno.land/)
- **make** - Build automation - [Install make](https://www.gnu.org/software/make/)
- **start-sdk** - Start9 SDK - [Install start-sdk](https://github.com/Start9Labs/start-os/tree/sdk/)
- **10+ GB free disk space**

### Setting Up Build Environment

#### 1. Install Docker and Dependencies

```bash
# Install Docker
curl -fsSL https://get.docker.com | bash
sudo usermod -aG docker "$USER"
exec sudo su -l $USER

# Set buildx as default builder
docker buildx install
docker buildx create --use

# Enable cross-architecture builds
docker run --privileged --rm linuxkit/binfmt:v0.8
```

#### 2. Install Build Tools

On Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install -y build-essential make yq
```

Or using snap:
```bash
sudo snap install yq
sudo snap install deno
```

#### 3. Install Start9 SDK

```bash
# Clone Start9 OS repository
git clone https://github.com/Start9Labs/start-os.git
cd start-os
git submodule update --init --recursive

# Build and install SDK
make sdk

# Initialize and verify
start-sdk init
start-sdk --version
```

### Cloning and Building

#### 1. Clone Both Repositories

The wrapper needs the upstream Garbageman repository as a sibling directory:

```bash
# Clone the wrapper repository
git clone https://github.com/paulscode/garbageman-nm-startos.git
cd garbageman-nm-startos

# Clone the upstream project (as sibling)
cd ..
git clone https://github.com/paulscode/garbageman-nm.git
cd garbageman-nm-startos
```

Your directory structure should look like:
```
parent-directory/
├── garbageman-nm/          # Upstream application
└── garbageman-nm-startos/  # StartOS wrapper (this repo)
```

#### 2. Build the Package

```bash
# Build package (currently x86_64 only)
make

# Verify package integrity
make verify

# Clean build artifacts
make clean

# Show available commands
make info
```

#### 3. Build Output

After a successful build, you'll have:

- `garbageman-nm.s9pk` - StartOS package file (~300-500 MB)
- `docker-images/x86_64.tar` - x86_64 Docker image

### Installing the Package

#### Option 1: Using start-cli

If you have `start-cli` configured:

```bash
# Login to your StartOS device
start-cli auth login
# Enter your StartOS password when prompted

# Install the package
start-cli --host https://your-startos-device.local package install garbageman-nm.s9pk

# Or if you have a default host configured
make install
```

#### Option 2: Sideload via Web UI

1. Open StartOS web interface: `https://your-startos-device.local`
2. Navigate to **System → Sideload Service**
3. Upload `garbageman-nm.s9pk`
4. Wait for installation to complete
5. Navigate to **Services → Garbageman Nodes Manager**
6. Configure and start the service

### Project Structure

```
garbageman-nm-startos/
├── Dockerfile              # Multi-stage build for API+UI+Supervisor
├── docker_entrypoint.sh    # Startup script (config parsing, initialization)
├── supervisord.conf        # Process manager for 3 services
├── manifest.yaml           # StartOS service definition
├── Makefile                # Build automation
├── LICENSE                 # MIT license
├── README.md               # This file
├── instructions.md         # User guide (displayed in StartOS UI)
├── icon.png                # Service icon (512x512 PNG)
├── .dockerignore           # Docker build context exclusions
├── .gitignore              # Git exclusions
├── assets/
│   └── compat/
│       └── config_spec.yaml  # Typed configuration UI specification
└── scripts/
    ├── deps.ts             # Deno dependencies
    ├── deno.json           # Deno configuration with import maps
    └── procedures/         # StartOS integration procedures
        ├── getConfig.ts    # Configuration getter
        ├── setConfig.ts    # Configuration setter
        ├── properties.ts   # Runtime properties
        ├── migrations.ts   # Version migrations
        └── healthChecks.ts # Health check implementation
```

### Architecture

The wrapper packages three services managed by `supervisord`:

1. **API Server (Fastify)** - Port 8080
   - REST API backend for web UI
   - Instance management operations
   - Peer discovery coordination

2. **Web UI (Next.js)** - Port 5173
   - React-based frontend dashboard
   - Real-time monitoring displays
   - Configuration interfaces

3. **Supervisor (Multi-daemon Manager)** - Port 9000
   - Bitcoin daemon lifecycle management
   - Process monitoring and health checks
   - Resource tracking

All services communicate internally over localhost. Only the Web UI (port 5173) is exposed externally via Tor hidden service and optional LAN.

### Development Workflow

1. **Make changes** to wrapper files (Dockerfile, entrypoint, etc.)
2. **Test build:** `make` (builds x86_64)
3. **Sideload** to test StartOS device
4. **Install and start** the service
5. **Test functionality:**
   - Configuration changes
   - Instance creation/management
   - Peer discovery
   - Artifact import
   - Backup/restore
6. **Check logs** for errors
7. **Iterate** until stable

### Testing

Before submitting changes:

- ✅ Build succeeds (`make`)
- ✅ Package verifies successfully (`make verify`)
- ✅ Service installs on StartOS
- ✅ Health check passes
- ✅ Web UI loads and responds
- ✅ All configuration options work
- ✅ Instances can be created and started
- ✅ Backup/restore functions correctly

### Contributing

Contributions are welcome! To contribute:

1. **Fork** this repository
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Test thoroughly** on real StartOS hardware (x86_64 devices)
4. **Commit changes** with clear messages
5. **Push to branch** (`git push origin feature/amazing-feature`)
6. **Open a Pull Request** with detailed description

Please ensure:
- Code follows existing style and conventions
- All files have accurate comments
- Changes are tested on actual StartOS devices
- Documentation is updated if needed

---

## Resource Requirements

### Minimum (per StartOS Device)
- **RAM:** 8 GB
- **CPU:** 4 cores
- **Disk:** 100 GB free

### Per Bitcoin Daemon Instance
- **RAM:** ~10 GB (full node with mempool)
- **Disk:** ~500 GB (mainnet), ~50 GB (testnet)
- **CPU:** 2 cores (during initial sync)

### Recommendations
- **Server deployment:** Up to 10 instances (with 128GB+ RAM)
- **Mid-range hardware:** 3-5 instances (with 32-64GB RAM)
- **Min-spec hardware:** 1-2 instances (with 8-16GB RAM)
- **Storage:** External SSD strongly recommended for blockchain data
- **Network:** Stable connection for initial sync (can take days)

---

## Security & Privacy

- **No Hardcoded Secrets** - Admin password auto-generated (32-char entropy)
- **Non-Root User** - All services run as `garbageman` (uid 1001)
- **Tor-First Design** - Peer discovery via Tor SOCKS5 proxy
- **Network Isolation** - StartOS container networking
- **Data Encryption** - StartOS backup encryption
- **Minimal Attack Surface** - Only Web UI exposed via Tor/LAN

---

## Known Limitations

1. **x86_64 Only** - ARM support pending upstream artifact availability (planned for future release)
2. **Resource Intensive** - Each Bitcoin node requires substantial resources
3. **Long Sync Times** - Initial blockchain sync can take days (artifacts help significantly)
4. **Large Backups** - Full blockchain backups are 500+ GB (consider selective backup)
5. **No Pruning Mode** - Full nodes only (pruning support planned)

---

## Links

- **Upstream Project:** https://github.com/paulscode/garbageman-nm
- **This Wrapper:** https://github.com/paulscode/garbageman-nm-startos
- **StartOS Documentation:** https://docs.start9.com/0.3.5.x/
- **Start9 Community:** https://community.start9.com/
- **Issue Tracker:** https://github.com/paulscode/garbageman-nm/issues

---

## License

MIT License - See [LICENSE](LICENSE) file for details.

---

## Changelog

### v0.1.0.1 (Initial Release - November 2025)
- ✅ Multi-service architecture (API, UI, Supervisor)
- ✅ Typed configuration UI with validation
- ✅ Health checks and backup support
- ✅ Tor hidden service and optional LAN access
- ✅ x86_64 support (ARM support planned for future release)
- ✅ Resource optimization for server deployments
- ✅ Comprehensive documentation and user guide

---

**Built with ❤️ for the StartOS ecosystem**
