# End-to-End Deployment Flow

This document outlines the full lifecycle for deploying VBMS Core locally on macOS ARM64, using the steps encoded in Core Cracker and the deployment guide.

## Step 1: Verify Environment

Run basic checks:

```bash
java -version
echo $JAVA_HOME
mvn -version
echo $MAVEN_OPTS

vbms-health
```

- Confirm Java is Zulu JDK 8 ARM64.
- Confirm `JAVA_HOME`, `MAVEN_OPTS`, `ORACLE_HOME`, and `DOMAINS_HOME` are set.
- Use `vbms-health` and `vbms-verify` to catch common misconfigurations.

## Step 2: Build VBMS Core

Use one of the following approaches:

```bash
# Using convenience alias/function
buildcore          # or
cd $VBMS_HOME/vbms
build-core

# Manual Maven command
cd $VBMS_HOME/vbms
export MAVEN_OPTS="-Xms512m -Xmx8000m -Djavax.net.ssl.trustStore=$HOME/dev/cacerts"
mvn clean install -U -T5C -Dmaven.test.skip=true
```

- **Build time**: Approximately 10–20 minutes.
- **Success indicator**: `[INFO] BUILD SUCCESS`.

If you encounter `GC overhead limit exceeded`, check that:

- `MAVEN_OPTS` includes at least `-Xmx8000m`.
- You are using parallel builds (`-T5C`).

## Step 3: Rebuild WebLogic Domain (When Needed)

Rebuild the domain when:

- Setting up for the first time.
- You changed `vbmsDeveloper.properties` (especially `javaMemArgs` or paths).
- You updated Java or WebLogic configuration.

```bash
cd $VBMS_HOME/vbms-install-weblogic
export JAVA_HOME=$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH
mvn clean install -DskipTests
```

**Note**: Rebuilding deletes and recreates the domain; back up custom configuration first.

## Step 4: Clear WebLogic Cache (Recommended)

Use a helper if available:

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

This avoids stale artifacts and configuration between deployments.

## Step 5: Start WebLogic Server

```bash
cd $DOMAINS_HOME/P2-DEV
./bin/startWebLogic.sh

# Or run in background:
nohup ./bin/startWebLogic.sh > weblogic.out 2>&1 &
```

- **Startup time**: ~20–30 seconds for AdminServer.
- **Success indicator** in logs:
  - `<Notice> <WebLogicServer> <BEA-000360> <The server started in RUNNING mode.>`

Verification commands:

```bash
ps aux | grep weblogic.Server | grep -v grep
lsof -i :7001
tail -f $DOMAINS_HOME/P2-DEV/servers/AdminServer/logs/AdminServer.log
```

## Step 6: Verify Deployment

1. **WebLogic Console**
	- URL: `http://localhost:7001/console`
	- Log in with the credentials configured during domain creation.

2. **Deployment Status**
	- Navigate to *Deployments*.
	- Confirm VBMS applications (e.g., `vbms-*`) are in *Active* state.

3. **Access VBMS Application**
	- Typical URLs:
	  - `http://localhost:7001/vbms`
	  - `http://claims01.p2.vbms.va.gov:7001/vbmsp2` (if hosts mapping is configured).

If deployments hang in "deploy running" state, refer to the Hazelcast Disablement document to ensure the JVM flag and properties are correctly set and the domain has been rebuilt.

