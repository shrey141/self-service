# Multi-stage build for Backstage
FROM node:18-bullseye-slim AS build

# Install dependencies for building
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    g++ \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Create a minimal Backstage app
RUN npx @backstage/create-app@latest --skip-install

# Copy our custom configuration
COPY app-config.yaml /app/app-config.yaml
COPY app-config.local.yaml /app/app-config.local.yaml

# Install dependencies
WORKDIR /app
RUN yarn install --frozen-lockfile --network-timeout 600000

# Build the application
RUN yarn tsc
RUN yarn build:backend --config app-config.yaml

# Production stage
FROM node:18-bullseye-slim

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy built artifacts from build stage
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/packages ./packages
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/yarn.lock ./yarn.lock

# Copy configuration
COPY app-config.yaml ./app-config.yaml
COPY app-config.local.yaml ./app-config.local.yaml

# Set environment
ENV NODE_ENV=production

# Expose ports
EXPOSE 7007

# Start the backend
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.local.yaml"]
