FROM node:18-alpine

WORKDIR /app

# Copy package.json files
COPY package*.json ./
# Explicitly create destination directory for dashboard packages
RUN mkdir -p ./ui/dashboard
# Copy dashboard package files individually
COPY ui/dashboard/package.json ./ui/dashboard/package.json
COPY ui/dashboard/package-lock.json ./ui/dashboard/package-lock.json

# Install dependencies
RUN npm install
RUN cd ui/dashboard && npm install

# Copy project files
COPY . .

# Make the uninstall script executable
RUN chmod +x ./uninstall_cursor.sh

# Set environment variables
ENV NODE_ENV=production

# Expose port for dashboard
EXPOSE 5173
EXPOSE 3000

# Command to run
CMD ["npm", "run", "dashboard"]
