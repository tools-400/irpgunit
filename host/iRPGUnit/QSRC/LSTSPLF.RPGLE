**FREE
// ==========================================================================
//  iRPGUnit - List Spooled Files.
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
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain;
/include qinclude,H_SPEC

//----------------------------------------------------------------------
//   IMPORTS
//----------------------------------------------------------------------

/include qinclude,COPYRIGHT
/include qinclude,ERRORCODE
/include qinclude,PGMMSG
/include qsysinc,QGYOLSPL
/include qsysinc,QGYGTLE
/include qsysinc,QGYCLST

/include qinclude,LSTSPLF

//----------------------------------------------------------------------
//   TYPE TEMPLATES
//----------------------------------------------------------------------

dcl-ds hLister_t qualified template;
  length          int(5);
  qJob            likeds(Job_t);
  splfNm          char(10);
  currSplFCnt     int(10);
  sizeFilterInfo  int(10);
  sortInfo        likeds(sortInfo_t);
  data            char(1024);
  filterInfo      likeds(OSPF0200_t) overlay(data);
end-ds;

//----------------------------------------------------------------------
//   CONSTANTS
//----------------------------------------------------------------------

dcl-c FILE_NAME_ALL  '*ALL';
dcl-c USRDTA_ALL     '*ALL';
dcl-c FRMTYPE_ALL    '*ALL';

dcl-c SYSTEM_CURRENT '*CURRENT';

dcl-c CRT_DATE_NULL  '';
dcl-c CRT_DATE_ALL   '*ALL';
dcl-c CRT_DATE_FIRST '*FIRST';
dcl-c CRT_DATE_LAST  '*LAST';

//----------------------------------------------------------------------
//   PRIVATE PROTOTYPES
//----------------------------------------------------------------------

dcl-pr toExtStatus char(10) extproc('toExtStatus');
  i_intFileStatus int(10) const;
end-pr;

//----------------------------------------------------------------------
// Initializes a spooled file lister.
// Returns:
//  spooled file lister handle on succeess, else ''.
//----------------------------------------------------------------------
dcl-proc SplfLister_init export;
  dcl-pi *n like(hSplFLister_t);
    i_qJob    likeds(Job_t) const options(*nopass);
    i_splfNm  char(10)      const options(*nopass);
    i_usrDta  char(10)      const options(*nopass);
  end-pi;

  dcl-ds qJob  likeds(i_qJob);
  dcl-s splfNm like(i_splfNm);
  dcl-s usrDta like(i_usrDta);

  dcl-s hListerRtn like(hSplFLister_t);
  dcl-ds hLister likeds(hLister_t) based(pHListerDS);

  if (%parms() >= %parmnum(i_qJob));
    qJob = i_qJob;
  else;
    qJob = '*';
  endif;

  if (%parms() >= %parmnum(i_splfNm) and i_splfNm <> '');
    splfNm = i_splfNm;
  else;
    splfNm = FILE_NAME_ALL;
  endif;

  if (%parms() >= %parmnum(i_usrDta) and i_usrDta <> '');
    usrDta = i_usrDta;
  else;
    usrDta = USRDTA_ALL;
  endif;

  pHListerDS = %addr(hListerRtn);

  clear hLister;
  hLister.filterInfo.lenFltrInf = %size(hLister.filterInfo);
  hLister.filterInfo.lenUsrNmE = %size(OSPF0200_userNameE_t);
  hLister.filterInfo.lenOutQNm = %size(OSPF0200_outQueueE_t);
  hLister.filterInfo.lenSplfSts = %size(OSPF0200_fileStatusE_t);
  hLister.filterInfo.lenPrtDevN = %size(OSPF0200_prtDevNameE_t);
  hLister.filterInfo.frmType = FRMTYPE_ALL;

  if (usrDta <> USRDTA_ALL);
    hLister.filterInfo.usrSpcDta = usrDta;
  else;
    hLister.filterInfo.usrSpcDta = splfNm;
  endif;

  hLister.filterInfo.sysNm = SYSTEM_CURRENT;
  hLister.filterInfo.strSplfCrtDt = CRT_DATE_ALL;
  hLister.filterInfo.strSplfCrtTm = '';
  hLister.filterInfo.endSplfCrtDt = '';
  hLister.filterInfo.endSplfCrtTm = '';
  hLister.filterInfo.reserved_01 = *ALLx'00';

  hLister.qJob = qJob;
  hLister.splfNm = splfNm;
  hLister.currSplFCnt = 0;
  hLister.sizeFilterInfo = %size(hLister.filterInfo);
  hLister.length = %addr(hLister.filterInfo) - %addr(hLister)
                   + %size(hLister.filterInfo);

  SplFLister_addStatus(hListerRtn: SL_STS_READY);

  return hListerRtn;

end-proc;

