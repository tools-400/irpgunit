**FREE
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
dcl-pr callWithLogging int(10) extproc('CMDRUN_callWithLogging');
  proc            likeds(proc_t) const;
end-pr;

// The entry point of RUCALLTST. Parameters are provided by RUCALLTST command.
dcl-pr cmdrun extpgm('RUCALLTST');
  testsuitename   likeds(object_t) const;
  testprocs       likeds(procNms_t) const;
  order           like(order_t) const;
  detail          like(detail_t) const;
  output          like(output_t) const;
  libl            likeds(libl_t) const;
  jobD            likeds(object_t) const;
  rclrsc          like(rclrsc_t) const;
  xmlstmf         like(stmf_t) const;
end-pr;

// Returns a formatted test run completion message.
dcl-pr fmtCompMsg varchar(256) extproc('CMDRUN_fmtCompMsg');
  testcasecnt     int(10) const;
  assertCnt       int(10) const;
  failureCnt      int(10) const;
  errorCnt        int(10) const;
end-pr;

// Return a user-friendly-formated qualified object name.
dcl-pr fmtObjNm varchar(21) extproc('CMDRUN_fmtObjNm');
  obj             const likeds(object_t);
end-pr;

// Set up the test suite.
dcl-pr setupTestSuite char(1) extproc('CMDRUN_setupTestSuite');
  testSuite       likeds(testSuite_t) const;
  result          likeds(result_t);
end-pr;

// Tear down test suite.
dcl-pr tearDownTestSuite char(1) extproc('CMDRUN_tearDownTestSuite');
  testSuite       likeds(testSuite_t) const;
  result          likeds(result_t);
end-pr;

// Run the test cases in a test suite.
dcl-pr runTests extproc('CMDRUN_runTests');
  result          likeds(result_t);
  testSuite       likeds(testSuite_t) const;
  testProcsToRun  likeds(procNms_t) const;
  order           char(8) const;
  detail          char(6) const;
  rclRsc          char(10) const;
end-pr;

// Check and restore library list.
dcl-pr checkAndRestoreLibl extproc('CMDRUN_checkAndRestoreLibl');
  mustRestoreLibl ind const;
  savedLibl       likeds(liblData_t) const;
end-pr;


dcl-ds result_t qualified;
  assertCnt       int(10);
  errorCnt        int(10);
  failureCnt      int(10);
  runsCnt         int(10);
end-ds;

/endif
