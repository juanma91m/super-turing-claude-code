---
description: Revisa una rama origen contra una rama destino y guarda un informe incremental global.
argument-hint: "[rama-origen] [rama-destino]"
arguments:
  - name: origen
  - name: destino
---
Delegá esta tarea al subagente `code-reviewer` (Agent tool, subagent_type: code-reviewer) con estas instrucciones:

Revisá el desarrollo de la rama origen `$origen` contra la rama destino `$destino`.

Aplicá la skill `code-review-branch-to-branch`, usá `merge-base`, no modifiques el repositorio y guardá el informe bajo `~/code-reviews/<identificador>/code-review-N.md` mediante el helper aprobado.

Si falta cualquiera de las dos ramas o la orientación es ambigua, pedí aclaración antes de revisar.
