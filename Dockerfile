FROM node:22-slim

# Instalando o necessário para o agente trabalhar
RUN apt-get update && apt-get install -y \
    git curl python3 python3-pip sudo \
    && rm -rf /var/lib/apt/lists/*

# Instala o Claude Code e o OpenClaw globalmente
RUN npm install -g @anthropic-ai/claude-code openclaw@latest

# Estrutura de pastas da VHXCO
WORKDIR /vhxco
RUN mkdir -p /vhxco/projects /vhxco/data

# Porta do Gateway (Control UI)
EXPOSE 18789

# Script de inicialização
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
