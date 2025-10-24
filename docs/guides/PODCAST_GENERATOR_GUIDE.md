# 🎙️ AI-Powered Podcast Generator - Complete Guide

Transform any topic or document into a professional-quality podcast using AI-generated scripts and TTS audio.

## 🌟 Overview

The Podcast Generator is a complete pipeline that:
1. **Generates podcast scripts** using Claude, Gemini, or Qodercli
2. **Converts scripts to audio** using Gemini or MiniMax TTS
3. **Produces professional podcasts** with multiple speakers and natural dialogue

```
Topic/File → AI Script Generation → TTS Audio → Professional Podcast
            (Claude/Gemini/Qodo)   (Gemini/MiniMax)
```

## 🚀 Quick Start

```bash
# Simple interview podcast about AI
./scripts/podcast-generator.sh -t "The Future of Artificial Intelligence"

# Educational podcast from a research paper
./scripts/podcast-generator.sh -f research_paper.pdf --type educational

# Casual conversation about movies
./scripts/podcast-generator.sh -t "Our Favorite Sci-Fi Movies" --type casual
```

## 📋 Prerequisites

### Required Tools

```bash
# AI CLI Tools (at least one required)
npm install -g @anthropics/claude-cli  # For Claude
# OR install Gemini CLI: https://github.com/google-gemini/gemini-cli
# OR install Qodercli: npm install -g @qodana/qodo-cli

# YAML Parser (required)
pip3 install yq

# PDF Processing (optional, for PDF inputs)
sudo apt-get install poppler-utils  # For pdftotext

# DOCX Processing (optional, for Word docs)
sudo apt-get install docx2txt
```

### API Keys

```bash
# For AI Script Generation
export ANTHROPIC_API_KEY="your-claude-key"  # If using Claude
export GEMINI_API_KEY="your-gemini-key"     # If using Gemini

# For TTS (Gemini or MiniMax)
export GEMINI_API_KEY="your-key"   # Already set above
export MINIMAX_API_KEY="your-key"  # If using MiniMax TTS
```

## 🎭 Podcast Types

The system includes 6 optimized podcast formats:

### 1. Interview (Default)
**Best For:** Expert interviews, Q&A sessions, professional discussions

```bash
./scripts/podcast-generator.sh \
  -t "Blockchain Technology Explained" \
  --type interview \
  -d 15
```

**Structure:**
- Introduction (1 min): Host introduces topic and guest
- Main Discussion (12 min): Q&A with detailed answers
- Conclusion (2 min): Takeaways and closing

**Speakers:** Host (curious interviewer) + Guest (knowledgeable expert)

---

### 2. Educational
**Best For:** Teaching concepts, tutorials, explaining complex topics

```bash
./scripts/podcast-generator.sh \
  -t "Understanding Quantum Computing" \
  --type educational \
  -d 10
```

**Structure:**
- Introduction (1 min): Hook and why it matters
- Core Concepts (7 min): Step-by-step explanation
- Practical Application (1 min): Real-world use
- Wrap-up (1 min): Summary and next steps

**Speakers:** Teacher (patient explainer) + Learner (asks clarifying questions)

---

### 3. News/Current Events
**Best For:** News analysis, current events, topical discussions

```bash
./scripts/podcast-generator.sh \
  -t "Recent Developments in Renewable Energy" \
  --type news \
  -d 12
```

**Structure:**
- Headlines (1 min): Key facts and timeline
- Deep Dive (8 min): Detailed analysis and implications
- Looking Ahead (2 min): Future predictions
- Closing (1 min): Summary

**Speakers:** Anchor (presents facts) + Analyst (expert commentary)

---

### 4. Storytelling/Narrative
**Best For:** True stories, historical events, narrative content

```bash
./scripts/podcast-generator.sh \
  -t "The Discovery of Penicillin" \
  --type storytelling \
  -d 15
```

**Structure:**
- Setup (2 min): Scene setting and characters
- Rising Action (5 min): Building tension
- Climax (3 min): Main event/revelation
- Resolution (3 min): Outcomes
- Reflection (2 min): Meaning and lessons

**Speakers:** Narrator (tells story) + Listener (reacts emotionally)

---

