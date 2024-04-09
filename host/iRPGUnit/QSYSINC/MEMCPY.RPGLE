      /IF NOT DEFINED(MEMCPY)
      /DEFINE MEMCPY

      // memcpy() -- Copy Bytes
      //    The behavior is undefined if copying takes place
      //    between objects that overlap.
      //    The memcpy() function returns a pointer to dest.
     d memcpy...
     d                 pr              *   extproc('memcpy')
     d  i_pDest                        *   value options(*string)
     d  i_pSrc                         *   value options(*string)
     d  i_count                      10u 0 value

      /ENDIF
