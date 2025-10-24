#!/bin/bash

################################################################################
# TTS Quick Runner - Wrapper для tts-manager.sh с автоматической активацией venv
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Активировать venv
source "$SCRIPT_DIR/venv/bin/activate"

# Загрузить .env
export $(cat "$SCRIPT_DIR/.env" | grep -v '^#' | xargs)

# Запустить tts-manager
"$SCRIPT_DIR/scripts/tts-manager.sh" "$@"
