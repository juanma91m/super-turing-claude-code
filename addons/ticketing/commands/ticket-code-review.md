---
description: Revisa ramas por ticket Jira y guarda un informe incremental bajo tmp/<ticket>/code-review/.
argument-hint: "[ticket] [rama-origen] [rama-destino]"
arguments:
  - name: ticket
  - name: origen
  - name: destino
---
Delegá esta tarea al subagente `code-reviewer` (Agent tool, subagent_type: code-reviewer) con estas instrucciones:

Revisá el ticket `$ticket` comparando la rama origen `$origen` contra la rama destino `$destino`.

Aplicá `code-review-branch-to-branch` en modo ticket y el contrato local de review: consulta Jira acotada, helper y storage por ticket habilitados por el agente efectivo. Si no hay un contrato compatible, pedí el contexto/agente correspondiente; el comando no habilita permisos ni fallback global y no crea handoff de implementación.

Si falta ticket o rama, pedí aclaración antes de iniciar.
