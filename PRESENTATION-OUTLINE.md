# Core Cracker - Presentation Outline

## 1. The Problem (30 seconds)
- Setting up VBMS Core locally on ARM64 Macs is complex and error-prone
- Developers spend hours troubleshooting environment issues
- Common mistakes: wrong JDK, missing environment variables, incorrect paths
- Documentation scattered across wiki, deployment guides, and tribal knowledge

## 2. The Solution (30 seconds)
- **Core Cracker**: Automated validation and fix toolkit
- Validates your entire development environment in seconds
- Auto-fixes common configuration issues
- Based on verified deployment strategy from official guides

## 3. Key Features (1-2 minutes)

### Health Checks
- Java environment (ARM64 Zulu JDK 8)
- WebLogic installation and configuration
- Maven settings (critical GC overhead prevention)
- Docker/Colima for Oracle DB
- VPN tunnel status
- System resources

### Auto-Fix Capabilities
- Detects what's already configured vs. what's missing
- Adds missing environment variables to ~/.zshrc
- Creates `.wljava_env` file (tells WebLogic which Java to use)
- Sets correct PATH order
- Preview changes with dry-run mode

### Developer Experience
- Global aliases: `vbms-health`, `vbms-fix`, `vbms-verify`
- Color-coded output (green/yellow/red)
- Specific recommendations for each issue
- Backup/restore configuration

## 4. How It Works (1 minute)

### Installation
```bash
git clone https://github.com/mcgraw-7/core-cracker.git ~/dev/core-cracker
source ~/dev/core-cracker/aliases.sh
```

### Usage
```bash
vbms-health    # Full diagnostic check
vbms-fix-dry   # Preview fixes
vbms-fix       # Apply fixes
```

### What It Validates
Based on official VBMS Core Installation Guide:
- Java Home → Zulu JDK 8 ARM64
- Maven Opts → -Xmx8000m (prevents GC errors)
- Oracle/WebLogic paths
- Required tools (Docker, Colima, git)
- VPN tunnel connection

## 5. Real-World Impact (30 seconds)
- Reduces setup time from hours to minutes
- Catches configuration issues before they cause build failures
- New developers can validate their setup independently
- Consistent environment across all ARM64 development machines

## 6. Technical Details (if asked)

### Architecture
- Pure shell scripts (zsh)
- No external dependencies
- Modular design (health-check, quick-fix, backup/restore)
- Smart detection (only shows what needs fixing)

### Source of Truth
- Derives all checks from official deployment documentation
- Maps directly to VBMS Core Installation Guide requirements
- Updated when deployment guide changes

### Files & Structure
```
core-cracker/
  aliases.sh              # Global vbms-* commands
  setup.sh                # Interactive validation
  scripts/utils/
    health-check.sh       # Comprehensive diagnostics
    quick-fix.sh          # Auto-fix issues
    verify-standardization.sh  # Quick check
    env-backup.sh         # Backup/restore
```

## 7. Demo Flow (if showing live)

1. **Show Problem**: `vbms-health` on misconfigured system
   - Red errors for missing config
   - Yellow warnings with specific issues
   - Recommendations listed

2. **Preview Fix**: `vbms-fix-dry`
   - Shows exactly what would change
   - Color-coded (green = already set, yellow = will add)

3. **Apply Fix**: `vbms-fix`
   - Applies all fixes
   - Backs up existing config
   - Confirms success

4. **Verify**: `vbms-health` again
   - All green checks
   - System ready for development

## 8. Key Takeaways (30 seconds)
- Automates tedious environment setup
- Prevents common configuration mistakes
- Saves developer time and frustration
- Maintains single source of truth (deployment guide)
- Open source and extensible

## 9. Next Steps / Q&A
- Repository: https://github.com/mcgraw-7/core-cracker
- Based on: VBMS Core Installation Guide
- Contributions welcome
- Questions?

---

## Quick Stats to Mention
- **21 automated checks** across 6 categories
- **6 auto-fix capabilities** for common issues
- **10+ vbms-* commands** via global aliases
- **ARM64 native** for Apple Silicon
- **Zero dependencies** beyond standard shell tools

## Elevator Pitch (15 seconds)
"Core Cracker validates and fixes your VBMS Core development environment on ARM64 Macs. It automates the tedious setup steps from the deployment guide, catching configuration issues before they cause build failures. Run `vbms-health` to check everything, `vbms-fix` to auto-correct issues."
