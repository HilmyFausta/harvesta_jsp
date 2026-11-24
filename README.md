# Harvesta

Tree and orchard management built with Java 21, Jakarta Servlets/JSP, Apache Tomcat, and PostgreSQL. The application is packaged as a WAR and can run locally with Maven or as a Docker Compose stack.

## Features

- Dashboard with tree, harvest, care-task, and financial summaries.
- Trees, care logs, harvests, blocks, categories, and tree types.
- Expenses, sales, and reports for administrators.
- User management, registration, login, profile, and appearance settings.
- Role-aware navigation, search, filters, sorting, and pagination.
- PostgreSQL schema setup and demo data seeding on first startup.

## Requirements

- Java 21
- Maven 3.8 or later
- PostgreSQL 16 or later

Docker is an alternative to installing Tomcat and PostgreSQL locally. See [the CasaOS deployment guide](docs/DEPLOY_CASAOS.md) for a server setup with an optional Cloudflare Tunnel.

## Run locally

Create a PostgreSQL role and a separate database for the JSP app. Do not reuse an existing application's database unless the configured role owns all of its tables.

```sql
CREATE ROLE harvesta_jsp LOGIN PASSWORD 'replace-with-a-strong-password';
CREATE DATABASE harvesta_jsp OWNER harvesta_jsp;
```

From the repository root, run the tests and start the app:

```bash
mvn test

DB_HOST=127.0.0.1 \
DB_PORT=5432 \
DB_DATABASE=harvesta_jsp \
DB_USERNAME=harvesta_jsp \
DB_PASSWORD='replace-with-a-strong-password' \
mvn jetty:run
```

Open <http://localhost:8085>. The app creates its schema and seeds demo records when it starts against an empty database.

Demo accounts use `admin@example.com`, `staff@example.com`, or `viewer@example.com`; the default development password is `password`. For any persistent or public deployment, set unique `SEED_*_PASSWORD` values before the database is first seeded. Updating those variables later does not change passwords for accounts that already exist.

To build the deployable WAR:

```bash
mvn package
```

## Run with Docker Compose

```bash
cp .env.docker.example .env.docker
nano .env.docker
docker compose --env-file .env.docker config --quiet
docker compose --env-file .env.docker up --build -d
docker compose --env-file .env.docker logs -f app
```

Open `http://localhost:8085` (or the configured `APP_PORT`). PostgreSQL data is kept in the `postgres_data` Docker volume. Do not use `docker compose down -v` unless you intend to delete that database.

## Project layout

```text
src/main/java/com/harvesta/       Servlet controllers, database helpers, and seeder
src/main/resources/schema.sql    PostgreSQL schema
src/main/webapp/WEB-INF/views/   JSP pages
src/main/webapp/WEB-INF/tags/    Shared JSP layout and tags
src/main/webapp/build/assets/    CSS, fonts, and static assets used by the JSP UI
src/test/java/                   Maven tests
docs/                            Deployment guides
```

## Deployment

For Ubuntu Server with CasaOS, a custom domain, and Cloudflare Tunnel without a public IP, follow [docs/DEPLOY_CASAOS.md](docs/DEPLOY_CASAOS.md). The tunnel service is optional and can be enabled with the Compose `tunnel` profile.

Updates from this source checkout are manual: pull the latest code and rebuild the Compose app. A GitHub-to-GHCR auto-deploy pipeline is not configured in this repository.
