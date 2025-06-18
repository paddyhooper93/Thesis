#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 '<command>'"
    echo "Example: $0 'ls -l /nonexistent'"
    exit 1
}

# Ensure a command is provided as an argument
if [ $# -ne 1 ]; then
    usage
fi

COMMAND="$1"

# Execute the command and capture its exit status
eval "$COMMAND"
EXIT_STATUS=$?

# Check if the command was successful
if [ $EXIT_STATUS -eq 1 ]; then
    echo "Command failed with exit status $EXIT_STATUS."
fi

exit $EXIT_STATUS
