**FREE
// ==========================================================================
//  iRPGUnit - Library list Utilities.
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

ctl-opt nomain;
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   Exported Procedures
//----------------------------------------------------------------------

/include qinclude,LIBL

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,MEMMGR
/include qinclude,TEMPLATES
/include qinclude,SYSTEMAPI
/include qinclude,ERRORCODE

//----------------------------------------------------------------------
//   Procedure Definitions
//----------------------------------------------------------------------

dcl-proc getLibl export;
  dcl-pi *N likeds(liblData_t   );
  end-pi;

  dcl-s i               int(10);
  dcl-ds libldata likeds(liblData_t);
  dcl-ds apiinfo qualified;
    bytRet  int(10);
    bytAvl  int(10);
  end-ds;
  dcl-ds jobi0700 likeds(jobi0700_t) based(pjobi0700);
  dcl-s liblE char(11) based(plible);
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  qusrjobi(apiinfo: %size(apiinfo): 'JOBI0700': '*': '': percolateErrors);


  pjobi0700 = MemMgr_alloc(apiinfo.bytAvl: 'pjobi0700');

  qusrjobi(jobi0700: apiinfo.bytAvl: 'JOBI0700': '*': '': percolateErrors);

  clear libldata;
  libldata.libl.nume = jobi0700.numUsrLibE;

  plible = %addr(jobi0700) + %size(jobi0700)
                           + jobi0700.numSysLibE * 11
                           + jobi0700.numPrdLibE * 11
                           + jobi0700.numCurLibE * 11;
  for i = 1 to libldata.libl.nume;
    libldata.libl.lib(i) = liblE;
    plible = plible + 11;
  endfor;

  if (jobi0700.numCurLibE > 0);
    plible = %addr(jobi0700) + %size(jobi0700)
                             + jobi0700.numSysLibE * 11
                             + jobi0700.numPrdLibE * 11;
    libldata.curlib = liblE;
  else;
    libldata.curlib = '*CRTDFT';
  endif;

  MemMgr_dealloc(pjobi0700: 'pjobi0700');

  return libldata;

end-proc;


dcl-proc loadLibl export;
  dcl-pi *N likeds(liblData_t   );
    qJobD           const  likeds(object_t  );
  end-pi;

  dcl-s i               int(10);
  dcl-ds libldata likeds(liblData_t);
  dcl-ds apiinfo qualified;
    bytRet          int(10);
    bytAvl          int(10);
  end-ds;
  dcl-ds jobd0100 likeds(jobd0100_t) based(pjobd0100);
  dcl-s lible           char(11) based(plible);
  dcl-ds percolateErrors
         likeds(percolateErrors_t)
  inz(*likeds);

  qwdrjobd(
        apiinfo: %size(apiinfo): 'JOBD0100': qJobD: percolateErrors);

  pjobd0100 = MemMgr_alloc(apiinfo.bytAvl: 'pjobd0100');

  qwdrjobd(
        jobd0100: apiinfo.bytAvl: 'JOBD0100': qJobD: percolateErrors);

  clear libldata;
  libldata.libl.nume = jobd0100.numInlLiblE;

  plible = %addr(jobd0100) + jobd0100.ofsInlLibl;
  for i = 1 to libldata.libl.nume;
    libldata.libl.lib(i) = lible;
    plible = plible + 11;
  endfor;

  libldata.curlib = '*CRTDFT';

  MemMgr_dealloc(pjobd0100: 'pjobd0100');

  return libldata;

end-proc;


dcl-proc restoreLibl export;
  dcl-pi *N;
    libldata        const  likeds(liblData_t);
  end-pi;

  dcl-s i               int(10) inz;

  dcl-ds inllibl qualified;
    nume            int(10) pos(1) inz;
    lib             char(11) dim(250) pos(5) inz;
    libs            char(2750) pos(5);
  end-ds;
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  for i = 1 to libldata.libl.nume;
    inllibl.lib(i) = libldata.libl.lib(i);
    inllibl.nume += 1;
  endfor;

  qlichgll(libldata.curlib: '*SAME': '*SAME': inllibl.libs: inllibl.nume: percolateErrors);

end-proc;


dcl-proc changeLibl export;
  dcl-pi *N;
    curlib          char(10) const;
    libl            const  likeds(libl_t);
  end-pi;

  dcl-s i               int(10);
  dcl-ds libldata likeds(liblData_t) inz;

  libldata.curlib = curlib;

  for i = 1 to libl.nume;
    libldata.libl.lib(i) = libl.lib(i);
    libldata.libl.nume += 1;
  endfor;

  restoreLibl(libldata);

end-proc;


dcl-proc setTestSuiteLibl export;
  dcl-pi *N              ind;
    libl            value likeds(libl_t);
    jobD            value likeds(object_t);
    testpgmlib      char(10) value;
  end-pi;

  dcl-ds loadedlibl likeds(liblData_t);

  select;
  when (libl.nume = 1);
    select;
    when (libl.lib(1) = LIBRARY_LIST_JOBD);
      if (jobD.nm = JOBD_DEFAULT);
        jobD.nm = 'RPGUNIT';
        jobD.lib = testpgmlib;
      endif;
      loadedlibl = loadLibl(jobD);
      restoreLibl(loadedlibl);
      return *on;
    when (libl.lib(1) = LIBRARY_LIST_CURRENT);
    // keep current library list
    other;
      changeLibl('*CRTDFT': libl);
      return *on;
    endsl;

  when (libl.nume > 1);
    changeLibl('*CRTDFT': libl);
    return *on;
  endsl;

  return *off;

end-proc;

