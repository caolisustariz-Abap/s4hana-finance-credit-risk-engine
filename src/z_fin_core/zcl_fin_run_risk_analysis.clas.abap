CLASS zcl_fin_run_risk_analysis DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    " Interfaz obligatoria para ejecutar código directamente en la consola de Eclipse
    INTERFACES if_oo_adt_classrun .

ENDCLASS.



CLASS zcl_fin_run_risk_analysis IMPLEMENTATION.

   METHOD if_oo_adt_classrun~main.

    DATA lo_credit_engine TYPE REF TO zif_fin_credit_check.
    DATA(lv_customer)     = |CUST_CAOLIS_01|.

    " IMPORTANTE: Ponemos un valor negativo a propósito para forzar el disparo del TRY-CATCH
    DATA lv_order_value   TYPE p LENGTH 8 DECIMALS 2 VALUE 3500.

    lo_credit_engine = NEW zcl_fin_credit_engine( ).

    out->write( '==================================================' ).
    out->write( '     S/4HANA CREDIT RISK ENGINE - SIMULATION     ' ).
    out->write( '==================================================' ).
    out->write( |Cliente Evaluado  : { lv_customer }| ).
    out->write( |Valor del Pedido  : ${ lv_order_value } USD| ).
    out->write( '--------------------------------------------------' ).

    " Iniciamos el bloque seguro
    TRY.
        lo_credit_engine->check_credit_limit(
          EXPORTING
            iv_customer_id = lv_customer
            iv_amount      = lv_order_value
          IMPORTING
            es_result      = DATA(ls_analysis_result)
        ).

        " Si el código llega aquí, significa que NO hubo error
        out->write( |Puntaje de Riesgo: { ls_analysis_result-risk_score }/100| ).
        out->write( |Límite de Crédito: ${ ls_analysis_result-credit_limit } USD| ).
        out->write( '--------------------------------------------------' ).

        IF ls_analysis_result-approved = abap_true.
          out->write( |[🟢 APROBADO] -> { ls_analysis_result-status_text }| ).
        ELSE.
          out->write( |[🔴 BLOQUEADO] -> { ls_analysis_result-status_text }| ).
        ENDIF.

      " Si ocurre nuestra excepción, el programa salta automáticamente aquí
      CATCH zcx_fin_invalid_amount INTO DATA(lx_financial_error).
        out->write( '--------------------------------------------------' ).
        out->write( |[⚠️ ALERTA DE SISTEMA] | ).
        out->write( lx_financial_error->mv_error_message ). " Imprime el mensaje personalizado

    ENDTRY.

    out->write( '==================================================' ).

  ENDMETHOD.
ENDCLASS.
