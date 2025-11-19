#!/bin/zsh
# Script Name: backup-vbms-properties.sh
# Description: Backup vbmsDeveloper.properties file with timestamped versions
# Version: 1.0

set -uo pipefail

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Constants
readonly BACKUP_DIR="${HOME}/dev/vbms-properties-backups"
readonly TIMESTAMP=$(date +%Y%m%d-%H%M%S)
readonly SOURCE_FILE="${HOME}/dev/vbms-core/vbms-install-weblogic/src/main/resources/vbmsDeveloper.properties"

function usage() {
    cat << EOF
${BLUE}VBMS Developer Properties Backup Tool${NC}

${CYAN}USAGE:${NC}
    $0 [OPTIONS]

${CYAN}OPTIONS:${NC}
    -h, --help              Show this help message
    -l, --list              List all backups
    -r, --restore FILE      Restore from specific backup
    -d, --diff FILE         Show differences between current and backup
    --latest                Show the latest backup
    --verify                Verify Hazelcast flag in current file

${CYAN}EXAMPLES:${NC}
    # Create backup
    $0

    # List backups
    $0 --list

    # Restore from specific backup
    $0 --restore vbmsDeveloper.properties.20251119-120000

    # Show differences
    $0 --diff vbmsDeveloper.properties.20251119-120000

    # Verify Hazelcast is disabled
    $0 --verify

${CYAN}BACKUP LOCATION:${NC}
    ${BACKUP_DIR}

EOF
}

function print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

function check_source_file() {
    if [[ ! -f "$SOURCE_FILE" ]]; then
        echo -e "${RED}✗ Error: vbmsDeveloper.properties not found${NC}"
        echo -e "${YELLOW}  Expected location: $SOURCE_FILE${NC}"
        echo -e "${YELLOW}  Make sure vbms-core repository is cloned to ~/dev/vbms-core${NC}"
        exit 1
    fi
}

function create_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        echo -e "${GREEN}✓ Created backup directory: $BACKUP_DIR${NC}"
    fi
}

function backup_properties() {
    print_header "Backing Up vbmsDeveloper.properties"
    
    check_source_file
    create_backup_dir
    
    local backup_file="${BACKUP_DIR}/vbmsDeveloper.properties.${TIMESTAMP}"
    
    # Copy file
    cp "$SOURCE_FILE" "$backup_file"
    
    # Get file size
    local size=$(du -h "$backup_file" | cut -f1)
    
    echo -e "${GREEN}✓ Backup created successfully${NC}"
    echo -e "${CYAN}  Source:${NC} $SOURCE_FILE"
    echo -e "${CYAN}  Backup:${NC} $backup_file"
    echo -e "${CYAN}  Size:${NC} $size"
    echo -e "${CYAN}  Time:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
    
    # Check for Hazelcast flag
    if grep -q "Dvbms.cache.hazelcast.enabled=false" "$backup_file"; then
        echo -e "${GREEN}✓ Hazelcast disabled flag present in backup${NC}"
    else
        echo -e "${YELLOW}⚠ Warning: Hazelcast disabled flag NOT found in backup${NC}"
        echo -e "${YELLOW}  You may need to add -Dvbms.cache.hazelcast.enabled=false to javaMemArgs${NC}"
    fi
}

