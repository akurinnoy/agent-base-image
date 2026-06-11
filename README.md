# agent-base-image

Base container image for agentic workspaces. Provides the runtime foundation that workspace containers need to host autonomous coding agents.

Part of the **Agentic Workspaces** ecosystem for running AI agents inside Eclipse Che cloud development workspaces.

## What It Provides

| Component | Source |
|-----------|--------|
| [Universal Developer Image](https://github.com/devfile/developer-images) | Base image with common dev tools |
| [chemuxer](https://github.com/che-incubator/chemuxer) | Web terminal multiplexer with split panes, tabs, and agent REST API (port 7681) |
| [gh CLI](https://github.com/cli/cli) | GitHub CLI for repository operations |

## Why It Exists

Coding agents need a web-accessible terminal with session management. This image bundles chemuxer (a browser-native terminal multiplexer with REST API for agent observability) on top of UDI so that workspaces have a working foundation before [tools-injector](https://github.com/che-incubator/tools-injector) adds coding agent binaries.

## Agent REST API

Chemuxer exposes a REST API on port 7681 for programmatic terminal access:

- `GET /agents.md` — discovery document for agents
- `GET /api/sessions` — list terminal sessions
- `POST /api/sessions` — create a new session
- `GET /api/sessions/:id/buffer` — read terminal output (ANSI stripped)
- `POST /api/sessions/:id/input` — send input to a session
- `GET /api/feed?since=<timestamp>` — activity feed

## Image

```
quay.io/che-incubator/agent-base-image:latest
```

Multi-arch: `linux/amd64`, `linux/arm64`

## Building Locally

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t agent-base-image .
```

## License

[EPL-2.0](LICENSE)
