      //
      // Prototypes for RPGUnit command line runner.
      //

       // Call a named procedure, logging any error with CMDLOG.
     D callWithLogging...
     D                 pr            10i 0
     D  proc                               const likeds(Proc_t)

       // The entry point of RUCALLTST. Parameters are provided by RUCALLTST command.
     D cmdRun          pr
     D  testSuiteName                      const likeds(Object_t)
     D  testProcs                          const likeds(ProcNms_t)
     D  order                              const like(order_t)
     D  detail                             const like(detail_t)
     D  output                             const like(output_t)
     D  libl                               const likeds(LibL_t)
     D  jobd                               const likeds(Object_t)
     D  rclRsc                             const like(rclrsc_t)

       // Returns a formatted test run completion message.
     D fmtCompMsg      pr           256a   varying
     D  testCaseCnt                  10i 0 const
     D  assertCnt                    10i 0 const
     D  failureCnt                   10i 0 const
     D  errorCnt                     10i 0 const

       // Return a user-friendly-formated qualified object name.
     D fmtObjNm        pr            21a   varying
     D  obj                                const likeds(Object_t)

       // Set up the test suite.
     D setupTestSuite  pr             1a
     D  testSuite                          const likeds(TestSuite_t)
     D  result                             likeds(result_t)

       // Tear down test suite.
     D tearDownTestSuite...
     D                 pr             1a
     D  testSuite                          const likeds(TestSuite_t)
     D  result                             likeds(result_t)

       // Run the test cases in a test suite.
     D runTests        pr
     D  result                                   likeds(result_t)
     D  testPgmNm                          const like(Object_t.nm)
     D  testSuite                          const likeds(TestSuite_t)
     D  testProcsToRun...
     D                                     const likeds(ProcNms_t)
     D  order                         8a   const
     D  detail                        6a   const
     D  rclRsc                       10a   const

       // Check and restore library list.
     D checkAndRestoreLibl...
     D                 pr
     D  mustRestoreLibl...
     D                                 n   const
     D  savedLibl                          const  likeds(LiblData_t)


     D result_t        DS                        qualified
     D  assertCnt                    10i 0
     D  errorCnt                     10i 0
     D  failureCnt                   10i 0
     D  runsCnt                      10i 0

