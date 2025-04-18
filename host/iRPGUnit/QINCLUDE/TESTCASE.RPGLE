**free
/if not defined (IRPGUNIT_TESTCASE)
/define IRPGUNIT_TESTCASE
/// ==========================================================================
//  iRPGUnit - Public API.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
/// ==========================================================================

/if defined(IRPGUNIT_STMF)
/include qinclude/TEMPLATES.rpgle
/else
/include qinclude,TEMPLATES
/endif

/// ------------------------------------
//  Assertions of module ASSERT.
/// ------------------------------------


///
// Cobol enabled.
// Aphanumeric Equality Assertion
//
// Compares the given String values 'expected' and 'actual'. The assertion
// fails, if both values are different.
//
// Example:
//   aEqual( 'John Smith' : name );
//
// Message:
//   Expected 'expected', but was 'actual'.
//
// If parameter 'fieldName' is specified, the message is prefixed
// with 'fieldName:'.
//
// @param Expected value
// @param Actual value
// @param Field name (optional)
//
// @throws CPF9897 Expected '{expected}', but was '{actual}'.
///
dcl-pr aEqual extproc('aEqual') opdesc;
  expected    char(32565) const;
  actual      char(32565) const;
 /if defined(RPGUNIT_INTERNAL)
  fieldName   char(64) options(*nopass: *omit) const;
 /else
  fieldName   varchar(64) options(*nopass: *omit) const;
 /endif
end-pr;

///
// Integer Equality Assertion
//
// Compares the given Integer values expected and actual. The assertion
// fails, if both values are different.
//
// Example:
//   iEqual( 1000 : balance );
//
// Message:
//   Expected 'expected', but was 'actual'.
//
// If parameter 'fieldName' is specified, the message is prefixed
// with 'fieldName:'.
//
// @param Expected value
// @param Actual value
// @param Field name (optional).
//
// @throws CPF9897 Expected '{expected}', but was '{actual}'.
///
dcl-pr iEqual extproc('iEqual') opdesc;
  expected   zoned(31: 0) const;
  actual     zoned(31: 0) const;
  fieldName  varchar(64) options(*nopass: *omit) const;
end-pr;

///
// Boolean Equality Assertion
//
// Compares the given Boolean values expected and actual. The assertion fails,
// if both values are different.
//
// Example:
//   iEqual( *ON : isFound );
//
// Message:
//   Expected 'expected', but was 'actual'.
//
// If parameter 'fieldName' is specified, the message is prefixed
// with 'fieldName:'.
//
// @param Expected value
// @param Actual value
// @param Field name (optional)
//
// @throws CPF9897 Expected '{expected}', but was '{actual}'.
///
dcl-pr nEqual extproc('nEqual') opdesc;
  expected   ind const;
  actual     ind const;
  fieldName  varchar(64) options(*nopass: *omit) const;
end-pr;

///
// Cobol enabled.
// General Purpose Assertion
//
// Checks the specified Boolean expression for true. The assertion fails,
// if the expression evaluates to false. When the assertion fails, the
// value of 'message' is added to the test report.
//
// Example 1:
//   assert( newTime > oldTime : 'newTime is not larger than oldTime' );
//
// Message:
//   newTime is not larger than oldTime
//
// Example 2:
//   assert( %not eof : 'Missing record in file XXX' );
//
// Message:
//   Missing record in file XXX
//
// @param Condition to test
// @param Message if false (optional)
//
// @throws CPF9897 {msgIfFalse}, e.g. 'Missing record in file XXX'
///

dcl-pr assert extproc('assert') opdesc;
  condition  ind const;
 /if defined(RPGUNIT_INTERNAL)
  msgIfFalse like(OldMsg_t) options(*nopass) const;
 /else
  msgIfFalse varchar(16384) options(*varsize: *nopass) const;
 /endif
end-pr;

