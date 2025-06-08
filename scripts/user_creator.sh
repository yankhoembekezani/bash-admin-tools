#!/bin/bash

# Constants
readonly DEFAULT_PASSWORD="Welcome123!"     # Default password for new users
readonly LOG_FILE="./user_creator.log"      # Log file for activity and errors

# Functions

# Logs messages with timestamps
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Prints usage and exits
print_usage() {
  echo "Usage: $0 username [--dry-run]"
  exit 1
}

# Validates that the username is not empty and follows system standards
validate_username() {
  if [[ -z "$username" ]]; then
    echo "Error: No username provided."
    print_usage
  fi

# Enforce valid usernames
  if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Error: Invalid username format."
    log "Invalid username: $username"
    exit 1
  fi
}

# Creates a new system user, assigns a password, and adds them to the sudo group
create_user() {
  # Check if user already exists
  if id "$username" &>/dev/null; then
    echo "User '$username' already exists."
    log "Attempted to create existing user: $username"
    exit 1
  fi

  # Handle dry-run logic
  if [ "$dry_run" = true ]; then
    echo "[Dry-run] Would create user '$username' with password '$DEFAULT_PASSWORD' and add to sudo group."
    log "[Dry-run] Skipped user creation for $username"
  else
    useradd -m "$username"
    echo "$username:$DEFAULT_PASSWORD" | chpasswd
    usermod -aG sudo "$username"
    echo "User '$username' created and added to sudo group."
    log "User $username created with default password and added to sudo"
  fi
}

# Main Script Execution

# Parse arguments
username="$1"
dry_run=false

if [[ "$2" == "--dry-run" ]]; then
  dry_run=true
fi

# Run logic
validate_username
create_user

