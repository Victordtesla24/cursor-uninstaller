FROM node:18-alpine

# Install git, as the agent will clone the repository
RUN apk add --no-cache git

# Set a working directory for the agent.
# The agent will clone the repository into this directory.
WORKDIR /agent_workspace

# Set environment variables if needed globally for the agent's environment
ENV NODE_ENV=production

# Expose ports if the processes started by the agent need to be accessed
EXPOSE 5173
EXPOSE 3000

# Default command to keep the container running, can be overridden by environment.json.
# A simple shell is often sufficient as a default.
CMD ["/bin/sh"]
