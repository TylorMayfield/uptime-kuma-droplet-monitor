# Uptime Kuma monitor on a dedicated Droplet

This companion config runs [Uptime Kuma](https://github.com/louislam/uptime-kuma) behind Caddy on a separate Linux server. Uptime Kuma is not exposed directly on a host port. Caddy accepts HTTPS traffic and proxies it to the monitor over the private Docker network.

## Read the guide

[Monitor a site from a separate server with Uptime Kuma](https://www.tylor.nz/content/monitor-site-with-uptime-kuma?utm_source=github&utm_medium=referral&utm_campaign=digitalocean-guides&utm_content=companion-readme)

## Disclosure

This README includes a DigitalOcean affiliate link. If you use it, I may earn a commission at no additional cost to you.

[Review Droplet plans for a separate monitoring server](https://www.tylor.nz/go/digitalocean?utm_source=github&utm_medium=affiliate&utm_campaign=digitalocean-guides&utm_content=monitor-site-with-uptime-kuma&product=droplets&placement=companion-readme&variant=readme-primary&locale=en). Resolve the private-bootstrap hold below before provisioning this setup.

## Private-bootstrap hold

The current Compose stack exposes Caddy publicly when it starts. HTTPS and a closed direct port 3001 do not restrict who can reach first-account setup through Caddy. This companion does not yet supply a tested private-bootstrap and certificate-issuance sequence.

Do not use the start block below as a turnkey public setup. First prepare and rehearse an administrator-only bootstrap on an authorized disposable instance. Keep public Caddy stopped and inbound ports 80, 443 and 3001 unreachable from the internet until that gate passes. The [guide's private-bootstrap acceptance gate](https://www.tylor.nz/content/monitor-site-with-uptime-kuma#article-section-required-private-bootstrap-acceptance-gate) describes the required evidence. No tested override or start commands are supplied here.

## Before you start

- Use a dedicated Droplet. Do not run the monitor on the same server as the service it checks.
- Point `KUMA_DOMAIN` at the Droplet's public IPv4 address before starting Caddy.
- Keep inbound TCP 80 and 443 closed during first-account bootstrap. Restrict SSH to your own current address or VPN. Rehearse the later Caddy certificate and dashboard-access transition before opening public access.
- Keep `./data` on the Droplet's local disk or a local Docker volume. Uptime Kuma documents that NFS is not supported for this data directory.

## Start the dashboard after the bootstrap gate passes

Stop here until the private-bootstrap hold above is resolved. The following original start block does not establish private first-account setup, and the preflight script does not prove it.

```sh
git clone https://github.com/TylorMayfield/uptime-kuma-droplet-monitor.git
cd uptime-kuma-droplet-monitor
cp .env.example .env
nano .env
./scripts/preflight.sh
docker compose up -d
./scripts/check-dashboard.sh
```

After the private-bootstrap and certificate checks pass, open `https://KUMA_DOMAIN` and sign in as the administrator already created through the verified private route. Create a notification before you add a production monitor. Do not publish the dashboard or a status page until you have decided who should see it.

## Add one monitor and test an alert

In the Uptime Kuma dashboard:

1. Create a notification method you can receive and test it.
2. Add an HTTP(s) monitor for a harmless URL on the target service. Set the expected status code and a timeout that matches the service.
3. Attach the notification to that monitor.
4. Trigger a controlled failure. A temporary endpoint that returns an error is safer than stopping production traffic.
5. Confirm that the dashboard shows the down event, your notification arrives, and a recovery notification follows when the endpoint works again.

This repository starts the monitoring server. It does not create monitors or notification credentials for you, because those settings live in Uptime Kuma's data store and should be reviewed in the dashboard.

## Update carefully

Read Uptime Kuma's current update guidance before changing images. Back up `./data`, pull the image, then recreate the services during a planned maintenance window. Verify the dashboard, one monitor, and one notification afterward.

## License

[MIT](LICENSE)
