# Etapa 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
RUN npm install -g pnpm
COPY package.json pnpm-lock.yaml ./
RUN pnpm install
COPY . .
RUN pnpm run build

# Etapa 2: Runner
FROM node:20-alpine AS runner
WORKDIR /app
RUN npm install -g pnpm
COPY --from=builder /app/.next ./.next
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod
COPY --from=builder /app/public ./public
# Línea eliminada:
# COPY --from=builder /app/next.config.js ./

EXPOSE 3000
CMD ["pnpm", "start"]
