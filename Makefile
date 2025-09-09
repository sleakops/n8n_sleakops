# n8n SleakOps Deployment Makefile

.PHONY: help start stop restart logs build health backup clean dev

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

start: ## Start n8n services (PostgreSQL version)
	@echo "🚀 Starting n8n SleakOps deployment..."
	docker compose up -d

start-sqlite: ## Start n8n services (SQLite version)
	@echo "🚀 Starting n8n SleakOps deployment with SQLite..."
	docker compose -f docker-compose.sqlite.yml up -d

stop: ## Stop n8n services (PostgreSQL version)
	@echo "🛑 Stopping n8n services..."
	docker compose down

stop-sqlite: ## Stop n8n services (SQLite version)
	@echo "🛑 Stopping n8n services..."
	docker compose -f docker-compose.sqlite.yml down

restart: ## Restart n8n services
	@echo "🔄 Restarting n8n services..."
	docker compose restart

logs: ## Show logs for all services (PostgreSQL version)
	@echo "📋 Showing logs..."
	docker compose logs -f

logs-sqlite: ## Show logs for SQLite version
	@echo "📋 Showing logs (SQLite)..."
	docker compose -f docker-compose.sqlite.yml logs -f

logs-n8n: ## Show logs for n8n service only (PostgreSQL version)
	docker compose logs -f n8n

logs-db: ## Show logs for PostgreSQL service only
	docker compose logs -f postgres

build: ## Build custom n8n image
	@echo "🔨 Building custom n8n image..."
	docker compose build

health: ## Run health check
	@echo "🏥 Running health check..."
	./scripts/health-check.sh

update: ## Update to latest n8n version
	@echo "📦 Updating n8n to latest version..."
	docker compose pull
	docker compose up -d

backup: ## Create backup of n8n data and database
	@echo "💾 Creating backup..."
	mkdir -p backups
	@echo "Backing up n8n data..."
	docker run --rm -v n8n_sleakops_n8n_data:/data -v $(PWD)/backups:/backup alpine tar czf /backup/n8n-backup-$$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
	@echo "Backing up PostgreSQL..."
	docker compose exec -T postgres pg_dump -U n8n n8n > backups/postgres-backup-$$(date +%Y%m%d-%H%M%S).sql
	@echo "✅ Backup completed in backups/ directory"

clean: ## Stop services and remove all data (DESTRUCTIVE!)
	@echo "⚠️  This will delete ALL data! Are you sure? (y/N)"
	@read -r REPLY; if [ "$$REPLY" = "y" ] || [ "$$REPLY" = "Y" ]; then \
		echo "🗑️  Removing all data..."; \
		docker compose down -v; \
		docker volume rm -f n8n_sleakops_n8n_data n8n_sleakops_postgres_data 2>/dev/null || true; \
		echo "✅ All data removed"; \
	else \
		echo "❌ Operation cancelled"; \
	fi

dev: ## Start development environment
	@echo "🔧 Starting development environment..."
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

setup: ## Initial setup - copy env file and start services
	@echo "⚙️  Setting up n8n SleakOps deployment..."
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "📝 .env file created from .env.example"; \
		echo "⚠️  Please edit .env file and change the default passwords!"; \
	fi
	@echo "🚀 Starting services..."
	$(MAKE) start
	@echo "✅ Setup completed!"
	@echo "📱 Access n8n at: http://localhost:5678"

status: ## Show service status
	@echo "📊 Service Status:"
	docker compose ps