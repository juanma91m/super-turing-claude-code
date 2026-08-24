# super-turing-claude-code

Source of truth versionado para la migración del ecosistema `super-turing-opencode` hacia Claude Code. Este repo es análogo, en espíritu y disciplina, a `opencode-stack`: define qué se despliega en `~/.claude/`, cómo se sincroniza, y qué queda deliberadamente fuera (secretos, estado machine-local, addons todavía no migrados).

**No reemplaza a OpenCode.** El deploy en `~/.config/opencode/` sigue intacto y funcionando; este repo solo agrega la capa equivalente del lado Claude Code, de forma aditiva.

## Estado: completo (Fases 1-6)

Incluye:
- 10 subagentes "base" (`planner`, `code-reviewer`, `reviewer`, `agent-design`, `code-inspector`, `backend-java-developer`, `frontend-web-developer`, `ui-web-designer`, `dev-test`, `merge-conflict-resolver`) + 2 subagentes de Knowledge (`knowledge-curator`, `knowledge-reader`).
- 7 slash commands (2 base + 5 de Knowledge).
- 18 skills (15 base + 3 de Knowledge).
- `~/.claude/CLAUDE.md` global (rol por defecto — reemplaza conceptualmente a `master-dev`, que en Claude Code no existe como agente primario intercambiable).
- Hook `PreToolUse` `env-guard` (bloqueo de `.env*`) + `sensitive-reference-guard` (ask forzado en `.ssh`, `.gnupg`, credenciales AWS/gh, claves privadas, `/etc/shadow`/`sudoers`).
- Perfil de permisos `permission-autopilot` en `~/.claude/settings.json` (`permissions.allow`/`ask`), puerto 1:1 de la lista de patrones bash riesgosos del plugin original.
- Hook `UserPromptSubmit` `engram-memory-hints` (nudge a guardar en Engram cuando el usuario dice "remember"/"don't forget"/etc.).
- Registro MCP manual de `context7`, `playwright`, `stitch` y `engram` (mismo binario/DB/tools que ya usa `super-turing-opencode-knowledge`, sin plugin oficial — por elección explícita, para que funcione tal cual funciona en OpenCode).

**Fase 2 (CodeGraph)** agrega: MCP `codegraph` (tool `mcp__codegraph__explore`, mismo aislamiento de superficie que en OpenCode), skill `codegraph-analisis-estructural`, comandos `/codegraph-init`, `/codegraph-status`, `/codegraph-sync`, `/codegraph-reindex`, y acceso a `codegraph_explore` para `planner`/`reviewer`/`code-inspector`/`code-reviewer`. Reusa los índices `.codegraph/` ya generados por proyecto (no depende del agente que los consulta).

De paso, fase 2 corrigió un bug de fase 1: varios subagentes (`planner`, `reviewer`, `code-inspector`, `agent-design`, `dev-test`, `knowledge-curator`, `knowledge-reader`) mencionaban en su prompt llamar tools `mem_*` de Engram directamente, pero no las tenían en su `tools:` — en Claude Code eso las dejaba inaccesibles. Ya está corregido (ver `CHANGELOG.md`).

**Fase 3 (Ticketing)** agrega: comandos `/ticket-plan`, `/ticket-refresh`, `/ticket-verdict` (delegan en `planner`), `/ticket-implement` (corre directo), `/ticket-validate` (delega en `dev-test`); skill `workflow-ticket-handoff`; y notas de "ticketing opcional" en `planner`, `agent-design` y `CLAUDE.md`. Sin MCP nuevo — reusa `~/.config/opencode/scripts/jira_helper.sh` (100% lectura contra Jira; la escritura es local, sandboxeada a `tmp/<ticket>/`).

**Fase 4 (Documents)** agrega: comandos `/crear-diagrama` y `/publicar-documento`, skills `diagramacion-tecnica` y `publicacion-documental` (portadas verbatim — ya eran agnósticas de agente OpenCode). Sin MCP nuevo — reusa los runtimes pineados de Quarto/D2 y los wrappers `publish_document.py`/`render_diagram.py`/`render_infographic.py` existentes, más las plantillas en `~/.config/opencode/documents/`.

**Fase 5 (github-accounts-local)** agrega: skill `github-cuentas-multiples` (mapeo owner→cuenta `gh`→alias SSH para las identidades GitHub que conviven en esta máquina). Portada verbatim. **Es machine-local por diseño** (ver `STACK-MANIFEST.json` → `machineLocalOnly`) — si este repo se clona a otra máquina, esta skill hay que reparametrizarla, no reusarla tal cual.

