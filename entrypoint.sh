#!/bin/bash
set -e

echo "=== VHXCO Claw Engine ==="
echo "OpenClaw $(openclaw --version 2>&1)"

# Gera um token padrão se não foi fornecido via env
if [ -z "$OPENCLAW_GATEWAY_TOKEN" ]; then
  export OPENCLAW_GATEWAY_TOKEN="vhxco-claw-default-token"
  echo "AVISO: Usando token padrão. Defina OPENCLAW_GATEWAY_TOKEN no CapRover."
fi

# Inicializa config se não existir
if [ ! -f ~/.openclaw/openclaw.json ]; then
  echo "Inicializando setup..."
  openclaw setup --non-interactive --mode local 2>&1 || true
fi

# Configura Control UI para aceitar conexões externas
openclaw config set gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback true --strict-json 2>&1 || true
openclaw config set gateway.mode local 2>&1 || true

echo "Iniciando Gateway na porta ${OPENCLAW_PORT:-18789}..."

# Inicia o gateway em foreground
exec openclaw gateway run \
  --port "${OPENCLAW_PORT:-18789}" \
  --bind lan \
  --token "$OPENCLAW_GATEWAY_TOKEN" \
  --allow-unconfigured \
  --verbose
