#!/bin/bash

################################################################################
# TTS Manager - Universal Text-to-Speech Script for Podcast Generation
# Supports: Gemini API and MiniMax API
# Author: Auto-generated
# Date: 2025-10-24
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

################################################################################
# Default Configuration
################################################################################

PROVIDER="gemini"           # Default provider: gemini or minimax
NUM_SPEAKERS=1              # Number of speakers: 1 or 2
OUTPUT_DIR="./outputs"      # Output directory
OUTPUT_FORMAT="mp3"         # Output format

# Gemini Configuration
GEMINI_MODEL="gemini-2.5-pro-preview-tts"  # or gemini-2.5-flash-tts
GEMINI_VOICE_1="Zephyr"     # Default voice for speaker 1
GEMINI_VOICE_2="Puck"       # Default voice for speaker 2
GEMINI_TEMPERATURE=0.9      # Voice variation (0.0-1.0)
GEMINI_STYLE=""             # Natural language style prompt
GEMINI_TONE=""              # Tone description
GEMINI_PACE="normal"        # slow, normal, fast
GEMINI_EMOTION=""           # Emotional delivery description

# MiniMax Configuration
MINIMAX_MODEL="speech-02-hd"  # speech-02-hd, speech-02-turbo, speech-01-hd, speech-01-turbo
MINIMAX_VOICE_ID=""         # Voice ID or cloned voice ID
MINIMAX_SPEED=1.0           # Speed: 0.5-2.0
MINIMAX_VOLUME=1.0          # Volume: 0.0-2.0
MINIMAX_PITCH=0             # Pitch: -12 to 12
MINIMAX_EMOTION="neutral"   # happy, sad, angry, fearful, disgusted, surprised, neutral
MINIMAX_SAMPLE_RATE=24000   # 8000, 16000, 22050, 24000, 32000, 44100
MINIMAX_BITRATE=128000      # 64000-320000
MINIMAX_LANGUAGE_BOOST="auto" # auto or language code

# Input
INPUT_TEXT=""
INPUT_FILE=""

################################################################################
# Available Voices
################################################################################

GEMINI_VOICES=(
    "Zephyr"    # Natural, conversational
    "Puck"      # Friendly, engaging
    "Charon"    # Professional, authoritative
    "Kore"      # Warm, approachable
    "Uranus"    # Distinctive, memorable
    "Fenrir"    # Strong, dramatic
    "Aoede"     # Musical, lyrical
    "Leda"      # Elegant, refined
    "Orus"      # Deep, commanding
)

MINIMAX_EMOTIONS=(
    "neutral"
    "happy"
    "sad"
    "angry"
    "fearful"
    "disgusted"
    "surprised"
)

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║           TTS Manager - Podcast Generation Tool               ║"
    echo "║              Gemini API & MiniMax API Support                  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo -e "${BLUE}━━━ $1 ━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ Error: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ Warning: $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

