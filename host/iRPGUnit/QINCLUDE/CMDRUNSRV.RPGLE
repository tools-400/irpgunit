**FREE
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
dcl-pr runTestProc extproc('CMDRUNSRV_runTestProc') likeds(testResult_t);
  testproc        likeds(proc_t) const;
  setup           likeds(proc_t) const;
  teardown        likeds(proc_t) const;
end-pr;

// Load and activate a test suite.
dcl-pr loadTestSuite extproc('CMDRUNSRV_loadTestSuite') likeds(testSuite_t);
  srvPgm          likeds(object_t) const;
end-pr;

// Raise an RPGUnit error.
dcl-pr raiseRUError extproc('CMDRUNSRV_raiseRUError');
  msg             varchar(256) const;
end-pr;

// Reclaim a test suite's allocated ressources.
dcl-pr rclTestSuite extproc('CMDRUNSRV_rclTestSuite');
  testSuite       likeds(testSuite_t);
end-pr;

// Run a test case in a test suite.
dcl-pr runTest extproc('CMDRUNSRV_runTest') likeds(testResult_t);
  testSuite       likeds(testSuite_t) const;
  testIdx         int(10) const;
end-pr;

// Run a setup, teardown or test procedure. See prototype.
// Constant TEMPLATES.TEST_CASE_EXECUTOR must match procedure name!
dcl-pr runProc likeds(testResult_t) extproc('CMDRUNSRV_runProc');
  proc            pointer(*proc) const;
  result          likeds(testResult_t);
end-pr;

// Run a test case. See prototype.
dcl-pr initTestResult likeds(testResult_t) extproc('CMDRUNSRV_initTestResult');
  testName        like(procNm_t) const;
end-pr;

