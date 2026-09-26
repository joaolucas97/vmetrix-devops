# ADR-004 — GitOps: ArgoCD com Kustomize

**Data:** 2024  
**Status:** Aceito

## Contexto

O desafio requer deploy contínuo declarativo com separação entre staging e production, aprovação manual para production e rollback sem rebuild. Era necessário escolher a ferramenta de GitOps e o mecanismo de templating de manifests.

## Decisão

ArgoCD como motor GitOps, Kustomize para gerenciar variações entre ambientes.

## Alternativas Consideradas

**Flux CD**
- Alternativa madura ao ArgoCD
- Modelo pull-based igualmente ao ArgoCD
- UI menos rica; operação mais orientada a CLI
- Menor adoção no mercado comparado ao ArgoCD

**ArgoCD + Helm**
- Helm é mais expressivo para parametrização complexa
- Para este projeto, a diferença entre staging e production é apenas a tag da imagem e número de réplicas — Kustomize é suficiente e mais simples
- Helm adiciona complexidade de templates desnecessária para o escopo atual

**ArgoCD + Kustomize**
- Kustomize é nativo no kubectl (sem instalação adicional)
- Modelo de `base` + `overlays` é direto para expressar diferenças entre ambientes
- ArgoCD tem suporte nativo a Kustomize sem configuração extra
- UI do ArgoCD permite visualizar o estado de sincronização, histórico de deploys e executar rollback com um clique

## Consequências

- O estado desejado do cluster vive em `gitops/` no repositório Git
- Qualquer mudança no Git é detectada pelo ArgoCD e aplicada ao cluster
- Drift (alguém modifica o cluster manualmente) é detectado e reportado como `OutOfSync`
- Rollback = reverter o commit no `gitops/` — ArgoCD aplica o estado anterior
- Staging sincroniza automaticamente; production requer sync manual (aprovação explícita)
- ArgoCD roda dentro do próprio cluster Kind — sem dependência de serviço externo
