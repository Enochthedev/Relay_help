# RelayHelp

This application is built with Ruby on Rails and uses **Phase** for secret management.

## Prerequisites

- Ruby 3.3.0
- PostgreSQL
- Redis
- Phase CLI (`brew install phase-auth/tap/phase`)

## Setup

1.  **Install Dependencies**
    ```bash
    bundle install
    ```

2.  **Phase Secrets Setup**
    This project uses [Phase](https://phase.dev) to manage environment variables securely.

    Authenticate with Phase:
    ```bash
    phase auth
    ```

    Verify you have access to the secrets (Development environment):
    ```bash
    phase secrets list
    ```

3.  **Database Setup**
    Create the database and run migrations. We use `phase run` to inject the database credentials:
    ```bash
    phase run rails db:prepare
    ```

## Running the Application

To start the app (Rails server + TailwindCSS watcher), use `bin/dev`. **Always wrap it with `phase run`** to inject secrets:

```bash
phase run bin/dev
```

The application will be available at [http://localhost:3000](http://localhost:3000).

## Managing Secrets with Phase

Since we removed sensitive variables from `.env` to avoid conflicts, use Phase commands to manage them.

### View Secrets
List all secrets in the current environment:
```bash
phase secrets list
```
To reveal values:
```bash
phase secrets list --show
```

### Add a New Secret
To add a new secret (e.g., `DISCORD_BOT_TOKEN`):

```bash
# Interactive mode (prompts for value)
phase secrets create DISCORD_BOT_TOKEN --env Development

# Or via command line (safe pipe)
echo "your_token_value_here" | phase secrets create DISCORD_BOT_TOKEN --env Development
```

### Update a Secret
Updating is similar to creating (it will prompt to overwrite):
```bash
echo "new_value" | phase secrets create POSTGRES_PASSWORD --env Development
```

### Important Note on `.env`
Do **not** put secrets managed by Phase (like `POSTGRES_PASSWORD`, `SECRET_KEY_BASE`) into your local `.env` file. `bin/dev` (Foreman) will prioritize `.env` values over Phase injection, which can break the application if the `.env` values are empty or incorrect. Keep `.env` for non-sensitive local overrides only.
