#!/bin/bash

################################################################################
# Podcast Generator - AI-Powered Podcast Creation Pipeline
# Uses Claude/Gemini/Qodercli to generate scripts, then TTS for audio
# Author: Auto-generated
# Date: 2025-10-24
################################################################################

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

################################################################################
# Configuration
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROMPTS_DIR="$PROJECT_ROOT/prompts"
OUTPUT_DIR="$PROJECT_ROOT/outputs"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"
TEMP_DIR="$PROJECT_ROOT/.tmp/podcast_generation"

# AI Provider Configuration
AI_PROVIDER="claude"  # claude, gemini, qodercli, auto
TTS_PROVIDER="gemini"  # gemini or minimax

# Podcast Configuration
PODCAST_TYPE="interview"
TOPIC=""
DURATION=15
NUM_SPEAKERS=2
INPUT_FILE=""
SOURCE_CONTENT=""

# Voice Configuration
VOICE_1="Zephyr"
VOICE_2="Puck"
TTS_STYLE=""
TTS_TONE="professional yet conversational"

# Output Configuration
OUTPUT_NAME=""
GENERATE_SCRIPT_ONLY=false
SKIP_AUDIO=false
VERBOSE=false

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║         AI-Powered Podcast Generator Pipeline                 ║"
    echo "║    Script Generation → TTS Conversion → Audio Output          ║"
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

PODCAST CONFIGURATION:
    -t, --topic TOPIC           Podcast topic (required unless using -f)
    -f, --file FILE             Input file to convert to podcast
    --type TYPE                 Podcast type (default: interview)
                                Options: interview, educational, news, storytelling,
                                        debate, casual
    -d, --duration MIN          Duration in minutes (default: 15)
    -s, --speakers NUM          Number of speakers: 1 or 2 (default: 2)

AI PROVIDER OPTIONS:
    --ai PROVIDER               AI for script generation (default: claude)
                                Options: claude, gemini, qodercli, auto
    --ai-model MODEL            Specific AI model to use
    --ai-prompt PROMPT          Custom prompt (overrides template)

TTS PROVIDER OPTIONS:
    --tts PROVIDER              TTS provider (default: gemini)
                                Options: gemini, minimax
    --voice-1 VOICE             Voice for speaker 1 (default: Zephyr)
    --voice-2 VOICE             Voice for speaker 2 (default: Puck)
    --style STYLE               TTS style description
    --tone TONE                 TTS tone (default: professional yet conversational)

OUTPUT OPTIONS:
    -o, --output NAME           Output file base name
    --output-dir DIR            Output directory (default: ./outputs)
    --script-only               Generate script only, skip audio
    --skip-audio                Alias for --script-only

OTHER OPTIONS:
    -v, --verbose               Verbose output
    --dry-run                   Show configuration without generating
    -h, --help                  Show this help message

PODCAST TYPES:
    interview       - Two-speaker interview (host + guest)
    educational     - Teaching format (teacher + learner)
    news            - News discussion (anchor + analyst)
    storytelling    - Narrative podcast (narrator + listener)
    debate          - Debate format (position A + position B)
    casual          - Casual conversation (friend 1 + friend 2)

EXAMPLES:

    # Generate AI interview podcast (full pipeline)
    $0 -t "The Future of AI in Healthcare" --type interview -d 15

    # Educational podcast about quantum physics
    $0 -t "Understanding Quantum Entanglement" --type educational -d 10

    # Convert research paper to podcast
    $0 -f research_paper.pdf --type interview -d 12

    # Generate script only (no audio)
    $0 -t "Climate Change Solutions" --type debate --script-only

    # Use specific AI and custom voices
    $0 --ai gemini -t "Space Exploration" --voice-1 Fenrir --voice-2 Charon

    # Casual podcast with MiniMax TTS
    $0 -t "Our Favorite Movies" --type casual --tts minimax

    # Full custom configuration
    $0 -t "The Art of Negotiation" \\
       --type interview \\
       -d 15 \\
       --ai claude \\
       --tts gemini \\
       --voice-1 Charon \\
       --voice-2 Kore \\
       --style "professional business podcast" \\
       -o negotiation_podcast

