###########################################################
# Docker Hardened Images (DHI) — Node.js
#
# Build/dev stages use the *-dev* variant, which includes a
# shell and npm. The final runtime stage uses the minimal DHI
# image (no shell, no package manager, non-root by default).
#
# Override the ARGs below to match your DHI access path:
#   Community (dhi.io):   dhi.io/node:22-debian12[-dev]
#   Mirrored org:         docker.io/<org>/dhi-node:22-debian12[-dev]
#
# Before building, authenticate:
#   Community:  docker login dhi.io
#   Mirrored:   docker login   (Hub login, then use --build-arg)
###########################################################
ARG DHI_DEV_IMAGE=dhi.io/node:22-debian12-dev
ARG DHI_RUNTIME_IMAGE=dhi.io/node:22-debian12


###########################################################
# Stage: base
#
# Shared foundation for dev and build stages. Uses the -dev
# variant so npm and a shell are available.
###########################################################
FROM ${DHI_DEV_IMAGE} AS base

WORKDIR /usr/local/app
# DHI images already run as a non-root `node` user; copy
# package manifests with its ownership so npm can write.
COPY --chown=node:node package.json package-lock.json ./


###########################################################
# Stage: dev
#
# Development image: installs all dependencies (including
# devDependencies) and watches for file changes via nodemon.
# Bind-mount ./src at runtime to pick up edits live:
#   docker run -v ./src:/usr/local/app/src <image>
###########################################################
FROM base AS dev
ENV NODE_ENV=development
RUN npm install
CMD ["npm", "run", "dev-container"]


###########################################################
# Stage: build
#
# Installs production-only dependencies, then copies the
# application source. Output is consumed by the final stage.
###########################################################
FROM base AS build
ENV NODE_ENV=production
RUN npm ci --omit=dev --ignore-scripts
COPY --chown=node:node ./src ./src


###########################################################
# Stage: final
#
# Minimal DHI runtime image (no shell, no npm). Only the
# production node_modules and application source are present.
# Non-root `node` user is the default; no further USER needed.
#
# NOTE: The DHI Node runtime image sets ENTRYPOINT to `node`,
# so CMD only needs the script path — not "node src/index.js".
# If your runtime image does NOT set this entrypoint, change
# CMD to: ["node", "src/index.js"]
###########################################################
FROM ${DHI_RUNTIME_IMAGE} AS final
ENV NODE_ENV=production
WORKDIR /usr/local/app
COPY --from=build --chown=node:node /usr/local/app/node_modules ./node_modules
COPY --from=build --chown=node:node /usr/local/app/package.json ./package.json
COPY --from=build --chown=node:node /usr/local/app/src ./src

EXPOSE 3000

CMD ["src/index.js"]
