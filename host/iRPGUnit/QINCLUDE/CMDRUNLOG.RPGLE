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
     D lineFeed        pr                  extproc('CMDRUNLOG_+
     D                                     lineFeed+
     D                                     ')

       // Log the test run completion message.
     D logCompMsg      pr                  extproc('CMDRUNLOG_+
     D                                     logCompMsg+
     D                                     ')
     D  msg                       16384a   const varying options(*Varsize)
     D  failures                     10i 0 const
     D  errors                       10i 0 const

       // Log a test error event.
     D logError        pr                  extproc('CMDRUNLOG_+
     D                                     logError+
     D                                     ')
     D  testNm                             const like(ProcNm_t)
     D  excpMsgInfo                        const likeds(Msg_t)

       // Log a test failure event.
     D logFailure      pr                  extproc('CMDRUNLOG_+
     D                                     logFailure+
     D                                     ')
     D  testNm                             const like(ProcNm_t)
     D  failure                            const likeds(AssertFailEvtLong_t)

       // Log a test success event.
     D logSuccess      pr                  extproc('CMDRUNLOG_+
     D                                     logSuccess+
     D                                     ')
     D  testNm                             const like(ProcNm_t)
     D  assertionCnt                 10i 0 const

       // Print a call stack entry.
     D logStackEntry   pr                  extproc('CMDRUNLOG_+
     D                                     logStackEntry+
     D                                     ')
     D  sender                             const likeds(MsgSender_t)

       // Log runtime error.
     D logRuntimeError...
     D                 pr                  extproc('CMDRUNLOG_+
     D                                     logRuntimeError+
     D                                     ')
     D  line                       2048a   const varying options(*varsize)

       // Formats a call stack entry.
     D fmtStackEntry   pr                  like(Line_t)
     D                                     extproc('CMDRUNLOG_+
     D                                     fmtStackEntry+
     D                                     ')
     D  sender                             const likeds(MsgSender_t)

       // Log library list.
     D logLibraryList...
     D                 pr
     D                                     extproc('CMDRUNLOG_+
     D                                     logLibraryList+
     D                                     ')
     D  libraryList                        const likeds(LiblData_t)

       // Set the logging context.
     D setLogContext   pr                  extproc('CMDRUNLOG_+
     D                                     setLogContext+
     D                                     ')
        // Name of the test service program being run.
     D  testPgm                            const likeds(Object_t)
     D  detail                       10a   const
     D  output                       10a   const

       // Log a raw line (no header, no automatic opening / closing).
     D logRawLine      pr                  extproc('CMDRUNLOG_+
     D                                     logRawLine+
     D                                     ')
     D  line                       2048a   Value varying

       // Returns the name of the current log spooled file.
     D getLogSplF      pr                  extproc('CMDRUNLOG_+
     D                                     getLogSplF+
     D                                     ')
     D                                     likeds(SplF_t)

