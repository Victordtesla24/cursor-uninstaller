FROM node:18-alpine AS dashboard_prep
WORKDIR /source_files
COPY ui/dashboard/package.json ./dashboard_package.json
COPY ui/dashboard/package-lock.json ./dashboard_package-lock.json
RUN echo "--- Contents of /source_files in dashboard_prep stage ---" && ls -la /source_files

FROM node:18-alpine
WORKDIR /app

# Copy package.json files
COPY package*.json ./
# Explicitly create destination directory for dashboard packages
RUN mkdir -p ./ui/dashboard
# Copy dashboard package files individually using explicit relative paths
COPY --from=dashboard_prep /source_files/dashboard_package.json ./ui/dashboard/package.json
COPY --from=dashboard_prep /source_files/dashboard_package-lock.json ./ui/dashboard/package-lock.json

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
