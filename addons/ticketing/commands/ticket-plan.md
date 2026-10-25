---
description: Inicia o reinicia la fase de análisis de un ticket y prepara tmp/<ticket> cuando el proyecto usa workflow de tickets.
argument-hint: "[ticket]"
---
Delegá esta tarea al subagente `planner` (Agent tool, subagent_type: planner) con estas instrucciones:

Analizá el ticket `$ARGUMENTS`.

Objetivo:
- iniciar o reiniciar la fase de análisis,
- si el proyecto usa Jira y workspace temporal, crear o actualizar `tmp/$ARGUMENTS/` (usando `bash ~/.config/opencode/scripts/jira_helper.sh dump $ARGUMENTS` o los subcomandos `note`/`write`/`mkdir` para escribir localmente bajo `tmp/$ARGUMENTS/`, nunca fuera de ese path),
- usar `jira_helper.sh` (lectura Jira: `issue`/`search`/`context`/`attachments`) si el proyecto tiene `JIRA_BASE_URL`/`JIRA_EMAIL`/`JIRA_API_TOKEN` configurados en su `.env` y está aprobado; si no, no asumas acceso a Jira,
- identificar problema/objetivo, alcance, estado actual, primeras hipótesis, preguntas abiertas y evidencias iniciales.

Reglas:
- En un proyecto que admite handoff, este comando con ticket concreto es pedido explícito: preparar el handoff aplicable sin repreguntar ni decidir por conveniencia. Un ID aislado o un proyecto review-only no lo habilitan.
- Rovo es complemento solo si falta contexto material y el caller tiene acceso aprobado; puede pasar evidencia destilada al planner. No exijas Rovo al planner si no está en sus tools ni repitas consultas ya resueltas por helper/evidencia.
- no implementes código,
- si el proyecto no usa workflow con `tmp/$ARGUMENTS/`, no lo fuerces,
- si el requerimiento sigue ambiguo, terminá con preguntas concretas,
- si el proyecto adopta el patrón de handoff, dejá encaminado `tmp/$ARGUMENTS/verdict.md` (con la skill `workflow-ticket-handoff`) o explicitá qué falta para cerrarlo.
