# 🦀 VHXCO Claw Engine

Container Docker para rodar o **OpenClaw** (+ Claude Code) na VPS via **CapRover**.

> **⚠️ Nunca coloque chaves de API no Dockerfile.** Use as variáveis de ambiente do CapRover.

## Stack do Container

| Componente | Versão |
|---|---|
| Node.js | 20 (slim) |
| Claude Code | latest |
| OpenClaw | latest |
| Extras | git, curl, python3, pip, sudo |

## Build & Push (Manual)

```bash
# Login no GHCR
export CR_PAT=SEU_TOKEN_GITHUB
echo $CR_PAT | docker login ghcr.io -u SEU_USUARIO --password-stdin

# Build
docker build -t ghcr.io/vhxco/vhxco-claw-engine:1.0.0 .

# Push
docker push ghcr.io/vhxco/vhxco-claw-engine:1.0.0
```

## Build & Push (CI/CD)

O workflow do GitHub Actions faz o build automaticamente ao criar uma tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

A imagem será publicada em:
- `ghcr.io/vhxco/vhxco-claw-engine:1.0.0`
- `ghcr.io/vhxco/vhxco-claw-engine:latest`

## Deploy no CapRover

1. **Apps > Deployment** → Method 6: Deploy regular Docker Image
   - Image: `ghcr.io/vhxco/vhxco-claw-engine:1.0.0`

2. **App Config**
   - Desmarcar HTTP Settings (Port 80) — acesso via terminal apenas

3. **Environment Variables**
   - `ANTHROPIC_API_KEY`
   - `GOOGLE_API_KEY`

4. **Persistent Directories**
   - Path in App: `/vhxco/data`
   - Label: `vhxco_data_vol`

## Como Usar o Agente

### Via SSH

```bash
ssh root@sua-vps-ip
docker exec -it $(docker ps -qf "name=srv-captain--vhxco-claw-engine") openclaw
```

### Via Painel CapRover

Aba **Log** → **Execute Shell** → digitar `openclaw`

## Estrutura de Pastas (Container)

```
/vhxco/
├── projects/   # Projetos do agente
└── data/       # Dados persistidos (volume)
```

## Versionamento

Seguir padrão semântico: `v1.0.0`, `v1.0.1`, `v1.1.0`, etc.

---

**VHXCO** — Built with 🧠
