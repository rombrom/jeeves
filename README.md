# Jeeves

A containerized coding agent "sandbox" via Apple Container.

## Prerequisites

- **Apple Container** — the container runtime. Read the install instructions on the [Apple Container GitHub](https://github.com/apple/container).
- **LLM Server** — a local llama.cpp (or similar) instance serving an OpenAI-compatible API on port 8484.

## Usage

Jeeves is a long-running container you can `exec` into for specific projects. It works best with a singular project root (e.g. `~/Code`) that maps transparently to the container via a volume mount.

> **Note:** By default `CONTAINER=container`.

1. **Configure `.env`** — copy `.env.example` to `.env` and set `WORKDIR` to your host workspace path (e.g. `/Users/rombrom/Code`). `WORKDIR` must be the same on both host and container so git worktrees resolve correctly.

2. **Build the container** — `make build`

3. **Start the container** — `make run`

4. **Set up aliases** in your shell config:

   ```bash
   alias jeeves='container exec -it jeeves'
   alias qq='container exec -t jeeves pi -nt --thinking off -p'
   alias pi='container exec -it jeeves bash -c "cd $PWD && pi"'
   alias claude='container exec -it jeeves bash -c "cd $PWD && claude"'
   alias killjeeves='container kill jeeves'
   ```

5. **Use the aliases** — `jeeves` for interactive shell access, `pi` to run the agent from your project directory, `qq` for ad-hoc LLM queries, `claude` for Claude CLI.

### `make sync`

Syncs repo-managed config and applies sysctl settings inside the running container:

```bash
make sync
```

## Pi Configuration

Agent settings are managed via the `config/` directory, which maps to `/root/` inside the container. Any Pi, Claude, or dotfile-based config placed here will override the base-image defaults from `container/`.

- **`config/.pi/agent/models.json`** — LLM provider configuration (models, base URLs, API keys)
- **`config/.pi/agent/settings.json`** — pi-coding-agent global settings (default provider, model, npm command)
- **`config/.pi/agent/prompts/`** — custom agent prompts
- **`config/.pi/agent/skills/`** — custom agent skills
- **`config/.pi/agent/agents/`** — custom agent type definitions

To customize agent behavior, edit files under `config/` and run `make sync`.

## Base-Image Configurations

The `container/` directory houses base-image configurations that are rsynced into the container on startup via `entrypoint.sh`. These provide default dotfile settings that can be overridden by files in `config/`.

> **Note:** `entrypoint.sh` also installs dynamic Pi packages listed in `~/.pi/agent/settings.json` at runtime via `pi install`.

| Path in `container/`           | Mapped to                       | Purpose                            |
| ------------------------------ | ------------------------------- | ---------------------------------- |
| `etc/sysctl.d/fs.inotify.conf` | `/etc/sysctl.d/fs.inotify.conf` | Kernel parameters (inotify limits) |
| `root/.bashrc`                 | `/root/.bashrc`                 | Shell aliases (git, mise, pi)      |
| `root/.gitconfig`              | `/root/.gitconfig`              | Git user identity                  |
| `root/.claude/settings.json`   | `/root/.claude/settings.json`   | Claude CLI sandbox config          |
| `etc/mise/config.toml`         | `/etc/mise/config.toml`         | mise config (latest)               |
| `root/.config/nvim/init.lua`   | `/root/.config/nvim/init.lua`   | Neovim OSC 52 clipboard config     |

## Architecture

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Host      │     │ Jeeves Container │     │  LLM Server     │
│             │     │                  │     │ (llama.cpp)     │
│ • .env      │────▶│ • pi-coding-agent│────▶│ :8484           │
│ • Makefile  │     │ • mise (latest)  │     │ OpenAI-compat   │
│ • config/   │     │ • tools (nvim,   │     │ API             │
│             │◀────│   ripgrep, tmux) │◀────│                 │
└─────────────┘     └──────────────────┘     └─────────────────┘
         ▲                      │
         │ volume: config/      │ volume: ~/.pi (named)
         │ (→ /root/)           │ volume: ~/.claude (named)
         └──────────────────────┘
```

- **Host**: Your machine with `.env`, `Makefile`, and `config/` directory
- **Container**: Self-contained environment with pi-coding-agent, tools, and base-image configurations
- **LLM Server**: llama.cpp (or any OpenAI-compatible API) providing inference

Data flows:

1. `config/` is mounted read-only into the container and rsynced to `/root/` (override dotfiles)
2. `container/` defaults are rsynced into the container on startup (base-image dotfiles)
3. `~/.pi/` persists as a named volume (`jeeves-pi`) across runs
4. `~/.claude/` persists as a named volume (`jeeves-claude`) across runs
5. LLM calls go from the container to the host on port 8484

### SSH Forwarding

The `run` target includes `--ssh` to forward your host SSH agent into the container. This is a **known security trade-off**: it enables git operations that require SSH keys but also exposes those keys to the container runtime. If you do not need SSH access inside the container, remove `--ssh` from the `run` target in the Makefile.

## Makefile Targets

```
  build        Build the Docker image
  run          Start the container (mounts local workspace, stops existing first)
  start        Start a stopped container if it exists
  stop         Stop the running container
  kill         Stop and delete the container
  sync         Synchronize container filesystem with host
  clean        Remove the Docker image
  help         Show this help message
```

## Testing

The project includes a [BATS](https://bats-core.readthedocs.io/) test suite under `test/`:

```bash
# Run all tests
bats test/

# Run only build verification
bats test/build.bats

# Run runtime checks (spins up a container, verifies binaries)
bats test/image.bats
```

**Test coverage:**

| File              | What it checks                                                                                                                                                                  |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `test/build.bats` | Container image builds successfully                                                                                                                                             |
| `test/image.bats` | Image starts, hostname resolves, bash works, and all 12 required binaries are available (`claude`, `curl`, `fd`, `git`, `jq`, `mise`, `nc`, `pi`, `psql`, `rg`, `tree`, `wget`) |

**Prerequisites:** BATS must be installed (managed via `mise.toml` — run `mise install bats`).
