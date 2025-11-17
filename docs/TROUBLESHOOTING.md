# Troubleshooting Guide

Common issues and solutions for VA Core local development environment setup.

## Table of Contents

- [Java Issues](#java-issues)
- [WebLogic Issues](#weblogic-issues)
- [Apple Silicon Issues](#apple-silicon-issues)
- [Docker/Colima Issues](#dockercolima-issues)
- [Environment Variables](#environment-variables)
- [Path Issues](#path-issues)
- [Script Errors](#script-errors)

---

## Java Issues

### JAVA_HOME not set

**Symptom:**
```
[FAIL] JAVA_HOME not set or incorrect
```

**Solution:**
```bash
# Set JAVA_HOME in ~/.zshrc
export JAVA_HOME="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"
export PATH="${JAVA_HOME}/bin:${PATH}"

# Reload shell configuration
source ~/.zshrc

# Verify
echo $JAVA_HOME
java -version
```

---

### [FAIL] Wrong Java Version

**Symptom:**
```
java version "17.0.9" detected
Expected: 1.8.0_202
```

**Solution:**
```bash
# Check all installed Java versions
./scripts/utils/java-versions.sh

# Set correct JAVA_HOME
export JAVA_HOME="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"

# Quick fix
./scripts/utils/quick-fix.sh --java-home

# Verify
java -version
```

---

### [FAIL] Oracle JDK Not Found

**Symptom:**
```
[FAIL] Oracle JDK 1.8.0_202 not found at expected location
```

**Solution:**

1. **Download Oracle JDK 1.8.0_202:**
   - Visit [Oracle Java Archive](https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html)
   - Download macOS x64 DMG installer

2. **Install:**
   ```bash
   # Mount and install DMG
   # Or use Homebrew cask (if available)
   
   # Verify installation
   ls -la /Library/Java/JavaVirtualMachines/
   ```

3. **Set JAVA_HOME:**
   ```bash
   export JAVA_HOME="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"
   ```

---

### [FAIL] Multiple Java Versions Conflicting

**Symptom:**
```
java -version shows different version than JAVA_HOME
```

**Solution:**
```bash
# Check what's in PATH
./scripts/utils/analyze-paths-config-tool.sh

# Find Java in PATH
which java

# Check for Java wrappers
which -a java

# Clean PATH
# Edit ~/.zshrc and ensure JAVA_HOME/bin is first
export PATH="${JAVA_HOME}/bin:/usr/local/bin:/usr/bin:/bin"

source ~/.zshrc
```

---

## WebLogic Issues

### [FAIL] WebLogic Not Found

**Symptom:**
```
[FAIL] WebLogic installation not found
```

**Solution:**

1. **Verify installation path:**
   ```bash
   ls -la ~/dev/Oracle/Middleware/Oracle_Home
   ```

2. **Check expected structure:**
   ```bash
   ./scripts/utils/verify-oracle-directory.sh
   ```

3. **Set environment variables:**
   ```bash
   export MW_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
   export DOMAIN_HOME="${MW_HOME}/user_projects/domains/your_domain"
   ```

---

### [FAIL] WebLogic Won't Start

**Symptom:**
```
Error: Could not create the Java Virtual Machine
```

**Solution:**

1. **Check Java compatibility:**
   ```bash
   ./scripts/utils/test-java-weblogic-compatibility.sh
   ```

2. **Verify JAVA_HOME in domain:**
   ```bash
   cat ${DOMAIN_HOME}/bin/setDomainEnv.sh | grep JAVA_HOME
   ```

3. **Check WebLogic Java config:**
   ```bash
   cat ~/.wljava_env
   # Should contain:
   export JAVA_HOME="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"
   ```

4. **Start with correct Java:**
   ```bash
   source ~/.wljava_env
   cd ${DOMAIN_HOME}/bin
   ./startWebLogic.sh
   ```

---

### [FAIL] Bouncy Castle Provider Error

**Symptom:**
```
java.security.NoSuchProviderException: no such provider: BC
```

**Solution:**

See [BOUNCY_CASTLE_ISSUE.md](BOUNCY_CASTLE_ISSUE.md) for detailed solution.

**Quick Fix:**
```bash
# Ensure using Oracle JDK 1.8.0_202, not OpenJDK
echo $JAVA_HOME
# Should be: $HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home

# Restart WebLogic with correct Java
```

---

### [FAIL] Domain Configuration Issues

**Symptom:**
```
Domain configuration appears corrupted
```

**Solution:**

1. **Backup domain:**
   ```bash
   ./scripts/utils/env-backup.sh
   ```

2. **Check domain config:**
   ```bash
   cd ${DOMAIN_HOME}
   cat config/config.xml | head -20
   ```

3. **Restore from backup:**
   ```bash
   ./scripts/utils/env-backup.sh --restore backup-YYYYMMDD-HHMMSS.tar.gz
   ```

---

## Apple Silicon Issues

### [FAIL] Oracle Database Won't Run (ARM64)

**Symptom:**
```
exec format error: Oracle database image
```

**Solution:**

Oracle Database requires x86_64 architecture. Use Colima with emulation:

```bash
# Stop existing Colima instance
colima stop

# Start with x86_64 emulation
colima start --arch x86_64 --cpu 4 --memory 8 --disk 60

# Verify architecture
docker run --rm -it --platform linux/amd64 oraclelinux:8 uname -m
# Should output: x86_64
```

---

### [FAIL] Rosetta 2 Not Installed

**Symptom:**
```
[FAIL] Rosetta 2 is not installed
```

**Solution:**
```bash
# Install Rosetta 2
softwareupdate --install-rosetta --agree-to-license

# Verify
/usr/bin/pgrep -q oahd && echo "Rosetta 2 installed" || echo "Not installed"
```

---

### [FAIL] Java Architecture Mismatch

**Symptom:**
```
Java binary is arm64 but x86_64 required
```

**Solution:**
```bash
# Check Java architecture
file $HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home/bin/java

# Oracle JDK 1.8.0_202 should be x86_64
# If arm64, reinstall correct version

# Download x86_64 version of Oracle JDK
# Install and verify
```

---

## Docker/Colima Issues

### [FAIL] Colima Not Running

**Symptom:**
```
[FAIL] Colima is not running
Cannot connect to Docker daemon
```

**Solution:**
```bash
# Check status
colima status

# Start Colima
colima start --arch x86_64 --cpu 4 --memory 8

# Verify Docker
docker info
```

---

### [FAIL] Docker Command Not Found

**Symptom:**
```
zsh: command not found: docker
```

**Solution:**
```bash
# Install Docker CLI
brew install docker

# Install Colima
brew install colima

# Start Colima
colima start

# Verify
docker --version
```

---

### [FAIL] Docker Permission Denied

**Symptom:**
```
permission denied while trying to connect to Docker daemon
```

**Solution:**
```bash
# Check Docker socket
ls -la /var/run/docker.sock

# Restart Colima
colima stop
colima start

# Test
docker ps
```

---

### [FAIL] Colima Architecture Wrong

**Symptom:**
```
Colima running with arm64 but x86_64 needed
```

**Solution:**
```bash
# Stop and delete existing instance
colima stop
colima delete

# Start with correct architecture
colima start --arch x86_64 --cpu 4 --memory 8

# Verify
colima status | grep arch
```

---

## Environment Variables

### [FAIL] Environment Variables Not Persisting

**Symptom:**
```
Variables work in current session but disappear after restart
```

**Solution:**

1. **Add to shell config:**
   ```bash
   # Edit ~/.zshrc
   nano ~/.zshrc
   
   # Add these lines:
   export JAVA_HOME="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"
   export MW_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
   export PATH="${JAVA_HOME}/bin:${PATH}"
   
   # Save and reload
   source ~/.zshrc
   ```

2. **Verify persistence:**
   ```bash
   # Open new terminal
   echo $JAVA_HOME
   echo $MW_HOME
   ```

---

### [FAIL] MW_HOME Not Set

**Symptom:**
```
[FAIL] MW_HOME environment variable not set
```

**Solution:**
```bash
# Set temporarily
export MW_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"

# Make permanent
echo 'export MW_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"' >> ~/.zshrc

source ~/.zshrc
```

---

## Path Issues

### [FAIL] Wrong Java in PATH

**Symptom:**
```
which java shows /usr/bin/java instead of Oracle JDK
```

**Solution:**
```bash
# Check PATH order
echo $PATH | tr ':' '\n' | nl

# Fix PATH - put JAVA_HOME first
export PATH="${JAVA_HOME}/bin:${PATH}"

# Make permanent
echo 'export PATH="${JAVA_HOME}/bin:${PATH}"' >> ~/.zshrc
source ~/.zshrc

# Verify
which java
java -version
```

---

### [FAIL] Path Contains Duplicates

**Symptom:**
```
PATH has multiple Java entries
```

**Solution:**
```bash
# View current PATH
./scripts/utils/analyze-paths-config-tool.sh

# Clean duplicates manually in ~/.zshrc
# Or use script
./scripts/utils/quick-fix.sh --paths
```

---

## Script Errors

### [FAIL] Permission Denied

**Symptom:**
```
zsh: permission denied: ./setup.sh
```

**Solution:**
```bash
# Make executable
chmod +x setup.sh
chmod +x scripts/**/*.sh

# Or individual script
chmod +x scripts/utils/health-check.sh

# Verify
ls -la setup.sh
```

---

### [FAIL] Script Not Found

**Symptom:**
```
zsh: no such file or directory: ./scripts/utils/script.sh
```

**Solution:**
```bash
# Verify you're in repository root
pwd
# Should be: /Users/yourusername/dev/core-cracker

# List scripts
ls -la scripts/utils/

# Run from correct location
cd /path/to/core-cracker
./scripts/utils/script.sh
```

---

### [FAIL] Color Codes Not Working

**Symptom:**
```
Scripts show ^[[0;32m instead of colors
```

**Solution:**

1. **Check terminal:**
   - Use Terminal.app, iTerm2, or modern terminal
   - Ensure terminal supports ANSI colors

2. **Force color output:**
   ```bash
   # Set terminal type
   export TERM=xterm-256color
   ```

---

## General Troubleshooting Steps

### 1. Run Health Check

```bash
./scripts/utils/health-check.sh
```

### 2. Run All Verifications

```bash
./setup.sh --auto
```

### 3. Check Individual Components

```bash
# Java
./scripts/utils/java-check.sh

# WebLogic
./scripts/utils/check-weblogic.sh

# Standardization
./scripts/utils/verify-standardization.sh

# Apple Silicon
./scripts/utils/check-apple-silicon.sh
```

### 4. Enable Debug Mode

```bash
# Run scripts with debug output
DEBUG=true ./scripts/utils/health-check.sh

# Enable verbose mode
./setup.sh --verbose
```

### 5. Check Logs

```bash
# View script logs
cat ~/.core-cracker/logs/health-check.log

# View WebLogic logs
tail -f ${DOMAIN_HOME}/servers/AdminServer/logs/AdminServer.log
```

### 6. Backup Before Changes

```bash
# Always backup before making changes
./scripts/utils/env-backup.sh
```

### 7. Quick Fix Common Issues

```bash
# Try automatic fixes
./scripts/utils/quick-fix.sh

# Dry run first
./scripts/utils/quick-fix.sh --dry-run
```

---

## Getting Help

If issues persist:

1. **Check existing issues:**
   - [GitHub Issues](https://github.com/mcgraw-7/core-cracker/issues)

2. **Create new issue:**
   - Include output of `./setup.sh --auto`
   - Include system info: `uname -a`
   - Include Java version: `java -version`
   - Include error messages

3. **Discussions:**
   - [GitHub Discussions](https://github.com/mcgraw-7/core-cracker/discussions)

---

## Quick Reference

### Essential Commands

```bash
# Full verification
./setup.sh --auto

# Health check
./scripts/utils/health-check.sh

# Java check
java -version
echo $JAVA_HOME

# WebLogic check
./scripts/utils/check-weblogic.sh

# Backup
./scripts/utils/env-backup.sh

# Quick fix
./scripts/utils/quick-fix.sh
```

### Essential Paths

```bash
# Java
$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home

# WebLogic
~/dev/Oracle/Middleware/Oracle_Home

# Config files
~/.zshrc
~/.wljava_env

# Logs
~/.core-cracker/logs/
${DOMAIN_HOME}/servers/AdminServer/logs/
```
