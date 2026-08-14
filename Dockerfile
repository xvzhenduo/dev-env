ARG CODE_SERVER_TAG=latest
FROM codercom/code-server:${CODE_SERVER_TAG}

# 修改扩展市场
# ENV EXTENSIONS_GALLERY={"serviceUrl":"https://marketplace.visualstudio.com/_apis/public/gallery","cacheUrl":"https://vscode.blob.core.windows.net/gallery/index","itemUrl":"https://marketplace.visualstudio.com/items"}

SHELL ["/bin/bash", "-c"]

# 切换到root
USER root

# 安装 nvm
ENV NVM_DIR=/usr/local/nvm \
    NODE_VERSION=24

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl git && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p "$NVM_DIR" && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# 使用 nvm 安装 node v24 并设为默认版本
RUN source "$NVM_DIR/nvm.sh" && \
    nvm install "$NODE_VERSION" && \
    nvm alias default "$NODE_VERSION" && \
    nvm use default && \
    ln -sfn "$(dirname "$(nvm which default)")" /usr/local/node-bin

ENV PATH="/usr/local/node-bin:$PATH"

# 安装 uv 并使用 uv 安装 python 3.12 作为默认版本
ENV UV_INSTALL_DIR=/usr/local/bin \
    UV_PYTHON_INSTALL_DIR=/usr/local/share/uv/python

RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    uv python install 3.12 --default && \
    chmod -R a+rX /usr/local/share/uv

# 恢复默认用户
USER coder

# 设置国内镜像源（容器运行在国内服务器上时生效）
ENV NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node \
    UV_DEFAULT_INDEX=https://pypi.tuna.tsinghua.edu.cn/simple \
    UV_PYTHON_INSTALL_MIRROR=https://gh-proxy.com/https://github.com/astral-sh/python-build-standalone/releases/download \
    UV_LINK_MODE=copy

# 复制 entrypoint 脚本到 /home/coder/entrypoint.d
COPY --chown=coder:coder entrypoint/ /home/coder/entrypoint.d/
RUN chmod -R +x /home/coder/entrypoint.d/
