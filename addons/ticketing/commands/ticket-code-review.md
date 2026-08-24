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

Aplicá `code-review-branch-to-branch` (incluye presupuesto operativo de review), consultá Jira una sola vez en modo `context` (`bash ~/.config/opencode/scripts/jira_helper.sh context $ticket ...`), no modifiques código y guardá el informe en el próximo `tmp/$ticket/code-review/code-review-N.md` reservado por el helper aprobado.

Si falta ticket o rama, pedí aclaración antes de iniciar.
