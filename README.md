# agentic-base-image

Base container image for agentic workspaces. Provides the runtime foundation that workspace containers need to host autonomous coding agents.

Part of the **Agentic Workspaces** ecosystem for running AI agents inside Eclipse Che cloud development workspaces.

## What It Provides

| Component | Version | Source |
|-----------|---------|--------|
| [Universal Developer Image](https://github.com/devfile/developer-images) | ubi9-latest | Base image with common dev tools |
| [ttyd](https://github.com/tsl0922/ttyd) | 1.7.8 | Web terminal server (port 7681) |
| [tmux](https://github.com/tmux/tmux) | 3.6a | Terminal multiplexer for agent session management |

## Why It Exists

Coding agents need a terminal multiplexer (`tmux`) for session management and a web terminal (`ttyd`) for browser access. This image bundles both on top of UDI so that workspaces have a working foundation before [tools-injector](https://github.com/che-incubator/tools-injector) adds coding agent binaries.

## Image

```
quay.io/che-incubator/agentic-base-image:latest
```

Multi-arch: `linux/amd64`, `linux/arm64`

## Building Locally

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t agentic-base-image .
```

## License

[EPL-2.0](LICENSE)
