# Prerequisites and Environment Variables

This document lists the required software, configuration, and environment variables for running VBMS Core locally, as implemented and validated by Core Cracker.

## Software Prerequisites

### Java (Zulu JDK 8 ARM64)

- **Location**:
	- `~/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home`
- **Version**:
	- `java -version` should show a Zulu 8 ARM64 build, for example:
	- `Zulu 8.90.0.19-CA-macos-aarch64` (1.8.0_472 or later).

### WebLogic

- **Version**: 12.2.1.4.0
- **Oracle Home**:
	- `~/dev/Oracle/Middleware/Oracle_Home`
- **Domain Home**:
	- `$ORACLE_HOME/user_projects/domains/P2-DEV`

### Maven

- **Version**: 3.9.9 or later.
- **Typical Homebrew path**:
	- `/opt/homebrew/Cellar/maven/<version>/libexec`

### Containers

- **Docker** installed and running.
- **Colima** used as the container runtime on macOS ARM64.

## Hosts File Configuration (`/etc/hosts`)

Required entries for VBMS Core local development:

```bash
# VBMS Core - Required
127.0.0.1       localhost
127.0.0.1       claims01.p2.vbms.va.gov
127.0.0.1       vbmsdb

# Docker/Kubernetes
127.0.0.1       kubernetes.docker.internal

# BIP Nexus
127.0.0.1       nexus.dev.bip.va.gov
```

Edit with:

```bash
sudo nano /etc/hosts
# or
sudo vi /etc/hosts
```

## Required Environment Variables (`~/.zshrc`)

Add the following to `~/.zshrc` and then source it.

```bash
# Java Home - ARM64 JDK 8
export JAVA_HOME="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# Maven Options - prevent GC overhead and set trust store
export MAVEN_OPTS="-Xms512m -Xmx8000m -Djavax.net.ssl.trustStore=$HOME/dev/cacerts"

# Oracle/WebLogic Homes
export ORACLE_HOME="$HOME/dev/Oracle/Middleware/Oracle_Home"
export DOMAINS_HOME="$ORACLE_HOME/user_projects/domains"

# VBMS Core repo home
export VBMS_HOME="$HOME/dev/vbms-core"

# Core Cracker aliases and VBMS functions
source "$HOME/dev/core-cracker/aliases.sh"
source "$HOME/dev/vbms-core/vbms-functions.sh"
```

Apply changes:

```bash
source ~/.zshrc
```

## Validation with Core Cracker

Use Core Cracker commands to verify prerequisites and environment variables:

```bash
vbms-health    # Comprehensive health check
vbms-verify    # Quick environment verification
vbms-java      # Java configuration details
vbms-wl        # WebLogic environment validation
```

These commands ensure your environment matches the expectations from the official deployment guide.

