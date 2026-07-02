# API Node.js/Express INTENCIONALMENTE vulnerable para el workshop.
# Usa node:20-slim (Debian) para evitar problemas de compilación nativa
# de better-sqlite3 en Alpine/musl.

FROM node:20-slim AS base

WORKDIR /app

# Dependencias primero para aprovechar el layer cache.
COPY package.json ./
RUN npm install --omit=dev \
    && npm cache clean --force

COPY src ./src
COPY files ./files

USER node
EXPOSE 4000

CMD ["node", "src/server.js"]
