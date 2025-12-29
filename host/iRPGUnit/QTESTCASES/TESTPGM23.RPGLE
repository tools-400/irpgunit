**FREE
// ==========================================================================
//  iRPGUnit Fixture - Test XML Output Files.
//  ERROR. 3 test cases, 3 assertions, 1 failure, 1 error.
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
//   Test 'Success'
//----------------------------------------------------------------------

dcl-proc testSuccess export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual('Donald': 'Donald');

  aEqual('Duck' : 'Duck');

end-proc;

//----------------------------------------------------------------------
//   Test 'Failure' / 'Success'
//----------------------------------------------------------------------
dcl-proc testFailure export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual('Donald': 'Dagobert');

  // Executed only if ONFAILURE(*CONTINUE) is set
  aEqual('Duck' : 'Duck');

end-proc;

//----------------------------------------------------------------------
//   Test 'Error'
//----------------------------------------------------------------------
dcl-proc testRuntimeError export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  assertEqual('Dagobert': 'Dagobert');

  // Error: CPD0084 - '*FOO      ' not valid for parameter OBJTYPE.
  runCmd('CHKOBJ OBJ(*LIBL/RUTESTCASE) OBJTYPE(*FOO)');

  // Must not be executed
  fail('Must never be reached.');

end-proc;

