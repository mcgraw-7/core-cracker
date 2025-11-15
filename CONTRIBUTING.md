# Contributing to core-cracker

Thank you for your interest in contributing! This document provides guidelines and best practices for contributing to the VA Core local development environment toolkit.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Script Guidelines](#script-guidelines)
- [Testing](#testing)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)

## Code of Conduct

This project follows a professional code of conduct:

- Be respectful and inclusive
- Focus on what is best for the community
- Show empathy towards other contributors
- Accept constructive criticism gracefully
- Collaborate openly and transparently

## Getting Started

### Prerequisites

- macOS (Apple Silicon or Intel)
- Git installed
- Basic knowledge of shell scripting (zsh)
- Understanding of Java/WebLogic development environment

### Fork and Clone

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/core-cracker.git
cd core-cracker

# Add upstream remote
git remote add upstream https://github.com/mcgraw-7/core-cracker.git
```

### Set Up Development Environment

```bash
# Make all scripts executable
chmod +x setup.sh scripts/**/*.sh

# Run initial verification
./setup.sh --auto
```

## Development Workflow

### Branch Naming

Use descriptive branch names:

```
feature/add-health-check-script
bugfix/fix-java-version-detection
docs/update-readme-examples
refactor/improve-error-handling
```

### Commit Messages

Follow conventional commit format:

```
type(scope): short description

Longer description if needed

- Bullet points for details
- Another detail

Fixes #123
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `style:` - Code style changes (formatting, no logic change)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

**Examples:**
```bash
git commit -m "feat(utils): add health-check.sh script

- Check Java installation
- Verify WebLogic status
- Validate environment variables
- Display system resources"

git commit -m "fix(setup): correct path in Oracle directory check

The path was checking /usr/local instead of user home directory.

Fixes #42"

git commit -m "docs(readme): add Apple Silicon setup instructions"
```

## Coding Standards

### Shell Script Standards

#### Shebang

Always use zsh:

```bash
#!/bin/zsh
```

#### Script Header

Include descriptive header:

```bash
#!/bin/zsh
# Script Name: health-check.sh
# Description: Comprehensive system health diagnostic
# Author: Your Name
# Date: 2025-11-14
# Version: 1.0
```

#### Color Codes

Use consistent color coding:

```bash
# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Usage
echo "${GREEN}[PASS] Success${NC}"
echo "${RED}[FAIL] Error${NC}"
echo "${YELLOW}[WARN]  Warning${NC}"
echo "${BLUE}[INFO]  Info${NC}"
```

#### Error Handling

Always handle errors:

```bash
# Check if file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "${RED}[FAIL] Configuration file not found: $CONFIG_FILE${NC}"
    exit 1
fi

# Check command success
if ! command -v java >/dev/null 2>&1; then
    echo "${RED}[FAIL] Java not found in PATH${NC}"
    exit 2
fi
```

#### Variables

```bash
# Use uppercase for constants
readonly ORACLE_JDK="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk"
readonly MIN_DISK_SPACE_GB=10

# Use lowercase for local variables
local script_dir=$(dirname "$0")
local timestamp=$(date +%Y%m%d_%H%M%S)

# Quote all variable references
echo "Java Home: ${JAVA_HOME}"
cd "${script_dir}" || exit 1
```

#### Functions

```bash
# Function naming: lowercase with underscores
function check_java_version() {
    local java_version=$("${JAVA_HOME}/bin/java" -version 2>&1 | head -n 1)
    
    if [[ "$java_version" == *"1.8.0_202"* ]]; then
        echo "${GREEN}[PASS] Java version correct${NC}"
        return 0
    else
        echo "${RED}[FAIL] Java version incorrect${NC}"
        return 1
    fi
}

# Always use local variables in functions
function calculate_disk_space() {
    local disk_usage=$(df -h / | tail -1 | awk '{print $4}')
    echo "$disk_usage"
}
```

#### Exit Codes

Use standard exit codes:

```bash
# 0 - Success
exit 0

# 1 - General error
exit 1

# 2 - Misuse of command
exit 2

# 130 - Terminated by Ctrl+C
trap 'exit 130' INT
```

### Code Style

#### Indentation

- Use 4 spaces (no tabs)
- Indent continuation lines

```bash
if [ -f "$CONFIG_FILE" ] && \
   [ -r "$CONFIG_FILE" ] && \
   [ -s "$CONFIG_FILE" ]; then
    echo "Config file valid"
fi
```

#### Line Length

- Maximum 100 characters per line
- Break long commands with backslash

```bash
docker run --rm -it \
    --platform linux/amd64 \
    -v "${PWD}:/workspace" \
    oraclelinux:8 \
    /bin/bash
```

#### Spacing

```bash
# Spaces around operators
if [ "$count" -gt 10 ]; then
    total=$((count + 5))
fi

# No spaces in variable assignment
name="value"
```

## Script Guidelines

### Script Structure

```bash
#!/bin/zsh
# Script header with metadata

# Set strict error handling
set -euo pipefail

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Constants
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly ORACLE_JDK="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk"

# Functions
function usage() {
    cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Verbose output
    --dry-run       Show what would be done
    
EXAMPLES:
    $0 --verbose
    $0 --dry-run

EOF
    exit 0
}

function main() {
    # Main logic here
    echo "${BLUE}Starting check...${NC}"
    
    # Your code
    
    echo "${GREEN}[PASS] Complete${NC}"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            echo "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Run main function
main
```

### Input Validation

```bash
function validate_java_home() {
    if [ -z "${JAVA_HOME:-}" ]; then
        echo "${RED}[FAIL] JAVA_HOME not set${NC}"
        return 1
    fi
    
    if [ ! -d "$JAVA_HOME" ]; then
        echo "${RED}[FAIL] JAVA_HOME directory does not exist: $JAVA_HOME${NC}"
        return 1
    fi
    
    if [ ! -x "${JAVA_HOME}/bin/java" ]; then
        echo "${RED}[FAIL] Java executable not found or not executable${NC}"
        return 1
    fi
    
    return 0
}
```

### Output Formatting

```bash
# Use consistent symbols
[PASS] # Success
[FAIL] # Error
[WARN] # Warning
[INFO] # Info
[SCAN] # Searching/Analyzing
[SAVE] # Backup/Save
[FIX]  # Fix/Tool
[HLTH] # Health Check

# Use separators for sections
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "System Health Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Align output
printf "%-30s %s\n" "Java Version:" "${GREEN}[PASS] PASS${NC}"
printf "%-30s %s\n" "WebLogic Status:" "${RED}[FAIL] FAIL${NC}"
```

## Testing

### Manual Testing

Before submitting:

```bash
# Test on clean shell
zsh -c './setup.sh --auto'

# Test individual scripts
./scripts/utils/health-check.sh
./scripts/utils/verify-standardization.sh

# Test with different environments
unset JAVA_HOME
./scripts/utils/java-check.sh
```

### Test Checklist

- [ ] Script runs without errors
- [ ] Color output displays correctly
- [ ] Error messages are clear and actionable
- [ ] Exit codes are correct
- [ ] Works on both Apple Silicon and Intel
- [ ] Handles missing dependencies gracefully
- [ ] Doesn't modify files unexpectedly
- [ ] Logs are created if applicable

### Edge Cases to Test

```bash
# Missing environment variables
unset JAVA_HOME MW_HOME

# Non-existent directories
export JAVA_HOME="/non/existent/path"

# Read-only directories
# Insufficient permissions

# Empty values
export JAVA_HOME=""

# Special characters in paths
```

## Documentation

### Code Comments

```bash
# Use comments to explain WHY, not WHAT

# Good
# Oracle JDK must be at this specific path for WebLogic compatibility
readonly ORACLE_JDK="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk"

# Bad
# Set Oracle JDK path
readonly ORACLE_JDK="$HOME/Library/Java/JavaVirtualMachines/zulu-8-arm.jdk"
```

### Documentation Updates

When adding new scripts:

1. Update `docs/script-reference.md`
2. Add to `README.md` if user-facing
3. Update menu in `setup.sh` if needed
4. Add usage examples

### README Format

```markdown
### `script-name.sh`

Brief one-line description.

**Location:** `scripts/utils/`

**Purpose:**
- What it does
- Why it's needed

**Usage:**
```bash
./scripts/utils/script-name.sh [options]
```

**Options:**
| Flag | Description |
|------|-------------|
| `--help` | Show help |

**Example:**
```bash
./scripts/utils/script-name.sh --verbose
```
```

## Submitting Changes

### Pull Request Process

1. **Update your fork:**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Create feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make changes and commit:**
   ```bash
   git add .
   git commit -m "feat(scope): description"
   ```

4. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create Pull Request:**
   - Go to GitHub
   - Click "New Pull Request"
   - Select your branch
   - Fill out template

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring
- [ ] Performance improvement

## Testing
- [ ] Tested on Apple Silicon Mac
- [ ] Tested on Intel Mac
- [ ] Added/updated tests
- [ ] All existing tests pass

## Checklist
- [ ] Code follows style guidelines
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Scripts are executable (chmod +x)

## Screenshots (if applicable)
```

### Review Process

1. Automated checks must pass
2. At least one approving review required
3. All comments must be addressed
4. Squash commits if requested
5. Keep commits focused and atomic

### After Merge

```bash
# Update your local main branch
git checkout main
git pull upstream main

# Delete feature branch
git branch -d feature/your-feature-name
git push origin --delete feature/your-feature-name
```

## Questions?

- Open an issue for bugs
- Start a discussion for questions
- Tag maintainers for urgent issues

Thank you for contributing! 🎉
