      //
      // Prototype for EXTTST.
      //

     D activateTestSuite...
     D                 pr                  extproc('activateTestSuite')
     D  testSuite                          likeds(TestSuite_t)
     D  actMark                            const like(ActMark_t)

     D getTestProc     pr                  likeds(Proc_t)
     D                                     extproc('getTestProc')
     D  testSuite                          const likeds(TestSuite_t)
     D  testIdx                      10i 0 const

     D getTestSuite    pr                  likeds(TestSuite_t)
     D                                     extproc('getTestSuite')
     D  procNmList                         const likeds(ProcNmList_t)