///
// Cobol enabled.
// Fail test
//
// Produces an error and appends the specified 'message' to the test
// report. The test case is terminated.
//
// Example:
//   monitor;
//     call PGM();
//     fail( 'PGM should have thrown an exception' );
//   on-error;
//     // Exception seen. Success.
//   endmon;
//
// @param Message
// @throws CPF9897 {msg}, e.g. 'PGM should have thrown an exception'
///
dcl-pr fail extproc('fail') opdesc;
 /if defined(RPGUNIT_INTERNAL)
  msg        like(OldMsg_t) options(*nopass) const;
 /else
  msg        varchar(16384) options(*varsize: *nopass) const;
 /endif
end-pr;

///
// Get Monitored Message.
//
// Retrieves the latest *ESCAPE message from the job log. Usually
// called within the 'on-error' section of a 'monitor' block.
//
// Example:
//   monitor;
//     a = 10;
//     b = 0;     // Attempt made to divide by zero for
//     c = a / b; // fixed point operation. (MCH1211)
//     fail( 'Division by zero did not raise an error.' );
//   on-error;
//     msgInfo = getMonitoredMessage(*ON); // remove message
//   endmon;                               // from job log
//
//   aEqual( 'MCH1211': msgInfo.Id );
//
// @param Whether to remove message from job log
//
// @return Message information (MsgInfo_t)
///
dcl-pr getMonitoredMessage likeds(MsgInfo_t) extproc('getMonitoredMessage') opdesc;
  doRmvMsg   ind options(*nopass) const;
end-pr;

dcl-ds MsgInfo_t qualified template;
  id      char(7);
  txt     varchar(256);
  pgm     char(10);
  mod     char(10);
  proc    varchar(256);
  specNb  char(10);
end-ds;

///
// Assert joblog contains message
//
// Checks whether the job log contains the specified message ID between
// NOW and 'timeLimit'.
//
// Examples:
//   assertJobLogContains( 'MCH1211' : %timestamp() - %minutes(2) );
//
// @param Message id to look for
// @param Time frame to search within a job log
//
// @throws CPF9897 'Message '{msgId}' not found in the job log.'
///
dcl-pr assertJobLogContains extproc('assertJobLogContains') opdesc;
  msgId      char(7) const;
  timeLimit  timestamp const;
end-pr;

///
// Assert message queue contains message
//
// Checks whether a given message queue contains the specified message ID between
// NOW and 'timeLimit'.
//
// Examples:
//   assertMessageQueueContains( 'MCH1211' : %timestamp() - %minutes(2) );
//
// @param User name or message queue name
// @param message queue library (optional)
// @param Message id to look for (optional)
// @param Text of message to match (optional)
// @param Help of message to match (optional)
// @param Time frame to search within a job log
//
// @throws CPF9897 'Message '{msgId}' not found in the job log.'
///
dcl-pr assertMessageQueueContains extproc('assertMessageQueueContains') opdesc;
  userOrQueue  char(10) const;
  library      char(10) options(*omit) const;
  msgId        char(7) options(*omit) const;
  msgText      varchar(132) options(*omit) const;
  msgHelp      varchar(256) options(*omit) const;
  timeLimit    timestamp const;
end-pr;

///
// ------------------------------------
//  CL Commands of module TESTUTILS.
// ------------------------------------
///

///
// Get Full Timestamp
//
// Returns the full current timestamp, without rounding the
// microSeconds like %timestamp() does.
//
// Example:
//   tmStmp = getFullTimeStamp();
//
// @return Current timestamp
///
dcl-pr getFullTimeStamp timestamp extproc('getFullTimeStamp') opdesc;
end-pr;

///
// Clear Physical File
//
// Uses CLRPFM to remove the data from 'member' of file 'file'.
// The file must be stored in *CURLIB.
//
// @param Physical file name clear
// @param Member name to clear (optional)
///
dcl-pr clrpfm extproc('CLRPFM') opdesc;
   // A file name.
  w1fileNm  char(10) const;
   // An (optional) member name.
  w1mbrNm   char(10) options(*NoPass) const;
end-pr;

