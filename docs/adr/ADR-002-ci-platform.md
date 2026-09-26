# ADR-002 — Plataforma de CI: GitHub Actions

**Data:** 2024  
**Status:** Aceito

## Contexto

Era necessário escolher uma plataforma de CI para automatizar builds, testes e publicação de artefatos. O critério principal era integração com o repositório Git e suporte a builds dependency-aware em monorepo.

## Decisão

GitHub Actions.

## Alternativas Consideradas

**Jenkins**
- Flexibilidade máxima, amplamente adotado em empresas
- Requer infraestrutura própria para hospedar o servidor
- Configuração e manutenção mais complexas
- Não justificado para o escopo deste projeto

**GitLab CI**
- Excelente integração com GitLab Registry e GitLab Packages
- Requereria migrar o repositório para GitLab
- Sintaxe de pipelines madura e bem documentada

**GitHub Actions**
- Integração nativa com o repositório GitHub
- Filtros `paths` por job permitem implementar builds dependency-aware sem ferramentas externas
- `needs` entre jobs expressa o grafo de dependências diretamente no YAML
- GitHub Container Registry (GHCR) e GitHub Packages integrados sem configuração adicional
- Gratuito para repositórios públicos
- Sem infraestrutura para manter

## Consequências

- Pipelines declarados em `.github/workflows/` versionados junto ao código
- Dependency-aware builds implementados com `paths` filters e `needs` — sem scripts externos
- Aprovação de production via `environment` com `required reviewers` nativo do GitHub
- Vendor lock-in no GitHub — mitigado pelo fato de que os scripts de build (Maven, Docker) são independentes de plataforma
