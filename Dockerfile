ARG BASE_VERSION=latest
FROM ghcr.io/openhands/agent-canvas:${BASE_VERSION}

ENV UV_NO_CACHE=1

# Install Python 3.12 as default
RUN uv python install 3.12 --default

# Install Node.js v24
USER root
RUN mkdir -p /var/lib/apt/lists/partial \
    && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nodesource.list

USER openhands