///
// Reclaim Activation Group
//
// Uses RCLACTGRP to reclaim the activation group specified at
// parameter 'activationGroup'.
//
// Example:
//   rclActGrp( '*ELIGIBLE' );
//
// @param Activation group name to reclaim
///
dcl-pr rclActGrp extproc('RCLACTGRP') opdesc;
  w1actGrpNm  char(10) const;
end-pr;

///
// Run CL Command
//
// Uses the QCMDEXC API to execute the CL command specified at
// parameter command.
//
// Example:
//   runCmd( 'ALCOBJ OBJ((*CURLIB/FILE *FILE *EXCL))' );
//
// @param Command to run
///
dcl-pr runCmd extproc('runCmd') opdesc;
  w1cmd  varchar(32702) const;
end-pr;

///
// Wait Seconds
//
// Suspends the current job for a specified number of seconds.
// Optionally displays a status message. When the job resumes
// the originally status message is restored.
//
// Example:
//   waitSeconds(3 : 'Waiting 3 seconds ...');
//
// @param Number of seconds to wait
// @param Message to log (optional)
///
dcl-pr waitSeconds extproc('waitSeconds') opdesc;
   // Wait time in seconds
  seconds  int(10) const;
   // Optional. Message sent to *EXT
  message  varchar(50) options(*nopass: *omit) const;
end-pr;

///
// Display Status Message
//
// Displays a given status message in the status line at the bottom of
// the screen.
//
// Example:
//   displayStatusMessage('Hello World!');
//
// @param Message to display
///
dcl-pr displayStatusMessage extproc('displayStatusMessage') opdesc;
   // Optional. Message sent to *EXT
  message  varchar(132) const;
end-pr;

///
// Restore Status Message
//
// Replaces the current status message with the previous message.
//
// Example:
//   // Display status message.
//   displayStatusMessage('Hello World!');
//
//   // Overwrite status message.
//   displayStatusMessage('The quick brown fox ...');
//
//   // Restore previous 'Hello World!' message.
//   restoreStatusMessage();
///
dcl-pr restoreStatusMessage extproc('restoreStatusMessage') opdesc;
end-pr;

///
// Clear Status Message
//
// Clears (removes) the status message that is currently being
// displayed at the bottom of the screen.
//
// Example:
//   clearStatusMessage();
///
dcl-pr clearStatusMessage extproc('clearStatusMessage') opdesc;
end-pr;

///
// Get Member Type.
//
// Returns the source type of a given source member.
//
// Example:
//   srcType = getMemberType('QINCLUDE': 'RPGUNIT': 'ASSERT');
//
// @param Source file name
// @param Source file library
// @param Source file member name
//
// @return Source member type
///
dcl-pr getMemberType char(10) extproc('getMemberType') opdesc;
  srcFile     char(10) const;
  srcFileLib  char(10) const;
  mbr         char(10) const;
end-pr;

///
 // getStmfType -- Get Stream File Type.
 //
 // Returns the source type of a given stream file.
 //
 // Example:
 //   srcType = getStmfType('/home/dev/mypgm.rpgle');
//
// @param Stream file path
//
// @return Stream file type
///
dcl-pr getStmfType char(10) extproc('getStmfType') opdesc;
  srcStmf     like(ifsStmf_t) const;
end-pr;

///
// Set lowest (oldest) message key.
//
// Sets the message key of the oldest message in the job log, that
// is considered to be returned by getMonitoredMessage().
//
// This procedure is automatically called by the iRPGUnit, before
// executing a unit test. Use this procedure with care.
//
// Example:
//   setLowMessageKey(msgKey);
//
// @param Message key
///
dcl-pr setLowMessageKey extproc('setLowMessageKey') opdesc;
  msgKey  char(4) options(*nopass) const;
end-pr;

///
// ------------------------------------
//  Self-test procedures.
// ------------------------------------
///
dcl-pr clrAssertFailEvt extproc('clrAssertFailEvt');
end-pr;

dcl-pr getAssertCalled int(10) extproc('getAssertCalled');
end-pr;

