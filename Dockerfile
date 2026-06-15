FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="WojakCoin Core" \
      org.opencontainers.image.description="WojakCoin Core daemon (wojakcoind) packaged for Docker" \
      org.opencontainers.image.source="https://github.com/WojakCoinProj/docker-wojakcoin-core" \
      org.opencontainers.image.licenses="MIT"

# Client version (CLIENT_VERSION in wojakcore) and the GitHub release that
# ships the matching Linux x86_64 binaries.
ENV WOJAKCOIN_VERSION=1.12.1
ENV WOJAKCOIN_RELEASE=1.0.1.2
ENV WOJAKCOIN_DATA=/root/.wojakcoin
ENV PATH=/opt/wojakcoin/bin:$PATH

# SHA256 checksums of the official release binaries (verified at build time).
ENV WOJAKCOIND_SHA256=4a6560275a0474c86e9492fbe79485f1e33dc2d909350887160a02943c1aa1fa \
    WOJAKCOIN_CLI_SHA256=59fe953cf3c065eac44f42e9e81f7d873ea892f2e95ff599861566a73fcd7c4d \
    WOJAKCOIN_TX_SHA256=b4cb5d48d57c0fef7857f15cd4c62d740b3b4e75ef6a07f22b9697c991d45705

RUN set -ex \
  && apt-get update -y \
  && apt-get install -y --no-install-recommends ca-certificates curl libstdc++6 libgcc-s1 \
  && mkdir -p /opt/wojakcoin/bin \
  && base="https://github.com/WojakCoinProj/wojakcore/releases/download/${WOJAKCOIN_RELEASE}" \
  && curl -fSL -o /opt/wojakcoin/bin/wojakcoind    "${base}/wojakcoind" \
  && curl -fSL -o /opt/wojakcoin/bin/wojakcoin-cli "${base}/wojakcoin-cli" \
  && curl -fSL -o /opt/wojakcoin/bin/wojakcoin-tx  "${base}/wojakcoin-tx" \
  && echo "${WOJAKCOIND_SHA256}  /opt/wojakcoin/bin/wojakcoind"     | sha256sum -c - \
  && echo "${WOJAKCOIN_CLI_SHA256}  /opt/wojakcoin/bin/wojakcoin-cli" | sha256sum -c - \
  && echo "${WOJAKCOIN_TX_SHA256}  /opt/wojakcoin/bin/wojakcoin-tx"   | sha256sum -c - \
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
