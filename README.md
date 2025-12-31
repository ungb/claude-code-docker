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

## Usage

### Using Docker Run

```bash
# Basic usage with API key
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code

# With persistent config (remembers settings between runs)
docker run -it --rm \
  -v $(pwd):/workspace \
  -v claude-config:/home/coder/.claude \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code

# With git/ssh support
docker run -it --rm \
  -v $(pwd):/workspace \
  -v claude-config:/home/coder/.claude \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code
```

### Using Docker Compose

1. Clone this repo or copy `docker-compose.yml` to your project:

```bash
curl -O https://raw.githubusercontent.com/ungb/claude-code-docker/main/docker-compose.yml
```

2. Create a `.env` file with your API key:

```bash
echo "ANTHROPIC_API_KEY=your-key-here" > .env
```

3. Run:

```bash
docker compose run --rm claude
```

### Run a Specific Command

```bash
# Run claude with arguments
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code \
  claude "explain this codebase"

# Check version
docker run -it --rm ungb/claude-code claude --version

# Run health check
docker run -it --rm \
  -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY \
  ungb/claude-code \
  claude doctor
```

## Authentication

### Option 1: API Key (Recommended for Docker)

Get an API key from [Anthropic Console](https://console.anthropic.com/) and pass it as an environment variable:

```bash
-e ANTHROPIC_API_KEY=sk-ant-...
```

### Option 2: OAuth Login

For browser-based OAuth (requires host network):

```bash
docker run -it --rm \
  --network host \
  -v $(pwd):/workspace \
  -v claude-config:/home/coder/.claude \
  ungb/claude-code \
  claude login
```

## Volume Mounts

| Mount | Purpose |
|-------|---------|
| `/workspace` | Your project directory (required) |
| `/home/coder/.claude` | Claude config and cache (optional, for persistence) |
| `/home/coder/.ssh` | SSH keys for git operations (optional, read-only) |
| `/home/coder/.gitconfig` | Git configuration (optional, read-only) |

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `ANTHROPIC_API_KEY` | Yes* | Your Anthropic API key |
| `ANTHROPIC_API_BASE_URL` | No | Custom API endpoint (for proxies) |

*Required unless using OAuth login

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

### OAuth Login Not Working

Use `--network host` to allow the OAuth callback:

```bash
docker run -it --rm \
  --network host \
  -v $(pwd):/workspace \
  -v claude-config:/home/coder/.claude \
  ungb/claude-code \
  claude login
```

## License

MIT License - see [LICENSE](LICENSE)

## Links

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Anthropic Console](https://console.anthropic.com/)
- [Claude Code GitHub](https://github.com/anthropics/claude-code)
