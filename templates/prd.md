# PRD -- <Nombre del producto / MVP>

> Nivel: MVP (v1) | Estado: draft | Version: 0.1 | Fecha: AAAA-MM-DD | Autor: <nombre>
>
> Limite de detalle: este PRD define el QUE y el PORQUE a nivel Epic + Use Case.
> NO baja a User Stories, ni a criterios de aceptacion EARS, ni a diseno tecnico.

## 1. Business problem to solve
<El problema de negocio/usuario en 1-3 parrafos. Que duele hoy, a quien, con que
evidencia. Sin proponer solucion todavia.>

## 2. Business Case / Impact   [la seccion mas importante]
- Por que ahora: <ventana de oportunidad, presion competitiva, regulacion...>
- Coste de no hacerlo: <que perdemos si no lo hacemos>
- Impacto esperado (medible): <metrica de negocio con orden de magnitud>
- Inversion estimada (orden de magnitud): <esfuerzo, no presupuesto exacto>
- North star (metrica que define ganar): <una metrica>

## 3. Objetivos y metricas de exito (KPIs)
| Objetivo | Metrica | Linea base | Meta MVP |
|----------|---------|------------|----------|
| <obj 1>  | <kpi>   | <hoy>      | <meta>   |

## 4. Usuarios objetivo (personas)
<1-3 personas: quien, contexto, job-to-be-done. Sin sobre-detallar.>

## 5. Scope
In-scope (MVP):
- <capacidad 1>
- <capacidad 2>

Out-of-scope (explicito, lo que el MVP NO hace):
- <fuera 1>
- <fuera 2>

## 6. Epics y Use Cases
> Cada Epic = una capacidad con outcome de negocio. Cada Use Case = actor +
> objetivo + valor, a nivel conversacional. Cada Epic se descompondra en User
> Stories que entran en feature_list.json.

### Epic E1 -- <nombre>
- Outcome de negocio: <que cambia cuando esto existe>
- Prioridad: must | should | could
- Use Cases:
  - UC1.1 -- Como <actor>, quiero <objetivo> para <valor>.
  - UC1.2 -- Como <actor>, quiero <objetivo> para <valor>.

### Epic E2 -- <nombre>
- ...

## 7. Assumptions y constraints
- <supuesto / restriccion>

## 8. Dependencies y risks
- <dependencia externa / riesgo + mitigacion>

## 9. Non-goals
- <decision deliberada de NO hacer X en el MVP>

## 10. Open questions
- <pregunta abierta pendiente>

## 11. Trazabilidad PRD -> ejecucion
| Epic | User Stories (ids feature_list) |
|------|----------------------------------|
| E1   | US-001, US-002 ...               |
