#!/bin/bash

echo "Cleaning up /tmp directory..."

# Save log before cleanup
ls /tmp > ~/cleanup_before.txt

# Remove files older than 2 days
find /tmp -type f -mtime +2 -exec rm -f {} \;

echo "Cleanup done. Files older than 2 days removed."

