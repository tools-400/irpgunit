**free
 /if not defined (IRPGUNIT_TESTCASE)
 /define IRPGUNIT_TESTCASE
 // ==========================================================================
 //  iRPGUnit - Public API.
 // ==========================================================================
 //  Copyright (c) 2013-2019 iRPGUnit Project Team
 //  All rights reserved. This program and the accompanying materials
 //  All rights reserved. This program and the accompanying materials
 //  are made available under the terms of the Common Public License v1.0
 //  which accompanies this distribution, and is available at
 //  http://www.eclipse.org/legal/cpl-v10.html
 // ==========================================================================

/include qinclude,TEMPLATES

 // ------------------------------------
 //  Assertions of module ASSERT.
 // ------------------------------------


 // Cobol enabled.
 // aEqual -- Aphanumeric Equality Assertion
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

dcl-pr aEqual extproc('aEqual') opdesc;
  expected    char(32565) const;
  actual      char(32565) const;
 /if defined(RPGUNIT_INTERNAL)
  fieldName   char(64) options(*nopass: *omit) const;
 /else
  fieldName   varchar(64) options(*nopass: *omit) const;
 /endif
end-pr;


 // iEqual -- Integer Equality Assertion
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

dcl-pr iEqual extproc('iEqual') opdesc;
  expected   zoned(31: 0) const;
  actual     zoned(31: 0) const;
  fieldName  varchar(64) options(*nopass: *omit) const;
end-pr;


 // nEqual -- Boolean Equality Assertion
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

dcl-pr nEqual extproc('nEqual') opdesc;
  expected   ind const;
  actual     ind const;
  fieldName  varchar(64) options(*nopass: *omit) const;
end-pr;


 // Cobol enabled.
 // assert -- General Purpose Assertion
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

dcl-pr assert extproc('assert') opdesc;
  condition  ind const;
 /if defined(RPGUNIT_INTERNAL)
  msgIfFalse like(OldMsg_t) options(*nopass) const;
 /else
  msgIfFalse varchar(16384) options(*varsize: *nopass) const;
 /endif
end-pr;


 // Cobol enabled.
 // fail -- Fail test
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
 // Messages:
 //   PGM should have thrown an exception

dcl-pr fail extproc('fail') opdesc;
 /if defined(RPGUNIT_INTERNAL)
  msg        like(OldMsg_t) options(*nopass) const;
 /else
  msg        varchar(16384) options(*varsize: *nopass) const;
 /endif
end-pr;


 // getMonitoredMessage -- Get Monitored Message.
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


 // assertJobLogContains -- General Purpose Assertion
 //
 // Checks whether the job log contains the specified message ID between
 // NOW and 'timeLimit'.
 //
 // Examples:
 //   assertJobLogContains( 'MCH1211' : %timestamp() - %minutes(2) );
 //
 // Messages:
 //   Message 'msgId' not found in the job log.

dcl-pr assertJobLogContains extproc('assertJobLogContains') opdesc;
  msgId      char(7) const;
  timeLimit  timestamp const;
end-pr;


 // assertMessageQueueContains -- General Purpose Assertion
 //
 // Checks whether a given message queue contains the specified message ID between
 // NOW and 'timeLimit'.
 //
 // Examples:
 //   assertMessageQueueContains( 'MCH1211' : %timestamp() - %minutes(2) );
 //
 // Messages:
 //   Message 'msgId' not found in the job log.

dcl-pr assertMessageQueueContains extproc('assertMessageQueueContains') opdesc;
  userOrQueue  char(10) const;
  library      char(10) options(*omit) const;
  msgId        char(7) options(*omit) const;
  msgText      varchar(132) options(*omit) const;
  msgHelp      varchar(256) options(*omit) const;
  timeLimit    timestamp const;
end-pr;


 // ------------------------------------
 //  CL Commands of module TESTUTILS.
 // ------------------------------------


 // getFullTimeStamp -- Get Full Timestamp
 //
 // Returns the full current timestamp, without rounding the
 // microseconds like %timestamp() does.
 //
 // Example:
 //   tmStmp = getFullTimeStamp();

dcl-pr getFullTimeStamp timestamp extproc('getFullTimeStamp') opdesc;
end-pr;


 // clrpfm -- Clear Physical File
 //
 // Uses CLRPFM to remove the data from 'member' of file 'file'.
 // The file must be stored in *CURLIB.

dcl-pr clrpfm extproc('CLRPFM') opdesc;
   // A file name.
  w1fileNm  char(10) const;
   // An (optional) member name.
  w1mbrNm   char(10) options(*NoPass) const;
end-pr;


 // rclactgrp -- Reclaim Activation Group
 //
 // Uses RCLACTGRP to reclaim the activation group specified at
 // parameter 'activationGroup'.
 //
 // Example:
 //   rclactgrp( '*ELIGIBLE' );

dcl-pr rclactgrp extproc('RCLACTGRP') opdesc;
  w1actGrpNm  char(10) const;
end-pr;


 // runCmd -- Run CL Command
 //
 // Uses the QCMDEXC API to execute the CL command specified at
 // parameter command.
 //
 // Example:
 //   runCmd( 'ALCOBJ OBJ((*CURLIB/FILE *FILE *EXCL))' );

