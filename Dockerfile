FROM debian:13-slim

ARG WORKDIR=/mnt/workdir

ENV TERM=xterm-256color
ENV SHELL=/usr/bin/bash
ENV PATH="/mise/shims:$PATH"

ENV MISE_DATA_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"

COPY container/. /

RUN <<EOF
  apt-get update

 # required libs, etc.
  apt-get install -qy \
    build-essential \
    ca-certificates \
    extrepo \
    libpq-dev \
    libyaml-dev \
    postgresql-client \
    zlib1g-dev

  # allows mise to be installed w/ apt-get
  extrepo enable mise
  apt-get remove -qy --auto-remove extrepo
  apt-get update

  # binaries
  apt-get install -qy \
    chromium \
    curl \
    git \
    gojq \
    fd-find \
    mise \
    neovim \
    netcat-openbsd \
    ripgrep \
    rsync \
    sudo \
    tree \
    tmux \
    wget

  rm -rf /var/lib/apt/lists/* \

  # `fd-find` installs the binary as `fdfind`
  ln -s $(which fdfind) /usr/local/bin/fd
  # `gojq` installs the binary as `gojq`
  ln -s $(which gojq) /usr/local/bin/jq

  mise install --system
EOF

WORKDIR ${WORKDIR}

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
