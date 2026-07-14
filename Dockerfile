FROM debian:13-slim

ARG WORKDIR=/mnt/workdir

ENV TERM=xterm-256color
ENV SHELL=/usr/bin/bash
ENV PATH="/root/.local/bin:/mise/shims:$PATH"

ENV MISE_DATA_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"

COPY container/. /opt/defaults/

RUN apt-get update && apt-get install -qy \
  build-essential \
  ca-certificates \
  chromium \
  curl \
  dtach \
  git \
  gojq \
  fd-find \
  neovim \
  netcat-openbsd \
  ripgrep \
  rsync \
  sudo \
  tree \
  tmux \
  wget \
  # required for ruby stuff
  libpq-dev \
  libyaml-dev \
  postgresql-client \
  zlib1g-dev \
  && \
  rm -rf /var/lib/apt/lists/* \
  && \
  # `fd-find` installs the binary as `fdfind`
  ln -s $(which fdfind) /usr/local/bin/fd && \
  # `gojq` installs the binary as `gojq`
  ln -s $(which gojq) /usr/local/bin/jq

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN curl https://mise.run | sh
RUN mise trust -a && mise install

RUN mise exec node@26 -- npm install -g @earendil-works/pi-coding-agent && \
  mise exec node@26 -- pi install npm:pi-subagents && \
  mkdir -p /root/.pi/agent/extensions && \
  for f in plan-mode question.ts questionnaire.ts todo.ts; do \
  ln -sf $(mise exec node@26 -- npm root -g)/@earendil-works/pi-coding-agent/examples/extensions/$f /root/.pi/agent/extensions/$f; \
  done && \
  find /root/.pi -iname package.json ! -path "*/node_modules/*" -execdir mise exec node@26 -- npm install \;

# Apply all patches in ~/.pi to their corresponding files
RUN find /root/.pi -name "*.patch" -type f | while read -r patchfile; do \
  patchdir=$(dirname "$patchfile"); \
  basename=$(basename "$patchfile" .patch); \
  cd "$patchdir" && [ -f "$basename" ] && patch < "$patchfile"; \
  done

RUN curl -fsSL https://claude.ai/install.sh | bash

WORKDIR ${WORKDIR}

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
