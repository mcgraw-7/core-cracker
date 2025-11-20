# Hazelcast Disablement (Deployment Blocker)

Hazelcast is the single biggest cause of local VBMS Core deployment hangs. This document describes how to fully disable it using configuration derived from the deployment guide and Core Cracker.

## Symptoms

- WebLogic deployment stays in **"deploy running"** state for 5–60 minutes.
- AdminServer log shows application startup stuck around Hazelcast client initialization.
- Eventually the deployment times out without ever reaching RUNNING state.

## Root Cause

- Spring attempts to create Hazelcast client beans during application startup.
- In local environments without a Hazelcast cluster, those clients wait indefinitely for a connection.
- This hang prevents the application from finishing startup, blocking deployment.

## Critical JVM Flag (Must-Have)

The primary fix is a JVM system property in `javaMemArgs` inside `vbmsDeveloper.properties`:

```properties
-Dvbms.cache.hazelcast.enabled=false
```

Effects:

- Prevents Spring from instantiating Hazelcast client beans at all.
- Eliminates the startup wait on a non-existent cluster.

This flag is the **#1 required change** for stable deployments.

## Supporting Properties

In addition to the JVM flag, there are properties that control Hazelcast server scripts:

```properties
hazelcastStartLinux=
hazelcastStopLinux=
```

- Setting these to empty strings ensures Hazelcast server processes are not started locally.
- However, **these alone are not enough** — without the JVM flag, Spring may still try to create clients and hang.

## Full Disablement Recipe

1. **Update `vbmsDeveloper.properties`**:

	 - Ensure `javaMemArgs` includes:

	 ```properties
	 -Dvbms.cache.hazelcast.enabled=false
	 ```

	 - Ensure Hazelcast start/stop properties are blank:

	 ```properties
	 hazelcastStartLinux=
	 hazelcastStopLinux=
	 ```

2. **Rebuild the WebLogic domain** so the new arguments are baked in:

	 ```bash
	 cd $VBMS_HOME/vbms-install-weblogic
	 mvn clean install -DskipTests
	 ```

3. **Restart WebLogic**:

	 ```bash
	 cd $DOMAINS_HOME/P2-DEV
	 ./bin/startWebLogic.sh
	 ```

## Verification from Startup Logs

During WebLogic startup, look for the "JAVA Memory arguments" line:

```bash
cd $DOMAINS_HOME/P2-DEV
./bin/startWebLogic.sh | grep "JAVA Memory arguments"
```

You should see `-Dvbms.cache.hazelcast.enabled=false` included among the JVM flags.

If the flag is missing:

- Confirm you edited the correct `vbmsDeveloper.properties`.
- Re-run the `mvn clean install -DskipTests` in `vbms-install-weblogic`.

## Using Core Cracker to Guard Against Regressions

- **Backup before upticks**:

	```bash
	vbms-backup-props
	```

- **List backups**:

	```bash
	vbms-backup-props --list
	```

- **Verify Hazelcast flag in a backup**:

	```bash
	vbms-backup-props --verify vbmsDeveloper.properties.YYYYMMDD-HHMMSS
	```

- **Diff current vs backup**:

	```bash
	vbms-backup-props --diff vbmsDeveloper.properties.YYYYMMDD-HHMMSS
	```

Because version upticks sometimes reset `vbmsDeveloper.properties`, Core Cracker’s backup tooling protects the Hazelcast configuration from being accidentally removed.

