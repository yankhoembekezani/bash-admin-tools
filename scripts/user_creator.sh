#!/usr/bin/env bash

# Constants
readonly DEFAULT_PASSWORD="Welcome123!"
readonly LOG_FILE="./user_creator.log"

# Functions

# Logs messages with timestamps
log() {
  if ! touch "$LOG_FILE" &>/dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] Cannot write to log file: $LOG_FILE" >&2
    exit 99
  fi
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Prints usage and exits
print_usage() {
  echo "Usage: $0 username [--dry-run | --random-password]"
  exit 1
}

# Validates that the username is not empty and follows system standards
validate_username() {
  if [[ -z "$username" ]]; then
    echo "Error: No username provided."
    print_usage
  fi

  if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Error: Invalid username format."
    log "Invalid username: $username"
    exit 1
  fi
}

# Generates a secure random password
generate_secure_password() {
  openssl rand -base64 16
}

# Creates a new system user
create_user() {
  if id "$username" &>/dev/null; then
    echo "User '$username' already exists."
    log "Attempted to create existing user: $username"
    exit 2
  fi

  if [ "$dry_run" = true ]; then
    echo "[Dry-run] Would create user '$username' and add to sudo group"
    log "[Dry-run] Skipped user creation for $username (password masked)"
    return
  fi

  if ! useradd -m "$username"; then
    echo "Error: Failed to create user '$username'"
    log "Failed to create user $username"
    exit 3
  fi

  # Set password
  if [ "$random_password" = true ]; then
    user_password=$(generate_secure_password)
    echo "Generated password for '$username': $user_password"
    log "Secure password generated for $username (password not logged)"
  else
    user_password="$DEFAULT_PASSWORD"
    log "Using default password for $username (masked)"
  fi

  if ! echo "$username:$user_password" | chpasswd; then
    echo "Error: Failed to set password for '$username'"
    log "Password set failed for $username"
    exit 4
  fi

  if ! usermod -aG sudo "$username"; then
    echo "Error: Failed to add '$username' to sudo group"
    log "Group assignment failed for $username"
    exit 5
  fi

  # Final verification
  if ! id "$username" &>/dev/null; then
    echo "Error: User '$username' creation verification failed."
    log "Post-creation check failed for $username"
    exit 6
  fi

  echo "User '$username' created and added to sudo group."
  log "User $username successfully created and added to sudo group"
}

# Main Script Execution

# Parse arguments
username="$1"
dry_run=false
random_password=false

case "$2" in
  --dry-run)
    dry_run=true
    ;;
  --random-password)
    random_password=true
    ;;
  "")
    ;;
  *)
    echo "Error: Invalid option '$2'"
    print_usage
    ;;
esac

# Must be run as root
if [[ $EUID -ne 0 ]]; then
  echo "Error: This script must be run as root." >&2
  log "Execution failed: not run as root"
  exit 1
fi

# Run logic
validate_username
create_user

