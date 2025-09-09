#!/bin/bash

# Test deployment script for n8n SleakOps
# This script tests the deployment without actually starting the services

set -e

echo "🧪 Testing n8n SleakOps deployment configuration..."

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not available"
    exit 1
fi

echo "✅ Docker is available"

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available"
    exit 1
fi

echo "✅ Docker Compose is available"

# Validate docker-compose.yml
echo "🔍 Validating Docker Compose configuration..."
if docker compose config > /dev/null; then
    echo "✅ Docker Compose configuration is valid"
else
    echo "❌ Docker Compose configuration has errors"
    exit 1
fi

# Check if required images are available locally
echo "🔍 Checking required Docker images..."
if docker image inspect n8nio/n8n:latest > /dev/null 2>&1; then
    echo "✅ n8n image is available"
else
    echo "⚠️  n8n image not found locally (will be pulled on first run)"
fi

if docker image inspect postgres:13-alpine > /dev/null 2>&1; then
    echo "✅ PostgreSQL image is available"
else
    echo "⚠️  PostgreSQL image not found locally (will be pulled on first run)"
fi

# Check if .env.example exists
if [ -f ".env.example" ]; then
    echo "✅ .env.example file exists"
else
    echo "❌ .env.example file is missing"
    exit 1
fi

# Check if essential scripts exist
if [ -f "scripts/health-check.sh" ] && [ -x "scripts/health-check.sh" ]; then
    echo "✅ Health check script exists and is executable"
else
    echo "❌ Health check script is missing or not executable"
    exit 1
fi

# Check if Makefile exists
if [ -f "Makefile" ]; then
    echo "✅ Makefile exists"
else
    echo "❌ Makefile is missing"
    exit 1
fi

# Check if README.md has deployment instructions
if [ -f "README.md" ] && grep -q "Quick Start" README.md; then
    echo "✅ README.md contains deployment instructions"
else
    echo "❌ README.md is missing or incomplete"
    exit 1
fi

# Validate development override
echo "🔍 Validating development Docker Compose override..."
if docker compose -f docker-compose.yml -f docker-compose.dev.yml config > /dev/null; then
    echo "✅ Development Docker Compose configuration is valid"
else
    echo "❌ Development Docker Compose configuration has errors"
    exit 1
fi

echo ""
echo "🎉 All deployment configuration tests passed!"
echo "📝 Next steps:"
echo "   1. Copy .env.example to .env and customize settings"
echo "   2. Run 'docker compose up -d' to start the services"
echo "   3. Access n8n at http://localhost:5678"
echo "   4. Use 'make help' to see available commands"