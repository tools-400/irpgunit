**FREE
// ==========================================================================
//  iRPGUnit Dev. of RDP Plugin. OK + Failure
//  ERROR. 5 test cases, 9 assertions, 3 failures, 1 error.
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
//   Test Procedures
//----------------------------------------------------------------------

dcl-proc testAllOK_4 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvt_v1 likeds(assertFailEvt_t) inz;
  dcl-ds assertFailEvt_v2 likeds(assertFailEvtLong_t) inz;

  assert(*on: 'OK: 1');
  assert(*on: 'OK: 2');

  aEqual('Hello' : 'Hello');

  // Keine Fehler aufgetreten => OK.
  assertFailEvt_v1 = getAssertFailEvt();
  aEqual(*blank : assertFailEvt_v1.msg);

  assertFailEvt_v2 = getAssertFailEvtLong();
  aEqual(*blank : assertFailEvt_v2.msg);

end-proc;

dcl-proc testRuntimeError export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s a1 int(10);
  dcl-s a2 int(10);

  // Produce a runtime error: division by zero
  a1 = a1 / a2;

end-proc;

dcl-proc testOK_1_Failure_2 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  callp(E) assert(*off : 'FAILURE: 1');  // continue on error

  assert(*on: 'OK: 1');
  assert(*off: 'FAILURE: 2');           // break on error

end-proc;


dcl-proc testFailInsideMonitorBlock export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  monitor;
    fail('Fail from inside a monitor block');
  on-error;
    fail('fail() must not be captured from the monitor block');
  endmon;

end-proc;


dcl-proc testNumFailure_noMessage export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s level int(10);

  procInError(level: 6);

  end-proc;

dcl-proc procInError export;
  dcl-pi *n extproc(*dclcase);
    level      int(10) value;
    maxLevel   int(10) value;
  end-pi;

  level += 1;
  if (level < maxLevel);
    procInError(level: maxLevel);
    return;
  endif;

  iEqual(1: 2); // Failure, no message

end-proc;

