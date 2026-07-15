# API Node.js/Express INTENCIONALMENTE vulnerable para el workshop.
# Usa node:20-slim (Debian) para evitar problemas de compilación nativa
# de better-sqlite3 en Alpine/musl.
#
# La imagen y el lockfile estan pineados para garantizar builds reproducibles.
# Ver about.md § "Política de reproducibilidad".

FROM node:20.20-slim AS base

WORKDIR /app

# Dependencias primero para aprovechar el layer cache.
# Usamos npm ci (no npm install) para instalar exactamente lo que dice
# package-lock.json y fallar si estan desincronizados.
COPY package.json package-lock.json ./
RUN npm ci --omit=dev \
    && npm cache clean --force

COPY src ./src
COPY files ./files

USER node
EXPOSE 4000

CMD ["node", "src/server.js"]
