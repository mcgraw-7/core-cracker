# VBMS Core Deployment Guide

Complete guide for deploying VBMS Core to WebLogic on macOS ARM64

## Prerequisites

### 1. Java Environment
- **ARM64 Zulu JDK 8**: `~/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home`
- **Version**: 1.8.0_472 or later
- **Verify**: `java -version` should show "Zulu 8.90.0.19-CA-macos-aarch64"

### 2. WebLogic Environment
- **Oracle Home**: `~/dev/Oracle/Middleware/Oracle_Home`
- **Domain Home**: `$ORACLE_HOME/user_projects/domains/P2-DEV`
- **WebLogic Version**: 12.2.1.4.0

### 3. Maven
- **Version**: 3.9.9+
- **Location**: `/opt/homebrew/Cellar/maven/<version>/libexec` (or wherever installed)

### 4. Hosts File Configuration (/etc/hosts)

**Required entries for local development**:

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

**To edit /etc/hosts**:
```bash
sudo nano /etc/hosts
# Or
sudo vi /etc/hosts
```

**⚠️ GOTCHA**: Without these entries, database connections and internal service calls will fail.

---

## Environment Variables Configuration

### Required Shell Environment Variables (~/.zshrc)

```bash
# Java Home - ARM64 JDK 8
export JAVA_HOME="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# Maven Options - CRITICAL for preventing GC overhead errors
export MAVEN_OPTS="-Xms512m -Xmx8000m -Djavax.net.ssl.trustStore=$HOME/dev/cacerts"

# Oracle/WebLogic Homes
export ORACLE_HOME="$HOME/dev/Oracle/Middleware/Oracle_Home"
export DOMAINS_HOME="$ORACLE_HOME/user_projects/domains"

# VBMS specific
export VBMS_HOME="$HOME/dev/vbms-core"

# Source utility functions
source $HOME/dev/vbms-core/vbms-functions.sh
```

**Apply changes**: `source ~/.zshrc`

---

## Critical Configuration Files

### 1. vbmsDeveloper.properties
**Location**: `$VBMS_HOME/vbms-install-weblogic/src/main/resources/vbmsDeveloper.properties`

**Required Settings**:

```properties
# Java SDK - MUST be ARM64 version
javaSDKHome=/Users/<your-username>/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home

# Domain Configuration
domainName=P2-DEV
clustering=false

# Oracle Middleware
middlewareHome=/Users/<your-username>/dev/Oracle/Middleware/Oracle_Home
domainsHome=/Users/<your-username>/dev/Oracle/Middleware/Oracle_Home/user_projects/domains

# Proxy Settings (adjust as needed)
proxyHost=127.0.0.1
proxyPort=9443
proxyUser=<your-username>
proxyPassword=<your-password>

# JVM Memory - Increased for stability
javaMemArgs=-Xms2000m -Xmx8000m -d64 -XX:CompileThreshold=8000 -Dsun.net.http.retryPost=false -Dhttp.proxyHost=${proxyHost} -Dhttp.proxyPort=${proxyPort} -Dhttp.proxyUser=${proxyUser} -Dhttp.proxyPassword=${proxyPassword} -Dhttps.proxyHost=${proxyHost} -Dhttps.proxyPort=${proxyPort} -Dhttp.nonProxyHosts=*.p2.vbms.va.gov

# Production Mode
productionMode=false

# CRITICAL: Hazelcast MUST be disabled
## HAZELCAST DISABLED - DO NOT ENABLE
hazelcastStartLinux=

hazelcastStopLinux=
```

**⚠️ GOTCHA**: If Hazelcast is enabled, it will cause startup issues and resource conflicts.

---

## Step-by-Step Deployment Process

### Step 1: Verify Environment

```bash
# Check Java version (must be ARM64 Zulu 8)
java -version

# Check JAVA_HOME
echo $JAVA_HOME
# Expected: ~/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home

# Check Maven
mvn -version

# Check MAVEN_OPTS
echo $MAVEN_OPTS
# Expected: -Xms512m -Xmx8000m -Djavax.net.ssl.trustStore=~/dev/cacerts
```

### Step 2: Build VBMS Core

```bash
# Option 1: Use alias (recommended)
buildcore

# Option 2: Use function
cd $VBMS_HOME/vbms
build-core

# Option 3: Manual
cd $VBMS_HOME/vbms
export MAVEN_OPTS="-Xms512m -Xmx8000m -Djavax.net.ssl.trustStore=$HOME/dev/cacerts"
mvn clean install -U -T5C -Dmaven.test.skip=true
```

