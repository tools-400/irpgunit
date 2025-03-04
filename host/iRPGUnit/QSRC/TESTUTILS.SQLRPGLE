**FREE
// ==========================================================================
//  iRPGUnit - Utilities.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  CRTSQLRPGI OBJ(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM) +
//                 OBJTYPE(*MODULE);
//   >>IMPORTANT<<
//     >>PARM<<  OPTION(*EVENTF);
//     >>PARM<<  DBGVIEW(*NONE);
//     >>PARM<<  RPGPPOPT(*LVL2);
//     >>PARM<<  COMPILEOPT('TRUNCNBR(*NO) DBGVIEW(*ALL)');
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt nomain;
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,TESTUTILS
/include qinclude,MILIB
/include qinclude,OBJECT
/include qinclude,PGMMSG
/include qinclude,SYSTEMAPI
/include qinclude,SRCMBR
/include qinclude,STMF


//----------------------------------------------------------------------
//   Type Templates
//----------------------------------------------------------------------

/include qinclude,TEMPLATES


//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

// Message key of the latest message in the
// job log, when a test case was started.
dcl-s g_lowMsgKey     char(4);

//----------------------------------------------------------------------
//   Procedure Definitions
//----------------------------------------------------------------------


dcl-proc waitSeconds export;
  dcl-pi *N opdesc;
    seconds   int(10) const;
    message   varchar(50) const  options(*nopass: *omit);
  end-pi;

  dcl-s mi_time like(mi_time_t) inz(*allx'00');

  if (seconds = 0);
    return;
  endif;

  if (%parms() >= 2 and %addr(message) <> *null);
    displayStatusMessage(message);
  endif;

  mitime(mi_time: 0: 0: seconds: 0);
  waitTime(mi_time: WAIT_SIGNALS);

  if (%parms() >= 2 and %addr(message) <> *null);
    rstStsMsg();
  endif;

end-proc;


dcl-proc displayStatusMessage export;
  dcl-pi *N opdesc;
    message varchar(132) const;
  end-pi;

  sndStsMsg(message);

end-proc;


dcl-proc restoreStatusMessage export;
  dcl-pi *N opdesc;
  end-pi;

  rstStsMsg();

end-proc;


dcl-proc clearStatusMessage export;
  dcl-pi *N opdesc;
  end-pi;

  sndStsMsg('');

end-proc;


dcl-proc getMemberType export;
  dcl-pi *N char(10) opdesc;
    srcFile      char(10) const;
    srcFileLib   char(10) const;
    mbr          char(10) const;
  end-pi;

  dcl-ds qSrcFile likeds(Object_t);

  qSrcFile.lib = srcFileLib;
  qSrcFile.nm = srcFile;

  return SrcMbr_getType(qSrcFile: mbr);

end-proc;


dcl-proc getStmfType export;
  dcl-pi *N char(10) opdesc;
    srcStmf     like(ifsStmf_t) const;
  end-pi;

  return Stmf_getType(srcStmf);

end-proc;


dcl-proc getFullTimestamp export;
  dcl-pi *N timestamp opdesc;
  end-pi;

  dcl-s now timestamp;

  exec sql set :now = current_timestamp;

  return now;

end-proc;


//--------------------------------------------------------------------
//        Reclaim Activation Group
//--------------------------------------------------------------------
dcl-proc rclActGrp export;
  dcl-pi *N opdesc;
    w1actGrpNm   char(10) const;
  end-pi;

  dcl-s w1cmd varchar(32702);

  runCmd( 'RCLACTGRP ' + %trim(w1actGrpNm) );

end-proc;


//--------------------------------------------------------------------
//        Run Command
//--------------------------------------------------------------------
dcl-proc runCmd export;
  dcl-pi *N opdesc;
    w1cmd   varchar(32702) const;
  end-pi;

  qcmdexc( w1cmd : %len(w1cmd) );

end-proc;


dcl-proc clrpfm export;
  dcl-pi *N opdesc;
    w1FileNm   char(10) const;
    w1MbrNm    char(10) const options(*nopass);
  end-pi;

  dcl-s w1cmd varchar(32702);

  if %parms = 1;
    runCmd( 'CLRPFM FILE(*CURLIB/' + %trim(w1FileNm) + ')' );
  else;
    runCmd( 'CLRPFM FILE(*CURLIB/' + %trim(w1FileNm) + ')'
          + ' MBR(' + %trim(w1MbrNm) + ')' );
  endif;

end-proc;


dcl-proc setLowMessageKey export;
  dcl-pi *N opdesc;
    msgKey   char(4) const options(*nopass);
  end-pi;

  if (%parms() >= %parmnum(msgKey));
    g_lowMsgKey = msgKey;
  else;
    g_lowMsgKey = getHighestMsgKey();
  endif;

end-proc;


dcl-proc getmonitoredmessage export;
  dcl-pi *N likeds(msginfo_t) opdesc;
    doRmvMsg   ind const options(*nopass);
  end-pi;

  dcl-ds msgInfo likeds(msginfo_t);
  dcl-ds msg likeds(msg_t);


  if (%parms() >= %parmnum(doRmvMsg) and %addr(doRmvMsg) <> *null);
    msg = getLatestEscMsg(g_lowMsgKey: doRmvMsg);
  else;
    msg = getLatestEscMsg(g_lowMsgKey: *off);
  endif;

  msgInfo.id = msg.id;
  msgInfo.txt = msg.txt;
  msgInfo.pgm = msg.qsndstmt.qpgm.nm;
  msgInfo.mod = msg.qsndstmt.qmod.nm;
  msgInfo.proc = msg.qsndstmt.procnm;
  msgInfo.specnb = msg.qsndstmt.specnb;

  return msgInfo;

end-proc;
