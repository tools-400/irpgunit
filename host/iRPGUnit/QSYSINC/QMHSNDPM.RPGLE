**FREE
//
// Send Program Message API
//

dcl-pr qmhsndpm extpgm('QMHSNDPM');
  msgID           char(7) const;
  qMsgF           char(20) const;
  msgData         char(256) const options(*varsize);
  msgDataLen      int(10) const;
  msgType         char(10) const;
  callStkEnt      char(1024) const options(*varsize);
  callStkCnt      int(10) const;
  msgKey          char(4);
  error           char(1024) options(*varsize);
  lenCallStkEnt   int(10) const options(*nopass);
  callStkEntQual  char(20) const options(*nopass);
  msgWaitTime     int(10) const options(*nopass);
end-pr;


//----------------------------------------------------------------------
//   Symbolic Constants
//----------------------------------------------------------------------

// Call stack entry:
// - current call stack entry
dcl-c CUR_CALL_STK_ENT  '*';

// - control boundary
dcl-c CONTROL_BOUNDARY  '*CTLBDY';