show_usage() {
    cat << EOF

Usage: $0 [OPTIONS]

REQUIRED:
    -t, --text TEXT             Text to convert to speech
    -f, --file FILE             Input text file (alternative to -t)

PROVIDER OPTIONS:
    -p, --provider PROVIDER     TTS provider: gemini (default) or minimax
    -s, --speakers NUM          Number of speakers: 1 (default) or 2
                                Note: MiniMax only supports 1 speaker

GEMINI OPTIONS (when --provider=gemini):
    --model MODEL               Model: gemini-2.5-pro-preview-tts (default)
                                       gemini-2.5-flash-tts
    --voice-1 VOICE             Voice for speaker 1 (default: Zephyr)
    --voice-2 VOICE             Voice for speaker 2 (default: Puck)
                                Available: ${GEMINI_VOICES[*]}
    --temperature TEMP          Voice variation 0.0-1.0 (default: 0.9)
    --style DESCRIPTION         Natural language style prompt
                                Example: "conversational and friendly"
    --tone DESCRIPTION          Tone description
                                Example: "warm and professional"
    --pace PACE                 Speaking pace: slow, normal (default), fast
    --emotion DESCRIPTION       Emotional delivery description
                                Example: "enthusiastic and energetic"

MINIMAX OPTIONS (when --provider=minimax):
    --model MODEL               Model: speech-02-hd (default), speech-02-turbo,
                                       speech-01-hd, speech-01-turbo
    --voice-id ID               Voice ID or cloned voice ID
    --speed SPEED               Speed: 0.5-2.0 (default: 1.0)
    --volume VOLUME             Volume: 0.0-2.0 (default: 1.0)
    --pitch PITCH               Pitch: -12 to 12 (default: 0)
    --emotion EMOTION           Emotion: ${MINIMAX_EMOTIONS[*]}
                                (default: neutral)
    --sample-rate RATE          Sample rate: 8000, 16000, 22050, 24000 (default),
                                            32000, 44100
    --bitrate BITRATE           Bitrate: 64000-320000 (default: 128000)
    --language-boost LANG       Language boost: auto (default) or language code

MULTI-SPEAKER FORMAT (for 2 speakers):
    Use format: "Speaker 1: Text here\nSpeaker 2: More text"
    Example: "Host: Welcome to the show!\nGuest: Thanks for having me!"

OUTPUT OPTIONS:
    -o, --output FILE           Output file path (default: auto-generated)
    --output-dir DIR            Output directory (default: ./outputs)
    --format FORMAT             Output format: wav (default), mp3, flac

OTHER OPTIONS:
    -h, --help                  Show this help message
    -v, --verbose               Verbose output
    --dry-run                   Show configuration without generating

EXAMPLES:

    # Single speaker with Gemini (default)
    $0 -t "Hello world!" --voice-1 Zephyr

    # Two speakers podcast with Gemini
    $0 -t "Host: Welcome!\nGuest: Thanks!" -s 2 --voice-1 Zephyr --voice-2 Puck

    # MiniMax with emotion and style
    $0 -p minimax -t "Hello world!" --emotion happy --speed 1.2

    # Gemini with custom style and tone
    $0 -t "Welcome to our podcast" --style "warm and conversational" \\
       --tone "friendly and professional" --pace normal

    # From text file with custom output
    $0 -f script.txt -s 2 -o my_podcast.wav

EOF
}

validate_gemini_voice() {
    local voice=$1
    for v in "${GEMINI_VOICES[@]}"; do
        if [[ "$v" == "$voice" ]]; then
            return 0
        fi
    done
    return 1
}

validate_minimax_emotion() {
    local emotion=$1
    for e in "${MINIMAX_EMOTIONS[@]}"; do
        if [[ "$e" == "$emotion" ]]; then
            return 0
        fi
    done
    return 1
}

check_dependencies() {
    local missing_deps=()

    if [[ "$PROVIDER" == "gemini" ]]; then
        if ! command -v python3 &> /dev/null; then
            missing_deps+=("python3")
        fi

        # Check if google-genai is installed
        if ! python3 -c "import google.genai" &> /dev/null; then
            missing_deps+=("google-genai (pip install google-genai)")
        fi
    elif [[ "$PROVIDER" == "minimax" ]]; then
        if ! command -v curl &> /dev/null; then
            missing_deps+=("curl")
        fi
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        exit 1
    fi
}

check_api_keys() {
    if [[ "$PROVIDER" == "gemini" ]]; then
        if [[ -z "$GEMINI_API_KEY" ]]; then
            print_error "GEMINI_API_KEY environment variable not set"
            echo "Please set it in .env file or export it:"
            echo "  export GEMINI_API_KEY='your-api-key'"
            exit 1
        fi
    elif [[ "$PROVIDER" == "minimax" ]]; then
        if [[ -z "$MINIMAX_API_KEY" ]]; then
            print_error "MINIMAX_API_KEY environment variable not set"
            echo "Please set it in .env file or export it:"
            echo "  export MINIMAX_API_KEY='your-api-key'"
            exit 1
        fi
    fi
}

################################################################################
# Audio Format Conversion
################################################################################

convert_audio_format() {
    local input_file=$1
    local target_filename=$2

    print_info "Converting $input_file to $target_filename"

    # Check if ffmpeg is available
    if ! command -v ffmpeg &> /dev/null; then
        print_warning "ffmpeg not found. Installing audio conversion dependencies..."
        apt update && apt install -y ffmpeg 2>/dev/null || {
            print_error "Could not install ffmpeg. Please install manually: apt install ffmpeg"
            return 1
        }
    fi

    # Check if input file exists
    if [[ ! -f "$input_file" ]]; then
        print_error "Input file not found: $input_file"
        return 1
    fi

    # Determine target format from filename
    local target_format="${target_filename##*.}"

    print_section "Converting to $target_format format"

    case "$target_format" in
        "mp3")
            ffmpeg -y -i "$input_file" -codec:a libmp3lame -q:a 2 "$target_filename" 2>/dev/null
            ;;
        "flac")
            ffmpeg -y -i "$input_file" -c:a flac "$target_filename" 2>/dev/null
            ;;
        *)
            print_warning "Unsupported format: $target_format. Keeping original format."
            return 0
            ;;
    esac

    if [[ $? -eq 0 && -f "$target_filename" ]]; then
        # Remove original WAV file
        rm -f "$input_file"

        print_success "Successfully converted to $target_format format"
        print_info "New file: $target_filename"
    else
        print_error "Audio conversion failed"
        rm -f "$target_filename"
        return 1
    fi
}

