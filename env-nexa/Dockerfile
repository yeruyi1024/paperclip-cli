# 20260627  fd2f82ac5bba6ce2db0c5d17c573733af5f2bbb8
# 20260518 ab8b471685bf17efd7d170cd43187c0318dcdeaa
# 20260509 4272c1604dd17955f37b4cc5db6672dffe75709c
# 20260426 4ef969f0840810527333aa6ee44fed89f4551f7c 
FROM node:lts-trixie-slim AS base
ARG USER_UID=1000
ARG USER_GID=1000
ARG DOCKER_GID=999
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources \
  && apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates gosu curl gh git wget ripgrep python3 python3-pip python3-venv docker.io \
  && rm -rf /var/lib/apt/lists/* \
  && corepack enable

# Modify the existing node user/group to have the specified UID/GID to match host user
RUN usermod -u $USER_UID --non-unique node \
  && groupmod -g $USER_GID --non-unique node \
  && (groupadd -g $DOCKER_GID docker || groupmod -g $DOCKER_GID docker || true) \
  && usermod -aG docker node \
  && usermod -g $USER_GID -d /paperclip node

RUN ARCH=$(dpkg --print-architecture) \
  && curl -fsSL "https://go.dev/dl/go1.24.0.linux-${ARCH}.tar.gz" -o go.tar.gz \
  && tar -C /usr/local -xzf go.tar.gz \
  && rm go.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
FROM base AS deps
WORKDIR /app
COPY package.json pnpm-workspace.yaml pnpm-lock.yaml .npmrc ./
COPY cli/package.json cli/
COPY server/package.json server/
COPY ui/package.json ui/
COPY packages/shared/package.json packages/shared/
COPY packages/db/package.json packages/db/
COPY packages/adapter-utils/package.json packages/adapter-utils/
COPY packages/mcp-server/package.json packages/mcp-server/
COPY packages/skills-catalog/package.json packages/skills-catalog/
COPY packages/teams-catalog/package.json packages/teams-catalog/
COPY packages/adapters/acpx-local/package.json packages/adapters/acpx-local/
COPY packages/adapters/claude-local/package.json packages/adapters/claude-local/
COPY packages/adapters/codex-local/package.json packages/adapters/codex-local/
COPY packages/adapters/cursor-cloud/package.json packages/adapters/cursor-cloud/
COPY packages/adapters/cursor-local/package.json packages/adapters/cursor-local/
COPY packages/adapters/gemini-local/package.json packages/adapters/gemini-local/
COPY packages/adapters/grok-local/package.json packages/adapters/grok-local/
COPY packages/adapters/hermes/package.json packages/adapters/hermes/
COPY packages/adapters/hermes-gateway/package.json packages/adapters/hermes-gateway/
COPY packages/adapters/openclaw-gateway/package.json packages/adapters/openclaw-gateway/
COPY packages/adapters/opencode-local/package.json packages/adapters/opencode-local/
COPY packages/adapters/pi-local/package.json packages/adapters/pi-local/
COPY packages/plugins/sdk/package.json packages/plugins/sdk/
COPY packages/plugins/sandbox-providers/./*/package.json packages/plugins/sandbox-providers/
COPY packages/plugins/paperclip-plugin-fake-sandbox/package.json packages/plugins/paperclip-plugin-fake-sandbox/
COPY packages/plugins/plugin-llm-wiki/package.json packages/plugins/plugin-llm-wiki/
COPY packages/plugins/plugin-workspace-diff/package.json packages/plugins/plugin-workspace-diff/
COPY patches/ patches/
COPY scripts/link-plugin-dev-sdk.mjs scripts/

RUN pnpm install --frozen-lockfile

FROM base AS build
WORKDIR /app
COPY --from=deps /app /app
COPY . .
RUN pnpm --filter @paperclipai/ui build
RUN pnpm --filter @paperclipai/plugin-sdk build
RUN pnpm --filter @paperclipai/server build
RUN test -f server/dist/index.js || (echo "ERROR: server build output missing" && exit 1)

FROM base AS production
ARG USER_UID=1000
ARG USER_GID=1000
WORKDIR /app
COPY --chown=node:node --from=build /app /app
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources \
  && npm config set registry https://registry.npmmirror.com \
  && npm install --global --omit=dev @anthropic-ai/claude-code@latest @openai/codex@latest opencode-ai @vue/cli degit @google/gemini-cli@latest \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
     openssh-client \
     jq \
  && rm -rf /var/lib/apt/lists/* \
  && export GOPATH=/usr/local/go \
  && export GOBIN=/usr/local/go/bin \
  && export GO111MODULE=on \
  && export GOPROXY=https://goproxy.cn,direct \
  && export PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple \
  && export PIP_BREAK_SYSTEM_PACKAGES=1 \
  && export UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple \
  && export PLAYWRIGHT_DOWNLOAD_HOST=https://npm.proxy.com.cn/playwright \
  && go install github.com/wailsapp/wails/v2/cmd/wails@latest \
  && mkdir -p /paperclip/.gemini/skills \
  && chown -R node:node /paperclip

# RUN curl -fsSL https://raw.githubusercontent.com/yeruyi1024/paperclip-cli/refs/heads/main/env-hermes/install.sh | bash -s -- --branch v2026.5.16  --install-user $USER_UID --skip-setup

COPY scripts/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV NODE_ENV=production \
  HOME=/paperclip \
  HOST=0.0.0.0 \
  PORT=3100 \
  SERVE_UI=true \
  PAPERCLIP_HOME=/paperclip \
  PAPERCLIP_INSTANCE_ID=default \
  USER_UID=${USER_UID} \
  USER_GID=${USER_GID} \
  PAPERCLIP_CONFIG=/paperclip/instances/default/config.json \
  PAPERCLIP_DEPLOYMENT_MODE=authenticated \
  PAPERCLIP_DEPLOYMENT_EXPOSURE=private \
  OPENCODE_ALLOW_ALL_MODELS=true \
  GEMINI_SANDBOX=false

EXPOSE 3100

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node", "--import", "./server/node_modules/tsx/dist/loader.mjs", "server/dist/index.js"]
