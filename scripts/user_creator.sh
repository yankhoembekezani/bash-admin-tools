#!/bin/bash

# User creation script with dry-run mode and logging

username=$1
dry_run=false
log_file="./user_creator.log"

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

# Check for dry-run 
if [[ "$2" == "--dry-run" ]]; then
  dry_run=true
fi

# Logging function
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$log_file"
}

# Check if username is provided
if [ -z "$username" ]; then
  log "No username provided."
  echo "Usage: sudo ./user_creator.sh <username> [--dry-run]"
  exit 1
fi

# Check if user already exists
if id "$username" &>/dev/null; then
  log "User '$username' already exists."
  exit 1
fi

# Main creation
if [ "$dry_run" = true ]; then
  log "[Dry-run] Would create user '$username', set password, and add to sudo group."
else
  useradd -m "$username"
  echo "$username:Welcome123!" | chpasswd
  usermod -aG sudo "$username"
  log "User '$username' created and added to sudo group with password 'Welcome123!'."
fi

