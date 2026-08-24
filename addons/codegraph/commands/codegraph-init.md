---
description: Inicializa o adopta de forma segura el índice CodeGraph machine-local de un repositorio.
argument-hint: "[path]"
---
Inicializá CodeGraph para el proyecto `$ARGUMENTS` (si no se recibió path, usá el repository root actual).

Ejecutá únicamente:

```bash
bash ~/.config/opencode/scripts/codegraph_project_init.sh --project-root "<root>"
```

Reglas:
- no crear `codegraph.json` salvo que exista una necesidad de configuración confirmada,
- si ya existe un índice compatible, adoptarlo sin reindexar,
- si el wrapper informa incompatibilidad o recomienda reindex, detenerse y explicarlo — no ejecutar `/codegraph-reindex` por tu cuenta,
- devolver el resumen de `codegraph status` sin modificar código funcional.
