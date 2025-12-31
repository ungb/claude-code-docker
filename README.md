# Claude Code Docker

Run [Claude Code](https://github.com/anthropics/claude-code) CLI in a Docker container. Claude Code is Anthropic's agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster.

## Table of Contents

- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Authentication](#authentication)
  - [OAuth Login (For Subscription Users)](#oauth-login-for-subscription-users)
  - [API Key (For API Credit Users)](#api-key-for-api-credit-users)
- [Usage Examples](#usage-examples)
  - [OAuth Usage Examples](#oauth-usage-examples)
  - [API Key Usage Examples](#api-key-usage-examples)
- [Configuration](#configuration)
  - [Sharing Your Claude Configuration](#sharing-your-claude-configuration)
  - [Using a Separate Docker Configuration](#using-a-separate-docker-configuration)
- [Volume Mounts](#volume-mounts)
- [Working with External Files and Screenshots](#working-with-external-files-and-screenshots)
- [Environment Variables](#environment-variables)
- [MCP (Model Context Protocol) Support](#mcp-model-context-protocol-support)
- [Troubleshooting](#troubleshooting)
- [Shell Alias (Convenience)](#shell-alias-convenience)
- [Building Locally](#building-locally)
- [License](#license)
- [Links](#links)

## Quick Start

Most users have a Claude Pro or Max subscription and should use OAuth:

```bash
# One-time login (opens browser)
docker run -it --rm \
  --network host \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code \
  claude login

# Then run normally (no API key needed!)
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code
```

If you're using API credits instead, see [API Key authentication](#api-key-for-api-credit-users).

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed
- One of the following:
  - Claude Pro or Max subscription (use [OAuth](#oauth-login-for-subscription-users))
  - [Anthropic API key](https://console.anthropic.com/) with API credits (use [API Key](#api-key-for-api-credit-users))

## Authentication

Choose your authentication method based on how you pay for Claude:

| Plan Type | Authentication Method | Section |
|-----------|----------------------|---------|
| **Claude Pro/Max Subscription** | OAuth Login (recommended) | [OAuth Setup](#oauth-login-for-subscription-users) |
| **API Credits (Pay-as-you-go)** | API Key | [API Key Setup](#api-key-for-api-credit-users) |

### OAuth Login (For Subscription Users)

**Recommended for most users.** If you have a Claude Pro or Max subscription, OAuth is the easiest way to authenticate.

#### One-Time Setup

```bash
# Login with browser-based OAuth (one-time only)
docker run -it --rm \
  --network host \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code \
  claude login
```

This opens your browser, authenticates with your Claude account, and saves tokens to `~/.claude/` on your host machine.

#### Daily Usage

After the one-time login, simply run:

```bash
# No API key needed!
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code
```

> **Important**: Always mount `-v ~/.claude:/home/coder/.claude` to persist your login. Without this mount, you'll need to login every time.

**How it works**: OAuth tokens are stored in `~/.claude/` on your host. By mounting this directory, your credentials persist between container runs. You only need to run `claude login` once (or when tokens expire).

### API Key (For API Credit Users)

If you're using Anthropic API credits (pay-as-you-go), use an API key from [Anthropic Console](https://console.anthropic.com/):

```bash
# Set your API key as an environment variable
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=sk-ant-... \
  ungb/claude-code
```

Or use an environment variable from your shell:

```bash
# Export once in your shell
export ANTHROPIC_API_KEY=sk-ant-...

# Then use in docker commands
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code
```

> **Note**: This method doesn't require mounting `~/.claude` for authentication (though you may still want to mount it for custom commands and settings).

## Usage Examples

### OAuth Usage Examples

All examples below assume you've completed the [OAuth one-time setup](#one-time-setup).

#### Interactive Session

```bash
# Start an interactive Claude Code session
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code
```

#### One-Shot Commands (Non-Interactive)

Use the `-p` flag for non-interactive mode (prints result and exits):

```bash
# Ask a question about your codebase
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code \
  claude -p "explain the architecture of this project"

# Generate code
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code \
  claude -p "create a REST API endpoint for user authentication"

# Fix bugs
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code \
  claude -p "fix the failing tests in src/utils"

# Code review
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code \
  claude -p "review the changes in the last commit"
```

#### Full Configuration (Recommended)

```bash
# Full setup with persistent config, git, SSH, and screenshots
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -v ~/claude-screenshots:/screenshots \
  ungb/claude-code
```

#### Using Docker Compose (OAuth)

1. Copy `docker-compose.yml` to your project
2. Ensure you've run `claude login` (one-time setup)
3. Run:

```bash
# Interactive session
docker compose run --rm claude

# One-shot command (non-interactive)
docker compose run --rm claude claude -p "explain this code"
```

#### Resume a Conversation

```bash
# Continue from where you left off
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code \
  claude --resume
```

#### Piping Input

```bash
# Analyze a file
cat README.md | docker run -i --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code \
  claude -p "summarize this document"

# Analyze git diff
git diff | docker run -i --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code \
  claude -p "review these changes"
```

### API Key Usage Examples

All examples below use the API key authentication method.

#### Interactive Session

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code
```

#### One-Shot Commands (Non-Interactive)

```bash
# Ask a question about your codebase
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code \
  claude -p "explain the architecture of this project"

# Generate code
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code \
  claude -p "create a REST API endpoint for user authentication"

# JSON output (for scripts/automation)
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code \
  claude -p --output-format json "list all TODO comments"
```

#### Using Docker Compose (API Key)

1. Copy `docker-compose.yml` to your project:

```bash
curl -O https://raw.githubusercontent.com/ungb/claude-code-docker/main/docker-compose.yml
```

2. Create a `.env` file:

```bash
echo "ANTHROPIC_API_KEY=your-key-here" > .env
```

3. Run:

```bash
# Interactive session
docker compose run --rm claude

# One-shot command (non-interactive)
docker compose run --rm claude claude -p "explain this code"
```

#### Non-Interactive / CI Mode

```bash
# Run without interactive prompts (for scripts/CI)
docker run --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code \
  claude -p --allowedTools "Bash(npm run format)" "format all TypeScript files"

# Skip all permission prompts (use with caution!)
docker run --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code \
  claude -p --dangerously-skip-permissions "run the linter and fix issues"
```

## Configuration

### Sharing Your Claude Configuration

The `~/.claude` directory contains your personal Claude Code configuration including custom slash commands, skills, agents, and settings. Mount it to use your customizations inside the container.

#### What's in ~/.claude

```
~/.claude/
├── settings.json          # Global settings and preferences
├── settings.local.json    # Local overrides and permissions
├── commands/              # Custom slash commands (.md files)
│   ├── my-command.md
│   └── another-command.md
├── agents/                # Custom agents (.md files with YAML frontmatter)
│   ├── code-reviewer.md
│   └── debugger.md
└── .claude.json           # MCP server configurations
```

#### Mount Your Configuration

```bash
# OAuth users: This is automatically included in OAuth setup
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code

# API Key users: Add this mount to access your custom commands/agents
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code
```

#### Use Custom Slash Commands

Once your `~/.claude` is mounted, your custom commands are available:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code

# Then inside the session, type: /my-custom-command
```

#### Project-Specific Configuration

Projects can have their own `.claude/` directory with project-specific commands:

```bash
# Your project's .claude/ is automatically available at /workspace/.claude/
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code
```

### Using a Separate Docker Configuration

If you want to use different Claude Code settings for Docker than your local setup (e.g., your local has MCP servers that won't work in Docker), you can create a separate configuration directory:

#### Step 1: Create a Docker-Specific Config Directory

```bash
# Create a separate config directory for Docker
mkdir -p ~/.claude-docker

# Copy your existing config if you want to start from there
cp -r ~/.claude/* ~/.claude-docker/

# Or start fresh - Claude will create default settings on first run
```

#### Step 2: Mount the Docker-Specific Config

```bash
# OAuth login with Docker-specific config
docker run -it --rm \
  --network host \
  -v ~/.claude-docker:/home/coder/.claude \
  ungb/claude-code \
  claude login

# Use the Docker-specific config
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude-docker:/home/coder/.claude \
  ungb/claude-code
```

#### Step 3: Customize Your Docker Config

Edit `~/.claude-docker/settings.json` or `.claude.json` on your host to:
- Remove MCP servers that don't work in Docker
- Add Docker-specific slash commands
- Adjust settings for containerized environment
- Configure different agents or hooks

#### Example: Docker-Specific Settings

```bash
# Edit your Docker-specific settings
nano ~/.claude-docker/settings.json

# Remove problematic MCP servers
nano ~/.claude-docker/.claude.json
```

This approach keeps your local Claude Code setup separate from your Docker setup, allowing each to have their own:
- MCP server configurations
- Custom commands and agents
- Settings and preferences
- OAuth credentials (if using different accounts)

## Volume Mounts

| Mount | Purpose |
|-------|---------|
| `/workspace` | Your project directory (required) |
| `/home/coder/.claude` | Claude config, commands, agents, settings, OAuth tokens |
| `/home/coder/.ssh` | SSH keys for git operations (read-only) |
| `/home/coder/.gitconfig` | Git configuration (read-only) |
| `/home/coder/.claude.json` | MCP server configurations (read-only) |
| `/screenshots` | Optional: Dedicated folder for screenshots and images (recommended) |

## Working with External Files and Screenshots

**Important**: Drag-and-drop doesn't work when Claude Code runs in a Docker container because it's isolated from your host filesystem. You need to explicitly mount directories to make files accessible.

### Recommended Setup: Dedicated Screenshots Folder

Create a dedicated folder on your host machine for screenshots and images you want to share with Claude Code:

#### Step 1: Create the Screenshots Directory

```bash
# Create a dedicated screenshots folder
mkdir -p ~/claude-screenshots
```

#### Step 2: Mount the Screenshots Folder

**Using docker run:**

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  -v ~/claude-screenshots:/screenshots \
  ungb/claude-code
```

**Using docker-compose:**

Update your `docker-compose.yml` to include the screenshots mount (see example in the repository).

#### Step 3: Add Your Files

```bash
# Copy screenshots or images to the folder
cp ~/Downloads/screenshot.png ~/claude-screenshots/
cp ~/Desktop/diagram.jpg ~/claude-screenshots/

# Or save screenshots directly to this folder using your screenshot tool
```

#### Step 4: Reference Files in Claude Code

Inside Claude Code, reference files using the mounted path:

```
Can you analyze /screenshots/screenshot.png?
```

```
Please review the UI in /screenshots/mockup.png and suggest improvements
```

```
Read the diagram at /screenshots/architecture.jpg and explain the flow
```

### Alternative: Using Your Downloads Folder

You can also mount your Downloads folder directly:

```bash
# Mount Downloads folder (read-only recommended for safety)
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  -v ~/Downloads:/downloads:ro \
  ungb/claude-code
```

Then reference files:

```
Analyze /downloads/screenshot.png
```

### Alternative: Copy Files to Your Workspace

If you're working on a specific project, copy files directly into your project directory:

```bash
# Copy to your project directory (which is already mounted as /workspace)
cp ~/Downloads/screenshot.png /path/to/your/project/

# Then in Claude Code:
# Analyze /workspace/screenshot.png
```

### Multiple Mount Points Example

You can mount multiple directories for different purposes:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  -v ~/claude-screenshots:/screenshots \
  -v ~/Downloads:/downloads:ro \
  -v ~/Documents:/docs:ro \
  ungb/claude-code
```

This gives you access to:
- `/workspace` - Your current project
- `/screenshots` - Dedicated screenshots folder (read-write)
- `/downloads` - Downloads folder (read-only)
- `/docs` - Documents folder (read-only)

### Tips for Working with External Files

1. **Use descriptive paths**: Instead of `screenshot.png`, use `login-page-error.png`
2. **Organize by purpose**: Create subfolders in `~/claude-screenshots/` like `bugs/`, `designs/`, `diagrams/`
3. **Read-only mounts**: Use `:ro` flag for folders you only need to read from (safety measure)
4. **Absolute paths**: Always use absolute paths when referencing files (e.g., `/screenshots/image.png`)

### Example Workflow

```bash
# 1. Take a screenshot (macOS example)
# Press Cmd+Shift+4 and save to ~/claude-screenshots/

# 2. Start Claude Code with screenshots mounted
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  -v ~/claude-screenshots:/screenshots \
  ungb/claude-code

# 3. In Claude Code, reference the screenshot
> Can you analyze the error message in /screenshots/error-screenshot.png and help me fix it?
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `ANTHROPIC_API_KEY` | Conditional* | Your Anthropic API key |
| `ANTHROPIC_API_BASE_URL` | No | Custom API endpoint (for proxies) |
| `CLAUDE_CONFIG_DIR` | No | Override config directory location |

*Required if using API key authentication. Not required if using OAuth.

## MCP (Model Context Protocol) Support

> **Warning**: MCP support in Docker containers is limited and may require additional configuration.

### Current Limitations

MCP servers may not work out of the box in Docker because:

1. **Stdio-based MCP servers** need the server binary installed inside the container
2. **Network-based MCP servers** need proper network configuration
3. **MCP servers that access local resources** (files, databases) need those resources available in the container
4. **Authentication** for MCP servers may not transfer into the container

### What Might Work

| MCP Type | Status | Notes |
|----------|--------|-------|
| HTTP/SSE servers (remote) | May work | Requires `--network host` or proper port mapping |
| Stdio servers (local) | Unlikely | Server must be installed in container |
| Servers needing local files | Partial | Files must be mounted into container |
| Servers with OAuth | Unlikely | Auth flow may not complete in container |

### Attempting MCP with Docker

If you want to try MCP servers:

```bash
# Mount MCP config and use host network
docker run -it --rm \
  --network host \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  -v ~/.claude.json:/home/coder/.claude.json:ro \
  ungb/claude-code
```

### Building a Custom Image with MCP Servers

For stdio-based MCP servers, you'll need to build a custom image:

```dockerfile
FROM ungb/claude-code:latest

# Switch to root to install packages
USER root

# Example: Install an MCP server
RUN npm install -g @anthropic/mcp-server-example

# Switch back to coder user
USER coder
```

### MCP Investigation Needed

Full MCP support in Docker containers requires further investigation:
- Testing specific MCP servers for compatibility
- Network configuration for different MCP transport types
- Credential/auth forwarding for authenticated MCP servers
- Potential need for Docker-in-Docker for some servers

If you have insights or solutions for MCP in Docker, please open an issue or PR!

## Troubleshooting

### OAuth Login Not Working

Use `--network host` to allow the OAuth callback:

```bash
docker run -it --rm \
  --network host \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code \
  claude login
```

### OAuth Login Not Persisting (Need to Login Every Time)

You must mount `~/.claude` to persist OAuth tokens between container runs:

```bash
# Always include this mount for OAuth persistence
-v ~/.claude:/home/coder/.claude
```

If you're still being prompted to login:
1. Verify the mount exists: `ls -la ~/.claude/`
2. Check for credential files: `ls ~/.claude/*.json 2>/dev/null`
3. Ensure you ran `claude login` with the same mount path

### Permission Denied on Mounted Files

The container runs as user `coder` (UID 1000). If you have permission issues:

```bash
# Run with your user ID
docker run -it --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/workspace \
  ungb/claude-code
```

### Git Operations Failing

Ensure SSH keys are mounted and git is configured:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  ungb/claude-code
```

### Custom Commands Not Found

Make sure you're mounting your `~/.claude` directory:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code
```

### Utility Commands

```bash
# Check version
docker run --rm ungb/claude-code claude --version

# Run health check (OAuth)
docker run --rm \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code \
  claude doctor

# Run health check (API Key)
docker run --rm \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code \
  claude doctor

# List available commands
docker run --rm \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code \
  claude /help
```

## Shell Alias (Convenience)

Add to your `~/.bashrc` or `~/.zshrc`:

### For OAuth Users

```bash
alias claude-docker='docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -v ~/claude-screenshots:/screenshots \
  ungb/claude-code claude'

# Usage (interactive): claude-docker
# Usage (one-shot):    claude-docker -p "explain this code"
# Usage (with screenshot): claude-docker -p "analyze /screenshots/bug.png"
```

### For API Key Users

```bash
alias claude-docker='docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -v ~/claude-screenshots:/screenshots \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code claude'

# Usage (interactive): claude-docker
# Usage (one-shot):    claude-docker -p "explain this code"
# Usage (with screenshot): claude-docker -p "analyze /screenshots/bug.png"
```

## Building Locally

```bash
git clone https://github.com/ungb/claude-code-docker.git
cd claude-code-docker
docker build -t claude-code .
```

## License

MIT License - see [LICENSE](LICENSE)

## Links

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Anthropic Console](https://console.anthropic.com/)
- [Claude Code GitHub](https://github.com/anthropics/claude-code)
