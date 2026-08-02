# Pi + Feynman research container
#
# Base image is pinned to an exact patch so `docker compose build --no-cache`
# is reproducible. Pi requires Node.js >= 22.19.0 (see its installer's
# preflight check), so a 22.x line is the minimum viable choice.
FROM node:22.23.2-bookworm-slim

# Version pins. Override at build time with:
#   docker compose build --build-arg FEYNMAN_VERSION=0.3.9
# Use "latest" to track the newest release (not recommended for reproducibility).
ARG FEYNMAN_VERSION=0.3.10
ARG PI_VERSION=0.83.0

# Default model, baked into the image so a fresh install starts on a
# good-value model instead of an expensive one.
#
# Must be an ID that appears in `feynman model list` — Pi ships a curated
# OpenRouter catalogue that lags OpenRouter's live list, so some real
# OpenRouter IDs (e.g. deepseek-v4-pro, deepseek-v4-flash-0731) are rejected
# with "Model not available in Pi auth storage".
ARG DEFAULT_MODEL=openrouter/deepseek/deepseek-v4-flash

# UID/GID of the user that owns ./workspace on the host. Must match, or the
# non-root user inside the container cannot write to the bind mount.
ARG USER_UID=1000
ARG USER_GID=1000

# curl: both installers fetch over HTTPS
# ca-certificates: TLS verification for the above
# tar: Feynman ships a tar.gz bundle
# git: Pi shells out to it for repo-aware operations
# less: Pi's pager
# procps: `ps`, used by some agent tooling
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        tar \
        git \
        less \
        procps \
    && rm -rf /var/lib/apt/lists/*

# The node image already ships a `node` user at uid/gid 1000. Rename it to
# `agent` and relocate its home rather than creating a second user, so the
# container user lands on uid 1000 and matches the host owner of ./workspace.
RUN if [ "$(id -u node)" != "${USER_UID}" ] || [ "$(id -g node)" != "${USER_GID}" ]; then \
        groupmod -g "${USER_GID}" node && \
        usermod -u "${USER_UID}" -g "${USER_GID}" node; \
    fi && \
    groupmod -n agent node && \
    usermod -l agent -d /home/agent -m node

USER agent
WORKDIR /home/agent

# Both installers place binaries in ~/.local/bin:
#   - Pi: npm's global prefix (/usr/local) is root-owned and therefore not
#     writable by `agent`, so its installer falls back to --prefix $HOME/.local
#   - Feynman: installs to $HOME/.local/bin unconditionally
# The installers append a PATH line to a shell profile, but profiles are not
# sourced by non-login/non-interactive shells (e.g. `docker compose run
# --entrypoint bash`). Setting PATH via ENV makes it apply to every shell.
ENV PATH="/home/agent/.local/bin:${PATH}"

# Create the config directories in the image so the named volumes mounted over
# them inherit `agent` ownership. Docker seeds an empty named volume from the
# image's directory (including its owner); without these, the volumes would be
# created root-owned and the agent could not write config.
RUN mkdir -p /home/agent/.pi/agent \
             /home/agent/.feynman \
             /home/agent/.ahub \
             /home/agent/workspace

# Pi. Installed via npm directly rather than the pi.dev shell installer so the
# version can be pinned — the installer always resolves "latest" and offers no
# version argument. --ignore-scripts and --min-release-age=0 mirror what the
# official installer does (Pi publishes npm-shrinkwrap.json, so pinning here
# does not reopen transitive dependency ranges).
RUN npm install -g --ignore-scripts --min-release-age=0 \
        --prefix /home/agent/.local \
        --no-fund --no-audit \
        "@earendil-works/pi-coding-agent@${PI_VERSION}" \
    && npm cache clean --force

# Feynman. The official installer takes the version as a positional argument
# and verifies the download's SHA-256 against the release's SHA256SUMS, so it
# is worth using rather than reimplementing.
# FEYNMAN_INSTALL_SKIP_PATH_UPDATE: PATH is already set via ENV above; this
# stops the installer writing a redundant line into ~/.profile.
RUN FEYNMAN_INSTALL_SKIP_PATH_UPDATE=1 \
    sh -c 'curl -fsSL https://feynman.is/install | sh -s -- "$0"' "${FEYNMAN_VERSION}"

# Fail the build rather than shipping an image where either binary is missing
# from a fresh shell's PATH.
RUN pi --version && feynman --version

# Bake the default model into the image's ~/.feynman/agent/settings.json.
# Docker seeds an empty named volume from the image, so a first-time user gets
# this default; an EXISTING feynman-config volume keeps whatever it already has
# and is not affected by a rebuild (change it with `feynman model set`).
#
# `model set` validates against the authenticated model list, which requires an
# OpenRouter key to be present. There is no key at build time, so a throwaway
# placeholder is supplied for this step only. It is never used for a request
# and is not persisted anywhere — the real key arrives via the environment at
# run time.
RUN OPENROUTER_API_KEY=placeholder-build-time-only \
    feynman model set "${DEFAULT_MODEL}" \
    && grep -q defaultModel /home/agent/.feynman/agent/settings.json

WORKDIR /home/agent/workspace

# Feynman is the research shell this container exists for; it runs Pi
# underneath with its own config root. Run bare `pi` with:
#   docker compose run --rm --entrypoint pi pi-feynman
CMD ["feynman"]
