# qbit-port-update

Polls Gluetun's port forwarding API and automatically updates qBittorrent's listening port when it changes.

## Usage

```sh
cp .env.example .env
# fill in .env with your credentials
docker compose up -d
```

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `QBIT_USER` | ✅ | — | qBittorrent username |
| `QBIT_PASS` | ✅ | — | qBittorrent password |
| `GLUETUN_USER` | ✅ | — | Gluetun API username |
| `GLUETUN_PASS` | ✅ | — | Gluetun API password |
| `QBIT_URL` | ❌ | `http://localhost:8080` | qBittorrent base URL |
| `GLUETUN_URL` | ❌ | `http://localhost:8000` | Gluetun base URL |
| `POLL_INTERVAL` | ❌ | `30` | Seconds between port checks |

## Docker Compose

```yaml
qbittorrent-port-update:
  image: ghcr.io/zeroward/qbit-port-update:latest
  container_name: qbittorrent-port-update
  network_mode: "service:gluetun"
  depends_on:
    - gluetun
  restart: unless-stopped
  env_file:
    - .env
```