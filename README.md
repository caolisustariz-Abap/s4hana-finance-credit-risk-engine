# S/4HANA Credit Risk Engine (ABAP Cloud / POO)

## 📌 Descripción del Proyecto
Este repositorio contiene un **Motor de Evaluación de Riesgo Comercial y Límite de Crédito** desarrollado bajo los estándares más estrictos de **ABAP Cloud** y los principios de la Programación Orientada a Objetos (POO). 

El sistema simula un escenario real del módulo de finanzas de SAP S/4HANA (Gestión de Crédito / Cuentas por Cobrar FI-AR), evaluando de forma automática el riesgo de impago de un cliente basándose en sus facturas vencidas (*Overdue Invoices*) y partidas abiertas (*Open Debts*) antes de autorizar o bloquear un pedido de venta.

---

## 🏗️ Arquitectura de Software y Conceptos Avanzados de POO
Para garantizar la mantenibilidad, escalabilidad y un código limpio (*Clean ABAP*), el proyecto se diseñó utilizando los siguientes pilares arquitectónicos:

1. **Diseño Desacoplado mediante Interfaces (`ZIF_FIN_CREDIT_CHECK`):** Se definió una interfaz pública como contrato único de comunicación. Esto permite cambiar las reglas o el motor interno de riesgo en el futuro sin alterar las aplicaciones consumidoras.
2. **Encapsulación Estricta de Datos (`ZCL_FIN_CUSTOMER_FINANCIALS`):** Los estados financieros confidenciales del cliente se modelaron de forma aislada con visibilidad privada (`PRIVATE SECTION`), exponiendo su lectura únicamente mediante métodos públicos (*Getters*).
3. **Inyección de Dependencias y Colaboración:** El motor evaluador recibe instancias completas de objetos financieros como parámetros de entrada, promoviendo el acoplamiento débil entre componentes.
4. **Robustez con Excepciones Basadas en Clases (`ZCX_FIN_INVALID_AMOUNT`):** Se implementó una clase de excepción global personalizada heredada de `CX_STATIC_CHECK` y controlada mediante bloques `TRY ... CATCH` para mitigar riesgos transaccionales (como importes negativos o inválidos) sin colapsar el sistema (*Dumps*).
5. **Sintaxis ABAP Moderna (7.40+):** Uso estricto de declaraciones en línea (*Inline Declarations*), constructores de instancias modernos (`NEW`), expresiones condicionales y plantillas de texto dinámicas (*String Templates*).

---

## 📊 Reglas de Negocio Financieras Implementadas
El motor procesa el análisis bajo las siguientes directrices de control de riesgo:
- **Límite de Crédito Base:** Asignación global estática de `$50,000.00 USD`.
- **Control de Morosidad Histórica:** Si un cliente supera el umbral máximo de **3 facturas vencidas**, su puntaje de riesgo escala automáticamente a **80/100**, disparando un bloqueo inmediato por riesgo financiero crítico.
- **Validación de la Exposición Total:** El sistema calcula matemáticamente la exposición sumando las deudas actuales más el importe del nuevo pedido. Si el total supera el límite de crédito disponible, el pedido se deniega detallando el saldo exacto remanente para compras.

---

## 📂 Componentes del Repositorio
El circuito completo se compone de los siguientes objetos de desarrollo en Eclipse ADT:

- **`ZIF_FIN_CREDIT_CHECK`**: Interfaz que define las estructuras de resultados y firmas del análisis.
- **`ZCL_FIN_CUSTOMER_FINANCIALS`**: Clase de dominio que encapsula los atributos financieros del deudor.
- **`ZCL_FIN_CREDIT_ENGINE`**: El núcleo lógico del proyecto; procesa el scoring y el control de saldos.
- **`ZCX_FIN_INVALID_AMOUNT`**: Excepción basada en clases para el control de errores de negocio.
- **`ZCL_FIN_RUN_RISK_ANALYSIS`**: Clase ejecutable (`if_oo_adt_classrun`) utilizada como banco de pruebas para simular escenarios aprobados, bloqueados y excepciones.

---

## 🖥️ Demostración de Ejecución en Consola

### Escenario A: Excepción Capturada (Importe Negativo)
Cuando se intenta ingresar un importe inválido en el flujo, el bloque `TRY-CATCH` captura la excepción personalizada e imprime una alerta controlada:
```text
==================================================
     S/4HANA CREDIT RISK ENGINE - SIMULATION     
==================================================
Cliente Evaluado  : CUST_CAOLIS_01
Valor del Pedido  : $-500.00 USD
--------------------------------------------------
--------------------------------------------------
[⚠️ ALERTA DE SISTEMA] 
Error Financiero: El importe ingresado (-500.00 USD) no es válido para análisis.
==================================================
```

### Escenario B: Cliente Aprobado (Riesgo Bajo y Saldo Disponible)
Tras corregir la lógica matemática, un cliente saludable (con 2 facturas vencidas) genera un scoring de 20/100 y autoriza la venta de forma exitosa:
```text
==================================================
     S/4HANA CREDIT RISK ENGINE - SIMULATION     
==================================================
Cliente Evaluado  : CUST_CAOLIS_01
Valor del Pedido  : \$3,500.00 USD
--------------------------------------------------
Puntaje de Riesgo: 20/100
Límite de Crédito: \$50,000.00 USD
--------------------------------------------------
[🟢 APROBADO] -> APROBADO: Evaluación de crédito exitosa
==================================================
```