dcl-pr runCmd extproc('runCmd') opdesc;
  w1cmd  varchar(32702) const;
end-pr;


 // waitSeconds -- Wait Seconds
 //
 // Suspends the current job for a specified number of seconds.
 // Optionally displays a status message. When the job resumes
 // the originally status message is restored.
 //
 // Example:
 //   waitSeconds(3 : 'Waiting 3 seconds ...');

dcl-pr waitSeconds extproc('waitSeconds') opdesc;
   // Wait time in seconds
  seconds  int(10) const;
   // Optional. Message sent to *EXT
  message  varchar(50) options(*nopass: *omit) const;
end-pr;


 // displayStatusMessage -- Display Status Message
 //
 // Displays a given status message in the status line at the bottom of
 // the screen.
 //
 // Example:
 //   displayStatusMessage('Hello World!');

dcl-pr displayStatusMessage extproc('displayStatusMessage') opdesc;
   // Optional. Message sent to *EXT
  message  varchar(132) const;
end-pr;


 // restoreStatusMessage -- Restore Status Message
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

dcl-pr restoreStatusMessage extproc('restoreStatusMessage') opdesc;
end-pr;


 // clearStatusMessage -- Clear Status Message
 //
 // Clears (removes) the status message that is currently being
 // displayed at the bottom of the screen.
 //
 // Example:
 //   clearStatusMessage();

dcl-pr clearStatusMessage extproc('clearStatusMessage') opdesc;
end-pr;


 // getMemberType -- Get Member Type.
 //
 // Returns the source type of a given source member.
 //
 // Example:
 //   srcType = getMemberType('QINCLUDE': 'RPGUNIT': 'ASSERT');

dcl-pr getMemberType char(10) extproc('getMemberType') opdesc;
  srcFile     char(10) const;
  srcFileLib  char(10) const;
  mbr         char(10) const;
end-pr;


 // setLowMessageKey -- Set lowest (oldest) message key.
 //
 // Sets the message key of the oldest message in the job log, that
 // is considered to be returned by getMonitoredMessage().
 //
 // This procedure is automatically called by the iRPGUnit, before
 // executing a unit test. Use this procedure with care.
 //
 // Example:
 //   setLowMessageKey(msgKey);

dcl-pr setLowMessageKey extproc('setLowMessageKey') opdesc;
  msgKey  char(4) options(*nopass) const;
end-pr;

 // ------------------------------------------------------------------
 //  V2 Prototypes
 // ------------------------------------------------------------------

dcl-pr assertEqual overload(assertEqual_string
                           : assertEqual_numeric
                           : assertEqual_float
                           : assertEqual_date
                           : assertEqual_time
                           : assertEqual_timestamp);
//                           : assertEqual_ind);

// assertEqual -- Aphanumeric Equality Assertion
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
dcl-pr assertEqual_string opdesc extproc('assertEqual_string');
  expected   like(assertString_t) options(*varsize) const;
  actual     like(assertString_t) options(*varsize) const;
  message    like(msgText_t) options(*nopass: *omit) const;
end-pr;


// assertEqual -- Integer Equality Assertion
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
//dcl-pr assertEqual_integer opdesc extproc('assertEqual_integer');
//  expected   int(20) const;
//  actual     int(20) const;
//  message    like(msgText_t) options(*nopass: *omit) const;
//end-pr;


// assertEqual -- Numeric Equality Assertion
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
dcl-pr assertEqual_numeric opdesc extproc('assertEqual_numeric');
  expected   zoned(63: 20) options(*exact) const;
  actual     zoned(63: 20) options(*exact) const;
  message    like(msgText_t) options(*nopass: *omit) const;
end-pr;


// assertEqual -- Float Equality Assertion
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
dcl-pr assertEqual_float opdesc extproc('assertEqual_float');
  expected   float(8) options(*exact) const;
  actual     float(8) options(*exact) const;
  message    like(msgText_t) options(*nopass: *omit) const;
end-pr;

// assertEqual -- Date Equality Assertion
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
dcl-pr assertEqual_date opdesc extproc(*dclcase);
  expected   date const;
  actual     date const;
  message    like(msgText_t) options(*nopass: *omit) const;
end-pr;

// assertEqual -- Time Equality Assertion
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
dcl-pr assertEqual_time opdesc extproc(*dclcase);
  expected   time const;
  actual     time const;
  message    like(msgText_t) options(*nopass: *omit) const;
end-pr;

// assertEqual -- Timestamp Equality Assertion
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
dcl-pr assertEqual_timestamp opdesc extproc(*dclcase);
  expected   timestamp(12) const;
  actual     timestamp(12) const;
  message    like(msgText_t) options(*nopass: *omit) const;
end-pr;

dcl-pr assertEqual_ind opdesc extproc(*dclcase);
  expected   ind options(*exact) const;
  actual     ind options(*exact) const;
  message    like(msgText_t) options(*nopass: *omit) const;
end-pr;

// assertThat -- Asserts that 'actual' satisfies the condition specified by matcher.
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
