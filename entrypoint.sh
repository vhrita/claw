#!/bin/bash
set -e

echo "=== VHXCO Claw Engine ==="
echo "Iniciando OpenClaw Gateway na porta 18789..."

# Inicia o gateway com a Control UI na porta 18789
# --host 0.0.0.0 permite acesso externo (necessário dentro do Docker)
exec openclaw gateway --port 18789 --host 0.0.0.0 --verbose
