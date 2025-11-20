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
export DOMAINS="${HOME}/dev/Oracle/Middleware/user_projects/domains"
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
vbms-backups       # List available backups
vbms-backup-props      # Backup/restore vbmsDeveloper.properties only

# Utilities
vbms-help              # Show all commands
vbms-paths             # Analyze system paths
```

</details>


<details>
<summary>terminal session screencaps</summary>
<h3>vbms-fix-dry</h3>
<img width="642" height="757" alt="CleanShot 2025-11-20 at 16 24 11" src="https://github.com/user-attachments/assets/be27df12-d677-476f-9eed-878126027d7a" />
<h3>vbms-health</h3>
<img width="591" height="1032" alt="CleanShot 2025-11-20 at 16 28 11" src="https://github.com/user-attachments/assets/a94e1bcb-d64f-4e44-a1a2-6c01640fe866" />
<h3>vbms-wl</h3>
<img width="1082" height="931" alt="CleanShot 2025-11-20 at 16 29 35" src="https://github.com/user-attachments/assets/d8272741-56d1-4663-a660-5b6a4401a189" />
<h3>vbms-backups</h3>
<img width="598" height="222" alt="CleanShot 2025-11-20 at 16 35 14" src="https://github.com/user-attachments/assets/d5cb2397-22a7-46d1-9ad2-2a62cf8bc309" />


</details

## References

- [VBMS Core Installation Guide](https://github.com/department-of-veterans-affairs/vbms-core/wiki/VBMS-Core-Installation-Guide) (official wiki)
- [Helpful Tips For Quicker Development](https://github.com/department-of-veterans-affairs/vbms-core/wiki/Helpful-Tips-For-Quicker-Development) (official wiki)
- [Zulu JDK 8 Downloads](https://www.azul.com/downloads/?version=java-8-lts&os=macos&architecture=arm-64-bit&package=jdk)

---

## ---> Hazelcast Must Be Disabled

**DEPLOYMENT BLOCKER** - If you're experiencing deployment hangs where the application gets stuck in "deploy running" state for 5-60 minutes, you're missing the Hazelcast disable flag.

### The Problem

Spring attempts to create Hazelcast client beans during application startup and hangs indefinitely waiting for cluster connection. This causes deployment timeouts and is the most common reason deployments fail on local environments.

### The Solution

Add `-Dvbms.cache.hazelcast.enabled=false` to your `javaMemArgs` in `vbmsDeveloper.properties`:

```bash
# Edit the properties file
vi ~/dev/vbms-core/vbms-install-weblogic/src/main/resources/vbmsDeveloper.properties

# Find javaMemArgs (around line 44) and add the flag:
javaMemArgs=-Xms2000m -Xmx8000m -XX:CompileThreshold=8000 \
  -Dsun.net.http.retryPost=false \
  -Dhttp.proxyHost=${proxyHost} \
  -Dhttp.proxyPort=${proxyPort} \
  -Dhttp.proxyUser=${proxyUser} \
  -Dhttp.proxyPassword=${proxyPassword} \
  -Dhttps.proxyHost=${proxyHost} \
  -Dhttps.proxyPort=${proxyPort} \
  -Dhttp.nonProxyHosts=*.p2.vbms.va.gov \
  -DVBMSCORE_LOGBACK_APPENDER=Console \
  -Dvbms.cache.hazelcast.enabled=false
```

### Why This Works

- **JVM Flag** (`-Dvbms.cache.hazelcast.enabled=false`): Prevents Spring from instantiating Hazelcast client beans entirely. This is what actually fixes the deployment hang.
- **Properties** (`hazelcastStartLinux=`): Prevents the Hazelcast server process from starting, but does NOT prevent Spring from trying to create client beans.

You need **BOTH** for complete Hazelcast disablement.

### Verification

After rebuilding your WebLogic domain, check the startup output:

```bash
cd $ORACLE_HOME/user_projects/domains/P2-DEV
./bin/startWebLogic.sh | grep "JAVA Memory arguments"
```

You should see `-Dvbms.cache.hazelcast.enabled=false` in the output.

### If You're Still Stuck

1. **Rebuild the domain** - The flag is baked into the domain at build time:
   ```bash
   cd ~/dev/vbms-core/vbms-install-weblogic
   mvn clean install -DskipTests
   ```

2. **Check for upticks** - Version updates may reset your `vbmsDeveloper.properties`. Always verify the flag is present after pulling upstream changes.

3. **See the Deployment Guide** - Full troubleshooting details in `~/dev/vbms-core/DEPLOYMENT-GUIDE.md` under "Issue 1: Deployment Hangs"

---

## 📋 Properties File Backup Tool

The `vbms-backup-props` command provides targeted backup and restore for the critical `vbmsDeveloper.properties` file. This file contains the Hazelcast JVM flag and other domain configuration that often gets reset during upticks.

### Quick Start

```bash
# Create a timestamped backup
vbms-backup-props

