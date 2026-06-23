FROM quay.io/devfile/universal-developer-image:ubi9-latest

USER 0

ARG TARGETARCH

# Install GitHub CLI
ARG GH_VERSION=2.92.0
RUN ARCH=$(case "${TARGETARCH}" in \
      amd64) echo "amd64" ;; \
      arm64) echo "arm64" ;; \
      *) echo "unsupported TARGETARCH=${TARGETARCH}" >&2; exit 1 ;; \
    esac) && \
    curl -fsSL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_checksums.txt" \
      -o /tmp/gh_checksums.txt && \
    curl -fsSL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${ARCH}.tar.gz" \
      -o /tmp/gh.tar.gz && \
    EXPECTED=$(grep "gh_${GH_VERSION}_linux_${ARCH}.tar.gz" /tmp/gh_checksums.txt | awk '{print $1}') && \
    ACTUAL=$(sha256sum /tmp/gh.tar.gz | awk '{print $1}') && \
    [ "$EXPECTED" = "$ACTUAL" ] || (echo "Checksum mismatch for gh CLI!" >&2; exit 1) && \
    tar xz --strip-components=2 -C /usr/local/bin -f /tmp/gh.tar.gz "gh_${GH_VERSION}_linux_${ARCH}/bin/gh" && \
    rm /tmp/gh.tar.gz /tmp/gh_checksums.txt && \
    gh --version

# Allow root-group writes to /etc/profile.d/ for postStart hook (injected-tools)
RUN chmod 775 /etc/profile.d/

# Install node-pty native addon (built for UDI/RHEL glibc platform)
# Chemuxer's JS bundle is injected via shared volume, but node-pty must be
# compiled for the target platform — Alpine-built binaries are incompatible.
RUN source /home/tooling/.nvm/nvm.sh && \
    npm install --prefix /usr/share/node-pty node-pty@1.1.0

# Install tini for proper PID 1 zombie reaping
ARG TINI_VERSION=v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini

USER 1001

ENTRYPOINT ["/usr/local/bin/tini", "--"]
