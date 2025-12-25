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
//     >>PARM<<  MODULE(&LI/CMDRUNLOGT);
//     >>PARM<<  BNDSRVPGM(&LI/RUMEMMGR);
//     >>PARM<<  BNDDIR(&LI/IRPGUNIT);
//     >>PARM<<  COPTION(*EVENTF);
//     >>PARM<<  BOPTION(*DUPPROC);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

/undefine ENABLE_DEBUG_MESSAGES

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,CALLSTACK
/copy qinclude,CMDRUNLOG
/copy qinclude,LIBL
/copy qinclude,MEMMGR
/copy qinclude,TEMPLATES
/copy qinclude,STRING
/copy qsysinc,memcpy

// CMDRUNPRTY is imported to mock module CMDRUNPRT. That way, we can
// test what would have been printed in the spool file, without
// involving the spool file API.
/copy qinclude,CMDRUNPRT

//----------------------------------------------------------------------
//   Constants
//----------------------------------------------------------------------

// Left margin of the log. Must match CMDRUNLOG.LEFT_MARGIN.
dcl-c MARGIN '     ';
dcl-c NO_SPEC_NBR '';

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

// The mock log lines and state.
dcl-s g_logIdx          int(10);
dcl-s g_logLine         char(80) Dim(100);
dcl-s g_logWasOpened    ind;
dcl-s g_logWasClosed    ind;
// The (dummy) service program containing the tests.
dcl-ds g_testSrvPgm likeds(Object_t);
// The (dummy) test case name.
dcl-s g_testNm          like(ProcNm_t);
// Path and type of the XML stream file that is created
dcl-ds g_xmlStmfInfo    likeds(xmlStmfInfo_t) inz;

dcl-s g_prtWidth int(10) inz(40);

//----------------------------------------------------------------------
//   Test Definitions
//----------------------------------------------------------------------

dcl-proc setUp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  clear g_logIdx;
  clear g_logLine;
  clear g_logWasOpened;
  clear g_logWasClosed;
  clear g_testSrvPgm;
  clear g_testNm;
  clear g_xmlStmfInfo;

  g_testSrvPgm.nm = 'MY_SRVPGM';
  setLogContext(g_testSrvPgm: DETAIL_ALL: OUTPUT_ALLWAYS: g_xmlStmfInfo);

  reset g_prtWidth;

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

  g_testNm = 'successful_test_with_one_assertion';

  // Execution.

  logSuccess(g_testNm: NO_SPEC_NBR: oneAssertion);

  // Controls.

  assert(g_logWasOpened : 'Log was not opened');
  aEqual(MARGIN + '*** Tests of MY_SRVPGM ***         ': g_logLine(1));

  r = findRow('successful_test');
  assert(r > 0: 'Row starting with ''successful_test'' not found');

  aEqual(MARGIN + 'successful_test_with_one_asser     ': g_logLine(r));
  aEqual(MARGIN + 'tion - Success                     ': g_logLine(r+1));
  aEqual(MARGIN + '  1 assertions                     ': g_logLine(r+2));
  aEqual(MARGIN + '-----------------------            ': g_logLine(r+3));
  iEqual(r+4: g_logIdx);

end-proc;


dcl-proc testLogSuccessWith2Assertions export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c twoAssertions const(2);
  dcl-s r int(10);

  // Setup.

  g_testNm = 'successful_test_with_two_assertions';

  // Execution.

  logSuccess(g_testNm: NO_SPEC_NBR: twoAssertions);

  // Controls.

  aEqual(MARGIN + '*** Tests of MY_SRVPGM ***        ': g_logLine(1));

  r = findRow('successful_test');
  assert(r > 0: 'Row starting with ''successful_test'' not found');

  aEqual(MARGIN + 'successful_test_with_two_asser    ': g_logLine(r ));
  aEqual(MARGIN + 'tions - Success                   ': g_logLine(r+1));
  aEqual(MARGIN + '  2 assertions                    ': g_logLine(r+2));
  aEqual(MARGIN + '-----------------------           ': g_logLine(r+3));
  iEqual(r+4: g_logIdx);

