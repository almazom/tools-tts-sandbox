# Project Structure

This document outlines the organized structure of the TTS Sandbox project.

## 📁 Directory Structure

```
tools_tts_sandbox/
├── 📁 archive/                    # Archived legacy files
│   ├── 📁 legacy_scripts/         # Old script versions
│   └── 📄 README.md              # Archive documentation
├── 📁 docs/                       # Project documentation
│   └── 📁 project_gathering/      # Analysis and schema documents
├── 📁 examples/                   # Usage examples
│   ├── 📄 ПРОСТЫЕ_ПРИМЕРЫ.md     # Simple examples (Russian)
│   ├── 📄 01_привет_мир.sh       # Hello world example
│   ├── 📄 02_диалог.sh           # Dialogue example
│   └── 📄 03_ai_подкаст.sh       # AI podcast example
├── 📁 outputs/                    # Generated audio files
├── 📁 prompts/                    # AI prompt templates
│   └── 📄 podcast_prompts.yaml   # Podcast generation prompts
├── 📁 scripts/                    # Core functionality
│   ├── 📄 gemini_tts.py          # Gemini TTS API wrapper
│   ├── 📄 tts-manager.sh         # Main TTS management script
│   ├── 📄 podcast-generator.sh   # Podcast generation orchestrator
│   └── 📄 podcast_cli.py         # CLI interface for podcast generation
├── 📁 tests/                      # Testing framework
│   ├── 📄 ТЕСТОВАЯ_СТРАТЕГИЯ.md   # Test strategy (Russian)
│   ├── 📄 bash_simulation_test.py
│   ├── 📄 debug_minimal_test.py
│   └── 📄 russian_encoding_test.py
├── 📁 venv/                       # Python virtual environment
├── 📄 tts-quick.sh               # Quick access wrapper script
├── 📄 .env                       # Environment variables (not tracked)
├── 📄 .gitignore                 # Git ignore rules
├── 📄 requirements.txt           # Python dependencies
└── 📄 README.md                  # Main project documentation
```

## 🎯 Key Components

### Core Scripts
- **`tts-manager.sh`**: Universal TTS script supporting Gemini and MiniMax APIs
- **`tts-quick.sh`**: Wrapper script that activates venv and handles environment
- **`podcast-generator.sh`**: AI-powered podcast generation orchestrator

### Python Modules
- **`gemini_tts.py`**: Core Gemini TTS API wrapper with multi-speaker support
- **`podcast_cli.py`**: Command-line interface for podcast functionality

### Configuration Files
- **`.env`**: API keys and configuration (use `.env.example` as template)
- **`prompts/podcast_prompts.yaml`**: Comprehensive prompt library for AI generation

### Documentation
- **`README.md`**: Main project documentation and setup guide
- **`PROJECT_STRUCTURE.md`**: This file - project organization guide
- **`TTS_MANAGER_GUIDE.md`**: Detailed usage guide for TTS manager
- **`PODCAST_GENERATOR_GUIDE.md`**: Podcast generation guide

### Testing
- **`tests/ТЕСТОВАЯ_СТРАТЕГИЯ.md`**: Comprehensive test strategy in Russian
- **`tests/*.py`**: Debug and test scripts for development

## 🚀 Quick Start

1. **Environment Setup**:
   ```bash
   source venv/bin/activate
   export $(cat .env | grep -v '^#' | xargs)
   ```

2. **Simple TTS Generation**:
   ```bash
   ./tts-quick.sh -t "Привет мир" --format mp3 -o hello_world
   ```

3. **Podcast Generation**:
   ```bash
   ./scripts/podcast-generator.sh -t "AI technology" -p interview
   ```

## 📝 File Organization Rules

### Temporary Files
- Use `.tmp/` directory for temporary files (auto-created during processing)
- Temporary files are automatically cleaned up after use

### Generated Content
- Audio files go to `outputs/` directory
- Auto-generated filenames follow pattern: `tts_{provider}_{type}_{timestamp}.{format}`

### Legacy Code
- Old script versions are moved to `archive/legacy_scripts/`
- Archive contains previous implementations for reference

### Documentation Language
- Primary documentation in English
- Examples and test cases in Russian (as required)
- Mixed language support throughout the project

## 🔧 Development Notes

### Dependencies
- Python 3.8+ with virtual environment
- Google Gemini API key
- ffmpeg for audio format conversion
- GitHub CLI (gh) for repository management

### API Support
- **Gemini API**: Multi-speaker support, 9 voice options, temperature control
- **MiniMax API**: Single speaker, emotion controls, speed/volume/pitch adjustment

### Audio Formats
- **Input**: Text files (TXT, PDF, DOCX)
- **Output**: WAV (default), MP3, FLAC (via ffmpeg conversion)
- **Quality**: 24kHz, 16-bit PCM for optimal voice synthesis