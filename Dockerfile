FROM node:20-slim

# Instalando o necessário para o agente trabalhar
RUN apt-get update && apt-get install -y \
    git curl python3 python3-pip sudo \
    && rm -rf /var/lib/apt/lists/*

# Instala o Claude Code e o OpenClaw globalmente
RUN npm install -g @anthropic-ai/claude-code openclaw

# Garante que o PATH inclui o bin global do npm
ENV PATH="/usr/local/bin:$PATH"

# Verifica instalação
RUN which openclaw && openclaw --version || echo 'WARN: openclaw not found, checking npm bin...' && ls $(npm root -g)/openclaw/ && echo "NPM global bin: $(npm bin -g)"

# Estrutura de pastas da VHXCO
WORKDIR /vhxco
RUN mkdir -p /vhxco/projects /vhxco/data

# Porta do Gateway (Control UI)
EXPOSE 18789

# Script de inicialização
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
