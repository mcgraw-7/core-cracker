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

## References

- [VBMS Deployment Guide](https://github.com/department-of-veterans-affairs/vbms-core/blob/development/DEPLOYMENT-GUIDE.md)
- [Zulu JDK 8 Downloads](https://www.azul.com/downloads/?version=java-8-lts&os=macos&architecture=arm-64-bit&package=jdk)
