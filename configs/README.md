# Configs

Example configs behind the projects on this site, trimmed to the parts worth
reading. They're templates, not copies of a live system.

- All IP addresses are examples in `10.0.10.0/24`.
- Hostnames, camera names and zone names are generic.
- Secrets are placeholders or environment variables: camera credentials, ntfy
  topics, password hashes, Wi-Fi details. The ESP8266 sketch reads its secrets
  from an uncommitted `secrets.h`.

| Folder | What's in it |
| --- | --- |
| `home-server/` | Caddyfile, macvlan network and host shim, Watchtower |
| `frigate/` | Frigate config and compose file, zone-gated alerts, frigate-notify |
| `pi/` | Daily update script and cron entry, always-reboot setup, Caddy CA naming |
| `esp8266/` | Plant monitor sketch and a secrets template |