end-proc;


dcl-proc testLog2Successes export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s testNm2 like(g_testNm);
  dcl-s r int(10);

  // Setup.

  g_testNm  = 'successful_test_1';
  testNm2 = 'successful_test_2';

  // Execution.

  logSuccess(g_testNm: NO_SPEC_NBR: 0);
  logSuccess(testNm2: NO_SPEC_NBR: 0);

  // Controls.

  aEqual(MARGIN + '*** Tests of MY_SRVPGM ***    ': g_logLine(1));

  r = findRow('successful_test');
  assert(r > 0: 'Row starting with ''successful_test'' not found');

  aEqual(MARGIN + 'successful_test_1 - Success   ': g_logLine(r ) );
  aEqual(MARGIN + '  0 assertions                ': g_logLine(r+1));
  aEqual(MARGIN + '-----------------------       ': g_logLine(r+2));
  aEqual(MARGIN + ''                               : g_logLine(r+3));
  aEqual(MARGIN + 'successful_test_2 - Success   ': g_logLine(r+4));
  aEqual(MARGIN + '  0 assertions                ': g_logLine(r+5));
  aEqual(MARGIN + '-----------------------       ': g_logLine(r+6));
  iEqual(r+7: g_logIdx);

end-proc;


dcl-proc testLogFailureWithoutSpecNb export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds testFailureEvent likeds(testFailureEvent_t) inz;
  dcl-s r int(10);

  dcl-s pCallstk pointer;
  dcl-ds callstkEnt likeds(callStkEnt_t);

  // Setup.

  g_testNm = 'failure_without_spec_nb';

  pCallstk = Callstack_alloc(1: 'pCallstk');

  clear callstkEnt;
  callstkEnt.qStmt.qPgm.nm = 'MY_SRVPGM';
  callstkEnt.qStmt.qMod.nm = 'MY_SRVPGM';
  callstkEnt.qStmt.procNm = g_testNm;
  callstkEnt.qStmt.specNb = *blank;

  Callstack_addEntry(pCallstk: callstkEnt);

  testFailureEvent.pCallstk = pCallstk;

  // Execution.

  logFailure(g_testNm: testFailureEvent);

  // Controls.

  assert(g_logWasOpened: 'Log was not opened' );
  aEqual(MARGIN + '*** Tests of MY_SRVPGM ***        ': g_logLine(1));

  r = findRow('failure_without');
  assert(r > 0: 'Row starting with ''failure_without'' not found');

  aEqual(MARGIN + 'failure_without_spec_nb - FAIL    ': g_logLine(r ));
  aEqual(MARGIN + 'URE                               ': g_logLine(r+1));
  aEqual(MARGIN + '                                  ': g_logLine(r+2)); // new with *JENKINS2
  aEqual(MARGIN + '  failure_without_spec_nb (MY_    ': g_logLine(r+3));
  aEqual(MARGIN + 'SRVPGM->MY_SRVPGM:*N)             ': g_logLine(r+4));
  aEqual(MARGIN + '                                  ': g_logLine(r+5)); // new with *JENKINS2
  aEqual(MARGIN + 'Expected:          Not availab    ': g_logLine(r+6));
  aEqual(MARGIN + 'le                                ': g_logLine(r+7));
  aEqual(MARGIN + 'Actual:            Not availab    ': g_logLine(r+8));
  aEqual(MARGIN + 'le                                ': g_logLine(r+9));
  aEqual(MARGIN + '-----------------------           ': g_logLine(r+10));
  aEqual(MARGIN + '                                  ': g_logLine(r+11));
  iEqual(r+11: g_logIdx);

on-exit;
  MemMgr_dealloc(pCallstk: 'pCallstk');

