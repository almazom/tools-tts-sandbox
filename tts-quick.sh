#!/bin/bash

################################################################################
# TTS Quick Runner - Wrapper для tts-manager.sh с автоматической активацией venv
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Активировать venv
if [ -d "$SCRIPT_DIR/.venv" ]; then
    source "$SCRIPT_DIR/.venv/bin/activate"
elif [ -d "$SCRIPT_DIR/venv" ]; then
    source "$SCRIPT_DIR/venv/bin/activate"
else
    echo "Error: No virtual environment found. Run: uv venv && uv pip install -r requirements.txt"
    exit 1
fi

# Загрузить .env
export $(cat "$SCRIPT_DIR/.env" | grep -v '^#' | xargs)

# Запустить tts-manager
"$SCRIPT_DIR/scripts/tts-manager.sh" "$@"
