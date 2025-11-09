# ==============================================================================
# Garbageman Nodes Manager - StartOS Dockerfile
# ==============================================================================
# Multi-stage build for minimal runtime image
# Target architecture: linux/amd64 (x86_64 only - ARM support in future release)
# Services: API (Fastify), UI (Next.js), Supervisor (Multi-daemon manager)

# ==============================================================================
# Stage 1: Build Dependencies Base
# ==============================================================================
FROM node:20-alpine AS deps-base

# Install build tools for native modules
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    && rm -rf /var/cache/apk/*

# ==============================================================================
# Stage 2: Install API Dependencies
# ==============================================================================
FROM deps-base AS api-deps

WORKDIR /build/api

# Copy package files
COPY garbageman-nm/webui/api/package*.json ./

# Install production dependencies
RUN npm ci --omit=dev && npm cache clean --force

# ==============================================================================
# Stage 3: Build API
# ==============================================================================
FROM deps-base AS api-builder

WORKDIR /build/api

# Copy package files and install ALL dependencies (including dev for TypeScript)
COPY garbageman-nm/webui/api/package*.json ./
RUN npm ci && npm cache clean --force

# Copy source files
COPY garbageman-nm/webui/api/tsconfig.json ./
COPY garbageman-nm/webui/api/src ./src
COPY garbageman-nm/webui/api/data ./data

# Build TypeScript
RUN npm run build

# ==============================================================================
# Stage 4: Install UI Dependencies
# ==============================================================================
FROM deps-base AS ui-deps

WORKDIR /build/ui

# Copy package files
COPY garbageman-nm/webui/ui/package*.json ./

# Install production dependencies
RUN npm ci --omit=dev && npm cache clean --force

# ==============================================================================
# Stage 5: Build UI (Next.js)
# ==============================================================================
FROM deps-base AS ui-builder

WORKDIR /build/ui

# Copy package files and install ALL dependencies (including dev)
COPY garbageman-nm/webui/ui/package*.json ./
RUN npm ci && npm cache clean --force

# Copy source files
COPY garbageman-nm/webui/ui/next.config.js ./
COPY garbageman-nm/webui/ui/tsconfig.json ./
COPY garbageman-nm/webui/ui/postcss.config.js ./
COPY garbageman-nm/webui/ui/tailwind.config.ts ./
COPY garbageman-nm/webui/ui/next-env.d.ts ./
COPY garbageman-nm/webui/ui/src ./src
COPY garbageman-nm/webui/ui/public ./public

# Build Next.js with standalone output
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production
RUN npm run build

# ==============================================================================
# Stage 6: Install Supervisor Dependencies
# ==============================================================================
FROM deps-base AS supervisor-deps

WORKDIR /build/supervisor

# Copy package files
COPY garbageman-nm/multi-daemon/package*.json ./

# Install production dependencies
RUN npm ci --omit=dev && npm cache clean --force

# ==============================================================================
# Stage 7: Build Supervisor
# ==============================================================================
FROM deps-base AS supervisor-builder

WORKDIR /build/supervisor

# Copy package files and install ALL dependencies (including dev for TypeScript)
COPY garbageman-nm/multi-daemon/package*.json ./
RUN npm ci && npm cache clean --force

# Copy source files
COPY garbageman-nm/multi-daemon/tsconfig.json ./
COPY garbageman-nm/multi-daemon/*.ts ./
COPY garbageman-nm/multi-daemon/scripts ./scripts

# Build TypeScript
RUN npm run build

# ==============================================================================
# Stage 8: Runtime Image
# ==============================================================================
FROM node:20-alpine AS runtime

# Install runtime dependencies only
RUN apk add --no-cache \
    curl \
    unzip \
    xz \
    tini \
    supervisor \
    tor \
    zeromq \
    && rm -rf /var/cache/apk/*

# Create app directory structure
WORKDIR /app

# Copy API build artifacts
COPY --from=api-builder /build/api/dist ./api/dist
COPY --from=api-builder /build/api/data ./api/data
COPY --from=api-deps /build/api/node_modules ./api/node_modules
COPY --from=api-builder /build/api/package.json ./api/

# Copy UI build artifacts (Next.js standalone)
COPY --from=ui-builder /build/ui/.next/standalone ./ui/
COPY --from=ui-builder /build/ui/.next/static ./ui/.next/static
COPY --from=ui-builder /build/ui/public ./ui/public
COPY --from=ui-builder /build/ui/package.json ./ui/

# Copy Supervisor build artifacts
COPY --from=supervisor-builder /build/supervisor/dist ./supervisor/dist
COPY --from=supervisor-builder /build/supervisor/scripts ./supervisor/scripts
COPY --from=supervisor-deps /build/supervisor/node_modules ./supervisor/node_modules
COPY --from=supervisor-builder /build/supervisor/package.json ./supervisor/

# Copy entrypoint script
COPY docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod +x /usr/local/bin/docker_entrypoint.sh

# Copy supervisord config
COPY supervisord.conf /etc/supervisord.conf

# Health check on UI port
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5173/ || exit 1

# Expose ports (for documentation, StartOS handles actual mapping)
EXPOSE 5173 8080 9000

# Use tini as init system for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Start via entrypoint script
CMD ["docker_entrypoint.sh"]
