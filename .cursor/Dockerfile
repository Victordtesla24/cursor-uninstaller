FROM node:18-alpine AS dashboard_prep
# Copy the entire ui/dashboard directory first
COPY ui/dashboard /temp_dashboard_files
WORKDIR /source_files
# Now, move the specific files from the copied directory
RUN mv /temp_dashboard_files/package.json ./dashboard_package.json && \
    mv /temp_dashboard_files/package-lock.json ./dashboard_package-lock.json && \
    rm -rf /temp_dashboard_files
RUN echo "--- Contents of /source_files in dashboard_prep stage ---" && ls -la /source_files

FROM node:18-alpine
WORKDIR /app

# Copy root package files and install root dependencies
COPY package*.json ./
RUN npm install

# Create dashboard directory and copy prepped package files
RUN mkdir -p ./ui/dashboard
COPY --from=dashboard_prep /source_files/dashboard_package.json ./ui/dashboard/package.json
COPY --from=dashboard_prep /source_files/dashboard_package-lock.json ./ui/dashboard/package-lock.json

RUN echo "--- Contents of /app/ui/dashboard in main stage after COPY --from ---" && ls -la ./ui/dashboard

# Install dashboard dependencies
RUN cd ui/dashboard && npm install

# Copy the rest of the project files
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
