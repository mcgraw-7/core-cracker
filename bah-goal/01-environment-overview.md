# VBMS Core Local Environment Overview (macOS ARM64)

This document describes the local VBMS Core development environment as validated by Core Cracker on macOS ARM64 (Apple Silicon).

## Purpose of Core Cracker

- Provide a **single, automated source of truth** for validating and fixing a VBMS Core local environment.
- Encode the requirements from the official VBMS Core Installation Guide and the local `DEPLOYMENT-GUIDE.md` into repeatable checks and scripts.
- Make it easy to spin up, repair, and verify a working WebLogic + VBMS Core stack on Apple Silicon.

## High-Level Architecture

- **VBMS Core Application**
	- Built from the `vbms-core` repository.
	- Deployed as EAR/WAR artifacts to a local WebLogic 12.2.1.4.0 domain.

- **WebLogic Application Server**
	- Installed under `~/dev/Oracle/Middleware/Oracle_Home`.
	- Domain home at `$ORACLE_HOME/user_projects/domains/P2-DEV`.
	- Runs the VBMS applications and exposes HTTP endpoints (e.g., `http://localhost:7001/vbms`).

- **Oracle DB / Supporting Services**
	- Typically run via Docker/Colima on macOS ARM64.
	- Reached via hostnames like `vbmsdb` mapped in `/etc/hosts`.

- **Developer Tooling**
	- **Java**: Zulu JDK 8 (ARM64) is the required JVM.
	- **Maven**: 3.9.9+ used for building VBMS Core modules and installer.
	- **Docker/Colima**: Provides containerized infrastructure (database, etc.).

## Supported Platform

- **Operating System**: macOS on Apple Silicon (ARM64).
- **Java**: Zulu JDK 8 ARM64 at:
	- `~/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home`
- **WebLogic**: 12.2.1.4.0 installed at:
	- `~/dev/Oracle/Middleware/Oracle_Home`
- **Maven**: 3.9.9+ (e.g., from Homebrew under `/opt/homebrew/Cellar/maven/...`).
- **Containers**: Docker and Colima installed and running.

## Key Moving Parts

- **Java Configuration**
	- `JAVA_HOME` must point to the ARM64 Zulu JDK 8.
	- `PATH` must include `$JAVA_HOME/bin` first to avoid Intel/legacy JDKs.

- **Maven Configuration**
	- `MAVEN_OPTS` should include memory and trust store settings, for example:
		- `-Xms512m -Xmx8000m -Djavax.net.ssl.trustStore=$HOME/dev/cacerts`

- **WebLogic Configuration**
	- `ORACLE_HOME` and `DOMAINS_HOME` must be set correctly.
	- `vbmsDeveloper.properties` drives domain build configuration.

- **Networking and Hosts**
	- `/etc/hosts` must map core hostnames to `127.0.0.1`, including:
		- `claims01.p2.vbms.va.gov`
		- `vbmsdb`
		- `nexus.dev.bip.va.gov`

- **Core Cracker Integration**
	- Sourcing `aliases.sh` adds `vbms-*` commands for health checks, fixes, backups, and diagnostics.
	- These commands are designed to validate that all of the above components align with the deployment guide.