**Build Time**: 10-20 minutes  
**Success Indicator**: `[INFO] BUILD SUCCESS`

**⚠️ GOTCHA**: If you get "GC overhead limit exceeded", check that:
- `MAVEN_OPTS` is set with at least `-Xmx8000m`
- You're using parallel builds with `-T5C`

### Step 3: Rebuild WebLogic Domain (if needed)

**When to rebuild**:
- First time setup
- After changing `vbmsDeveloper.properties`
- After changing Java version
- After WebLogic configuration changes

```bash
cd $VBMS_HOME/vbms-install-weblogic
export JAVA_HOME=$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH
mvn clean install -DskipTests
```

**⚠️ GOTCHA**: Domain rebuild deletes the old domain completely. Backup any custom configurations first.

### Step 4: Clear WebLogic Cache (recommended before deploy)

```bash
clear-core-cache
```

Or manually:
```bash
cd $DOMAINS_HOME/P2-DEV
rm -rf servers/AdminServer/tmp/*
rm -rf servers/AdminServer/cache/*
rm -rf servers/AdminServer/data/ldap/ldapfiles/*
```

### Step 5: Start WebLogic Server

```bash
cd $DOMAINS_HOME/P2-DEV
./bin/startWebLogic.sh

# Or in background:
nohup ./bin/startWebLogic.sh > weblogic.out 2>&1 &
```

**Startup Time**: 20-30 seconds  
**Success Indicator**: `<Notice> <WebLogicServer> <BEA-000360> <The server started in RUNNING mode.>`

**Verify**:
```bash
# Check if WebLogic is running
ps aux | grep weblogic.Server | grep -v grep

# Check if port 7001 is listening
lsof -i :7001

# Check startup logs
tail -f $DOMAINS_HOME/P2-DEV/servers/AdminServer/logs/AdminServer.log
```

### Step 6: Deploy Application

```bash
deploy-core
```

Or manually:
```bash
cp $VBMS_HOME/vbms/vbms/target/vbms-*.war \
   $DOMAINS_HOME/P2-DEV/autodeploy/
```

**What is Autodeploy?**

`autodeploy/` is a WebLogic feature that automatically deploys applications:
- **Monitors directory**: WebLogic watches this folder for new/updated WAR/EAR files
- **Hot deployment**: Deploys without restarting the server (if running)
- **Automatic**: No manual intervention needed via console
- **Development mode**: Only works when domain is in development mode (not production)

**Autodeploy Process**:
1. Copy WAR file to `autodeploy/` directory
2. WebLogic detects the file within seconds
3. Application is automatically deployed
4. Access application at configured context path

**⚠️ GOTCHA**: 
- Must use `autodeploy` directory, not `applications` (manual deployments only)
- WebLogic must be running for hot deployment
- If server is stopped, deployment occurs on next startup
- Files in autodeploy are temporary - removed on domain rebuild

### Step 7: Verify Deployment

1. **Access WebLogic Console**:
   - URL: http://localhost:7001/console
   - Default Credentials: weblogic/weblogic1 (or as configured)

2. **Check Deployment Status**:
   - Console → Deployments
   - Look for `vbms-*.war` in Active state

3. **Access Application** (once deployed):
   - URL: http://localhost:7001/vbms

---

## Common Issues & Solutions

### Issue 1: Hazelcast Starting Despite Being Disabled
**Symptom**: Startup log shows "Starting Hazelcast Server" even though it's disabled in properties

**Root Cause**: The Hazelcast startup code is baked into the domain's `startWebLogic.sh` during domain creation. Setting `hazelcastStartLinux=` in properties only affects NEW domains.

**Quick Fix** (edit existing domain):
```bash
# Stop WebLogic first
pkill -9 -f weblogic.Server

# Comment out Hazelcast startup in domain script
# Find lines 101-105 in startWebLogic.sh and comment them out:
vi $DOMAINS_HOME/P2-DEV/bin/startWebLogic.sh

# Or use sed to comment them out automatically:
sed -i.bak '/^echo "Starting Hazelcast Server"/,/^cd \$CURRENT_DIR/ s/^/# /' \
  $DOMAINS_HOME/P2-DEV/bin/startWebLogic.sh

# Add a comment above it:
sed -i '' '/^# echo "Starting Hazelcast Server"/ i\
## HAZELCAST DISABLED - Commented out to prevent startup
' $DOMAINS_HOME/P2-DEV/bin/startWebLogic.sh

# Verify it's commented out
grep -A6 "HAZELCAST DISABLED" $DOMAINS_HOME/P2-DEV/bin/startWebLogic.sh

# Restart WebLogic
cd $DOMAINS_HOME/P2-DEV
./bin/startWebLogic.sh
```

