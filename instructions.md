# Garbageman Nodes Manager - User Guide

Welcome to Garbageman Nodes Manager! This guide will help you get started managing Bitcoin nodes on your StartOS device.

**Supported Platforms:**
- ✅ x86_64 (Intel/AMD 64-bit)
- ⏳ ARM64 (Raspberry Pi) - Coming in future release

---

## Getting Started

### Step 1: Configure the Service

Before starting Garbageman for the first time:

1. Go to **Services → Garbageman Nodes Manager**
2. Click **Config** in the menu
3. Review the default settings (most users can use defaults)
4. **Important settings:**
   - **Max Instances** - Set based on available RAM (see Resource Management section)
   - **Enable Tor Proxy** - Keep enabled for privacy
   - **Log Level** - Use "Info" for normal operation
5. Click **Save**

### Step 2: Start the Service

1. Click **Start** in the service page
2. Wait 30-60 seconds for services to initialize
3. Health check will turn green when ready
4. Click **Launch UI** to access the web interface

---

## Using the Web Interface

### Dashboard Overview

The main dashboard shows:
- **Status Board** - Network info, peer counts, uptime
- **Instance Cards** - Your Bitcoin node instances
- **Command Bar** - Quick actions (Import Artifact, New Instance, View Peers)
- **System Stats** - CPU, RAM, disk usage

### Creating Your First Bitcoin Node

#### Option A: Import Artifact (Recommended)

Artifacts contain pre-built binaries and pre-synced blockchain data, dramatically reducing setup time:

1. Click **IMPORT ARTIFACT** in the command bar
2. Choose **Import from GitHub**
3. Select the latest release (e.g., `v2025-11-03-rc2`)
4. Wait for download (5-10 minutes, ~2-5 GB)
5. Extraction happens automatically

**What you get:**
- Pre-compiled Garbageman or Knots binary
- Pre-synced blockchain data (saves days of syncing!)
- Ready-to-use configuration templates

#### Option B: Start from Scratch

Build and sync from scratch (takes longer):

1. Skip artifact import
2. Create instance (see below)
3. Initial sync will download entire blockchain (days to weeks)

### Creating an Instance

1. Click **NEW INSTANCE** in the command bar
2. Configure your node:
   - **Implementation** - Garbageman or Bitcoin Knots
   - **Network** - Mainnet (live Bitcoin), Testnet (testing), Signet, or Regtest
   - **Ports** - Leave auto-assigned or customize
   - **Data Source** - Select imported artifact or create fresh
3. Click **CREATE**
4. Wait for blockchain extraction (~2 minutes with artifact)
5. Instance card appears on dashboard

### Starting and Monitoring Instances

**Start a node:**
1. Click **START** button on instance card
2. Daemon initializes (~10-30 seconds)
3. Watch real-time metrics update:
   - Block height
   - Peer count
   - Sync progress (%)
   - Network traffic

**Monitor sync progress:**
- **Green ring** - Fully synced
- **Yellow ring** - Syncing in progress
- **Red ring** - Error or stopped
- **Block height** - Current vs. network tip

**Stop a node:**
1. Click **STOP** button
2. Graceful shutdown (waits for writes to complete)
3. Data is preserved, can restart anytime

---

## Peer Discovery

Garbageman automatically discovers Bitcoin peers on the network:

1. Click **VIEW PEERS** in command bar
2. Browse tabs:
   - **Clearnet Peers** - Standard Bitcoin nodes
   - **Tor Peers** - .onion hidden services
   - **Seeds Checked** - DNS seed query results

**Features:**
- **Libre Relay Detection** - Auto-tagged nodes removing spam filters
- **Version Info** - Bitcoin Core version, Knots, etc.
- **Service Flags** - Node capabilities (full node, pruned, etc.)
- **Real-time updates** - Refreshes every minute

**Filters:**
- All Peers
- Libre Relay Only
- Core v30+ Only

---

## Managing Artifacts

### Viewing Artifacts

1. Click **ARTIFACTS** in the side menu (or command bar)
2. See list of imported artifacts:
   - **Release Tag** - Version identifier
   - **Size** - Disk space used
   - **Imported Date** - When downloaded
   - **Status** - Available, In Use, or Cached

