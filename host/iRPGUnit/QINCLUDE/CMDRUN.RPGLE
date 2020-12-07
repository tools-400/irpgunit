      /if not defined(CMDRUN)
      /define CMDRUN
      // ==========================================================================
      //  iRPGUnit - Command line runner.
      // ==========================================================================
      //  Copyright (c) 2013-2020 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

      /include qinclude,TEMPLATES

       // Call a named procedure, logging any error with CMDLOG.
     D callWithLogging...
     D                 pr            10i 0 extproc('CMDRUN_callWithLogging')
     D  proc                               const likeds(Proc_t)

       // The entry point of RUCALLTST. Parameters are provided by RUCALLTST command.
     D cmdRun          pr                  extpgm('CMDRUN')
     D  testSuiteName                      const likeds(Object_t)
     D  testProcs                          const likeds(ProcNms_t)
     D  order                              const like(order_t)
     D  detail                             const like(detail_t)
     D  output                             const like(output_t)
     D  libl                               const likeds(LibL_t)
     D  jobd                               const likeds(Object_t)
     D  rclRsc                             const like(rclrsc_t)
     D  xmlStmf                            const like(stmf_t)

       // Returns a formatted test run completion message.
     D fmtCompMsg      pr           256a   varying extproc('CMDRUN_fmtCompMsg')
     D  testCaseCnt                  10i 0 const
     D  assertCnt                    10i 0 const
     D  failureCnt                   10i 0 const
     D  errorCnt                     10i 0 const

       // Return a user-friendly-formated qualified object name.
     D fmtObjNm        pr            21a   varying extproc('CMDRUN_fmtObjNm')
     D  obj                                const likeds(Object_t)

       // Set up the test suite.
     D setupTestSuite  pr             1a   extproc('CMDRUN_setupTestSuite')
     D  testSuite                          const likeds(TestSuite_t)
     D  result                             likeds(result_t)

       // Tear down test suite.
     D tearDownTestSuite...
     D                 pr             1a   extproc('CMDRUN_tearDownTestSuite')
     D  testSuite                          const likeds(TestSuite_t)
     D  result                             likeds(result_t)

       // Run the test cases in a test suite.
     D runTests        pr                  extproc('CMDRUN_runTests')
     D  result                                   likeds(result_t)
     D  testSuite                          const likeds(TestSuite_t)
     D  testProcsToRun...
     D                                     const likeds(ProcNms_t)
     D  order                         8a   const
     D  detail                        6a   const
     D  rclRsc                       10a   const

       // Check and restore library list.
     D checkAndRestoreLibl...
     D                 pr                  extproc('CMDRUN_checkAndRestoreLibl')
     D  mustRestoreLibl...
     D                                 n   const
     D  savedLibl                          const  likeds(LiblData_t)


     D result_t        DS                        qualified
     D  assertCnt                    10i 0
     D  errorCnt                     10i 0
     D  failureCnt                   10i 0
     D  runsCnt                      10i 0

      /endif
