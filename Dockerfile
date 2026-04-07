FROM docker.io/tsl0922/ttyd:1.7.8-alpine AS ttyd

FROM quay.io/devfile/universal-developer-image:ubi9-latest

USER 0

ARG TARGETARCH
ARG TMUX_VERSION=3.6a

RUN ARCH=$(case "${TARGETARCH}" in amd64) echo "x86_64" ;; arm64) echo "arm64" ;; *) echo "${TARGETARCH}" ;; esac) && \
    curl -fsSL "https://github.com/tmux/tmux-builds/releases/download/v${TMUX_VERSION}/tmux-${TMUX_VERSION}-linux-${ARCH}.tar.gz" \
      | tar xz -C /usr/bin tmux

COPY --from=ttyd /usr/bin/ttyd /usr/bin/ttyd

USER 1001

EXPOSE 7681
CMD ["/usr/bin/ttyd", "-W", "-p", "7681", "bash"]
