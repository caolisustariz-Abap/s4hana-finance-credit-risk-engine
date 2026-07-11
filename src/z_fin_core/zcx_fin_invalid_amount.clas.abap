CLASS zcx_fin_invalid_amount DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    " Atributo público para almacenar el mensaje personalizado
    DATA mv_error_message TYPE string.

    METHODS constructor
      IMPORTING
        textid            LIKE textid OPTIONAL
        previous          LIKE previous OPTIONAL
        iv_custom_message TYPE string OPTIONAL.
ENDCLASS.


CLASS zcx_fin_invalid_amount IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        textid   = textid
        previous = previous.

    me->mv_error_message = iv_custom_message.
  ENDMETHOD.
ENDCLASS.

