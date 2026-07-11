CLASS zcl_fin_customer_financials DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        iv_customer_id TYPE string
        iv_open_debts  TYPE p
        iv_overdue_inv TYPE i. " Cantidad de facturas vencidas

    METHODS get_open_debts  EXPORTING ev_debts TYPE p.
    METHODS get_overdue_inv EXPORTING ev_overdue TYPE i.

  PRIVATE SECTION.
    DATA customer_id TYPE string.
    DATA open_debts  TYPE p LENGTH 8 DECIMALS 2.
    DATA overdue_inv TYPE i.
ENDCLASS.

CLASS zcl_fin_customer_financials IMPLEMENTATION.
  METHOD constructor.
    me->customer_id = iv_customer_id.
    me->open_debts  = iv_open_debts.
    me->overdue_inv = iv_overdue_inv.
  ENDMETHOD.

  METHOD get_open_debts.
    ev_debts = me->open_debts.
  ENDMETHOD.

  METHOD get_overdue_inv.
    ev_overdue = me->overdue_inv.
  ENDMETHOD.
ENDCLASS.