### 5. Debate
**Best For:** Controversial topics, multiple perspectives, balanced discussions

```bash
./scripts/podcast-generator.sh \
  -t "Universal Basic Income: Pros and Cons" \
  --type debate \
  -d 15
```

**Structure:**
- Introduction (2 min): Both positions presented
- Round 1 (5 min): First arguments with evidence
- Round 2 (5 min): Counter-arguments
- Rebuttal (2 min): Address opposing points
- Conclusion (1 min): Summary of positions

**Speakers:** Position A + Position B (respectful opposing views)

---

### 6. Casual Conversation
**Best For:** Informal discussions, entertainment, friend-to-friend chat

```bash
./scripts/podcast-generator.sh \
  -t "What We're Binge-Watching Right Now" \
  --type casual \
  -d 12
```

**Structure:**
- Warm-up (1 min): Natural greeting
- Main Discussion (9 min): Free-flowing conversation with tangents
- Wrap-up (2 min): Final thoughts and sign-off

**Speakers:** Friend 1 + Friend 2 (natural, humorous dialogue)

## 📝 Input Methods

### Method 1: Topic String
Simple text topic for AI to elaborate on:

```bash
./scripts/podcast-generator.sh -t "The History of Jazz Music"
```

### Method 2: Text File
Structured content or long-form text:

```bash
# Create a text file
cat > topic.txt <<EOF
Topic: Climate Change Solutions
Key Points:
- Renewable energy technologies
- Carbon capture and storage
- Policy recommendations
- Individual actions
EOF

./scripts/podcast-generator.sh -f topic.txt --type interview
```

### Method 3: PDF Document
Research papers, articles, reports:

```bash
./scripts/podcast-generator.sh \
  -f research_paper.pdf \
  --type interview \
  -d 15
```

### Method 4: Word Document
Manuscripts, drafts, formatted documents:

```bash
./scripts/podcast-generator.sh \
  -f manuscript.docx \
  --type storytelling
```

## 🎨 Voice Customization

### Gemini Voices

| Voice | Character | Best For |
|-------|-----------|----------|
| **Zephyr** | Natural, conversational | General interviews, casual podcasts |
| **Puck** | Friendly, engaging | Storytelling, educational content |
| **Charon** | Professional, authoritative | Business, news, academic |
| **Kore** | Warm, approachable | Tutorials, friendly discussions |
| **Uranus** | Distinctive, memorable | Brand identity, unique content |
| **Fenrir** | Strong, dramatic | Dramatic stories, intense topics |
| **Aoede** | Musical, lyrical | Poetry, artistic content |
| **Leda** | Elegant, refined | Sophisticated discussions |
| **Orus** | Deep, commanding | Leadership, motivational |

### Voice Examples

```bash
# Professional business interview
./scripts/podcast-generator.sh \
  -t "Corporate Leadership Strategies" \
  --voice-1 Charon \
  --voice-2 Orus \
  --tone "professional and authoritative"

# Friendly educational content
./scripts/podcast-generator.sh \
  -t "How Plants Grow" \
  --type educational \
  --voice-1 Kore \
  --voice-2 Puck \
  --tone "warm and approachable"

# Dramatic storytelling
./scripts/podcast-generator.sh \
  -t "The Mystery of the Bermuda Triangle" \
  --type storytelling \
  --voice-1 Fenrir \
  --voice-2 Zephyr \
  --style "dramatic and suspenseful"
```

## 🔧 Advanced Usage

### Custom AI Prompts

Override the template with your own prompt:

```bash
./scripts/podcast-generator.sh \
  -t "Machine Learning" \
  --ai-prompt "Create a fun, beginner-friendly conversation about ML \
with lots of real-world examples and analogies. Make it entertaining!"
```

### Script-Only Generation

Generate the script without audio (faster, no TTS API calls):

```bash
./scripts/podcast-generator.sh \
  -t "Blockchain Basics" \
  --script-only
```

Review and edit the script, then generate audio separately:

```bash
./scripts/tts-manager.sh \
  -f .tmp/podcast_generation/interview_20251024_134000_script.txt \
  -s 2 \
  --voice-1 Zephyr \
  --voice-2 Puck
```

