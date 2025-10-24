#!/bin/bash

################################################################################
# TTS Manager - Text-to-Speech generation with Gemini API
# Supports MP3/WAV output with error handling and retry logic
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

################################################################################
# Configuration
################################################################################

PROVIDER="gemini"
OUTPUT_DIR="./outputs"
OUTPUT_FORMAT="mp3"
MAX_RETRIES=3

# Gemini Configuration (loaded from .env)
GEMINI_MODEL=""
GEMINI_VOICE="Zephyr"
GEMINI_TEMPERATURE=0.9

# Environment setup
SCRIPTS_DIR="$(dirname "$0")"

################################################################################
# Helper Functions
################################################################################

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Convert audio format using ffmpeg
convert_audio_format() {
    local input_file=$1
    local output_file=$2

    case "${OUTPUT_FORMAT}" in
        "mp3")
            ffmpeg -y -i "$input_file" -codec:a libmp3lame -qscale:a 2 "$output_file" >/dev/null 2>&1
            ;;
        *)
            cp "$input_file" "$output_file"
            ;;
    esac

    if [[ $? -eq 0 ]]; then
        rm -f "$input_file"
        return 0
    else
        return 1
    fi
}

# Generate output filename if not provided
generate_output_filename() {
    local base_name="tts_${PROVIDER}_$(date +%Y%m%d_%H%M%S)"
    echo "${OUTPUT_DIR}/${base_name}.${OUTPUT_FORMAT}"
}

################################################################################
# Gemini TTS Generation
################################################################################

generate_gemini_tts() {
    local output_file=$1
    local text=$2

    # Ensure output directory exists
    mkdir -p "$OUTPUT_DIR"

    # Encode text to base64 to preserve Unicode characters
    local encoded_text=$(echo -n "$text" | base64 -w 0)

    # Generate temporary WAV filename
    local temp_wav_file="temp_gemini_$(date +%s).wav"

    print_info "Generating TTS with Gemini..."

    # Create Python script for TTS generation
    local python_script=$(cat <<'PYTHON'
import os
import sys
import base64
import time
import random
from pathlib import Path

# Add scripts directory to path
scripts_dir = os.environ.get('SCRIPTS_DIR', 'scripts')
sys.path.insert(0, scripts_dir)

def generate_with_retry(tts, text, voice_name, temperature, max_retries=3):
    """Generate TTS with retry logic"""
    for attempt in range(max_retries):
        try:
            if attempt > 0:
                delay = (2 ** attempt) + random.uniform(0, 1)
                print(f"Retry {attempt + 1}/{max_retries}...")
                time.sleep(delay)

            print(f"Attempt {attempt + 1}/{max_retries}")
            filename = tts.generate_speech(
                text=text,
                voice_name=voice_name,
                temperature=temperature
            )

            if filename and Path(filename).exists():
                return filename
            else:
                raise Exception(f"Invalid filename: {filename}")

        except Exception as e:
            print(f"Attempt {attempt + 1} failed: {e}")
            if attempt == max_retries - 1:
                return None

    return None

try:
    from gemini_tts import GeminiTTS

    # Get configuration from environment
    api_key = os.environ.get('GEMINI_API_KEY')
    model = os.environ.get('GEMINI_MODEL', 'gemini-2.5-flash-preview-tts')
    voice_name = os.environ.get('GEMINI_VOICE', 'Zephyr')
    temperature = float(os.environ.get('GEMINI_TEMPERATURE', '0.9'))
    encoded_text = os.environ.get('ENCODED_TEXT')
    output_file = os.environ.get('TEMP_WAV_FILE')

    if not api_key or not encoded_text:
        print("Missing required environment variables")
        sys.exit(1)

    # Decode text
    text = base64.b64decode(encoded_text).decode('utf-8')

    # Initialize TTS
    tts = GeminiTTS(api_key=api_key, model=model)

    # Generate with retry
    result_file = generate_with_retry(
        tts=tts,
        text=text,
        voice_name=voice_name,
        temperature=temperature,
        max_retries=3
    )

    if result_file:
        if output_file and result_file != output_file:
            Path(result_file).rename(output_file)
        print("SUCCESS")
    else:
        print("FAILURE")
        sys.exit(1)

except Exception as e:
    print(f"Fatal error: {e}")
    sys.exit(1)
PYTHON
)

    # Set environment variables for Python script
    export GEMINI_API_KEY="${GEMINI_API_KEY}"
    export GEMINI_MODEL="${GEMINI_MODEL}"
    export GEMINI_VOICE="${GEMINI_VOICE}"
    export GEMINI_TEMPERATURE="${GEMINI_TEMPERATURE}"
    export ENCODED_TEXT="${encoded_text}"
    export TEMP_WAV_FILE="${temp_wav_file}"
    export SCRIPTS_DIR="${SCRIPTS_DIR}"

    # Execute Python script
    if source venv/bin/activate && python3 -c "$python_script"; then
        # Find the generated file
        if [[ -f "$temp_wav_file" ]]; then
            local actual_wav_file="$temp_wav_file"
        else
            actual_wav_file=$(ls -t *.wav 2>/dev/null | head -1)
        fi

        if [[ -n "$actual_wav_file" && -f "$actual_wav_file" ]]; then
            # Convert to requested format if needed
            if [[ "$OUTPUT_FORMAT" != "wav" ]]; then
                if convert_audio_format "$actual_wav_file" "$output_file"; then
                    print_success "Output: $output_file"
                    return 0
                else
                    print_error "Conversion failed"
                    return 1
                fi
            else
                mv "$actual_wav_file" "$output_file"
                print_success "Output: $output_file"
                return 0
            fi
        else
            print_error "No output file found"
            return 1
        fi
    else
        print_error "TTS generation failed"
        return 1
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    local text=""
    local output_file=""

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--text)
                text="$2"
                shift 2
                ;;
            -f|--file)
                if [[ -f "$2" ]]; then
                    text=$(cat "$2")
                else
                    print_error "File not found: $2"
                    exit 1
                fi
                shift 2
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            --format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --voice)
                GEMINI_VOICE="$2"
                shift 2
                ;;
            --temperature)
                GEMINI_TEMPERATURE="$2"
                shift 2
                ;;
            -h|--help)
                cat << EOF