EOF
}

check_dependencies() {
    local missing_deps=()

    # Check for yq (YAML parser)
    if ! command -v yq &> /dev/null; then
        print_warning "yq not found (YAML parser). Attempting to install..."
        if command -v pip3 &> /dev/null; then
            pip3 install yq
        else
            missing_deps+=("yq (install: pip3 install yq)")
        fi
    fi

    # Check AI CLI tools
    case $AI_PROVIDER in
        claude)
            if ! command -v claude &> /dev/null; then
                missing_deps+=("claude CLI (install: npm install -g @anthropics/claude-cli)")
            fi
            ;;
        gemini)
            if ! command -v gemini &> /dev/null; then
                missing_deps+=("gemini CLI (install instructions: https://github.com/google-gemini/gemini-cli)")
            fi
            ;;
        qodercli)
            if ! command -v qodercli &> /dev/null; then
                missing_deps+=("qodercli (install: npm install -g @qodana/qodo-cli)")
            fi
            ;;
    esac

    # Check TTS manager
    if [[ ! -x "$SCRIPTS_DIR/tts-manager.sh" ]]; then
        missing_deps+=("tts-manager.sh not found or not executable")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        return 1
    fi

    return 0
}

detect_ai_provider() {
    print_info "Auto-detecting available AI provider..."

    if command -v claude &> /dev/null; then
        AI_PROVIDER="claude"
        print_success "Found Claude CLI"
        return 0
    elif command -v gemini &> /dev/null; then
        AI_PROVIDER="gemini"
        print_success "Found Gemini CLI"
        return 0
    elif command -v qodercli &> /dev/null; then
        AI_PROVIDER="qodercli"
        print_success "Found Qodercli"
        return 0
    else
        print_error "No AI CLI tool found"
        print_info "Please install one of: claude, gemini, or qodercli"
        return 1
    fi
}

load_prompt_template() {
    local podcast_type=$1
    local prompts_file="$PROMPTS_DIR/podcast_prompts.yaml"

    if [[ ! -f "$prompts_file" ]]; then
        print_error "Prompts file not found: $prompts_file"
        return 1
    fi

    # Extract prompt template using yq
    local template=$(yq eval ".podcast_types.$podcast_type.prompt_template" "$prompts_file")

    if [[ "$template" == "null" || -z "$template" ]]; then
        print_error "Podcast type '$podcast_type' not found in prompts file"
        return 1
    fi

    # Get default variables
    local duration=$(yq eval ".podcast_types.$podcast_type.variables.duration" "$prompts_file")
    local word_count=$(yq eval ".podcast_types.$podcast_type.variables.word_count" "$prompts_file")
    local tone=$(yq eval ".podcast_types.$podcast_type.variables.tone" "$prompts_file")

    # Replace variables in template
    template="${template//\{topic\}/$TOPIC}"
    template="${template//\{duration\}/$DURATION}"
    template="${template//\{word_count\}/$word_count}"
    template="${template//\{tone\}/$tone}"

    echo "$template"
}

generate_script_with_claude() {
    local prompt=$1
    local output_file=$2

    print_section "Generating podcast script with Claude"

    # Use Claude CLI to generate script
    print_info "Sending prompt to Claude..."

    if echo "$prompt" | claude --output "$output_file" --quiet 2>&1; then
        print_success "Script generated successfully"
        return 0
    else
        print_error "Failed to generate script with Claude"
        return 1
    fi
}

generate_script_with_gemini() {
    local prompt=$1
    local output_file=$2

    print_section "Generating podcast script with Gemini"

    print_info "Sending prompt to Gemini CLI..."

    # Use Gemini CLI
    if echo "$prompt" | gemini -o "$output_file" 2>&1; then
        print_success "Script generated successfully"
        return 0
    else
        print_error "Failed to generate script with Gemini"
        return 1
    fi
}

