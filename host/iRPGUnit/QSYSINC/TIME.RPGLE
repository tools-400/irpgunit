      /IF NOT DEFINED(TIME)
      /DEFINE TIME

      // time -- Determine Current Time
      //    The time() function returns the current calendar time.
      //    The return value is also stored in the location that
      //    is given by timeptr.
     d time...
     d                 pr            10i 0 extproc('time')
     d  timeptr                        *   value

      /ENDIF
