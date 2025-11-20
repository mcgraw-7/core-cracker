# Core Cracker Tooling Overview

Core Cracker is a command-line toolkit that validates and repairs your VBMS Core local environment on macOS ARM64.

## Installation

```bash
git clone https://github.com/mcgraw-7/core-cracker.git ~/dev/core-cracker
cd ~/dev/core-cracker
chmod +x setup.sh scripts/**/*.sh

echo 'source ~/dev/core-cracker/aliases.sh' >> ~/.zshrc
source ~/.zshrc
```

## Setup Script

```bash
./setup.sh   # Validate environment and basic prerequisites
```

This script performs initial checks (Java, Maven, WebLogic paths) and ensures the tooling is executable.

## Command Categories

### Health and Diagnostics

```bash
vbms-health   # Comprehensive system health check
vbms-verify   # Quick environment verification
vbms-java     # Check Java configuration
vbms-wl       # Check WebLogic status
vbms-paths    # Analyze PATH and related environment variables
```

These commands verify that your system matches the requirements from the VBMS Core deployment guide.

### Auto-Fix Tools

```bash
vbms-fix      # Auto-fix environment issues
vbms-fix-dry  # Preview fixes without applying
```

Typical fixes include:

- Adding or correcting `JAVA_HOME` in `~/.zshrc`.
- Ensuring `MAVEN_OPTS` includes required memory and trust store flags.
- Setting `ORACLE_HOME` and `DOMAINS_HOME` correctly.
- Creating or updating `.wljava_env` with the correct Java configuration.
- Making `.sh` scripts executable.

### Backup and Restore

```bash
vbms-backup        # Backup environment configuration
vbms-restore       # Restore configuration
vbms-backup-list   # List all backups
vbms-backup-props  # Backup/restore vbmsDeveloper.properties only
```

The `vbms-backup-props` command focuses on `vbmsDeveloper.properties` because it is frequently overwritten by version upticks and contains critical settings (like the Hazelcast JVM flag).

Backup location:

- `~/dev/vbms-properties-backups/` with timestamped filenames, e.g.:
	- `vbmsDeveloper.properties.20250115-143022`

### Mapping to the Deployment Guide

Core Cracker automates many of the manual steps from:

- `vbms-core` GitHub Wiki: VBMS Core Installation Guide.
- Local `DEPLOYMENT-GUIDE.md` in the VBMS Core repo.

Examples:

- **Prerequisite checks**: `vbms-health`, `vbms-java`, and `vbms-wl` perform the same validations documented in the guide (JDK path, WebLogic home, domain presence, etc.).
- **Environment setup**: `vbms-fix` applies the exports and PATH edits recommended in the guide.
- **Configuration protection**: `vbms-backup-props` preserves `vbmsDeveloper.properties` between upticks, keeping the Hazelcast JVM flag and other customizations intact.

Using these commands regularly keeps your local environment aligned with the evolving official deployment instructions.

