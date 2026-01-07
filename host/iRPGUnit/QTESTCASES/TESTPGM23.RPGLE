**FREE
// ==========================================================================
//  iRPGUnit Fixture - Test XML Output Files.
//  ONFAILURE(*ABORT):
//  FAILURE. 3 test cases, 6 assertions, 2 failures, 0 error.
//  ONFAILURE(*CONTINUE):
//  ERROR. 3 test cases, 7 assertions, 2 failures, 1 error.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
//    >>PRE-COMPILER<<
//      >>CRTCMD<<  RUCRTRPG    TSTPGM(&LI/&OB) +
//                              SRCFILE(&SL/&SF) SRCMBR(&SM);
//      >>IMPORTANT<<
//        >>PARM<< COPTION(*SRCSTMT *EVENTF);
//        >>PARM<< DBGVIEW(*LIST);
//      >>END-IMPORTANT<<
//      >>EXECUTE<<
//    >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,TESTCASE
/include qinclude,ASSERT
/include qinclude,TEMPLATES

//----------------------------------------------------------------------
//   Test 'Failure' / 'Success'
//----------------------------------------------------------------------
dcl-proc testFailure export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // *JENKINS / *CONTINUE, test case #1
  assertEqual('Donald Duck': 'Dagobert Duck');

  // *JENKINS / *CONTINUE, test case #2
  // Executed only if ONFAILURE(*CONTINUE) is set
  aEqual('Duck' : 'Duck');

end-proc;

//----------------------------------------------------------------------
//   Test 'Error'
//   Produces a 'Failure' on line 66 if executed with ONFAILURE(*ABORT).
//   Produces a 'runtime error' on line 70 if executed with
//   ONFAILURE(*CONTINUE).
//----------------------------------------------------------------------
dcl-proc testRuntimeError export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // *JENKINS / *CONTINUE, test case #3
  assertEqual('Tick': 'Tick');

  // *JENKINS / *CONTINUE, test case #4
  assertEqual('Daisy Duck': 'Gustav Gans');

  // *JENKINS / *CONTINUE, test case #5
  // Error: CPD0084 - '*FOO      ' not valid for parameter OBJTYPE.
  runCmd('CHKOBJ OBJ(*LIBL/RUTESTCASE) OBJTYPE(*FOO)');

  // Must not be executed
  fail('Must never be reached.');

end-proc;

//----------------------------------------------------------------------
//   Test 'Success'
//   Produces a 'Success' if called with ONFAILURE(*ABORT), because we
//   can detect and ignore the monitored assertion on line 96.
//   Produces a 'Failure' if called with ONFAILURE(*CONTINUE), because
//   we cannot detect the monitored assertion and hence it counts.
//----------------------------------------------------------------------
dcl-proc testSuccess export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // *JENKINS / *CONTINUE, test case #6
  assertEqual('Trick': 'Trick');

  // *JENKINS / *CONTINUE, test case #7
  aEqual('Track' : 'Track');

  monitor;
    // *JENKINS / *CONTINUE, test case #8
    assert(*off: 'Expected a failed assertion.');
  on-error;
  endmon;

end-proc;