//----------------------------------------------------------------------
// Adds a status filter.
// Returns:
//  Number of status filters on success, else -1.
//----------------------------------------------------------------------
dcl-proc SplFLister_addStatus export;
  dcl-pi *n int(10);
    io_hLister   like(hSplFLister_t);
    i_status     char(10) const;
  end-pi;

  dcl-ds hLister likeds(hLister_t) based(pHLister);

  dcl-s checkLength int(10);
  dcl-s status like(OSPF0200_fileStatusE_t) based(pStatus);
  dcl-s i int(10);

  pHLister = %addr(io_hLister);

  if (hLister.length >= %size(hLister.data) - %size(status));
    return -1;
  endif;

  if (i_status <> SL_STS_CLOSED and
      i_status <> SL_STS_DEFERRED and
      i_status <> SL_STS_SENDING and
      i_status <> SL_STS_FINISHED and
      i_status <> SL_STS_HELD and
      i_status <> SL_STS_MESSAGE and
      i_status <> SL_STS_OPEN and
      i_status <> SL_STS_PENDING and
      i_status <> SL_STS_PRINTER and
      i_status <> SL_STS_READY and
      i_status <> SL_STS_SAVED and
      i_status <> SL_STS_WRITING);
    sndEscapeMsgToCaller('Invalid status value: ' + i_status);
  endif;

  if (hLister.filterInfo.numSplfSts > 0);
    checkLength = hLister.filterInfo.offsSplfSts
                  + (hLister.filterInfo.numSplfSts * %size(status));
    if (hLister.sizeFilterInfo <> checkLength);
      return -1;
    endif;
  else;
    hLister.filterInfo.offsSplfSts = hLister.sizeFilterInfo;
  endif;

  // Replace status

  if (hLister.filterInfo.numSplfSts = 1);
    pStatus = %addr(hLister.filterInfo) + hLister.filterInfo.offsSplfSts;
    if (status = '*ALL');
      status = i_status;
      return hLister.filterInfo.numSplfSts;
    endif;
  endif;

  // Already set?

  for i = 1 to hLister.filterInfo.numSplfSts;
    pStatus = %addr(hLister.filterInfo) + hLister.filterInfo.offsSplfSts
              + ((i - 1) * %size(status));
    if (status = i_status);
      return hLister.filterInfo.numSplfSts;
    endif;
  endfor;

  // Add status

  pStatus = %addr(hLister.filterInfo) + hLister.filterInfo.offsSplfSts
            + (hLister.filterInfo.numSplfSts * %size(status));

  status = i_status;

  hLister.filterInfo.numSplfSts += 1;

  hLister.sizeFilterInfo += %size(status);
  hLister.length += %size(status);

  return hLister.filterInfo.numSplfSts;

end-proc;

//----------------------------------------------------------------------
// Sets a start time (time created) filter.
// Returns:
//  *on on success, else *off.
//----------------------------------------------------------------------
dcl-proc SplFLister_setStartTime export;
  dcl-pi *n ind;
    io_hLister   like(hSplFLister_t);
    i_startTime  timestamp const;
  end-pi;

  dcl-ds hLister likeds(hLister_t) based(pHLister);

  dcl-s endCrtTime timestamp;

  pHLister = %addr(io_hLister);

  if (hLister.filterInfo.endSplfCrtDt <> CRT_DATE_NULL and
      hLister.filterInfo.endSplfCrtDt <> CRT_DATE_LAST);
    endCrtTime = %date(hLister.filterInfo.endSplfCrtDt: *cymd0) +
                 %time(hLister.filterInfo.endSplfCrtTm: *hms0);
  endif;

  if (endCrtTime > i_startTime);
    sndEscapeMsgToCaller('Start time must be greater than end time.');
  endif;

  pHLister = %addr(io_hLister);

  hLister.filterInfo.strSplfCrtDt = %char(%date(i_startTime): *cymd0);
  hLister.filterInfo.strSplfCrtTm = %char(%time(i_startTime): *hms0);

  if (hLister.filterInfo.endSplfCrtDt = CRT_DATE_NULL);
    hLister.filterInfo.endSplfCrtDt = CRT_DATE_LAST;
    hLister.filterInfo.endSplfCrtTm = CRT_DATE_NULL;
  endif;

  return *on;

end-proc;

//----------------------------------------------------------------------
// Sets a end time (time created) filter.
// Returns:
//  *on on success, else *off.
//----------------------------------------------------------------------
dcl-proc SplFLister_setEndTime export;
  dcl-pi *n ind;
    io_hLister   like(hSplFLister_t);
    i_endTime  timestamp const;
  end-pi;

  dcl-ds hLister likeds(hLister_t) based(pHLister);

  dcl-s startCrtTime timestamp;

  pHLister = %addr(io_hLister);

  if (hLister.filterInfo.strSplfCrtDt <> CRT_DATE_ALL and
      hLister.filterInfo.strSplfCrtDt <> CRT_DATE_FIRST);
    startCrtTime = %date(hLister.filterInfo.strSplfCrtDt: *cymd0) +
                   %time(hLister.filterInfo.strSplfCrtTm: *hms0);
  endif;

  if (startCrtTime > i_endTime);
    sndEscapeMsgToCaller('End time must be lower than start time.');
  endif;

  hLister.filterInfo.endSplfCrtDt = %char(%date(i_endTime): *cymd0);
  hLister.filterInfo.endSplfCrtTm = %char(%time(i_endTime): *hms0);

  if (hLister.filterInfo.strSplfCrtDt = CRT_DATE_ALL);
    hLister.filterInfo.endSplfCrtDt = CRT_DATE_FIRST;
    hLister.filterInfo.endSplfCrtTm = CRT_DATE_NULL;
  endif;

  return *on;