function list_backups() {
    print_header "Available Backups"
    
    if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        echo -e "${YELLOW}No backups found${NC}"
        return
    fi
    
    echo -e "${CYAN}Location:${NC} $BACKUP_DIR\n"
    
    # List files with details
    local count=0
    for file in "$BACKUP_DIR"/vbmsDeveloper.properties.*; do
        if [[ -f "$file" ]]; then
            ((count++))
            local basename=$(basename "$file")
            local timestamp=${basename##*.}
            local size=$(du -h "$file" | cut -f1)
            local date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file")
            local has_hazelcast=""
            
            if grep -q "Dvbms.cache.hazelcast.enabled=false" "$file"; then
                has_hazelcast="${GREEN}✓ Hazelcast disabled${NC}"
            else
                has_hazelcast="${RED}✗ Hazelcast NOT disabled${NC}"
            fi
            
            echo -e "${BLUE}$count.${NC} $basename"
            echo -e "   Size: $size | Date: $date"
            echo -e "   $has_hazelcast"
            echo ""
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        echo -e "${YELLOW}No backups found${NC}"
    fi
}

function restore_backup() {
    local backup_file="$1"
    
    print_header "Restoring vbmsDeveloper.properties"
    
    # Check if backup file exists (try both full path and basename)
    local restore_path=""
    if [[ -f "$backup_file" ]]; then
        restore_path="$backup_file"
    elif [[ -f "${BACKUP_DIR}/${backup_file}" ]]; then
        restore_path="${BACKUP_DIR}/${backup_file}"
    else
        echo -e "${RED}✗ Error: Backup file not found: $backup_file${NC}"
        echo -e "${YELLOW}  Use --list to see available backups${NC}"
        exit 1
    fi
    
    check_source_file
    
    # Create backup of current file before restoring
    local current_backup="${SOURCE_FILE}.before-restore.${TIMESTAMP}"
    cp "$SOURCE_FILE" "$current_backup"
    echo -e "${GREEN}✓ Created backup of current file:${NC}"
    echo -e "   $current_backup"
    echo ""
    
    # Restore
    cp "$restore_path" "$SOURCE_FILE"
    
    echo -e "${GREEN}✓ Restored successfully${NC}"
    echo -e "${CYAN}  From:${NC} $restore_path"
    echo -e "${CYAN}  To:${NC} $SOURCE_FILE"
    
    # Verify Hazelcast flag
    if grep -q "Dvbms.cache.hazelcast.enabled=false" "$SOURCE_FILE"; then
        echo -e "${GREEN}✓ Hazelcast disabled flag present${NC}"
    else
        echo -e "${YELLOW}⚠ Warning: Hazelcast disabled flag NOT found${NC}"
    fi
}

function show_diff() {
    local backup_file="$1"
    
    print_header "Differences Between Current and Backup"
    
    # Check if backup file exists (try both full path and basename)
    local diff_path=""
    if [[ -f "$backup_file" ]]; then
        diff_path="$backup_file"
    elif [[ -f "${BACKUP_DIR}/${backup_file}" ]]; then
        diff_path="${BACKUP_DIR}/${backup_file}"
    else
        echo -e "${RED}✗ Error: Backup file not found: $backup_file${NC}"
        echo -e "${YELLOW}  Use --list to see available backups${NC}"
        exit 1
    fi
    
    check_source_file
    
    echo -e "${CYAN}Current:${NC} $SOURCE_FILE"
    echo -e "${CYAN}Backup:${NC} $diff_path"
    echo ""
    
    diff -u "$diff_path" "$SOURCE_FILE" || true
}

function show_latest() {
    print_header "Latest Backup"
    
    if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        echo -e "${YELLOW}No backups found${NC}"
        return
    fi
    
    local latest=$(ls -t "$BACKUP_DIR"/vbmsDeveloper.properties.* 2>/dev/null | head -1)
    
    if [[ -z "$latest" ]]; then
        echo -e "${YELLOW}No backups found${NC}"
        return
    fi
    
    local basename=$(basename "$latest")
    local size=$(du -h "$latest" | cut -f1)
    local date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$latest")
    
    echo -e "${CYAN}File:${NC} $basename"
    echo -e "${CYAN}Path:${NC} $latest"
    echo -e "${CYAN}Size:${NC} $size"
    echo -e "${CYAN}Date:${NC} $date"
    
    if grep -q "Dvbms.cache.hazelcast.enabled=false" "$latest"; then
        echo -e "${GREEN}✓ Hazelcast disabled flag present${NC}"
    else
        echo -e "${RED}✗ Hazelcast disabled flag NOT found${NC}"
    fi
}

function verify_hazelcast() {
    print_header "Verifying Hazelcast Configuration"
    
    check_source_file
    
    echo -e "${CYAN}Checking:${NC} $SOURCE_FILE\n"
    
    if grep -q "Dvbms.cache.hazelcast.enabled=false" "$SOURCE_FILE"; then
        echo -e "${GREEN}✓ Hazelcast is DISABLED${NC}"
        echo -e "${GREEN}  Found: -Dvbms.cache.hazelcast.enabled=false in javaMemArgs${NC}"
        
        # Show the line
        echo -e "\n${CYAN}Configuration line:${NC}"
        grep "javaMemArgs" "$SOURCE_FILE" | grep --color=always "Dvbms.cache.hazelcast.enabled=false" || \
        grep "javaMemArgs" "$SOURCE_FILE"
    else
        echo -e "${RED}✗ Hazelcast disabled flag NOT FOUND${NC}"
        echo -e "${YELLOW}  This will cause deployment hangs!${NC}"
        echo -e "\n${CYAN}Current javaMemArgs:${NC}"
        grep "javaMemArgs" "$SOURCE_FILE" || echo "  (javaMemArgs not found)"
        echo -e "\n${YELLOW}Recommendation:${NC}"
        echo -e "  Add the following to your javaMemArgs line:"
        echo -e "  ${CYAN}-Dvbms.cache.hazelcast.enabled=false${NC}"
    fi
    
    # Check hazelcast properties
    echo -e "\n${CYAN}Hazelcast server startup:${NC}"
    if grep -q "^hazelcastStartLinux=$" "$SOURCE_FILE"; then
        echo -e "${GREEN}✓ Hazelcast server startup is disabled (empty)${NC}"
    else
        echo -e "${YELLOW}⚠ hazelcastStartLinux may not be empty${NC}"
    fi
}

# Main script logic
case "${1:-}" in
    -h|--help)
        usage
        exit 0
        ;;
    -l|--list)
        list_backups
        exit 0
        ;;
    -r|--restore)
        if [[ -z "${2:-}" ]]; then
            echo -e "${RED}✗ Error: Backup file required${NC}"
            echo -e "${YELLOW}  Usage: $0 --restore <backup-file>${NC}"
            exit 1
        fi
        restore_backup "$2"
        exit 0
        ;;
    -d|--diff)
        if [[ -z "${2:-}" ]]; then
            echo -e "${RED}✗ Error: Backup file required${NC}"
            echo -e "${YELLOW}  Usage: $0 --diff <backup-file>${NC}"
            exit 1
        fi
        show_diff "$2"
        exit 0
        ;;
    --latest)
        show_latest
        exit 0
        ;;
    --verify)
        verify_hazelcast
        exit 0
        ;;
    "")
        # No arguments - create backup
        backup_properties
        exit 0
        ;;
    *)
        echo -e "${RED}✗ Unknown option: $1${NC}"
        usage
        exit 1
        ;;
esac
