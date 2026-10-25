---
description: Refresca el análisis de un ticket y limpia/actualiza tmp/<ticket>/ con evidencia vigente.
argument-hint: "[ticket]"
---
Delegá esta tarea al subagente `planner` (Agent tool, subagent_type: planner) con estas instrucciones:

Refrescá el análisis del ticket `$ARGUMENTS`.

Objetivo:
- releer el ticket (vía `jira_helper.sh issue/context` si el proyecto tiene Jira configurado) o la nueva información disponible,
- actualizar `tmp/$ARGUMENTS/` si el proyecto usa ese workspace,
- eliminar o corregir hipótesis/evidencias obsoletas,
- dejar el workspace temporal consistente con el estado actual del análisis.

Reglas:
- Un ticket o este comando no habilitan handoff por sí solos: respetá el workflow local; si no está activo, respondé sin crear artefactos de implementación.
- Rovo es complemento solo si falta contexto material y el caller tiene acceso aprobado; puede pasar evidencia destilada al planner. No exijas Rovo al planner si no está en sus tools ni repitas consultas ya resueltas por helper/evidencia.
- no implementes código,
- si el proyecto no usa workflow con `tmp/$ARGUMENTS/`, devolvé el refresh en tu respuesta en vez de escribir archivos,
- si algo cambió, dejalo explícito,
- mantené el foco en información útil para llegar a un `verdict.md` sólido.