end-proc;

//----------------------------------------------------------------------
// Reads the list of spooled files.
// Returns:
//  *on on success, wlse *off.
//----------------------------------------------------------------------
dcl-proc SplFLister_list export;
  dcl-pi *n ind;
    io_hLister   like(hSplFLister_t);
    i_pCallback  pointer(*proc) const;
    i_pUserData  pointer options(*nopass) const;
  end-pi;

  dcl-s pUserData like(i_pUserData);

  dcl-ds hLister likeds(hLister_t) based(pHLister);
  dcl-ds ospl0300 likeds(dsOSPL0300);
  dcl-ds listInfo likeds(dsOpnList);
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);
  dcl-s opnListHdl like(dsOpnList.rqsHdl);

  // Retrieve only one record.
  dcl-c ONE_RECORD 1;

  dcl-ds qJob likeds(Job_t);
  dcl-s splfNm like(ospl0300.splfNm);
  dcl-s splfNbr like(ospl0300.splfNb);
  dcl-s status varchar(10);

  dcl-s pCallback pointer(*proc);
  dcl-pr callback ind extproc(pCallback);
    i_hSplF       pointer       const;
    i_pUserData   pointer       const;
    i_splfNm      char(10)      const;
    i_qJob        likeds(Job_t) const;
    i_splFNbr     int(10)       const;
    i_fileStatus  char(10)      const;
  end-pr;

  if (%parms() >= %parmnum(i_pUserData));
    pUserData = i_pUserData;
  else;
    pUserData = *null;
  endif;

  pHLister = %addr(io_hLister);

  QGYOLSPL(ospl0300 :
           0 :
           listInfo :
           OLSL_FULL_SYNCHRONOUS_BUILD :
           hLister.sortInfo :
           hLister.filterInfo :
           hLister.qJob :
           'OSPL0300' :
           percolateErrors :
           'OSPF0200');

  if ( listInfo.retRcdCnt <> 0 );
    sndEscapeMsgAboveCtlBdy('QGYOLSPL unexpectedly returned a record');
  endif;

  if ( listInfo.infoCompInd <> 'C' );
    sndEscapeMsgAboveCtlBdy('QGYOLSPL could not retrieve complete info.' +
          'Indicator=' + listInfo.infoCompInd );
  endif;

  if ( listInfo.firstRcdIdx <> 0 );
    sndEscapeMsgAboveCtlBdy('QGYOLSPL unexpectedly returned a first record');
  endif;

  pCallback = i_pCallback;

  for hLister.currSplFCnt = 1 to listInfo.totalRcdCnt;

    opnListHdl = listInfo.rqsHdl;

    QGYGTLE( ospl0300 :
             %size(ospl0300) :
             opnListHdl :
             listInfo :
             ONE_RECORD :
             hLister.currSplFCnt :
             percolateErrors );

    if (hLister.splfNm = '*ALL' or hLister.splfNm = ospl0300.splfNm);

      splfNm = ospl0300.splfNm;

      qJob.name = ospl0300.jobNm;
      qJob.user = ospl0300.usrNm;
      qJob.nbr = ospl0300.jobNb;

      splfNbr = ospl0300.splfNb;
      status = toExtStatus(ospl0300.fileStatus);

      if (pCallback <> *null);
        if (not callback(%addr(ospl0300): pUserData: splfNm: qJob: splfNbr: status));
          leave;
        endif;
      endif;
    endif;
  endfor;

  QGYCLST( listInfo.rqsHdl : percolateErrors );

  return *on;

end-proc;

dcl-proc SplFLister_getUserData export;
  dcl-pi *n char(10);
    i_hSplf  pointer const;
  end-pi;

  dcl-ds ospl0300 likeds(dsOSPL0300) based(i_hSplf);

  return ospl0300.usrDta;

end-proc;

//----------------------------------------------------------------------
// Converts the spooled file status as returned by the API to
// the external, human readable format.
//----------------------------------------------------------------------
dcl-proc toExtStatus;
  dcl-pi *n char(10);
    i_intFileStatus int(10) const;
  end-pi;

  select;
  when (i_intFileStatus = 1);
    return 'RDY';
  when (i_intFileStatus = 2);
    return 'OPN';
  when (i_intFileStatus = 3);
    return 'CLO';
  when (i_intFileStatus = 4);
    return 'SAV';
  when (i_intFileStatus = 5);
    return 'WTR';
  when (i_intFileStatus = 6);
    return 'HLD';
  when (i_intFileStatus = 7);
    return 'MSGW';
  when (i_intFileStatus = 8);
    return 'PND';
  when (i_intFileStatus = 9);
    return 'PRT';
  when (i_intFileStatus = 10);
    return 'FIN';
  when (i_intFileStatus = 11);
    return 'SND';
  when (i_intFileStatus = 12);
    return 'DFR';
  endsl;

end-proc;

