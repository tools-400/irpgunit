**FREE
// ==========================================================================
//  iRPGUnit - Object Utilities.
// ==========================================================================
//  Copyright (c) 2013-2020 iRPGUnit Project Team
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

ctl-opt nomain;
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   IMPORTS
//----------------------------------------------------------------------

/include qinclude,SRCMBR
/include qinclude,OBJECT
/include qinclude,TEMPLATES
/include qinclude,SYSTEMAPI
/include qinclude,ERRORCODE

dcl-pr retrieveObjectDescription char(4096) extproc('retrieveObjectDescription');
  object          const likeds(object_t);
  objType         char(10) const;
  format          char(8) const;
  errorCode       likeds(errorCode_t) options(*nopass: *omit);
end-pr;

dcl-pr retrieveMemberDescription char(4096) extproc('retrieveMemberDescription');
  file            const likeds(object_t);
  member          char(10) const;
  format          char(8) const;
  errorCode       likeds(errorCode_t) options(*nopass: *omit);
end-pr;

//----------------------------------------------------------------------
//  Returns *ON when the specified iRPGUnit test suite does not
//  exist or is dirty. A test suite is considered as dirty, when
//  the source code has been changed since the object has been created.
//----------------------------------------------------------------------
dcl-proc TestSuite_isDirty export;
  dcl-pi *N ind;
    srvPgm          char(10) const;
    library         char(10) const;
  end-pi;

  dcl-ds qSrvPgm likeds(object_t);

  qSrvPgm.nm = srvPgm;
  qSrvPgm.lib = library;

  if (not Object_exists(qSrvPgm: '*SRVPGM'));
    return *on;
  endif;

  return Object_isDirty(qSrvPgm: '*SRVPGM');

end-proc;

//----------------------------------------------------------------------
//  Returns *ON when the specified iRPGUnit test suite does not exist.
//----------------------------------------------------------------------
dcl-proc TestSuite_exists export;
  dcl-pi *N ind;
    srvPgm          char(10) const;
    library         char(10) const;
  end-pi;

  dcl-ds qSrvPgm likeds(object_t);

  qSrvPgm.nm = srvPgm;
  qSrvPgm.lib = library;

  return Object_exists(qSrvPgm: '*SRVPGM');

end-proc;

//----------------------------------------------------------------------
//  Resolves the object library.
//----------------------------------------------------------------------
dcl-proc Object_resolveLibrary export;
  dcl-pi *N char(10);
    object          const likeds(object_t);
    objType         char(10) const;
  end-pi;

  dcl-ds objd0100 likeds(objd0100_t) inz;
  dcl-ds errorCode likeds(errorCode_t) inz(*likeds);

  clear errorCode;
  errorCode.bytPrv = %size(errorCode);
  objd0100 = retrieveObjectDescription(object: objType: 'OBJD0100': errorCode);

  if (errorCode.bytAvl > 0);
    return '';
  endif;

  if (objd0100.bytRet = 0);
    return '';
  endif;

  return objd0100.rtnLib;

end-proc;

//----------------------------------------------------------------------
//  Resolves the object library.
//----------------------------------------------------------------------
dcl-proc Object_getAttribute export;
  dcl-pi *N char(10);
    object          const likeds(object_t);
    objType         char(10) const;
  end-pi;

  dcl-ds objd0200 likeds(objd0200_t) inz;
  dcl-ds errorCode likeds(errorCode_t) inz(*likeds);

  clear errorCode;
  errorCode.bytPrv = %size(errorCode);
  objd0200 = retrieveObjectDescription(object: objType: 'OBJD0200': errorCode);

  if (errorCode.bytAvl > 0);
    return '';
  endif;

  if (objd0200.bytRet = 0);
    return '';
  endif;

  return objd0200.extObjAtr;

end-proc;

