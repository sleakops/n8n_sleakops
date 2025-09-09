# n8n SleakOps Deployment

This repository contains Docker and Docker Compose configurations for deploying n8n workflow automation platform with SleakOps specific configurations.

## Features

- 🐳 **Docker & Docker Compose** deployment
- 🗄️ **PostgreSQL** database for production use
- 🔒 **Basic Authentication** enabled by default
- 📦 **Persistent volumes** for data storage
- 🏥 **Health checks** for service monitoring
- 🔧 **Environment-based** configuration
- 🚀 **Development** and **production** ready

## Quick Start

### Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+

### 1. Clone the Repository

```bash
git clone https://github.com/sleakops/n8n_sleakops.git
cd n8n_sleakops
```

### 2. Configure Environment

```bash
# Copy the example environment file
cp .env.example .env

# Edit the .env file with your settings
nano .env
```

**Important**: Change the default passwords in the `.env` file before deployment!

### 3. Deploy n8n

```bash
# Start the services
docker compose up -d

# Check the logs
docker compose logs -f
```

### 4. Access n8n

Open your browser and navigate to:
- **URL**: http://localhost:5678
- **Username**: admin (or your configured username)
- **Password**: password (or your configured password)

## Configuration

### Environment Variables

The following environment variables can be configured in your `.env` file:

| Variable | Description | Default |
|----------|-------------|---------|
| `POSTGRES_DB` | PostgreSQL database name | `n8n` |
| `POSTGRES_USER` | PostgreSQL username | `n8n` |
| `POSTGRES_PASSWORD` | PostgreSQL password | `n8n_password` |
| `N8N_BASIC_AUTH_USER` | n8n admin username | `admin` |
| `N8N_BASIC_AUTH_PASSWORD` | n8n admin password | `password` |
| `N8N_HOST` | n8n host address | `localhost` |
| `N8N_PROTOCOL` | Protocol (http/https) | `http` |
| `WEBHOOK_URL` | Webhook base URL | `http://localhost:5678/` |
| `TIMEZONE` | Container timezone | `UTC` |

### Custom Domain Setup

For production deployment with a custom domain:

1. Update your `.env` file:
```env
N8N_HOST=your-domain.com
N8N_PROTOCOL=https
WEBHOOK_URL=https://your-domain.com/
```

2. Set up a reverse proxy (nginx/traefik) with SSL certificates

## Development

For development with additional debugging and local workflow mounting:

```bash
# Start with development overrides
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# This enables:
# - Debug logging
# - Local workflow mounting
# - PostgreSQL port exposure
```

## Management Commands

### Start Services
```bash
docker compose up -d
```

### Stop Services
```bash
docker compose down
```

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f n8n
```

### Update n8n
```bash
# Pull latest images
docker compose pull

# Restart with new images
docker compose up -d
```

### Backup Data
```bash
# Backup n8n data
docker run --rm -v n8n_sleakops_n8n_data:/data -v $(pwd)/backups:/backup alpine tar czf /backup/n8n-backup-$(date +%Y%m%d-%H%M%S).tar.gz -C /data .

# Backup PostgreSQL
docker-compose exec postgres pg_dump -U n8n n8n > backups/postgres-backup-$(date +%Y%m%d-%H%M%S).sql
```

### Restore Data
```bash
# Restore n8n data
docker run --rm -v n8n_sleakops_n8n_data:/data -v $(pwd)/backups:/backup alpine tar xzf /backup/your-backup-file.tar.gz -C /data

# Restore PostgreSQL
docker compose exec -T postgres psql -U n8n -d n8n < backups/your-postgres-backup.sql
```

## Troubleshooting

### Service Won't Start

1. Check Docker logs:
```bash
docker compose logs n8n
docker compose logs postgres
```

2. Verify environment variables:
```bash
docker compose config
```

3. Check container status:
```bash
docker compose ps
```

### Database Connection Issues

1. Ensure PostgreSQL is healthy:
```bash
docker compose exec postgres pg_isready -U n8n -d n8n
```

2. Check database credentials in `.env` file

3. Restart services:
```bash
docker compose restart
```

### Reset Everything

⚠️ **Warning**: This will delete all your workflows and data!

```bash
# Stop services and remove volumes
docker compose down -v

# Remove all data
docker volume rm n8n_sleakops_n8n_data n8n_sleakops_postgres_data

# Start fresh
docker compose up -d
```

## Security Considerations

- Change all default passwords before deployment
- Use strong passwords for database and n8n authentication
- Consider using Docker secrets for sensitive data
- Set up proper firewall rules
- Use HTTPS in production with valid SSL certificates
- Regularly update Docker images and apply security patches

## Support

For issues specific to this deployment:
- Create an issue in this repository
- Check the [n8n documentation](https://docs.n8n.io/)
- Visit the [n8n community forum](https://community.n8n.io/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.