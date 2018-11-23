       //----------------------------------------------------------------------
       //   Procedure Prototypes
       //----------------------------------------------------------------------

     D clrAssertFailEvt...
     D                 pr                  extproc('clrAssertFailEvt')

     D getAssertCalled...
     D                 pr            10i 0 extproc('getAssertCalled')

     D getAssertFailEvt...
     D                 pr                  extproc('getAssertFailEvt')
     D                                     likeds(AssertFailEvt_t)

     D getAssertFailEvtLong...
     D                 pr                  extproc('getAssertFailEvtLong')
     D                                     likeds(AssertFailEvtLong_t)

     D clearAssertCounter...
     D                 pr                  extproc('clearAssertCounter')

     D setLowMessageKey...
     D                 pr                  extproc('setLowMessageKey')
     D  msgKey                        4a   const

