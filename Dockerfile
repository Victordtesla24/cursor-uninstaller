FROM node:20-slim

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Set shell options for better error handling
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install git and necessary tools in a single layer to reduce image size
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git=1:2.39.* \
    sudo=1.9.* \
    curl=7.88.* \
    ca-certificates=20230311 \
    gnupg=2.2.* \
    bash=5.2.* \
    wget=1.21.* \
    procps=2:4.0.* \
    lsof=4.95.* \
    net-tools=2.10-* \
    tmux=3.3* \
    jq=1.6-* \
    vim-tiny=2:9.0.* \
    python3=3.11.* \
    python3-pip=23.0.* && \
    # Add GitHub CLI installation
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh=2.* && \
    # Clean up apt cache to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install npm global packages for diagnostics and development
RUN npm install -g npm@10.2.5 vite@5.0.8 nodemon@3.0.2 concurrently@8.2.2

# Set environment variables
ENV NODE_ENV=development
ENV PATH="/home/node/.npm-global/bin:${PATH}"
ENV NPM_CONFIG_PREFIX="/home/node/.npm-global"

# Create essential directories with proper permissions in a single layer
RUN mkdir -p /home/node/.config && \
    mkdir -p /agent_workspace && \
    mkdir -p /agent_workspace/.cursor/logs && \
    mkdir -p /home/node/.npm-global && \
    touch /agent_workspace/.cursor/logs/agent.log && \
    chown -R node:node /home/node/.config && \
    chown -R node:node /agent_workspace && \
    chown -R node:node /agent_workspace/.cursor && \
    chown -R node:node /home/node/.npm-global && \
    # Configure git globally
    git config --system user.email "background-agent@cursor.sh" && \
    git config --system user.name "Cursor Background Agent"

# Switch to non-root user for better security
USER node

# Set working directory for the non-root user
WORKDIR /agent_workspace

# Configure npm and git for the non-root user
RUN npm config set prefix '/home/node/.npm-global' && \
    git config --global credential.helper 'cache --timeout=3600'

# Default command
CMD ["bash", "-c", "id && echo 'Cursor Background Agent is ready.' && bash"]

# Note: The project itself will be cloned into /agent_workspace by Cursor,
# so we don't COPY it here. This Dockerfile only sets up the environment.

# This setup follows Cursor documentation guidelines where the Dockerfile
# only installs tools and dependencies, not the project itself.
