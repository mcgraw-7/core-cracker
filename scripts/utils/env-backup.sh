#!/bin/zsh
# Script Name: env-backup.sh
# Description: Backup and restore environment configurations
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
readonly BACKUP_DIR="${HOME}/.env-backups"
readonly TIMESTAMP=$(date +%Y%m%d-%H%M%S)
readonly BACKUP_FILE="backup-${TIMESTAMP}.tar.gz"

# Files to backup
typeset -a BACKUP_FILES=(
    "${HOME}/.zshrc"
    "${HOME}/.wljava_env"
    "${HOME}/.bash_profile"
    "${HOME}/.bashrc"
)

# Directories to backup (if they exist)
typeset -a BACKUP_DIRS=(
    "${HOME}/dev/Oracle/Middleware/Oracle_Home/user_projects/domains"
    "${HOME}/dev/standardized-scripts"
)

function usage() {
    cat << EOF
${BLUE}Environment Backup & Restore Tool${NC}

${CYAN}USAGE:${NC}
    $0 [OPTIONS]

${CYAN}OPTIONS:${NC}
    -h, --help              Show this help message
    -l, --list              List available backups
    -r, --restore FILE      Restore from backup file
    -d, --delete FILE       Delete backup file
    --dry-run               Show what would be backed up

${CYAN}EXAMPLES:${NC}
    # Create backup
    $0

    # List backups
    $0 --list

    # Restore from backup
    $0 --restore backup-20251114-120000.tar.gz

    # Dry run (preview)
    $0 --dry-run

${CYAN}BACKUP INCLUDES:${NC}
    - Shell configuration files (~/.zshrc, ~/.bash_profile, etc.)
    - WebLogic Java environment (~/.wljava_env)
    - Domain configurations (if exist)
    - Standardized scripts (if exist)

${CYAN}BACKUP LOCATION:${NC}
    ${BACKUP_DIR}/

EOF
    exit 0
}

function create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        echo "${GREEN}Created backup directory: ${BACKUP_DIR}${NC}"
    fi
}

function list_backups() {
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${BLUE}Available Backups${NC}"
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        echo "${YELLOW}No backups found${NC}"
        echo ""
        echo "Create a backup with: $0"
        exit 0
    fi
    
    local count=0
    for backup in "$BACKUP_DIR"/backup-*.tar.gz; do
        if [ -f "$backup" ]; then
            ((count++))
            local filename=$(basename "$backup")
            local size=$(du -h "$backup" | cut -f1)
            local date=$(echo "$filename" | sed 's/backup-\(.*\)\.tar\.gz/\1/' | sed 's/-/ /')
            
            printf "${GREEN}%-40s${NC} ${CYAN}%8s${NC}  %s\n" "$filename" "$size" "$date"
        fi
    done
    
    echo ""
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "Total backups: $count"
    echo "Location: ${BACKUP_DIR}/"
    echo ""
}

function create_backup() {
    local dry_run=$1
    
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${BLUE}💾 Creating Environment Backup${NC}"
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [ "$dry_run" = true ]; then
        echo "${YELLOW}DRY RUN MODE - No files will be created${NC}"
        echo ""
    fi
    
    # Create temp directory for staging
    local temp_dir=$(mktemp -d)
    local backup_root="${temp_dir}/env-backup"
    mkdir -p "$backup_root"
    
    echo "${CYAN}Files to backup:${NC}"
    
    # Backup individual files
    for file in "${BACKUP_FILES[@]}"; do
        if [ -f "$file" ]; then
            echo "  ${GREEN}${NC} $(basename "$file")"
            if [ "$dry_run" = false ]; then
                local file_dir=$(dirname "$file")
                mkdir -p "${backup_root}${file_dir}"
                cp "$file" "${backup_root}${file}"
            fi
        else
            echo "  ${YELLOW}${NC}  $(basename "$file") (not found, skipping)"
        fi
    done
    
    echo ""
    echo "${CYAN}Directories to backup:${NC}"
    
    # Backup directories
    for dir in "${BACKUP_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            local dir_name=$(basename "$dir")
            echo "  ${GREEN}${NC} ${dir_name}/"
            if [ "$dry_run" = false ]; then
                local parent_dir=$(dirname "$dir")
                mkdir -p "${backup_root}${parent_dir}"
                cp -r "$dir" "${backup_root}${dir}"
            fi
        else
            echo "  ${YELLOW}${NC}  $(basename "$dir")/ (not found, skipping)"
        fi
    done
    
    if [ "$dry_run" = true ]; then
        echo ""
        echo "${YELLOW}Would create: ${BACKUP_DIR}/${BACKUP_FILE}${NC}"
        rm -rf "$temp_dir"
        exit 0
    fi
    
    # Create backup directory
    create_backup_dir
    
    # Create tarball
    echo ""
    echo "${CYAN}Creating backup archive...${NC}"
    
    cd "$temp_dir"
    tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" env-backup/ 2>/dev/null
    
    if [ $? -eq 0 ]; then
        local backup_size=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}" | cut -f1)
        echo "${GREEN}Backup created successfully${NC}"
        echo ""
        echo "  File: ${BACKUP_FILE}"
        echo "  Size: ${backup_size}"
        echo "  Location: ${BACKUP_DIR}/"
        echo ""
        echo "${CYAN}To restore this backup:${NC}"
        echo "  $0 --restore ${BACKUP_FILE}"
    else
        echo "${RED}Failed to create backup${NC}"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
    
    echo ""
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

