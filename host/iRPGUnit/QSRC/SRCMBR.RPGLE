**FREE
// ==========================================================================
//  iRPGunit - Source Member Utilities.
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
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   IMPORTS
//----------------------------------------------------------------------
/include qinclude,SRCMBR
/include qinclude,OBJECT
/include qinclude,PGMMSG
/include qinclude,STMF
/include qinclude,TEMPLATES
/include qinclude,USRSPC
/include qinclude,SYSTEMAPI
/include qinclude,ERRORCODE

dcl-pr getOPMSourceMember char(10) extproc('getOPMSourceMember');
  qPgm      const  likeds(object_t );
  qSrcMbr   likeds(srcMbr_t);
end-pr;

dcl-pr getObjectType char(10) extproc('getObjectType');
  object    const  likeds(object_t );
end-pr;

//----------------------------------------------------------------------
//   Global Constants
//----------------------------------------------------------------------

dcl-c TYPE_OPM_PGM    '*OPM';
dcl-c TYPE_ILE_PGM    '*PGM';
dcl-c TYPE_ILE_SRVPGM '*SRVPGM';

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

// User Space.
dcl-ds g_usrspc likeds(object_t);

// API List Header.
dcl-ds g_modList likeds(listhdr_t) based(g_pModList);

// Last pgm/srvPgm.
dcl-ds g_lastObject qualified inz;
  qObj   likeds(object_t);
  qMod   likeds(object_t);
end-ds;

//----------------------------------------------------------------------
//  Initializes this module.
//----------------------------------------------------------------------
dcl-proc SrcMbr_initialize export;
  dcl-pi *N;
  end-pi;

  g_usrspc.nm  = 'RUMODLIST';
  g_usrspc.lib = 'QTEMP';
  g_pModList = crtUsrSpc( g_usrspc: 'RPGUnit - Module list.');

  clear g_lastObject;

end-proc;

//----------------------------------------------------------------------
//  Returns the source member of a given unit test suite.
//----------------------------------------------------------------------
dcl-proc SrcMbr_getTestSuiteSrc export;
  dcl-pi *N likeds(srcInf_t);
    qObj   const likeds(object_t);
  end-pi;

  dcl-ds qMod likeds(object_t);

  qMod.nm = qObj.nm;
  qMod.lib = '*LIBL';
  return SrcMbr_getModSrc(qObj: qMod);

end-proc;

//----------------------------------------------------------------------
//  Returns the source member of a given program or
//  service program.
//----------------------------------------------------------------------
dcl-proc SrcMbr_getModSrc export;
  dcl-pi *N        likeds(srcInf_t);
    qObj   const likeds(object_t );
    qMod   const likeds(object_t );
  end-pi;

  // Return Value: Source member.
  dcl-ds qSrcInf likeds(srcInf_t) inz;

  dcl-s objType char(10);
  dcl-s count int(10);

  // QBNLSPGM and QBNLPGMI items (identical formats)
  dcl-ds module likeds(spgl0110_t) based(pModule);
  dcl-s stmfPath char(4096) based(pStmfPath);
  dcl-ds errorCode likeds(errorCode_t) inz(*likeds);

  clear qSrcInf;

  dou '1';

    clear errorCode;
    errorCode.bytPrv = %size(errorCode);

    objType = getObjectType(qObj);

    select;
    when (objType = TYPE_ILE_SRVPGM);
      if (qObj <> g_lastObject.qObj);
        qbnlspgm(g_usrspc: 'SPGL0110': qObj: errorCode);
      endif;
    when (objType = TYPE_ILE_PGM);
      if (qObj <> g_lastObject.qObj);
        qbnlpgmi(g_usrspc: 'PGML0110': qObj: errorCode);
      endif;
    when (objType = TYPE_OPM_PGM);
      getOPMSourceMember(qObj: qSrcInf.mbr);
      leave;
    other;
      leave;
    endsl;

    count = 0;
    dow (errorCode.bytAvl = 0 and count < g_modList.entCnt);
      count += 1;
      if (count = 1);
        pModule = g_pModList + g_modList.listoffs;
      else;
        pModule += g_modList.entSize;
      endif;

      if (module.ofsSrcStmf > 0);
        pStmfPath = g_pModList + module.ofsSrcStmf;
      else;
        pStmfPath = *null;
      endif;

      if (module.mod = qMod.nm and
          (qMod.lib = '*LIBL' or qMod.lib = module.modLib));
        if (pStmfPath <> *null);
          qSrcInf.type = TYPE_STMF;
          qSrcInf.mbr.file = '';
          qSrcInf.mbr.lib = '';
          qSrcInf.mbr.mbr = '';
          qSrcInf.stmf = %subst(stmfPath: 1: module.lenSrcStmf);
          qSrcInf.stmf = Stmf_resolvePath(qSrcInf.stmf);
        else;
          qSrcInf.type = TYPE_MEMBER;
          qSrcInf.mbr.file = module.srcFile;
          qSrcInf.mbr.lib = module.srcLib;
          qSrcInf.mbr.mbr = module.srcMbr;
          qSrcInf.stmf = '';
        endif;
        leave;
      endif;
    enddo;

  enddo;

  g_lastObject.qObj = qObj;
  g_lastObject.qMod = qMod;

  return qSrcInf;

