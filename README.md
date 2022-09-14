# Ctrl+F to search data on ALV
## Usage purpose of hotkey Ctrl+F to search data in ALV


### Usage purpose for two ALV bootom and top.


1. Set function code for button "Search" like in figure below 
![alt text](https://github.com/Sgudkov/ALV_SEARCH_CTRL_F/blob/main/GUI_STATUS.jpg)


2. Use down below code snippet in user-command event(PAI). 

```abap  
      CALL METHOD cl_gui_control=>get_focus
        IMPORTING
          control           = lo_control
        EXCEPTIONS
          cntl_error        = 1
          cntl_system_error = 2
          OTHERS            = 3.
      CHECK sy-subrc = 0.

      IF lo_control IS BOUND.
        CASE lo_control->parent.
          WHEN go_grid_top.
            IF go_grid_top IS BOUND.
              go_grid_top->search( ).
            ENDIF.
          WHEN go_grid_bot.
            IF go_grid_bot IS BOUND.
              go_grid_bot->search( ).
            ENDIF.
        ENDCASE.
        RETURN.
      ENDIF.
```  