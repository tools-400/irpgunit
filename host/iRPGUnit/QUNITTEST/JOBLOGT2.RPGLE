**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test JOBLOG.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM) +
//                        BNDDIR(&LI/IRPGUNIT);
//   >>IMPORTANT<<
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,JOBLOG
/copy qinclude,PGMMSG
/copy qinclude,TESTUTILS
/copy qinclude,TYPES_H

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

dcl-s testStartTime timestamp;
dcl-s totalMsgCount int(10);
dcl-s msgTextRetrieved varchar(50) dim(NUM_MSG_TO_SEND);

dcl-c NUM_MSG_TO_SEND 500;

//----------------------------------------------------------------------
//   Tests
//----------------------------------------------------------------------

dcl-proc setUp export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  testStartTime = %timestamp();
  totalMsgCount = 0;

end-proc;


dcl-proc testJobLogNext export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s hReader like(hJobLogReader_t);
  dcl-s i int(10);

  hReader = JobLogReader_init(JL_RD_PREVIOUS);

  for i = 1 to NUM_MSG_TO_SEND;
    sndInfoMsg('Message #' + %char(i));
  endfor;

  JobLogReader_read(hReader: %paddr(callback): *null);

  assertEqual(NUM_MSG_TO_SEND: totalMsgCount);
  for i = 1 to NUM_MSG_TO_SEND;
    assertEqual('Message #' + %char(i): msgTextRetrieved(NUM_MSG_TO_SEND - i + 1));
  endfor;

end-proc;



//----------------------------------------------------------------------
//   Private Helper Procedures
//----------------------------------------------------------------------

dcl-proc callback;
  dcl-pi callback ind;
    i_hMsgInfo    pointer      const;
    i_pUserData   pointer      const;
    i_msgId       char(7)      const;
    i_msgText     varchar(132) const;
    i_msgSentTime timestamp    const;
  end-pi;

  if (i_msgSentTime < testStartTime);
    return *off;
  endif;

  totalMsgCount += 1;
  msgTextRetrieved(totalMsgCount) = i_msgText;

  return *on;

end-proc;

