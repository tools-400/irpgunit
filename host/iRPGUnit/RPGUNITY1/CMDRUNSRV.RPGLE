      //
      // Prototypes for RUN.
      //

       // Runs a given test case procedure.
     D runTestProc     pr                  extproc('runTestProc')
     D                                     likeds(TestResult_t)
     D  testProc                           const likeds(Proc_t)
     D  setUp                              const likeds(Proc_t)
     D  tearDown                           const likeds(Proc_t)