**Long-term Fix**: Set `hazelcastStartLinux=` (empty) in `vbmsDeveloper.properties` before building NEW domains

### Issue 2: Wrong JDK in CLASSPATH
**Symptom**: Startup log shows `/Library/Java/JavaVirtualMachines/zulu-8.jdk` (x86) in CLASSPATH

**Impact**: Usually benign - the actual Java runtime (`JAVA_HOME`) is correct (ARM64). The x86 JDK in classpath is just for `tools.jar` and typically doesn't cause issues.

**Fix if needed**: Rebuild domain (see Step 3), but only necessary if you experience actual problems

### Issue 3: Wrong Java Version Used
**Symptom**: WebLogic startup shows wrong Java path

**Solution**:
```bash
# Check current JAVA_HOME
echo $JAVA_HOME

# Should be: ~/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home
# If not, update ~/.zshrc and reload:
source ~/.zshrc

# Rebuild domain to update startup scripts
cd $VBMS_HOME/vbms-install-weblogic
mvn clean install -DskipTests
```

### Issue 4: Maven GC Overhead Error
**Symptom**: "java.lang.OutOfMemoryError: GC overhead limit exceeded"

**Solution**:
```bash
# Check MAVEN_OPTS
echo $MAVEN_OPTS

# Should include: -Xmx8000m
# If not, add to ~/.zshrc:
export MAVEN_OPTS="-Xms512m -Xmx8000m -Djavax.net.ssl.trustStore=$HOME/dev/cacerts"

source ~/.zshrc
```

### Issue 5: Port Already in Use
**Symptom**: "Address already in use" when starting WebLogic

**Solution**:
```bash
# Find process using port 7001
lsof -i :7001

# Kill the process
kill -9 <PID>

# Or kill all WebLogic processes
pkill -9 -f weblogic.Server
```

### Issue 6: Database Connection Failures
**Symptom**: Application fails to connect to database, errors like "Connection refused" or "TNS listener"

**Current Database Configuration**: Oracle XE (local)
- **Host**: `vbmsdb` (must be in /etc/hosts)
- **Port**: 1521
- **SID**: XE
- **JDBC URL**: `jdbc:oracle:thin:@vbmsdb:1521/XE`

**Troubleshooting Steps**:

1. **Verify /etc/hosts entry**:
   ```bash
   grep vbmsdb /etc/hosts
   # Should show: 127.0.0.1       vbmsdb
   ```

2. **Check if Oracle XE is running**:
   ```bash
   # For Docker-based Oracle XE
   docker ps | grep oracle
   
   # Check if port 1521 is listening
   lsof -i :1521
   ```

3. **Test database connection**:
   ```bash
   # Using sqlplus (if installed)
   sqlplus vbms/vbms@vbmsdb:1521/XE
   
   # Or using telnet to test port
   telnet vbmsdb 1521
   ```

4. **Verify liquibase properties**:
   ```bash
   grep "url=" $VBMS_HOME/vbms-db-config/src/main/resources/local/liquibase*.properties
   # All should show: jdbc:oracle:thin:@vbmsdb:1521/XE
   ```

---

## Available Utility Functions

### From vbms-functions.sh:

```bash
# Clear WebLogic cache and temp files
clear-core-cache

# Clear WebLogic locks
clear-weblogic-locks

# Build VBMS Core (from vbms-functions.sh)
build-core

# Deploy WAR to autodeploy
deploy-core
```

### Aliases:

```bash
# Build VBMS Core
buildcore

# Same as buildcore
jamonit

# View this deployment guide
corecheck
```

---

## Verification Checklist

Before deployment:
- [ ] JAVA_HOME points to ARM64 Zulu 8
- [ ] MAVEN_OPTS includes -Xmx8000m
- [ ] vbmsDeveloper.properties has correct paths
- [ ] Hazelcast is disabled in properties
- [ ] WebLogic domain exists and is clean
- [ ] /etc/hosts has required VBMS entries

After build:
- [ ] Build completed successfully
- [ ] WAR file exists in target directory
- [ ] No compilation errors in logs

After WebLogic start:
- [ ] WebLogic process is running
- [ ] Port 7001 is listening
- [ ] Console accessible at http://localhost:7001/console
- [ ] Server state is RUNNING

After deployment:
- [ ] WAR appears in autodeploy directory
- [ ] Deployment shows as Active in console
- [ ] Application accessible at configured URL

