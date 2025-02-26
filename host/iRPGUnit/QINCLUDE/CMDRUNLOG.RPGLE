**FREE
// ==========================================================================
//  iRPGUnit - Logging Facilities for CMDRUN.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

// Linefeed.
dcl-pr lineFeed extproc('CMDRUNLOG_lineFeed');
end-pr;

// Log the test run completion message.
dcl-pr logCompMsg extproc('CMDRUNLOG_logCompMsg');
  msg             varchar(16384) options(*varsize) const;
  failures        int(10) const;
  errors          int(10) const;
end-pr;

// Log a test error event.
dcl-pr logError extproc('CMDRUNLOG_logError');
  testnm          like(procNm_t) const;
  excpmsginfo     likeds(msg_t) const;
end-pr;

// Log a test failure event.
dcl-pr logfailure extproc('CMDRUNLOG_logFailure');
  testnm          like(procNm_t) const;
  failure         likeds(assertFailEvtLong_t) const;
end-pr;

// Log a test success event.
dcl-pr logSuccess extproc('CMDRUNLOG_logSuccess');
  testnm          like(procNm_t) const;
  assertioncnt    int(10) const;
end-pr;

// Print a call stack entry.
dcl-pr logStackEntry extproc('CMDRUNLOG_logStackEntry');
  qsndstmt        likeds(qStatement_t) const;
end-pr;

// Log runtime error.
dcl-pr logRuntimeError extproc('CMDRUNLOG_logRuntimeError');
  line            varchar(2048) options(*varsize) const;
end-pr;

// Formats a call stack entry.
dcl-pr fmtStackEntry like(line_t) extproc('CMDRUNLOG_fmtStackEntry');
  qsndstmt        likeds(qStatement_t) const;
end-pr;

// Log library list.
dcl-pr logLibraryList extproc('CMDRUNLOG_logLibraryList');
  librarylist     likeds(liblData_t) const;
end-pr;

// Set the logging context.
dcl-pr setLogContext extproc('CMDRUNLOG_setLogContext');
  // Name of the test service program being run.
  testpgm         likeds(object_t) const;
  detail          char(10) const;
  output          char(10) const;
end-pr;

dcl-pr updateLogContext extproc('updateLogContext');
  libldata        likeds(liblData_t) const;
end-pr;

// Log a raw line (no header, no automatic opening / closing).
dcl-pr logRawLine extproc('CMDRUNLOG_logRawLine');
  line            varchar(2048) value;
end-pr;

// Returns the name of the current log spooled file.
dcl-pr getLogSplF extproc('CMDRUNLOG_getLogSplF') likeds(splf_t);
end-pr;