end-proc;

//----------------------------------------------------------------------
//  Returns the date and time the member was last changed.
//----------------------------------------------------------------------
dcl-proc SrcMbr_getLastChgDate export;
  dcl-pi *N timestamp;
    qSrcFile   likeds(object_t ) const;
    srcMbr     char(10) const;
  end-pi;

  dcl-ds mbrd0100 likeds(mbrd0100_t) inz;
  dcl-ds apiDateTime qualified;
    date   char(7);
    time   char(6);
  end-ds;
  dcl-s lastChgDate timestamp;

  qusrmbrd(mbrd0100: %size(mbrd0100): 'MBRD0100': qSrcFile: srcMbr: '0');

  apiDateTime = mbrd0100.srcChgDatTim;

  lastChgDate = %date(apiDateTime.date: *cymd0) +
                %time(apiDateTime.time: *hms0);

  return lastChgDate;

end-proc;

//----------------------------------------------------------------------
//  Returns the ccsid of a given source file.
//----------------------------------------------------------------------
dcl-proc SrcMbr_getCcsid export;
  dcl-pi *N like(ccsid_t);
    qSrcFile   likeds(object_t ) const;
  end-pi;

  dcl-ds Qdb_Qddfmt likeds(Qdb_Qddfmt_t) inz;
  dcl-ds Qdb_Qdbfh likeds(Qdb_Qdbfh_t) inz;
  dcl-ds qFileRet likeds(object_t) inz;
  dcl-ds errcode likeds(percolateErrors_t) inz(*likeds);
  dcl-s ccsid like(ccsid_t);

  dcl-s isSrcFile ind;
  dcl-s isCommonCcsid ind;

  dcl-c RCDFMT_FIRST '*FIRST';
  dcl-c IGNORE_OVERRIDE '0';
  dcl-c LOCAL_FILE '*LCL';
  dcl-c EXTERNAL_FORMAT '*EXT';

  qdbrtvfd(Qdb_Qdbfh: %size(Qdb_Qdbfh): qFileRet: 'FILD0100': qSrcFile: RCDFMT_FIRST
           : IGNORE_OVERRIDE: LOCAL_FILE: EXTERNAL_FORMAT: errCode);

  isSrcFile =  %bitand(Qdb_Qdbfh.Qdbfhflg: QDBFHFSU) = QDBFHFSU;
  if (not isSrcFile);
    sndEscapeMsgToCaller('QDBRTVFD: File is not a source file: ' + Object_qName(qFileRet));
  endif;

  qdbrtvfd(Qdb_Qddfmt: %size(Qdb_Qddfmt): qFileRet: 'FILD0200': qSrcFile: RCDFMT_FIRST
           : IGNORE_OVERRIDE: LOCAL_FILE: EXTERNAL_FORMAT: errCode);

  // Actually the following condition must always be met, because 'SRCDTA'
  // is the only TEXT field of source files.
  isCommonCcsid = %bitand(Qdb_Qddfmt.Qddflgs: QDDFRSID) = QDDFRSID;
  if (not isCommonCcsid);
    sndEscapeMsgToCaller('QDBRTVFD: File has different CCSIDs: ' + Object_qName(qSrcFile));
  endif;

  ccsid = Qdb_Qddfmt.Qddfrcid;

  return ccsid;