### Different AI Providers

```bash
# Use Claude for script generation
./scripts/podcast-generator.sh \
  --ai claude \
  -t "The Metaverse Explained"

# Use Gemini for script generation
./scripts/podcast-generator.sh \
  --ai gemini \
  -t "Web3 Technologies"

# Auto-detect available AI CLI
./scripts/podcast-generator.sh \
  --ai auto \
  -t "Future of Work"
```

### Different TTS Providers

```bash
# Use MiniMax TTS (single speaker only)
./scripts/podcast-generator.sh \
  -t "Morning Motivation" \
  -s 1 \
  --tts minimax \
  --voice-id "custom_voice_123" \
  --emotion happy

# Use Gemini TTS with custom style
./scripts/podcast-generator.sh \
  -t "Leadership Principles" \
  --tts gemini \
  --voice-1 Charon \
  --style "inspirational and motivating" \
  --tone "confident and uplifting"
```

## 📚 Real-World Examples

### Example 1: Tech News Podcast

```bash
./scripts/podcast-generator.sh \
  --type news \
  -t "Latest AI Breakthroughs from OpenAI and Google" \
  -d 12 \
  --ai claude \
  --tts gemini \
  --voice-1 Charon \
  --voice-2 Zephyr \
  --tone "professional yet accessible" \
  -o tech_news_episode_001
```

### Example 2: Educational Series

```bash
# Episode 1: Introduction to Python
./scripts/podcast-generator.sh \
  --type educational \
  -t "Python Programming Basics: Variables and Data Types" \
  -d 10 \
  --voice-1 Kore \
  --voice-2 Puck \
  --style "beginner-friendly with practical examples" \
  -o python_basics_ep01

# Episode 2: Control Flow
./scripts/podcast-generator.sh \
  --type educational \
  -t "Python Programming: If Statements and Loops" \
  -d 10 \
  --voice-1 Kore \
  --voice-2 Puck \
  -o python_basics_ep02
```

### Example 3: Research Paper to Podcast

```bash
./scripts/podcast-generator.sh \
  -f "papers/quantum_computing_advances_2025.pdf" \
  --type interview \
  -d 15 \
  --voice-1 Zephyr \
  --voice-2 Charon \
  --style "make complex research accessible to general audience" \
  --tone "enthusiastic about science" \
  -o quantum_research_podcast
```

### Example 4: Business Interview Series

```bash
./scripts/podcast-generator.sh \
  --type interview \
  -t "Startup Fundraising Strategies from Seed to Series A" \
  -d 15 \
  --voice-1 Orus \
  --voice-2 Charon \
  --style "practical advice from experienced entrepreneurs" \
  --tone "professional with real-world insights" \
  -o startup_funding_ep03
```

### Example 5: Historical Storytelling

```bash
./scripts/podcast-generator.sh \
  --type storytelling \
  -t "The Race to Decode the Enigma Machine in World War II" \
  -d 15 \
  --voice-1 Fenrir \
  --voice-2 Zephyr \
  --style "dramatic historical narrative with tension" \
  --tone "engaging and suspenseful" \
  -o history_enigma
```

## 🎯 Best Practices

### For High-Quality Scripts

1. **Be Specific with Topics**
   ```bash
   # Good: Specific and focused
   -t "How CRISPR gene editing is treating sickle cell disease in 2025"

   # Less good: Too broad
   -t "Gene editing"
   ```

2. **Match Type to Content**
   - Use **interview** for expert knowledge
   - Use **educational** for teaching concepts
   - Use **debate** for controversial topics
   - Use **storytelling** for narratives

3. **Adjust Duration Appropriately**
   - 10 min: Single focused topic
   - 15 min: Comprehensive discussion
   - 20+ min: Deep dive with multiple angles

### For High-Quality Audio

1. **Choose Appropriate Voices**
   - Match voice character to content tone
   - Use distinct voices for 2-speaker formats
   - Example: Charon (professional) + Puck (friendly) for accessible expert content

2. **Specify Style and Tone**
   ```bash
   --style "conversational and warm" \
   --tone "professional yet approachable"
   ```

