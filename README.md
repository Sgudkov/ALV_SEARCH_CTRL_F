# Ctrl+F to search data on ALV
## Usage purpose of hotkey Ctrl+F to search data in ALV for two ALV

- [x] Notice that you should choose ALV by clicking on it to define usage container before you going to use Ctrl+F 

1. Set function code for button "Search" like in figure below 

![alt text](https://github.com/Sgudkov/ALV_SEARCH_CTRL_F/blob/main/GUI_STATUS.jpg)


2. Use down below code snippet in user-command event(PAI). 

> All grids should be define like "TYPE REF lcl_alv_grid". 
> Source code [here](https://github.com/Sgudkov/ALV_SEARCH_CTRL_F/blob/main/Search.abap).

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