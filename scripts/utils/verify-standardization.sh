#!/bin/zsh
# VA Core Environment Standardization Verification

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check Java installation
ORACLE_JDK="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"
echo -n "Checking Java installation: "
if [ -d "$ORACLE_JDK" ]; then
    echo "${GREEN}FOUND${NC}"
    echo "  Path: $ORACLE_JDK"
else
    echo "${RED}NOT FOUND${NC}"
    exit 1
fi

# Check WebLogic Java environment file
WLJAVA_ENV="$HOME/.wljava_env"
echo -n "Checking WebLogic Java environment: "
if [ -f "$WLJAVA_ENV" ]; then
    echo "${GREEN}FOUND${NC}"
    echo "  Path: $WLJAVA_ENV"
else
    echo "${YELLOW}NOT FOUND${NC}"
fi

echo ""

# Current Java Environment
echo "Java Environment:"
echo "JAVA_HOME: $JAVA_HOME"
echo "Version: $(java -version 2>&1 | head -n 1)"
