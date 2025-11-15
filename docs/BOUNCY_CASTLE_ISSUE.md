# Bouncy Castle Dependency Issue in VBMS Core

## Problem Summary

When building and deploying the VBMS Core multi-module Maven project (targeting WebLogic 12.1.3), the following issues were encountered:

- **Class loading errors and NullPointerExceptions** at runtime, traced to Bouncy Castle JARs.
- **Maven build failures** due to missing or misconfigured Bouncy Castle dependencies, specifically `bctsp-jdk15on`.

## Root Cause

- **Bouncy Castle 1.67+** introduced multi-release JARs, which are not compatible with WebLogic 12.1.3. This caused class loading issues and runtime exceptions.
- The project referenced `bctsp-jdk15on`, which does not exist in Bouncy Castle 1.60 or any 1.x version, leading to Maven errors about missing dependency versions.

## Solution

1. **Force all Bouncy Castle dependencies to version 1.60** in the root POM:
   - `bcprov-jdk15on`
   - `bcpkix-jdk15on`
   - `bcmail-jdk15on`
2. **Remove all references to `bctsp-jdk15on`** from every module POM, as it does not exist in 1.60.
3. **Verify** that no submodule POMs reference `bctsp-jdk15on` and that all Bouncy Castle dependencies use version 1.60.

## Steps Taken

- Updated the root POM to manage Bouncy Castle versions at 1.60.
- Removed `bctsp-jdk15on` from the root and all submodule POMs.
- Searched and confirmed no remaining references to `bctsp-jdk15on`.
- Rebuilt the project to ensure all modules use only supported Bouncy Castle artifacts.

## References
- [Bouncy Castle Release Notes](https://www.bouncycastle.org/releasenotes.html)
- [WebLogic 12.1.3 Documentation](https://docs.oracle.com/middleware/1213/wls/index.html)

## Recommendation
- Always use Bouncy Castle 1.60 for WebLogic 12.1.3 deployments.
- Avoid multi-release JARs and non-existent artifacts in dependency management.
- If upgrading WebLogic, re-evaluate Bouncy Castle compatibility.
