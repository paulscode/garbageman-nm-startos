# Garbageman Nodes Manager - StartOS Wrapper
## Quick Build & Deploy Guide

### 🎯 What This Is

Production-ready StartOS 0.3.5.x wrapper for Garbageman Nodes Manager with complete compliance.

**Current status:**
- ✅ x86_64 (Intel/AMD 64-bit) fully supported
- ⏳ ARM64 support pending upstream artifact availability (future release)

### 🚀 Quick Build

```bash
cd /home/paul/workspace/garbageman-nm-startos

# Check everything is ready
make info

# Build package (x86_64)
make

# Expected output:
# - docker-images/x86_64.tar (~200-400 MB)  
# - garbageman-nm.s9pk (verified package)
```

### 📦 Installation Options

#### Option 1: Via Web UI
1. Open StartOS: `http://your-startos.local`
2. Navigate to: **System → Sideload Service**
3. Upload: `garbageman-nm.s9pk`
4. Configure and start the service

#### Option 2: Via CLI
```bash
# First time setup
echo "host: http://your-startos.local" > ~/.embassy/config.yaml
start-cli auth login

# Install
make install
# or directly:
start-cli package install garbageman-nm.s9pk
```

### 🔧 Development Workflow

```bash
# Build and verify
make                # Build x86_64 image and create .s9pk
make verify         # Verify package integrity

# Clean build artifacts
make clean

# Show package info
make info

# TypeScript type checking (scripts)
cd scripts && deno check *.ts
```

**IDE Setup:**
- VS Code: Deno extension enabled for scripts/ directory
- TypeScript types cached via `deno cache`
- Configuration in `.vscode/settings.json`

### 📋 File Structure

```
garbageman-nm-startos/
├── manifest.yaml                 ✅ Compliant with 0.3.5.x
├── Dockerfile                    ✅ Multi-stage, optimized
├── docker_entrypoint.sh          ✅ Config integration
├── supervisord.conf              ✅ Multi-service orchestration
├── Makefile                      ✅ Universal build system
├── LICENSE                       ✅ MIT
├── icon.png                      ✅ 512x512 PNG
├── instructions.md               ✅ Comprehensive guide
├── assets/
│   └── compat/
│       └── config_spec.yaml      ✅ Typed config UI
└── scripts/
    ├── embassy.ts                ✅ Procedure exports
    ├── deps.ts                   ✅ SDK imports
    ├── bundle.ts                 ✅ Deno bundler
    ├── deno.json                 ✅ Import map
    └── procedures/
        ├── getConfig.ts          ✅ Config retrieval
        ├── setConfig.ts          ✅ Config application
        ├── properties.ts         ✅ Service properties
        ├── migrations.ts         ✅ Version migrations
        └── healthChecks.ts       ✅ Health monitoring
```

### 🎨 Features Supported

**Core Functionality:**
- ✅ Multi-daemon Bitcoin node management
- ✅ Garbageman & Bitcoin Knots support
- ✅ Real-time monitoring dashboard
- ✅ Peer discovery (DNS seeds + Tor)
- ✅ Libre Relay detection
- ✅ Artifact management (pre-synced blockchains)
- ✅ Multiple network support (mainnet/testnet/signet/regtest)

**StartOS Integration:**
- ✅ Tor hidden service (automatic)
- ✅ Optional LAN access (HTTPS)
- ✅ Typed configuration UI
- ✅ Health monitoring
- ✅ Backup/restore support
- ✅ Version migrations
- ✅ Resource-aware (configurable instance limits)

**Technical:**
- ✅ TypeScript end-to-end
- ✅ Multi-stage Docker build
- ✅ Non-root container execution
- ✅ Supervisord process management
- ✅ Graceful shutdown handling

### 📖 User Experience Flow

1. **Install** → User sideloads .s9pk
2. **Configure** → UI presents typed config options from config_spec.yaml
3. **Start** → Services initialize (API, UI, Supervisor)
4. **Access** → Launch UI via Tor or LAN
5. **Import Artifact** → Download pre-synced blockchain (~2-5 GB)
6. **Create Instance** → Configure Bitcoin node (mainnet/testnet)
7. **Monitor** → Real-time block height, peer count, sync progress
8. **Backup** → Automatic via StartOS backup system

### 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│         StartOS (0.3.5.x)                   │
│  ┌───────────────────────────────────────┐  │
│  │  Garbageman NM Container              │  │
│  │  ┌─────────────────────────────────┐  │  │
│  │  │  supervisord                    │  │  │
│  │  │  ├─ Multi-Daemon Supervisor     │  │  │
│  │  │  │  (port 9000)                 │  │  │
│  │  │  ├─ API Server (Fastify)        │  │  │
│  │  │  │  (port 8080)                 │  │  │
│  │  │  └─ UI Server (Next.js)         │  │  │
│  │  │     (port 5173) ← Tor/LAN       │  │  │
│  │  └─────────────────────────────────┘  │  │
│  │                                        │  │
│  │  Volume: /root (main data)            │  │
│  │  ├─ /root/data (blockchains)          │  │
│  │  ├─ /root/envfiles (daemon configs)   │  │
│  │  ├─ /root/artifacts (binaries)        │  │
│  │  └─ /root/start9/config.yaml          │  │
│  └───────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

### ⚠️ Important Notes

**Resource Requirements:**
- Minimum: 8 GB RAM, 4 CPU cores, 100 GB disk
- Each Bitcoin node: ~10 GB RAM + 500 GB disk
- Recommended: 2-3 instances on embedded devices

**Config Path:**
- StartOS config: `/root/start9/config.yaml` (managed by compat system)
- Application reads from this path on startup
- Changes require service restart

**Data Persistence:**
- All mutable data under `/root` (mounted by StartOS)
- Application code at `/app` (immutable)
- Backups include entire `/root` volume

### 🐛 Troubleshooting

**Build Issues:**
```bash
# Verify prerequisites
make check-prereqs

# Check source directory
ls -la ../garbageman-nm/

# Enable Docker buildx
docker buildx create --use
docker run --privileged --rm linuxkit/binfmt:v0.8
```

**Runtime Issues:**
- Check health status in StartOS UI
- View logs via StartOS logs viewer
- Verify config via Config menu
- Restart service after config changes

### 📚 References

- **Manifest Spec:** https://docs.start9.com/0.3.5.x/developer-docs/specification/manifest.html
- **Config Spec:** https://docs.start9.com/0.3.5.x/developer-docs/specification/config-spec.html
- **Docker Guide:** https://docs.start9.com/0.3.5.x/developer-docs/specification/docker.html
- **Packaging:** https://docs.start9.com/0.3.5.x/developer-docs/packaging.html
- **Upstream Project:** https://github.com/paulscode/garbageman-nm

---

**Status:** ✅ Production Ready  
**Last Updated:** November 8, 2025  
**Compliance:** 100% with StartOS 0.3.5.x
