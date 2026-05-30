# PRD -- Eco-Smart: carga con excedente solar (MVP)

> Nivel: MVP (v1) | Estado: draft | Version: 0.1 | Fecha: 2026-05-30 | Autor: Producto
>
> EJEMPLO ILUSTRATIVO (dominio Wallbox). No es una decision real de la empresa.

## 1. Business problem to solve
Los propietarios de vivienda con paneles fotovoltaicos quieren cargar el coche con
el excedente solar en vez de verterlo a la red a precio bajo. Hoy el cargador es
"tonto" respecto a la produccion solar: carga a corriente fija, ignorando cuanta
energia sobra en cada momento.

## 2. Business Case / Impact
- Por que ahora: el autoconsumo residencial crece y el precio de vertido a red es
  bajo; cargar con excedente es un ahorro tangible para el usuario.
- Coste de no hacerlo: perdemos diferenciacion frente a competidores que ya
  ofrecen carga solar; el cargador se percibe como commodity.
- Impacto esperado: aumento del attach rate del Pulsar Plus en hogares con FV y
  mayor retencion; posible upsell del medidor de energia. Orden de magnitud:
  decenas de miles de hogares objetivo en el primer ano.
- North star: porcentaje de energia de carga proveniente de excedente solar.

## 3. Objetivos y metricas de exito
| Objetivo                          | Metrica                          | Linea base | Meta MVP |
|-----------------------------------|----------------------------------|------------|----------|
| Cargar con excedente solar        | % energia de carga de origen solar | 0%       | > 60%    |
| Visibilidad para el usuario       | % usuarios FV que activan Eco-Smart | 0%      | > 40%    |

## 4. Usuarios objetivo
Propietario de vivienda unifamiliar con instalacion FV y un Pulsar Plus, que
quiere maximizar el autoconsumo sin tener que gestionarlo manualmente.

## 5. Scope
In-scope (MVP):
- Detectar el excedente solar disponible en cada momento.
- Modular la corriente de carga para usar solo el excedente.
- Mostrar en la app cuanta energia solar se ha usado para cargar.

Out-of-scope:
- V2G / devolver energia a la red.
- Gestion de varios cargadores (Power Sharing).
- Tarifas dinamicas de red.

## 6. Epics y Use Cases

### Epic E1 -- Medicion del excedente solar
- Outcome de negocio: el cargador conoce el excedente disponible en tiempo real.
- Prioridad: must
- Use Cases:
  - UC1.1 -- Como propietario, quiero que el cargador sepa cuanto excedente solar
    hay para poder usarlo.

### Epic E2 -- Modulacion de carga al excedente
- Outcome de negocio: el coche carga sin tirar de red mientras haya sol.
- Prioridad: must
- Use Cases:
  - UC2.1 -- Como propietario, quiero que el coche cargue solo con el excedente
    para no comprar energia a la red.
  - UC2.2 -- Como propietario, quiero un modo "solar + minimo de red" para no
    parar la carga si baja el sol.

### Epic E3 -- Visibilidad en la app
- Outcome de negocio: el usuario ve el valor del autoconsumo y confia en el modo.
- Prioridad: should
- Use Cases:
  - UC3.1 -- Como propietario, quiero ver cuanta energia solar he usado para
    cargar en la app.

## 9. Non-goals
- No optimizamos contra el precio de mercado en el MVP, solo contra el excedente.

## 11. Trazabilidad PRD -> ejecucion
| Epic | User Stories (ids feature_list) |
|------|----------------------------------|
| E1   | US-001, US-002                   |
| E2   | US-003, US-004                   |
| E3   | US-005                           |
