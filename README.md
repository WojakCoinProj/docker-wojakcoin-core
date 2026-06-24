# docker-wojakcoin-core

A Docker image for [WojakCoin Core](https://github.com/WojakCoinProj/wojakcore) (`wojakcoind`),
modelled on [ruimarinho/docker-bitcoin-core](https://github.com/ruimarinho/docker-bitcoin-core).

The image is **multi-platform** (`linux/amd64` and `linux/arm64`). For each
platform it downloads the matching official release binaries (`wojakcoind`,
`wojakcoin-cli`, `wojakcoin-tx`) and verifies their SHA256 checksums at build time.
The `arm64` binaries are built from the exact same source commit as the release
using WojakCore's own `depends` system, so they are statically linked the same
way as the published `amd64` binaries.

- **Image:** `reallyshadydev/wojakcoin-core:1.12.1.0`
- **Platforms:** `linux/amd64`, `linux/arm64`
- **Client version:** `1.12.1.0` (WojakCore `CLIENT_VERSION`)
- **Release:** [`1.12.1.0`](https://github.com/WojakCoinProj/wojakcore/releases/tag/1.12.1.0)
- **Data directory:** `/root/.wojakcoin` (config file `wojakcoin.conf`)

## Ports

| Network | RPC | P2P |
|---------|------|------|
| mainnet | 20760 | 20759 |
| testnet | 30760 | 30759 |
| regtest | 30760 | 18444 |

ZMQ: `28332`.

## Usage

```bash
# Run in regtest with RPC enabled
docker run -d --name wojak \
  -p 30760:30760 \
  reallyshadydev/wojakcoin-core:1.12.1.0 \
  wojakcoind -regtest -server -txindex \
  -rpcbind=0.0.0.0 -rpcallowip=0.0.0.0/0 \
  -rpcuser=user -rpcpassword=pass

# Query it
docker exec wojak wojakcoin-cli -regtest -rpcuser=user -rpcpassword=pass getblockchaininfo
```

If the first argument starts with `-`, it is treated as an argument to
`wojakcoind`, so `docker run reallyshadydev/wojakcoin-core -regtest` works too.

A `wojakcoin.conf` mounted into `/root/.wojakcoin/` is loaded automatically.

## Building locally

A single-platform build for your host architecture:

```bash
docker build -t reallyshadydev/wojakcoin-core:1.12.1.0 .
```

A multi-platform build (requires Docker Buildx + QEMU):

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t reallyshadydev/wojakcoin-core:1.12.1.0 \
  --push .
```

## Publishing (CI)

`.github/workflows/docker.yml` uses `docker buildx` to build and push a
multi-platform (`linux/amd64,linux/arm64`) image to Docker Hub on every push to
`main` and on tags. Set two repository secrets:

- `DOCKERHUB_USERNAME` — a Docker Hub account with write access to the `reallyshadydev` namespace
- `DOCKERHUB_TOKEN` — a Docker Hub access token for that account

## License

MIT