dcl-pr getAssertFailEvt extproc('getAssertFailEvt')
       likeds(assertfailevt_t);
end-pr;

dcl-pr getAssertFailEvtLong extproc('getAssertFailEvtLong')
       likeds(assertFailEvtLong_t);
end-pr;

dcl-pr clearAssertCounter extproc('clearAssertCounter');
end-pr;

///
// ------------------------------------
//   Prototypes of internal procedures
// ------------------------------------
///
dcl-pr registerStartPgm extproc('ASSERT_registerStartPgm');
  lib             char(10) const;
  pgm             char(10) const;
end-pr;

///
// ------------------------------------
//   Prototypes of module VERSION
// ------------------------------------
///
dcl-pr getversion extproc('VERSION_getVersion');
  version         char(20);
  date            char(10);
end-pr;

///
// ------------------------------------------------------------------
//  V2 Prototypes
// ------------------------------------------------------------------
///

///
// Equality assertion
//
// Overloaded prorotype for
// assertEqual_numeric,
// assertEqual_float,
// assertEqual_date,
// assertEqual_time,
// assertEqual_timestamp
///
/if not defined(DISABLE_ASSERT_EQUAL)
dcl-pr assertEqual   overload(assertEqual_string
                           : assertEqual_numeric
                           : assertEqual_float
                           : assertEqual_date
                           : assertEqual_time
                           : assertEqual_timestamp);
//                           : assertEqual_ind);
/endif

///
// Aphanumeric Equality Assertion
//
// Compares the given String values 'expected' and 'actual'. The assertion
// fails, if both values are different.
//
// Example:
//   assertEqual( 'John Smith' : name );
//
// Message:
//   Expected 'John Smith', but was 'actual'.
//
// If parameter 'message' is specified that is appened to the log.
//
// @param Expected value
// @param Actual value
// @param Message (optional)
//
// @throws CPF9897 Expected '{expected}', but was '{actual}'.
///
dcl-pr assertEqual_string opdesc extproc('assertEqual_string');
  expected   like(assertString_t) options(*varsize) const;
  actual     like(assertString_t) options(*varsize) const;
  message    like(msgText_t) options(*nopass: *omit) const;
end-pr;

///
// Integer Equality Assertion
// Procedure disabled, because it is handled by: assertEqual_numeric
//
// Compares the given Integer values 'expected' and 'actual'. The assertion
// fails, if both values are different.
//
// Example:
//   assertEqual( 123 : intValue );
//
// Message:
//   Expected '123', but was 'actual'.
//
// If parameter 'message' is specified that is appened to the log.
//
// @param Expected value
// @param Actual value
// @param Message (optional)
//
// @throws CPF9897 Expected '{expected}', but was '{actual}'.
///
//dcl-pr assertEqual_integer opdesc extproc('assertEqual_integer');
//  expected   int(20) const;
//  actual     int(20) const;
//  message    like(msgText_t) options(*nopass: *omit) const;
//end-pr;

///
// Numeric Equality Assertion
//
// Compares the given Integer values 'expected' and 'actual'. The assertion
// fails, if both values are different.
//
// Example:
//   assertEqual( 123,45 : intValue );
//
// Message:
//   Expected '123,45', but was 'actual'.
//
// If parameter 'message' is specified that is appened to the log.
//
// @param Expected value
// @param Actual value
// @param Message (optional)
//
// @throws CPF9897 Expected '{expected}', but was '{actual}'.
///
dcl-pr assertEqual_numeric opdesc extproc('assertEqual_numeric');
  expected   zoned(63: 20) options(*exact) const;
  actual     zoned(63: 20) options(*exact) const;
  message    like(msgText_t) options(*nopass: *omit) const;
end-pr;

