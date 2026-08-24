---
description: Regenera explícitamente el índice CodeGraph de un repositorio después de confirmación.
argument-hint: "[path]"
---
Prepará el reindex de CodeGraph para `$ARGUMENTS` (si no se recibió path, usá el repository root actual).

Esta operación reemplaza un índice regenerable existente. Antes de ejecutarla:

1. mostrá el estado actual (`bash ~/.config/opencode/scripts/codegraph_project_status.sh --project-root "<root>"`),
2. explicá por qué hace falta reindex y no alcanza `/codegraph-sync`,
3. pedí confirmación explícita al usuario,
4. recién entonces ejecutá:

```bash
bash ~/.config/opencode/scripts/codegraph_project_reindex.sh --project-root "<root>" --confirm-reindex
```

No ejecutes `uninit`, `unlock` ni borres `.codegraph/` manualmente.
