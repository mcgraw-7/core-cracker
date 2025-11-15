#!/bin/zsh
# Path Analysis Configuration Tool
# This script analyzes system paths and categorizes them for Maven, Java, and Oracle
# to help verify against documentation and ensure proper configuration

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
print_section() {
    echo "${BLUE}========== $1 ==========${NC}"
}

print_subsection() {
    echo "${CYAN}--- $1 ---${NC}"
}

print_path() {
    local path="$1"
    local path_status="$2"
    local description="$3"
    
    if [ "$path_status" = "exists" ]; then
        echo "${GREEN} $path${NC}"
        echo "    $description"
    elif [ "$path_status" = "optional" ]; then
        if [ -d "$path" ] || [ -f "$path" ]; then
            echo "${GREEN} $path${NC}"
            echo "    $description"
        else
            echo "${YELLOW}$path (optional)${NC}"
            echo "    $description"
        fi
    else
        echo "${RED} $path${NC}"
        echo "    $description"
    fi
}

# -------------------------------------
# MAVEN PATH ANALYSIS
# -------------------------------------
print_section "MAVEN"

print_subsection "Maven Installation Paths"
# Check Maven installation
if command -v mvn >/dev/null 2>&1; then
    MVN_PATH=$(which mvn)
    MVN_HOME=$(mvn -v | grep "Maven home" | awk '{print $3}')
    print_path "$MVN_PATH" "exists" "Maven executable location"
    print_path "$MVN_HOME" "exists" "Maven home directory"
else
    print_path "mvn command" "missing" "Maven not found in PATH"
fi

print_subsection "Maven Configuration Paths"
# Maven settings and repository paths
MAVEN_SETTINGS="$HOME/.m2/settings.xml"
MAVEN_REPO="$HOME/.m2/repository"
MAVEN_LOCAL_REPO="$HOME/.m2/repository"

print_path "$MAVEN_SETTINGS" "$([ -f "$MAVEN_SETTINGS" ] && echo "exists" || echo "missing")" "Maven settings.xml file"
print_path "$MAVEN_REPO" "$([ -d "$MAVEN_REPO" ] && echo "exists" || echo "missing")" "Maven local repository"
print_path "$MAVEN_LOCAL_REPO" "$([ -d "$MAVEN_LOCAL_REPO" ] && echo "exists" || echo "missing")" "Maven local repository (alternative path)"

print_subsection "Maven Repository URLs"
if [ -f "$MAVEN_SETTINGS" ]; then
    echo "Configured repositories in settings.xml:"
    # Use a more robust approach to extract repository URLs
    if grep -q "<repository>" "$MAVEN_SETTINGS"; then
        # Extract URLs from repository sections
        awk '/<repository>/,/<\/repository>/ {
            if ($0 ~ /<url>/) {
                gsub(/.*<url>/, "")
                gsub(/<\/url>.*/, "")
                gsub(/^[ \t]+/, "")
                gsub(/[ \t]+$/, "")
                if (length($0) > 0) {
                    print "  - " $0
                }
            }
        }' "$MAVEN_SETTINGS"
    else
        echo "  - No custom repositories found (using Maven Central)"
    fi
    
    # Also check for mirror configurations
    if grep -q "<mirror>" "$MAVEN_SETTINGS"; then
        echo ""
        echo "Maven mirrors configured:"
        awk '/<mirror>/,/<\/mirror>/ {
            if ($0 ~ /<url>/) {
                gsub(/.*<url>/, "")
                gsub(/<\/url>.*/, "")
                gsub(/^[ \t]+/, "")
                gsub(/[ \t]+$/, "")
                if (length($0) > 0) {
                    print "  - " $0
                }
            }
        }' "$MAVEN_SETTINGS"
    fi
else
    echo "${YELLOW}  No settings.xml found - using default Maven Central${NC}"
fi

# -------------------------------------
# JAVA PATH ANALYSIS
# -------------------------------------
print_section "JAVA"

print_subsection "Java Installation Paths"
# Check Java installations
JAVA_PATH=$(which java)
JAVA_HOME_VALUE="$JAVA_HOME"
JDK_8_PATH="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk"
JDK_11_PATH="$HOME/dev/jdk-11.0.26.jdk"
JDK_8_ALT_PATH="$HOME/dev/jdk1.8.0_181"

print_path "$JAVA_PATH" "$([ -n "$JAVA_PATH" ] && echo "exists" || echo "missing")" "Java executable location"
print_path "$JAVA_HOME_VALUE" "$([ -n "$JAVA_HOME_VALUE" ] && echo "exists" || echo "missing")" "JAVA_HOME environment variable"
print_path "$JDK_8_PATH" "$([ -d "$JDK_8_PATH" ] && echo "exists" || echo "missing")" "Standard JDK 8 installation (Oracle)"
print_path "$JDK_11_PATH" "$([ -d "$JDK_11_PATH" ] && echo "exists" || echo "missing")" "JDK 11 installation (local)"
print_path "$JDK_8_ALT_PATH" "$([ -d "$JDK_8_ALT_PATH" ] && echo "exists" || echo "optional")" "Alternative JDK 8 installation (local)"

print_subsection "Java Version Information"
if command -v java >/dev/null 2>&1; then
    JAVA_VERSION=$(java -version 2>&1 | head -1)
    echo "Current Java version: $JAVA_VERSION"
    
    # Check if it's the expected Java 8
    if [[ "$JAVA_VERSION" == *"1.8"* ]]; then
        echo "${GREEN} Java 8 detected - compatible with WebLogic${NC}"
    else
        echo "${YELLOW}  Non-Java 8 version detected - may cause WebLogic issues${NC}"
    fi
