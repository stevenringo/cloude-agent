#!/bin/bash
# Ensure workspace and skills directories exist and are writable
# Railway volumes mount as root, so we need to fix permissions

WORKSPACE_DIR="${WORKSPACE_DIR:-/app/workspace}"
SKILLS_DIR="${SKILLS_DIR:-$WORKSPACE_DIR/.claude/skills}"

# Create directories if they don't exist
mkdir -p "$WORKSPACE_DIR"
mkdir -p "$SKILLS_DIR"

# Make all skill scripts executable
find "$SKILLS_DIR" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
find "$SKILLS_DIR" -name "*.py" -exec chmod +x {} \; 2>/dev/null || true

# If we're root, change ownership to appuser
if [ "$(id -u)" = "0" ]; then
    chown -R appuser:appuser "$WORKSPACE_DIR"
    # Run the app as appuser
    exec su appuser -c "uvicorn main:app --host 0.0.0.0 --port ${PORT:-8080}"
else
    # Already running as appuser
    exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8080}
fi


