**FREE
// ==========================================================================
//  iRPGUnit - Logging Facilities for CMDRUN.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Outputs a line feed character to the log output stream.
// Used for formatting and spacing in log output.
///
dcl-pr lineFeed extproc('CMDRUNLOG_lineFeed');
end-pr;

///
// Logs the final test run completion message with summary statistics.
// This procedure outputs the overall results of the test suite execution
// including total failures and errors encountered.
//
// @param msg      - Completion message text to be logged
// @param failures - Total number of test failures recorded
// @param errors   - Total number of test errors recorded
///
dcl-pr logCompMsg extproc('CMDRUNLOG_logCompMsg');
  msg      varchar(16384) options(*varsize) const;
  failures int(10) const;
  errors   int(10) const;
end-pr;

///
// Logs a test error event when an unexpected exception occurs during test execution.
// This captures and records system errors, runtime exceptions, and other
// unexpected conditions that prevent normal test completion.
//
// @param testnm      - Name of the test procedure where the error occurred
// @param excpmsginfo - Detailed exception message information structure
///
dcl-pr logError extproc('CMDRUNLOG_logError');
  testnm      like(procNm_t) const;
  excpmsginfo likeds(msg_t) const;
end-pr;

///
// Logs a test failure event when an assertion does not meet expected conditions.
// This records deliberate test failures where the test logic detected
// an incorrect result or condition.
//
// @param testnm  - Name of the test procedure that failed
// @param failure - Detailed failure information including assertion details
///
dcl-pr logfailure extproc('CMDRUNLOG_logFailure');
  testnm  like(procNm_t) const;
  failure likeds(assertFailEvtLong_t) const;
end-pr;

///
// Logs a successful test completion with assertion count summary.
// Records when a test procedure completes successfully with all
// assertions passing as expected.
//
// @param testnm       - Name of the successfully completed test procedure
// @param assertionCnt - Total number of assertions executed in the test
///
dcl-pr logSuccess extproc('CMDRUNLOG_logSuccess');
  testnm       like(procNm_t) const;
  assertionCnt int(10) const;
end-pr;

///
// Logs a single call stack entry for debugging and error tracing purposes.
// Used to output detailed program flow information when errors occur,
// helping developers trace the execution path.
//
// @param qsndstmt - Statement information from the call stack
///
dcl-pr logStackEntry extproc('CMDRUNLOG_logStackEntry');
  qsndstmt likeds(qStatement_t) const;
end-pr;

///
// Logs runtime error messages that occur during test framework execution.
// Captures and records system-level errors, configuration issues,
// and other runtime problems outside of individual test failures.
//
// @param line - Error message text to be logged
///
dcl-pr logRuntimeError extproc('CMDRUNLOG_logRuntimeError');
  line varchar(2048) options(*varsize) const;
end-pr;

// TODO: remove prototype
///
// Formats a call stack entry into a standardized readable string format.
// Converts raw call stack statement information into a human-readable
// format suitable for logging and debugging output.
//
// @param qsndstmt - Raw statement information from the call stack
//
// @return Formatted stack entry string ready for output
///
//dcl-pr fmtStackEntry like(line_t) extproc('CMDRUNLOG_fmtStackEntry');
//  qsndstmt likeds(qStatement_t) const;
//end-pr;

// TODO: remove prototype
///
// Logs the current library list configuration for debugging purposes.
// Records the active library list at the time of test execution,
// which is crucial for troubleshooting object resolution issues.
//
// @param librarylist - Complete library list data structure
///
//dcl-pr logLibraryList extproc('CMDRUNLOG_logLibraryList');
//  librarylist likeds(liblData_t) const;
//end-pr;

///
// Establishes the logging context and configuration for the test run session.
// Initializes logging parameters including target program, detail level,
// and output format that will be used throughout the test execution.
//
// @param testpgm - Object information for the test service program being executed
// @param detail  - Logging detail level (e.g., 'BASIC', 'ALL', 'FAILURE')
// @param output  - Output format specification (e.g., 'SPOOLFILE', 'STDOUT')
///
dcl-pr setLogContext extproc('CMDRUNLOG_setLogContext');
  testpgm likeds(object_t) const;
  detail  char(10) const;
  output  char(10) const;
end-pr;

///
// Updates the current logging context with new library list information.
// Modifies the active logging context to reflect changes in the
// library list that may affect subsequent logging operations.
//
// @param libldata - Updated library list data structure
///
dcl-pr updateLogContext extproc('updateLogContext');
  libldata likeds(liblData_t) const;
end-pr;

///
// Outputs a raw text line directly to the log without any formatting or headers.
// Provides direct access to the log output stream for custom formatting
// or special logging requirements that bypass standard log formatting.
//
// @param line - Raw text line to be written directly to log output
///
dcl-pr logRawLine extproc('CMDRUNLOG_logRawLine');
  line varchar(2048) value;
end-pr;

///
// Retrieves information about the current log spooled file being used.
// Returns details about the active spooled file where log output
// is being written, useful for log management and retrieval operations.
//
// @return Complete spooled file information structure
///
dcl-pr getLogSplF extproc('CMDRUNLOG_getLogSplF') likeds(splf_t);
end-pr;
