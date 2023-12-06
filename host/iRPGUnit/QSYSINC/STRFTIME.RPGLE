      /IF NOT DEFINED(STRFTIME)
      /DEFINE STRFTIME

      /include qsysinc,localtime

      // strftime -- Convert to Formatted Time
      //    strftime() returns the number of bytes placed into the
      //    array pointed to by 'dest'.
     d strftime...
     d                 pr            10i 0 extproc('strftime')
     d  dest                           *   value
     d  maxsize                      10i 0 value
     d  format                         *   value options(*string)
     d  timeptr                            const  likeds(tm_t)

      /ENDIF