else
    echo "${RED} Java not found in PATH${NC}"
fi

print_subsection "Java Environment Variables"
echo "JAVA_HOME: $JAVA_HOME"
echo "JAVA_OPTS: $JAVA_OPTS"
echo "JRE_HOME: $JRE_HOME"

# -------------------------------------
# ORACLE PATH ANALYSIS
# -------------------------------------
print_section "ORACLE"

print_subsection "Oracle Middleware Paths"
# Oracle WebLogic paths
ORACLE_HOME="$HOME/dev/Oracle/Middleware/Oracle_Home"
WEBLOGIC_HOME="$ORACLE_HOME/wlserver"
ORACLE_COMMON="$ORACLE_HOME/oracle_common"
ORACLE_INVENTORY="$HOME/dev/Oracle/oraInventory"

print_path "$ORACLE_HOME" "$([ -d "$ORACLE_HOME" ] && echo "exists" || echo "missing")" "Oracle Middleware home (required)"
print_path "$WEBLOGIC_HOME" "$([ -d "$WEBLOGIC_HOME" ] && echo "exists" || echo "missing")" "WebLogic Server home"
print_path "$ORACLE_COMMON" "$([ -d "$ORACLE_COMMON" ] && echo "exists" || echo "missing")" "Oracle Common home"
print_path "$ORACLE_INVENTORY" "$([ -d "$ORACLE_INVENTORY" ] && echo "exists" || echo "optional")" "Oracle Inventory directory"

print_subsection "WebLogic Domain Paths"
# WebLogic domain paths
DOMAIN_BASE="$ORACLE_HOME/user_projects/domains"
DOMAIN_CONFIG="$DOMAIN_BASE/*/config/config.xml"

if [ -d "$DOMAIN_BASE" ]; then
    found_domains=0
    echo "Available WebLogic domains:"
    for domain in "$DOMAIN_BASE"/*; do
        if [ -d "$domain" ]; then
            domain_name=$(basename "$domain")
            if [ -f "$domain/config/config.xml" ]; then
                print_path "$domain" "exists" "Domain: $domain_name"
            else
                print_path "$domain" "optional" "Domain: $domain_name (incomplete)"
            fi
            found_domains=1
        fi
    done
    if [ $found_domains -eq 0 ]; then
        echo "  (none found)"
    fi
else
    print_path "$DOMAIN_BASE" "missing" "No WebLogic domains directory found"
fi

print_subsection "Oracle Database Paths"
# Oracle database container status
ORACLE_DB_CONTAINER="vbms-dev-docker-19c"

# Check Docker and Colima status
if command -v docker >/dev/null 2>&1; then
    echo "Docker/Colima Status:"
    
    # Check if Colima is running
    if command -v colima >/dev/null 2>&1; then
        COlima_STATUS=$(colima status 2>/dev/null | grep "colima is running" || echo "not running")
        if [[ "$COlima_STATUS" == *"running"* ]]; then
            echo "  ${GREEN} Colima is running${NC}"
            # Get Colima details
            COlima_ARCH=$(colima status 2>/dev/null | grep "arch:" | awk '{print $2}')
            COlima_RUNTIME=$(colima status 2>/dev/null | grep "runtime:" | awk '{print $2}')
            echo "    Architecture: $COlima_ARCH"
            echo "    Runtime: $COlima_RUNTIME"
        else
            echo "  ${RED} Colima is not running${NC}"
        fi
    else
        echo "  ${YELLOW}  Colima not installed${NC}"
    fi
    
    # Check Oracle DB container status
    if docker ps -a --format "table {{.Names}}\t{{.Status}}" | grep -q "$ORACLE_DB_CONTAINER"; then
        CONTAINER_STATUS=$(docker ps --format "table {{.Names}}\t{{.Status}}" | grep "$ORACLE_DB_CONTAINER" | awk '{print $2}')
        if [[ "$CONTAINER_STATUS" == *"Up"* ]]; then
            echo "  ${GREEN} Oracle DB Container ($ORACLE_DB_CONTAINER) is running${NC}"
        else
            echo "  ${YELLOW}  Oracle DB Container ($ORACLE_DB_CONTAINER) exists but not running${NC}"
            echo "    Status: $CONTAINER_STATUS"
        fi
    else
        echo "  ${RED} Oracle DB Container ($ORACLE_DB_CONTAINER) not found${NC}"
    fi
    
    # Show all running containers
    RUNNING_CONTAINERS=$(docker ps --format "{{.Names}}" | wc -l)
    echo "  Total running containers: $RUNNING_CONTAINERS"
    
else
    echo "  ${RED} Docker not available${NC}"
fi


# -------------------------------------
# ENVIRONMENT PATH ANALYSIS
# -------------------------------------
print_section "ENVIRONMENT"

print_subsection "PATH Environment Variable"
echo "Current PATH entries:"
echo "$PATH" | tr ':' '\n' | sed 's/^/  /' | while read path_entry; do
    if [ -n "$path_entry" ]; then
        # Skip Oracle_Home/bin as it's not a standard Oracle WebLogic directory
        if [[ "$path_entry" == *"Oracle_Home/bin"* ]]; then
            continue
        fi
        if [ -d "$path_entry" ]; then
            echo "${GREEN}   $path_entry${NC}"
        else
            echo "${RED}   $path_entry (not found)${NC}"
        fi
    fi
done

print_subsection "Key Environment Variables"
echo "ORACLE_HOME: $ORACLE_HOME"
echo "WEBLOGIC_HOME: $WEBLOGIC_HOME"
echo "M2_HOME: $M2_HOME"
echo "JAVA_HOME: $JAVA_HOME"
echo "DOMAIN_HOME: $DOMAIN_HOME"

