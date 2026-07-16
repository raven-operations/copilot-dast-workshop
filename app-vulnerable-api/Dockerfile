# API Node.js/Express INTENCIONALMENTE vulnerable para el workshop.
# Usa node:20-slim (Debian) para evitar problemas de compilación nativa
# de better-sqlite3 en Alpine/musl.
#
# La imagen y el lockfile estan pineados para garantizar builds reproducibles.
# Ver about.md § "Política de reproducibilidad".

FROM node:20.20-slim AS base

WORKDIR /app

# Instalar `iputils-ping`: `node:20-slim` no lo trae y el endpoint
# `/ping` del workshop (Paso 3.3, Command Injection) necesita el
# binario para que el uso legitimo devuelva salida real de ping.
# Sin esto el fix bloquearia el exploit pero el uso legitimo tambien
# devolveria 500 "ping failed" (falso negativo pedagogico).
RUN apt-get update \
    && apt-get install -y --no-install-recommends iputils-ping \
    && rm -rf /var/lib/apt/lists/*

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
