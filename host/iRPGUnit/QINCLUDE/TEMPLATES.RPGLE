**FREE
/if defined(templates)
/eof
/endif
/define templates
// ==========================================================================
//  iRPGUnit - Public Type Templates.
// ==========================================================================
//  Copyright (c) 2013-2026 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

dcl-c MAX_CALL_STK_SIZE 64;

// Call Stack Entry v1.
dcl-ds callStk_v1_t qualified template;
  numE    int(10) inz;
  entry   likeds(callStkEnt_t) dim(MAX_CALL_STK_SIZE) inz(*likeds);
end-ds;

// Call Stack Entry.
dcl-ds callStkEnt_t qualified template;
  level   int(10) inz;
  qStmt   likeds(qStatement_t) inz(*likeds);
end-ds;

// Qualified program statement
dcl-ds qStatement_t qualified template;
  qPgm     likeds(object_t) inz(*likeds);
  qMod     likeds(object_t) inz(*likeds);
  procNm   like(procNm_t) inz;
  specNb   char(10) inz;
end-ds;

// Object qualified Name.
dcl-ds object_t qualified template;
  nm    char(10) inz;
  lib   char(10) inz;
end-ds;

// Assertion Failure Event of v1
dcl-ds assertFailEvt_t qualified template;
  msg       varchar(256) inz;
  callstk   likeds(callStk_v1_t) inz(*likeds);
end-ds;

// Assertion Failure Event Long v2 (external)
dcl-ds assertFailEvtLong_t qualified template;
  msg          like(msgText_t) inz;
  logExpected  likeds(logValue_t) inz(*likeds);
  logActual    likeds(logValue_t) inz(*likeds);
  callstk      likeds(callStk_v1_t) inz(*likeds);
end-ds;

// Message information
dcl-ds msgInfo_t qualified template;
  id      char(7);
  txt     varchar(256);
  pgm     char(10);
  mod     char(10);
  proc    varchar(256);
  specNb  char(10);
end-ds;

// Expected/actual log value.
dcl-ds logValue_t qualified template;
   value          varchar(2048) inz;
   type           like(dataType_t) inz;
   isTruncated    ind inz(*off);
   length         int(10) inz;
   originalLength int(10) inz;
end-ds;

// Procedure name.
dcl-s procNm_t varchar(256) template;

// Assertion string value.
dcl-s assertString_t varchar(32565:4) ccsid(*UTF8) template;

// Assertion procedure name prefix.
dcl-s assertProcNmPrefix_t varchar(32) template;

// Log value data type.
dcl-s dataType_t varchar(20) template;

// Stream file path.
dcl-s ifsStmf_t varchar(4096);

// Message replacement data or message text.
dcl-s msgText_t varchar(1024) template;

// Old style error message prior to version 2.0.0.
dcl-s oldMsg_t char(256);

