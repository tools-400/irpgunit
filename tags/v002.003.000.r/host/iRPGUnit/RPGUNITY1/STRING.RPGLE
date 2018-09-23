      //----------------------------------------------------------------------
      //   Exported Procedure Prototypes
      //----------------------------------------------------------------------

     D uCase           pr                        like(String_t)
     D                                     extproc('uCase')
     D  string                             const like(String_t)
     D                                           options(*varsize)

     D startsWith...
     D                 pr              N
     D                                     extproc('startsWith')
     D  prefix                             const like(String_t)
     D                                           options(*varsize)
     D  string                             const like(String_t)
     D                                           options(*varsize)

     D endsWith...
     D                 pr              N
     D                                     extproc('endsWith')
     D  prefix                             const like(String_t)
     D                                           options(*varsize)
     D  string                             const like(String_t)
     D                                           options(*varsize)

     D isQuoted...
     D                 pr              n
     D                                     extproc('isQuoted')
     D  string                             const like(String_t)
     D                                           options(*varsize)

     D addQuotes...
     D                 pr                        like(String_t)
     D                                     extproc('addQuotes')
     D  string                             const like(String_t)
     D                                           options(*varsize)

     D removeQuotes...
     D                 pr                        like(String_t)
     D                                     extproc('removeQuotes')
     D  string                             const like(String_t)
     D                                           options(*varsize)

     D spaces...
     D                 pr                        like(String_t)
     D                                     extproc('spaces')
     D  length                       10i 0 value
     D  char                          1a   value options(*nopass)

