---
name: codegraph-analisis-estructural
description: Usa CodeGraph (mcp__codegraph__explore) para analizar callers, flujos, blast radius y tests afectados en repositorios ya indexados; no usar para búsquedas literales ni para inicializar índices autónomamente.
---

# CodeGraph: análisis estructural

## Cuándo cargar esta skill

- antes de modificar símbolos con coupling no obvio,
- al rastrear un flujo entre capas o módulos,
- para identificar callers/callees o blast radius,
- para orientar revisión y selección de tests.

## Qué resuelve

CodeGraph aporta evidencia estructural vigente del código: símbolos y definiciones, callers y callees, flujos entre archivos, blast radius, tests potencialmente afectados.

No reemplaza: Engram para decisiones durables, Qdrant para corpus documental, el MCP `context7` para APIs externas, `Grep`/`Read` para confirmar texto o una línea exacta.

## Flujo

1. Resolver el repository root absoluto.
2. Consultar la tool `mcp__codegraph__explore` con una pregunta corta y símbolos concretos.
3. Pasar `projectPath` siempre que no haya default inequívoco.
4. Tratar el source devuelto como leído.
5. Abrir archivos adicionales solo para confirmar una hipótesis no cubierta.
6. Contrastar findings materiales con diff, tests o lectura directa.

## Fallback

Si no hay índice o la tool falla:
- explicitarlo,
- usar `Glob`/`Grep`/`Read`,
- sugerir `/codegraph-init <root>` si el usuario quiere habilitarlo,
- no inicializar ni reindexar por cuenta propia.

## Límites

- El grafo puede quedar incompleto por parsing dinámico o código generado.
- No usarlo como prueba única de ausencia de callers.
- No guardar el grafo en memoria durable ni Qdrant.
- No compartir `.codegraph/` entre worktrees — cada worktree necesita su propio índice.