end-proc;


dcl-proc testLogErrorWithoutMsgId export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds excpMsgInfo likeds(Msg_t);
  dcl-s r int(10);

  // Setup.

  g_testNm = 'error_with_missing_msg_id';
  excpMsgInfo.Id = *blank;
  excpMsgInfo.txt = 'Error message.';
  excpMsgInfo.qSndStmt.qPgm.nm = 'ERRORPGM';
  excpMsgInfo.qSndStmt.procNm = 'error_proc';
  excpMsgInfo.qSndStmt.specNb = '1000';

  // Execution.

  logError(g_testNm: excpMsgInfo);

  // Controls.

  assert(g_logWasOpened : 'Log was not opened');
  aEqual(MARGIN + '*** Tests of MY_SRVPGM ***        ': g_logLine(1));

  r = findRow('error_with');
  assert(r > 0: 'Row starting with ''error_with'' not found');

  aEqual(MARGIN + 'error_with_missing_msg_id - ERROR ': g_logLine(r));
  aEqual(MARGIN + 'Error message.                    ': g_logLine(r+1));
  aEqual(MARGIN + '  error_proc (ERRORPGM->:1000)    ': g_logLine(r+2));
  aEqual(MARGIN + '-----------------------           ': g_logLine(r+3));
  iEqual(r+4: g_logIdx);

end-proc;


dcl-proc testLogErrorWithoutExcpInfoOrigin export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-ds excpMsgInfo likeds(Msg_t);
  dcl-s r int(10);

  // Setup.

  g_testNm = 'error_without_origin_info';
  excpMsgInfo.Id = 'CPF1234';
  excpMsgInfo.txt = 'Error message.';
  excpMsgInfo.qSndStmt.qPgm.nm = *blank;
  excpMsgInfo.qSndStmt.procNm = *blank;
  excpMsgInfo.qSndStmt.specNb = *blank;

  // Execution.

  logError(g_testNm: excpMsgInfo);

  // Controls.

  aEqual(MARGIN + '*** Tests of MY_SRVPGM ***        ': g_logLine(1));

  r = findRow('error_without');
  assert(r > 0: 'Row starting with ''error_without'' not found');

  aEqual(MARGIN + 'error_without_origin_info - ERROR ': g_logLine(r));
  aEqual(MARGIN + 'CPF1234 - Error message.          ': g_logLine(r+1));
  aEqual(MARGIN + '-----------------------           ': g_logLine(r+2));
  iEqual(r+3: g_logIdx);

end-proc;


dcl-proc testLogCompMsg export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s r int(10);

  // Execution.

  logCompMsg('Completion message': 0: 0);

  // Controls.

  assert(g_logWasOpened: 'Log was not opened');
  aEqual(MARGIN + '*** Tests of MY_SRVPGM ***        ': g_logLine(1));

  r = findRow('Library list:');
  assert(r > 0: 'Row starting with ''Library list:'' not found');

  aEqual(MARGIN + 'Completion message                ': g_logLine(r+2));
  assert(r+2 = g_logIdx
  : 'Line with ''Completion message'' must be the last one');
  assert(g_logWasClosed: 'Log was not closed');

end-proc;


