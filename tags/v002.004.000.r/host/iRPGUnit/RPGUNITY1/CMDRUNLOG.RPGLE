      //
      // Prototypes for RPGUnit command line runner logging facilities.
      //

       // Linefeed.
     D lineFeed        pr

       // Log the test run completion message.
     D logCompMsg      pr
     D  msg                       16384a   const varying options(*Varsize)
     D  failures                     10i 0 const
     D  errors                       10i 0 const

       // Log a test error event.
     D logError        pr
     D  testNm                             const like(ProcNm_t)
     D  excpMsgInfo                        const likeds(Msg_t)

       // Log a test failure event.
     D logFailure      pr
     D  testNm                             const like(ProcNm_t)
     D  failure                            const likeds(AssertFailEvtLong_t)

       // Log a test success event.
     D logSuccess      pr
     D  testNm                             const like(ProcNm_t)
     D  assertionCnt                 10i 0 const

       // Print a call stack entry.
     D logStackEntry   pr
     D  sender                             const likeds(MsgSender_t)

       // Formats a call stack entry.
     D fmtStackEntry   pr                  like(Line_t)
     D  sender                             const likeds(MsgSender_t)

       // Set the logging context.
     D setLogContext   pr
        // Name of the test service program being run.
     D  testPgm                            const likeds(Object_t)
     D  detail                       10a   const
     D  output                       10a   const

       // Log a raw line (no header, no automatic opening / closing).
     D logRawLine      pr
     D  line                       2048a   Value varying

       // Returns the name of the current log spooled file.
     D getLogSplF      pr                  extproc('getLogSplF')
     D                                     likeds(SplF_t)

