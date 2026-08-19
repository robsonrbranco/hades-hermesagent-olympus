# Hades

Segundo cérebro rodando [Hermes Agent](https://github.com/NousResearch/hermes-agent) (Nous Research) no cluster k3s do Olympus — sandbox isolado do [Cerbero](https://github.com/robsonrbranco/cerbero-openclaw-wslc) (OpenClaw), não substituto.

**Objetivo**: testar o loop de auto-aperfeiçoamento do Hermes Agent (cria/refina skills sozinho, memória cross-session) em paralelo ao `skill-workshop` do OpenClaw, e comparar sinergia/custo entre modelos de IA por vocação.

## Estado atual (12/08/2026)

- Chaves de API dos provedores (Anthropic/OpenAI/DeepSeek/Gemini) são **dedicadas**, não reaproveitadas do Cerbero — objetivo inclui comparar custo por modelo, chave compartilhada misturaria o gasto no dashboard de cada provedor.
- Estado (config, chaves, sessões, memórias, skills) vive inteiramente no PVC `hades-data` (`/opt/data`), fora da imagem e fora do git — mesmo princípio já usado no Cerbero.
- Setup inicial rodou sozinho a partir das env vars (`ANTHROPIC_API_KEY` etc.) — não precisou do wizard interativo.
- API (8642) e dashboard (9119) vêm **desligados por padrão** na imagem oficial; precisam de `API_SERVER_ENABLED=true` e `HERMES_DASHBOARD=1` explícitos (ver `k8s/hades.yaml`).
- **Dashboard público em `https://hades.ecomciencia.com`**, atrás do Cloudflare Access (só `robson.branco@gmail.com`) — mesmo padrão do Cerbero/Hermes/Argos. Segunda camada de auth própria do app (`dashboard.basic_auth` no `config.yaml`, obrigatória pro app aceitar bind em `0.0.0.0` — sem ela ele recusa subir publicamente mesmo com o Access na frente).
- **API (8642) continua só interna ao cluster** (Service ClusterIP, sem Ingress) — protegida por `API_SERVER_KEY` (bearer token). Não exposta publicamente de propósito: com `terminal.backend` local (padrão, não sandboxado), qualquer chamada autenticada roda com acesso total ao terminal/filesystem do container. Avaliar `terminal.backend: docker` antes de conectar outro pod nela via MCP.

## Pendências conhecidas

- Sem backup (restic→R2) ainda — adicionar quando o estado acumulado valer a pena proteger.
- `terminal.backend` ainda não sandboxado (ver acima) — bloqueia conectar outros pods na API com segurança.

## Estrutura

- `Dockerfile` — camada fina sobre `nousresearch/hermes-agent`, versão pinada (nunca `latest`).
- `k8s/hades.yaml` — PVC + Deployment + Service + Ingress, namespace `olympus`.
- `.github/workflows/deploy.yml` — build+push+deploy automático a cada push na `main`.
