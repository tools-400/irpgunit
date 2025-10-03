**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test CMDRUNLOG.
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
//     >>PARM<<  MODULE(&LI/CMDRUNLOG +
//                      &LI/CMDRUNPRT +
//                      &LI/JOBLOG    +
//                      &LI/LIBL      +
//                      &LI/OSVERSION +
//                      &LI/PGMMSG    +
//                      &LI/STRING    +
//                      );
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//     >>PARM<<  BOPTION(*DUPPROC);
//   >>END-IMPORTANT<<
//   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNLOG) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/CMDRUNPRT) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/JOBLOG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/LIBL     ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/OSVERSION) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/STRING   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,CMDRUNLOG
/copy qinclude,LIBL
/copy qinclude,TEMPLATES
/copy qinclude,STRING

// CMDRUNPRTY is imported to mock module CMDRUNPRT. That way, we can
// test what would have been printed in the spool file, without
// involving the spool file API.
/copy qinclude,CMDRUNPRT

//----------------------------------------------------------------------
//   Constants
//----------------------------------------------------------------------

// Left margin of the log. Must match CMDRUNLOG.LEFT_MARGIN.
dcl-c MARGIN '     ';

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

// The mock log lines and state.
dcl-s logIdx          int(10);
dcl-s logLine         char(80) Dim(100);
dcl-s logWasOpened    ind;
dcl-s logWasClosed    ind;
// The (dummy) service program containing the tests.
dcl-ds testSrvPgm likeds(Object_t);
// The (dummy) test case name.
dcl-s testNm          like(ProcNm_t);

//----------------------------------------------------------------------
//   Test Definitions
//----------------------------------------------------------------------

dcl-proc setUp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  clear logIdx;
  clear logLine;
  clear logWasOpened;
  clear logWasClosed;
  clear testSrvPgm;
  clear testNm;

  testSrvPgm.nm = 'MY_SRVPGM';
  setLogContext(testSrvPgm: DETAIL_ALL: OUTPUT_ALLWAYS);

end-proc;


dcl-proc tearDown export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  logCompMsg(*blank: 0: 0);    // Close log in all cases.

end-proc;


dcl-proc testLogSuccessWith1Assertion export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c oneAssertion const(1);
  dcl-s r int(10);

  // Setup.

  testNm = 'successful_test_with_one_assertion';

  // Execution.

  logSuccess(testNm: oneAssertion);

  // Controls.

  assert(logWasOpened : 'Log was not opened');
  aEqual(MARGIN + '*** Tests of MY_SRVPGM ***         ': logLine(1));

  r = findRow('successful_test');
  assert(r > 0: 'Row starting with ''successful_test'' not found');

  aEqual(MARGIN + 'successful_test_with_one_asser     ': logLine(r));
  aEqual(MARGIN + 'tion - Success                     ': logLine(r+1));
  aEqual(MARGIN + '  1 assertions                     ': logLine(r+2));
  aEqual(MARGIN + '-----------------------            ': logLine(r+3));
  iEqual(r+4: logIdx);

end-proc;


dcl-proc testLogSuccessWith2Assertions export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c twoAssertions const(2);
  dcl-s r int(10);

  // Setup.

  testNm = 'successful_test_with_two_assertions';

  // Execution.

  logSuccess(testNm: twoAssertions);

  // Controls.

  aEqual(MARGIN + '*** Tests of MY_SRVPGM ***        ': logLine(1));

  r = findRow('successful_test');
  assert(r > 0: 'Row starting with ''successful_test'' not found');

  aEqual(MARGIN + 'successful_test_with_two_asser    ': logLine(r ));
  aEqual(MARGIN + 'tions - Success                   ': logLine(r+1));
  aEqual(MARGIN + '  2 assertions                    ': logLine(r+2));
  aEqual(MARGIN + '-----------------------           ': logLine(r+3));
  iEqual(r+4: logIdx);

end-proc;