generate_script_with_qodercli() {
    local prompt=$1
    local output_file=$2

    print_section "Generating podcast script with Qodercli"

    print_info "Sending prompt to Qodercli..."

    # Use Qodercli
    if echo "$prompt" | qodercli generate --output "$output_file" 2>&1; then
        print_success "Script generated successfully"
        return 0
    else
        print_error "Failed to generate script with Qodercli"
        return 1
    fi
}

generate_script() {
    local prompt=$1
    local output_file=$2

    case $AI_PROVIDER in
        claude)
            generate_script_with_claude "$prompt" "$output_file"
            ;;
        gemini)
            generate_script_with_gemini "$prompt" "$output_file"
            ;;
        qodercli)
            generate_script_with_qodercli "$prompt" "$output_file"
            ;;
        *)
            print_error "Unknown AI provider: $AI_PROVIDER"
            return 1
            ;;
    esac
}

generate_audio_from_script() {
    local script_file=$1
    local output_audio=$2

    print_section "Converting script to audio with TTS"

    local tts_args=(
        "-f" "$script_file"
        "-p" "$TTS_PROVIDER"
        "-s" "$NUM_SPEAKERS"
        "-o" "$output_audio"
    )

    # Add voice configuration
    if [[ -n "$VOICE_1" ]]; then
        tts_args+=("--voice-1" "$VOICE_1")
    fi

    if [[ "$NUM_SPEAKERS" -eq 2 && -n "$VOICE_2" ]]; then
        tts_args+=("--voice-2" "$VOICE_2")
    fi

    # Add style and tone if specified
    if [[ -n "$TTS_STYLE" ]]; then
        tts_args+=("--style" "$TTS_STYLE")
    fi

    if [[ -n "$TTS_TONE" ]]; then
        tts_args+=("--tone" "$TTS_TONE")
    fi

    # Execute TTS manager
    if "$SCRIPTS_DIR/tts-manager.sh" "${tts_args[@]}"; then
        print_success "Audio generated successfully"
        return 0
    else
        print_error "Failed to generate audio"
        return 1
    fi
}

process_input_file() {
    local input_file=$1

    print_info "Processing input file: $input_file"

    if [[ ! -f "$input_file" ]]; then
        print_error "Input file not found: $input_file"
        return 1
    fi

    # Extract text based on file type
    local extension="${input_file##*.}"

    case "$extension" in
        txt|md)
            SOURCE_CONTENT=$(cat "$input_file")
            ;;
        pdf)
            # Try to extract text from PDF
            if command -v pdftotext &> /dev/null; then
                SOURCE_CONTENT=$(pdftotext "$input_file" -)
            else
                print_error "pdftotext not found. Install poppler-utils to process PDF files"
                return 1
            fi
            ;;
        docx)
            # Try to extract text from DOCX
            if command -v docx2txt &> /dev/null; then
                SOURCE_CONTENT=$(docx2txt "$input_file" -)
            else
                print_error "docx2txt not found. Install docx2txt to process DOCX files"
                return 1
            fi
            ;;
        *)
            print_error "Unsupported file type: $extension"
            return 1
            ;;
    esac

    print_success "Extracted content from $input_file"
    return 0
}

################################################################################
# Main Function
################################################################################