//----------------------------------------------------------------------
//  Returns *ON when the source member is younger than the object.
//----------------------------------------------------------------------
dcl-proc Object_isDirty export;
  dcl-pi *N ind;
    object          const likeds(object_t);
    objType         char(10) const;
  end-pi;

  dcl-ds objd0300 likeds(objd0300_t) inz;
  dcl-ds apiDateTime qualified;
    date   char(7);
    time   char(6);
  end-ds;
  dcl-ds qSrcFile likeds(object_t);
  dcl-s srcMbr char(10);
  dcl-ds obj qualified;
    crtDate         timestamp;
    srcLastChgDate  timestamp;
  end-ds;
  dcl-ds src qualified;
    lastChgDate     timestamp;
  end-ds;

  objd0300 = retrieveObjectDescription(object: objType: 'OBJD0300');

  apiDateTime = objd0300.crtDatTim;
  obj.crtDate = %date(apiDateTime.date: *cymd0) +
                %time(apiDateTime.time: *hms0);

  if (objd0300.srcFile = '' or
      objd0300.srcLib = '' or
      objd0300.srcMbr = '');
    return *on;
  endif;

  if (objd0300.srcfDatTim <> '');
    apiDateTime = objd0300.srcfDatTim;
    obj.srcLastChgDate = %date(apiDateTime.date: *cymd0) +
                         %time(apiDateTime.time: *hms0);
  else;
    obj.srcLastChgDate = *loval;
  endif;

  qSrcFile.nm = objd0300.srcFile;
  qSrcFile.lib = objd0300.srcLib;
  srcMbr = objd0300.srcMbr;

  src.lastChgDate = SrcMbr_getLastChgDate(qSrcFile: srcMbr);

  if (src.lastChgDate > obj.crtDate or
      src.lastChgDate > obj.srcLastChgDate);
    return *on;
  endif;

  return *off;

end-proc;

//----------------------------------------------------------------------
//  Returns *ON when the specified object exists, else *OFF.
//----------------------------------------------------------------------
dcl-proc Object_exists export;
  dcl-pi *N ind;
    object          const likeds(object_t);
    objType         char(10) const;
    mbr             char(10) const options(*nopass);
  end-pi;

  dcl-ds objd0100 likeds(objd0100_t) inz;
  dcl-ds mbrd0100 likeds(mbrd0100_t) inz;
  dcl-ds errorCode likeds(errorCode_t) inz(*likeds);

  if (%parms() >= %parmnum(mbr) and %addr(mbr) <> *null);
    mbrd0100 = retrieveMemberDescription(object: mbr: 'MBRD0100': errorCode);
  else;
    objd0100 = retrieveObjectDescription(object: objType: 'OBJD0100': errorCode);
  endif;

  if (errorCode.bytAvl = 0);
    return *on;
  endif;

  return *off;

end-proc;

//----------------------------------------------------------------------
//  Returns the qualified object name.
//----------------------------------------------------------------------
dcl-proc Object_qName export;
  dcl-pi *N varchar(21);
    object          const likeds(object_t);
  end-pi;

  dcl-s qName varchar(21);

  qName = %trim(object.lib) + '/' + %trim(object.nm);

  return qName;

end-proc;

//----------------------------------------------------------------------
//  Returns the object description of a given object.
//----------------------------------------------------------------------
dcl-proc retrieveObjectDescription;
  dcl-pi *N char(4096);
    object          const likeds(object_t);
    objType         char(10) const;
    format          char(8) const;
    errorCode       likeds(errorCode_t) options(*nopass: *omit);
  end-pi;

  dcl-ds objDesc len(4096);
    bytRet          int(10);
    bytAvl          int(10);
  end-ds;

  clear objDesc;

  if (%parms() >= %parmnum(errorCode) and %addr(errorCode) <> *null);
    qusrobjd(objDesc:%size(objDesc):format:object:objType:errorCode);
  else;
    qusrobjd(objDesc:%size(objDesc):format:object:objType);
  endif;

  return objDesc;

end-proc;

//----------------------------------------------------------------------
//  Returns the object description of a given object.
//----------------------------------------------------------------------
dcl-proc retrieveMemberDescription;
  dcl-pi *N char(4096);
    file            const likeds(object_t);
    member          char(10) const;
    format          char(8) const;
    errorCode       likeds(errorCode_t) options(*nopass: *omit);
  end-pi;

  dcl-ds fileDesc len(4096);
    bytRet   int(10);
    bytAvl   int(10);
  end-ds;

  clear fileDesc;

  if (%parms() >= %parmnum(errorCode) and %addr(errorCode) <> *null);
    qusrmbrd(
      fileDesc: %size(fileDesc): format: file: member: '0': errorCode);
  else;
    qusrmbrd(
      fileDesc: %size(fileDesc): format: file: member:'0');
  endif;

  return fileDesc;

end-proc;