Usage: $0 [OPTIONS]

REQUIRED:
    -t, --text TEXT             Text to convert to speech
    -f, --file FILE             Input text file (alternative to -t)

OPTIONS:
    -o, --output FILE           Output file path (default: auto-generated)
    --format FORMAT             Output format: wav, mp3 (default)
    --voice VOICE               Voice name (default: Zephyr)
    --temperature TEMP          Voice variation 0.0-1.0 (default: 0.9)
    -h, --help                  Show this help message

EXAMPLES:
    $0 -t "Hello world!" --format mp3
    $0 -f script.txt --voice Puck --output my_audio.mp3
EOF
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$text" ]]; then
        print_error "Text is required. Use -t for text or -f for file."
        exit 1
    fi

    # Generate output filename if not provided
    if [[ -z "$output_file" ]]; then
        output_file=$(generate_output_filename)
    fi

    # Load environment variables
    if [[ -f ".env" ]]; then
        source .env
    fi

    # Set defaults from environment
    GEMINI_API_KEY="${GEMINI_API_KEY}"
    GEMINI_MODEL="${GEMINI_TTS_MODEL:-gemini-2.5-flash-preview-tts}"

    print_info "Using model: $GEMINI_MODEL"
    print_info "Voice: $GEMINI_VOICE"
    print_info "Output: $output_file"

    # Generate TTS
    case "$PROVIDER" in
        "gemini")
            if generate_gemini_tts "$output_file" "$text"; then
                print_success "TTS completed successfully!"
                exit 0
            else
                print_error "TTS generation failed"
                exit 1
            fi
            ;;
        *)
            print_error "Unsupported provider: $PROVIDER"
            exit 1
            ;;
    esac
}

# Execute main function with all arguments
main "$@"