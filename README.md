# Hades

Segundo cérebro rodando [Hermes Agent](https://github.com/NousResearch/hermes-agent) (Nous Research) no cluster k3s do Olympus — sandbox isolado do [Cerbero](https://github.com/robsonrbranco/cerbero-openclaw-wslc) (OpenClaw), não substituto.

**Objetivo**: testar o loop de auto-aperfeiçoamento do Hermes Agent (cria/refina skills sozinho, memória cross-session) em paralelo ao `skill-workshop` do OpenClaw, e comparar sinergia/custo entre modelos de IA por vocação.

## Estado atual (11/08/2026)

- Deploy inicial: só Control UI/dashboard (porta 9119) + API (porta 8642), sem canal de mensageria (WhatsApp/Telegram) e sem exposição pública ainda — decisão consciente, validar comportamento isolado primeiro.
- Chaves de API dos provedores (Anthropic/OpenAI/DeepSeek/Gemini) são **dedicadas**, não reaproveitadas do Cerbero — objetivo inclui comparar custo por modelo, chave compartilhada misturaria o gasto no dashboard de cada provedor.
- Estado (config, chaves, sessões, memórias, skills) vive inteiramente no PVC `hades-data` (`/opt/data`), fora da imagem e fora do git — mesmo princípio já usado no Cerbero.

## Pendências conhecidas

- **Setup inicial provavelmente precisa de um passo manual**: a doc oficial do Hermes Agent mostra um wizard interativo (`hermes-agent setup`) na primeira execução. As env vars (`ANTHROPIC_API_KEY` etc.) cobrem o caso simples de 1 provedor; pra registrar os 4 provedores com roteamento por vocação/custo, provavelmente vai precisar editar `/opt/data/config.yaml` direto no pod (`kubectl exec`) depois do primeiro deploy — mesmo padrão já usado no Cerbero pra autenticação de modelo (env var sozinha não é confiável em runtime real).
- Sem Terraform/DNS/Cloudflare Access ainda — só depois de validar que vale manter.
- Sem backup (restic→R2) ainda — adicionar quando o estado acumulado valer a pena proteger.

## Estrutura

- `Dockerfile` — camada fina sobre `nousresearch/hermes-agent`, versão pinada (nunca `latest`).
- `k8s/hades.yaml` — PVC + Deployment + Service, namespace `olympus`.
- `.github/workflows/deploy.yml` — build+push+deploy automático a cada push na `main`.
