**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test JOBLOG.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,TESTUTILS
/copy qinclude,TYPES_H

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

dcl-s testStartTime timestamp;
dcl-s assertCntBefore int(10);
dcl-s assertCntAfter int(10);

//----------------------------------------------------------------------
//   Tests
//----------------------------------------------------------------------

dcl-proc setUp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  testStartTime = getFullTimeStamp();
  clear assertCntBefore;
  clear assertCntAfter;

end-proc;


dcl-proc testNoMsgInJobLog export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds assertFailEvt likeds(AssertFailEvt_t);

  // Setup.

  assertCntBefore = getAssertCalled();

  // Run.

  monitor;
    assertJobLogContains('MCH1211': testStartTime);
    fail('assertJobLogContains(...) should have raised a failure.');
  on-error;
    // Exception message, as expected.
    assertFailEvt = getAssertFailEvt();
    assertCntAfter = getAssertCalled();
  endmon;

  // Check.

  iEqual(assertCntBefore + 1: assertCntAfter);
  aEqual('Message MCH1211 not found in the job log.': assertFailEvt.msg);

end-proc;


dcl-proc testMsgInJobLog export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Setup.

  sndMCH1211Msg();
  assertCntBefore = getAssertCalled();

  // Run.

  assertJobLogContains('MCH1211': testStartTime);

  // Check.

  assertCntAfter = getAssertCalled();
  iEqual(assertCntBefore + 1: assertCntAfter);

end-proc;


//----------------------------------------------------------------------
//   Private Helper Procedures
//----------------------------------------------------------------------

dcl-proc sndMCH1211Msg;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s zero int(10) inz(0);
  dcl-s x int(10) inz(1);


  monitor;
    x = 1 / zero;
  on-error;
  endmon;

end-proc;
