FROM node:22-slim

LABEL maintainer="ungb"
LABEL description="Claude Code CLI in a Docker container"
LABEL org.opencontainers.image.source="https://github.com/ungb/claude-code-docker"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    openssh-client \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Create non-root user for security
RUN useradd -m -s /bin/bash coder \
    && mkdir -p /home/coder/.claude \
    && chown -R coder:coder /home/coder

# Set up workspace directory
RUN mkdir -p /workspace && chown coder:coder /workspace

# Copy entrypoint script
COPY --chown=coder:coder entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to non-root user
USER coder
WORKDIR /workspace

# Environment variables
ENV HOME=/home/coder
ENV CLAUDE_CONFIG_DIR=/home/coder/.claude

ENTRYPOINT ["/entrypoint.sh"]
CMD ["claude"]
