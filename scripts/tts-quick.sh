#!/bin/bash

################################################################################
# TTS Quick Runner - Wrapper для tts-manager.sh с автоматической активацией venv
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Активировать venv
if [ -d "$PROJECT_ROOT/.venv" ]; then
    source "$PROJECT_ROOT/.venv/bin/activate"
elif [ -d "$PROJECT_ROOT/venv" ]; then
    source "$PROJECT_ROOT/venv/bin/activate"
else
    echo "Error: No virtual environment found. Run: uv venv && uv pip install -r requirements.txt"
    exit 1
fi

# Загрузить .env
export $(cat "$PROJECT_ROOT/.env" | grep -v '^#' | xargs)

# Запустить tts-manager
"$SCRIPT_DIR/tts-manager.sh" "$@"
