#!/bin/zsh
# WebLogic Environment Check

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "${BLUE}=== WebLogic Environment Check ===${NC}"
echo ""

# Check Oracle JDK
echo "${YELLOW}Checking Oracle JDK...${NC}"
ORACLE_JDK="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"
if [ -d "$ORACLE_JDK" ]; then
    echo "${GREEN}Found Oracle JDK at: $ORACLE_JDK${NC}"
    
    # Check Java version
    JAVA_VERSION=$("$ORACLE_JDK/bin/java" -version 2>&1 | head -n 1)
    echo "${GREEN}Java version: $JAVA_VERSION${NC}"
else
    echo "${RED}Oracle JDK not found at expected location${NC}"
    echo "${YELLOW}Expected: $ORACLE_JDK${NC}"
fi

echo ""

# Check WebLogic installation
echo "${YELLOW}Checking WebLogic installation...${NC}"
WEBLOGIC_HOME="/Users/michaelmcgraw/dev/Oracle/Middleware/Oracle_Home"
if [ -d "$WEBLOGIC_HOME" ]; then
    echo "${GREEN}Found WebLogic at: $WEBLOGIC_HOME${NC}"
    
    # Check WebLogic version
    if [ -f "$WEBLOGIC_HOME/wlserver/version.txt" ]; then
        WEBLOGIC_VERSION=$(head -n 1 "$WEBLOGIC_HOME/wlserver/version.txt")
        echo "${GREEN}WebLogic version: $WEBLOGIC_VERSION${NC}"
    else
        echo "${YELLOW}Could not determine WebLogic version${NC}"
    fi
else
    echo "${RED}WebLogic not found at expected location${NC}"
    echo "${YELLOW}Expected: $WEBLOGIC_HOME${NC}"
fi

echo ""

# Check WebLogic domain
echo "${YELLOW}Checking WebLogic domain...${NC}"
DOMAIN_HOME="/Users/michaelmcgraw/dev/Oracle/Middleware/user_projects/domains/P2-DEV"
if [ -d "$DOMAIN_HOME" ]; then
    echo "${GREEN}Found WebLogic domain at: $DOMAIN_HOME${NC}"
    
    # Check if domain is configured
    if [ -f "$DOMAIN_HOME/config/config.xml" ]; then
        echo "${GREEN}Domain configuration found${NC}"
    else
        echo "${RED}Domain configuration not found${NC}"
    fi
    
    # Check if start script exists
    if [ -f "$DOMAIN_HOME/bin/startWebLogic.sh" ]; then
        echo "${GREEN}Start script found${NC}"
    else
        echo "${RED}Start script not found${NC}"
    fi
else
    echo "${RED}WebLogic domain not found at expected location${NC}"
    echo "${YELLOW}Expected: $DOMAIN_HOME${NC}"
fi

echo ""

# Check WebLogic processes
echo "${YELLOW}Checking WebLogic processes...${NC}"
WEBLOGIC_PROCESSES=$(ps aux | grep weblogic | grep -v grep | wc -l)
if [ "$WEBLOGIC_PROCESSES" -gt 0 ]; then
    echo "${GREEN}WebLogic processes running: $WEBLOGIC_PROCESSES${NC}"
    ps aux | grep weblogic | grep -v grep | awk '{print $2, $11}' | while read pid cmd; do
        echo "${GREEN}  PID: $pid - $cmd${NC}"
    done
else
    echo "${YELLOW}No WebLogic processes currently running${NC}"
fi

echo ""

# Check WebLogic admin console
echo "${YELLOW}Checking WebLogic admin console...${NC}"
if curl -s http://localhost:7001/console >/dev/null 2>&1; then
    echo "${GREEN}WebLogic admin console is accessible${NC}"
    echo "${GREEN}URL: http://localhost:7001/console${NC}"
else
    echo "${YELLOW}WebLogic admin console is not accessible${NC}"
    echo "${YELLOW}URL: http://localhost:7001/console${NC}"
fi

echo ""

# Check environment variables
echo "${YELLOW}Checking environment variables...${NC}"
if [ -n "$JAVA_HOME" ]; then
    echo "${GREEN}JAVA_HOME is set: $JAVA_HOME${NC}"
else
    echo "${RED}JAVA_HOME is not set${NC}"
fi

if [ -n "$MW_HOME" ]; then
    echo "${GREEN}MW_HOME is set: $MW_HOME${NC}"
else
    echo "${YELLOW}MW_HOME is not set${NC}"
fi

if [ -n "$WL_HOME" ]; then
    echo "${GREEN}WL_HOME is set: $WL_HOME${NC}"
else
    echo "${YELLOW}WL_HOME is not set${NC}"
fi

echo ""

# Check WebLogic security configuration
echo "${YELLOW}Checking WebLogic security configuration...${NC}"
if [ -f "$DOMAIN_HOME/config/config.xml" ]; then
    # Check for security configuration
    if grep -q "security-configuration" "$DOMAIN_HOME/config/config.xml"; then
        echo "${GREEN}Security configuration found in domain${NC}"
    else
        echo "${YELLOW}No security configuration found in domain${NC}"
    fi
    
    # Check for authentication providers
    if grep -q "authentication-provider" "$DOMAIN_HOME/config/config.xml"; then
        echo "${GREEN}Authentication providers configured${NC}"
    else
        echo "${YELLOW}No authentication providers found${NC}"
    fi
else
    echo "${RED}Domain config not found, cannot check security${NC}"
fi

echo ""
echo "${GREEN}WebLogic environment check completed!${NC}" 