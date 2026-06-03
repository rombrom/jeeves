FROM debian:13-slim

ARG JEEVES_USER=jeeves
ARG JEEVES_HOME=/home/jeeves
ARG PI_EXAMPLE_EXTENSIONS="plan-mode question.ts questionnaire.ts todo.ts"
ARG WORKDIR=/home/jeeves

ENV TERM=xterm-256color
ENV SHELL=/usr/bin/bash
ENV PATH="${JEEVES_HOME}/.local/bin:/mise/shims:$PATH"

ENV MISE_DATA_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
ENV MISE_SHELL=bash

# Create user with sudo access
RUN groupadd -g 1000 ${JEEVES_USER} && \
  useradd -m -g ${JEEVES_USER} -u 1000 -s /usr/bin/bash ${JEEVES_USER}

COPY container/. /
RUN chown -R ${JEEVES_USER}:${JEEVES_USER} ${JEEVES_HOME}

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
  # Symlink pi-coding-agent example extensions into ~/.pi/agent/extensions
  mkdir -p ${JEEVES_HOME}/.pi/agent/extensions && \
  for f in $PI_EXAMPLE_EXTENSIONS; do \
  ln -sf $(mise exec node@26 -- npm root -g)/@earendil-works/pi-coding-agent/examples/extensions/$f ${JEEVES_HOME}/.pi/agent/extensions/$f; \
  done && \
  # Install all .pi package dependencies
  find ${JEEVES_HOME}/.pi -iname package.json ! -path "*/node_modules/*" -execdir mise exec node@26 -- npm install \;

# Apply all patches in ~/.pi to their corresponding files
RUN find ${JEEVES_HOME}/.pi -name "*.patch" -type f | while read -r patchfile; do \
  patchdir=$(dirname "$patchfile"); \
  basename=$(basename "$patchfile" .patch); \
  cd "$patchdir" && [ -f "$basename" ] && patch < "$patchfile"; \
  done

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER ${JEEVES_USER}
WORKDIR ${JEEVES_HOME}

RUN curl -fsSL https://claude.ai/install.sh | bash

WORKDIR ${WORKDIR}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
