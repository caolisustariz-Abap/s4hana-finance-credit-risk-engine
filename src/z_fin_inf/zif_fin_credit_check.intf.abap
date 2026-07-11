INTERFACE zif_fin_credit_check
  PUBLIC.

  TYPES: BEGIN OF ty_result,
           approved      TYPE abap_bool,
           risk_score    TYPE i,
           status_text   TYPE string,
           credit_limit  TYPE p LENGTH 8 DECIMALS 2,
         END OF ty_result.

  METHODS check_credit_limit
    IMPORTING
      iv_customer_id TYPE string
      iv_amount      TYPE p
    EXPORTING
      es_result      TYPE ty_result
    RAISING
      zcx_fin_invalid_amount. " <- esto para advertir al compilador

ENDINTERFACE.
