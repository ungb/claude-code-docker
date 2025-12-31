# Claude Code Docker

Run [Claude Code](https://github.com/anthropics/claude-code) CLI in a Docker container. Claude Code is Anthropic's agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster.

## Quick Start

```bash
# Pull and run (replace with your API key)
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=your-key \
  ungb/claude-code
```

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed
- [Anthropic API key](https://console.anthropic.com/) or Claude account for OAuth

## Usage Examples

### Basic Interactive Session

```bash
# Start an interactive Claude Code session
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code
```

### One-Shot Commands (Non-Interactive)

Use the `-p` flag for non-interactive mode (prints result and exits):

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

# Fix bugs
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code \
  claude -p "fix the failing tests in src/utils"

# Code review
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code \
  claude -p "review the changes in the last commit"

# JSON output (for scripts/automation)
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code \
  claude -p --output-format json "list all TODO comments"
```

### Piping Input

```bash
# Analyze a file
cat README.md | docker run -i --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code \
  claude -p "summarize this document"

# Analyze git diff
git diff | docker run -i --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code \
  claude -p "review these changes"
```

### With Full Configuration (Recommended)

```bash
# Full setup with persistent config, git, and SSH
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code
```

### Using Docker Compose

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

### Resume a Conversation

```bash
# Continue from where you left off (requires persistent config)
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code \
  claude --resume
```

### Non-Interactive / CI Mode

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

## Sharing Your Claude Configuration

The `~/.claude` directory contains your personal Claude Code configuration including custom slash commands, skills, agents, and settings. Mount it to use your customizations inside the container.

### What's in ~/.claude

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

### Mount Your Configuration

```bash
# Share your entire .claude folder (includes commands, agents, settings)
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code
```

### Use Custom Slash Commands

Once your `~/.claude` is mounted, your custom commands are available:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code

# Then inside the session, type: /my-custom-command
```

### Project-Specific Configuration

Projects can have their own `.claude/` directory with project-specific commands:

```bash
# Your project's .claude/ is automatically available at /workspace/.claude/
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code
```

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
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
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

## Authentication

### Option 1: API Key (Recommended for Docker)

Get an API key from [Anthropic Console](https://console.anthropic.com/):

```bash
-e ANTHROPIC_API_KEY=sk-ant-...
```

### Option 2: OAuth Login

OAuth login is a two-step process:

**Step 1: Login (once)**

```bash
# Login with browser-based OAuth (requires host network for callback)
docker run -it --rm \
  --network host \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code \
  claude login
```

This opens a browser, authenticates, and saves tokens to `~/.claude/`.

**Step 2: Use normally**

```bash
# Now run without API key - tokens are in ~/.claude
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code
```

> **Note**: Mount `~/.claude` from your host so tokens persist between container runs.

## Volume Mounts

| Mount | Purpose |
|-------|---------|
| `/workspace` | Your project directory (required) |
| `/home/coder/.claude` | Claude config, commands, agents, settings |
| `/home/coder/.ssh` | SSH keys for git operations (read-only) |
| `/home/coder/.gitconfig` | Git configuration (read-only) |
| `/home/coder/.claude.json` | MCP server configurations (read-only) |

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `ANTHROPIC_API_KEY` | Yes* | Your Anthropic API key |
| `ANTHROPIC_API_BASE_URL` | No | Custom API endpoint (for proxies) |
| `CLAUDE_CONFIG_DIR` | No | Override config directory location |

*Required unless using OAuth login

## Utility Commands

```bash
# Check version
docker run --rm ungb/claude-code claude --version

# Run health check
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

## Building Locally

```bash
git clone https://github.com/ungb/claude-code-docker.git
cd claude-code-docker
docker build -t claude-code .
```

## Troubleshooting

### Permission Denied on Mounted Files

The container runs as user `coder` (UID 1000). If you have permission issues:

```bash
# Run with your user ID
docker run -it --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code
```

### Git Operations Failing

Ensure SSH keys are mounted and git is configured:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code
```

### Custom Commands Not Found

Make sure you're mounting your `~/.claude` directory:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code
```

### OAuth Login Not Working

Use `--network host` to allow the OAuth callback:

```bash
docker run -it --rm \
  --network host \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  ungb/claude-code \
  claude login
```

## Shell Alias (Convenience)

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias claude-docker='docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.claude:/home/coder/.claude \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code claude'

# Usage (interactive): claude-docker
# Usage (one-shot):    claude-docker -p "explain this code"
```

## License

MIT License - see [LICENSE](LICENSE)

## Links

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Anthropic Console](https://console.anthropic.com/)
- [Claude Code GitHub](https://github.com/anthropics/claude-code)
