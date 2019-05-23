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


      // ------------------------------------
      //  Assertions of module ASSERT.
      // ------------------------------------


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

     D aEqual          pr                  extproc('+
     D                                     aEqual+
     D                                     ')
     D  expected                  32565a   const
     D  actual                    32565a   const
     D  fieldName                    64a   const varying options(*nopass: *omit)


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

     D iEqual          pr                  extproc('+
     D                                     iEqual+
     D                                     ')
     D  expected                     31s 0 const
     D  actual                       31s 0 const
     D  fieldName                    64a   const varying options(*nopass: *omit)


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

     D nEqual          pr                  extproc('+
     D                                     nEqual+
     D                                     ')
     D  expected                       n   const
     D  actual                         n   const
     D  fieldName                    64a   const varying options(*nopass: *omit)


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

     D assert          pr                  extproc('+
     D                                     assert+
     D                                     ')
     D  condition                      n   const
      /if defined(RPGUNIT_INTERNAL)
     D  msgIfFalse                  256a   const
      /else
     D  msgIfFalse                16384a   const varying options(*Varsize)
      /endif


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

     D assertJobLogContains...
     D                 pr                  extproc('+
     D                                     assertJobLogContains+
     D                                     ')
     D  msgId                         7a   const
     D  timeLimit                      z   const


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

     D fail            pr                  extproc('+
     D                                     fail+
     D                                     ')
      /if defined(RPGUNIT_INTERNAL)
     D  msg                         256a   const
      /else
     D  msg                       16384a   const varying options(*Varsize)
      /endif


      // ------------------------------------
      //  CL Commands of module TESTUTILS.
      // ------------------------------------


      // clrpfm -- Clear Physical File
      //
      // Uses CLRPFM to remove the data from 'member' of file 'file'.
      // The file must be stored in *CURLIB.

     D clrpfm          pr                  extproc('+
     D                                     CLRPFM+
     D                                     ')
        // A file name.
     D  w1fileNm                     10a   const
        // An (optional) member name.
     D  w1mbrNm                      10a   const options(*NoPass)


      // rclactgrp -- Reclaim Activation Group
      //
      // Uses RCLACTGRP to reclaim the activation group specified at
      // parameter 'activationGroup'.
      //
      // Example:
      //   rclactgrp( '*ELIGIBLE' );

     D rclactgrp       pr                  extproc('+
     D                                     RCLACTGRP+
     D                                     ')
     D  w1actGrpNm                   10a   const


      // runCmd -- Run CL Command
      //
      // Uses the QCMDEXC API to execute the CL command specified at
      // parameter command.
      //
      // Example:
      //   runCmd( 'ALCOBJ OBJ((*CURLIB/FILE *FILE *EXCL))' );

     D runCmd          pr                  extproc('+
     D                                     runCmd+
     D                                     ')
     D  w1cmd                     32702a   const varying


      // waitSeconds -- Wait Seconds
      //
      // Suspends the current job for a specified number of seconds.
      // Optionally displays a status message. When the job resumes
      // the originally status message is restored.
      //
      // Example:
      //   waitSeconds(3 : 'Waiting 3 seconds ...');

     D waitSeconds     pr                  extproc('+
     D                                     waitSeconds+
     D                                     ')
        // Wait time in seconds
     D  seconds                      10i 0 const
        // Optional. Message sent to *EXT
     D  message                      50a   const varying options(*nopass: *omit)


      // displayStatusMessage -- Display Status Message
      //
      // Displays a given status message in the status line at the bottom of
      // the screen.
      //
      // Example:
      //   displayStatusMessage('Hello World!');

     D displayStatusMessage...
     D                 pr                  extproc('+
     D                                     displayStatusMessage+
     D                                     ')
        // Optional. Message sent to *EXT
     D  message                     132a   const varying


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

     D restoreStatusMessage...
     D                 pr                  extproc('+
     D                                     restoreStatusMessage+
     D                                     ')


      // clearStatusMessage -- Clear Status Message
      //
      // Clears (removes) the status message that is currently being
      // displayed at the bottom of the screen.
      //
      // Example:
      //   clearStatusMessage();

     D clearStatusMessage...
     D                 pr                  extproc('+
     D                                     clearStatusMessage+
     D                                     ')


      // getMonitoredMsg -- Get Monitored Message.
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
      //     msgInfo = getMonitoredMsg(*ON); // remove message
      //   endmon;                           // from job log
      //
      //   aEqual( 'MCH1211': msgInfo.Id );

     D getMonitoredMessage...
     D                 pr                  likeds(MsgInfo_t)
     D                                     extproc('+
     D                                     getMonitoredMessage+
     D                                     ')
     D  doRmvMsg                       n   const options(*nopass)

     D MsgInfo_t       ds                  qualified based(template)
     D  id                            7a
     D  txt                         256a   varying
     D  pgm                          10a
     D  mod                          10a
     D  proc                        256a   varying
     D  specNb                       10a


      // getFullTimeStamp -- Get Full Timestamp
      //
      // Returns the full current timestamp, without rounding the
      // microseconds like %timestamp() does.
      //
      // Example:
      //   tmStmp = getFullTimeStamp();

     D getFullTimeStamp...
     D                 pr              z   extproc('+
     D                                     getFullTimeStamp+
     D                                     ')


      // getMemberType -- Get Member Type.
      //
      // Returns the source type of a given source member.
      //
      // Example:
      //   srcType = getMemberType('QSRC': 'TOOLS400': 'RUWSCST');

     D getMemberType...
     D                 pr            10a
     D                                     extproc('+
     D                                     getMemberType+
     D                                     ')
     D  srcFile                      10a   const
     D  srcFileLib                   10a   const
     D  mbr                          10a   const


      // setLowMessageKey -- Set lowest (oldest) message key.
      //
      // Sets the message key of the oldest message in the job log, that
      // is considered to be returned by getMonitoredMessage().
      //
      // This procedure is automatically called by the iRPGUnit, before
      // executing a unit test.
      //
      // Example:
      //   setLowMessageKey(msgKey);

     D setLowMessageKey...
     D                 pr                  extproc('+
     D                                     setLowMessageKey+
     D                                     ')
     D  msgKey                        4a   const

      /endif
