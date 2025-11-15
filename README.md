# VA Core Local Development Environment Setup

Configuration scripts for VA Core local development environment setup. Automates dependency checks, environment validation, and Oracle configuration for Apple Silicon (M1/M2/M3) and Intel Macs.

## Important Requirements

WebLogic **must** be installed in the Oracle standardized directory:

```
${HOME}/dev/Oracle/Middleware/Oracle_Home
```

ARM64 Zulu JDK 8 must be installed at:

```
${HOME}/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk
```

**Note**: Download Zulu JDK 8 ARM64 from [Azul's website](https://www.azul.com/downloads/?version=java-8-lts&os=macos&architecture=arm-64-bit&package=jdk)

## Quick Start

1. Clone and setup:

   ```bash
   git clone https://github.com/mcgraw-7/core-cracker.git ~/dev/core-cracker
   cd ~/dev/core-cracker
   chmod +x setup.sh scripts/**/*.sh
   ```

2. Load global aliases (add to ~/.zshrc):

   ```bash
   # VA Core development aliases
   source ~/dev/core-cracker/aliases.sh
   ```

3. Apply changes:

   ```bash
   source ~/.zshrc
   ```

4. Run verification:

   ```bash
   vbms-auto
   # or
   ./setup.sh --auto
   ```

## Usage

### Auto-Run Mode

Automatically run all verification checks:

```bash
./setup.sh --auto
# or
./setup.sh -a
# or
AUTO_RUN_CHECKS=true ./setup.sh
```

### Interactive Mode

Run the setup script and select from the available options:

```bash
./setup.sh
```

## System Requirements

- macOS (Apple Silicon M1/M2/M3/M4 recommended)
- ARM64 Zulu JDK 8 (version 1.8.0_472 or later)
- WebLogic Server 12.2.1.4.0
- Maven 3.9.9+
- Colima/Docker (for Oracle database container)

## Links

- **[VBMS Core Deployment Guide](https://github.com/department-of-veterans-affairs/vbms-core/blob/development/DEPLOYMENT-GUIDE.md)** - Complete deployment strategy
- **[Core DB Notes](https://boozallen.enterprise.slack.com/docs/T02UXS1N2/F08UG28LKS6)** - Slack Canvas with core database notes

## Critical Configuration

### Environment Variables (~/.zshrc)

```bash
# Java Home - ARM64 Zulu JDK 8
export JAVA_HOME="${HOME}/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# Maven Options - CRITICAL for preventing GC overhead errors
export MAVEN_OPTS="-Xms512m -Xmx8000m"

# Oracle/WebLogic Homes
export ORACLE_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
export DOMAINS_HOME="${HOME}/dev/Oracle/Middleware/user_projects/domains"

# VA Core development aliases
source ~/dev/core-cracker/aliases.sh
```

Apply changes: `source ~/.zshrc`

## Usage with Aliases

After sourcing `aliases.sh`, you can use convenient shortcuts:

```bash
# Quick diagnostics
vbms-health           # Full system health check
vbms-auto             # Run all verification checks

# Java management
vbms-java             # Check Java installation
vbms-java-versions    # List all installed Java versions

# WebLogic
vbms-wl               # Check WebLogic environment
vbms-wl-status        # Check server status

# Quick fixes
vbms-fix              # Auto-fix all issues
vbms-fix-java         # Fix JAVA_HOME only
vbms-fix-dry          # Dry run (show what would be fixed)

# Backup
vbms-backup           # Create environment backup
vbms-backups          # List available backups

# Help
vbms-help             # Show all available commands
```

See `vbms-help` for complete list of aliases.

## Documentation

- **[JDK Compatibility Issue](docs/jdk-compatibility-issue.md)** - WebLogic JDK 17 vs JDK 8 compatibility problem and solution
- **[Core DB Notes](https://boozallen.enterprise.slack.com/docs/T02UXS1N2/F08UG28LKS6)** - links to Slack Canvas with my notes on core db
