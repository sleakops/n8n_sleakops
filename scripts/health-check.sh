#!/bin/bash

# Health check script for n8n SleakOps deployment
# Usage: ./scripts/health-check.sh

set -e

echo "🏥 Checking n8n SleakOps deployment health..."

# Check if Docker Compose is running
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Docker Compose services are not running"
    echo "Run: docker-compose up -d"
    exit 1
fi

# Check n8n service
echo "🔍 Checking n8n service..."
if curl -f http://localhost:5678/healthz >/dev/null 2>&1; then
    echo "✅ n8n service is healthy"
else
    echo "❌ n8n service is not responding"
    echo "Check logs: docker-compose logs n8n"
    exit 1
fi

# Check PostgreSQL service
echo "🔍 Checking PostgreSQL service..."
if docker-compose exec -T postgres pg_isready -U n8n -d n8n >/dev/null 2>&1; then
    echo "✅ PostgreSQL service is healthy"
else
    echo "❌ PostgreSQL service is not responding"
    echo "Check logs: docker-compose logs postgres"
    exit 1
fi

# Check data volumes
echo "🔍 Checking data volumes..."
N8N_VOLUME=$(docker volume ls | grep n8n_data | wc -l)
POSTGRES_VOLUME=$(docker volume ls | grep postgres_data | wc -l)

if [ "$N8N_VOLUME" -gt 0 ] && [ "$POSTGRES_VOLUME" -gt 0 ]; then
    echo "✅ Data volumes are present"
else
    echo "⚠️  Some data volumes may be missing"
fi

echo ""
echo "🎉 Health check completed successfully!"
echo "📱 Access n8n at: http://localhost:5678"
echo "📊 View logs: docker-compose logs -f"