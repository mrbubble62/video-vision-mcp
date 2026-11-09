FROM node:20-slim AS builder

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Production image
FROM node:20-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    ffmpeg \
    python3 \
    && rm -rf /var/lib/apt/lists/

RUN useradd -ms /bin/bash mcpuser
USER mcpuser
WORKDIR /home/mcpuser/app

COPY --from=builder --chown=mcpuser:mcpuser /app/dist ./dist
COPY --from=builder --chown=mcpuser:mcpuser /app/package*.json ./
RUN npm install --omit=dev

EXPOSE 3000

ENTRYPOINT ["node", "dist/server.js", "--server", "--port", "3000"]
#ENTRYPOINT ["node", "dist/index.js"]
