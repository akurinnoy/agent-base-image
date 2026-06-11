# Stage 1: Build chemuxer from source
FROM node:22-alpine AS chemuxer-build

RUN apk add --no-cache python3 make g++ pkgconf pixman-dev cairo-dev pango-dev git
WORKDIR /build

# Clone chemuxer PR #4 branch (agent observability REST API)
RUN git clone --branch feature/agent-observability --depth 1 \
    https://github.com/che-incubator/chemuxer.git .

RUN npm ci
# Remove test files to avoid TypeScript compilation errors in Docker build
RUN rm -rf server/src/__tests__ client/src/__tests__ 2>/dev/null || true
RUN npm run build

# Production dependencies only
RUN npm ci --omit=dev

# Stage 2: Final image
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

# Copy chemuxer build output and production dependencies
COPY --from=chemuxer-build /build/dist /usr/share/chemuxer/dist
COPY --from=chemuxer-build /build/node_modules /usr/share/chemuxer/node_modules
COPY --from=chemuxer-build /build/package.json /usr/share/chemuxer/package.json

USER 1001

ENV HOST=0.0.0.0
ENV STATIC_DIR=/usr/share/chemuxer/dist/client

EXPOSE 7681
CMD ["node", "/usr/share/chemuxer/dist/server/server/src/main.js"]