### Deleting Artifacts

Artifacts can be large (1-10 GB each). Delete unused ones to free space:

1. Find artifact in list
2. Click **DELETE** button
3. Confirm deletion
4. **Note:** Cannot delete artifacts in use by running instances

### Artifact Cache Limit

Configure in **Config → Advanced → Artifact Cache Size**:
- Default: 5 artifacts
- Set to 0 for unlimited (monitor disk space!)
- Oldest artifacts auto-deleted when limit reached

---

## Resource Management

### Monitor Usage

Dashboard shows real-time:
- **CPU Usage** - % across all cores
- **RAM Usage** - GB used / total available
- **Disk Usage** - GB used / total available

### Resource Requirements

**Per Bitcoin daemon instance:**
- **RAM:** ~10 GB (full node)
- **Disk:** ~500 GB (mainnet), ~50 GB (testnet)
- **CPU:** 2 cores during sync, 1 core idle

**Recommendations:**
- **High-end server (64GB+ RAM):** Up to 10 instances
- **Mid-range server (32GB RAM):** 3-5 instances  
- **Min-spec server (8-16GB RAM):** 1-2 instances

**If running out of resources:**
1. Stop unused instances
2. Delete old artifacts
3. Reduce Max Instances (Config menu)
4. Consider testnet instead of mainnet (smaller)

---

## Configuration Options

Access via **Config** menu in service page.

### Basic Settings

- **API Port** (8080) - Internal backend port
- **UI Port** (5173) - Internal web UI port
- **Supervisor Port** (9000) - Daemon manager port
- **Admin Password** - Auto-generated secure credential
- **Log Level** - debug/info/warn/error (info recommended)
- **Enable Tor Proxy** - For .onion peer discovery (keep enabled)
- **Max Instances** - Limit concurrent nodes (2-3 for embedded)

### Advanced Settings

- **Tor Proxy Host/Port** - External Tor service configuration
- **Peer Discovery Interval** - Refresh frequency (minutes)
- **Enable Libre Relay Detection** - Auto-tag Libre Relay nodes
- **Artifact Cache Size** - Max cached artifacts (0 = unlimited)

**After changing config:**
1. Click **Save**
2. Service restarts automatically
3. Wait for health check to pass
4. Instances reload with new settings

---

## Backups and Restore

### What Gets Backed Up

Using StartOS backup feature:
- ✅ Instance configurations (ENV files)
- ✅ Artifacts (pre-built binaries, blockchain data)
- ✅ StartOS config (app.yaml)

**Note:** Full blockchain backups can be 500+ GB. Consider:
- Backing up configs only
- Re-syncing blockchains after restore
- Using artifacts to speed up re-sync

### Creating a Backup

1. Go to **System → Backups**
2. Select Garbageman Nodes Manager
3. Choose backup location (USB drive, network)
4. Click **Create Backup**
5. Wait for completion (time depends on data size)

### Restoring from Backup

1. Reinstall Garbageman Nodes Manager (if needed)
2. Go to **System → Backups**
3. Select backup to restore
4. Click **Restore**
5. Wait for completion
6. Start Garbageman service
7. Instances should reload automatically

---

## Troubleshooting

### UI Not Loading

**Symptoms:** Clicking "Launch UI" shows error or blank page

**Solutions:**
1. Wait 60 seconds after start (services initializing)
2. Check health check is green
3. View logs: **Logs** menu in service page
4. Restart service: **Stop → Start**
5. Check StartOS Tor connectivity

### Instance Won't Start

**Symptoms:** Instance stuck in "Starting" state or errors immediately

**Solutions:**
1. Check logs for specific error
2. Verify enough RAM available (10+ GB free)
3. Verify enough disk space (500+ GB for mainnet)
4. Try different port numbers (avoid conflicts)
5. Delete and recreate instance

### Slow Sync or No Peers

**Symptoms:** Block height not increasing, 0 peers connected

**Solutions:**
1. Enable Tor Proxy: **Config → Enable Tor Proxy**
2. Check peer discovery: **VIEW PEERS** → verify nodes found
3. Check network connectivity on StartOS device
4. Try different network (testnet for testing)
5. Wait - initial peer discovery can take 5-10 minutes

