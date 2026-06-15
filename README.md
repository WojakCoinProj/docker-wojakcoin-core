# docker-wojakcoin-core

A Docker image for [WojakCoin Core](https://github.com/WojakCoinProj/wojakcore) (`wojakcoind`),
modelled on [ruimarinho/docker-bitcoin-core](https://github.com/ruimarinho/docker-bitcoin-core).

The image packages the official Linux x86_64 release binaries (`wojakcoind`,
`wojakcoin-cli`, `wojakcoin-tx`) and verifies their SHA256 checksums at build time.

- **Image:** `wojakcoinproj/wojakcoin-core:1.12.1`
- **Client version:** `1.12.1` (WojakCore `CLIENT_VERSION`)
- **Release:** [`1.0.1.2`](https://github.com/WojakCoinProj/wojakcore/releases/tag/1.0.1.2)
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
  wojakcoinproj/wojakcoin-core:1.12.1 \
  wojakcoind -regtest -server -txindex \
  -rpcbind=0.0.0.0 -rpcallowip=0.0.0.0/0 \
  -rpcuser=user -rpcpassword=pass

# Query it
docker exec wojak wojakcoin-cli -regtest -rpcuser=user -rpcpassword=pass getblockchaininfo
```

If the first argument starts with `-`, it is treated as an argument to
`wojakcoind`, so `docker run wojakcoinproj/wojakcoin-core -regtest` works too.

A `wojakcoin.conf` mounted into `/root/.wojakcoin/` is loaded automatically.

## Building locally

```bash
docker build -t wojakcoinproj/wojakcoin-core:1.12.1 .
```

## Publishing (CI)

`.github/workflows/docker.yml` builds and pushes to Docker Hub on every push to
`main` and on tags. Set two repository secrets:

- `DOCKERHUB_USERNAME` — a Docker Hub account with write access to the `wojakcoinproj` namespace
- `DOCKERHUB_TOKEN` — a Docker Hub access token for that account

## License

MIT