main() {
    print_header

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--topic)
                TOPIC="$2"
                shift 2
                ;;
            -f|--file)
                INPUT_FILE="$2"
                shift 2
                ;;
            --type)
                PODCAST_TYPE="$2"
                shift 2
                ;;
            -d|--duration)
                DURATION="$2"
                shift 2
                ;;
            -s|--speakers)
                NUM_SPEAKERS="$2"
                shift 2
                ;;
            --ai)
                AI_PROVIDER="$2"
                shift 2
                ;;
            --ai-model)
                AI_MODEL="$2"
                shift 2
                ;;
            --ai-prompt)
                AI_CUSTOM_PROMPT="$2"
                shift 2
                ;;
            --tts)
                TTS_PROVIDER="$2"
                shift 2
                ;;
            --voice-1)
                VOICE_1="$2"
                shift 2
                ;;
            --voice-2)
                VOICE_2="$2"
                shift 2
                ;;
            --style)
                TTS_STYLE="$2"
                shift 2
                ;;
            --tone)
                TTS_TONE="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_NAME="$2"
                shift 2
                ;;
            --output-dir)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --script-only|--skip-audio)
                GENERATE_SCRIPT_ONLY=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                set -x
                shift
                ;;
            --dry-run)
                DRY_RUN=true
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
    if [[ -z "$TOPIC" && -z "$INPUT_FILE" ]]; then
        print_error "Either --topic or --file must be specified"
        show_usage
        exit 1
    fi

    # Process input file if specified
    if [[ -n "$INPUT_FILE" ]]; then
        if ! process_input_file "$INPUT_FILE"; then
            exit 1
        fi
    fi

    # Auto-detect AI provider if set to auto
    if [[ "$AI_PROVIDER" == "auto" ]]; then
        if ! detect_ai_provider; then
            exit 1
        fi
    fi

    # Create necessary directories
    mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"

    # Generate output filename
    if [[ -z "$OUTPUT_NAME" ]]; then
        local timestamp=$(date +%Y%m%d_%H%M%S)
        OUTPUT_NAME="${PODCAST_TYPE}_${timestamp}"
    fi

    local script_file="$TEMP_DIR/${OUTPUT_NAME}_script.txt"
    local audio_file="$OUTPUT_DIR/${OUTPUT_NAME}.wav"

    # Show configuration
    print_section "Configuration"
    echo "Podcast Type:    $PODCAST_TYPE"
    echo "Topic:           ${TOPIC:-from file}"
    echo "Duration:        $DURATION minutes"
    echo "Speakers:        $NUM_SPEAKERS"
    echo "AI Provider:     $AI_PROVIDER"
    echo "TTS Provider:    $TTS_PROVIDER"
    echo "Voice 1:         $VOICE_1"
    if [[ "$NUM_SPEAKERS" -eq 2 ]]; then
        echo "Voice 2:         $VOICE_2"
    fi
    echo "Script Output:   $script_file"
    if [[ "$GENERATE_SCRIPT_ONLY" == "false" ]]; then
        echo "Audio Output:    $audio_file"
    fi
    echo ""

    # Dry run
    if [[ -n "$DRY_RUN" ]]; then
        print_info "Dry run mode - no podcast will be generated"
        exit 0
    fi

    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi

    # Load prompt template
    print_section "Loading Prompt Template"
    local prompt
    if [[ -n "$AI_CUSTOM_PROMPT" ]]; then
        prompt="$AI_CUSTOM_PROMPT"
        print_info "Using custom prompt"
    else
        prompt=$(load_prompt_template "$PODCAST_TYPE")
        if [[ $? -ne 0 ]]; then
            exit 1
        fi
        print_success "Loaded $PODCAST_TYPE template"
    fi

    # If source content exists, add it to prompt
    if [[ -n "$SOURCE_CONTENT" ]]; then
        prompt="$prompt

SOURCE CONTENT TO CONVERT:
$SOURCE_CONTENT"
    fi

    # Generate script
    if ! generate_script "$prompt" "$script_file"; then
        exit 1
    fi

    print_success "Script saved to: $script_file"

    # Show preview of script
    if [[ "$VERBOSE" == "true" ]]; then
        print_section "Script Preview"
        head -n 20 "$script_file"
        echo "..."
    fi

    # Generate audio if not script-only mode
    if [[ "$GENERATE_SCRIPT_ONLY" == "false" ]]; then
        if ! generate_audio_from_script "$script_file" "$audio_file"; then
            print_warning "Audio generation failed, but script was saved successfully"
            exit 1
        fi

        print_success "Audio saved to: $audio_file"
    fi

    # Summary
    print_section "Summary"
    print_success "Podcast generation complete!"
    echo ""
    echo "Generated files:"
    echo "  📝 Script: $script_file"
    if [[ "$GENERATE_SCRIPT_ONLY" == "false" && -f "$audio_file" ]]; then
        echo "  🎵 Audio:  $audio_file"
        local file_size=$(du -h "$audio_file" | cut -f1)
        echo "  📊 Size:   $file_size"
    fi
    echo ""
}

# Run main function
main "$@"
