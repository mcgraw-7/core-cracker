#!/bin/zsh
# Apple Silicon Compatibility Check

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running on Apple Silicon
if [ "$(uname -m)" = "arm64" ]; then
    echo " Detected Apple Silicon Mac (arm64)"
else
    echo "  Not running on Apple Silicon"
    exit 0
fi

echo ""

# Check Colima status
echo "Checking Colima status..."
if command -v colima >/dev/null 2>&1; then
    echo " Colima is installed"
    
    COlima_STATUS=$(colima status 2>/dev/null | grep "colima is running" || echo "not running")
    if [[ "$COlima_STATUS" == *"running"* ]]; then
        echo " Colima is running"
        
        # Get Colima architecture
        COlima_ARCH=$(colima status 2>/dev/null | grep "arch:" | awk '{print $2}')
        if [ "$COlima_ARCH" = "x86_64" ]; then
            echo " Colima is running with x86_64 architecture"
        else
            echo "  Colima architecture: $COlima_ARCH"
        fi
    else
        echo " Colima is not running"
    fi
else
    echo " Colima not installed"
fi

echo ""

# Check Docker
echo "Checking Docker..."
if command -v docker >/dev/null 2>&1; then
    echo " Docker is installed"
    
    if docker info >/dev/null 2>&1; then
        echo " Docker is working correctly"
    else
        echo " Docker is not working"
    fi
else
    echo " Docker not installed"
fi

echo ""

# Check Rosetta 2
echo "Checking Rosetta 2..."
if /usr/bin/pgrep -q oahd; then
    echo " Rosetta 2 is installed"
else
    echo " Rosetta 2 is not installed"
fi

echo ""

# Check Oracle JDK
echo "Checking Oracle JDK..."
ORACLE_JDK="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"
if [ -d "$ORACLE_JDK" ]; then
    echo " Found Oracle JDK at: $ORACLE_JDK"
    
    # Check architecture
    JDK_ARCH=$(file "$ORACLE_JDK/bin/java" | grep -o "x86_64\|arm64")
    if [ "$JDK_ARCH" = "x86_64" ]; then
        echo " Oracle JDK is x86_64 (will run via Rosetta 2)"
    else
        echo "  Oracle JDK architecture: $JDK_ARCH"
    fi
else
    echo " Oracle JDK not found at expected location"
fi
