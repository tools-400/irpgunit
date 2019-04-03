      // >>PRE-COMPILER<<
      //   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) +
      //                 SRCMBR(&SM);
      //   >>IMPORTANT<<
      //     >>PARM<<  OPTION(*EVENTF);
      //     >>PARM<<  DBGVIEW(*LIST);
      //   >>END-IMPORTANT<<
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<

      //
      // Extracts message info.
      //

     H NoMain
      /copy RPGUNITY1,H_SPEC

      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,PGMMSG


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,ERRORCODE
      /copy RPGUNITY1,QMHRCVPM
      /copy RPGUNITY1,QMHSNDPM
      /copy RPGUNITY1,TEMPLATES


      //----------------------------------------------------------------------
      //   Global Fields
      //----------------------------------------------------------------------

     D g_status        ds                  qualified
     D  lastStsMsg                  256a   inz


      //----------------------------------------------------------------------
      //   Procedure Definitions
      //----------------------------------------------------------------------

     P rcvExcpMsgInfo...
     P                 b                   export
     D                 pi                  likeds(Msg_t)

     D  msg            ds                  likeds(Msg_t)

      /free

        msg = rcvPgmMsg( '*EXCP' : ONE_CALL_STK_LVL_ABOVE );

        return msg;

      /end-free
     P                 e


     P rcvMsgData...
     P                 b                   export
     D                 pi           256a
     D msgType                       10a   const

     D msg             ds                  likeds(Msg_t)

      /free

        msg = rcvPgmMsg( msgType : ONE_CALL_STK_LVL_ABOVE );
        return msg.rplData;

      /end-free
     P                 e


     P rcvMsgTxt...
     P                 b                   export
     D                 pi           256a
     D msgType                       10a   const

     D msg             ds                  likeds(Msg_t)

      /free

        msg = rcvPgmMsg( msgType : ONE_CALL_STK_LVL_ABOVE );
        return msg.txt;

      /end-free
     P                 e


     P rcvPgmMsg...
     P                 b                   export
     D                 pi                  likeds(Msg_t)
     D  msgType                      10a   const
     D  callStkCnt                   10i 0 const options(*NoPass)

       // Safe value for the NoPass parameter callStkCnt.
     D safeCallStkCnt  s                   like(callStkCnt)
       // Buffer for message info.
     D rawMsgBuf       s          32767a
     D rawMsgHdr       ds                  likeds(RCVM0300Hdr)
     D                                     based(rawMsgHdr_p)
     D rawMsgHdr_p     s               *
       // Position in buffer (starting at 1).
     D bufPos          s             10i 0
       // Buffer for message sender info.
     D senderInfo      ds                  likeds(RCVM0300Sender)
     D                                     based(senderInfo_p)
     D senderInfo_p    s               *
       // The received message.
     D msg             ds                  likeds(Msg_t)

      /free

        if %parms() > 1;
          safeCallStkCnt = callStkCnt;
        else;
          safeCallStkCnt = 0;
        endif;

        QMHRCVPM( rawMsgBuf :
                  %size(rawMsgBuf) :
                  ALL_MSG_INFO_WITH_SENDER_INFO :
                  THIS_CALL_STK_ENT :
                  ONE_CALL_STK_LVL_ABOVE + safeCallStkCnt :
                  msgType :
                  NO_MSG_KEY :
                  NO_WAIT :
                  MARK_AS_OLD :
                  percolateErrors );

        rawMsgHdr_p = %addr( rawMsgBuf );

        if (rawMsgHdr.bytesA = 0);
          sndEscapeMsgToCaller( %trim(msgType) + ' message not found' );
        endif;

        msg.id = rawMsgHdr.msgId;

        bufPos = %size(rawMsgHdr) + 1;
        msg.rplData = %subst( rawMsgBuf :
                              bufPos :
                              rawMsgHdr.rplDataLenR );

        bufPos += rawMsgHdr.rplDataLenR;
        msg.txt = %subst( rawMsgBuf :
                          bufPos :
                          rawMsgHdr.msgLenR );

        bufPos += rawMsgHdr.msgLenR;
        bufPos += rawMsgHdr.msgHlpLenR;
        senderInfo_p = %addr(rawMsgBuf) + bufPos - 1;
        msg.sender.qPgm.nm = senderInfo.sndPgmNm;
        msg.sender.qPgm.lib = '*N';
        msg.sender.qMod.nm = senderInfo.sndModNm;
        msg.sender.qMod.lib = '*N';
        msg.sender.procNm = senderInfo.sndProcNm;
        msg.sender.specNb = senderInfo.sndPgmSttNb(1);

        return msg;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Send a completion message. See prototype.
       //----------------------------------------------------------------------
     P sndCompMsg...
     P                 b                   export
     D                 pi
     D  msg                         256a   const

       // The message reference key.
     D msgKey          s              4a

      /free

        QMHSNDPM( 'CPDA0FF' :
                  'QCPFMSG   *LIBL' :
                  %trimr(msg) :
                  %len(%trimr(msg)) :
                  '*COMP' :
                  CONTROL_BOUNDARY :
                  ONE_CALL_STK_LVL_ABOVE :
                  msgKey :
                  percolateErrors );

      /end-free
     P                 e


     P sndEscapeMsg...
     P                 b                   export
     D                 pi
     D  msg                         256a   const
     D  callStkCnt                   10i 0 const

       // The message reference key.
     D msgKey          s              4a

      /free

        QMHSNDPM( 'CPF9897' :
                  'QCPFMSG   *LIBL' :
                  %trimr(msg) :
                  %len(%trimr(msg)) :
                  '*ESCAPE' :
                  CUR_CALL_STK_ENT :
                  ONE_CALL_STK_LVL_ABOVE + callStkCnt :
                  msgKey :
                  percolateErrors );

      /end-free
     P                 e


     P sndEscapeMsgToCaller...
     P                 b                   export
     D                 pi
     D  msg                         256a   const
      /free

        sndEscapeMsg( msg : TWO_CALL_STK_LVL_ABOVE );

      /end-free
     P                 e


     P sndEscapeMsgAboveCtlBdy...
     P                 b                   export
     D                 pi
     D  msg                         256a   const

       // The message reference key.
     D msgKey          s              4a
      /free

        QMHSNDPM( 'CPF9897' :
                  'QCPFMSG   *LIBL' :
                  %trimr(msg) :
                  %len(%trimr(msg)) :
                  '*ESCAPE' :
                  CONTROL_BOUNDARY :
                  ONE_CALL_STK_LVL_ABOVE :
                  msgKey :
                  percolateErrors );

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Send an information message. See prototype.
       //----------------------------------------------------------------------
     P sndInfoMsg...
     P                 b                   export
     D                 pi
     D  msg                         256a   const

       // The message reference key.
     D msgKey          s              4a

      /free

        QMHSNDPM( '' :
                  'QCPFMSG   *LIBL' :
                  %trimr(msg) :
                  %len(%trimr(msg)) :
                  '*INFO' :
                  CUR_CALL_STK_ENT :
                  ONE_CALL_STK_LVL_ABOVE :
                  msgKey :
                  percolateErrors );

      /end-free
     P                 e


     P sndStsMsg...
     P                 b                   export
     D                 pi
     D  msg                         256a   const

       // The message reference key.
     D msgKey          s              4a

      /free

        g_status.lastStsMsg = msg;

        QMHSNDPM( 'CPDA0FF' :
                  'QCPFMSG   *LIBL' :
                  %trimr(msg) :
                  %len(%trimr(msg)) :
                  '*STATUS' :
                  '*EXT' :
                  *zero :
                  msgKey :
                  percolateErrors );

      /end-free
     P                 e


     P rstStsMsg...
     P                 b                   export
     D                 pi

      /free

         sndStsMsg(g_status.lastStsMsg);

      /end-free
     P                 e


     P getHighestMsgKey...
     P                 b                   export
     D                 pi             4a

       // The message reference key.
     D msg             s            128a   varying inz('getHighestMsgKey')
     D msgKey          s              4a
     D rawMsgBuf       ds                  qualified
     D  bytRet                       10i 0
     D  bytAvl                       10i 0
      /free

         QMHSNDPM( '':
                   'QCPFMSG   *LIBL' :
                   msg :
                   %len(msg) :
                   '*INFO' :
                   CUR_CALL_STK_ENT :
                   THIS_CALL_STK_LVL :
                   msgKey :
                   percolateErrors );

        QMHRCVPM( rawMsgBuf :
                  %size(rawMsgBuf) :
                  EXTENDED_MSG_INFO :
                  THIS_CALL_STK_ENT :
                  THIS_CALL_STK_LVL :
                  '*INFO' :
                  msgKey :
                  NO_WAIT :
                  REMOVE_MSG :
                  percolateErrors );

         return msgKey;

      /end-free
     P                 e


     P getLatestEscMsg...
     P                 b                   export
     D                 pi                  likeds(Msg_t)
     D  lowMsgKey                     4a   Value
     D  doRmvMsg                       n   Value

     D msg             ds                  likeds(Msg_t)

       // The message reference key.
     D rplData         s            128a   varying
     D lowKey          s             10i 0 based(pLowKey)
     D highMsgKey      ds
     D  highKey                      10i 0
     D rawMsgBuf       s           1024a
     D rcvm0300        ds                  likeds(RCVM0300Hdr)
     D                                     based(pRcvm0300)
     D pRcvm0300       s               *   inz(%addr(rawMsgBuf))
     D senderInfo      ds                  likeds(RCVM0300Sender)
     D                                     based(senderInfo_p)
     D msgOffs         s             10i 0
     D msgLen          s             10i 0
     D action          s             10a
      /free

         if (lowMsgKey = *ALLx'00');
            sndEscapeMsgToCaller(
               'Invalid lowMsgKey value. lowMsgKey must be graeter than 0');
         endif;

         clear msg;

         pLowKey = %addr(lowMsgKey);
         highMsgKey = getHighestMsgKey();

         if (doRmvMsg);
            action = REMOVE_MSG;
         else;
            action = KEEP_UNCHANGED;
         endif;

         reset errorCode;
         dow (msg.txt = '' and highKey > lowKey and errorCode.bytesA = 0);
            highKey -= 1;
            QMHRCVPM( rawMsgBuf : %size(rawMsgBuf) :
                      ALL_MSG_INFO_WITH_SENDER_INFO :
                      THIS_CALL_STK_ENT : THIS_CALL_STK_LVL : '*ANY' :
                      highMsgKey : NO_WAIT : action : errorCode );
            if (errorCode.bytesA > 0);
               if (errorCode.msgID = 'CPF2410');
            // QMHRCVPM( rawMsgBuf : %size(rawMsgBuf) :
            //           ALL_MSG_INFO_WITH_SENDER_INFO :
            //           THIS_CALL_STK_ENT : THIS_CALL_STK_LVL : '*ESCAPE' :
            //           NO_MSG_KEY : NO_WAIT : REMOVE_MSG : percolateErrors );
                  reset errorCode;
               endif;
            else;
               if (rcvm0300.bytesA > 0);
                  if (rcvm0300.msgLenR > 0);
                     // Stored message description
                     msgLen = rcvm0300.msgLenR;
                     msgOffs = %size(rcvm0300) + 1 + rcvm0300.rplDataLenR;
                  else;
                     // Impromptu message
                     msgLen = rcvm0300.rplDataLenR;
                     msgOffs = %size(rcvm0300) + 1;
                  endif;
                  msg.id = rcvm0300.msgId;
                  msg.txt = %subst(rawMsgBuf: msgOffs: msgLen);
                  msg.rplData = %subst(rawMsgBuf: %size(rcvm0300) + 1
                                       : rcvm0300.rplDataLenR);
                  senderInfo_p = %addr(rawMsgBuf) + %size(rcvm0300) +
                                    rcvm0300.rplDataLenR +
                                    rcvm0300.msgLenR +
                                    rcvm0300.msgHlpLenR;
                  msg.sender.qPgm.nm = senderInfo.sndPgmNm;
                  msg.sender.qPgm.lib = '*N';
                  msg.sender.qMod.nm = senderInfo.sndModNm;
                  msg.sender.qMod.lib = '*N';
                  msg.sender.procNm = senderInfo.sndProcNm;
                  msg.sender.specNb = senderInfo.sndPgmSttNb(1);
               endif;
            endif;
         enddo;

         return msg;

      /end-free
     P                 e
