#!/bin/zsh
# Script Name: quick-fix.sh
# Description: Auto-fix common VA Core environment issues
# Version: 1.0
# Based on: Verified deployment strategy from DEPLOYMENT-GUIDE.md

set -uo pipefail

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Constants - Based on verified working configuration
readonly ORACLE_JDK_ARM64="${HOME}/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"
readonly ORACLE_JDK_X86="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"
readonly MW_HOME_DEFAULT="${HOME}/dev/Oracle/Middleware/Oracle_Home"
readonly DOMAINS_HOME_DEFAULT="${HOME}/dev/Oracle/Middleware/user_projects/domains"

DRY_RUN=false
FIX_ALL=true
FIX_JAVA=false
FIX_WEBLOGIC=false
FIX_PATHS=false
FIX_PERMISSIONS=false

function usage() {
    cat << EOF
${BLUE}Quick Fix - Auto-fix common environment issues${NC}

${CYAN}USAGE:${NC}
    $0 [OPTIONS]

${CYAN}OPTIONS:${NC}
    -h, --help          Show this help message
    --dry-run           Show what would be fixed without making changes
    --all               Fix all issues (default)
    --java-home         Fix JAVA_HOME configuration
    --weblogic          Fix WebLogic environment variables
    --paths             Fix PATH configuration
    --permissions       Fix script permissions

${CYAN}EXAMPLES:${NC}
    # Fix all issues
    $0

    # Dry run (preview fixes)
    $0 --dry-run

    # Fix specific issue
    $0 --java-home
    $0 --weblogic

${CYAN}FIXES APPLIED:${NC}
    ${GREEN}✅${NC} JAVA_HOME configuration (ARM64 Zulu 8 on Apple Silicon)
    ${GREEN}✅${NC} WebLogic environment variables (MW_HOME, WLS_HOME)
    ${GREEN}✅${NC} PATH order (JAVA_HOME/bin first)
    ${GREEN}✅${NC} Script permissions (chmod +x)
    ${GREEN}✅${NC} .wljava_env file creation/update
    ${GREEN}✅${NC} Missing directory creation

${CYAN}BASED ON:${NC}
    Verified working deployment strategy (November 2025)
    - ARM64 Zulu JDK 8 on Apple Silicon
    - Intel Oracle JDK 1.8.0_202 on Intel Macs
    - WebLogic 12.2.1.4.0
    - MAVEN_OPTS with -Xmx8000m

EOF
    exit 0
}

function print_header() {
    echo ""
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${BLUE}🔧 Quick Fix - Environment Auto-Repair${NC}"
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [ "$DRY_RUN" = true ]; then
        echo "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
        echo ""
    fi
}