**Fase 6 (rollout a higyrus-workspace + de-duplicación cross-stack)** agrega, para los 9 proyectos de `/home/jmagnaterra/TRABAJO/AUNE/higyrus-workspace/` (higyrus, market-data, virtual-broker, keycloak, higyrus-gateway, aggregator, perfil-inversor, documento-api, oms-api):
- Un `CLAUDE.md` real por proyecto (autoría directa, agnóstico de herramienta — reemplaza el bridge `CLAUDE.md -> AGENTS.md` que existía en `higyrus`/`aggregator`).
- `<project>/.claude/skills/<nombre>` symlinkeadas a `<project>/.opencode/skills/<nombre>/SKILL.md` (script `addons/higyrus-workspace/scripts/sync-project-overlay.sh`) — cero copias, un solo lugar de verdad por skill.
- 2 nuevos agentes globales: `backend-python-developer` (market-data) y `backend-typescript-developer` (oms-api).
- Fix de gap de fase 1: comandos globales `/code-review` y `/code-review-pr` (nunca se habían portado).
- **De-duplicación cross-stack** (autorizada explícitamente): `aune-code-review-eficiente`, `aune-higyrus-workspace-ecosystem` y `ticket-code-review.md` — antes duplicados idénticos en los 9 proyectos — se promovieron a globales en `~/.config/opencode/` y se reemplazaron por symlinks en los 9 lados; el MCP `atlassian-rovo` se promovió igual a `~/.config/opencode/opencode.json` global (verificado con `opencode debug config` que el merge global+proyecto sigue resolviéndolo tras sacarlo de los 9 `opencode.json` de proyecto). Ver `STACK-MANIFEST.json` → `crossStackSymlinks` y `opencodeSideChangesThisPhase` para el detalle completo.
- Retro-fix de fases 1-5: 8 skills globales que ya se habían portado con pequeñas diferencias de texto se reconciliaron y ahora son symlinks al archivo de OpenCode (ya actualizado) en vez de copias independientes — editar en OpenCode alcanza para ambos stacks. Frontmatter YAML agregado a las ~14 skills de dominio de `higyrus` (el único proyecto que no lo tenía) para poder symlinkearlas también.
- `higyrus-AN` (clon git duplicado y desactualizado de `higyrus`) quedó documentado como fuera de alcance, sin tocar.

El plan completo de cada fase, con todas las decisiones de arquitectura, con todas las decisiones de arquitectura y el mapeo agente-por-agente, quedó documentado en `/home/jmagnaterra/.claude/plans/glimmering-twirling-stroustrup.md` (sesión original de migración).

## Uso

```bash
./install.sh                 # primer deploy + registro de MCP servers
./scripts/sync-claude-stack.sh --status   # ver qué cambió sin tocar nada
./scripts/sync-claude-stack.sh            # aplicar cambios (con backup de lo reemplazado)
```

Backups de sync quedan en `~/.claude/backups/claude-stack-sync/<timestamp>/`, con retención de 5 snapshots.

## Principio de no-destrucción

- Fases 1-5: nunca se editó `~/.config/opencode/**` ni ningún repo bajo `~/.local/src/super-turing-opencode-*`.
- Fase 6 (autorizada explícitamente por el usuario): sí se edita el lado OpenCode, pero **siempre de forma aditiva** — agregar frontmatter YAML donde falta, o consolidar duplicados exactos a una sola fuente con symlinks. Nunca se borra contenido real. Ver `STACK-MANIFEST.json` → `opencodeSideChangesThisPhase` para el listado completo.
- Los scripts de Qdrant/Engram/Jira (`~/.config/opencode/scripts/*.sh`, binario `engram`) se reusan por ruta absoluta, nunca se copian.
- `~/.claude/settings.json` solo recibe un merge de las claves `hooks`/`permissions`; el resto de las claves (ej. `theme`) queda intacto.
- Los MCP servers se registran con `claude mcp add-json --scope user`, nunca editando `~/.claude.json` a mano.
- Cuando el archivo fuente de un skill es en sí un symlink hacia OpenCode, `sync-claude-stack.sh` replica un symlink real en destino (no una copia) — ver `STACK-MANIFEST.json` → `crossStackSymlinks`.
