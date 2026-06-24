FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="WojakCoin Core" \
      org.opencontainers.image.description="WojakCoin Core daemon (wojakcoind) packaged for Docker" \
      org.opencontainers.image.source="https://github.com/WojakCoinProj/docker-wojakcoin-core" \
      org.opencontainers.image.licenses="MIT"

# Client version (CLIENT_VERSION in wojakcore) and the GitHub release that
# ships the matching Linux release binaries.
ENV WOJAKCOIN_VERSION=1.12.1.0
ENV WOJAKCOIN_RELEASE=1.12.1.0
ENV WOJAKCOIN_DATA=/root/.wojakcoin
ENV PATH=/opt/wojakcoin/bin:$PATH

# Target architecture, provided automatically by `docker buildx` for each
# platform in a multi-platform build (e.g. amd64, arm64).
ARG TARGETARCH

# Download the per-architecture release binaries and verify their SHA256 checksums:
#   amd64 -> wojakcoind / wojakcoin-cli / wojakcoin-tx
#   arm64 -> *-aarch64 variants (built from the release commit via the depends system)
RUN set -ex \
  && apt-get update -y \
  && apt-get install -y --no-install-recommends ca-certificates curl libstdc++6 libgcc-s1 \
  && mkdir -p /opt/wojakcoin/bin \
  && base="https://github.com/WojakCoinProj/wojakcore/releases/download/${WOJAKCOIN_RELEASE}" \
  && case "$TARGETARCH" in \
       amd64) suffix="" ; \
              d_sha=4a6560275a0474c86e9492fbe79485f1e33dc2d909350887160a02943c1aa1fa ; \
              c_sha=59fe953cf3c065eac44f42e9e81f7d873ea892f2e95ff599861566a73fcd7c4d ; \
              t_sha=b4cb5d48d57c0fef7857f15cd4c62d740b3b4e75ef6a07f22b9697c991d45705 ;; \
       arm64) suffix="-aarch64" ; \
              d_sha=ed703d62c93ce5b289be3098200228159f94d72898e42f5f8d9f206c54275b3d ; \
              c_sha=c2e22656da13cccf19d3692fc472909381212c2c047360bb4eba8dac027eddd1 ; \
              t_sha=6f319c04847dbe077ad7969467621788c4462056beb522c5a95514d5dbcfbcf2 ;; \
       *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2 ; exit 1 ;; \
     esac \
  && curl -fSL -o /opt/wojakcoin/bin/wojakcoind    "${base}/wojakcoind${suffix}" \
  && curl -fSL -o /opt/wojakcoin/bin/wojakcoin-cli "${base}/wojakcoin-cli${suffix}" \
  && curl -fSL -o /opt/wojakcoin/bin/wojakcoin-tx  "${base}/wojakcoin-tx${suffix}" \
  && echo "${d_sha}  /opt/wojakcoin/bin/wojakcoind"     | sha256sum -c - \
  && echo "${c_sha}  /opt/wojakcoin/bin/wojakcoin-cli"  | sha256sum -c - \
  && echo "${t_sha}  /opt/wojakcoin/bin/wojakcoin-tx"   | sha256sum -c - \
  && chmod +x /opt/wojakcoin/bin/* \
  && apt-get purge -y --auto-remove curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/root/.wojakcoin"]

# RPC / P2P ports: mainnet 20760/20759, testnet 30760/30759, regtest 18444; ZMQ 28332
EXPOSE 20759 20760 30759 30760 18444 28332

ENTRYPOINT ["/entrypoint.sh"]

# Fail the build if the daemon cannot execute.
RUN wojakcoind -version | grep -i "WojakCore Daemon"

CMD ["wojakcoind"]
