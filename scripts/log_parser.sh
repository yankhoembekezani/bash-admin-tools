#!/bin/bash

# log parser 

echo "Searching for 'error' in /var/log/syslog..."

grep -i "error" /var/log/syslog | tail -n 20

echo "Finished showing last 20 errors."

