---
description: Toma tmp/<ticket>/verdict.md como insumo primario cuando existe y arranca la implementación.
argument-hint: "[ticket]"
---
Implementá el ticket `$ARGUMENTS`.

Objetivo:
- si existe `tmp/$ARGUMENTS/verdict.md`, tomarlo como insumo principal,
- leer primero las referencias de `Evidencias` dentro de ese verdict,
- si sigue faltando contexto, usar `tmp/$ARGUMENTS/repo_findings.md` y luego `tmp/$ARGUMENTS/analysis.md`,
- verificar que el veredicto siga siendo válido frente al código real,
- implementar el cambio mínimo suficiente (delegando en los subagentes de desarrollo que correspondan si la especialización aporta foco),
- reportar riesgos o desvíos si aparecen,
- dejar `tmp/$ARGUMENTS/result-dev.md` al finalizar cuando el proyecto use ese patrón (secciones: Cambio realizado, Deuda técnica detectada, Riesgos/impacto, Validaciones manuales recomendadas).

Reglas:
- En un proyecto que admite handoff, este comando con ticket concreto es pedido explícito; usarlo y exigir lo requerido antes de implementar. En proyectos sin ese flujo, implementar desde el alcance acordado sin crear `verdict.md` ni `result-dev.md`. Un ID aislado no lo activa.
- si el proyecto usa `verdict.md` y falta o está incompleto, frená y explicitá qué falta,
- no recorras `tmp/$ARGUMENTS/` completo salvo necesidad real; priorizá `verdict -> evidencias -> repo_findings -> analysis`,
- no hagas `git add`, `git commit` ni push,
- cuidá performance y compatibilidad.
