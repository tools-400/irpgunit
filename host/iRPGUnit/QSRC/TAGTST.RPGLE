**FREE
// ==========================================================================
//  iRPGUnit - Tag Test Service Program.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  OPTION(*EVENTF);
//     >>PARM<<  DBGVIEW(*LIST);
//   >>END-IMPORTANT<<
//   >>CMD<<     STRREXPRC SRCMBR(A_INSTALL) SRCFILE(&LI/QBUILD) +
//               PARM('CMPMOD &LI LIST');
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt nomain;
/include qinclude,h_spec
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

/include qinclude,ERRORCODE

//----------------------------------------------------------------------
//   Prototypes
//----------------------------------------------------------------------
/include qinclude,TAGTST
/include qinclude,TEMPLATES
/include qsysinc,QLICOBJD
/include qinclude,SRCMBR
/include qinclude,STMF

//*
// \brief main procedure
///
dcl-proc tagTstSrvPgm export;
  dcl-pi *N;
    qsrvpgm         likeds(object_t) const;
    qsrcfile        likeds(object_t) const;
    srcMbr          like(srcMbr_t.mbr) const;
    srcStmf         like(ifsStmf_t) const;
  end-pi;

  dcl-s rtnLib char(10);

  dcl-ds objInfo qualified;
    keys        int(10);
    type        int(10);
    length      int(10);
    attribute   char(30);
  end-ds;

  dcl-s lastChgDate     timestamp;
  dcl-ds errorCode likeds(errorCode_t) inz(*likeds);

  clear errorCode;
  errorCode.bytPrv = 0;

  // Change: user defined attribute
  objInfo.keys = 1;
  objInfo.type = 9;
  objInfo.length = 10;
  objInfo.attribute = 'RPGUNIT';
  qlicobjd(rtnLib : qsrvpgm : '*SRVPGM' : objInfo : errorCode);

  // Change: source file and member
  objInfo.keys = 1;
  objInfo.type = 1;
  objInfo.length = 30;
  objInfo.attribute = qsrcfile + srcMbr;
  qlicobjd(rtnLib : qsrvpgm : '*SRVPGM' : objInfo : errorCode);

  // Retrieve source member last changed date and time
  // TODO: fix for stream files
  if (isStmf(srcStmf));
    lastChgDate = Stmf_getLastChgDate(srcStmf);
  else;
    lastChgDate = SrcMbr_getLastChgDate(qsrcfile: srcMbr);
  endif;

  // Change: last changed date and time
  objInfo.keys = 1;
  objInfo.type = 2;
  objInfo.length = 13;
  objInfo.attribute = %char(%date(lastChgDate): *cymd0) + %char(%time(lastChgDate): *hms0);
  qlicobjd(rtnLib : qsrvpgm : '*SRVPGM' : objInfo : errorCode);

end-proc;


dcl-proc isStmf;
  dcl-pi *N ind extproc(*dclcase);
    stmf   const like(ifsStmf_t);
  end-pi;

  if (stmf <> '');
    return *on;
  else;
    return *off;
  endif;

end-proc;

