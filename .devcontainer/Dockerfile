# syntax=docker/dockerfile:1.4
FROM mcr.microsoft.com/devcontainers/base:bookworm

ARG OVERMIND_VERSION=v2.5.1

RUN apt-get update -qq \
    && apt-get install --no-install-recommends -y fonts-noto-cjk libjemalloc2 tmux \
    && rm -rf /var/lib/apt/lists/*

# Install overmind (arch-aware)
RUN ARCH=$(dpkg --print-architecture) \
    && OVERMIND_ARCH=$([ "${ARCH}" = "amd64" ] && echo "linux-amd64" || echo "linux-arm64") \
    && curl -fsSL "https://github.com/DarthSim/overmind/releases/download/${OVERMIND_VERSION}/overmind-${OVERMIND_VERSION}-${OVERMIND_ARCH}.gz" \
       | gunzip > /usr/local/bin/overmind \
    && chmod +x /usr/local/bin/overmind
