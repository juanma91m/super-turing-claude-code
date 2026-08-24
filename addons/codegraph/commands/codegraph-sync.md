---
description: Sincroniza incrementalmente un índice CodeGraph existente y valida su estado final.
argument-hint: "[path]"
---
Delegá esta tarea al subagente `code-inspector` (Agent tool, subagent_type: code-inspector) con estas instrucciones:

Sincronizá CodeGraph para el proyecto `$ARGUMENTS` (si no se recibió path, usá el repository root actual). Ejecutá únicamente:

```bash
bash ~/.config/opencode/scripts/codegraph_project_sync.sh --project-root "<root>"
```

No inicialices un índice ausente ni ejecutes reindex completo como fallback. Informá resultado y estado final.
