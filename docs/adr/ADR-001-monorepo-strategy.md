# ADR-001 — Estratégia de Repositório: Monorepo

**Data:** 2024  
**Status:** Aceito

## Contexto

O sistema possui cinco módulos Java com dependências internas explícitas. Era necessário decidir como organizar o código-fonte: monorepo, multi-repo ou híbrido.

## Decisão

Monorepo: todos os cinco módulos no mesmo repositório Git.

## Alternativas Consideradas

**Multi-repo** (um repositório por módulo)
- Versionamento independente por padrão
- Complexidade operacional alta: cinco repositórios para manter, cinco pipelines separados, coordenação de versões entre repos
- Dificulta visualizar o impacto de uma mudança em `calc-lib` sobre `svc-calc` e `web-app`

**Híbrido** (bibliotecas em repos separados, serviços juntos)
- Reduz um pouco a complexidade do multi-repo
- Ainda exige coordenação entre repositórios para atualizar dependências

**Monorepo**
- Visibilidade total do grafo de dependências em um único lugar
- Um único PR pode modificar `calc-lib` e seus consumidores atomicamente
- Pipelines dependency-aware implementados com filtros de path no mesmo workflow
- Simplicidade operacional: um repositório, uma configuração de CI

## Consequências

- Pipelines precisam de lógica para detectar quais módulos foram alterados e buildar apenas o necessário
- Todos os módulos compartilham o mesmo histórico Git — adequado para um sistema coeso como este
- Escala bem para o tamanho atual do projeto; em projetos muito maiores (dezenas de serviços), ferramentas como Nx ou Turborepo seriam consideradas
