      //
      // Main prototypes for RURUNNER service program.
      // These prototypes are meant to be used by all test runners.
      //

      // Get a test case's name.
     D getTestNm       pr                  extproc('getTestNm')
     D                                     like(ProcNm_t)
     D  testSuite                          const likeds(TestSuite_t)
     D  testIdx                      10i 0 const

      // Load and activate a test suite.
     D loadTestSuite   pr                  extproc('loadTestSuite')
     D                                     likeds(TestSuite_t)
     D  srvPgm                             const likeds(Object_t)

      // Raise an RPGUnit error.
     D raiseRUError    pr                  extproc('raiseRUError')
     D  msg                         256a   const varying

      // Reclaim a test suite's allocated ressources.
     D rclTestSuite    pr                  extproc('rclTestSuite')
     D  testSuite                          likeds(TestSuite_t)

      // Run a test case in a test suite.
     D runTest         pr                  extproc('runTest')
     D                                     likeds(TestResult_t)
     D  testSuite                          const likeds(TestSuite_t)
     D  testIdx                      10i 0 const

      // Run a setup, teardown or test procedure. See prototype.
     D runProc         pr                  likeds(TestResult_t)
     D                                     extproc('runProc')
     D  proc                           *   const procptr
     D  result                             likeds(TestResult_t)

      // Run a test case. See prototype.
     D initTestResult  pr                  likeds(TestResult_t)
     D                                     extproc('initTestResult')
     D  testName                           const like(ProcNm_t)

