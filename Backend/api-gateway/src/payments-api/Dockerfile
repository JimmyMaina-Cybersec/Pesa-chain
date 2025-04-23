# ────────────────
# 1) Base image
# ────────────────
FROM node:23-slim AS base
WORKDIR /app

# Prevent interactive prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# Optional: install system dependencies if needed
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Install deps
COPY ../../package*.json ./
ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV
RUN if [ "$NODE_ENV" = "development" ]; then npm install; else npm install --only=production; fi

COPY . .

# ────────────────
# 2) Build stage (only needed for production)
# ────────────────
FROM base AS build
RUN npm run build

# ────────────────
# 3) Final runtime image
# ────────────────
FROM node:23-slim AS final
WORKDIR /app

# Environment
ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV

COPY ../../package*.json ./
RUN if [ "$NODE_ENV" = "development" ]; then npm install; else npm install --only=production; fi

COPY --from=build /app/dist ./dist
COPY --from=base /app/src ./src
COPY --from=base /app/tsconfig*.json ./

# Create non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser

# Expose NestJS port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl --fail http://localhost:3000/ || exit 1

# Start app
CMD [ "sh", "-c", "if [ \"$NODE_ENV\" = \"development\" ]; then npm run start:dev; else node dist/main; fi" ]
