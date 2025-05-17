FROM node:20-slim

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install git explicitly first to ensure proper repository cloning
RUN apt-get update && apt-get install -y git && git --version

# Install utilities and dependencies needed for the development environment
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    curl \
    ca-certificates \
    gnupg \
    bash \
    wget \
    procps \
    lsof \
    net-tools \
    tmux \
    jq \
    vim \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install npm global packages for diagnostics and development
RUN npm install -g npm@latest vite nodemon concurrently

# Set environment variables
ENV NODE_ENV=development
ENV PATH="/home/node/.npm-global/bin:${PATH}"
ENV NPM_CONFIG_PREFIX="/home/node/.npm-global"

# Configure git for the node user
RUN mkdir -p /home/node/.config && \
    chown -R node:node /home/node/.config && \
    git config --system user.email "background-agent@cursor.sh" && \
    git config --system user.name "Cursor Background Agent"

# Create workspace directories - Cursor will clone the repository into /agent_workspace
RUN mkdir -p /agent_workspace && chown -R node:node /agent_workspace

# Create log directory
RUN mkdir -p /home/node/.cursor/logs && \
    chown -R node:node /home/node/.cursor

# Switch to non-root user for better security
USER node
WORKDIR /home/node

# Configure npm for the non-root user
RUN mkdir -p /home/node/.npm-global && \
    npm config set prefix '/home/node/.npm-global'

# Configure GitHub credentials helper to cache credentials
RUN git config --global credential.helper 'cache --timeout=3600'

# Note: The project itself will be cloned into /agent_workspace by Cursor,
# so we don't COPY it here. This Dockerfile only sets up the environment.

# This setup follows Cursor documentation guidelines where the Dockerfile
# only installs tools and dependencies, not the project itself.