dcl-proc testLog2Successes export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s testNm2 like(TestNm);
  dcl-s r int(10);

  // Setup.

  testNm  = 'successful_test_1';
  testNm2 = 'successful_test_2';

  // Execution.

  logSuccess(testNm: 0);
  logSuccess(testNm2: 0);

  // Controls.

  aEqual(MARGIN + '*** Tests of MY_SRVPGM ***    ': logLine(1));

  r = findRow('successful_test');
  assert(r > 0: 'Row starting with ''successful_test'' not found');

  aEqual(MARGIN + 'successful_test_1 - Success   ': logLine(r ) );
  aEqual(MARGIN + '  0 assertions                ': logLine(r+1));
  aEqual(MARGIN + '-----------------------       ': logLine(r+2));
  aEqual(MARGIN + ''                               : logLine(r+3));
  aEqual(MARGIN + 'successful_test_2 - Success   ': logLine(r+4));
  aEqual(MARGIN + '  0 assertions                ': logLine(r+5));
  aEqual(MARGIN + '-----------------------       ': logLine(r+6));
  iEqual(r+7: logIdx);

end-proc;


dcl-proc testLogFailureWithoutSpecNb export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds failure likeds(AssertFailEvtLong_t) inz;
  dcl-s r int(10);

  // Setup.

  testNm = 'failure_without_spec_nb';
  failure.callStk.numE = 1;
  failure.callStk.Entry(1).qStmt.qPgm.nm = 'MY_SRVPGM';
  failure.callStk.Entry(1).qStmt.qMod.nm = 'MY_SRVPGM';
  failure.callStk.Entry(1).qStmt.procNm = testNm;
  failure.callStk.Entry(1).qStmt.specNb = *blank;

  // Execution.

  logFailure(testNm: failure);

  // Controls.

  assert(logWasOpened: 'Log was not opened' );
  aEqual(MARGIN + '*** Tests of MY_SRVPGM ***        ': logLine(1));

  r = findRow('failure_without');
  assert(r > 0: 'Row starting with ''failure_without'' not found');

  aEqual(MARGIN + 'failure_without_spec_nb - FAIL    ': logLine(r ));
  aEqual(MARGIN + 'URE                               ': logLine(r+1));
  aEqual(MARGIN + '                                  ': logLine(r+2)); // new with *TYPE2 log output
  aEqual(MARGIN + '  failure_without_spec_nb (MY_    ': logLine(r+3));
  aEqual(MARGIN + 'SRVPGM->MY_SRVPGM:*N)             ': logLine(r+4));
  aEqual(MARGIN + '                                  ': logLine(r+5)); // new with *TYPE2 log output
  aEqual(MARGIN + 'Expected:          Not availab    ': logLine(r+6));
  aEqual(MARGIN + 'le                                ': logLine(r+7));
  aEqual(MARGIN + 'Actual:            Not availab    ': logLine(r+8));
  aEqual(MARGIN + 'le                                ': logLine(r+9));
  aEqual(MARGIN + '-----------------------           ': logLine(r+10));
  aEqual(MARGIN + '                                  ': logLine(r+11));
  iEqual(r+11: logIdx);

end-proc;


dcl-proc testLogErrorWithoutMsgId export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds excpMsgInfo likeds(Msg_t);
  dcl-s r int(10);

  // Setup.

  testNm = 'error_with_missing_msg_id';
  excpMsgInfo.Id = *blank;
  excpMsgInfo.txt = 'Error message.';
  excpMsgInfo.qSndStmt.qPgm.nm = 'ERRORPGM';
  excpMsgInfo.qSndStmt.procNm = 'error_proc';
  excpMsgInfo.qSndStmt.specNb = '1000';

  // Execution.

  logError(testNm: excpMsgInfo);

  // Controls.

  assert(logWasOpened : 'Log was not opened');
  aEqual(MARGIN + '*** Tests of MY_SRVPGM ***        ': logLine(1));

  r = findRow('error_with');
  assert(r > 0: 'Row starting with ''error_with'' not found');

  aEqual(MARGIN + 'error_with_missing_msg_id - ERROR ': logLine(r));
  aEqual(MARGIN + 'Error message.                    ': logLine(r+1));
  aEqual(MARGIN + '  error_proc (ERRORPGM->:1000)    ': logLine(r+2));
  aEqual(MARGIN + '-----------------------           ': logLine(r+3));
  iEqual(r+4: logIdx);

end-proc;


