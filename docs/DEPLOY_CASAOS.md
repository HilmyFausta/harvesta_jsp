# Deploy Harvesta to CasaOS with Cloudflare Tunnel

This guide deploys the JSP application and PostgreSQL on Ubuntu Server using Docker Compose. Cloudflare Tunnel publishes the app through a domain without a public IP address, router port forwarding, or an inbound firewall rule.

The server needs outbound internet access to pull Docker images and maintain the Cloudflare Tunnel connection. A domain name is still required; domain registration and renewal may have a cost.

## 1. Prepare CasaOS and the repository

Make sure CasaOS and Docker are running. Connect to the server over SSH, then clone the repository:

```bash
git clone https://github.com/HilmyFausta/harvesta.git
cd harvesta
```

If you already cloned it, enter that checkout and update it:

```bash
cd /path/to/harvesta
git pull --ff-only
```

Keep the checkout on the server so later updates can use `git pull`.

## 2. Configure the database and app passwords

Create a private environment file from the template:

```bash
cp .env.docker.example .env.docker
nano .env.docker
```

Replace the PostgreSQL password and all three seed account passwords with unique, strong values. Keep `SEED_DEMO_DATA=true` if you want the sample orchard records. Leave `CLOUDFLARE_TUNNEL_TOKEN` blank for now. Do not commit or share `.env.docker`.

Validate the Compose configuration and start the app:

```bash
docker compose --env-file .env.docker config --quiet
docker compose --env-file .env.docker up --build -d
docker compose --env-file .env.docker ps
docker compose --env-file .env.docker logs -f app
```

The first build may take several minutes. Once the app is ready, open `http://SERVER_LAN_IP:8085` from your local network. Change `APP_PORT` in `.env.docker` if port 8085 is already in use.

The database schema and initial accounts are created on the first startup. Seed passwords are only applied when accounts are first created; changing `.env.docker` later does not reset existing account passwords.

## 3. Add your domain to Cloudflare

1. Register a domain with a registrar that lets you change its nameservers.
2. Add the domain to your Cloudflare account.
3. At the registrar, replace the domain's nameservers with the pair Cloudflare provides.
4. Wait for Cloudflare to confirm the domain is active.

Use a hostname such as `harvesta.example.com`; replace `example.com` with your own domain throughout this guide. Cloudflare's free plan can proxy a hostname, but the domain registration itself is not free.

## 4. Create the Cloudflare Tunnel

In the Cloudflare dashboard, open **Zero Trust → Networks → Tunnels** and create a Cloudflared tunnel. Choose the Docker connector instructions and copy the tunnel token. Treat the token like a password.

On the server, add the token to `.env.docker`:

```dotenv
CLOUDFLARE_TUNNEL_TOKEN=paste-your-tunnel-token-here
```

In the tunnel's public-hostname or published-application route, configure:

- **Hostname:** `harvesta.example.com`
- **Service type:** `HTTP`
- **Service URL:** `http://app:8080`

`app` is the Compose service name. The `cloudflared` container shares the Compose network with Tomcat, so do not use `localhost:8085` here; that would point to the tunnel container itself.

## 5. Start the tunnel

From the repository directory, start the optional `tunnel` profile:

```bash
docker compose --profile tunnel --env-file .env.docker up --build -d
docker compose --profile tunnel --env-file .env.docker ps
docker compose --profile tunnel --env-file .env.docker logs -f cloudflared
```

Open `https://harvesta.example.com`. Cloudflare serves HTTPS to visitors and forwards traffic through the outbound tunnel to the app. **Do not configure port forwarding** on the router. Cloudflare Tunnel does not require the server to have a public IP address.

The app's port 8085 is published for direct local-network access. Do not expose it through router port forwarding; restrict local access with the Ubuntu firewall if needed. The tunnel uses the internal Compose network and does not depend on port 8085.

See Cloudflare's current [Tunnel setup guide](https://developers.cloudflare.com/tunnel/get-started/) for dashboard changes and troubleshooting.

## 6. Updates and backups

To deploy a newer version from this repository:

```bash
git pull --ff-only
docker compose --profile tunnel --env-file .env.docker up --build -d
```

This rebuilds the app image and keeps the PostgreSQL volume. GitHub pushes do not update this server automatically; an image publishing and update pipeline is not configured.

Create a database backup periodically and store it outside the Docker volume:

```bash
docker compose --env-file .env.docker exec -T db \
  sh -c 'pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB"' \
  > "harvesta-$(date +%F).sql"
```

To stop the app without deleting its data:

```bash
docker compose --profile tunnel --env-file .env.docker down
```

**Destructive:** `docker compose down -v` deletes the `postgres_data` volume and all database data. Back up the database before intentionally removing that volume.

## Troubleshooting

- **App does not start:** check `docker compose --env-file .env.docker logs app` and verify the DB password values match.
- **Tunnel does not connect:** check the token and `docker compose --profile tunnel --env-file .env.docker logs cloudflared`. The server must be able to make outbound connections.
- **Cloudflare shows a 502:** confirm the public hostname's service URL is `http://app:8080` and both services use the same Compose project.
- **Hostname does not resolve:** verify Cloudflare activated the domain and that the public hostname route exists on the correct tunnel.
- **The app is reachable only on the LAN:** verify the tunnel container is running and the public hostname route is configured; do not open router ports as a workaround.