function restore_backup() {
    local backup_file=$1
    
    # Check if backup file exists
    if [ ! -f "${BACKUP_DIR}/${backup_file}" ]; then
        echo "${RED}Backup file not found: ${backup_file}${NC}"
        echo ""
        echo "Available backups:"
        list_backups
        exit 1
    fi
    
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${BLUE}🔄 Restoring Environment Backup${NC}"
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Confirm restoration
    echo "${YELLOW}This will overwrite your current environment configuration!${NC}"
    echo ""
    echo "Backup to restore: ${backup_file}"
    echo ""
    read "response?Continue? [y/N] "
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "${YELLOW}Restoration cancelled${NC}"
        exit 0
    fi
    
    # Create temp directory
    local temp_dir=$(mktemp -d)
    
    # Extract backup
    echo ""
    echo "${CYAN}Extracting backup...${NC}"
    tar -xzf "${BACKUP_DIR}/${backup_file}" -C "$temp_dir"
    
    if [ $? -ne 0 ]; then
        echo "${RED}Failed to extract backup${NC}"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Restore files
    echo "${CYAN}Restoring files...${NC}"
    
    if [ -d "${temp_dir}/env-backup" ]; then
        cd "${temp_dir}/env-backup"
        
        # Restore each file/directory
        for item in $(find . -type f -o -type d); do
            if [ "$item" != "." ]; then
                local target="${item#.}"
                local target_dir=$(dirname "$target")
                
                # Create parent directory if needed
                if [ ! -d "$target_dir" ]; then
                    mkdir -p "$target_dir"
                fi
                
                # Copy file or directory
                if [ -f "$item" ]; then
                    cp "$item" "$target"
                    echo "  ${GREEN}${NC} Restored: $target"
                elif [ -d "$item" ] && [ "$item" != "." ]; then
                    cp -r "$item" "$target"
                    echo "  ${GREEN}${NC} Restored: ${target}/"
                fi
            fi
        done
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
    
    echo ""
    echo "${GREEN}Restore completed successfully${NC}"
    echo ""
    echo "${CYAN}Next steps:${NC}"
    echo "  1. Reload shell configuration: source ~/.zshrc"
    echo "  2. Verify environment: ./setup.sh --auto"
    echo ""
    echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

function delete_backup() {
    local backup_file=$1
    
    if [ ! -f "${BACKUP_DIR}/${backup_file}" ]; then
        echo "${RED}Backup file not found: ${backup_file}${NC}"
        exit 1
    fi
    
    echo "${YELLOW}Delete backup: ${backup_file}?${NC}"
    read "response?Continue? [y/N] "
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        rm "${BACKUP_DIR}/${backup_file}"
        echo "${GREEN}Backup deleted${NC}"
    else
        echo "${YELLOW}Deletion cancelled${NC}"
    fi
}

# Parse arguments
DRY_RUN=false
ACTION="backup"
RESTORE_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -l|--list)
            ACTION="list"
            shift
            ;;
        -r|--restore)
            ACTION="restore"
            RESTORE_FILE="$2"
            shift 2
            ;;
        -d|--delete)
            ACTION="delete"
            RESTORE_FILE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Execute action
case $ACTION in
    list)
        list_backups
        ;;
    restore)
        if [ -z "$RESTORE_FILE" ]; then
            echo "${RED}No backup file specified${NC}"
            usage
        fi
        restore_backup "$RESTORE_FILE"
        ;;
    delete)
        if [ -z "$RESTORE_FILE" ]; then
            echo "${RED}No backup file specified${NC}"
            usage
        fi
        delete_backup "$RESTORE_FILE"
        ;;
    backup)
        create_backup $DRY_RUN
        ;;
esac