3. **Review Scripts Before Audio Generation**
   ```bash
   # Generate script only
   ./scripts/podcast-generator.sh -t "Topic" --script-only

   # Review and edit script
   vim .tmp/podcast_generation/interview_*_script.txt

   # Generate audio from edited script
   ./scripts/tts-manager.sh -f edited_script.txt -s 2
   ```

## 🔧 Troubleshooting

### "No AI CLI tool found"

**Solution:** Install at least one AI CLI tool:

```bash
# Install Claude
npm install -g @anthropics/claude-cli

# OR use Gemini CLI
# Follow instructions at: https://github.com/google-gemini/gemini-cli
```

### "yq not found"

**Solution:** Install yq for YAML parsing:

```bash
pip3 install yq
```

### "Failed to extract text from PDF"

**Solution:** Install PDF tools:

```bash
sudo apt-get install poppler-utils
```

### Script Quality Issues

**Solutions:**
1. Be more specific with topic
2. Provide more context in prompt
3. Try different AI provider
4. Use custom prompt with detailed instructions

### Audio Quality Issues

**Solutions:**
1. Edit generated script for better TTS flow
2. Add punctuation for natural pauses
3. Try different voice combinations
4. Adjust speaking style with `--style` and `--tone`

## 📊 Workflow Comparison

| Workflow | Speed | Quality | Customization | Cost |
|----------|-------|---------|---------------|------|
| **Quick & Automated** | ⚡⚡⚡ | ⭐⭐⭐ | ⭐ | 💰 |
| **Script Review** | ⚡⚡ | ⭐⭐⭐⭐ | ⭐⭐⭐ | 💰 |
| **Full Custom** | ⚡ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 💰💰 |

### Quick & Automated
```bash
./scripts/podcast-generator.sh -t "Topic" --type interview
```
Best for: Testing, rapid prototyping, content generation at scale

### Script Review
```bash
# 1. Generate script
./scripts/podcast-generator.sh -t "Topic" --script-only

# 2. Review and edit
vim .tmp/podcast_generation/*_script.txt

# 3. Generate audio
./scripts/tts-manager.sh -f edited_script.txt -s 2
```
Best for: Professional podcasts, quality control, brand voice

### Full Custom
```bash
# 1. Write custom prompt
# 2. Generate with custom AI prompt
# 3. Edit script thoroughly
# 4. Generate audio with precise voice settings
# 5. Post-process audio (external tools)
```
Best for: Premium content, unique requirements, maximum quality

## 📁 Output Files

```
outputs/
├── interview_20251024_134000.wav       # Generated audio
└── .tmp/podcast_generation/
    └── interview_20251024_134000_script.txt  # Generated script
```

## 🚀 Next Steps

1. **Start Simple:** Generate a basic interview podcast
2. **Experiment:** Try different podcast types and voices
3. **Customize:** Add custom styles and tones
4. **Refine:** Review and edit scripts for better quality
5. **Scale:** Build a podcast series with consistent quality

## 🤝 Integration with Other Tools

### Post-Processing Audio

```bash
# Generate podcast
./scripts/podcast-generator.sh -t "Topic" -o my_podcast

# Add intro music with ffmpeg
ffmpeg -i intro.mp3 -i outputs/my_podcast.wav \
  -filter_complex "[0:a][1:a]concat=n=2:v=0:a=1" \
  outputs/my_podcast_final.wav
```

### Batch Processing

```bash
# Generate multiple episodes
for topic in "AI" "Blockchain" "Quantum Computing"; do
  ./scripts/podcast-generator.sh \
    -t "Introduction to $topic" \
    --type educational \
    -d 10 \
    -o "series_${topic// /_}"
done
```

### RSS Feed Generation

Combine with podcast RSS feed generators to publish your series.

## 📚 Additional Resources

- [TTS Manager Guide](./TTS_MANAGER_GUIDE.md) - Detailed TTS configuration
- [Prompt Templates](./prompts/podcast_prompts.yaml) - All prompt templates
- [Voice Guide](./docs/voice_selection_guide.md) - Voice selection tips
- [Best Practices](./docs/podcast_best_practices.md) - Professional tips

---

**Happy Podcasting! 🎙️**

Need help? Run `./scripts/podcast-generator.sh --help`
