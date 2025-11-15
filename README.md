# Core Cracker

VA Core local development environment validation toolkit for macOS ARM64.

## Requirements

- Zulu JDK 8 ARM64: `~/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk`
- WebLogic 12.2.1.4.0: `~/dev/Oracle/Middleware/Oracle_Home`
- Maven 3.9.9+
- Colima/Docker

## Install

```bash
git clone https://github.com/mcgraw-7/core-cracker.git ~/dev/core-cracker
cd ~/dev/core-cracker
chmod +x setup.sh scripts/**/*.sh

# Add to ~/.zshrc
echo 'source ~/dev/core-cracker/aliases.sh' >> ~/.zshrc
source ~/.zshrc
```

## Environment Setup

Add to `~/.zshrc`

```bash
# Java
export JAVA_HOME="${HOME}/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# Maven (critical - prevents GC overhead)
export MAVEN_OPTS="-Xms512m -Xmx8000m"

# WebLogic
export ORACLE_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
export DOMAINS_HOME="${HOME}/dev/Oracle/Middleware/user_projects/domains"
```

## Usage

```bash
./setup.sh             # Validate environment
vbms-help              # Show all commands
vbms-health            # Full health check
vbms-fix               # Auto-fix issues
```

<details>
<summary>All Available Commands</summary>

```bash
# Health & Diagnostics
vbms-health            # Comprehensive system health check
vbms-verify            # Quick environment verification
vbms-java              # Check Java configuration
vbms-wl                # Check WebLogic status

# Auto-Fix Tools
vbms-fix               # Auto-fix environment issues
vbms-fix-dry           # Preview fixes without applying

# Backup & Restore
vbms-backup            # Backup environment configuration
vbms-restore           # Restore from backup
vbms-backup-list       # List available backups

# Utilities
vbms-help              # Show all commands
vbms-paths             # Analyze system paths
```

</details>

## References

- VBMS Deployment Guide: `~/dev/vbms-core/DEPLOYMENT-GUIDE.md` (local file)
- [Zulu JDK 8 Downloads](https://www.azul.com/downloads/?version=java-8-lts&os=macos&architecture=arm-64-bit&package=jdk)

---

## How This Tool Maps to the Deployment Guide

Core Cracker automates the verification and setup steps from the VBMS Core Deployment Guide (`~/dev/vbms-core/DEPLOYMENT-GUIDE.md`). Here's how each tool validates the documented requirements:

### Prerequisites Validation

| Deployment Guide Requirement | Core Cracker Tool | What It Checks |
|------------------------------|-------------------|----------------|
| **Java Environment**<br>Zulu JDK 8 ARM64 at `~/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk` | `vbms-health`<br>`vbms-java`<br>`vbms-verify` | ✓ JAVA_HOME set and valid<br>✓ JDK 8 version (1.8.0_xxx)<br>✓ ARM64 native architecture<br>✓ Java executable present |
| **WebLogic Environment**<br>Oracle Home at `~/dev/Oracle/Middleware/Oracle_Home`<br>Domain at `~/dev/Oracle/Middleware/user_projects/domains` | `vbms-health`<br>`vbms-wl` | ✓ MW_HOME set correctly<br>✓ WLS_HOME directory exists<br>✓ `.wljava_env` configured<br>✓ Domain directories present |
| **Environment Variables**<br>JAVA_HOME, MAVEN_OPTS, ORACLE_HOME, DOMAINS_HOME | `vbms-health`<br>`vbms-verify` | ✓ All required exports present<br>✓ PATH includes JAVA_HOME/bin<br>✓ MAVEN_OPTS has -Xmx8000m<br>✓ cacerts trust store configured |
| **Maven**<br>Version 3.9.9+<br>MAVEN_OPTS with GC settings | `vbms-health` | ✓ Maven installed<br>✓ MAVEN_OPTS set with -Xms512m -Xmx8000m |
| **Docker/Colima**<br>For Oracle DB on ARM64 | `vbms-health` | ✓ Docker installed and running<br>✓ Colima installed<br>✓ Rosetta 2 for x86_64 emulation |
| **System Resources**<br>Minimum disk and memory | `vbms-health` | ✓ 20GB+ disk space available<br>✓ 8GB+ system memory<br>✓ CPU architecture detected |

### Auto-Fix Capabilities

| Manual Setup Step | Core Cracker Command | What It Does |
|-------------------|----------------------|--------------|
| Add JAVA_HOME to `~/.zshrc` | `vbms-fix` | Automatically adds correct JAVA_HOME for your architecture (ARM64/Intel) |
| Configure MAVEN_OPTS | `vbms-fix` | Adds `-Xms512m -Xmx8000m` to prevent GC overhead errors |
| Set WebLogic variables | `vbms-fix` | Exports MW_HOME, WLS_HOME, DOMAINS_HOME, ORACLE_HOME |
| Create `.wljava_env` | `vbms-fix` | Generates WebLogic Java config file with correct JAVA_HOME |
| Fix PATH order | `vbms-fix` | Ensures JAVA_HOME/bin is first in PATH |
| Make scripts executable | `vbms-fix` | Runs `chmod +x` on all `.sh` files |

### Preview Changes Safely

```bash
vbms-fix-dry  # Shows exactly what would be changed without modifying anything
```

### Deployment Guide Source of Truth

All validation logic in Core Cracker is derived from the verified deployment strategy documented in:
- **File**: `~/dev/vbms-core/DEPLOYMENT-GUIDE.md`
- **Date**: November 2025 (verified working configuration)
- **Platform**: macOS ARM64 (Apple Silicon)

When the deployment guide is updated, Core Cracker should be updated to match.
