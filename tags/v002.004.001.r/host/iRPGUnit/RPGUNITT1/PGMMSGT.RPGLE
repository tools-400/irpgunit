      // =====================================================================
      //
      // Tests PGMMSG.
      //
      // =====================================================================
      //   >>PRE-COMPILER<<
      //     >>CMD<<    CRTBNDCL   PGM(QTEMP/MKPGMMSGT) SRCFILE(&SF);
      //     >>CMD<<    CALL       PGM(QTEMP/MKPGMMSGT) PARM(&LI);
      //   >>END-PRE-COMPILER<<
      // =====================================================================

     H NoMain Option(*SrcStmt)


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,ERRORCODE
      /copy RPGUNITY1,PGMMSG
      /copy RPGUNITY1,TEMPLATES
      /copy RPGUNIT1,TESTCASE


      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D test_rcvExcpMsgInfo...
     D                 pr                  extproc('test_rcvExcpMsgInfo')
     D test_sndEscapeMsgToCaller...
     D                 pr                  extproc('test_sndEscapeMsgToCaller')
     D test_resendEscapeMsg...
     D                 pr                  extproc('test_resendEscapeMsg')
     D test_monitorMessage...
     D                 pr                  extproc('test_monitorMessage')


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

     D callSndEscapeMsgToCaller...
     D                 pr                  extproc('callSndEscapeMsgToCaller')
     D monitorEscapeMsgAndResendIt...
     D                 pr                  extproc('monitorEscapeMsgAndResendIt+
     D                                     ')
     D procWithError...
     D                 pr            10i 0 extproc('procWithError')


      //----------------------------------------------------------------------
      //   Helper Procedures Definitions
      //----------------------------------------------------------------------

     P callSndEscapeMsgToCaller...
     P                 b
     D callSndEscapeMsgToCaller...
     D                 pi
      /free

        sndEscapeMsgToCaller( 'Dummy error message' );

      /end-free
     P callSndEscapeMsgToCaller...
     P                 e


     P monitorEscapeMsgAndResendIt...
     P                 b
     D monitorEscapeMsgAndResendIt...
     D                 pi
      /free

        monitor;
          procWithError();
        on-error;
          resendEscapeMsg( LAST_NEW_ESCAPE_MSG : percolateErrors );
        endmon;

      /end-free
     P                 e


     P procWithError   b
     D procWithError   pi            10i 0
     D  zero           s             10i 0 inz(0)
      /free

        return (1 / zero);

      /end-free
     P procWithError   e


      //----------------------------------------------------------------------
      //   Test Procedure Definitions
      //----------------------------------------------------------------------

     P test_rcvExcpMsgInfo...
     P                 b                   export
     D test_rcvExcpMsgInfo...
     D                 pi

     D excpMsgInfo     ds                  likeds(Msg_t)

      /free

        monitor;
          procWithError();
          fail( 'procWithError() did not raise an error.' );

        on-error;
          // Success.
        endmon;

        excpMsgInfo = rcvExcpMsgInfo();

        aEqual( 'MCH1211': excpMsgInfo.Id );
        assert( excpMsgInfo.txt <> *blank : 'Exception message not retrieved' );
            // We should be checking the message content, but I do not know how to
            // do that, since it depends on the locale.
        aEqual( 'PGMMSGT': excpMsgInfo.sender.qPgm.nm );
        aEqual( 'procWithError': excpMsgInfo.sender.procNm );
        aEqual( '9000': excpMsgInfo.sender.specNb );

      /end-free
     P                 e


     P test_sndEscapeMsgToCaller...
     P                 b                   export
     D test_sndEscapeMsgToCaller...
     D                 pi

     D excpMsgInfo     ds                  likeds(Msg_t)

      /free

        monitor;
          callSndEscapeMsgToCaller();
          fail( 'sndEscapeMsgToCaller() did not raise an exception.' );

        on-error;
          // Success.
        endmon;

        excpMsgInfo = rcvExcpMsgInfo();

        aEqual( 'Dummy error message' : excpMsgInfo.txt );

      /end-free
     P test_sndEscapeMsgToCaller...
     P                 e


     P test_resendEscapeMsg...
     P                 b                   export
     D test_resendEscapeMsg...
     D                 pi

     D resentMsgSeen   s               n
     D msg             ds                  likeds(Msg_t)

      /free

        monitor;
          monitorEscapeMsgAndResendIt();
          resentMsgSeen = *off;
        on-error;
          resentMsgSeen = *on;
        endmon;

        assert( resentMsgSeen : 'Resent msg not seen' );
        msg = rcvPgmMsg( '*ESCAPE' );
        aEqual( 'MCH1211' : msg.id );

      /end-free
     P                 e


     P test_monitorMessage...
     P                 b                   export
     D                 pi

     D msgInfo         ds                  likeds(MsgInfo_t)
     D msgInfo2        ds                  likeds(MsgInfo_t)
     D msgInfo3        ds                  likeds(MsgInfo_t)
     D a               s             10i 0
     D b               s             10i 0
     D c               s             10i 0

      /free

         monitor;
           a = 10;
           b = 0;     // Attempt made to divide by zero for
           c = a / b; // fixed point operation. (MCH1211)
           fail( 'Division by zero did not raise an error.' );
         on-error;
           msgInfo = getMonitoredMessage();
         endmon;

         aEqual( 'MCH1211': msgInfo.Id );

         // receive message info again
         // and remove message
         msgInfo2 = getMonitoredMessage(*ON);
         assert(msgInfo = msgInfo2: 'Message info values must match');

         // try to receive it a third time
         msgInfo3 = getMonitoredMessage();
         assert(msgInfo3.id     = '' and
                msgInfo3.txt    = '' and
                msgInfo3.pgm    = '' and
                msgInfo3.mod    = '' and
                msgInfo3.proc   = '' and
                msgInfo3.specNb = ''
                : 'Message MCH1211 must habe been removed +
                   from the job log');


        monitor;
          procWithError();
          fail( 'procWithError() did not raise an error.' );
        on-error;
          msgInfo = getMonitoredMessage();
        endmon;

        aEqual( 'MCH1211': msgInfo.Id );
        assert( msgInfo.txt <> *blank : 'Exception message not retrieved' );
            // We should be checking the message content, but I do not know how to
            // do that, since it depends on the locale.
        aEqual( 'PGMMSGT': msgInfo.pgm );
        aEqual( 'procWithError': msgInfo.proc );
        aEqual( '9000': msgInfo.specNb );

      /end-free
     P                 e
