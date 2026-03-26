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

# Inicia o gateway em background
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

# Script de auto-pairing para o primeiro acesso
# Ele roda em background aposta verificando a cada 5 segundos por 5 minutos
(
  echo ">>> Aguardando conexão da UI para auto-aprovação (pairing)..."
  for i in {1..60}; do
    # Tenta aprovar a requisição mais recente usando o token do gateway
    if openclaw devices approve --latest --token "$OPENCLAW_GATEWAY_TOKEN" 2>/dev/null | grep -q 'Approved pairing request'; then
      echo ">>> Pairing aprovado automaticamente com sucesso! ✅"
      break
    fi
    sleep 5
  done
) &

# Mantém o processo do gateway em foreground
wait $GATEWAY_PID