///
// Float Equality Assertion
//
// Compares the given float values 'expected' and 'actual'. The assertion
// fails, if both values are different.
//
// Example:
//   assertEqual( 123,45 : intValue );
//
// Message:
//   Expected '123,45', but was 'actual'.
//
// If parameter 'message' is specified that is appened to the log.
//
// @param Expected value
// @param Actual value
// @param Message (optional)
//
// @throws CPF9897 Expected '{expected}', but was '{actual}'.
///
dcl-pr assertEqual_float opdesc extproc('assertEqual_float');
  expected   float(8) options(*exact) const;
  actual     float(8) options(*exact) const;
  message    like(msgText_t) options(*nopass: *omit) const;
end-pr;

///
// Date Equality Assertion
//
// Compares the given date values 'expected' and 'actual'. The assertion
// fails, if both values are different.
//
// Example:
//   assertEqual( D'2024-09-16' : D'2023-01-11'  );
//
// Message:
//   Expected '2024-09-16', but was '2023-01-11'.
//
// If parameter 'message' is specified that is appened to the log.
//
// @param Expected value
// @param Actual value
// @param Message (optional)
//
// @throws CPF9897 Expected '{expected}', but was '{actual}'.
///
dcl-pr assertEqual_date opdesc extproc('assertEqual_date');
  expected   date const;
  actual     date const;
  message    like(msgText_t) options(*nopass: *omit) const;
end-pr;

///
// Time Equality Assertion
//
// Compares the given time values 'expected' and 'actual'. The assertion
// fails, if both values are different.
//
// Example:
//   assertEqual( T'11.22.33' : T'22.33.44'  );
//
// Message:
//   Expected '11.22.33', but was '22.33.44'.
//
// If parameter 'message' is specified that is appened to the log.
//
// @param Expected value
// @param Actual value
// @param Message (optional)
//
// @throws CPF9897 Expected '{expected}', but was '{actual}'.
///
dcl-pr assertEqual_time opdesc extproc('assertEqual_time');
  expected   time const;
  actual     time const;
  message    like(msgText_t) options(*nopass: *omit) const;
end-pr;

///
// Timestamp Equality Assertion
//
// Compares the given timestamp values 'expected' and 'actual'. The assertion
// fails, if both values are different.
//
// Example:
//   assertEqual( Z'2024-09-16-11.22.33.123456' : Z'2024-01-11-11.22.33.123456'  );
//
// Message:
//   Expected '2024-09-16-11.22.33.123456', but was '2024-01-11-11.22.33.123456'.
//
// If parameter 'message' is specified that is appened to the log.
//
// @param Expected value
// @param Actual value
// @param Message (optional)
//
// @throws CPF9897 Expected '{expected}', but was '{actual}'.
///
dcl-pr assertEqual_timestamp opdesc extproc('assertEqual_timestamp');
  expected   timestamp(12) const;
  actual     timestamp(12) const;
  message    like(msgText_t) options(*nopass: *omit) const;
end-pr;

dcl-pr assertEqual_ind opdesc extproc('assertEqual_ind');
  expected   ind options(*exact) const;
  actual     ind options(*exact) const;
  message    like(msgText_t) options(*nopass: *omit) const;
end-pr;

///
// Asserts that 'actual' satisfies the condition specified by matcher.
//
// Calls the 'matcher' for comparing 'actual. The assertion fails if the 'mathcer'
// return 'false'.
//
// Example:
//   assertThat( actual : %paddr('matcher') : pUserData );
//
// Message:
//   ???
//
// If parameter 'message' is specified that is appened to the log.
//
// @param Expected value
// @param Actual value
// @param Pointer to matcher procedure
// @param Message (optional)
//
// @throws CPF9897 Expected '{expected}', but was '{actual}'.
///
dcl-pr assertThat opdesc extproc('assertThat');
  expected   pointer const;
  actual     pointer const;
  matcher    pointer(*proc) const;
  message    like(msgText_t) options(*nopass: *omit) const;
end-pr;

dcl-s pMatcher_t pointer(*proc);
dcl-pr matcher_t ind extproc(pMatcher_t);
  expected   pointer const;
  actual     pointer const;
  message    like(msgText_t) options(*nopass);
end-pr;

/endif
