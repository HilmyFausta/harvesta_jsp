# AGENTS.md

Read `PRD.md` first. It is the source of truth for product scope, roles, schema, and Git workflow. This file records the technical conventions for the Java/JSP implementation.

## Stack

- Java 21, Jakarta Servlet 6, JSP 3.1, JSTL 3, and Apache Tomcat 10.1.
- PostgreSQL 16+ for development and deployment.
- Maven for builds and tests.
- Docker Compose for CasaOS deployment; Cloudflare Tunnel is an optional Compose profile.

## Project structure

- `src/main/java/com/harvesta/`: application helpers and servlet controllers.
- `src/main/resources/schema.sql`: PostgreSQL schema initialized by the application.
- `src/main/webapp/WEB-INF/views/`: JSP pages.
- `src/main/webapp/WEB-INF/tags/`: shared layouts and JSP tags.
- `src/main/webapp/build/assets/`: CSS, fonts, and images used by the JSP UI.
- `src/test/java/`: Maven tests.

## Commands

```bash
mvn test
mvn package
mvn jetty:run
docker compose --env-file .env.docker config --quiet
docker compose --env-file .env.docker up --build -d
```

`mvn jetty:run` needs a running PostgreSQL database and valid `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, and `DB_PASSWORD` values.

## Conventions

- Keep request handling, validation, authorization, and database access in Java servlets/helpers; JSP is for rendering.
- Use prepared statements for every value originating from a request. Do not concatenate request values into SQL.
- Escape user-controlled output with the existing JSP function tags, for example `${h:e(value)}`.
- Reuse the existing `Db`, `Format`, `Options`, and `Fn` helpers instead of duplicating behavior.
- Keep UI text in English and preserve the existing layout, colors, spacing, and static CSS assets unless the task specifically asks for a visual change.
- Lists should paginate by 15, with filters and sorting retained in pagination links.
- Update `src/main/resources/schema.sql` and the relevant PRD schema section together when changing the database schema.
- Keep `.env`, `.env.docker`, passwords, and Cloudflare Tunnel tokens out of Git.
- Preserve the `postgres_data` volume during application updates. Do not run destructive volume-removal commands without explicit approval.
- Work directly on `main`; use Conventional Commits if committing. Never push; the human pushes.
- Do not report completion while Maven tests or packaging fail.