# List all backups
vbms-backup-props --list

# Restore from a specific backup
vbms-backup-props --restore vbmsDeveloper.properties.20250115-143022

# Compare current file with a backup
vbms-backup-props --diff vbmsDeveloper.properties.20250115-143022

# Show the most recent backup
vbms-backup-props --latest

# Verify Hazelcast flag in a backup
vbms-backup-props --verify vbmsDeveloper.properties.20250115-143022
```

### Why Use This?

**Problem**: Version upticks (40.3 → 40.4) often reset `vbmsDeveloper.properties`, wiping out your carefully configured Hazelcast disable flag and other settings.

**Solution**: Backup before pulling upstream changes, then restore or diff after the uptick to see what changed.

### Backup Location

All backups are stored in `~/dev/vbms-properties-backups/` with timestamps:
```
vbmsDeveloper.properties.20250115-143022
vbmsDeveloper.properties.20250115-120000
vbmsDeveloper.properties.20250114-093045
```

### Restore Safety

Every restore operation automatically creates a backup of the current file before overwriting it, so you can always roll back.

### Hazelcast Validation

The tool automatically checks every backup for the critical `-Dvbms.cache.hazelcast.enabled=false` flag and warns if it's missing. This helps you avoid restoring a broken configuration.

---

## How This Tool Maps to the Deployment Guide

Core Cracker automates the verification and setup steps from the VBMS Core Deployment Guide (`~/dev/vbms-core/DEPLOYMENT-GUIDE.md`). Here's how each tool validates the documented requirements:

### Prerequisites Validation

| Deployment Guide Requirement | Core Cracker Tool | What It Checks |
|------------------------------|-------------------|----------------|
| **Java Environment**<br>Zulu JDK 8 ARM64 at `~/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk` | `vbms-health`<br>`vbms-java`<br>`vbms-verify` | ✓ JAVA_HOME set and valid<br>✓ JDK 8 version (1.8.0_xxx)<br>✓ ARM64 native architecture<br>✓ Java executable present |
| **WebLogic Environment**<br>Oracle Home at `~/dev/Oracle/Middleware/Oracle_Home`<br>Domain at `$ORACLE_HOME/user_projects/domains` | `vbms-health`<br>`vbms-wl` | ✓ MW_HOME set correctly<br>✓ `.wljava_env` configured<br>✓ Domain directories present |
| **Environment Variables**<br>JAVA_HOME, MAVEN_OPTS, ORACLE_HOME, DOMAINS | `vbms-health`<br>`vbms-verify` | ✓ All required exports present<br>✓ PATH includes JAVA_HOME/bin<br>✓ MAVEN_OPTS has -Xmx8000m<br>✓ cacerts trust store configured |
| **Maven**<br>Version 3.9.9+<br>MAVEN_OPTS with GC settings | `vbms-health` | ✓ Maven installed<br>✓ MAVEN_OPTS set with -Xms512m -Xmx8000m |
| **Docker/Colima**<br>For Oracle DB on ARM64 | `vbms-health` | ✓ Docker installed and running<br>✓ Colima installed<br>✓ Rosetta 2 for x86_64 emulation |
| **System Resources**<br>Minimum disk and memory | `vbms-health` | ✓ 20GB+ disk space available<br>✓ 8GB+ system memory<br>✓ CPU architecture detected |

### Auto-Fix Capabilities

| Manual Setup Step | Core Cracker Command | What It Does |
|-------------------|----------------------|--------------|
| Add JAVA_HOME to `~/.zshrc` | `vbms-fix` | Automatically adds correct JAVA_HOME for your architecture (ARM64/Intel) |
| Configure MAVEN_OPTS | `vbms-fix` | Adds `-Xms512m -Xmx8000m` to prevent GC overhead errors |
| Set WebLogic variables | `vbms-fix` | Exports MW_HOME, DOMAINS, ORACLE_HOME |
| Create `.wljava_env` | `vbms-fix` | Generates WebLogic Java config file with correct JAVA_HOME |
| Fix PATH order | `vbms-fix` | Ensures JAVA_HOME/bin is first in PATH |
| Make scripts executable | `vbms-fix` | Runs `chmod +x` on all `.sh` files |

### Preview Changes Safely

```bash
vbms-fix-dry  # Shows exactly what would be changed without modifying anything
```

### Deployment Guide Source of Truth

All validation logic in Core Cracker is derived from the verified deployment strategy documented in:
- **Official Guide**: [VBMS Core Installation Guide](https://github.com/department-of-veterans-affairs/vbms-core/wiki/VBMS-Core-Installation-Guide) (GitHub Wiki)
- **Local Reference**: `~/dev/vbms-core/DEPLOYMENT-GUIDE.md`
- **Date**: November 2025 (verified working configuration)
- **Platform**: macOS ARM64 (Apple Silicon)

When the installation guide is updated, Core Cracker should be updated to match.
