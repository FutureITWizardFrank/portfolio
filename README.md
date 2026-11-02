# Frank Ruiz — portfolio

Source for my portfolio site, live at https://portfolio.techwizardsaz.com:
a RHEL 10 home server, Frigate camera NVRs (at home and one built for a friend),
a self-hosted workout tracker and an auto-watering plant monitor.

Plain HTML and CSS, no build step, hosted on GitHub Pages.

```
index.html              home page: rack drawing, projects, skills, contact
projects/               one page per project
assets/site.css         every style for the site
configs/                example configs from the builds (see configs/README.md)
CNAME                   custom domain for GitHub Pages
.nojekyll               serve files as-is, no Jekyll processing
```

## Updating the site

```bash
git pull
# edit, then preview with: python3 -m http.server 8000
git add -A && git commit -m "what changed" && git push
```

## Before committing anything new

Nothing internal goes in this repo: no real IPs, hostnames, camera locations,
passwords, hashes, tokens, ntfy topics, Tailscale addresses or VPN configs.

```bash
grep -rniE "192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.|100\.[0-9]+\.[0-9]+\.[0-9]+|password|secret|token|PrivateKey" --exclude-dir=.git .
```
