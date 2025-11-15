#!/bin/zsh
# Global Aliases for VA Core Local Development Scripts
# Source this file in your ~/.zshrc: source ~/dev/core-cracker/aliases.sh

# Color output
alias_success='\033[0;32m'
alias_nc='\033[0m'

# Base directory
LOCAL_ARM_MAC_DIR="${HOME}/dev/core-cracker"

# Quick access aliases
alias vbms-setup="${LOCAL_ARM_MAC_DIR}/setup.sh"
alias vbms-auto="${LOCAL_ARM_MAC_DIR}/setup.sh --auto"

# Health and diagnostics
alias vbms-health="${LOCAL_ARM_MAC_DIR}/scripts/utils/health-check.sh"
alias vbms-check="${LOCAL_ARM_MAC_DIR}/scripts/utils/health-check.sh"

# Java utilities
alias vbms-java="${LOCAL_ARM_MAC_DIR}/scripts/utils/java-check.sh"
alias vbms-java-versions="${LOCAL_ARM_MAC_DIR}/scripts/utils/java-versions.sh"
alias vbms-java-test="${LOCAL_ARM_MAC_DIR}/scripts/utils/test-java-switching.sh"

# WebLogic utilities
alias vbms-wl="${LOCAL_ARM_MAC_DIR}/scripts/utils/check-weblogic.sh"
alias vbms-wl-status="${LOCAL_ARM_MAC_DIR}/scripts/weblogic/check-weblogic-status.sh"

# Path and configuration analysis
alias vbms-paths="${LOCAL_ARM_MAC_DIR}/scripts/utils/analyze-paths-config-tool.sh"
alias vbms-config="${LOCAL_ARM_MAC_DIR}/scripts/utils/show-complete-configuration.sh"
alias vbms-compare="${LOCAL_ARM_MAC_DIR}/scripts/utils/compare-configuration.sh"

# Verification and standardization
alias vbms-verify="${LOCAL_ARM_MAC_DIR}/scripts/utils/verify-standardization.sh"
alias vbms-verify-oracle="${LOCAL_ARM_MAC_DIR}/scripts/utils/verify-oracle-directory.sh"

# Apple Silicon specific
alias vbms-arm="${LOCAL_ARM_MAC_DIR}/scripts/utils/check-apple-silicon.sh"
alias vbms-mac="${LOCAL_ARM_MAC_DIR}/scripts/utils/check-apple-silicon.sh"

# Backup and restore
alias vbms-backup="${LOCAL_ARM_MAC_DIR}/scripts/utils/env-backup.sh"
alias vbms-restore="${LOCAL_ARM_MAC_DIR}/scripts/utils/env-backup.sh --restore"
alias vbms-backups="${LOCAL_ARM_MAC_DIR}/scripts/utils/env-backup.sh --list"

# Quick fix utilities
alias vbms-fix="${LOCAL_ARM_MAC_DIR}/scripts/utils/quick-fix.sh"
alias vbms-fix-java="${LOCAL_ARM_MAC_DIR}/scripts/utils/quick-fix.sh --java-home"
alias vbms-fix-wl="${LOCAL_ARM_MAC_DIR}/scripts/utils/quick-fix.sh --weblogic"
alias vbms-fix-dry="${LOCAL_ARM_MAC_DIR}/scripts/utils/quick-fix.sh --dry-run"

# Navigation
alias vbms-cd="cd ${LOCAL_ARM_MAC_DIR}"
alias vbms-scripts="cd ${LOCAL_ARM_MAC_DIR}/scripts/utils"
alias vbms-docs="cd ${LOCAL_ARM_MAC_DIR}/docs"

# Help function
vbms-help() {
    echo "VA Core Local Development Aliases"
    echo ""
    echo "SETUP & DIAGNOSTICS:"
    echo "  vbms-setup          - Run interactive setup"
    echo "  vbms-auto           - Run all checks automatically"
    echo "  vbms-health         - System health check"
    echo "  vbms-check          - Alias for health check"
    echo ""
    echo "JAVA:"
    echo "  vbms-java           - Check Java installation"
    echo "  vbms-java-versions  - List all Java versions"
    echo "  vbms-java-test      - Test Java switching"
    echo ""
    echo "WEBLOGIC:"
    echo "  vbms-wl             - Check WebLogic environment"
    echo "  vbms-wl-status      - Check WebLogic server status"
    echo ""
    echo "CONFIGURATION:"
    echo "  vbms-paths          - Analyze PATH and JAVA_HOME"
    echo "  vbms-config         - Show complete configuration"
    echo "  vbms-compare        - Compare configurations"
    echo "  vbms-verify         - Verify standardization"
    echo "  vbms-verify-oracle  - Verify Oracle directory"
    echo ""
    echo "APPLE SILICON:"
    echo "  vbms-arm            - Check Apple Silicon compatibility"
    echo "  vbms-mac            - Alias for Apple Silicon check"
    echo ""
    echo "BACKUP & RESTORE:"
    echo "  vbms-backup         - Create environment backup"
    echo "  vbms-restore        - Restore from backup"
    echo "  vbms-backups        - List available backups"
    echo ""
    echo "QUICK FIX:"
    echo "  vbms-fix            - Auto-fix all issues"
    echo "  vbms-fix-java       - Fix JAVA_HOME only"
    echo "  vbms-fix-wl         - Fix WebLogic only"
    echo "  vbms-fix-dry        - Dry run (show what would be fixed)"
    echo ""
    echo "NAVIGATION:"
    echo "  vbms-cd             - Go to core-cracker directory"
    echo "  vbms-scripts        - Go to scripts/utils directory"
    echo "  vbms-docs           - Go to docs directory"
    echo ""
    echo "HELP:"
    echo "  vbms-help           - Show this help message"
}

# Print success message when sourced
echo "${alias_success}✓${alias_nc} VA Core development aliases loaded. Type 'vbms-help' for available commands."
