FROM node:20-slim

# Instalando o necessário para o agente trabalhar
RUN apt-get update && apt-get install -y \
    git curl python3 python3-pip sudo \
    && rm -rf /var/lib/apt/lists/*

# Instala o Claude Code e o OpenClaw globalmente
RUN npm install -g @anthropic-ai/claude-code openclaw

# Estrutura de pastas da VHXCO
WORKDIR /vhxco
RUN mkdir -p /vhxco/projects /vhxco/data

# Mantém o container rodando para você dar comandos via Exec
CMD ["tail", "-f", "/dev/null"]
