FROM node:20.12.2-alpine

WORKDIR /app

# Copiar arquivos de dependências
COPY package.json yarn.lock ./

# Instalar dependências
RUN yarn install --frozen-lockfile

# Copiar código-fonte
COPY . .

# Criar diretórios necessários
RUN mkdir -p /app/media/clothing /app/media/igloos /app/mods /app/data

# Build do TypeScript
RUN yarn build-tsc

# Expor portas (HTTP, Login, World)
EXPOSE 24105 24106 24107

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:24105', (r) => {if (r.statusCode !== 404) throw new Error(r.statusCode)})" || exit 1

# Comando para iniciar o servidor (usa arquivo compilado, não nodemon)
CMD ["node", "compiled/server/main.js"]
