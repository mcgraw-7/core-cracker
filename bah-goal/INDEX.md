# VBMS Core / Core Cracker Onboarding Index

This folder provides a structured, Core-Cracker-backed walkthrough for setting up and running VBMS Core locally on macOS ARM64.

1. **Environment Overview**  
   See `01-environment-overview.md` for a high-level picture of the VBMS Core local stack and supported platform.

2. **Prerequisites and Environment Variables**  
   See `02-prerequisites-and-env-vars.md` for required software, `/etc/hosts` entries, and `~/.zshrc` configuration.

3. **`vbmsDeveloper.properties` Configuration**  
   See `03-vbms-developer-properties.md` for details on the WebLogic domain configuration file and when to rebuild the domain.

4. **Hazelcast Disablement (Deployment Blocker)**  
   See `04-hazelcast-disablement.md` for the critical JVM flag and properties needed to prevent deployment hangs.

5. **Core Cracker Tooling Overview**  
   See `05-core-cracker-tooling.md` for installation steps and a reference for all `vbms-*` helper commands.

6. **End-to-End Deployment Flow**  
   See `06-deployment-flow.md` for the complete step-by-step process: verify, build, rebuild domain, start WebLogic, and validate deployment.
