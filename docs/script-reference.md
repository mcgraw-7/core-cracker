# Script Reference

Complete reference for all scripts in the core-cracker toolkit.

## Table of Contents

- [Core Setup](#core-setup)
- [Utility Scripts](#utility-scripts)
- [WebLogic Scripts](#weblogic-scripts)
- [Script Output](#script-output)

## Core Setup

### `setup.sh`

Main entry point for the toolkit. Provides interactive menu and auto-run capability.

**Location:** `/`

**Usage:**
```bash
# Interactive mode
./setup.sh

# Auto-run all checks
./setup.sh --auto
./setup.sh -a
AUTO_RUN_CHECKS=true ./setup.sh
```

**Options:**
| Flag | Description |
|------|-------------|
| `--auto`, `-a` | Run all verification checks automatically |

**Features:**
- Color-coded output (green=success, red=error, yellow=warning)
- Pre-flight Oracle JDK validation
- Interactive menu for individual checks
- Automated verification mode

**Menu Options:**
1. Path Analysis
2. WebLogic Environment Check
3. VA Core Standardization Verification
4. Oracle Directory Structure Verification
5. Apple Silicon Compatibility Check
6. System Health Check
7. Environment Backup
8. Quick Fix Common Issues

---

## Utility Scripts

### `analyze-paths-config-tool.sh`

Comprehensive analysis of PATH, JAVA_HOME, and environment configuration.

**Location:** `scripts/utils/`

**Purpose:**
- Analyze PATH variable for Java installations
- Verify JAVA_HOME configuration
- Check for conflicting Java versions
- Display all Java-related environment variables

**Output:**
```
=== Java Environment Configuration ===
JAVA_HOME: $HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home 
Current Java: java version "1.8.0_202" 

=== PATH Analysis ===
PATH entries containing 'java':
  1. $HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home/bin
```

**Exit Codes:**
- `0` - Configuration valid
- `1` - Critical issues found

---

### `check-apple-silicon.sh`

Detect and validate Apple Silicon (ARM64) compatibility.

**Location:** `scripts/utils/`

**Checks:**
- CPU architecture (arm64 vs x86_64)
- Colima installation and status
- Docker installation and functionality
- Rosetta 2 installation
- Oracle JDK architecture compatibility

**Usage:**
```bash
./scripts/utils/check-apple-silicon.sh
```

**Output Example:**
```
[PASS] Detected Apple Silicon Mac (arm64)

Checking Colima status...
[PASS] Colima is installed
[PASS] Colima is running
[PASS] Colima is running with x86_64 architecture

Checking Docker...
[PASS] Docker is installed
[PASS] Docker is working correctly

Checking Rosetta 2...
[PASS] Rosetta 2 is installed
```

**Exit Codes:**
- `0` - Apple Silicon detected, all compatible
- `0` - Intel Mac (exits early)

---

### `check-weblogic.sh`

Validate WebLogic Server environment configuration.

**Location:** `scripts/utils/`

**Validates:**
- `MW_HOME` environment variable
- WebLogic installation directory structure
- WebLogic version
- Domain configurations

**Usage:**
```bash
./scripts/utils/check-weblogic.sh
```

**Required Environment Variables:**
```bash
export MW_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
```

---

### `compare-configuration.sh`

Compare environment configurations across different setups.

**Location:** `scripts/utils/`

**Purpose:**
- Compare current config vs reference
- Identify configuration drift
- Export configuration profiles

**Usage:**
```bash
# Compare with reference
./scripts/utils/compare-configuration.sh

# Export current configuration
./scripts/utils/compare-configuration.sh --export > my-config.txt
```

---

### `health-check.sh`

Comprehensive system health diagnostic.

**Location:** `scripts/utils/`

**Checks:**
- [PASS] Java installation and version
- [PASS] WebLogic installation and status
- [PASS] Environment variables
- [PASS] Directory structure
- [PASS] Required tools (git, docker, colima)
- [PASS] Network connectivity
- [PASS] Disk space
- [PASS] Memory availability

**Usage:**
```bash
./scripts/utils/health-check.sh
```

**Output:**
```
[HEALTH] System Health Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Java Environment         [PASS] PASS
WebLogic Installation    [PASS] PASS
Environment Variables    [WARN]  WARNING
Directory Structure      [PASS] PASS
Required Tools          [PASS] PASS
Network Connectivity    [PASS] PASS
Disk Space              [PASS] PASS (127 GB available)
Memory                  [PASS] PASS (8 GB available)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall Status: [WARN]  WARNINGS FOUND

[WARN]  Warnings:
  - MW_HOME not set in current shell
  
[TIP] Recommendations:
  - Add MW_HOME to ~/.zshrc
  - Run: export MW_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
```

---

### `java-check.sh`

Verify Java installation and configuration.

**Location:** `scripts/utils/`

**Validates:**
- Java executable accessibility
- Java version
- JAVA_HOME setting
- JDK vs JRE
- Architecture (x86_64 vs arm64)

**Usage:**
```bash
./scripts/utils/java-check.sh
```

---

### `java-versions.sh`

List all installed Java versions.

**Location:** `scripts/utils/`

**Usage:**
```bash
./scripts/utils/java-versions.sh
```

**Output:**
```
Available Java Versions:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[PASS] $HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk
   Version: 1.8.0_202
   Architecture: x86_64
   Currently active: YES

⚪ /Library/Java/JavaVirtualMachines/jdk-17.jdk
   Version: 17.0.9
   Architecture: arm64
   Currently active: NO
```

---

### `test-java-switching.sh`

Test Java version switching capabilities.

**Location:** `scripts/utils/`

**Purpose:**
- Verify ability to switch Java versions
- Test JAVA_HOME updates
- Validate PATH updates

**Usage:**
```bash
./scripts/utils/test-java-switching.sh
```

---

### `test-java-weblogic-compatibility.sh`

Test Java and WebLogic compatibility.

**Location:** `scripts/utils/`

**Tests:**
- Java version compatibility with WebLogic
- WebLogic startup with specific Java version
- Bouncy Castle provider compatibility

---

### `verify-oracle-directory.sh`

Verify Oracle/WebLogic directory structure.

**Location:** `scripts/utils/`

**Expected Structure:**
```
${HOME}/dev/Oracle/Middleware/Oracle_Home/
├── coherence/
├── inventory/
├── oracle_common/
├── wlserver/
│   ├── server/
│   │   └── lib/
│   └── common/
└── user_projects/
    └── domains/
```

**Usage:**
```bash
./scripts/utils/verify-oracle-directory.sh
```

---

### `verify-standardization.sh`

Verify VA Core environment standardization.

**Location:** `scripts/utils/`

**Validates:**
- Oracle JDK installation at standard path
- `.wljava_env` configuration
- Standardized scripts directory
- Critical script presence
- Environment variable configuration

**Usage:**
```bash
./scripts/utils/verify-standardization.sh
```

---

### `env-backup.sh`

Backup and restore environment configurations.

**Location:** `scripts/utils/`

**Usage:**
```bash
# Create backup
./scripts/utils/env-backup.sh

# Restore from backup
./scripts/utils/env-backup.sh --restore backup-2025-11-14-120000.tar.gz

# List backups
./scripts/utils/env-backup.sh --list
```

**Backed Up Files:**
- `~/.zshrc`
- `~/.wljava_env`
- `~/.bash_profile`
- `~/dev/Oracle/Middleware/Oracle_Home/domains/*/config.xml`

**Backup Location:** `~/.env-backups/`

---

### `quick-fix.sh`

Auto-fix common environment issues.

**Location:** `scripts/utils/`

**Fixes:**
- [PASS] JAVA_HOME misconfiguration
- [PASS] Missing PATH entries
- [PASS] WebLogic environment variables
- [PASS] Missing directories
- [PASS] Incorrect file permissions

**Usage:**
```bash
# Fix all issues
./scripts/utils/quick-fix.sh

# Fix specific issue
./scripts/utils/quick-fix.sh --java-home
./scripts/utils/quick-fix.sh --weblogic
./scripts/utils/quick-fix.sh --paths
./scripts/utils/quick-fix.sh --permissions
```

**Dry Run:**
```bash
./scripts/utils/quick-fix.sh --dry-run
```

---

## WebLogic Scripts

### `check-weblogic-status.sh`

Check WebLogic Server running status.

**Location:** `scripts/weblogic/`

**Usage:**
```bash
./scripts/weblogic/check-weblogic-status.sh
```

**Output:**
```
WebLogic Server Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

AdminServer:    [PASS] RUNNING (PID: 12345)
  Port:         7001
  Memory:       2.1 GB / 4.0 GB
  Uptime:       3h 24m

ManagedServer1: [FAIL] STOPPED
```

**Exit Codes:**
- `0` - All servers running
- `1` - One or more servers stopped
- `2` - No servers found

---

## Script Output

### Color Codes

All scripts use consistent color coding:

- 🟢 **Green** - Success, items found, passed checks
- 🔴 **Red** - Errors, items not found, failed checks
- 🟡 **Yellow** - Warnings, recommendations
- 🔵 **Blue** - Informational messages, headers

### Exit Codes

Standard exit codes across all scripts:

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | General error or check failed |
| `2` | Missing required dependency |
| `3` | Invalid configuration |
| `130` | Interrupted by user (Ctrl+C) |

### Log Files

Scripts may generate log files in:
- `~/.core-cracker/logs/`
- Individual script logs: `~/.core-cracker/logs/<script-name>.log`

---

## Environment Variables Reference

### Required Variables

```bash
# Java
export JAVA_HOME="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"

# WebLogic
export MW_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
export DOMAIN_HOME="${MW_HOME}/user_projects/domains/mydomain"

# Path
export PATH="${JAVA_HOME}/bin:${PATH}"
```

### Optional Variables

```bash
# Debugging
export DEBUG=true                    # Enable debug output
export VERBOSE=true                  # Verbose logging

# Auto-run
export AUTO_RUN_CHECKS=true         # Auto-run setup.sh checks

# Colima
export COLIMA_ARCH="x86_64"         # Force Colima architecture
```

---

## Tips & Best Practices

### Running Scripts

1. **Always make scripts executable first:**
   ```bash
   chmod +x scripts/**/*.sh
   ```

2. **Run from repository root:**
   ```bash
   cd /path/to/core-cracker
   ./setup.sh
   ```

3. **Use auto-run for CI/CD:**
   ```bash
   ./setup.sh --auto
   ```

### Troubleshooting

1. **Enable debug mode:**
   ```bash
   DEBUG=true ./scripts/utils/health-check.sh
   ```

2. **Check script logs:**
   ```bash
   cat ~/.core-cracker/logs/health-check.log
   ```

3. **Verify permissions:**
   ```bash
   ls -la scripts/utils/*.sh
   ```

---

## Contributing

When adding new scripts:

1. Follow naming convention: `lowercase-with-hyphens.sh`
2. Add shebang: `#!/bin/zsh`
3. Include color codes for output
4. Add to this reference document
5. Update main README menu if user-facing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for details.
