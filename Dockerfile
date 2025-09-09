# Use the official n8n image as base
FROM n8nio/n8n:latest

# Set working directory
WORKDIR /home/node

# Switch to root to install additional packages if needed
USER root

# Install additional packages (if required by SleakOps)
# RUN apk add --no-cache \
#     curl \
#     git \
#     && rm -rf /var/cache/apk/*

# Switch back to node user for security
USER node

# Expose n8n port
EXPOSE 5678

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

# Start n8n
CMD ["n8n", "start"]