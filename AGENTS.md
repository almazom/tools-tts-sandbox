# AGENTS.md

This file provides guidance to Qoder (qoder.com) when working with code in this repository.

## Project Overview

This is a **Podcast Generator toolkit** using Google's Gemini API for text-to-speech conversion. It supports single-speaker TTS, multi-speaker podcast interviews, and AI-powered script generation. The codebase is primarily Python-based with Bash scripts for workflow orchestration.

## Build and Test Commands

### Environment Setup
```bash
# Activate virtual environment
source venv/bin/activate

# Load environment variables (.env contains GEMINI_API_KEY)
export $(cat .env | xargs)
```

### Running Tests
```bash
# Run all test suites
python3 tests/test_runner.py

# Run specific test suite
python3 tests/test_runner.py unit_tests
python3 tests/test_runner.py integration_tests

# Run individual unit tests
pytest tests/unit/test_gemini_tts_unit.py -v

# Run integration tests
pytest tests/integration/test_rest_api_integration.py -v
```

### Code Quality
- No linting configured in this project
- No type checking configured in this project

## Core Architecture

### Python Core - Gemini TTS Wrapper (`scripts/gemini_tts.py`)

The `GeminiTTS` class is the foundation of all TTS functionality:

- **Single Speaker Generation**: `generate_speech()` method converts text to speech using one of 6 available voices (Zephyr, Puck, Charon, Kore, Uranus, Fenrir)
- **Multi-Speaker Podcasts**: `generate_podcast_interview()` method handles labeled scripts with multiple speakers (e.g., "Speaker 1: Hello")
- **Script Generation**: `generate_podcast_script()` uses Gemini's text generation for creating podcast scripts
- **Audio Processing**: Handles PCM to WAV conversion with proper headers, streaming audio chunks, and file I/O

### CLI Interface (`scripts/podcast_cli.py`)

Command-line wrapper around `GeminiTTS` with three main commands:
- `voices` - List available voices
- `single` - Generate single-speaker audio
- `multi` - Generate multi-speaker podcast
- `script` - Generate podcast script using AI

Usage pattern:
```bash
python3 scripts/podcast_cli.py single "Text here" -v Zephyr -o output_file
python3 scripts/podcast_cli.py multi "Speaker 1: Hi\nSpeaker 2: Hello" -s "Speaker 1:Zephyr" "Speaker 2:Puck"
```

### Bash Orchestration Scripts

**`scripts/tts-manager.sh`**:
- Universal TTS script with retry logic and error handling
- Supports MP3/WAV output via ffmpeg conversion
- Handles Gemini API calls through embedded Python script
- Base64 encoding for Unicode text preservation

**`scripts/podcast-generator.sh`**:
- Full AI-powered podcast generation pipeline
- Integrates multiple AI providers (Claude/Gemini/Qodercli) for script generation
- Uses YAML prompt templates from `prompts/podcast_prompts.yaml`
- Supports file input (TXT, PDF, DOCX) conversion to podcasts
- Orchestrates script generation → TTS conversion → audio output

**`scripts/tts-quick.sh`**:
- Quick access wrapper that handles venv activation and environment loading

### Configuration Files

**Environment Variables (`.env`)**:
- `GEMINI_API_KEY` - Required for all API calls
- `GEMINI_TTS_MODEL` - Model selection (default: `gemini-2.5-flash-preview-tts`)

**Prompts (`prompts/podcast_prompts.yaml`)**:
- Contains templated prompts for different podcast types (interview, educational, news, storytelling, debate, casual)
- Variables: `{topic}`, `{duration}`, `{word_count}`, `{tone}`

## Development Guidelines

### Audio File Handling
- All audio is generated as PCM data and converted to WAV with proper RIFF headers
- WAV files can be converted to MP3/FLAC using ffmpeg (handled by `tts-manager.sh`)
- Output files go to `./outputs/` directory by default
- Temporary files use `.tmp/` directory

### API Integration Patterns
- The project uses `google-genai` Python package (not the legacy `google.generativeai`)
- Streaming API pattern: iterate over `generate_content_stream()` chunks and collect `inline_data.data`
- Multi-speaker config requires `SpeakerVoiceConfig` with speaker labels matching script format

### Error Handling
- Retry logic with exponential backoff for API calls (implemented in `tts-manager.sh`)
- Validation of voice names against `AVAILABLE_VOICES` list
- Base64 encoding for preserving Unicode characters in Bash→Python data transfer

### Testing Strategy
- Unit tests: Test `GeminiTTS` class methods in isolation
- Integration tests: Test REST API endpoints
- E2E tests: Test full workflows (script generation → audio)
- BDD tests: Feature-based testing with pytest-bdd
- Test runner: `tests/test_runner.py` orchestrates all test suites

## Important Notes

- Always activate the virtual environment before running Python scripts
- The `.env` file contains the API key and should not be committed
- Available voices are hardcoded in `GeminiTTS.AVAILABLE_VOICES` - validate against this list
- Multi-speaker scripts must use exact speaker labels (e.g., "Speaker 1:", "Speaker 2:") that match the `speaker_configs`
- The project supports both English and Russian documentation/examples
