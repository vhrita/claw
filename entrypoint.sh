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

# Inicia o gateway em background, pega a URL e depois traz pra foreground
openclaw gateway run \
  --port "${OPENCLAW_PORT:-18789}" \
  --bind lan \
  --token "$OPENCLAW_GATEWAY_TOKEN" \
  --allow-unconfigured \
  --verbose &

GATEWAY_PID=$!

# Espera o gateway subir e imprime a URL tokenizada
sleep 5
echo ""
echo "============================================"
echo "  DASHBOARD URL (copie e acesse no browser):"
echo "============================================"
openclaw dashboard --no-open 2>&1 || echo "Use: https://seu-dominio/?token=$OPENCLAW_GATEWAY_TOKEN"
echo "============================================"
echo ""

# Mantém o processo do gateway em foreground
wait $GATEWAY_PID
