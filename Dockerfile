###########################################################
# Base stage — shared foundation for all build stages.
#
# DHI (Docker Hub Images) MCP recommendation: node:22.17.0-slim
# This is the official Node.js 22 LTS slim image, minimal
# Debian-based, chosen for its small footprint and long-term
# support status.
###########################################################
FROM node:22.17.0-slim AS base

# Create a dedicated non-root user to run the app
RUN groupadd --gid 1001 appuser \
 && useradd --uid 1001 --gid 1001 --no-create-home appuser

WORKDIR /usr/local/app

###########################################################
# Deps stage — install only production dependencies.
# Isolated so that "npm ci" is re-run only when package
# manifests change, not on every source-code change.
###########################################################
FROM base AS deps

# Copy manifests first for maximum layer-cache reuse
COPY package.json package-lock.json ./

# Install production deps only; skip lifecycle scripts
# (prevents "husky install" from running during image build)
RUN npm ci --omit=dev --ignore-scripts \
 && npm cache clean --force

###########################################################
# Final / production stage — lean runtime image
###########################################################
FROM base AS final

ENV NODE_ENV=production

# Pull pre-installed node_modules from the deps stage
COPY --from=deps --chown=appuser:appuser \
     /usr/local/app/node_modules ./node_modules

# Application metadata
COPY --chown=appuser:appuser package.json ./

# Application source (COPY not ADD — explicit, auditable)
COPY --chown=appuser:appuser ./src ./src

# Drop privileges; run as non-root
USER appuser

EXPOSE 3000

# Pure-node healthcheck — no extra tooling required in slim image
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
  CMD node -e "\
    require('http').get('http://localhost:3000/', (r) => \
      process.exit(r.statusCode === 200 ? 0 : 1) \
    ).on('error', () => process.exit(1))"

CMD ["node", "src/index.js"]
