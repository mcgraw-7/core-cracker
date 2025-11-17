#!/bin/zsh
# WebLogic Environment Check

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "${BLUE}WebLogic Environment${NC}"
echo ""

# Check WebLogic installation
echo "${YELLOW}WebLogic Installation:${NC}"
WEBLOGIC_HOME="${HOME}/dev/Oracle/Middleware/Oracle_Home"
if [ -d "$WEBLOGIC_HOME" ]; then
    echo "${GREEN}Location:${NC} $WEBLOGIC_HOME"
    
    # Check WebLogic version
    if [ -f "$WEBLOGIC_HOME/wlserver/version.txt" ]; then
        WEBLOGIC_VERSION=$(head -n 1 "$WEBLOGIC_HOME/wlserver/version.txt")
        echo "${GREEN}Version:${NC} $WEBLOGIC_VERSION"
    else
        echo "${YELLOW}Version:${NC} Could not determine"
    fi
else
    echo "${RED}Not found at: $WEBLOGIC_HOME${NC}"
fi

echo ""

# Check WebLogic domain
echo "${YELLOW}WebLogic Domain:${NC}"
DOMAIN_HOME="${HOME}/dev/Oracle/Middleware/user_projects/domains/P2-DEV"
if [ -d "$DOMAIN_HOME" ]; then
    echo "${GREEN}Location:${NC} $DOMAIN_HOME"
    
    # Check if domain is configured
    if [ -f "$DOMAIN_HOME/config/config.xml" ]; then
        echo "${GREEN}Configuration:${NC} Found"
    else
        echo "${RED}Configuration:${NC} Not found"
    fi
    
    # Check if start script exists
    if [ -f "$DOMAIN_HOME/bin/startWebLogic.sh" ]; then
        echo "${GREEN}Start script:${NC} Found"
    else
        echo "${RED}Start script:${NC} Not found"
    fi
else
    echo "${RED}Not found at: $DOMAIN_HOME${NC}"
fi

echo ""

# Check WebLogic processes
echo "${YELLOW}WebLogic Processes:${NC}"
WEBLOGIC_PROCESSES=$(ps aux | grep weblogic | grep -v grep | wc -l | tr -d ' ')
if [ "$WEBLOGIC_PROCESSES" -gt 0 ]; then
    echo "${GREEN}Running:${NC} $WEBLOGIC_PROCESSES processes"
    ps aux | grep weblogic | grep -v grep | awk '{print "  PID: " $2 " - " $11}' | head -5
else
    echo "${YELLOW}Running:${NC} No processes found"
fi

echo ""

# Check environment variables
echo "${YELLOW}Environment Variables:${NC}"
if [ -n "${MW_HOME:-}" ]; then
    echo "${GREEN}MW_HOME:${NC} $MW_HOME"
else
    echo "${YELLOW}MW_HOME:${NC} Not set"
fi

if [ -n "${WL_HOME:-}" ]; then
    echo "${GREEN}WL_HOME:${NC} $WL_HOME"
else
    echo "${YELLOW}WL_HOME:${NC} Not set"
fi

if [ -n "${DOMAINS:-}" ]; then
    echo "${GREEN}DOMAINS:${NC} $DOMAINS"
else
    echo "${YELLOW}DOMAINS:${NC} Not set"
fi

echo ""
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