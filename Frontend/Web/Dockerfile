# Stage 1: Build the application
FROM node:18-alpine AS build

# Set the working directory
WORKDIR /app

# Install build dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application files
COPY . .

# Build the frontend application
ARG ENV=production
RUN if [ "$ENV" = "development" ]; then npm run build:dev; else npm run build:prod; fi

# Stage 2: Set up the production image
FROM nginx:alpine AS production

# Copy the build output from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Optional: Run as non-root user for security
RUN adduser -D -H nginx_user && \
    chown -R nginx_user:nginx_user /usr/share/nginx/html

USER nginx_user

# Start nginx server
CMD ["nginx", "-g", "daemon off;"]

# Stage 3: Set up the development image (optional)
FROM node:18-alpine AS development

# Set the working directory
WORKDIR /app

# Copy the build dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application files
COPY . .

# Install development dependencies
RUN npm install --only=dev

# Expose port for development (if needed)
EXPOSE 3000

CMD ["npm", "run", "dev"]