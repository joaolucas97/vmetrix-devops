# ADR-003 — Versionamento de Artefatos: Semântico + Commit SHA

**Data:** 2024  
**Status:** Aceito

## Contexto

Era necessário definir como versionar os artefatos produzidos pelo pipeline: JARs das bibliotecas e imagens Docker dos serviços. O requisito do desafio é que a versão seja rastreável ao commit que a originou.

## Decisão

- **Bibliotecas (JAR):** versionamento semântico (`MAJOR.MINOR.PATCH`) gerenciado no `pom.xml`, independente dos serviços
- **Imagens Docker:** tag imutável baseada no commit SHA (`ghcr.io/org/svc-calc:a3f2c1d`), opcionalmente combinada com a versão semântica do serviço

## Alternativas Consideradas

**Somente `latest`**
- Simples, mas não rastreável
- Impossibilita rollback sem rebuild
- Rejeitado

**Somente semântico (ex: `1.2.3`)**
- Legível e familiar
- Requer processo de bump de versão a cada release
- Em um monorepo com múltiplos serviços, coordenar bumps manuais é propenso a erros

**Commit SHA como tag primária**
- Imutável por definição — um SHA sempre aponta para o mesmo código
- Rastreabilidade direta: dado o SHA da imagem em produção, o commit exato é identificável imediatamente
- Não requer processo de bump manual
- Menos legível para humanos, mas isso é mitigado pelo uso adicional de tags semânticas quando necessário

## Consequências

- Toda imagem publicada tem uma tag imutável que mapeia diretamente para um commit Git
- Rollback = trocar a tag no manifest GitOps para um SHA anterior — a imagem já existe no registry
- A tag `latest` nunca é usada em staging ou production
- Para bibliotecas, o versionamento semântico no `pom.xml` é suficiente pois o JAR é um artefato interno consumido em tempo de build, não em tempo de execução
