# Base image setup
FROM node:18-alpine AS base
WORKDIR /app

# Copy package.json and package-lock.json separately to leverage Docker cache
COPY package*.json ./

# Debug step to check for package-lock.json
RUN ls -l package-lock.json

# Install dependencies based on environment
ARG NODE_ENV=development
RUN if [ "$NODE_ENV" = "production" ]; then npm install --only=production; else npm ci; fi

# Copy the rest of the application code
COPY . .

# Build the application (applicable for both dev and prod)
RUN npm run build

# Define the production or development stage
FROM base AS final

# Expose port
EXPOSE 3000

# Health check for both dev and prod
# HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
#   CMD curl --fail http://localhost:3000/health || exit 1

# Add a non-root user and switch to it for security
RUN adduser -D appuser
USER appuser

# Command to run the application in different environments
CMD if [ "$NODE_ENV" = "production" ]; then npm start; else npm run dev; fi