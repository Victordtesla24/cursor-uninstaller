FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install git, sudo, curl, and other basic utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    sudo \
    curl \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (e.g., LTS version, adjust as needed)
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
ENV NODE_MAJOR=20
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user 'agentuser' with sudo privileges and set it as the default
RUN useradd -m -s /bin/bash agentuser && echo "agentuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/agentuser
USER agentuser
WORKDIR /home/agentuser

# The project itself will be cloned into /agent_workspace by Cursor,
# so we don't COPY it here. This Dockerfile only sets up the environment.
