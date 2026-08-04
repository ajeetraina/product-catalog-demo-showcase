###########################################################
# Build stage — compile the React / Vite application.
#
# DHI recommendation: node:22.17.0-slim
###########################################################
FROM node:22.17.0-slim AS build

WORKDIR /app

# Install dependencies first (cache-friendly layer order)
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy source and produce optimised static bundle
COPY . .
RUN yarn build

###########################################################
# Runtime stage — serve the built assets with nginx.
#
# DHI recommendation: nginxinc/nginx-unprivileged:1.27.5-alpine3.21
# This variant runs as a non-root user on port 8080 and is
# significantly smaller than the full nginx image.
###########################################################
FROM nginxinc/nginx-unprivileged:1.27.5-alpine3.21 AS runtime

# Replace the default nginx virtual-host config with our own
# (SPA routing + /api reverse-proxy to the catalog service)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled static assets from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 8080

# wget is available in the alpine nginx image
HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
