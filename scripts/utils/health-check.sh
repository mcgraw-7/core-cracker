#!/bin/zsh
# Script Name: health-check.sh
# Description: Comprehensive system health diagnostic for VA Core development environment
# Version: 1.0

# Set strict error handling
set -uo pipefail

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Constants
readonly ORACLE_JDK="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk/Contents/Home"
readonly MIN_DISK_SPACE_GB=20
readonly MIN_MEMORY_GB=8

# Counters
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# Arrays for messages
typeset -a ERRORS
typeset -a WARNINGS
typeset -a RECOMMENDATIONS

# Functions
function print_header() {
    echo ""
    echo "${BLUE}System Health Check${NC}"
    echo ""
}

function print_footer() {
    echo ""
    
    local overall_status
    if [ $FAIL_COUNT -gt 0 ]; then
        overall_status="${RED}FAILURES FOUND${NC}"
    elif [ $WARN_COUNT -gt 0 ]; then
        overall_status="${YELLOW}WARNINGS FOUND${NC}"
    else
        overall_status="${GREEN}ALL CHECKS PASSED${NC}"
    fi
    
    echo "Status: $overall_status"
    printf "Results: ${GREEN}%d passed${NC}, ${RED}%d failed${NC}, ${YELLOW}%d warnings${NC}\n" \
        $PASS_COUNT $FAIL_COUNT $WARN_COUNT
    echo ""
    
    # Print errors
    if [ ${#ERRORS[@]} -gt 0 ]; then
        echo "${RED}Errors:${NC}"
        for error in "${ERRORS[@]}"; do
            echo "  - $error"
        done
        echo ""
    fi
    
    # Print warnings
    if [ ${#WARNINGS[@]} -gt 0 ]; then
        echo "${YELLOW}Warnings:${NC}"
        for warning in "${WARNINGS[@]}"; do
            echo "  - $warning"
        done
        echo ""
    fi
    
    # Print recommendations
    if [ ${#RECOMMENDATIONS[@]} -gt 0 ]; then
        echo "${CYAN}Recommendations:${NC}"
        for rec in "${RECOMMENDATIONS[@]}"; do
            echo "  - $rec"
        done
        echo ""
    fi
}

function check_pass() {
    ((PASS_COUNT++))
    printf "%-35s %s\n" "$1" "${GREEN}PASS${NC}"
}

function check_fail() {
    ((FAIL_COUNT++))
    printf "%-35s %s\n" "$1" "${RED}FAIL${NC}"
    ERRORS+=("$2")
}

function check_warn() {
    ((WARN_COUNT++))
    printf "%-35s %s\n" "$1" "${YELLOW}WARN${NC}"
    WARNINGS+=("$2")
}

function check_java() {
    echo "${CYAN}Java Environment${NC}"
    
    # Check JAVA_HOME set
    if [ -n "${JAVA_HOME:-}" ]; then
        check_pass "JAVA_HOME set"
    else
        check_fail "JAVA_HOME set" "JAVA_HOME environment variable not set"
        RECOMMENDATIONS+=("Set JAVA_HOME in ~/.zshrc: export JAVA_HOME=\"${ORACLE_JDK}\"")
        echo ""
        return
    fi
    
    # Check JAVA_HOME exists
    if [ -d "$JAVA_HOME" ]; then
        check_pass "JAVA_HOME directory exists"
    else
        check_fail "JAVA_HOME directory exists" "Directory not found: $JAVA_HOME"
        if [ "$(uname -m)" = "arm64" ]; then
            RECOMMENDATIONS+=("Install Zulu JDK 8 ARM64: https://www.azul.com/downloads/")
        else
            RECOMMENDATIONS+=("Install Oracle JDK 1.8.0_202 or correct JAVA_HOME path")
        fi
        echo ""
        return
    fi
    
    # Check Java executable
    if [ -x "${JAVA_HOME}/bin/java" ]; then
        check_pass "Java executable found"
    else
        check_fail "Java executable found" "Java not executable at ${JAVA_HOME}/bin/java"
        echo ""
        return
    fi
    
    # Check Java version (Zulu 8 for ARM64, Oracle for Intel)
    local java_version=$("${JAVA_HOME}/bin/java" -version 2>&1 | head -n 1)
    local cpu_arch=$(uname -m)
    
    if [ "$cpu_arch" = "arm64" ]; then
        # ARM64: Zulu JDK 8 (1.8.0_xxx)
        if [[ "$java_version" == *"1.8.0"* ]]; then
            check_pass "Java version (Zulu 8)"
        else
            check_fail "Java version (Zulu 8)" "Expected JDK 8, found: $java_version"
            RECOMMENDATIONS+=("Install Zulu JDK 8 ARM64 from https://www.azul.com/downloads/")
        fi
        
        # Check it's ARM64 native
        local java_arch=$(file "${JAVA_HOME}/bin/java" | grep -o "x86_64\|arm64")
        if [ "$java_arch" = "arm64" ]; then
            check_pass "Java architecture (ARM64)"
        else
            check_warn "Java architecture (ARM64)" "Java is $java_arch, ARM64 native recommended"
        fi
    else
        # Intel: Oracle JDK 1.8.0_202
        if [[ "$java_version" == *"1.8.0_202"* ]]; then
            check_pass "Java version (Oracle 1.8.0_202)"
        else
            check_warn "Java version (Oracle 1.8.0_202)" "Expected 1.8.0_202, found: $java_version"
            RECOMMENDATIONS+=("Install Oracle JDK 1.8.0_202 for WebLogic compatibility")
        fi
    fi
    
    echo ""
}

function check_weblogic() {
    echo "${CYAN}WebLogic Installation${NC}"
    
    # Check MW_HOME set
    if [ -n "${MW_HOME:-}" ]; then
        check_pass "MW_HOME set"
    else
        check_warn "MW_HOME set" "MW_HOME environment variable not set"
        RECOMMENDATIONS+=("Set MW_HOME in ~/.zshrc: export MW_HOME=\"\${HOME}/dev/Oracle/Middleware/Oracle_Home\"")
    fi
    
    # Check MW_HOME directory
    local expected_mw_home="${HOME}/dev/Oracle/Middleware/Oracle_Home"
    if [ -d "$expected_mw_home" ]; then
        check_pass "WebLogic directory exists"
    else
        check_fail "WebLogic directory exists" "Directory not found: $expected_mw_home"
        RECOMMENDATIONS+=("Install WebLogic Server at ${expected_mw_home}")
        echo ""
        return
    fi
    
    # Check WLS_HOME
    local expected_wls_home="${expected_mw_home}/wlserver"
    if [ -d "$expected_wls_home" ]; then
        check_pass "WLS_HOME directory exists"
    else
        check_fail "WLS_HOME directory exists" "Directory not found: $expected_wls_home"
    fi
    
    # Check .wljava_env file
    if [ -f "${HOME}/.wljava_env" ]; then
        check_pass ".wljava_env file exists"
        
        # Check content
        if grep -q "JAVA_HOME" "${HOME}/.wljava_env"; then
            check_pass ".wljava_env has JAVA_HOME"
        else
            check_warn ".wljava_env has JAVA_HOME" "JAVA_HOME not set in .wljava_env"
            RECOMMENDATIONS+=("Add to ~/.wljava_env: export JAVA_HOME=\"${ORACLE_JDK}\"")
        fi
    else
        check_warn ".wljava_env file exists" "WebLogic Java config file not found"
        RECOMMENDATIONS+=("Create ~/.wljava_env with: export JAVA_HOME=\"${ORACLE_JDK}\"")
    fi
    
    echo ""
}

function check_environment() {
    echo "${CYAN}Environment Variables${NC}"
    
    # Check PATH contains JAVA_HOME
    if [[ ":${PATH}:" == *":${JAVA_HOME}/bin:"* ]]; then
        check_pass "JAVA_HOME in PATH"
    else
        check_warn "JAVA_HOME in PATH" "JAVA_HOME/bin not in PATH"
        RECOMMENDATIONS+=("Add to PATH: export PATH=\"\${JAVA_HOME}/bin:\${PATH}\"")
    fi
    
    echo ""
}

function check_tools() {
    echo "${CYAN}Required Tools${NC}"
    
    # Check git
    if command -v git >/dev/null 2>&1; then
        check_pass "git installed"
    else
        check_fail "git installed" "git not found in PATH"
    fi
    
    # Check docker (if on ARM)
    if [ "$(uname -m)" = "arm64" ]; then
        if command -v docker >/dev/null 2>&1; then
            check_pass "Docker installed"
            
            # Check Docker running
            if docker info >/dev/null 2>&1; then
                check_pass "Docker running"
            else
                check_warn "Docker running" "Docker daemon not accessible"
                RECOMMENDATIONS+=("Start Docker or Colima: colima start")
            fi
        else
            check_warn "Docker installed" "Docker not found (needed for Oracle DB on ARM)"
            RECOMMENDATIONS+=("Install Docker: brew install docker")
        fi
        
        # Check Colima
        if command -v colima >/dev/null 2>&1; then
            check_pass "Colima installed"
            
            # Check Colima status
            local colima_status=$(colima status 2>/dev/null || echo "not running")
            if [[ "$colima_status" == *"running"* ]]; then
                check_pass "Colima running"
                
                # Check architecture
                local colima_arch=$(colima status 2>/dev/null | grep "arch:" | awk '{print $2}')
                if [ "$colima_arch" = "x86_64" ]; then
                    check_pass "Colima arch (x86_64)"
                else
                    check_warn "Colima arch (x86_64)" "Running $colima_arch, x86_64 needed for Oracle DB"
                    RECOMMENDATIONS+=("Restart Colima: colima stop && colima start --arch x86_64")
                fi
            else
                check_warn "Colima running" "Colima not running"
                RECOMMENDATIONS+=("Start Colima: colima start --arch x86_64")
            fi
        else
            check_warn "Colima installed" "Colima not found (needed for containers on ARM)"
            RECOMMENDATIONS+=("Install Colima: brew install colima")
        fi
        
        # Check Rosetta 2
        if /usr/bin/pgrep -q oahd; then
            check_pass "Rosetta 2 installed"
        else
            check_warn "Rosetta 2 installed" "Rosetta 2 not installed (needed for x86_64 emulation)"
            RECOMMENDATIONS+=("Install Rosetta 2: softwareupdate --install-rosetta")
        fi
    fi
    
    echo ""
}

function check_system_resources() {
    echo "${CYAN}System Resources${NC}"
    
    # Check disk space
    local disk_avail=$(df -h / | tail -1 | awk '{print $4}' | sed 's/Gi//')
    local disk_avail_num=$(echo "$disk_avail" | sed 's/G.*//')
    
    if [ "$disk_avail_num" -ge "$MIN_DISK_SPACE_GB" ]; then
        check_pass "Disk space (${disk_avail} available)"
    else
        check_warn "Disk space (${disk_avail} available)" "Less than ${MIN_DISK_SPACE_GB}GB available"
        RECOMMENDATIONS+=("Free up disk space, at least ${MIN_DISK_SPACE_GB}GB recommended")
    fi
    
    # Check memory
    local total_mem=$(sysctl -n hw.memsize)
    local total_mem_gb=$((total_mem / 1024 / 1024 / 1024))
    
    if [ "$total_mem_gb" -ge "$MIN_MEMORY_GB" ]; then
        check_pass "System memory (${total_mem_gb}GB)"
    else
        check_warn "System memory (${total_mem_gb}GB)" "Less than ${MIN_MEMORY_GB}GB RAM"
        RECOMMENDATIONS+=("${MIN_MEMORY_GB}GB+ RAM recommended for development")
    fi
    
    # Check CPU architecture
    local cpu_arch=$(uname -m)
    if [ "$cpu_arch" = "arm64" ]; then
        check_pass "CPU architecture (Apple Silicon)"
    else
        check_pass "CPU architecture (Intel)"
    fi
    
    echo ""
}

function check_network() {
    echo "${CYAN}Network Connectivity${NC}"
    
    # Check internet connectivity
    if ping -c 1 google.com >/dev/null 2>&1; then
        check_pass "Internet connectivity"
    else
        check_warn "Internet connectivity" "Cannot reach google.com"
    fi
    
    # Check GitHub connectivity
    if ping -c 1 github.com >/dev/null 2>&1; then
        check_pass "GitHub connectivity"
    else
        check_warn "GitHub connectivity" "Cannot reach github.com"
    fi
    
    echo ""
}

function check_tunnel() {
    echo "${CYAN}VPN/Tunnel Status${NC}"
    
    # Check for devvpn SSH tunnel
    local tunnel_pid=$(ps -ef | grep ssh | grep amazon | grep "dvpc-socks-fleet-nlb" | awk '{print $2}')
    
    if [ -n "$tunnel_pid" ]; then
        check_pass "devvpn tunnel running"
    else
        check_warn "devvpn tunnel running" "SSH tunnel to AWS not detected"
        
        # Auto-start tunnel if script exists
        if [ -f "${HOME}/dev/scripts/devvpn" ]; then
            echo "  ${CYAN}Starting devvpn tunnel...${NC}"
            "${HOME}/dev/scripts/devvpn" start >/dev/null 2>&1 &
            sleep 2
            
            # Re-check if started successfully
            tunnel_pid=$(ps -ef | grep ssh | grep amazon | grep "dvpc-socks-fleet-nlb" | awk '{print $2}')
            if [ -n "$tunnel_pid" ]; then
                echo "  ${GREEN}Tunnel started successfully${NC}"
            else
                echo "  ${RED}Failed to start tunnel - check credentials${NC}"
                RECOMMENDATIONS+=("Manually start: ~/dev/scripts/devvpn start")
            fi
        else
            RECOMMENDATIONS+=("Install devvpn script to ~/dev/scripts/devvpn")
        fi
    fi
    
    echo ""
}

function main() {
    print_header
    
    check_java
    check_weblogic
    check_environment
    check_tools
    check_system_resources
    check_network
    check_tunnel
    
    print_footer
    
    # Exit with error if failures found
    if [ $FAIL_COUNT -gt 0 ]; then
        exit 1
    fi
    
    exit 0
}

# Run main function
main