//----------------------------------------------------------------------
// The below layout must be ensured over the time, because the spooled
// file is parsed by the VS Code 'IBM i Testing' extension.
// See:
//    https://github.com/tools-400/irpgunit/issues/22
//    https://github.com/IBM/vscode-ibmi-testing
//----------------------------------------------------------------------
// ....+....1....+....2....+....3....+....4....+....5....+....8....+....7....+....8
//      XML file    : '/home/RADDATZ/this_is_an-extra_ordinary_very_long_path'
//                    '_name_that_requires_more_than_two_lines_for_beeing_pri'
//                    'nted_on_the_iRPGUnit_spooled_file/irpgunit-ruplugint1.'
//                    'xml'
//      XML type    : *JENKINS1
//----------------------------------------------------------------------
dcl-proc testLogStmfPath export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  clear g_logIdx;
  clear g_logLine;
  clear g_logWasOpened;
  clear g_logWasClosed;
  clear g_testSrvPgm;
  clear g_testNm;
  clear g_xmlStmfInfo;

  g_xmlStmfInfo.path = '/home/RADDATZ/this_is_an-extra_ordinary_very_long_path_name_+
                      that_requires_more_than_two_lines_for_beeing_printed_on_the_+
                      iRPGUnit_spooled_file/irpgunit-ruplugint1.xml';
  g_xmlStmfInfo.type = '*JENKINS2';

  g_prtWidth = 80;

  g_testSrvPgm.nm = 'MY_SRVPGM';
  setLogContext(g_testSrvPgm: DETAIL_ALL: OUTPUT_ALLWAYS: g_xmlStmfInfo);

  // Execution.

  logStmfPath('XML file    : ': g_xmlStmfInfo.path);
  logRawLine('XML type    : ' + g_xmlStmfInfo.type);

  // Controls.

  aEqual(MARGIN + 'XML file    : ''/home/RADDATZ/this_is_an-extra_ordinary_very_long_path'''
        : g_logLine(1));
  aEqual(MARGIN + '              ''_name_that_requires_more_than_two_lines_for_beeing_pri'''
        : g_logLine(2));
  aEqual(MARGIN + '              ''nted_on_the_iRPGUnit_spooled_file/irpgunit-ruplugint1.'''
        : g_logLine(3));
  aEqual(MARGIN + '              ''xml'''
        : g_logLine(4));
  aEqual(MARGIN + 'XML type    : *JENKINS2'
        : g_logLine(5));
  iEqual(5: g_logIdx);

end-proc;


dcl-proc testLogRawLine export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  // Execution.

  logRawLine('A short text');

  // Controls.

  aEqual(MARGIN + 'A short text                      ': g_logLine(1));
  iEqual(1: g_logIdx);

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
  aEqual(MARGIN + 'A very very very very very ver': g_logLine(1));
  aEqual(MARGIN + 'y very very long text': g_logLine(2));
  iEqual(2: g_logIdx);

end-proc;


//----------------------------------------------------------------------
//   Support Procedures
//----------------------------------------------------------------------

// Procedure to mock module CMDRUNPRT.
dcl-proc clsPrt export;
  dcl-pi *n;
  end-pi;

  g_logWasClosed = *on;

end-proc;


// Procedure to mock module CMDRUNPRT.
dcl-proc getPrtWidth export;
  dcl-pi *n int(10);
  end-pi;

  return g_prtWidth;

end-proc;


// Procedure to mock module CMDRUNPRT.
dcl-proc opnPrt export;
  dcl-pi *n;
    testPgmNm   const like(Object_t.nm);
  end-pi;

  g_logWasOpened = *on;
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

  g_logIdx += 1;
  g_logLine(g_logIdx) = line;

  sndPlainDbgMsg(%char(g_logIdx) + ': ' + g_logLine(g_logIdx));

end-proc;


// Helper to search a row starting with a given string.
dcl-proc findRow;
  dcl-pi *n int(10) extproc(*dclcase);
    value   varchar(80) const;
  end-pi;

  dcl-s i int(10);

  for i = 1 to g_logIdx;
    if (startsWith(value: %trim(g_logLine(i))));
      return i;
    endif;
  endfor;

  return -1;

end-proc;

//----------------------------------------------------------------------
// Sends a debug message to the job log.
//----------------------------------------------------------------------
dcl-proc sndPlainDbgMsg;
  dcl-pi *n extproc(*dclcase);
    i_msg varchar(256) const;
  end-pi;

/if defined(ENABLE_DEBUG_MESSAGES)
  snd-msg *INFO '[DEBUG] ' + i_msg %target(*caller);
/endif

end-proc;

