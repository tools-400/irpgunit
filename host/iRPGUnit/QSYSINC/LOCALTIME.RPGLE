      /IF NOT DEFINED(LOCALTIME)
      /DEFINE LOCALTIME

      // localtime() -- Correct Local Time, returns tm_t*
      //    The localtime() function converts a time value, in
      //    seconds, to a structure of type tm.
     d localtime...
     d                 pr              *   extproc('localtime')
     d  time                         10i 0 const

      // localtime_r() -- Correct Local Time
      //    It is the same as localtime() except that it passes
      //    in the place to store the returned structure result.
     d localtime_r...
     d                 pr              *   extproc('localtime_r')
     d  time                         10i 0 const
     d  tm                                 const  likeds(tm_t)

     d tm_t            ds                  qualified  template
     d  tm_sec                       10i 0
     d  tm_min                       10i 0
     d  tm_hour                      10i 0
     d  tm_mday                      10i 0
     d  tm_mon                       10i 0
     d  tm_year                      10i 0
     d  tm_wday                      10i 0
     d  tm_yday                      10i 0
     d  tm_isdst                     10i 0

      /ENDIF
