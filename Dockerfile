FROM node:20.12.2-alpine

WORKDIR /app

# Copiar arquivos de dependências
COPY package.json yarn.lock ./

# Instalar dependências (curl para download e unzip para extrair a mídia)
RUN apk add --no-cache curl unzip && \
    yarn install --frozen-lockfile

# Copiar código-fonte
COPY . .

# Criar diretórios necessários
RUN mkdir -p /app/media/clothing /app/media/igloos /app/media/default/websites /app/mods /app/data

# Build do TypeScript
RUN yarn build-tsc

# Download da mídia padrão (arquivos essenciais do Club Penguin)
# O default.zip contém o conteúdo de media/default/ na raiz do zip,
# por isso precisa ser extraído DENTRO de /app/media/default.
RUN curl -L "https://github.com/nhaar/Waddle-Forever/releases/download/v1.4.5/default.zip" -o /tmp/default.zip && \
    mkdir -p /app/media/default && \
    unzip -q /tmp/default.zip -d /app/media/default && \
    rm /tmp/default.zip

# Expor portas (HTTP, Login, World)
EXPOSE 24105 24106 24107

# Health check: o servidor responde 200 na raiz quando a mídia está correta
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:24105', (r) => {if (r.statusCode !== 200) throw new Error('status ' + r.statusCode)})" || exit 1

# Comando para iniciar o servidor (usa arquivo compilado)
CMD ["node", "compiled/server/main.js"]
