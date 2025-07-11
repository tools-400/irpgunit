**FREE
/if defined(templates)
/eof
/endif
/define templates
// ==========================================================================
//  iRPGUnit - Type Templates.
// ==========================================================================
//  Copyright (c) 2013-2020 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

dcl-c TEST_CASE_EXECUTOR 'CMDRUNSRV_runProc';

dcl-c TEST_PREFIX 'TEST';

dcl-c TSTPRC_ALL '*ALL';

dcl-c ORDER_API '*API';
dcl-c ORDER_REVERSE '*REVERSE';

dcl-c DETAIL_BASIC '*BASIC';
dcl-c DETAIL_ALL '*ALL';

dcl-c OUTPUT_NONE '*NONE';
dcl-c OUTPUT_ERROR '*ERROR';
dcl-c OUTPUT_ALLWAYS '*ALLWAYS';

dcl-c LIBRARY_LIST_JOBD '*JOBD';
dcl-c LIBRARY_LIST_CURRENT '*CURRENT';

dcl-c JOBD_DEFAULT '*DFT';

dcl-c RCLRSC_NO '*NO';
dcl-c RCLRSC_ALWAYS '*ALWAYS';
dcl-c RCLRSC_ONCE '*ONCE';

dcl-c NO_VALUE '*N';

dcl-c NO_MSG_TEXT '*N';

dcl-c MBR_RPGLE 'RPGLE';
dcl-c MBR_SQLRPGLE 'SQLRPGLE';
dcl-c MBR_CBLLE 'CBLLE';
dcl-c MBR_SQLCBLLE 'SQLCBLLE';

dcl-c PARM_DBGVIEW 'DBGVIEW';
dcl-c PARM_DEFINE 'DEFINE';
dcl-c PARM_TGTCCSID 'TGTCCSID';
dcl-c PARM_INCDIR 'INCDIR';
dcl-c PARM_OPTION 'OPTION';

dcl-c SLASH u'002F';
dcl-c BACK_SLASH u'005C';
dcl-c COLON u'003A';

dcl-s order_t char(10) template;
dcl-s detail_t char(10) template;
dcl-s output_t char(10) template;
dcl-s rclrsc_t char(10) template;
dcl-s stmf_t varchar(1024) template;
dcl-s stmf_fl_t char(1024) template;
dcl-s yesno_t char(1) template;

dcl-c TYPE_STMF '*STMF';
dcl-c TYPE_MEMBER '*MBR';

dcl-c MAX_NUM_LIB 250;

// 'Modul created in' message IDs
dcl-c MOD_CRT_RPG 'RNS9305';
dcl-c MOD_CRT_CBL 'LNC0899';

dcl-ds libl_t template;
  nume   int(5) pos(1);
  lib    char(10) dim(MAX_NUM_LIB) pos(3);
end-ds;

dcl-ds liblData_t qualified template;
  curlib   char(10) pos(1);
  libl     likeds(libl_t);
end-ds;

// ILE Activation Mark.
dcl-s actMark_t int(10) template;

// Empty Assertion Failure Event of version 1.
dcl-ds EMPTY_ASSERT_FAIL_EVT likeds(assertFailEvt_t) inz;

dcl-ds EMPTY_ASSERT_FAIL_EVT_LONG likeds(assertFailEvtLong_t) inz;

// Assertion Failure Event.
dcl-ds assertFailEvtLong_t qualified template;
  msg       like(msgText_t);
  callstk   likeds(callStk_t);
end-ds;

// Assertion Failure Event of version 1
dcl-ds assertFailEvt_t qualified template;
  msg       varchar(256);
  callstk   likeds(callStk_t);
end-ds;

// Call Stack.
dcl-ds callStk_t qualified template;
  nume    int(10);
  entry   likeds(callStkEnt_t) dim(MAX_CALL_STK_SIZE);
end-ds;

// Call Stack Entry.
dcl-ds callStkEnt_t qualified template;
  level   int(10);
  qstmt   likeds(qStatement_t);
end-ds;

// Program Message.
dcl-ds msg_t qualified template;
  id         char(7);
  txt        like(msgText_t);
  rpldata    varchar(256);
  key        char(4);
  qsndstmt   likeds(qStatement_t);
  qrcvstmt   likeds(qStatement_t);
end-ds;

// Qualified program statement
dcl-ds qStatement_t qualified template;
  qpgm     likeds(object_t);
  qmod     likeds(object_t);
  procnm   like(procNm_t);
  specnb   char(10);
end-ds;

// Old style error message prior to version 2.0.0.
dcl-s oldMsg_t char(256);

// MsgInfo_t is and must be defined in member TESTCASE!

// SQL pre-compiler option RPGPPOPT
dcl-s rpgPpOpt_t char(10);

// SQL pre-compiler option COMPILEOPT
dcl-s compileOpt_t varchar(5000);

// CRTRPGMOD INCDIR parameter
dcl-ds incdir_t qualified template;
  size     int(5);
  path     like(ifsStmf_t) dim(32);
end-ds;

// CRTRPGMOD TGTCCSID parameter
dcl-s tgtCcsid_t int(10);

// CRTSQL*I CVTCCSID parameter
dcl-s cvtCcsid_t int(10);

// CRTRPGMOD SRCSTMF parameter
dcl-s ifsStmf_t varchar(4096);

// Object qualified Name.
dcl-ds object_t qualified template;
  nm    char(10);
  lib   char(10);
