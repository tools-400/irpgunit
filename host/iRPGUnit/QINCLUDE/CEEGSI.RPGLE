      /if not defined(CEEGSI)
      /define CEEGSI

      // Get String Information (CEEGSI) API
     d CEEGSI...
     d                 pr
     d                                     extproc('CEEGSI')
     d  i_posn                       10i 0 const
     d  o_datatype                   10i 0
     d  o_curlen                     10i 0
     d  o_maxlen                     10i 0
     d  o_fb                         12a          options(*omit   )

      // Reference fields for CEEGSI API
     d strInf_t        ds                  qualified based(pDummy)
     d  datatype                     10i 0
     d  curlen                       10i 0
     d  maxlen                       10i 0
      /endif
