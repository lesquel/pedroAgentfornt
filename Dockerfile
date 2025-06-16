# Etapa 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Instala pnpm globalmente
RUN npm install -g pnpm

# Copia package.json y lockfile para instalar dependencias
COPY package.json pnpm-lock.yaml ./

# Instala dependencias
RUN pnpm install

# Copia el resto del código fuente
COPY . .

# Construye la app Next.js
RUN pnpm run build

# Etapa 2: Runner (producción)
FROM node:20-alpine AS runner

WORKDIR /app

RUN npm install -g pnpm

# Copia la carpeta .next de la build (generada)
COPY --from=builder /app/.next ./.next

# Copia package.json y lockfile para instalar sólo prod dependencies
COPY package.json pnpm-lock.yaml ./

# Instala solo dependencias de producción
RUN pnpm install --prod

# Copia los archivos estáticos, si existen
# Solo copiar 'public' si existe en builder
COPY --from=builder /app/public ./public || echo "No public folder, skipping"

# Copia otros archivos necesarios como next.config.js o tsconfig.json
COPY --from=builder /app/next.config.js ./ || true

# Expone el puerto en que corre Next.js (por defecto 3000)
EXPOSE 3000

# Comando para iniciar la app
CMD ["pnpm", "start"]