end-ds;

// Spooled file qualified Name.
dcl-ds splf_t qualified template;
  system   char(10);
  nm       char(10);
  nbr      int(10);
  job      likeds(job_t);
end-ds;

// Job qualified Name.
dcl-ds job_t qualified template;
  name   char(10);
  user   char(10);
  nbr    char(6);
end-ds;

// Named callable procedure.
dcl-ds proc_t qualified template;
  procnm    like(procNm_t);
  procptr   pointer(*proc);
end-ds;

dcl-ds procNmList_t qualified template;
  handle     pointer;
  cnt        pointer(*proc);
  getnm      pointer(*proc);
  gotonext   pointer(*proc);
end-ds;

dcl-s procNm_t varchar(256) template;

dcl-ds procNms_t qualified template;
  nume   int(5);
  name   like(procNm_t) dim(250);
end-ds;

// qualified Job Name.
dcl-ds qlfJobNm_t qualified template;
  jobNm   char(10);
  usrNm   char(10);
  jobNb   char(6);
end-ds;

dcl-ds testResult_t qualified template;
  outcome     char(1);
  details;
  failure     likeds(assertFailEvtLong_t) overlay(details);
  error       likeds(msg_t) overlay(details);
  testname    like(procNm_t);
  exectime    int(20);
  srcFile     char(10);
  srcLib      char(10);
  srcMbr      char(10);
  assertCnt   int(10);
end-ds;

dcl-ds testSuite_t qualified template;
  isCobol         ind;
  qName           likeds(object_t);
  setupSuite      likeds(proc_t);
  setup           likeds(proc_t);
  testCasesCnt    int(10);
  testList        pointer;
  tearDown        likeds(proc_t);
  tearDownSuite   likeds(proc_t);
  testResults     pointer;
end-ds;

// User profile name.
dcl-s usrNm_t char(10) template;

// Object description
dcl-s text_t varchar(50) template;

// String value (must be greater than COMPILEOPT)
dcl-s string_t varchar(5120) template;

// Value of a line of the log.
dcl-s line_t varchar(256) template;

// Message replacement data or message text.
dcl-s msgText_t varchar(1024) template;

// Full qualified source member.
dcl-ds srcMbr_t qualified template;
  file   char(10);
  lib    char(10);
  mbr    char(10);
end-ds;

// Source information of a module
dcl-ds srcInf_t qualified template;
  type   char(10); // one of TYPE_STMF | TYPE_MEMBER
  mbr    likeds(srcMbr_t);
  stmf   like(stmf_t);
end-ds;

dcl-c MAX_CALL_STK_SIZE 64;
dcl-c CALL_STACK_INCOMPLETE '*INCOMPLETE';

// TestResult_t.outcome can have three values.
dcl-c TEST_CASE_SUCCESS 'S';
dcl-c TEST_CASE_FAILURE 'F';
dcl-c TEST_CASE_ERROR   'E';

dcl-c QUOTE const('''');


// A sized array of OS400 objects.
dcl-ds objectArray_t template qualified;
  size     int(5);
  object   dim(51) likeds(object_t);
end-ds;

// A sized list of options.
dcl-ds options_t template qualified;
  size     int(5);
  option   char(12) dim(25);
end-ds;

// A sized list of compiler directives.
dcl-ds defines_t template qualified;
  size     int(5);
  define   char(50) dim(32);
end-ds;

dcl-s headToken_t char(10) template;
dcl-s dbgView_t char(10) template;
dcl-s export_t char(10) template;
dcl-s activationGroup_t char(10) template;

dcl-s cmd_t varchar(8192) template;
dcl-s serializedArray_t varchar(2048) template;
dcl-s serializedObject_t varchar(21) template;
dcl-s serializedOptions_t varchar(512) template;
dcl-s serializedString_t varchar(5136) template;
dcl-s targetRelease_t char(10) template;
dcl-s assertString_t varchar(32565:4) CCSID(*UTF8) TEMPLATE;
dcl-s assertNumeric_t zoned(63:20) template;
dcl-s serializedIncDir_t varchar(131072) template; // 32 * 4096
dcl-s serializedStmf_t varchar(4098) template; // 4096 + 2 * len(QUOTES)
dcl-s serializedTgtCcsid_t varchar(20) template;

// Program Status Data Structure.
dcl-ds sds_t template qualified;
  pgmname         char(10);
  pgmstat         zoned(5);
  prevstat        zoned(5);
  lastseq         char(8);
  lastsubr        char(8);
  nbrparm         zoned(3);
  exctype         char(3);
  excnbr          char(4);
  miinstruction   char(4);
  workarea        char(30);
  pgmLib          char(10);
  excdata         char(80);
  rnx9001exc      char(4);
  lastfilelong    char(10);
  unused_1        char(6);
  datFmt          char(8);
  year            zoned(2);
  lastfileshort   char(8);
  filestat        char(35);
  job             char(10);
  user            char(10);
  nbr             zoned(6);
  startdate       zoned(6);
  rundate         zoned(6);
  runtime         zoned(6);
  compdate        char(6);
  comptime        char(6);
  complevel       char(4);
  srcFile         char(10);
  srcLib          char(10);
  srcMbr          char(10);
  pgmcontproc     char(10);
  modcontproc     char(10);
  sourceid1       int(5);
  sourceid2       int(5);
  curruser        char(10);
  unused_2        char(62);
end-ds;

