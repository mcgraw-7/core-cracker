#!/bin/zsh
# Oracle Directory Structure Verification

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Required Oracle paths
ORACLE_HOME="$HOME/dev/Oracle/Middleware/Oracle_Home"
WEBLOGIC_HOME="$ORACLE_HOME/wlserver"
DOMAIN_HOME="$ORACLE_HOME/user_projects/domains"
ORACLE_JDK="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"

# Check Oracle Home directory
echo -n "Checking Oracle Home directory: "
if [ -d "$ORACLE_HOME" ]; then
    echo "${GREEN}✅ FOUND${NC}"
else
    echo "${RED}❌ NOT FOUND${NC}"
    exit 1
fi

# Check WebLogic Server directory
echo -n "Checking WebLogic Server directory: "
if [ -d "$WEBLOGIC_HOME" ]; then
    echo "${GREEN}✅ FOUND${NC}"
else
    echo "${RED}❌ NOT FOUND${NC}"
fi

# Check WebLogic Domain
echo -n "Checking WebLogic Domain: "
if [ -d "$DOMAIN_HOME" ] && [ "$(ls -A "$DOMAIN_HOME" 2>/dev/null)" ]; then
    echo "${GREEN}✅ FOUND${NC}"
else
    echo "${RED}❌ NOT FOUND${NC}"
fi

# Check Oracle JDK
echo -n "Checking Oracle JDK: "
if [ -d "$ORACLE_JDK" ]; then
    echo "${GREEN}✅ FOUND${NC}"
else
    echo "${RED}❌ NOT FOUND${NC}"
fi
