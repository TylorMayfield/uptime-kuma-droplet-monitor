# Uptime Kuma monitor on a dedicated Droplet

This companion config runs [Uptime Kuma](https://github.com/louislam/uptime-kuma) behind Caddy on a separate Linux server. Uptime Kuma is not exposed directly on a host port. Caddy accepts HTTPS traffic and proxies it to the monitor over the private Docker network.

## Read the guide

[Monitor a site from a separate server with Uptime Kuma](https://www.tylor.nz/content/monitor-site-with-uptime-kuma)

## Disclosure

This README includes a DigitalOcean affiliate link. If you use it, I may earn a commission at no additional cost to you.

[Create a monitoring Droplet on DigitalOcean](https://www.awin1.com/cread.php?s=4757508&v=123996&q=601070&r=3054551)

## Before you start

- Use a dedicated Droplet. Do not run the monitor on the same server as the service it checks.
- Point `KUMA_DOMAIN` at the Droplet's public IPv4 address before starting Caddy.
- Allow inbound TCP 80 and 443 to the monitor Droplet. Restrict SSH to your own current address or VPN.
- Keep `./data` on the Droplet's local disk or a local Docker volume. Uptime Kuma documents that NFS is not supported for this data directory.

## Start the dashboard

```sh
git clone https://github.com/TylorMayfield/uptime-kuma-droplet-monitor.git
cd uptime-kuma-droplet-monitor
cp .env.example .env
nano .env
./scripts/preflight.sh
docker compose up -d
./scripts/check-dashboard.sh
```

Open `https://KUMA_DOMAIN`, create the first administrator account, and create a notification before you add a production monitor. Do not publish the dashboard or a status page until you have decided who should see it.

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
