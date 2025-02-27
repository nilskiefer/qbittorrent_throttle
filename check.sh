#!/bin/bash
# plex_watch.sh - periodically checks if Plex is actively streaming
# and calls the Python program with --stop if a session is active, or --start if not.

# Ensure required environment variables are set
if [ -z "$PLEX_URL" ] || [ -z "$PLEX_TOKEN" ]; then
  echo "Error: PLEX_URL and PLEX_TOKEN must be set in the environment."
  exit 1
fi

# Use a default check interval (in seconds) if not provided
CHECK_INTERVAL=${CHECK_INTERVAL:-60}
# Use a default Python program name if not provided (assuming the Python file is in the same folder)
PYTHON_SCRIPT=${PYTHON_SCRIPT:-"./throttle.py"}

while true; do
  echo "Checking Plex sessions at $(date)..."
  # Fetch Plex sessions (returns XML)
  response=$(curl -s "$PLEX_URL/status/sessions?X-Plex-Token=$PLEX_TOKEN")
  
  # If the XML contains a <Video> tag, assume something is playing.
  if echo "$response" | grep -q "<Video"; then
    echo "Active Plex session detected – calling stop."
    python3 "$PYTHON_SCRIPT" --stop
  else
    echo "No active Plex session detected – calling start."
    python3 "$PYTHON_SCRIPT" --start
  fi
  
  sleep "$CHECK_INTERVAL"
done
