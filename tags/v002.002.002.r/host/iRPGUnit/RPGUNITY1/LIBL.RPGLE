      /if defined(libl)
      /eof
      /endif
      /define libl
      //----------------------------------------------------------------------
      //   Exported Procedure Prototypes
      //----------------------------------------------------------------------

       // Retrieves the library list.
     D getLibl         pr                  likeds(LiblData_t   )
     D                                     extproc('getLibl')

       // Load library list (from job description)
     D loadLibl        pr                  likeds(LiblData_t   )
     D                                     extproc('loadLibl')
     D  qJobD                              const  likeds(Object_t  )

       // Restore library list.
     D restoreLibl     pr
     D                                     extproc('restoreLibl')
     D  liblData                           const  likeds(LiblData_t)

       // Change library list.
     D changeLibl      pr
     D                                     extproc('changeLibl')
     D  curLib                       10a   const
     D  libL                               const  likeds(LibL_t)

       // Change library list according to what the user requested.
     D setTestSuiteLibl...
     D                 pr              n
     D                                     extproc('setTestSuiteLibl')
     D  libl                               value likeds(LibL_t)
     D  jobd                               value likeds(Object_t)
     D  testSuiteLib                 10a   Value

      /COPY RPGUNITY1,TEMPLATES