end-proc;

//----------------------------------------------------------------------
//  Returns the description of a given source member.
//----------------------------------------------------------------------
dcl-proc SrcMbr_getDescription export;
  dcl-pi *N varchar(50);
    qSrcFile   likeds(object_t) const;
    srcMbr     char(10) const;
  end-pi;

  dcl-ds mbrd0100 likeds(mbrd0100_t) inz;

  qusrmbrd(mbrd0100: %size(mbrd0100): 'MBRD0100': qSrcFile: srcMbr: '0');

  return mbrd0100.text;

end-proc;

//----------------------------------------------------------------------
//  Returns the type of a given source member.
//----------------------------------------------------------------------
dcl-proc SrcMbr_getType export;
  dcl-pi *N varchar(10);
    qSrcFile   likeds(object_t) const;
    srcMbr     char(10) const;
  end-pi;

  dcl-ds mbrd0100 likeds(mbrd0100_t) inz;

  qusrmbrd(mbrd0100: %size(mbrd0100): 'MBRD0100': qSrcFile: srcMbr: '0');

  return %trim(mbrd0100.srcType);

end-proc;

//----------------------------------------------------------------------
//  Returns the source member of a given OPM program.
//----------------------------------------------------------------------
dcl-proc getOPMSourceMember;
  dcl-pi *N char(10);
    qPgm      likeds(object_t) const;
    qSrcMbr   likeds(srcMbr_t);
  end-pi;

  // QCLRPGMI API.
  dcl-ds pgmi0100 likeds(pgmi0100_t);
  dcl-ds errorCode likeds(errorCode_t) inz(*likeds);

  clear qSrcMbr;

  clear errorCode;
  errorCode.bytPrv = %size(errorCode);
  qclrpgmi(pgmi0100: %size(pgmi0100): 'PGMI0100': qPgm: errorCode);
  if (errorCode.bytAvl > 0);
    return *off;
  endif;

  qSrcMbr.file = pgmi0100.srcFile;
  qSrcMbr.lib = pgmi0100.srcLib;
  qSrcMbr.mbr = pgmi0100.srcMbr;

  return *on;

end-proc;


//----------------------------------------------------------------------
//  Returns *OPM, *PGM or *SRVPGM depending on the type
//  of a given object.
//----------------------------------------------------------------------
dcl-proc getObjectType;
  dcl-pi *N char(10);
    qObj   likeds(object_t) const;
  end-pi;

  // QUSROBJD API.
  dcl-ds objd0100 likeds(objd0100_t);

  // QCLRPGMI API.
  dcl-ds pgmi0100 likeds(pgmi0100_t);
  dcl-ds errorCode likeds(errorCode_t) inz(*likeds);

  clear errorCode;
  errorCode.bytPrv = %size(errorCode);

  qusrobjd(objd0100: %size(objd0100): 'OBJD0100': qObj: '*SRVPGM': errorCode);
  if (errorCode.bytAvl > 0);
    clear errorCode;
    errorCode.bytPrv = %size(errorCode);
    qclrpgmi(pgmi0100: %size(pgmi0100): 'PGMI0100': qObj: errorCode);
    if (errorCode.bytAvl > 0);
      return '';
    endif;

    if (pgmi0100.type = 'B');
      return TYPE_ILE_PGM;
    else;
      return TYPE_OPM_PGM;
    endif;
  else;
    return TYPE_ILE_SRVPGM;
  endif;

end-proc;

