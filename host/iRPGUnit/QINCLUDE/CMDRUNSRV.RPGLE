      // ==========================================================================
      //  iRPGUnit - Command Line Toolkit.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

       // Runs a given test case procedure.
     D runTestProc     pr                  extproc('CMDRUNSRV_runTestProc')
     D                                     likeds(TestResult_t)
     D  testProc                           const likeds(Proc_t)
     D  setUp                              const likeds(Proc_t)
     D  tearDown                           const likeds(Proc_t)

      // Load and activate a test suite.
     D loadTestSuite   pr                  extproc('CMDRUNSRV_loadTestSuite')
     D                                     likeds(TestSuite_t)
     D  srvPgm                             const likeds(Object_t)

      // Raise an RPGUnit error.
     D raiseRUError    pr                  extproc('CMDRUNSRV_raiseRUError')
     D  msg                         256a   const varying

      // Reclaim a test suite's allocated ressources.
     D rclTestSuite    pr                  extproc('CMDRUNSRV_rclTestSuite')
     D  testSuite                          likeds(TestSuite_t)

      // Run a test case in a test suite.
     D runTest         pr                  extproc('CMDRUNSRV_runTest')
     D                                     likeds(TestResult_t)
     D  testSuite                          const likeds(TestSuite_t)
     D  testIdx                      10i 0 const

      // Run a setup, teardown or test procedure. See prototype.
      // Constant TEMPLATES.TEST_CASE_EXECUTOR must match procedure name!
     D runProc         pr                  likeds(TestResult_t)
     D                                     extproc('CMDRUNSRV_runProc')
     D  proc                           *   const procptr
     D  result                             likeds(TestResult_t)

      // Run a test case. See prototype.
     D initTestResult  pr                  likeds(TestResult_t)
     D                                     extproc('CMDRUNSRV_initTestResult')
     D  testName                           const like(ProcNm_t)

