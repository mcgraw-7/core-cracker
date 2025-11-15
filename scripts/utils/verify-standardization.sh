#!/bin/zsh
# VA Core Environment Standardization Verification

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check Oracle JDK installation
ORACLE_JDK="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"
echo -n "Checking Oracle JDK installation: "
if [ -d "$ORACLE_JDK" ]; then
    echo "${GREEN} FOUND${NC}"
    echo "  Path: $ORACLE_JDK"
else
    echo "${RED} NOT FOUND${NC}"
    exit 1
fi

# Check WebLogic Java environment file
WLJAVA_ENV="$HOME/.wljava_env"
echo -n "Checking WebLogic Java environment file: "
if [ -f "$WLJAVA_ENV" ]; then
    echo "${GREEN} FOUND${NC}"
    echo "  Path: $WLJAVA_ENV"
else
    echo "${RED} NOT FOUND${NC}"
fi

# Check standardized scripts directory
STANDARDIZED_SCRIPTS="$HOME/dev/standardized-scripts"
echo -n "Checking standardized scripts directory: "
if [ -d "$STANDARDIZED_SCRIPTS" ]; then
    echo "${GREEN} FOUND${NC}"
    echo "  Path: $STANDARDIZED_SCRIPTS"
    SCRIPT_COUNT=$(find "$STANDARDIZED_SCRIPTS" -name "*.sh" | wc -l)
    echo "  Contains $SCRIPT_COUNT scripts"
else
    echo "${RED} NOT FOUND${NC}"
fi

echo ""

# Current Java Environment
echo "Current Java Environment:"
echo "JAVA_HOME: $JAVA_HOME ${GREEN}${NC}"
echo "Java version: $(java -version 2>&1 | head -n 1) ${GREEN}${NC}"

# Validate critical scripts
echo ""
echo "Validation of critical scripts:"
CORE_CONFIG_SCRIPT="$STANDARDIZED_SCRIPTS/core-config-status.sh"
if [ -f "$CORE_CONFIG_SCRIPT" ]; then
    if grep -q "jdk1.8.0_202" "$CORE_CONFIG_SCRIPT" 2>/dev/null; then
        echo "core-config-status.sh: Using correct JDK path ${GREEN}${NC}"
    else
        echo "core-config-status.sh: May need JDK path update ${YELLOW}${NC}"
    fi
else
    echo "core-config-status.sh: Not found ${RED}${NC}"
fi