################################################################################
# Gemini TTS Generation
################################################################################

generate_gemini_tts() {
    print_section "Generating with Gemini TTS"

    local output_file=$1
    local text=$2

    # Encode text to base64 to preserve Unicode characters
    local encoded_text=$(echo -n "$text" | base64 -w 0)

    # Build Python script for Gemini TTS
    local python_script=$(cat <<PYTHON
import os
import sys
import base64
from pathlib import Path

# Add scripts directory to path
scripts_dir = '${SCRIPTS_DIR}'
sys.path.insert(0, scripts_dir)

from gemini_tts import GeminiTTS

# Initialize TTS
tts = GeminiTTS(
    api_key='${GEMINI_API_KEY}',
    model='${GEMINI_MODEL}'
)

# Configuration - decode base64 text to preserve Unicode
encoded_text = '${encoded_text}'
text = base64.b64decode(encoded_text).decode('utf-8')

# Always generate WAV first, then convert if needed
original_output_file = '${output_file}'
if original_output_file.endswith('.mp3') or original_output_file.endswith('.flac'):
    output_file = original_output_file.rsplit('.', 1)[0] + '.wav'
else:
    output_file = original_output_file

num_speakers = ${NUM_SPEAKERS}

try:
    if num_speakers == 1:
        print("Generating single speaker audio...")
        tts.generate_speech(
            text=text,
            voice_name='${GEMINI_VOICE_1}',
            output_file=output_file,
            temperature=${GEMINI_TEMPERATURE}
        )
    else:
        print("Generating multi-speaker audio...")
        # Parse speaker mappings
        speakers = {
            'Speaker 1': '${GEMINI_VOICE_1}',
            'Speaker 2': '${GEMINI_VOICE_2}',
            'Host': '${GEMINI_VOICE_1}',
            'Guest': '${GEMINI_VOICE_2}'
        }
        speaker_list = [
            {'speaker': k, 'voice': v}
            for k, v in speakers.items()
        ]
        tts.generate_podcast_interview(
            script=text,
            speaker_configs=speaker_list,
            output_file=output_file,
            temperature=${GEMINI_TEMPERATURE}
        )

    print(f"✓ Audio generated successfully: {output_file}")

except Exception as e:
    print(f"✗ Error: {str(e)}", file=sys.stderr)
    sys.exit(1)
PYTHON
)

    # Execute Python script and capture the actual output filename
    python3 -c "$python_script"
    local actual_wav_file=$(ls -t *.wav 2>/dev/null | head -1)

    if [[ $? -eq 0 ]]; then
        print_success "Gemini TTS generation completed"

        # Convert to requested format if needed
        if [[ "$OUTPUT_FORMAT" != "wav" && -n "$actual_wav_file" ]]; then
            local target_filename="${OUTPUT_FILE}"

            print_info "Converting WAV file: $actual_wav_file to target: $target_filename"
            convert_audio_format "$actual_wav_file" "$target_filename"

            # Update output_file to point to the converted file
            output_file="$target_filename"
        else
            output_file="$actual_wav_file"
        fi

        print_info "Output: $output_file"
    else
        print_error "Gemini TTS generation failed"
        exit 1
    fi
}

################################################################################
# MiniMax TTS Generation
################################################################################

