**FREE
// ==========================================================================
//  iRPGUnit - ACPTSTT Unit Test Helper.
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
//     >>PARM<<  OPTION(*SRCSTMT *EVENTF);
//     >>PARM<<  DBGVIEW(*LIST);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Exported Procedures
//----------------------------------------------------------------------

/include qunittest,SPLF_H

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/copy qinclude,ASSERT
/copy qinclude,ERRORCODE
/copy qinclude,SYSTEMAPI
/copy qinclude,TEMPLATES
/copy qinclude,USRSPC

/copy qinclude,LSTSPLF

//----------------------------------------------------------------------
//   Constants
//----------------------------------------------------------------------

// SNA Character String (in spool files).
// - New Line
dcl-c NULL const(x'00');
dcl-c NL const(x'15');
dcl-c PP const(x'34');
dcl-c CR const(x'0D');
dcl-c FF const(x'0C');

//----------------------------------------------------------------------
//   Templates
//----------------------------------------------------------------------

dcl-ds SplfId_t qualified template;
  qJob   likeds(QlfJobNm_t);
  name   char(10);
  number int(10);
  handle int(10);
end-ds;

dcl-ds userData_t qualified template;
  countDeleted int(10);
end-ds;

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

// Spool file.
dcl-ds splf qualified;
  qJob            likeds(QlfJobNm_t);
  name            char(10);
  number          int(10);
  usrSpcNm        likeds(Object_t);
  pUsrSpc         pointer;
  // - Handle
  hdl             int(10) inz(-1);
  // - Print Data User Space Current Position Pointer
  bufPos_p        pointer;
  // - Print Data User Space End Pointer
  usrSpcEnd_p     pointer;
end-ds;

//----------------------------------------------------------------------
//   Procedure Definition
//----------------------------------------------------------------------

dcl-proc chkAndCloSplF export;
  dcl-pi *n;
  end-pi;

  if (splf.hdl <> -1);
    cloSplf();
  endif;

end-proc;


dcl-proc cloSplf export;
  dcl-pi *n;
  end-pi;

  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);
  dcl-s cmd varchar(100);

  QSPCLOSP(splf.hdl: percolateErrors);

  cmd = 'DLTSPLF FILE(' + %trim(splf.name) + ') ' +
                'JOB(' + %trim(splf.qJob.jobNb) + '/' +
                         %trim(splf.qJob.usrNm) +'/' +
                         %trim(splf.qJob.jobNm) + ') ' +
                'SPLNBR(' + %char(splf.number) + ')';

  qcmdexc(cmd: %len(cmd));

  clear splf;
  splf.hdl = -1;

end-proc;


dcl-proc dltSplfs export;
  dcl-pi *n int(10);
    splfNm    like(UsrNm_t) const;
    usrData   char(10) const;
  end-pi;

  dcl-s hLister like(hSplFLister_t);
  dcl-ds userData likeds(userData_t);

  clear userData;
  userData.countDeleted = 0;

  hLister = SplFLister_init('*': splFNm: usrData);
  // filterInfo.usrNm   = rtvJobUsrNm();
  SplFLister_list(hLister: %paddr('listSplfCallback'): %addr(userData));

  return userData.countDeleted;

end-proc;


