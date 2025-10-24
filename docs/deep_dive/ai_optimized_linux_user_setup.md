# AI-Optimized Linux User Setup: Deep Dive Research

**Last Updated:** 2025-10-24
**Purpose:** Comprehensive guide for creating a secure, AI-agent-optimized Linux user setup

---

## Table of Contents
1. [Linux User Creation & Security](#1-linux-user-creation--security)
2. [SSH Security & Authentication](#2-ssh-security--authentication)
3. [Shell Setup: Zsh & Oh My Zsh](#3-shell-setup-zsh--oh-my-zsh)
4. [tmux Configuration & MCP Integration](#4-tmux-configuration--mcp-integration)
5. [Terminal File Browsers](#5-terminal-file-browsers)
6. [Claude Code Setup](#6-claude-code-setup)
7. [Sudoers Configuration](#7-sudoers-configuration)
8. [Dotfiles Management](#8-dotfiles-management)
9. [AI Coding Assistants](#9-ai-coding-assistants)
10. [Home Directory Structure](#10-home-directory-structure)
11. [Complete Setup Workflow](#11-complete-setup-workflow)

---

## 1. Linux User Creation & Security

### Best Practices for User Creation

#### Create User with Proper Defaults
```bash
# Create user with home directory
sudo useradd -m -s /bin/zsh mvps

# Set strong password (12-14+ characters, mixed case, numbers, symbols)
sudo passwd mvps

# Add to necessary groups
sudo usermod -aG sudo,docker mvps  # Adjust based on needs
```

#### Security Principles
- **Enforce Strong Password Policies:**
  - Minimum 12-14 characters
  - Include lowercase, uppercase, numbers, symbols
  - Use randomly generated passwords where feasible

- **Regular Account Reviews:**
  - Disable or remove accounts no longer in use
  - Minimizes attack surface by eliminating dormant access points

- **Restrict Root Access:**
  - Use sudo for administrative tasks instead of logging in as root
  - Disable SSH remote login for root after setting up user account

- **Principle of Least Privilege:**
  - Grant users only permissions needed to perform their tasks
  - Minimizes risk of unauthorized access and security breaches

#### Audit User Activity
```bash
# Monitor logins
last -a

# Check command history
history

# View failed login attempts
sudo grep "Failed password" /var/log/auth.log
```

---

## 2. SSH Security & Authentication

### Modern SSH Key Standards (2025)

#### Ed25519 Keys (Recommended)
```bash
# Generate Ed25519 key (industry standard as of 2025)
ssh-keygen -t ed25519 -C "[email protected]"

# For older systems compatibility
ssh-keygen -t rsa -b 4096 -C "[email protected]"
```

**Why Ed25519?**
- Security comparable to 4096-bit RSA despite being shorter
- Widely supported for ~10 years
- Faster and more efficient than RSA

#### Key Rotation Best Practices
- Create new SSH key every 2 years
- Embed year in key name for tracking: `id_ed25519_2025`
- Remove old keys from `~/.ssh/authorized_keys`

### Secure Permissions
```bash
# Set correct permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/config
```

### SSH Server Configuration
Edit `/etc/ssh/sshd_config`:
```bash
# Disable password authentication (use keys only)
PasswordAuthentication no

# Disable root login
PermitRootLogin no

# Use SSH protocol version 2
Protocol 2

# Strong ciphers only
Ciphers aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512,hmac-sha2-256

# Restart SSH service after changes
sudo systemctl restart sshd
```

### Two-Factor Authentication (Optional but Recommended)
```bash
# Install Google Authenticator
sudo apt install libpam-google-authenticator

# Configure for user
google-authenticator
```

### Security Checklist
- ✅ Disable password-based authentication
- ✅ Use Ed25519 or RSA 4096-bit keys
- ✅ Set secure file permissions (700/600)
- ✅ Rotate keys every 2 years
- ✅ Enable 2FA for SSH
- ✅ Regular audits of SSH keys and access
- ✅ Remove unused keys and accounts

---

## 3. Shell Setup: Zsh & Oh My Zsh

### Installation

#### Install Zsh
```bash
# Ubuntu/Debian
sudo apt install zsh

# Set as default shell
chsh -s $(which zsh)
```

#### Install Oh My Zsh
```bash
# Standard installation
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Essential Plugins

#### 1. zsh-autosuggestions
Fish-like autosuggestions based on command history.
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

#### 2. zsh-syntax-highlighting
Real-time syntax highlighting for commands.
```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

#### 3. fast-syntax-highlighting
Enhanced syntax highlighting with better performance.
```bash
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
```

#### 4. zsh-autocomplete (Alternative to fzf-tab)
```bash
git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete
```

**Note:** `fzf-tab` and `zsh-autocomplete` collide - choose one based on preference.

### Configuration

Edit `~/.zshrc`:
```bash
# Theme (popular choices for 2025)
ZSH_THEME="spaceship"  # Or "powerlevel10k"

# Plugins
plugins=(
  git
  docker
  kubectl
  zsh-autosuggestions
  zsh-syntax-highlighting
  fast-syntax-highlighting
  zsh-autocomplete
)

# Custom aliases for AI work
alias python=python3
alias pip=pip3
alias ll='ls -lah'
alias gs='git status'
alias gp='git pull'

# Claude Code alias (if needed)
alias cc='claude'
```

### AI-Specific Plugin: zsh_codex
OpenAI Codex integration for command line.
```bash
git clone https://github.com/tom-doerr/zsh_codex ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh_codex

# Add to plugins in ~/.zshrc
plugins=(... zsh_codex)
```

### Popular Themes

#### Spaceship (Recommended for 2025)
```bash
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

# Set in ~/.zshrc
ZSH_THEME="spaceship"
```

#### Powerlevel10k (Alternative)
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Set in ~/.zshrc
ZSH_THEME="powerlevel10k/powerlevel10k"

# Run configuration wizard
p10k configure
```

### Usage Tips
- Right arrow key completes suggestions
- Tab for autocomplete menu
- Ctrl+R for history search
- Alt+C to navigate directories (with fzf)

---

## 4. tmux Configuration & MCP Integration

### Why tmux for AI Agents?

tmux provides:
- **Persistent Sessions:** Detach/reattach without losing progress
- **Multiple Panes:** View multiple processes simultaneously
- **AI Integration:** MCP servers enable Claude to control terminals
- **Collaboration:** Multiple AI agents in separate panes/sessions

### Installation

```bash
# Ubuntu/Debian
sudo apt install tmux

# Verify installation
tmux -V
```

### Basic Configuration

Create `~/.tmux.conf`:
```bash
# Enable mouse support
set -g mouse on

# Increase scrollback buffer
set -g history-limit 50000

# Start window numbering at 1
set -g base-index 1
setw -g pane-base-index 1

# Enable 256 colors
set -g default-terminal "screen-256color"

# Vim-like pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Reload config with r
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Status bar customization
set -g status-bg black
set -g status-fg white
set -g status-interval 1
set -g status-left-length 30
set -g status-left '#[fg=green](#S) #(whoami) '
set -g status-right '#[fg=yellow]%H:%M:%S'
```

### tmux MCP Server Integration

#### Option 1: nickgnd/tmux-mcp (Most Popular)

**For Claude Desktop:**
Edit `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or
`~/.config/Claude/claude_desktop_config.json` (Linux):

```json
{
  "mcpServers": {
    "tmux": {
      "command": "npx",
      "args": ["-y", "tmux-mcp"]
    }
  }
}
```

**For Claude Code CLI:**
```bash
claude mcp add-json "tmux" '{"command":"npx","args":["-y","tmux-mcp"]}'
```

**For Fish Shell:**
```json
{
  "mcpServers": {
    "tmux": {
      "command": "npx",
      "args": ["-y", "tmux-mcp", "--shell-type=fish"]
    }
  }
}
```

#### Option 2: rinadelph/tmux-mcp (Python-based)

```bash
# Clone repository
git clone https://github.com/rinadelph/tmux-mcp.git ~/tmux-mcp

# Add to Claude Desktop config
{
  "mcpServers": {
    "tmux-control": {
      "command": "python",
      "args": ["/absolute/path/to/tmux-mcp/tmux_mcp_server.py"],
      "env": {}
    }
  }
}
```

#### Option 3: TmuxAI (AI Terminal Assistant)

Non-intrusive terminal assistant that reads all tmux panes in real-time.

**Installation:**
```bash
# Install TmuxAI
pip install tmuxai

# Configure ~/.config/tmuxai/config.yaml
model: "anthropic:claude-sonnet-4-5"
```

**Usage:**
- Works alongside you in a tmux window
- Reads terminal content across all panes
- Understands context without special setup

### Multi-Agent Setup

Create separate tmux sessions for different AI agents:
```bash
# Session for Claude Code
tmux new-session -d -s claude-code

# Session for GitHub Copilot
tmux new-session -d -s copilot

# Session for development
tmux new-session -d -s dev

# List all sessions
tmux ls

# Attach to session
tmux attach -t claude-code
```

### Essential tmux Commands

```bash
# Sessions
tmux new -s session_name        # Create new session
tmux attach -t session_name     # Attach to session
tmux ls                         # List sessions
tmux kill-session -t name       # Kill session
Ctrl+b d                        # Detach from session

# Panes
Ctrl+b %                        # Split vertically
Ctrl+b "                        # Split horizontally
Ctrl+b arrow_key                # Navigate panes
Ctrl+b x                        # Close pane
Ctrl+b z                        # Zoom pane

# Windows
Ctrl+b c                        # Create window
Ctrl+b n                        # Next window
Ctrl+b p                        # Previous window
Ctrl+b &                        # Kill window
```

### TmuxAI Configuration Example

`~/.config/tmuxai/config.yaml`:
```yaml
model: "anthropic:claude-sonnet-4-5"
auto_start: true
pane_layout: "horizontal"  # or "vertical"
max_context_lines: 1000
```

---

## 5. Terminal File Browsers

### Comparison: ranger vs lf vs nnn

| Feature | ranger | lf | nnn |
|---------|--------|----|----|
| **Speed** | Slower (Python) | Fast (Go) | Fastest |
| **Resources** | Heavy | Light | Lightest |
| **Key Bindings** | Vi-like | Vi-like | Vi-like |
| **Image Preview** | ✅ (w3m) | ✅ | ✅ |
| **Customization** | High | High | Moderate |
| **Dependencies** | Many | Few | Minimal |
| **2025 Ranking** | #5 | #3 | #1 |

### Recommendation: nnn

**Why nnn?**
- Ranked #1 by Slant community for 2025
- Super fast and resource-efficient
- Nearly 0-config required
- Designed for low-power devices and desktops
- Tiny footprint, incredibly fast
- Smart workflows that match developer thinking

### Installation

#### nnn (Recommended)
```bash
# Ubuntu/Debian
sudo apt install nnn

# From source for latest version
git clone https://github.com/jarun/nnn.git
cd nnn
make
sudo make install
```

#### ranger (Alternative)
```bash
# Ubuntu/Debian
sudo apt install ranger

# For image preview support
sudo apt install w3m w3m-img
```

#### lf (Alternative)
```bash
# Download latest release
wget https://github.com/gokcehan/lf/releases/download/r30/lf-linux-amd64.tar.gz
tar -xvf lf-linux-amd64.tar.gz
sudo mv lf /usr/local/bin/
```

### Configuration

#### nnn Configuration
Add to `~/.zshrc` or `~/.bashrc`:
```bash
# nnn configuration
export NNN_PLUG='p:preview-tui;o:fzopen;d:dragdrop'
export NNN_FIFO='/tmp/nnn.fifo'
export NNN_COLORS='2136'

# Aliases
alias n='nnn -de'
```

#### ranger Configuration
```bash
# Generate config
ranger --copy-config=all

# Edit ~/.config/ranger/rc.conf for customization
```

### Usage

```bash
# Launch nnn
n

# Launch ranger
ranger

# Launch lf
lf
```

**Basic Navigation (all tools):**
- `j/k` or arrow keys: Navigate
- `h/l`: Go up/open directory
- `Enter`: Open file
- `q`: Quit

---

## 6. Claude Code Setup

### System Requirements

#### Essential
- **OS:** Modern Linux (Ubuntu 18.04+, CentOS 7+)
- **Node.js:** Version 18+ (20.x LTS recommended for 2025)
- **RAM:** Minimum 4GB
- **Internet:** Active connection required
- **Terminal:** Bash, Zsh, or Fish

#### Optional but Recommended
- **ripgrep:** Enhanced search capabilities
  ```bash
  sudo apt install ripgrep
  ```

### Installation

```bash
# Install globally (DO NOT use sudo)
npm install -g @anthropic-ai/claude-code

# Verify installation
claude --version
```

**IMPORTANT:** Never use `sudo` with npm install - causes permission issues and security risks.

### Special Requirements: Alpine Linux

For musl/uClibc-based distributions:
```bash
# Install dependencies
apk add libgcc libstdc++ ripgrep

# Set environment variable
export USE_BUILTIN_RIPGREP=0
```

### Authentication Options

Choose one:
1. **Anthropic Console** (requires active billing)
2. **Claude Pro/Max subscription**
3. **Enterprise platforms:** AWS Bedrock or Google Vertex AI

### First Run

```bash
# Start Claude Code
claude

# Authenticate when prompted
# Follow on-screen instructions
```

### Terminal Configuration for Claude Code

#### Recommended Terminal Setup
```bash
# .zshrc additions for Claude Code
export EDITOR=vim  # Or nano, emacs based on preference
export VISUAL=$EDITOR

# Aliases for quick access
alias cc='claude'
alias ccode='claude'
```

#### Integration with tmux
```bash
# Start Claude Code in tmux session
tmux new-session -s claude-code "claude"
```

### MCP Server Integration

Claude Code supports MCP servers for extended functionality:

```bash
# Add tmux MCP server
claude mcp add-json "tmux" '{"command":"npx","args":["-y","tmux-mcp"]}'

# List MCP servers
claude mcp list

# Remove MCP server
claude mcp remove tmux
```

### Best Practices

1. **Project-specific sessions:** Use tmux to maintain separate Claude Code sessions per project
2. **Environment variables:** Store API keys in `.env` files (add to `.gitignore`)
3. **Regular updates:** Keep Claude Code updated for latest features
   ```bash
   npm update -g @anthropic-ai/claude-code
   ```

4. **Documentation:** Refer to official docs at https://docs.claude.com/en/docs/claude-code

---

## 7. Sudoers Configuration

### Principle of Least Privilege

Grant users only the minimum privileges necessary to perform their tasks.

### Always Use `visudo`

```bash
# Edit main sudoers file
sudo visudo

# Edit user-specific file
sudo visudo -f /etc/sudoers.d/mvps
```

**Why `visudo`?**
- Syntax checking before saving
- Prevents lockout from misconfiguration
- Safe concurrent editing

### Modular Configuration: `/etc/sudoers.d/`

**Best Practice:** Use `/etc/sudoers.d/` for user-specific or application-specific configurations.

```bash
# Create user-specific sudoers file
sudo visudo -f /etc/sudoers.d/mvps
```

### Example Configurations

#### Minimal Privileges (Recommended)
```bash
# /etc/sudoers.d/mvps
# Allow mvps to restart specific service only
mvps ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart myapp.service

# Allow mvps to reload nginx
mvps ALL=(ALL) NOPASSWD: /usr/bin/systemctl reload nginx

# Allow mvps to view logs
mvps ALL=(ALL) NOPASSWD: /usr/bin/journalctl
```

#### Group-Based Management
```bash
# Create developer group
sudo groupadd developers
sudo usermod -aG developers mvps

# /etc/sudoers.d/developers
%developers ALL=(ALL) NOPASSWD: /usr/bin/docker, /usr/bin/systemctl
```

#### Time-Limited sudo
```bash
# Set sudo timeout to 5 minutes (default is 15)
Defaults:mvps timestamp_timeout=5

# Or require password every time
Defaults:mvps timestamp_timeout=0
```

### Security Best Practices

#### ❌ DON'T DO THIS
```bash
# Grants unlimited root privileges - DANGEROUS
mvps ALL=(ALL) ALL

# Allows privilege escalation bypass
mvps ALL=(ALL) NOPASSWD: ALL
```

#### ✅ DO THIS
```bash
# Specific commands only
mvps ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart myapp, \
                         /usr/bin/systemctl status myapp, \
                         /usr/bin/docker ps

# Use secure_path
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Enable logging
Defaults logfile="/var/log/sudo.log"
Defaults log_input, log_output
```

### Command Restrictions

```bash
# Allow specific git commands only
mvps ALL=(ALL) NOPASSWD: /usr/bin/git pull, /usr/bin/git status

# Allow pip installations but not removals
mvps ALL=(ALL) NOPASSWD: /usr/bin/pip3 install *

# Restrict to specific directories
mvps ALL=(ALL) NOPASSWD: /bin/chown mvps\:mvps /home/mvps/projects/*
```

### Monitoring and Auditing

#### Enable Detailed Logging
```bash
# /etc/sudoers.d/logging
Defaults logfile="/var/log/sudo.log"
Defaults log_input
Defaults log_output
Defaults iolog_dir="/var/log/sudo-io"
```

#### Review Logs
```bash
# View sudo activity
sudo cat /var/log/sudo.log

# Failed sudo attempts
sudo grep "FAILED" /var/log/sudo.log

# Recent sudo commands
sudo grep "COMMAND" /var/log/sudo.log | tail -20
```

### Testing Configuration

```bash
# Test sudo access for user
sudo -l -U mvps

# Test specific command
sudo -u mvps sudo systemctl status myapp
```

### Regular Maintenance

1. **Quarterly Review:** Audit sudoers configurations
2. **Remove Unused Entries:** Delete privileges no longer needed
3. **Update Documentation:** Maintain changelog of sudoers modifications
4. **Backup:** Keep backups before major changes
   ```bash
   sudo cp /etc/sudoers /etc/sudoers.backup
   sudo cp -r /etc/sudoers.d /etc/sudoers.d.backup
   ```

---

## 8. Dotfiles Management

### Why Manage Dotfiles?

- **Consistency:** Same environment across multiple machines
- **Version Control:** Track changes, experiment safely, revert when needed
- **Portability:** New machine setup = clone repo + run script
- **Backup:** Never lose configurations
- **Shareability:** Learn from and share with community

### Management Approaches

#### 1. Bare Repository Method (Recommended)

**Advantages:**
- No extra tooling required
- No symlinks needed
- Files stay in place
- Use different branches for different machines
- Clean and simple

**Setup:**
```bash
# Initialize bare repository
git init --bare $HOME/.dotfiles

# Create alias for dotfiles git
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Add alias to ~/.zshrc
echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> ~/.zshrc

# Configure repository
dotfiles config --local status.showUntrackedFiles no

# Add files
dotfiles add ~/.zshrc
dotfiles add ~/.tmux.conf
dotfiles add ~/.ssh/config
dotfiles commit -m "Initial dotfiles commit"

# Push to remote
dotfiles remote add origin git@github.com:username/dotfiles.git
dotfiles push -u origin main
```

**Clone on New Machine:**
```bash
# Clone bare repository
git clone --bare git@github.com:username/dotfiles.git $HOME/.dotfiles

# Define alias
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Checkout files
dotfiles checkout

# If conflicts, backup existing files
mkdir -p ~/.dotfiles-backup
dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} ~/.dotfiles-backup/{}

# Retry checkout
dotfiles checkout

# Hide untracked files
dotfiles config --local status.showUntrackedFiles no
```

#### 2. Symlink Method

**Setup:**
```bash
# Create dotfiles directory
mkdir -p ~/dotfiles

# Move config files
mv ~/.zshrc ~/dotfiles/zshrc
mv ~/.tmux.conf ~/dotfiles/tmux.conf

# Create symlinks
ln -s ~/dotfiles/zshrc ~/.zshrc
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf

# Initialize git
cd ~/dotfiles
git init
git add .
git commit -m "Initial dotfiles"
git remote add origin git@github.com:username/dotfiles.git
git push -u origin main
```

**Setup Script:**
```bash
#!/bin/bash
# ~/dotfiles/setup.sh

# Create symlinks
ln -sf ~/dotfiles/zshrc ~/.zshrc
ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/vimrc ~/.vimrc

echo "Dotfiles linked successfully!"
```

#### 3. Using Management Tools

**chezmoi** (Popular Choice):
```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# Initialize with GitHub repo
chezmoi init https://github.com/username/dotfiles.git

# Preview changes
chezmoi diff

# Apply dotfiles
chezmoi apply -v

# Add new file
chezmoi add ~/.zshrc

# Update dotfiles
chezmoi update
```

### Security Best Practices

#### .gitignore for Secrets
```bash
# ~/dotfiles/.gitignore
*.key
*.pem
.env
.env.*
*_rsa
*_ed25519
secrets/
credentials.json
```

#### Environment Variables for Secrets
```bash
# In dotfiles: ~/.zshrc
export OPENAI_API_KEY="${OPENAI_API_KEY}"
export DATABASE_URL="${DATABASE_URL}"

# Actual values in ~/.env (not in git)
# ~/.env
OPENAI_API_KEY=sk-...
DATABASE_URL=postgresql://...
```

#### Conditional Loading
```bash
# ~/.zshrc
# Load work-specific config only on work machine
if [ -f ~/.zshrc.work ]; then
    source ~/.zshrc.work
fi

# Load secrets from .env
if [ -f ~/.env ]; then
    export $(cat ~/.env | xargs)
fi
```

### Directory Structure Example

```
~/dotfiles/
├── .gitignore
├── README.md
├── setup.sh
├── zsh/
│   ├── zshrc
│   ├── aliases.zsh
│   └── functions.zsh
├── tmux/
│   └── tmux.conf
├── vim/
│   └── vimrc
├── git/
│   ├── gitconfig
│   └── gitignore_global
└── scripts/
    ├── install_deps.sh
    └── setup_ssh.sh
```

### README.md Template

```markdown
# My Dotfiles

Personal configuration files for development environment.

## Quick Start

```bash
# Clone repository
git clone https://github.com/username/dotfiles.git ~/dotfiles

# Run setup script
cd ~/dotfiles
chmod +x setup.sh
./setup.sh
```

## What's Included

- **Zsh:** Oh My Zsh with plugins
- **tmux:** Terminal multiplexer config
- **Git:** Aliases and global config
- **Vim:** Editor configuration

## Requirements

- Zsh
- Oh My Zsh
- tmux 3.0+
- Git 2.0+

## Manual Installation

1. Install dependencies: `./scripts/install_deps.sh`
2. Link dotfiles: `./setup.sh`
3. Install Oh My Zsh plugins (see zsh/README.md)

## License

MIT
```

### Automation Script Example

```bash
#!/bin/bash
# ~/dotfiles/setup.sh

set -e

echo "🚀 Setting up dotfiles..."

# Backup existing files
backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

# Files to link
declare -A dotfiles=(
    ["zsh/zshrc"]="$HOME/.zshrc"
    ["tmux/tmux.conf"]="$HOME/.tmux.conf"
    ["git/gitconfig"]="$HOME/.gitconfig"
    ["vim/vimrc"]="$HOME/.vimrc"
)

# Create symlinks
for source in "${!dotfiles[@]}"; do
    target="${dotfiles[$source]}"

    # Backup existing file
    if [ -f "$target" ]; then
        echo "📦 Backing up $target"
        mv "$target" "$backup_dir/"
    fi

    # Create symlink
    echo "🔗 Linking $source -> $target"
    ln -sf "$PWD/$source" "$target"
done

echo "✅ Dotfiles setup complete!"
echo "📁 Backups saved to: $backup_dir"
```

### Best Practices Summary

1. ✅ **Version Control:** Use Git for all dotfiles
2. ✅ **Security:** Never commit secrets (use .env + .gitignore)
3. ✅ **Modularity:** Separate configs by tool/purpose
4. ✅ **Documentation:** Maintain README with setup instructions
5. ✅ **Automation:** Create setup script for easy deployment
6. ✅ **Backup:** Always backup before linking new dotfiles
7. ✅ **Test:** Try setup on fresh VM before relying on it
8. ✅ **Public/Private:** Consider separate public/private repos

---

## 9. AI Coding Assistants

### GitHub Copilot CLI (2025 Release)

#### Overview
Released to public preview on September 25, 2025, GitHub Copilot CLI brings AI coding directly to your terminal.

#### Key Features
- **Natural Language Commands:** Interact with GitHub using plain English
- **Agentic Capabilities:** Build, edit, debug, refactor with AI planning
- **MCP Support:** Ships with GitHub MCP server, supports custom servers
- **User Control:** Preview every action before execution
- **Model Selection:** Default Claude Sonnet 4.5, switchable to GPT-5 or Claude Sonnet 4

#### Installation

```bash
# Install GitHub Copilot CLI
npm install -g @github/copilot-cli

# Authenticate
gh copilot auth

# Or use GitHub CLI
gh extension install github/gh-copilot
```

#### Usage

```bash
# Ask for command help
gh copilot suggest "find all large files"

# Explain command
gh copilot explain "tar -xzf archive.tar.gz"

# Interactive mode
gh copilot
```

#### Configuration

```bash
# Choose model
gh copilot /model

# Available models (as of 2025):
# - claude-sonnet-4-5 (default)
# - claude-sonnet-4
# - gpt-5
```

#### Requirements
- GitHub Copilot Pro, Pro+, Business, or Enterprise plan
- GitHub CLI installed
- Active internet connection

### Claude Code Integration

See [Section 6](#6-claude-code-setup) for detailed Claude Code setup.

**Quick Integration:**
```bash
# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Run in tmux for persistence
tmux new-session -s claude-code "claude"
```

### TmuxAI

AI assistant that works within tmux sessions.

```bash
# Install
pip install tmuxai

# Configure ~/.config/tmuxai/config.yaml
model: "anthropic:claude-sonnet-4-5"

# Start in tmux pane
tmuxai
```

### Comparison Matrix

| Feature | Claude Code | GitHub Copilot CLI | TmuxAI |
|---------|-------------|-------------------|---------|
| **Cost** | Claude Pro/API | Copilot subscription | Free/API cost |
| **Terminal Native** | ✅ | ✅ | ✅ |
| **Code Generation** | ✅ | ✅ | ✅ |
| **Context Awareness** | High | High | Medium |
| **MCP Support** | ✅ | ✅ | ❌ |
| **tmux Integration** | Via MCP | Limited | Native |
| **Offline Mode** | ❌ | ❌ | ❌ |
| **Best For** | Full dev workflows | GitHub integration | tmux users |

### Integration Strategy

**Recommended Multi-Assistant Setup:**
```bash
# Create separate tmux sessions for each assistant
tmux new-session -d -s claude-code "claude"
tmux new-session -d -s copilot
tmux new-session -d -s dev

# Switch between them as needed
tmux attach -t claude-code
# Detach: Ctrl+b d
tmux attach -t copilot
```

### Best Practices

1. **Use for Appropriate Tasks:**
   - Claude Code: Complex refactoring, architecture decisions
   - Copilot CLI: Quick commands, GitHub operations
   - TmuxAI: Context-aware assistance during terminal work

2. **Security:**
   - Never share API keys in prompts
   - Review generated code before execution
   - Use private repositories for sensitive work

3. **Efficiency:**
   - Keep assistants in tmux sessions for quick access
   - Create aliases for common operations
   - Use MCP servers to extend capabilities

---

## 10. Home Directory Structure

### Best Practices for Developers (2025)

#### Standard Structure

```
/home/mvps/
├── .ssh/                    # SSH keys and config
├── .config/                 # Application configs
│   ├── tmuxai/
│   └── Code/
├── .local/                  # Local binaries and data
│   ├── bin/
│   └── share/
├── bin/                     # Personal scripts
├── dev/                     # Development projects (or ~/projects)
│   ├── personal/
│   ├── work/
│   └── open-source/
├── Documents/               # Documentation
├── Downloads/               # Temporary downloads
├── tmp/                     # Temporary files
└── .dotfiles/               # Dotfiles git bare repo
```

#### Key Principles

1. **Development Projects:** `~/dev` or `~/projects`
   - All personal projects in `/home/mvps/dev`
   - Organized by category (personal, work, open-source)

2. **Personal Tools:** `~/bin` or `~/.local/bin`
   - Custom scripts and tools
   - Add to PATH in `~/.zshrc`: `export PATH="$HOME/bin:$PATH"`

3. **System Tools:** `/usr/bin`
   - Installed via package manager
   - Don't manually modify

4. **Configuration:** `~/.config/`
   - XDG Base Directory standard
   - Application-specific configs

#### Security and Permissions

```bash
# Home directory: user-only access
chmod 700 /home/mvps

# SSH directory: strict permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
chmod 644 ~/.ssh/*.pub

# Personal scripts: executable
chmod 755 ~/bin/*

# Configuration: user read/write
chmod 644 ~/.zshrc ~/.tmux.conf
```

#### Organization Tips

```bash
# Create standard structure
mkdir -p ~/dev/{personal,work,open-source}
mkdir -p ~/Documents/{notes,guides,research}
mkdir -p ~/bin
mkdir -p ~/.config
mkdir -p ~/tmp

# Symlink common locations
ln -s ~/dev ~/projects  # Alias for convenience
```

#### .gitignore for Home Directory

If using bare repo method:
```bash
# ~/.gitignore_global
*
!/.zshrc
!/.tmux.conf
!/.config/
!/.ssh/config
!/bin/
```

#### Backup Strategy

```bash
# Important directories to backup
~/dev/           # All projects
~/.ssh/          # SSH keys (encrypted backup!)
~/.config/       # Configurations
~/Documents/     # Important docs
~/.zsh_history   # Command history
```

**Automated Backup Script:**
```bash
#!/bin/bash
# ~/bin/backup-home.sh

BACKUP_DIR="/mnt/backup/home-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup important directories
rsync -av --exclude 'node_modules' ~/dev/ "$BACKUP_DIR/dev/"
rsync -av ~/.config/ "$BACKUP_DIR/config/"
rsync -av ~/Documents/ "$BACKUP_DIR/Documents/"
rsync -av --exclude 'id_*' ~/.ssh/ "$BACKUP_DIR/ssh/"

echo "Backup complete: $BACKUP_DIR"
```

#### Temporary Files

```bash
# Use ~/tmp for temporary work
export TMPDIR="$HOME/tmp"

# Clean tmp directory weekly (add to crontab)
0 0 * * 0 find ~/tmp -type f -mtime +7 -delete
```

#### File Organization Tips

1. **Avoid Root Clutter:** Don't place files directly in `~`, use subdirectories
2. **Consistent Naming:** Use lowercase with hyphens: `my-project`, not `MyProject`
3. **Archive Old Projects:** Move to `~/dev/archive/` instead of deleting
4. **Use .gitignore:** Prevent accidentally committing large files
5. **Regular Cleanup:** Monthly review and cleanup of Downloads/ and tmp/

---

## 11. Complete Setup Workflow

### Initial Server Setup

#### 1. Update System
```bash
# Update package lists and upgrade
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    htop \
    ufw \
    fail2ban
```

#### 2. Configure Firewall
```bash
# Enable UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 22/tcp
sudo ufw enable
sudo ufw status
```

#### 3. Install Fail2Ban
```bash
# Install and enable
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Check status
sudo fail2ban-client status
```

### Create User: mvps

#### 1. Create User with Secure Settings
```bash
# Create user with zsh as default shell
sudo useradd -m -s /bin/zsh -G sudo mvps

# Set strong password
sudo passwd mvps
# Enter secure password (12+ chars, mixed case, numbers, symbols)
```

#### 2. Configure SSH Access
```bash
# Switch to mvps user
sudo su - mvps

# Create SSH directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate SSH key (Ed25519)
ssh-keygen -t ed25519 -C "mvps@server-$(hostname)"

# Add public key to authorized_keys
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Copy public key for local machine access
cat ~/.ssh/id_ed25519.pub
# Copy output, then on local machine:
# echo "ssh-ed25519 AAAA..." >> ~/.ssh/authorized_keys
```

#### 3. Secure SSH Server
```bash
# Edit SSH config (as root/sudo)
sudo vim /etc/ssh/sshd_config

# Make these changes:
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes

# Restart SSH
sudo systemctl restart sshd
```

#### 4. Configure Sudoers
```bash
# Create user-specific sudoers file
sudo visudo -f /etc/sudoers.d/mvps

# Add minimal permissions (adjust as needed):
mvps ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart *, \
                         /usr/bin/systemctl status *, \
                         /usr/bin/docker *, \
                         /usr/bin/apt update, \
                         /usr/bin/apt upgrade
```

### Install Development Tools

#### 1. Install Node.js (for Claude Code & npm packages)
```bash
# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Load NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js LTS
nvm install --lts
nvm use --lts

# Verify
node --version
npm --version
```

#### 2. Install Python & Pip
```bash
sudo apt install -y python3 python3-pip python3-venv
python3 --version
pip3 --version
```

#### 3. Install Docker (Optional)
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add mvps to docker group
sudo usermod -aG docker mvps

# Verify (logout/login required)
docker --version
```

### Setup Shell Environment

#### 1. Install Zsh & Oh My Zsh
```bash
# Install Zsh (if not already installed)
sudo apt install -y zsh

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set Zsh as default
chsh -s $(which zsh)
```

#### 2. Install Zsh Plugins
```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# fast-syntax-highlighting
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting

# Spaceship theme
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
```

#### 3. Configure .zshrc
```bash
vim ~/.zshrc

# Set theme
ZSH_THEME="spaceship"

# Enable plugins
plugins=(
  git
  docker
  zsh-autosuggestions
  zsh-syntax-highlighting
  fast-syntax-highlighting
)

# Add custom aliases
alias ll='ls -lah'
alias gs='git status'
alias gp='git pull'
alias python=python3
alias pip=pip3

# Add bin to PATH
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Source .zshrc
source ~/.zshrc
```

### Setup tmux

#### 1. Install tmux
```bash
sudo apt install -y tmux
tmux -V
```

#### 2. Configure tmux
```bash
vim ~/.tmux.conf

# Paste configuration from Section 4
# Then reload:
tmux source-file ~/.tmux.conf
```

#### 3. Install tmux MCP Server
```bash
# For Claude Code
claude mcp add-json "tmux" '{"command":"npx","args":["-y","tmux-mcp"]}'

# Or install TmuxAI
pip3 install tmuxai
mkdir -p ~/.config/tmuxai
cat > ~/.config/tmuxai/config.yaml << EOF
model: "anthropic:claude-sonnet-4-5"
auto_start: true
EOF
```

### Install Terminal Tools

#### 1. Install File Browser (nnn)
```bash
sudo apt install -y nnn

# Configure in ~/.zshrc
echo 'export NNN_PLUG="p:preview-tui;o:fzopen"' >> ~/.zshrc
echo 'alias n="nnn -de"' >> ~/.zshrc
source ~/.zshrc
```

#### 2. Install ripgrep
```bash
sudo apt install -y ripgrep
rg --version
```

#### 3. Install fzf (fuzzy finder)
```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

### Install AI Assistants

#### 1. Claude Code
```bash
# Install globally (without sudo)
npm install -g @anthropic-ai/claude-code

# Verify
claude --version

# Authenticate (first run)
claude
```

#### 2. GitHub Copilot CLI (Optional)
```bash
# Install GitHub CLI
sudo apt install -y gh

# Install Copilot extension
gh extension install github/gh-copilot

# Authenticate
gh auth login
gh copilot auth
```

### Setup Dotfiles Management

#### 1. Initialize Bare Repository
```bash
# Initialize
git init --bare $HOME/.dotfiles

# Create alias
echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> ~/.zshrc
source ~/.zshrc

# Configure
dotfiles config --local status.showUntrackedFiles no

# Add files
dotfiles add ~/.zshrc
dotfiles add ~/.tmux.conf

# Commit
dotfiles commit -m "Initial dotfiles for mvps user"

# Add remote (create repo on GitHub first)
dotfiles remote add origin git@github.com:username/dotfiles.git
dotfiles push -u origin main
```

### Create Directory Structure

```bash
# Create standard directories
mkdir -p ~/dev/{personal,work,open-source}
mkdir -p ~/Documents/{notes,guides}
mkdir -p ~/bin
mkdir -p ~/tmp
mkdir -p ~/.config

# Create .gitignore templates
cat > ~/dev/.gitignore << EOF
node_modules/
venv/
.env
*.key
*.pem
EOF
```

### Security Hardening

#### 1. Set Secure Permissions
```bash
# Home directory
chmod 700 ~

# SSH
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/config
```

#### 2. Configure Git
```bash
git config --global user.name "mvps"
git config --global user.email "mvps@example.com"
git config --global init.defaultBranch main
git config --global core.editor vim
```

#### 3. Create .env Template
```bash
cat > ~/.env.template << EOF
# API Keys (never commit this file!)
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
GITHUB_TOKEN=

# Database
DATABASE_URL=

# Application
NODE_ENV=development
EOF

# Copy for actual use
cp ~/.env.template ~/.env
chmod 600 ~/.env

# Add to .gitignore
echo ".env" >> ~/.gitignore_global
```

### Testing & Verification

#### 1. Test SSH Access
```bash
# From local machine
ssh -i ~/.ssh/id_ed25519 mvps@your-server-ip

# Should connect without password
```

#### 2. Test Sudo
```bash
# Test allowed command
sudo systemctl status ssh

# Should work without password prompt
```

#### 3. Test Tools
```bash
# Zsh plugins
# Type 'git' and press tab - should see completions
# Start typing previous command - should see suggestion

# tmux
tmux new -s test
# Split panes with Ctrl+b % and Ctrl+b "
tmux kill-session -t test

# nnn
n  # Should open file browser

# Claude Code
claude --version

# Python/Node
python3 --version
node --version
npm --version
```

### Maintenance Scripts

#### 1. System Update Script
```bash
cat > ~/bin/update-system.sh << 'EOF'
#!/bin/bash
echo "🔄 Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "🔄 Updating npm packages..."
npm update -g

echo "🔄 Updating Python packages..."
pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U

echo "✅ System updated!"
EOF

chmod +x ~/bin/update-system.sh
```

#### 2. Backup Script
```bash
cat > ~/bin/backup-configs.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="$HOME/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📦 Backing up configurations..."
cp ~/.zshrc "$BACKUP_DIR/"
cp ~/.tmux.conf "$BACKUP_DIR/"
cp -r ~/.ssh/config "$BACKUP_DIR/" 2>/dev/null
cp ~/.gitconfig "$BACKUP_DIR/" 2>/dev/null

echo "✅ Backup complete: $BACKUP_DIR"
EOF

chmod +x ~/bin/backup-configs.sh
```

### Final Checklist

- ✅ User `mvps` created with secure password
- ✅ SSH key authentication configured
- ✅ Password authentication disabled
- ✅ Root SSH login disabled
- ✅ Sudoers configured with least privilege
- ✅ Firewall (UFW) enabled
- ✅ Fail2ban installed and running
- ✅ Zsh with Oh My Zsh installed
- ✅ Essential plugins configured
- ✅ tmux installed and configured
- ✅ tmux MCP server integrated
- ✅ Terminal tools installed (nnn, ripgrep, fzf)
- ✅ Claude Code installed and authenticated
- ✅ Dotfiles managed with Git
- ✅ Directory structure created
- ✅ Security permissions set
- ✅ All tools tested and verified

### Quick Reference Commands

```bash
# Update everything
~/bin/update-system.sh

# Backup configs
~/bin/backup-configs.sh

# Start Claude Code in tmux
tmux new-session -s claude-code "claude"

# Manage dotfiles
dotfiles status
dotfiles add ~/.zshrc
dotfiles commit -m "Update zshrc"
dotfiles push

# Browse files
n  # nnn file browser

# Search files
rg "search term"  # ripgrep

# Fuzzy find files
fzf

# View system info
htop
```

---

## Resources & References

### Official Documentation
- [Claude Code Docs](https://docs.claude.com/en/docs/claude-code)
- [Oh My Zsh](https://ohmyz.sh/)
- [tmux Documentation](https://github.com/tmux/tmux/wiki)
- [GitHub Copilot CLI](https://github.com/features/copilot/cli)

### Community Resources
- [awesome-dotfiles](https://github.com/webpro/awesome-dotfiles)
- [tmux MCP Server](https://github.com/nickgnd/tmux-mcp)
- [nnn File Browser](https://github.com/jarun/nnn)

### Security Resources
- [SSH Best Practices 2025](https://www.brandonchecketts.com/archives/ssh-ed25519-key-best-practices-for-2025)
- [Linux Security Hardening](https://www.cyberciti.biz/tips/linux-unix-bsd-openssh-server-best-practices.html)

---

## Conclusion

This guide provides a comprehensive approach to creating a secure, AI-optimized Linux user setup. By following these best practices, you'll have:

- **Security:** SSH key authentication, disabled root login, least-privilege sudo
- **Productivity:** Oh My Zsh with powerful plugins, tmux for session management
- **AI Integration:** Claude Code, GitHub Copilot CLI, tmux MCP servers
- **Maintainability:** Dotfiles in version control, automated scripts
- **Organization:** Clean directory structure, proper file management

Remember to:
1. Regularly update all tools and packages
2. Review and audit security settings quarterly
3. Backup configurations before major changes
4. Document any custom modifications
5. Keep dotfiles repository updated

**Ready to start?** Jump to [Section 11: Complete Setup Workflow](#11-complete-setup-workflow) for step-by-step instructions!

---

*Generated: 2025-10-24*
*For: mvps user setup on new server*
*Maintained by: Claude Code*
