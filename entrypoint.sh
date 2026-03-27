#!/bin/bash
set -e

# 1) Fixar onde o OpenClaw guarda estado (config, sessões, memory, etc.)
export HOME="/vhxco/data"
mkdir -p "$HOME"

# 2) Migração one-time: se já existia estado em /root/.openclaw
if [ -d "/root/.openclaw" ] && [ ! -d "$HOME/.openclaw" ]; then
  echo "Migrando /root/.openclaw -> $HOME/.openclaw ..."
  mkdir -p "$HOME/.openclaw"
  cp -a /root/.openclaw/. "$HOME/.openclaw/" || true
fi

echo "=== VHXCO Claw Engine ==="
echo "OpenClaw $(openclaw --version 2>&1)"
echo "Estado em: $HOME/.openclaw"

# 3) Token de autenticação (obrigatório — sem token padrão)
if [ -z "$OPENCLAW_GATEWAY_TOKEN" ]; then
  echo "ERRO: OPENCLAW_GATEWAY_TOKEN não definido. Configure nas variáveis de ambiente do CapRover."
  exit 1
fi

# 4) Inicializa config se não existir
if [ ! -f "$HOME/.openclaw/openclaw.json" ]; then
  echo "Inicializando setup..."
  openclaw setup --non-interactive --mode local 2>&1 || true
fi

# 5) Configura Control UI para aceitar conexões externas
openclaw config set gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback true --strict-json 2>&1 || true
openclaw config set gateway.mode local 2>&1 || true

# 6) Auto-pairing em background (roda antes do exec, verifica a cada 5s por 5 min)
(
  sleep 8
  echo ">>> Aguardando pairing request para auto-aprovação..."
  for i in $(seq 1 60); do
    if openclaw devices approve --latest --token "$OPENCLAW_GATEWAY_TOKEN" 2>&1 | grep -qi 'approved'; then
      echo ">>> Pairing aprovado automaticamente! ✅"
      break
    fi
    sleep 5
  done
) &

# 7) Dashboard URL nos logs
(
  sleep 6
  echo ""
  echo "============================================"
  echo "  DASHBOARD URL (copie e acesse no browser):"
  echo "============================================"
  openclaw dashboard --no-open 2>&1 || echo "https://seu-dominio/?token=$OPENCLAW_GATEWAY_TOKEN"
  echo "============================================"
  echo ""
) &

echo "Iniciando Gateway na porta ${OPENCLAW_PORT:-18789}..."

# 8) Gateway em foreground via exec (melhor pra sinais/stop/restart)
exec openclaw gateway run \
  --port "${OPENCLAW_PORT:-18789}" \
  --bind lan \
  --token "$OPENCLAW_GATEWAY_TOKEN" \
  --allow-unconfigured \
  --verbose
