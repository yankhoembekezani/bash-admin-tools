#!/bin/bash
# capturing username

username=$1

if [ "$username" == "" ]; then
  echo "No username provided. Example usage: ./user_creator.sh testuser"
  exit 1
fi

# adding user
useradd -m "$username"
echo "$username:Welcome123!" | chpasswd
usermod -aG sudo "$username"

echo "User $username created with password 'Welcome123!' and added to sudo group"