function print_footer() {
    echo ""
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${GREEN}✅ Quick Fix Complete${NC}"
    echo ""
    echo "${CYAN}Next steps:${NC}"
    echo "  1. Reload shell: ${YELLOW}source ~/.zshrc${NC}"
    echo "  2. Verify: ${YELLOW}./setup.sh --auto${NC}"
    echo "  3. Check health: ${YELLOW}./scripts/utils/health-check.sh${NC}"
    echo ""
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

function fix_java_home() {
    echo "${CYAN}Fixing JAVA_HOME Configuration${NC}"
    echo "─────────────────────────────────────────"
    
    # Detect architecture
    local cpu_arch=$(uname -m)
    local correct_java_home
    
    if [ "$cpu_arch" = "arm64" ]; then
        echo "  Detected: ${GREEN}Apple Silicon (ARM64)${NC}"
        correct_java_home="$ORACLE_JDK_ARM64"
        
        if [ ! -d "$correct_java_home" ]; then
            echo "  ${RED}❌ ARM64 Zulu JDK 8 not found${NC}"
            echo "  ${YELLOW}⚠️  Install from: https://www.azul.com/downloads/?version=java-8-lts&os=macos&architecture=arm-64-bit&package=jdk${NC}"
            return 1
        fi
    else
        echo "  Detected: ${GREEN}Intel (x86_64)${NC}"
        correct_java_home="$ORACLE_JDK_X86"
        
        if [ ! -d "$correct_java_home" ]; then
            echo "  ${RED}❌ Oracle JDK 1.8.0_202 not found${NC}"
            echo "  ${YELLOW}⚠️  Install from Oracle Java Archive${NC}"
            return 1
        fi
    fi
    
    # Check current JAVA_HOME
    if [ "${JAVA_HOME:-}" = "$correct_java_home" ]; then
        echo "  ${GREEN}✅ JAVA_HOME already correct${NC}"
        return 0
    fi
    
    # Update ~/.zshrc
    local zshrc="${HOME}/.zshrc"
    
    if [ "$DRY_RUN" = true ]; then
        echo "  ${YELLOW}Would set:${NC} JAVA_HOME=$correct_java_home"
        echo "  ${YELLOW}Would update:${NC} ~/.zshrc"
        return 0
    fi
    
    # Backup ~/.zshrc
    cp "$zshrc" "${zshrc}.backup-$(date +%Y%m%d-%H%M%S)"
    
    # Remove old JAVA_HOME exports
    sed -i '' '/^export JAVA_HOME=/d' "$zshrc"
    
    # Add correct JAVA_HOME
    cat >> "$zshrc" << EOF

# Java Home - ${cpu_arch} (auto-fixed $(date +%Y-%m-%d))
export JAVA_HOME="$correct_java_home"
export PATH="\$JAVA_HOME/bin:\$PATH"
EOF
    
    echo "  ${GREEN}✅ Updated JAVA_HOME in ~/.zshrc${NC}"
    echo "  ${CYAN}Set to:${NC} $correct_java_home"
    
    # Update current session
    export JAVA_HOME="$correct_java_home"
    export PATH="$JAVA_HOME/bin:$PATH"
    
    echo ""
}

function fix_weblogic_env() {
    echo "${CYAN}Fixing WebLogic Environment${NC}"
    echo "─────────────────────────────────────────"
    
    local zshrc="${HOME}/.zshrc"
    local wljava_env="${HOME}/.wljava_env"
    
    # Check MW_HOME
    if [ ! -d "$MW_HOME_DEFAULT" ]; then
        echo "  ${YELLOW}⚠️  WebLogic not found at: $MW_HOME_DEFAULT${NC}"
        echo "  ${YELLOW}⚠️  Install WebLogic or update MW_HOME manually${NC}"
        return 1
    fi
    
    # Update ~/.zshrc
    if [ "$DRY_RUN" = true ]; then
        echo "  ${YELLOW}Would set:${NC} MW_HOME=$MW_HOME_DEFAULT"
        echo "  ${YELLOW}Would set:${NC} WLS_HOME=\$MW_HOME/wlserver"
        echo "  ${YELLOW}Would set:${NC} DOMAINS_HOME=$DOMAINS_HOME_DEFAULT"
        echo "  ${YELLOW}Would create/update:${NC} ~/.wljava_env"
        return 0
    fi
    
    # Backup
    [ -f "$zshrc" ] && cp "$zshrc" "${zshrc}.backup-$(date +%Y%m%d-%H%M%S)"
    
    # Remove old WebLogic exports
    sed -i '' '/^export MW_HOME=/d' "$zshrc"
    sed -i '' '/^export WLS_HOME=/d' "$zshrc"
    sed -i '' '/^export ORACLE_HOME=/d' "$zshrc"
    sed -i '' '/^export DOMAINS_HOME=/d' "$zshrc"
    
    # Add WebLogic environment
    cat >> "$zshrc" << EOF

# WebLogic Environment (auto-fixed $(date +%Y-%m-%d))
export ORACLE_HOME="$MW_HOME_DEFAULT"
export MW_HOME="$MW_HOME_DEFAULT"
export WLS_HOME="\$MW_HOME/wlserver"
export DOMAINS_HOME="$DOMAINS_HOME_DEFAULT"
EOF
    
    echo "  ${GREEN}✅ Updated WebLogic variables in ~/.zshrc${NC}"
    
    # Create/update .wljava_env
    cat > "$wljava_env" << EOF
# WebLogic Java Environment
# Auto-generated by quick-fix.sh on $(date +%Y-%m-%d)
export JAVA_HOME="$JAVA_HOME"
EOF
    
    echo "  ${GREEN}✅ Created ~/.wljava_env${NC}"
    echo ""
}

function fix_maven_opts() {
    echo "${CYAN}Fixing Maven Configuration${NC}"
    echo "─────────────────────────────────────────"
    
    local zshrc="${HOME}/.zshrc"
    local cacerts="${HOME}/dev/cacerts"
    
    # Check if cacerts exists
    if [ ! -f "$cacerts" ]; then
        echo "  ${YELLOW}⚠️  Warning: $cacerts not found${NC}"
        echo "  ${YELLOW}⚠️  MAVEN_OPTS will be set but SSL trust may not work${NC}"
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "  ${YELLOW}Would set:${NC} MAVEN_OPTS=\"-Xms512m -Xmx8000m -Djavax.net.ssl.trustStore=\$HOME/dev/cacerts\""
        return 0
    fi
    
    # Backup
    [ -f "$zshrc" ] && cp "$zshrc" "${zshrc}.backup-$(date +%Y%m%d-%H%M%S)" 2>/dev/null
    
    # Remove old MAVEN_OPTS
    sed -i '' '/^export MAVEN_OPTS=/d' "$zshrc"
    
    # Add MAVEN_OPTS (based on verified deployment strategy)
    cat >> "$zshrc" << EOF

# Maven Options (auto-fixed $(date +%Y-%m-%d))
# Critical: Prevents GC overhead errors during VBMS build
export MAVEN_OPTS="-Xms512m -Xmx8000m -Djavax.net.ssl.trustStore=\$HOME/dev/cacerts"
EOF
    
    echo "  ${GREEN}✅ Updated MAVEN_OPTS in ~/.zshrc${NC}"
    echo "  ${CYAN}Set to:${NC} -Xms512m -Xmx8000m"
    echo ""
}

function fix_paths() {
    echo "${CYAN}Fixing PATH Configuration${NC}"
    echo "─────────────────────────────────────────"
    
    # Check if JAVA_HOME/bin is first in PATH
    if [[ ":${PATH}:" == ":${JAVA_HOME}/bin:"* ]]; then
        echo "  ${GREEN}✅ PATH already correct (JAVA_HOME/bin is first)${NC}"
        return 0
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "  ${YELLOW}Would reorder PATH to put JAVA_HOME/bin first${NC}"
        return 0
    fi
    
    # This is handled in fix_java_home
    echo "  ${CYAN}ℹ️  PATH will be fixed with JAVA_HOME update${NC}"
    echo ""
}

function fix_permissions() {
    echo "${CYAN}Fixing Script Permissions${NC}"
    echo "─────────────────────────────────────────"
    
    local script_dir=$(cd "$(dirname "$0")/../.." && pwd)
    
    if [ "$DRY_RUN" = true ]; then
        echo "  ${YELLOW}Would make all .sh files executable${NC}"
        return 0
    fi
    
    # Make all scripts executable
    find "$script_dir" -name "*.sh" -type f -exec chmod +x {} \;
    
    echo "  ${GREEN}✅ Made all .sh files executable${NC}"
    echo ""
}

function create_directories() {
    echo "${CYAN}Creating Missing Directories${NC}"
    echo "─────────────────────────────────────────"
    
    local dirs=(
        "${HOME}/dev"
        "${HOME}/dev/standardized-scripts"
        "${HOME}/.env-backups"
        "${HOME}/.core-cracker/logs"
    )
    
    local created=0
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            if [ "$DRY_RUN" = true ]; then
                echo "  ${YELLOW}Would create:${NC} $dir"
                ((created++))
            else
                mkdir -p "$dir"
                echo "  ${GREEN}✅ Created:${NC} $dir"
                ((created++))
            fi
        fi
    done
    
    if [ $created -eq 0 ]; then
        echo "  ${GREEN}✅ All directories exist${NC}"
    fi
    
    echo ""
}

function main() {
    print_header
    
    if [ "$FIX_ALL" = true ] || [ "$FIX_JAVA" = true ]; then
        fix_java_home
        fix_maven_opts
    fi
    
    if [ "$FIX_ALL" = true ] || [ "$FIX_WEBLOGIC" = true ]; then
        fix_weblogic_env
    fi
    
    if [ "$FIX_ALL" = true ] || [ "$FIX_PATHS" = true ]; then
        fix_paths
    fi
    
    if [ "$FIX_ALL" = true ] || [ "$FIX_PERMISSIONS" = true ]; then
        fix_permissions
    fi
    
    if [ "$FIX_ALL" = true ]; then
        create_directories
    fi
    
    print_footer
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --all)
            FIX_ALL=true
            shift
            ;;
        --java-home)
            FIX_ALL=false
            FIX_JAVA=true
            shift
            ;;
        --weblogic)
            FIX_ALL=false
            FIX_WEBLOGIC=true
            shift
            ;;
        --paths)
            FIX_ALL=false
            FIX_PATHS=true
            shift
            ;;
        --permissions)
            FIX_ALL=false
            FIX_PERMISSIONS=true
            shift
            ;;
        *)
            echo "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Run main
main
