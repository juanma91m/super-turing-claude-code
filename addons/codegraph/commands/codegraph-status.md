---
description: Muestra el estado real del índice CodeGraph de un repositorio sin modificarlo.
argument-hint: "[path]"
---
Delegá esta tarea al subagente `code-inspector` (Agent tool, subagent_type: code-inspector) con estas instrucciones:

Revisá el estado CodeGraph del proyecto `$ARGUMENTS` (si no se recibió path, usá el repository root actual). Ejecutá únicamente:

```bash
bash ~/.config/opencode/scripts/codegraph_project_status.sh --project-root "<root>"
```

Informá si el índice existe, versión que lo construyó, archivos/nodos/aristas, cambios pendientes y si CodeGraph recomienda reindex. No modifiques nada.
