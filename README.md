# kali-anonsurf

ParrotSec's anonsurf and pandora modules, ported and improved for Kali Linux.

## Changes from original (v2.0.0)

- **Configuration file** — `/etc/anonsurf/anonsurf.conf` for all settings
- **`--no-kill` / `--no-wipe` flags** — skip app termination or cache cleaning on start
- **Tor connectivity verification** — checks Tor circuit is working after `start`
- **DNS leak test** — built into `anonsurf status` (compares Tor SOCKS IP vs direct IP)
- **Lockfile state tracking** — prevents double-start (`/var/lock/anonsurf`)
- **Logging** — timestamped entries to `/var/log/anonsurf.log`
- **Tor bridge support** — pipe-separated bridges in config
- **MAC address spoofing** — optional via `macchanger` (off by default)
- **Rollback on failure** — if iptables rules fail partway, original state is restored
- **Pandora VM save/restore** — kernel VM parameters restored after RAM wipe
- **Systemd service** — auto-start anonsurf at boot with `--no-kill --no-wipe`

### Bug fixes
- IPv6 now actually re-enables on `stop` (was checking wrong filename)
- `stop` no longer kills apps twice on `restart`
- DNS backup no longer destroyed by start/stop/start cycles
- iptables rules saved unconditionally (not just when backup file is absent)
- All iptables rules checked for errors with rollback
- Config variables (`TOR_PORT`, `TOR_DNS_PORT`) actually used in rules

## Installation

```bash
sudo ./installer.sh
```

Or manually install the .deb:

```bash
sudo apt-get install -y secure-delete tor i2p curl
sudo dpkg -i kali-anonsurf.deb
sudo apt-get -f install -y
```

## Usage

### anonsurf

```
anonsurf {start|stop|restart|change|status|myip|starti2p|stopi2p}

  start      - Start transparent Tor proxy
  stop       - Stop and restore original iptables/DNS
  restart    - Stop then start (single circuit change)
  change     - Force Tor to use a new circuit
  status     - Show status + DNS leak test + Tor IP
  myip       - Show current public IP
  starti2p   - Start I2P services
  stopi2p    - Stop I2P services

Optional flags (after command):
  --no-kill  - Don't kill browsers/IM clients on start
  --no-wipe  - Don't run bleachbit cache cleaning on start

Examples:
  sudo anonsurf start
  sudo anonsurf start --no-kill
  sudo anonsurf status
  sudo anonsurf stop
```

### pandora

```bash
pandora bomb   # Wipe free RAM (saves+restores VM settings)
```

Systemd service auto-runs pandora on shutdown to wipe RAM.

## Configuration

Edit `/etc/anonsurf/anonsurf.conf`:

| Setting | Default | Description |
|---------|---------|-------------|
| `TOR_UID` | `debian-tor` | UID Tor runs as |
| `TOR_PORT` | `9040` | Tor TransPort |
| `TOR_SOCKS_PORT` | `9050` | Tor SOCKS port |
| `TOR_DNS_PORT` | `53` | Tor DNS port |
| `TOR_EXCLUDE` | `192.168.0.0/16 ...` | Subnets bypassing Tor |
| `DNS_SERVERS` | `127.0.0.1` | Primary DNS |
| `DNS_FALLBACK` | `209.222.18.222 209.222.18.218` | Fallback DNS |
| `KILL_APPS` | `chrome firefox ...` | Apps killed on start |
| `DISABLE_IPV6` | `true` | Disable IPv6 while active |
| `MAC_SPOOF` | `false` | Randomize MAC (needs macchanger) |
| `MAC_INTERFACES` | `eth0 wlan0` | Interfaces to spoof |
| `TOR_BRIDGES` | `""` | Bridges (pipe-separated) |
| `LOG_ENABLED` | `true` | Write to log file |
| `LOG_FILE` | `/var/log/anonsurf.log` | Log path |

## License

GPLv3 — based on ParrotSec anonsurf and [Und3rf10w/kali-anonsurf](https://github.com/Und3rf10w/kali-anonsurf)
