# n8n Docker Setup with Queue Workers

n8n configuration using Docker Compose with queue architecture (queue mode) for distributed workflow processing.

## 📋 Requirements

- Docker Engine 20.10+
- Docker Compose 2.0+
- Available ports: 5678

## 🏗️ Architecture

This setup includes 4 services:

- **PostgreSQL**: Database for storing workflows, credentials and executions
- **Redis**: Queue system for job distribution
- **n8n**: Main server (web interface and API)
- **n8n-worker**: Worker for background workflow processing

## 🚀 Quick Start

### 1. Clone or create the files

Make sure you have these files in your directory:
- `compose.yaml`
- `.env`
- `Dockerfile`

### 2. Create folder for local files

```bash
mkdir -p local-files
```

### 3. Start the services

```bash
docker-compose up -d
```

### 4. Access n8n

Open your browser at: `http://localhost:5678`

### 5. View logs

```bash
# All services
docker-compose logs -f

# Only n8n
docker-compose logs -f n8n

# Only workers
docker-compose logs -f n8n-worker
```

## 🛠️ Useful Commands

### Stop services
```bash
docker-compose down
```

### Stop and remove volumes (⚠️ deletes all data)
```bash
docker-compose down -v
```

### Restart services
```bash
docker-compose restart
```

### Rebuild images
```bash
docker-compose build --no-cache
docker-compose up -d
```

### Scale workers
```bash
docker-compose up -d --scale n8n-worker=3
```

## 📝 Execution Modes (Entrypoints)

The n8n image supports different execution modes:

### `start` (default)
Starts the main n8n server with web interface and API.
```yaml
command: start
# Or simply omit the command
```

### `worker`
Starts a worker to process queue jobs.
```yaml
command: worker
```

### `webhook`
Starts only the webhook server (useful for horizontal scaling).
```yaml
command: webhook
```

### Other available commands
```bash
# Execute command inside container
docker-compose exec n8n n8n --help

# Export workflows
docker-compose exec n8n n8n export:workflow --all --output=/files/

# Import workflows
docker-compose exec n8n n8n import:workflow --input=/files/workflow.json

# Execute workflow
docker-compose exec n8n n8n execute --id=<workflow-id>
```

## ⚙️ Configuration

### Main Environment Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `N8N_PORT` | Server port | `5678` |
| `N8N_PROTOCOL` | Protocol (http/https) | `http` |
| `N8N_HOST` | Server host | `localhost` |
| `EXECUTIONS_MODE` | Execution mode | `queue` |
| `N8N_WORKERS_ENABLED` | Enable workers | `true` |
| `DB_TYPE` | Database type | `postgresdb` |
| `QUEUE_BULL_REDIS_HOST` | Redis host | `redis` |

Other environment variables are documented in the [official n8n documentation](https://docs.n8n.io/hosting/configuration/environment-variables/).

### Modify Configuration

1. Edit the `.env` file
2. Restart the services:
```bash
docker-compose down
docker-compose up -d
```

## 📂 File Structure

```
.
├── compose.yaml           # Service definition
├── Dockerfile            # n8n base image
├── .env                  # Environment variables
├── local-files/          # Files shared with n8n
└── README.md            # This file
```

### Persistent Volumes

- `n8n_data`: n8n data (workflows, credentials, configuration)
- `postgres_data`: PostgreSQL database
- `redis_data`: Redis data
- `./local-files`: Local files accessible from workflows

## 🔧 Customization

### Add npm Packages

Modify the `Dockerfile`:

```dockerfile
FROM docker.n8n.io/n8nio/n8n:1.115.3

USER root
RUN npm install -g <package>
USER node
```

Then rebuild:
```bash
docker-compose build --no-cache
docker-compose up -d
```

### Change Timezone

In `.env`:
```env
GENERIC_TIMEZONE=America/Argentina/Buenos_Aires
TZ=America/Argentina/Buenos_Aires
```

### Enable HTTPS

1. Configure a reverse proxy (nginx, traefik, caddy)
2. Or use SSL certificates directly:

```env
N8N_PROTOCOL=https
N8N_SSL_KEY=/path/to/key.pem
N8N_SSL_CERT=/path/to/cert.pem
```

## 🐛 Troubleshooting

### Error: "Command n8n not found"
- **Cause**: Incorrect command in `compose.yaml`
- **Solution**: Use `command: worker` or `command: start` (without the `n8n` prefix)

### Workflows don't execute
- Verify that Redis is running: `docker-compose ps`
- Check worker logs: `docker-compose logs n8n-worker`
- Confirm `EXECUTIONS_MODE=queue` in `.env`

### Can't access localhost:5678
- Verify the port is not in use: `lsof -i :5678`
- Check logs: `docker-compose logs n8n`
- Confirm the service is running: `docker-compose ps`

### Database doesn't connect
- Wait for PostgreSQL to be ready (has healthcheck)
- Verify credentials in `.env`
- Check logs: `docker-compose logs db`

## 📚 Resources

- [Official n8n Documentation](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)
- [n8n GitHub](https://github.com/n8n-io/n8n)
- [Docker Hub - n8n](https://hub.docker.com/r/n8nio/n8n)

## 🔐 Security

⚠️ **Important for Production:**

1. Change `N8N_ENCRYPTION_KEY` to a randomly generated secure key
2. Use strong passwords for PostgreSQL
3. Configure `N8N_SECURE_COOKIE=true` if using HTTPS
4. Restrict CORS in production (remove the `*`)
5. Use secure environment variables (Docker secrets)
6. Consider using a reverse proxy with authentication

### Generate New Encryption Key

```bash
openssl rand -base64 32
```

## 📊 Monitoring

### Health Checks

Services have configured health checks:

```bash
# View health status
docker-compose ps
```

### Metrics

To enable Prometheus metrics, add to `.env`:

```env
N8N_METRICS=true
N8N_METRICS_PREFIX=n8n_
```

## 🔄 Update

```bash
# 1. Stop services
docker-compose down

# 2. Update version in Dockerfile
# FROM docker.n8n.io/n8nio/n8n:1.XXX.X

# 3. Rebuild and start
docker-compose build --no-cache
docker-compose up -d

# 4. Check logs
docker-compose logs -f
```

## 📄 License

**n8n**: This project uses n8n, which is under [Apache 2.0 License with Commons Clause](https://github.com/n8n-io/n8n/blob/master/LICENSE.md). 

⚠️ **Important note**: The Commons Clause restricts commercial use of n8n as a SaaS service. If you plan to offer n8n as a service to your customers, review the [n8n enterprise licensing options](https://n8n.io/pricing/).

---

**Problems?** Check the logs with `docker-compose logs -f` or open an issue in the repository.