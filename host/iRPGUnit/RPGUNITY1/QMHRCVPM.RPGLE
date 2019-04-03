      //
      // Receive Program Message API prototype.
      //
      // http://publib.boulder.ibm.com/iseries/v5r2/ic2924/index.htm?info/apis/QMHRCVPM.HTM
      //

     D QMHRCVPM        pr                  ExtPgm('QMHRCVPM')
     D  msgInfo                   32565a   options(*varsize)
     D  msgInfoLen                   10i 0 const
     D  fmtNm                         8a   const
     D  callStkEnt                   10a   const
     D  callStkCnt                   10i 0 const
     D  msgType                      10a   const
     D  msgKey                        4a   const
     D  waitTime                     10i 0 const
     D  msgAction                    10a   const
     D  errorCode                 32565a   options(*varsize) noopt

     D RCVM0200Hdr     ds                  qualified based(template)
     D  bytesR                       10i 0
     D  bytesA                       10i 0
     D  msgSev                       10i 0
     D  msgId                         7a
     D  msgType                       2a
     D  msgKey                        4a
     D  msgFileNm                    10a
     D  msgFileLibS                  10a
     D  msgFileLibU                  10a
     D  sendingJob                   10a
     D  sendingUsr                   10a
     D  sendingJobNb                  6a
     D  sendingPgmNm                 12a
     D  sendingPgmSttNb...
     D                                4a
     D  dateSent                      7a
     D  timeSent                      6a
     D  rcvPgmNm                     10a
     D  rcvPgmSttNb                   4a
     D  sendingType                   1a
     D  rcvType                       1a
     D                                1a
     D  CCSIDCnvStsIndForTxt...
     D                               10i 0
     D  CCSIDCnvStsIndForData...
     D                               10i 0
     D  alertOpt                      9a
     D  CCSIDMsgAndMsgHlp...
     D                               10i 0
     D  CCSIDRplData                 10i 0
     D  rplDataLenR                  10i 0
     D  rplDataLenA                  10i 0
     D  msgLenR                      10i 0
     D  msgLenA                      10i 0
     D  msgHlpLenR                   10i 0
     D  msgHlpLenA                   10i 0

     D RCVM0300Hdr     ds                  qualified based(template)
     D  bytesR                       10i 0
     D  bytesA                       10i 0
     D  msgSev                       10i 0
     D  msgId                         7a
     D  msgType                       2a
     D  msgKey                        4a
     D  msgFileNm                    10a
     D  msgFileLibS                  10a
     D  msgFileLibU                  10a
     D  alertOpt                      9a
     D  CCSIDCnvStsIndOfMsg...
     D                               10i 0
     D  CCSIDCnvStsIndForData...
     D                               10i 0
     D  CCSIDRplData                 10i 0
     D  CCSIDRplDataMsgHlp...
     D                               10i 0
     D  rplDataLenR                  10i 0
     D  rplDataLenA                  10i 0
     D  msgLenR                      10i 0
     D  msgLenA                      10i 0
     D  msgHlpLenR                   10i 0
     D  msgHlpLenA                   10i 0
     D  sndInfoLenR                  10i 0
     D  sndInfoLenA                  10i 0

     D RCVM0300Sender  ds                  qualified based(template)
     D  sndJob                       10a
     D  sndUsrPrf                    10a
     D  sndJobNb                      6a
     D  dateSent                      7a
     D  timeSent                      6a
     D  sndType                       1a
     D  rcvType                       1a
     D  sndPgmNm                     12a
     D  sndModNm                     10a
     D  sndProcNm                   256a
     D                                1a
     D  sndPgmSttCnt                 10i 0
     D  sndPgmSttNb                  30a   dim(3)
     D  rcvPgmNm                     10a
     D  rcvModNm                     10a
     D  rcvProcNm                   256a
     D                               10a
     D  rcvPgmSttCnt                 10i 0
     D  rcvPgmSttNb                  30a   dim(3)
     D                                2a
      // ...last fields omitted.


      //----------------------------------------------------------------------
      //   Symbolic Constants
      //----------------------------------------------------------------------

       // Format Name:
       // - extended format for QMHRCVPM API.
     D EXTENDED_MSG_INFO...
     D                 c                   const('RCVM0200')
       // - most detailed format for QMHRCVPM API.
     D ALL_MSG_INFO_WITH_SENDER_INFO...
     D                 c                   const('RCVM0300')

       // The current call stack entry.
     D THIS_CALL_STK_ENT...
     D                 c                   const('*')

       // No message key.
     D NO_MSG_KEY      c                   const(*blank)

       // Do not wait for receiving the message.
     D NO_WAIT         c                   const(0)

       // Message action:
       // - keep the message in the message queue and mark it as an old message
     D KEEP_UNCHANGED  c                   const('*SAME')
       // - keep the message in the message queue and mark it as an old message
     D MARK_AS_OLD     c                   const('*OLD')
       // - remove the message after receiving it
     D REMOVE_MSG      c                   const('*REMOVE')