generate_minimax_tts() {
    print_section "Generating with MiniMax TTS"

    local output_file=$1
    local text=$2

    # Build JSON request
    local json_payload=$(cat <<JSON
{
    "model": "${MINIMAX_MODEL}",
    "text": "${text}",
    "voice_setting": {
        "voice_id": "${MINIMAX_VOICE_ID}",
        "speed": ${MINIMAX_SPEED},
        "vol": ${MINIMAX_VOLUME},
        "pitch": ${MINIMAX_PITCH},
        "emotion": "${MINIMAX_EMOTION}"
    },
    "audio_setting": {
        "sample_rate": ${MINIMAX_SAMPLE_RATE},
        "bitrate": ${MINIMAX_BITRATE},
        "format": "${OUTPUT_FORMAT}",
        "channel": 1
    },
    "language_boost": "${MINIMAX_LANGUAGE_BOOST}"
}
JSON
)

    print_info "Sending request to MiniMax API..."

    # Call MiniMax API
    local response=$(curl -s -X POST \
        "https://api.minimax.chat/v1/text_to_speech" \
        -H "Authorization: Bearer ${MINIMAX_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "$json_payload")

    # Check for errors
    if echo "$response" | grep -q '"error"'; then
        print_error "MiniMax API error:"
        echo "$response" | python3 -m json.tool
        exit 1
    fi

    # Extract and save audio data
    echo "$response" | python3 -c "
import sys
import json
import base64

data = json.load(sys.stdin)
if 'audio' in data:
    audio_data = base64.b64decode(data['audio'])
    with open('${output_file}', 'wb') as f:
        f.write(audio_data)
    print('✓ Audio saved to ${output_file}')
else:
    print('✗ No audio data in response', file=sys.stderr)
    sys.exit(1)
"

    if [[ $? -eq 0 ]]; then
        print_success "MiniMax TTS generation completed"
        print_info "Output: $output_file"
    else
        print_error "MiniMax TTS generation failed"
        exit 1
    fi
}

################################################################################
# Main Function
################################################################################

main() {
    # Set script directory
    SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    print_header

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--text)
                INPUT_TEXT="$2"
                shift 2
                ;;
            -f|--file)
                INPUT_FILE="$2"
                shift 2
                ;;
            -p|--provider)
                PROVIDER="$2"
                shift 2
                ;;
            -s|--speakers)
                NUM_SPEAKERS="$2"
                shift 2
                ;;
            --model)
                if [[ "$PROVIDER" == "gemini" ]]; then
                    GEMINI_MODEL="$2"
                else
                    MINIMAX_MODEL="$2"
                fi
                shift 2
                ;;
            --voice-1)
                GEMINI_VOICE_1="$2"
                shift 2
                ;;
            --voice-2)
                GEMINI_VOICE_2="$2"
                shift 2
                ;;
            --temperature)
                GEMINI_TEMPERATURE="$2"
                shift 2
                ;;
            --style)
                GEMINI_STYLE="$2"
                shift 2
                ;;
            --tone)
                GEMINI_TONE="$2"
                shift 2
                ;;
            --pace)
                GEMINI_PACE="$2"
                shift 2
                ;;
            --emotion)
                if [[ "$PROVIDER" == "gemini" ]]; then
                    GEMINI_EMOTION="$2"
                else
                    MINIMAX_EMOTION="$2"
                fi
                shift 2
                ;;
            --voice-id)
                MINIMAX_VOICE_ID="$2"
                shift 2
                ;;
            --speed)
                MINIMAX_SPEED="$2"
                shift 2
                ;;
            --volume)
                MINIMAX_VOLUME="$2"
                shift 2
                ;;
            --pitch)
                MINIMAX_PITCH="$2"
                shift 2
                ;;
            --sample-rate)
                MINIMAX_SAMPLE_RATE="$2"
                shift 2
                ;;
            --bitrate)
                MINIMAX_BITRATE="$2"
                shift 2
                ;;
            --language-boost)
                MINIMAX_LANGUAGE_BOOST="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            --output-dir)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            --dry-run)
                DRY_RUN=1
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Validate inputs
    if [[ -z "$INPUT_TEXT" && -z "$INPUT_FILE" ]]; then
        print_error "Either --text or --file must be specified"
        show_usage
        exit 1
    fi

    # Read from file if specified
    if [[ -n "$INPUT_FILE" ]]; then
        if [[ ! -f "$INPUT_FILE" ]]; then
            print_error "Input file not found: $INPUT_FILE"
            exit 1
        fi
        INPUT_TEXT=$(cat "$INPUT_FILE")
    fi

    # Validate provider
    if [[ "$PROVIDER" != "gemini" && "$PROVIDER" != "minimax" ]]; then
        print_error "Invalid provider: $PROVIDER (must be 'gemini' or 'minimax')"
        exit 1
    fi

    # Validate speakers
    if [[ "$NUM_SPEAKERS" -ne 1 && "$NUM_SPEAKERS" -ne 2 ]]; then
        print_error "Number of speakers must be 1 or 2"
        exit 1
    fi

    # MiniMax doesn't support multi-speaker
    if [[ "$PROVIDER" == "minimax" && "$NUM_SPEAKERS" -eq 2 ]]; then
        print_error "MiniMax does not support multi-speaker (2 speakers)"
        echo "Please use --provider gemini for 2-speaker podcasts"
        exit 1
    fi

    # Validate Gemini voices
    if [[ "$PROVIDER" == "gemini" ]]; then
        if ! validate_gemini_voice "$GEMINI_VOICE_1"; then
            print_warning "Invalid voice: $GEMINI_VOICE_1 (using default: Zephyr)"
            GEMINI_VOICE_1="Zephyr"
        fi
        if [[ "$NUM_SPEAKERS" -eq 2 ]]; then
            if ! validate_gemini_voice "$GEMINI_VOICE_2"; then
                print_warning "Invalid voice: $GEMINI_VOICE_2 (using default: Puck)"
                GEMINI_VOICE_2="Puck"
            fi
        fi
    fi

    # Validate MiniMax emotion
    if [[ "$PROVIDER" == "minimax" ]]; then
        if ! validate_minimax_emotion "$MINIMAX_EMOTION"; then
            print_warning "Invalid emotion: $MINIMAX_EMOTION (using default: neutral)"
            MINIMAX_EMOTION="neutral"
        fi
    fi

    # Create output directory
    mkdir -p "$OUTPUT_DIR"

    # Generate output filename if not specified
    if [[ -z "$OUTPUT_FILE" ]]; then
        local timestamp=$(date +%Y%m%d_%H%M%S)
        if [[ "$NUM_SPEAKERS" -eq 1 ]]; then
            OUTPUT_FILE="${OUTPUT_DIR}/tts_${PROVIDER}_single_${timestamp}.${OUTPUT_FORMAT}"
        else
            OUTPUT_FILE="${OUTPUT_DIR}/tts_${PROVIDER}_multi_${timestamp}.${OUTPUT_FORMAT}"
        fi
    else
        # Ensure output file has correct extension
        if [[ ! "$OUTPUT_FILE" == *.* ]]; then
            OUTPUT_FILE="${OUTPUT_FILE}.${OUTPUT_FORMAT}"
        fi
    fi

    # Show configuration
    print_section "Configuration"
    echo "Provider:       $PROVIDER"
    echo "Speakers:       $NUM_SPEAKERS"
    echo "Output:         $OUTPUT_FILE"
    echo "Format:         $OUTPUT_FORMAT"

    if [[ "$PROVIDER" == "gemini" ]]; then
        echo "Model:          $GEMINI_MODEL"
        echo "Voice 1:        $GEMINI_VOICE_1"
        if [[ "$NUM_SPEAKERS" -eq 2 ]]; then
            echo "Voice 2:        $GEMINI_VOICE_2"
        fi
        echo "Temperature:    $GEMINI_TEMPERATURE"
        [[ -n "$GEMINI_STYLE" ]] && echo "Style:          $GEMINI_STYLE"
        [[ -n "$GEMINI_TONE" ]] && echo "Tone:           $GEMINI_TONE"
        [[ -n "$GEMINI_PACE" ]] && echo "Pace:           $GEMINI_PACE"
        [[ -n "$GEMINI_EMOTION" ]] && echo "Emotion:        $GEMINI_EMOTION"
    else
        echo "Model:          $MINIMAX_MODEL"
        echo "Voice ID:       ${MINIMAX_VOICE_ID:-auto}"
        echo "Speed:          $MINIMAX_SPEED"
        echo "Volume:         $MINIMAX_VOLUME"
        echo "Pitch:          $MINIMAX_PITCH"
        echo "Emotion:        $MINIMAX_EMOTION"
        echo "Sample Rate:    $MINIMAX_SAMPLE_RATE Hz"
        echo "Bitrate:        $MINIMAX_BITRATE bps"
    fi

    echo ""

    # Dry run
    if [[ -n "$DRY_RUN" ]]; then
        print_info "Dry run mode - no audio will be generated"
        exit 0
    fi

    # Check dependencies and API keys
    check_dependencies
    check_api_keys

    # Generate TTS
    if [[ "$PROVIDER" == "gemini" ]]; then
        generate_gemini_tts "$OUTPUT_FILE" "$INPUT_TEXT"
    else
        generate_minimax_tts "$OUTPUT_FILE" "$INPUT_TEXT"
    fi

    print_success "TTS generation complete!"
    echo ""
}

# Run main function
main "$@"
