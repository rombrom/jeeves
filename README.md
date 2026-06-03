# Jeeves

A containerized coding agent "sandbox" via Apple Container.

## Prerequisites

- **Apple Container** — the container runtime. Read the install instructions on the [Apple Container GitHub](https://github.com/apple/container).

## Usage

Jeeves is a long-running container you can `exec` into for specific projects. It works best with a singular project root (e.g. `~/Code`) that maps transparently to the container's `WORKDIR` via a volume mount.

> **Note:** By default `CONTAINER=container`.

1. **Configure `.env`** — set `WORKDIR` to the mount path inside the container.
2. **Build the container** — `make build`
3. **Start the container** — `make run`
4. **Set up aliases** in your shell config:

   ```bash
   alias jeeves='container exec -it jeeves'
   alias qq='container exec -t jeeves mise exec node@26 -- pi -nt --thinking off -p'
   alias pi='container exec -it jeeves bash -c "cd $PWD && mise exec node@26 -- pi"'
   alias claude='container exec -it jeeves bash -c "cd $PWD && claude --dangerously-skip-permissions"'
   alias killjeeves='container kill jeeves'
   ```

5. **Use the aliases** — `jeeves` for interactive shell access, `pi` to run the agent from your project directory, `qq` for ad-hoc LLM queries, `claude` for claude.

### `make sync`

You can iterate on Jeeves and sync settings/config with `make sync`. The prerequisite is to have `JEEVESDIR` set in `.env`. This needs to point to the directory where you have `rombrom/jeeves` checked out and should be a descendant path of `WORKDIR`.

## Pi Configuration

Agent settings are managed via:

- **`config/agent/models.json`** — LLM provider configuration (models, base URLs, API keys)
- **`config/agent/settings.json`** — pi-coding-agent global settings (default provider, model, npm command)

To customize agent behavior, edit the corresponding `.md` files under `container/home/jeeves/.pi/agents/`. Changes are synced into the container via `make sync`.

## Architecture

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Host      │     │ Jeeves Container │     │  LLM Server     │
│             │     │                  │     │ (llama.cpp)     │
│ • .env      │────▶│ • pi-coding-agent│────▶│ :8484           │
│ • Makefile  │     │ • mise (Node 26) │     │ OpenAI-compat   │
│ • config/   │     │ • tools (nvim,   │     │ API             │
│             │◀────│   ripgrep, tmux) │◀────│                 │
└─────────────┘     └──────────────────┘     └─────────────────┘
         ▲                      │
         │ volume: config/      │ volume: ~/.pi (named)
         └──────────────────────┘
```

- **Host**: Your machine with `.env`, `Makefile`, and `config/` directory
- **Container**: Self-contained environment with pi-coding-agent, tools, and agent prompts
- **LLM Server**: llama.cpp (or any OpenAI-compatible API) providing inference

Data flows:

1. `config/` is mounted read-only into the container (`/config`)
2. Agent prompts in `container/` are rsynced into the container on startup
3. `~/.pi/` persists as a named volume (`jeeves-pi`) across runs
4. LLM calls go from the container to the host on port 8484

## Makefile Targets

```
  build        Build the Docker image
  run          Start the container (mounts local workspace)
  stop         Stop and remove the running container
  sync         Synchronize container filesystem with host
  clean        Remove the Docker image
  help         Show this help message
```
