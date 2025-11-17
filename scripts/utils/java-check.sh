#!/bin/zsh
# Java Environment Check

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "${BLUE}Java Environment${NC}"
echo ""

# Check JAVA_HOME
if [ -n "${JAVA_HOME:-}" ]; then
    echo "${GREEN}JAVA_HOME:${NC} $JAVA_HOME"
else
    echo "${RED}JAVA_HOME not set${NC}"
    exit 1
fi

# Check Java executable
if [ -x "${JAVA_HOME}/bin/java" ]; then
    echo "${GREEN}Java executable:${NC} ${JAVA_HOME}/bin/java"
else
    echo "${RED}Java executable not found or not executable${NC}"
    exit 1
fi

# Java version
JAVA_VERSION=$("${JAVA_HOME}/bin/java" -version 2>&1 | head -n 1)
echo "${GREEN}Version:${NC} $JAVA_VERSION"

# Architecture
CPU_ARCH=$(uname -m)
JAVA_ARCH=$(file "${JAVA_HOME}/bin/java" | grep -o "x86_64\|arm64")
echo "${GREEN}CPU Architecture:${NC} $CPU_ARCH"
echo "${GREEN}Java Architecture:${NC} $JAVA_ARCH"

# Check if in PATH
if [[ ":${PATH}:" == *":${JAVA_HOME}/bin:"* ]]; then
    echo "${GREEN}In PATH:${NC} Yes"
else
    echo "${YELLOW}In PATH:${NC} No"
fi

echo ""
