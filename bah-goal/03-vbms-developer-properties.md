# `vbmsDeveloper.properties` Configuration

The `vbmsDeveloper.properties` file is the central configuration for building and configuring the local WebLogic domain that runs VBMS Core.

## Location and Role

- **Location in repo**:
	- `$VBMS_HOME/vbms-install-weblogic/src/main/resources/vbmsDeveloper.properties`
- **Purpose**:
	- Controls how the P2-DEV domain is created and configured.
	- Sets JVM, proxy, and middleware paths used during domain provisioning.

## Core Settings

Example key properties (adapt `<your-username>`):

```properties
javaSDKHome=/Users/<your-username>/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home

domainName=P2-DEV
clustering=false

middlewareHome=/Users/<your-username>/dev/Oracle/Middleware/Oracle_Home
domainsHome=/Users/<your-username>/dev/Oracle/Middleware/Oracle_Home/user_projects/domains
```

- `javaSDKHome`: Must point to the ARM64 Zulu JDK 8 installation.
- `domainName`: Typically `P2-DEV` for local development.
- `clustering`: `false` for a single-node dev setup.
- `middlewareHome` / `domainsHome`: Must match your local WebLogic install paths.

## Proxy Configuration

Typical proxy-related properties:

```properties
proxyHost=127.0.0.1
proxyPort=9443
proxyUser=<your-username>
proxyPassword=<your-password>
```

These values are interpolated into `javaMemArgs` and other locations to ensure outbound HTTP/HTTPS traffic flows correctly through your dev proxy (if required by your environment).

## JVM Memory and System Properties (`javaMemArgs`)

The `javaMemArgs` property sets the JVM options used by WebLogic, including memory sizing and critical system properties.

Example:

```properties
javaMemArgs=-Xms2000m -Xmx8000m -d64 -XX:CompileThreshold=8000 \
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

Important aspects:

- Memory sizing (`-Xms2000m -Xmx8000m`) ensures stable runtime and reduces GC overhead.
- Proxy flags tie back to the `proxyHost`/`proxyPort` properties above.
- `-Dvbms.cache.hazelcast.enabled=false` is the **critical Hazelcast disable flag** that prevents deployment hangs.

## Production Mode and Related Toggles

```properties
productionMode=false
```

- `productionMode=false` keeps WebLogic in development mode for your local environment.

Hazelcast-related toggles (expanded in the Hazelcast document):

```properties
hazelcastStartLinux=
hazelcastStopLinux=
```

- Leaving these blank prevents Hazelcast server scripts from running, complementing the JVM flag in `javaMemArgs`.

## When to Rebuild the Domain

Any time you change significant properties in `vbmsDeveloper.properties`, especially:

- `javaSDKHome`
- `middlewareHome` / `domainsHome`
- `javaMemArgs` (including Hazelcast flag changes)

You should **rebuild the domain** so the new configuration is applied:

```bash
cd $VBMS_HOME/vbms-install-weblogic
mvn clean install -DskipTests
```

Core Cracker’s `vbms-backup-props` command is designed to snapshot this file before and after such changes, and across repo upticks.