dcl-proc listSplfCallback export;
  dcl-pi *n ind extproc(*dclcase);
    i_hSplF       pointer const;
    i_pUserData   pointer const;
    i_name        char(10) const;
    i_qJob        likeds(Job_t) const;
    i_splFNbr     int(10) const;
    i_status      varchar(10) const;
  end-pi;

  dcl-ds userData likeds(userData_t) based(i_pUserData);
  dcl-s cmd varchar(512);

  cmd = 'DLTSPLF FILE(' + %trim(i_name) + ') +
         JOB(' + %trim(i_qJob.nbr) + '/' +
                 %trim(i_qJob.user) + '/' +
                 %trim(i_qJob.name) + ') +
         SPLNBR(' + %char(i_splFNbr) + ')';

  qcmdexc( cmd: %len(cmd) );

  userData.countDeleted += 1;

  return *on;

end-proc;


dcl-proc getNextLine;
  dcl-pi *n varchar(256) extproc(*dclcase);
  end-pi;

  // Character at current position.
  dcl-s currentChar char(1) based(splf.bufPos_p);
  dcl-s line varchar(256);
  dcl-s isLine ind;

  isLine = *off;

  dow (splf.bufPos_p <= splf.usrSpcEnd_p);
    select;
    when (currentChar = NULL);
      splf.bufPos_p += %size(NULL);
      if (isLine);
        isLine = *off;
        return line;
      endif;
    when (currentChar = NL);
      splf.bufPos_p += %size(NL);
      isLine = *on;
    when (currentChar = PP);
      splf.bufPos_p = splf.bufPos_p + %size( PP ) + 2;
    when (currentChar = CR);
      splf.bufPos_p += %size(CR);
    when (currentChar = FF);
      splf.bufPos_p += %size(FF);
    when (currentChar >= x'40' and currentChar <= x'FE');
      if (isLine);
        line += currentChar;
      endif;
      splf.bufPos_p += %size(currentChar);
    other;
      splf.bufPos_p += 1;
    endsl;
  enddo;

  fail('Reached end of spooled file.');

end-proc;


dcl-proc opnSplf export;
  dcl-pi *n;
    splfNm    char(10) const;
    usrData   char(10) const;
  end-pi;


  dcl-ds splfId likeds(SplfId_t) inz;
  dcl-s char char(1) based(splf.bufPos_p);

  clear splf;
  splfId = rtvSplfHdl(splfNm: usrData);

  splf.qJob = splfId.qJob;
  splf.name = splfId.name;
  splf.number = splfId.number;
  splf.hdl = splfId.handle;

  splf.usrSpcNm.nm = 'RUSPOOL';
  splf.usrSpcNm.lib = 'QTEMP';

  splf.pUsrSpc = crtUsrSpc(splf.usrSpcNm:
                           'RPGUnit - SelfTest - Spool File Contents.' );

  readSplfBuf();

  // Skip first 15 bytes according to "Decoding a Spooled File after Using the QSPGETSP API":
  // https://www.ibm.com/support/pages/decoding-spooled-file-after-using-qspgetsp-api
  splf.bufPos_p += 15;

  // Patch first byte to x'15' to make it work.
  // In RPGUNIT spooled files the first byte is x'0D' but
  // in compiler listings the first byte is x'15'.
  // The meaning of the first byte is unknown due to the
  // lack of IBM documentation.
  char = NL; // = x'15'

end-proc;


dcl-proc readSplfBuf;
  dcl-pi *n extproc(*dclcase);
  end-pi;
  // QSPGETSP API: Reading an entire spooled file.
  dcl-c READ_ENTIRE_SPLF -1;
  // QSP API generic header.
  dcl-ds qspGenHdr likeds(qspGenHdr_t) based(splf.pUsrSpc);
  // User Space to store spool contents.
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  QSPGETSP(splf.hdl:
           splf.usrSpcNm:
           'SPFR0300':
           READ_ENTIRE_SPLF:
           '*ERROR':
           percolateErrors);

  aEqual( 'C' : qspGenHdr.compInd );

//  splf.bufPos_p = splf.pUsrSpc + qspGenHdr.firstBufOffs;
//  splf.usrSpcEnd_p = splf.pUsrSpc + qspGenHdr.usrSpcSizeUsed;

  resetReadPointer();

end-proc;


dcl-proc rtvJobUsrNm;
  dcl-pi *n char(10) extproc(*dclcase);
  end-pi;

  // Job attributes.
  dcl-ds jobAttribs likeds(dsRTVC0100);
  // Job attribute keys.
  dcl-s attribKeys int(10) Dim(1);
  // Current user profile name job attribute entry.
  dcl-ds usrNmEnt likeds(dsRTVC0100Ent);
  dcl-ds percolateErrors likeds(percolateErrors_t)
  inz(*likeds);

  attribKeys(1) = CUR_USR_NM;

  QWCRTVCA(jobAttribs:
           %size(jobAttribs):
           'RTVC0100':
           %elem(attribKeys):
           attribKeys:
           percolateErrors);

  if (jobAttribs.attribCnt <> 1);
     fail('QWCRTVCA returned an unexpected number of job attributes');
  endif;

  usrNmEnt = jobAttribs.attribEnts;

  if (usrNmEnt.key <> CUR_USR_NM) or
     (usrNmEnt.dataType <> 'C') or
     (usrNmEnt.dataLen <> 10);
     fail('QWCRTVA returned an unexpected attribute format');
  endif;

  return usrNmEnt.data;

end-proc;


dcl-proc rtvLatestSplf;
  dcl-pi *N likeds(SplfId_t);
    usrNm           const like(UsrNm_t);
    usrData         char(10) const;
  end-pi;

  // Retrieve only one record.
  dcl-c ONE_RECORD const(1);
  // Retrieve spool files from all jobs.
  dcl-c ALL_JOBS const(*blank);
  // Do not retrieve any record.
  dcl-c NO_RETRIEVAL const(*zero);
  // The entire list is build synchronously.
  dcl-c BUILD_ENTIRE_LIST_SYNCHRONOUSLY
        const(-1);
  // Latest spool file id.
  dcl-ds latestSplfId likeds(SplfId_t);
  // Latest spool file info from QGYOLSPL API.
  dcl-ds latestSplfInfo likeds(dsOSPL0300);
  // Open list information for QGYOLSPL API.
  dcl-ds listInfo likeds(dsOpnList);
  // Open list handle.
  dcl-s opnListHdl      like(dsOpnList.rqsHdl);
  // Last spool file record index.
  dcl-s lastRcdIdx      int(10);
  // Spool file sorting information.
  dcl-ds sortInfo likeds(SortInfo_t);

  // Spool file filtering information, according to OSPF0100 format.
  dcl-ds filterInfo qualified;
    usrNmCnt    int(10) inz(1);
    usrNm       char(10);
    *N          char(2) inz(x'00');
    outqNmCnt   int(10) inz(1);
    outqNm      char(10) inz('*ALL');
    outqLibNm   char(10) inz(*blank);
    formType    char(10) inz('*ALL');
    usrData     char(10);
    statusCnt   int(10) inz(1);
    splfStatus  char(10) inz('*READY');
    *N          char(2) inz(x'00');
    deviceNmCnt int(10) inz(1);
    deviceNm    char(10) inz('*ALL');
    *N          char(2) inz(x'00');
  end-ds;

  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  filterInfo.usrNm = usrNm;
  filterInfo.usrData = usrData;

  sortInfo = *allx'00';

  QGYOLSPL(latestSplfInfo:
           NO_RETRIEVAL:
           listInfo:
           BUILD_ENTIRE_LIST_SYNCHRONOUSLY:
           sortInfo:
           filterInfo:
           ALL_JOBS:
           'OSPL0300':
           percolateErrors);

  if (listInfo.retRcdCnt <> 0);
    fail('QGYOLSPL unexpectedly returned a record');
  endif;

  if (listInfo.infoCompInd <> 'C');
    fail('QGYOLSPL could not retrieve complete info. ' +
         'Indicator=' + listInfo.infoCompInd);
  endif;

  if (listInfo.firstRcdIdx <> 0);
    fail('QGYOLSPL unexpectedly returned a first record');
  endif;

  assert(listInfo.totalRcdCnt > 0:
         'No spool file found for user ' + %trimr(usrNm) +
         ' and user data ' + %trimr(usrData) );

  opnListHdl = listInfo.rqsHdl;
  lastRcdIdx = listInfo.totalRcdCnt;

  QGYGTLE(latestSplfInfo:
          %size(latestSplfInfo):
          opnListHdl:
          listInfo:
          ONE_RECORD:
          lastRcdIdx:
          percolateErrors);

  QGYCLST( listInfo.rqsHdl : percolateErrors );

  latestSplfId.qJob.jobNm = latestSplfInfo.jobNm;
  latestSplfId.qJob.usrNm = latestSplfInfo.usrNm;
  latestSplfId.qJob.jobNb = latestSplfInfo.jobNb;
  latestSplfId.name = latestSplfInfo.splfNm;
  latestSplfId.number = latestSplfInfo.splfNb;

  return latestSplfId;

end-proc;


dcl-proc rtvSplfHdl;
  dcl-pi *n likeds(SplfId_t) extproc(*dclcase);
    splfNm    char(10) const;
    usrData   char(10) const;
  end-pi;

  // Latest spool file handle.
  dcl-s latestSplfHdl int(10);
  // Latest spool file id.
  dcl-ds latestSplfId likeds(SplfId_t);
  // Current user profile name.
  dcl-s curUsrNm like(UsrNm_t);
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  // A simple QSPOPNSP( splfHdl : '*' : *blank : *blank : splfNm : -1 : 1 : percolateErr
  // would be enough for regular (i.e., interactive and submitted) jobs, but it does
  // not work for remote commands (a.k.a. server jobs).  In the latter, the spool file
  // is created by a special job named QPRTJOB.

  curUsrNm = rtvJobUsrNm();
  latestSplfId = rtvLatestSplf(curUsrNm: usrData);

  QSPOPNSP(latestSplfHdl:
           latestSplfId.qJob:
           *blank:
           *blank:
           latestSplfId.name:
           latestSplfId.number:
           1:
           percolateErrors);

  latestSplfId.handle = latestSplfHdl;

  return latestSplfId;

end-proc;


dcl-proc splfLineStartsWith export;
  dcl-pi *n;
    expString   varchar(256) const;
  end-pi;

  dcl-s line            varchar(256);

  line = getNextLine();
  assertEqual( expString : %subst(line: 1: %len(expString)) );


  end-proc;


dcl-proc splfContains export;
  dcl-pi *n;
    expString   varchar(256) const;
  end-pi;

  dcl-s line varchar(256);

  resetReadPointer();

  dow (*on);
    line = getNextLine();
    if (%scan(expString: line) > 0);
      return;
    endif;
  enddo;

end-proc;


dcl-proc resetReadPointer;
  dcl-pi *n;
  end-pi;

  // QSP API generic header.
  dcl-ds qspGenHdr likeds(qspGenHdr_t) based(splf.pUsrSpc);

  splf.bufPos_p = splf.pUsrSpc + qspGenHdr.firstBufOffs;
  splf.usrSpcEnd_p = splf.pUsrSpc + qspGenHdr.usrSpcSizeUsed;

end-proc;


dcl-proc splfSkipLine export;
  dcl-pi *n;
  end-pi;

  getNextLine();

end-proc;

