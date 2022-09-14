CLASS lcl_alv_grid DEFINITION INHERITING FROM cl_gui_alv_grid.

  PUBLIC SECTION.

    METHODS:
    constructor
      IMPORTING
        i_shellstyle     TYPE        i OPTIONAL
        i_lifetime       TYPE        i OPTIONAL
        i_parent         TYPE REF TO cl_gui_container
        i_appl_events    TYPE        char01 OPTIONAL
        i_parentdbg      TYPE REF TO cl_gui_container OPTIONAL
        i_applogparent   TYPE REF TO cl_gui_container OPTIONAL
        i_graphicsparent TYPE REF TO cl_gui_container OPTIONAL
        i_name           TYPE        string OPTIONAL
        i_fcat_complete  TYPE        sap_bool OPTIONAL,
     search.

  PRIVATE SECTION.

    TYPES:
        BEGIN OF l_type_s_search_criteria,
          new     TYPE sap_bool,
          value   TYPE lvc_value,
          order   TYPE char01,
          as_word TYPE char1,
          all     TYPE char1,
          info    TYPE lvc_string,
        END   OF l_type_s_search_criteria .
    TYPES:
      BEGIN OF l_type_s_search_position,
        row           TYPE i,
        column        TYPE i,
        index         TYPE i,
        start_offset  TYPE i,
        end_offset    TYPE i,
      END   OF l_type_s_search_position .
    TYPES:
      l_type_t_search_position TYPE SORTED TABLE OF l_type_s_search_position
           WITH UNIQUE KEY row column .
    TYPES:
      BEGIN OF l_type_s_search_package,
        start_index    TYPE i,
        end_index      TYPE i,
        t_data         TYPE lvc_t_data,
        position_index TYPE i,
        size           TYPE i,
        lines          TYPE i,
      END   OF l_type_s_search_package .
    TYPES:
      BEGIN OF l_type_s_search_result,
        t_result       TYPE l_type_t_search_position,
        position_index TYPE i,
      END   OF l_type_s_search_result .
    TYPES:
      BEGIN OF l_type_s_search_area,
        mtdata_lines TYPE i,
        columns      TYPE i,
        t_area       TYPE lvc_t_coll,
      END   OF l_type_s_search_area .
    TYPES:
      BEGIN OF l_type_s_back_front_map,  ">>>>>>>>>>Y6BK069609
             back  TYPE i,
             front TYPE i,
      END   OF l_type_s_back_front_map .
    TYPES:
      l_type_t_back_front_map TYPE STANDARD TABLE OF
          l_type_s_back_front_map WITH DEFAULT KEY .
    TYPES:
      BEGIN OF l_type_s_search,
        s_criteria   TYPE l_type_s_search_criteria,
        s_position   TYPE l_type_s_search_position,
        s_result     TYPE l_type_s_search_result,
        s_area       TYPE l_type_s_search_area,
        t_col_pos    TYPE l_type_t_back_front_map,
        s_package    TYPE l_type_s_search_package,
      END   OF l_type_s_search .

    DATA: mr_search TYPE REF TO cl_alv_lvc_search_dialog,
          ms_search TYPE l_type_s_search.

    METHODS:
      on_match_found FOR EVENT match_found OF cl_alv_lvc_search_dialog
                                IMPORTING e_modus
                                          et_search_entries
                                          e_number_of_hits
                                          e_current_hit.




ENDCLASS.                    "lcl_alv_grid DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_alv_grid IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_alv_grid IMPLEMENTATION.

  METHOD constructor.

    super->constructor(
      EXPORTING
        i_shellstyle     = i_shellstyle
        i_lifetime       = i_lifetime
        i_parent         = i_parent
        i_appl_events    = i_appl_events
        i_parentdbg      = i_parentdbg
        i_applogparent   = i_applogparent
        i_graphicsparent = i_graphicsparent
        i_name           = i_name
        i_fcat_complete  = i_fcat_complete

     ).

  ENDMETHOD.                    "constructor


  METHOD search.

    DATA: lt_fieldcat     TYPE lvc_t_fcat,
          lt_filter_index TYPE lvc_t_fidx,
          ls_cell         TYPE lvc_s_cell.


    me->get_current_cell(
      IMPORTING
        es_row_id = ls_cell-row_id
        es_col_id = ls_cell-col_id                "Backend COl_NAME
        ).

    cl_gui_cfw=>flush( ).

*... fill current cell
    DATA: ls_current_cell TYPE if_alv_lvc_search=>type_s_search_position.
    ls_current_cell-column_name = ls_cell-col_id-fieldname.
    ls_current_cell-row         = ls_cell-row_id-index.

    me->get_internal_fieldcat( IMPORTING et_fieldcatalog = lt_fieldcat ).

    IF mr_search IS NOT BOUND.
      CREATE OBJECT mr_search.
      SET HANDLER me->on_match_found FOR mr_search.
    ENDIF.

    CALL METHOD mr_search->execute
      EXPORTING
        no_dialog      = space
        acc_mode       = m_acc_mode
        modus          = if_alv_lvc_search=>c_modus_first
        it_fieldcat    = lt_fieldcat
        it_fidx        = lt_filter_index
        s_current_cell = ls_current_cell
      CHANGING
        cr_data        = mt_outtab.

  ENDMETHOD.                    "search

  METHOD on_match_found.

*... lvc variables
    DATA:
      ls_cell             TYPE lvc_s_cell,
      ls_col              TYPE lvc_s_col,
      ls_roid             TYPE lvc_s_roid,
      ls_row              TYPE lvc_s_row,
      ls_search_entries   TYPE if_alv_lvc_search=>type_s_search_position.

*...FIND MORE Button
    IF e_modus EQ if_alv_lvc_search=>c_modus_next.
      ms_search-s_criteria-new = abap_true.  "to keep Button FIND_MORE alive
    ELSEIF e_modus EQ if_alv_lvc_search=>c_modus_first.
      CLEAR ms_search.
    ENDIF.

    READ TABLE et_search_entries INTO ls_search_entries INDEX 1.
    IF sy-subrc EQ 0.
      ls_roid-row_id   = ls_search_entries-row.

*... backend coordinates
      ls_row-index     = ls_search_entries-row.
      ls_col-fieldname = ls_search_entries-column_name.
      me->set_current_cell_via_id(
                          is_row_id    = ls_row
                          is_column_id = ls_col
                          ).

      me->select_text_in_current_cell(
                                   from = ls_search_entries-start_offset
                                   to   = ls_search_entries-end_offset
                                 ).

      cl_gui_cfw=>flush( ).

    ENDIF.

  ENDMETHOD.                    "on_match_found

ENDCLASS.                    "lcl_alv_grid IMPLEMENTATION