---

## Quick Reference Commands

```bash
# Full deployment workflow
buildcore                    # Build VBMS Core
clear-core-cache            # Clear WebLogic cache
cd $ORACLE_HOME/user_projects/domains/P2-DEV
./bin/startWebLogic.sh      # Start WebLogic
# Wait for startup...
deploy-core                 # Deploy application

# Stop WebLogic
cd $ORACLE_HOME/user_projects/domains/P2-DEV
./bin/stopWebLogic.sh

# Emergency stop
pkill -9 -f weblogic.Server

# Check status
ps aux | grep weblogic.Server
lsof -i :7001

# View logs
tail -f $ORACLE_HOME/user_projects/domains/P2-DEV/servers/AdminServer/logs/AdminServer.log
```

---

## Important File Locations

```
# Configuration
~/.zshrc                                                                    # Shell environment
$VBMS_HOME/vbms-functions.sh                                               # Utility functions
$VBMS_HOME/vbms-install-weblogic/src/main/resources/vbmsDeveloper.properties

# WebLogic Domain
$DOMAINS_HOME/P2-DEV/                                                       # Domain root
$DOMAINS_HOME/P2-DEV/bin/startWebLogic.sh
$DOMAINS_HOME/P2-DEV/bin/stopWebLogic.sh
$DOMAINS_HOME/P2-DEV/autodeploy/

# Build Artifacts
$VBMS_HOME/vbms/vbms/target/vbms-*.war

# Logs
$DOMAINS_HOME/P2-DEV/servers/AdminServer/logs/AdminServer.log
$DOMAINS_HOME/P2-DEV/weblogic.out
```

---

## Contact & Support

For issues not covered here:
1. Check WebLogic logs in `servers/AdminServer/logs/`
2. Review Maven build output for errors
3. Verify all environment variables are set correctly
4. Ensure Java version matches ARM64 Zulu 8

---

## Working Configuration (Verified November 6, 2025)

🎉 **SUCCESS**: This configuration achieved **2 successful deployments** after resolving critical issues that blocked deployment for 2 days. Key breakthrough was identifying Hazelcast startup interference and ARM64 JDK configuration issues.

This deployment guide reflects a **fully tested and working configuration** on macOS ARM64:

### Verified Working Setup:
- ✅ **Java**: ARM64 Zulu JDK 8 (1.8.0_472) - `~/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home`
- ✅ **WebLogic**: 12.2.1.4.0 running on port 7001
- ✅ **Maven**: 3.9.9 with `MAVEN_OPTS="-Xms512m -Xmx8000m -Djavax.net.ssl.trustStore=$HOME/dev/cacerts"`
- ✅ **Hazelcast**: Disabled (manually commented out in `startWebLogic.sh`)
- ✅ **Browser Access**: WebLogic Console accessible at http://localhost:7001/console
  - **Note**: If console appears unresponsive, restart Chrome/browser (hard refresh may not work)
- ✅ **Oracle XE Database**: Configured via `/etc/hosts` entry for `vbmsdb`
- ✅ **JVM Memory**: `-Xms2000m -Xmx8000m` in domain configuration

### Key Success Factors:
1. **Hazelcast disabled** by commenting out lines 101-105 in `$DOMAINS_HOME/P2-DEV/bin/startWebLogic.sh`
2. **ARM64 JDK** used throughout (not x86 Rosetta version)
3. **Browser restart** required for WebLogic console access (Chrome cache issue)
4. **Environment variables** properly set in `~/.zshrc` and sourced
5. **Utility functions** in `vbms-functions.sh` for common tasks

### Startup Verification:
```bash
# Confirm no Hazelcast in startup log
tail -n 100 $DOMAINS_HOME/P2-DEV/weblogic.out | grep -i hazelcast
# Should return nothing

# Confirm ARM64 JDK in classpath
tail -n 100 $DOMAINS_HOME/P2-DEV/weblogic.out | grep "zulu-8-arm"
# Should show ARM64 JDK path

# Confirm server running
lsof -i :7001
# Should show java process listening
```

---

**Last Updated**: November 6, 2025  
**Environment**: macOS ARM64 (Apple Silicon)  
**WebLogic**: 12.2.1.4.0  
**Java**: Zulu 8 (ARM64)  
**Status**: ✅ Verified Working Configuration

**Note**: This guide uses environment variable notation (e.g., `$HOME`, `$VBMS_HOME`) for portability. Replace these with your actual paths when configuring files that don't support variable expansion.
