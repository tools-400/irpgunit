**FREE
//
// Receive Program Message API prototype.
//
// http://publib.boulder.ibm.com/iseries/v5r2/ic2924/index.htm?info/apis/QMHRCVPM.HTM
//

dcl-pr qmhrcvpm extpgm('QMHRCVPM');
  msgInfo    char(32767) options(*varsize);
  msgInfoLen int(10) const;
  fmtNm      char(8) const;
  callStkEnt char(10) const;
  callStkCnt int(10) const;
  msgType    char(10) const;
  msgKey     char(4) const;
  waitTime   int(10) const;
  msgAction  char(10) const;
  errorCode  char(32767) options(*varsize) noopt;
  lenStkE    int(10) options(*nopass) const;     // | optGrp 1
  callStkEQ  char(20) options(*nopass) const;    // |
  callStkEDT char(10) options(*nopass) const;    // | optGrp 2
  ccsid      int(10) options(*nopass) const;     // |
end-pr;

dcl-ds rcvm0200hdr qualified template;
  bytRet                int(10);
  bytAvl                int(10);
  msgSev                int(10);
  msgID                 char(7);
  msgType               char(2);
  msgKey                char(4);
  msgFileNm             char(10);
  msgFileLibS           char(10);
  msgFileLibU           char(10);
  sendingJob            char(10);
  sendingUsr            char(10);
  sendingJobNb          char(6);
  sendingPgmNm          char(12);
  sendingPgmSttNb       char(4);
  dateSent              char(7);
  timeSent              char(6);
  rcvPgmNm              char(10);
  rcvPgmSttNb           char(4);
  sendingType           char(1);
  rcvType               char(1);
  *N                    char(1);
  ccsidCnvStsIndForTxt  int(10);
  ccsidCnvStsIndForData int(10);
  alertOpt              char(9);
  ccsidMsgAndMsgHlp     int(10);
  ccsidRplData          int(10);
  rplDataLenR           int(10);
  rpldataLenA           int(10);
  msgLenR               int(10);
  msgLenA               int(10);
  msgHlpLenR            int(10);
  msgHlpLenA            int(10);
end-ds;

dcl-ds rcvm0300hdr qualified template;
  bytRet                int(10);
  bytAvl                int(10);
  msgSev                int(10);
  msgID                 char(7);
  msgType               char(2);
  msgKey                char(4);
  msgFileNm             char(10);
  msgFileLibS           char(10);
  msgFileLibU           char(10);
  alertOpt              char(9);
  ccsidCnvStsIndOfMsg   int(10);
  ccsidCnvStsIndForData int(10);
  ccsidRplData          int(10);
  ccsidRplDataMsgHlp    int(10);
  rplDataLenR           int(10);
  rpldataLenA           int(10);
  msgLenR               int(10);
  msgLenA               int(10);
  msgHlpLenR            int(10);
  msgHlpLenA            int(10);
  sndInfoLenR           int(10);
  sndInfoLenA           int(10);
end-ds;

dcl-ds rcvm0300sender qualified template;
  sndJob           char(10);
  sndJobUsrPrf     char(10);
  sndjobnb         char(6);
  dateSent         char(7);
  timeSent         char(6);
  sndType          char(1);
  rcvType          char(1);
  sndPgmNm         char(12);
  sndModNm         char(10);
  sndProcNm        char(256);
  reserved_1       char(1);
  sndPgmSttCnt     int(10);
  sndPgmSttNb      char(10) dim(3);
  rcvPgmNm         char(10);
  rcvModNm         char(10);
  rcvProcNm        char(256);
  reserved_2       char(10);
  rcvPgmSttCnt     int(10);
  rcvPgmSttNb      char(10) dim(3);
  reserved_3       char(2);
  offsLngSndPgmNm  int(10);
  lenLngSndPgmNm   int(10);
  offsLngSndProcNm int(10);
  lenLngSndProcNm  int(10);
  offsLngRcvProcNm int(10);
  lenLngRcvProcNm  int(10);
  mSecs            char(6);
  sndUsrPrf        char(10);
  //   char(*)   Long sending program name
  //   char(*)   Long sending procedure name
  //   char(*)   Long receiving procedure name
end-ds;

//----------------------------------------------------------------------
//   Symbolic Constants
//----------------------------------------------------------------------

// Format Name:

dcl-c BRIEF_MSG_INFO                 'RCVM0100'; // - brief message information format
dcl-c EXTENDED_MSG_INFO              'RCVM0200'; // - extended format
dcl-c ALL_MSG_INFO_WITH_SENDER_INFO  'RCVM0300'; // - most detailed format

/if not defined(THIS_CALL_STK_ENT)
/define THIS_CALL_STK_ENT
// The current call stack entry.
dcl-c THIS_CALL_STK_ENT  '*';
/endif

// No message key.
dcl-c NO_MSG_KEY  '';

// Do not wait for receiving the message.
dcl-c NO_WAIT     0;

// Message action:
// - keep the message in the message queue and mark it as an old message
dcl-c KEEP_UNCHANGED  '*SAME';

// - keep the message in the message queue and mark it as an old message
dcl-c MARK_AS_OLD     '*OLD';

// - remove the message after receiving it
dcl-c REMOVE_MSG      '*REMOVE';

