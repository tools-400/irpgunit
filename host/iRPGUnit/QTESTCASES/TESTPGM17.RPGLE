**free
// ==========================================================================
//  iRPGUnit Fixture - Error in setupSuite.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

ctl-opt nomain option(*srcstmt: *nodebugio);

/include qinclude,TESTCASE
/include qinclude,ERRORCODE
/include qinclude,SYSTEMAPI

dcl-proc setupSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;
  dcl-s x int(10) inz(0);

  sndInfoMsg( 'setupSuite' );

  x = 1 / x;    // Generate error.

end-proc;

dcl-proc test1 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  sndInfoMsg( 'test1' );

end-proc;

dcl-proc teardownSuite export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  sndInfoMsg( 'teardownSuite' );

end-proc;

dcl-proc sndInfoMsg export;
  dcl-pi *n extproc(*dclcase);
    msg char(256) const;
  end-pi;

  // Call Stack Counter.
  // 1 - QCMDEXC
  // 2 - ACPTST.RUN
  // 3 - ACPTST.TEST...
  dcl-c CALL_STK_CNT 3;

  // The message reference key (unique string of characters that identifies
  // a particular instance of a message in a queue).
  dcl-s msgKey char(4);
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);
  dcl-ds qMsgF likeds(object_t) inz;

  qMsgF.nm = 'QCPFMSG';
  qMsgF.lib = '*LIBL';

  QMHSNDPM('': qMsgF: %trimr(msg): %len(%trimr(msg)): '*INFO'
           : '*CTLBDY': CALL_STK_CNT: msgKey: percolateErrors );

end-proc;
