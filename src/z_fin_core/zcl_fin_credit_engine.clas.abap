CLASS zcl_fin_credit_engine DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

" Implementamos la interfaz para cumplir con el contrato de diseño
    INTERFACES zif_fin_credit_check .

"   Constantes estaticas para las reglas del negocio globales
    CLASS-DATA: cv_max_overdue_invoices TYPE i VALUE 3,
                cv_maxbase_credit_limit TYPE p LENGTH 8 DECIMALS 2 value '50000.00'.


  PRIVATE SECTION.
  "     Metodo privado encapsulado: el mundo entero no necesita saber como calculamos el scoring
  METHODS calculate_risk_score
    IMPORTING
        io_customer TYPE REF TO zcl_fin_customer_financials
    EXPORTING
        ev_score TYPE i.
ENDCLASS.



CLASS zcl_fin_credit_engine IMPLEMENTATION.
  METHOD zif_fin_credit_check~check_credit_limit.
    " --- NUEVA VALIDACIÓN DE EXCEPCIÓN ---
    IF iv_amount <= 0.
      RAISE EXCEPTION NEW zcx_fin_invalid_amount(
          iv_custom_message = |Error Financiero: El importe ingresado (${ iv_amount } USD) no es válido para análisis.| ).
    ENDIF.
    " -------------------------------------

    " 1. Simulamos la búsqueda del cliente (El resto del código se queda igual...)



    " 1. Simulamos la busqueda del cliente( en un caso real buscariamos aqui en una tabla de la bd
    " Creamos un cliente de prueba que debe 10,000 USD y tiene 4 facturas vencidas
    DATA(io_customer) = NEW zcl_fin_customer_financials( iv_customer_id = iv_customer_id
                                                         iv_open_debts  = '10000.00'
                                                         iv_overdue_inv = 2 ).

    " 2. Inicializamos los valores por defecto del resultado utilizando la estructura de la interfaz
    es_result-credit_limit = me->cv_maxbase_credit_limit.

    " 3. Llamamos al metodo privado para evaluar el riesgo
    calculate_risk_score( EXPORTING io_customer = io_customer
                          IMPORTING ev_score    = es_result-risk_score ).

    " 4. Obtenemos las deudas actuales del cliente para la validacion matematica
    io_customer->get_open_debts( IMPORTING ev_debts = DATA(lv_current_debts) ).

    " 5. Regla del negocio: Validar si la nueva compra excede el limite disponible
    DATA(lv_total_exposure) = lv_current_debts + iv_amount.

    IF es_result-risk_score > 70.
      es_result-approved    = abap_false.
      es_result-status_text = 'BLOQUEADO: Riesgo financiero crítico (Demasiadas facturas impagadas)'.
    ELSEIF lv_total_exposure > es_result-credit_limit.
      es_result-approved    = abap_false.
      es_result-status_text = |BLOQUEADO: Excede límite de crédito. Disponible: { es_result-credit_limit - lv_current_debts }|.
    ELSE.
      es_result-approved    = abap_true.
      es_result-status_text = 'APROBADO: Evaluación de crédito exitosa'.
    ENDIF.
  ENDMETHOD.

  METHOD calculate_risk_score.
    " Lógica interna para determinar el puntaje del 1 al 100
    io_customer->get_overdue_inv( IMPORTING ev_overdue = DATA(lv_overdue) ).

    " Si supera las facturas máximas permitidas por la constante estática, el riesgo sube a 80
    IF lv_overdue > cv_max_overdue_invoices.
      ev_score = 80.
    ELSE.
      ev_score = 20. " Cliente saludable
    ENDIF.
  ENDMETHOD.

ENDCLASS.
