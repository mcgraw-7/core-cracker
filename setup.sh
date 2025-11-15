#!/bin/zsh
# VA Core Local Development Environment Setup
# This script checks for correct paths and environment variables

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check for auto-run flags
AUTO_RUN=false
if [[ "$1" == "--auto" || "$1" == "-a" || "$AUTO_RUN_CHECKS" == "true" ]]; then
    AUTO_RUN=true
fi

# Check if Oracle JDK exists
ORACLE_JDK="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"
if [ ! -d "$ORACLE_JDK" ]; then
    echo "${RED}Oracle JDK 1.8.0_202 not found at expected location${NC}"
    exit 1
fi

# If auto-run is enabled, execute option 1 directly
if [ "$AUTO_RUN" = true ]; then
    echo "${BLUE}Running all verification checks...${NC}"
    echo ""
    
    echo "${YELLOW}=== 1. Path Analysis ===${NC}"
    "$(dirname "$0")/scripts/utils/analyze-paths-config-tool.sh"
    echo ""
    
    echo "${YELLOW}=== 2. WebLogic Environment ===${NC}"
    "$(dirname "$0")/scripts/utils/check-weblogic.sh"
    echo ""
    
    echo "${YELLOW}=== 3. VA Core Environment Standardization ===${NC}"
    "$(dirname "$0")/scripts/utils/verify-standardization.sh"
    echo ""
    
    echo "${YELLOW}=== 4. Oracle Directory Structure ===${NC}"
    "$(dirname "$0")/scripts/utils/verify-oracle-directory.sh"
    echo ""
    
    echo "${GREEN}All verification checks completed!${NC}"
    exit 0
fi

# Setup options
echo "${BLUE}=== Available Tools ===${NC}"
echo "1. Run all verification checks"
echo "2. Path Analysis (analyze system paths for Maven, Java, Oracle)"
echo "3. Check WebLogic environment"
echo "4. Verify VA Core environment standardization"
echo "5. Verify Oracle directory structure"
echo "6. View README Documentation"
echo "7. Exit"

echo -n "Select an option (1-7): "
read option

case $option in
    1)
        echo "${BLUE}Running all verification checks...${NC}"
        echo ""
        
        echo "${YELLOW}=== 1. Path Analysis ===${NC}"
        "$(dirname "$0")/scripts/utils/analyze-paths-config-tool.sh"
        echo ""
        
        echo "${YELLOW}=== 2. WebLogic Environment ===${NC}"
        "$(dirname "$0")/scripts/utils/check-weblogic.sh"
        echo ""
        
        echo "${YELLOW}=== 3. VA Core Environment Standardization ===${NC}"
        "$(dirname "$0")/scripts/utils/verify-standardization.sh"
        echo ""
        
        echo "${YELLOW}=== 4. Oracle Directory Structure ===${NC}"
        "$(dirname "$0")/scripts/utils/verify-oracle-directory.sh"
        echo ""
        
        echo "${GREEN}All verification checks completed!${NC}"
        ;;
    2)
        echo "Running Path Analysis Configuration Tool..."
        "$(dirname "$0")/scripts/utils/analyze-paths-config-tool.sh"
        ;;
    3)
        echo "Checking WebLogic environment..."
        "$(dirname "$0")/scripts/utils/check-weblogic.sh"
        ;;
    4)
        echo "Verifying VA Core environment standardization..."
        "$(dirname "$0")/scripts/utils/verify-standardization.sh"
        ;;
    5)
        echo "Verifying Oracle directory structure..."
        "$(dirname "$0")/scripts/utils/verify-oracle-directory.sh"
        ;;
    6)
        echo "Displaying README documentation..."
        if command -v glow &> /dev/null; then
            glow "$(dirname "$0")/README.md"
        elif command -v mdless &> /dev/null; then
            mdless "$(dirname "$0")/README.md"
        elif command -v bat &> /dev/null; then
            bat "$(dirname "$0")/README.md"
        elif command -v less &> /dev/null; then
            less "$(dirname "$0")/README.md"
        else
            cat "$(dirname "$0")/README.md"
        fi
        ;;
    7)
        echo "${YELLOW}Exiting setup script${NC}"
        exit 0
        ;;
    *)
        echo "${RED}Invalid option. Please select a valid option (1-7).${NC}"
        ;;
esac