### Out of Disk Space

**Symptoms:** "Disk full" errors, can't create instances

**Solutions:**
1. Delete unused instances: **DELETE** button on instance cards
2. Clear artifact cache: **ARTIFACTS → DELETE** old releases
3. Reduce artifact cache size: **Config → Advanced → Artifact Cache Size**
4. Consider external storage for StartOS
5. Use testnet instead of mainnet (much smaller)

### High RAM Usage / Slow Performance

**Symptoms:** Device sluggish, services crashing

**Solutions:**
1. Stop unused instances
2. Reduce Max Instances: **Config → Max Instances → 2**
3. Restart StartOS device
4. Consider upgrading RAM (8GB minimum recommended)
5. Monitor with: Dashboard → System Stats

### Service Crashes on Startup

**Symptoms:** Service starts, health check fails, automatically stops

**Solutions:**
1. View logs: **Logs** menu
2. Check config for invalid values: **Config** menu
3. Reset to defaults: Delete config, service recreates with defaults
4. Check StartOS logs: **System → Logs**
5. Report issue: https://github.com/paulscode/garbageman-nm/issues

---

## Advanced Usage

### Multiple Networks

Run different networks simultaneously:
- **Mainnet** - Live Bitcoin network
- **Testnet** - Testing network (free coins)
- **Signet** - Stable testing network
- **Regtest** - Local development network

Each network is isolated, can run concurrently (if enough resources).

### Port Configuration

Default auto-assigned ports avoid conflicts. Manual configuration:
1. Create instance
2. Set custom P2P, RPC, ZMQ ports
3. Ensure ports don't overlap with other services
4. Restart instance after changes

### Libre Relay Nodes

Garbageman automatically detects Libre Relay nodes:
- **What:** Bitcoin Core fork removing spam filters
- **Why:** Supports freedom of transaction types
- **How:** Peer discovery tags nodes, shows in peer list
- **Filter:** **VIEW PEERS → Filter: Libre Relay Only**

### Using Artifacts Effectively

**Best practices:**
1. Import latest release before creating instances
2. Reuse artifacts across multiple instances (same network)
3. Delete old artifacts to free space
4. Re-download if corruption suspected

**Artifact contents:**
- Pre-compiled binaries (Garbageman, Knots)
- Pre-synced blockchain (mainnet, testnet)
- Configuration templates
- Metadata (block height, date)

---

## Privacy and Security

### Tor Integration

All external peer connections use Tor by default:
- **Hidden Service:** Each instance gets .onion address
- **Peer Discovery:** Finds .onion Bitcoin nodes
- **Privacy:** IP address hidden from network

**Disable Tor:** Not recommended, but possible via **Config → Enable Tor Proxy → Off**

### Data Isolation

Each instance has separate data directory:
- No cross-contamination between nodes
- Independent wallets (if using wallet features)
- Isolated peer lists

### Secure Credentials

Admin password auto-generated:
- 32 characters, alphanumeric + symbols
- Stored in StartOS config (encrypted)
- Copyable via **Config** menu

---

## Tips for Best Performance

1. **Use Artifacts:** Dramatically reduces sync time
2. **Limit Instances:** 2-3 max on Raspberry Pi
3. **External Storage:** SSD strongly recommended
4. **Monitor Resources:** Check dashboard regularly
5. **Testnet First:** Practice with testnet before mainnet
6. **Enable Tor:** Better privacy, more peers
7. **Regular Backups:** Protect instance configs
8. **Update Regularly:** New releases improve performance

---

## Getting Help

**Documentation:**
- This guide (always accessible in service page)
- Garbageman README: https://github.com/paulscode/garbageman-nm
- StartOS Docs: https://docs.start9.com/

**Support:**
- GitHub Issues: https://github.com/paulscode/garbageman-nm/issues
- Start9 Community: https://community.start9.com/
- Matrix Chat: [Join Start9 channels]

**Bug Reports:**
Please include:
- StartOS version
- Garbageman version
- Steps to reproduce
- Logs (from service Logs menu)
- System specs (RAM, disk, device type)

---

**Happy Bitcoin node management! 🚀**
