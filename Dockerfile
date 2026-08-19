# Hades - Hermes Agent (Nous Research) rodando no cluster k3s do Olympus.
#
# Camada fina em cima da imagem oficial, so pra fixar a versao (nunca "latest"
# - ja sofremos duas vezes no Cerbero com base image nao pinada: gogcli e o
# proprio ghcr.io/openclaw/openclaw:latest ficando desalinhado do resto do
# sistema, ver LICOES-APRENDIDAS.md do cerbero-openclaw-wslc). Atualizar a
# versao aqui e um ato deliberado, nao uma surpresa de rebuild.
#
# Todo o estado (config.yaml, chaves de API, sessoes, memorias, skills) vive
# fora da imagem, no volume /opt/data (PVC hades-data) - nada disso e
# copiado pra dentro da imagem nem versionado neste repo.
FROM nousresearch/hermes-agent:v2026.8.18

CMD ["gateway", "run"]
