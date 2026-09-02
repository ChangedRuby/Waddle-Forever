FROM node:20.12.2-alpine

WORKDIR /app

# Copiar arquivos de dependências
COPY package.json yarn.lock ./

# Instalar dependências (inclui curl para download)
RUN apk add --no-cache curl && \
    yarn install --frozen-lockfile

# Copiar código-fonte
COPY . .

# Criar diretórios necessários
RUN mkdir -p /app/media/clothing /app/media/igloos /app/media/default/websites /app/mods /app/data

# Build do TypeScript
RUN yarn build-tsc

# Download da mídia padrão (arquivos essenciais do Club Penguin)
# Tenta fazer download do repositório oficial, se falhar continua mesmo assim
RUN echo "Attempting to download media files..." && \
    mkdir -p /app/media/default/websites && \
    (curl -L "https://github.com/nhaar/Waddle-Forever/releases/download/v1.4.5/default.zip" -o /app/media/default.zip 2>/dev/null && \
    cd /app/media && unzip -q /app/media/default.zip && rm /app/media/default.zip) || \
    echo "⚠️  Warning: Could not download media files. Server will attempt to serve from local cache."

# Expor portas (HTTP, Login, World)
EXPOSE 24105 24106 24107

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:24105', (r) => {if (r.statusCode !== 404) throw new Error(r.statusCode)})" || exit 1

# Comando para iniciar o servidor (usa arquivo compilado)
CMD ["node", "compiled/server/main.js"]