dcl-proc testLogErrorWithoutExcpInfoOrigin export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds excpMsgInfo likeds(Msg_t);
  dcl-s r int(10);

  // Setup.

  testNm = 'error_without_origin_info';
  excpMsgInfo.Id = 'CPF1234';
  excpMsgInfo.txt = 'Error message.';
  excpMsgInfo.qSndStmt.qPgm.nm = *blank;
  excpMsgInfo.qSndStmt.procNm = *blank;
  excpMsgInfo.qSndStmt.specNb = *blank;

  // Execution.

  logError(testNm: excpMsgInfo);

  // Controls.

  aEqual(MARGIN + '*** Tests of MY_SRVPGM ***        ': logLine(1));

  r = findRow('error_without');
  assert(r > 0: 'Row starting with ''error_without'' not found');

  aEqual(MARGIN + 'error_without_origin_info - ERROR ': logLine(r));
  aEqual(MARGIN + 'CPF1234 - Error message.          ': logLine(r+1));
  aEqual(MARGIN + '-----------------------           ': logLine(r+2));
  iEqual(r+3: logIdx);

end-proc;


dcl-proc testLogCompMsg export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s r int(10);

  // Execution.

  logCompMsg('Completion message': 0: 0);

  // Controls.

  assert(logWasOpened: 'Log was not opened');
  aEqual(MARGIN + '*** Tests of MY_SRVPGM ***        ': logLine(1));

  r = findRow('Library list:');
  assert(r > 0: 'Row starting with ''Library list:'' not found');

  aEqual(MARGIN + 'Completion message                ': logLine(r+2));
  assert(r+2 = logIdx
  : 'Line with ''Completion message'' must be the last one');
  assert(logWasClosed: 'Log was not closed');

end-proc;


dcl-proc testLogRawLine export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Execution.

  logRawLine('A short text');

  // Controls.

  aEqual(MARGIN + 'A short text                      ': logLine(1));
  iEqual(1: logIdx);

end-proc;


dcl-proc testLogRawLineWithWrapping export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s longText char(256);


  // Setup.

  //          111111111122222222223333333333444444444455
  // 123456789012345678901234567890123456789012345678901
  longText = 'A very very very very very very very very long text';

  // Execution.

  logRawLine( longText );

  // Controls.

  //          1111111111222222222233333333334
  // 1234567890123456789012345678901234567890
  aEqual(MARGIN + 'A very very very very very ver': logLine(1));
  aEqual(MARGIN + 'y very very long text': logLine(2));
  iEqual(2: logIdx);

end-proc;


//----------------------------------------------------------------------
//   Support Procedures
//----------------------------------------------------------------------

// Procedure to mock module CMDRUNPRT.
dcl-proc clsPrt export;
  dcl-pi *n;
  end-pi;

  logWasClosed = *on;

end-proc;


// Procedure to mock module CMDRUNPRT.
dcl-proc getPrtWidth export;
  dcl-pi *n int(10);
  end-pi;

  return 40;

end-proc;


// Procedure to mock module CMDRUNPRT.
dcl-proc opnPrt export;
  dcl-pi *n;
    testPgmNm   const like(Object_t.nm);
  end-pi;

  logWasOpened = *on;
  aEqual('MY_SRVPGM': testPgmNm);

end-proc;


// Procedure to mock module CMDRUNPRT.
dcl-proc getSplf export;
  dcl-pi *n likeds(splF_t);
  end-pi;

  dcl-ds splF likeds(splF_t);

  splF.system = 'SYSTEM';
  splF.nm = 'QSYSPRT';
  splF.nbr = 1;
  splF.job = 'RPGUNIT';

  return splF;

end-proc;


// Procedure to mock module CMDRUNPRT.
dcl-proc prtLine export;
  dcl-pi *n;
    line   char(80) const;
  end-pi;

  logIdx += 1;
  logLine(logIdx) = line;

end-proc;


// Helper to search a row starting with a given string.
dcl-proc findRow;
  dcl-pi *n int(10) extproc(*dclcase);
    value   varchar(80) const;
  end-pi;

  dcl-s i int(10);

  for i = 1 to logIdx;
    if (startsWith(value: %trim(logLine(i))));
      return i;
    endif;
  endfor;

  return -1;

end-proc;

