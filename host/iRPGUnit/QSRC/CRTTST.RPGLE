**FREE
// ==========================================================================
//  iRPGUnit - Implementation of RUCRT* commands.
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

/include qinclude,H_SPEC
/include qinclude,COPYRIGHT


//----------------------------------------------------------------------
//   IMPORTS
//----------------------------------------------------------------------

/include qinclude,JOBLOG
/include qinclude,STRING
/include qinclude,LSTSPLF
/include qinclude,PGMMSG
/include qinclude,TEMPLATES
/include qinclude,SRCMBR
/include qinclude,STMF
/include qinclude,SYSTEMAPI
/include qinclude,TESTUTILS
/include qinclude,TAGTST
/include qinclude,OBJECT
/include qinclude,OSVERSION
/include qinclude,PGMMSG
/include qinclude,ERRORCODE

/include qsysinc,QCAPCMD
/include qsysinc,STAT


//----------------------------------------------------------------------
//   PUBLIC PROTOTYPES
//----------------------------------------------------------------------

/include qinclude,CRTTST

//----------------------------------------------------------------------
//   TYPE TEMPLATE
//----------------------------------------------------------------------

dcl-ds jobLogUserData_t qualified template;
  timelimit       timestamp;
  crtmsgid        char(7);
  modules         likeds(objectArray_t) inz;
end-ds;


//----------------------------------------------------------------------
//   GLOBAL VARIABLES
//----------------------------------------------------------------------

dcl-ds srvPgm likeds(object_t);


//---------------------------------------------------------------------
//   MAIN PROGRAM
//---------------------------------------------------------------------

dcl-proc crtTst export;
  dcl-pi *N;
    testPgm         likeds(object_t) const;
    srcFile         likeds(object_t) const;
    srcMbr          like(srcMbr_t.mbr) const;
    srcStmf         like(ifsStmf_t) const;
    text            like(text_t) const;
    cOption         likeds(options_t) const;
    dbgView         like(dbgView_t) const;
    bndSrvPgm       likeds(objectArray_t) const;
    bndDir          likeds(objectArray_t) const;
    bOption         likeds(options_t) const;
    define          likeds(defines_t) const;
    dltSplF         like(yesno_t) const;
    actGrp          like(activationGroup_t) const;
    bModules        likeds(objectArray_t) const;
    pRpgPpOpt       like(rpgPpOpt_t) const;
    pOption         likeds(options_t) const;
    compileOpt      like(compileOpt_t) const;
    targetRls       like(targetRelease_t) const;
    incDir          likeds(incDir_t) const;
    tgtCcsid        like(tgtCcsid_t) const;
  end-pi;

  dcl-ds modules likeds(bModules) inz;
  dcl-s srcType varchar(10);
  dcl-s textRslv like(text) inz;
  dcl-s i int(10);
  dcl-s mbrtype char(10);
  dcl-ds tmpopts likeds(options_t) inz;
  dcl-ds qSrcfile likeds(object_t) inz;
  dcl-s librslv char(10);
  dcl-s startcompiletime timestamp;
  dcl-ds modulescreated likeds(objectArray_t) inz;
  dcl-s srcMbrRslv like(srcMbr);
  dcl-s localSrcStmf like(srcStmf);
  dcl-s localSrcMbr like(srcStmf);
  dcl-ds st_stat likeds(st_stat_t) inz;
  dcl-s srcCcsid like(ccsid_t);
  dcl-s rc int(10);

  dcl-s isError ind;

  qSrcfile = srcFile;

  if (srcMbr = '*TSTPGM');
    srcMbrRslv = testPgm.nm;
  else;
    srcMbrRslv = srcMbr;
  endif;

  if (isStmf(srcStmf));

    // Verify that the source stream file exists
    localSrcStmf = %trim(%xlate('\': '/': srcStmf));
    rc = stat(localSrcStmf: st_stat); // -1 = error, not found
    if (rc = -1);
      sndEscapeMsgAboveCtlBdy('Stream file not found: ' + localSrcStmf);
    endif;

    srcCcsid = Stmf_getCcsid(localSrcStmf);

    // Validate we have a source member type
    srcType = uCase(Stmf_getType(localSrcStmf));
    if (srcType = '');
      sndEscapeMsgAboveCtlBdy( 'Could not retrieve source type of stream file '
                             + localSrcStmf
                             + '.' );
    endif;
  else;

    // Verify that the source file exists
    if (not Object_exists(qSrcfile: '*FILE'));
      sndEscapeMsgAboveCtlBdy(
         'Source file ' + %trim(qSrcfile.nm) + ' not found in library '+
                          %trim(qSrcfile.lib) + '.' );
    endif;

    // Resolve source file library special values
    if (%subst(qSrcfile.lib: 1: 1) = '*');
      librslv = Object_resolveLibrary(qSrcfile: '*FILE');
    else;
      if (not Object_exists(qSrcfile: '*FILE'));
        librslv = '';
      else;
        librslv = qSrcfile.lib;
      endif;
    endif;

    if (librslv = '');
      sndEscapeMsgAboveCtlBdy(
        'Library ' + %trim(qSrcfile.lib) + ' not found.' );
    endif;

    qSrcfile.lib = librslv;

    // Verify that the source member exists
    if (not Object_exists(qSrcfile: '*FILE': srcMbrRslv));
      sndEscapeMsgAboveCtlBdy(
         'Member ' + %trim(srcMbrRslv) + ' not found in source file ' +
                     %trim(qSrcfile.lib) + '/' + %trim(qSrcfile.nm) + '.' );
    endif;

    localSrcMbr = '/QSYS.LIB/'
                   + %trim(qSrcfile.lib) + '.LIB/'
                   + %trim(qSrcfile.nm) + '.FILE/'
                   + %trim(srcMbrRslv) + '.MBR';
    rc = stat(localSrcMbr: st_stat); // -1 = error, not found
    if (rc = -1);
      sndEscapeMsgAboveCtlBdy(
         'Source member ' + %trim(localSrcMbr) + ' not found.');
    endif;

    srcCcsid = SrcMbr_getCcsid(qSrcfile);

    // Ensure we have a valid EVFEVENT file member name for RDi
    if (srcMbrRslv = '*TSTPGM');
      mbrtype = getMemberType(qSrcfile.nm: qSrcfile.lib: testPgm);
      if (mbrtype = MBR_RPGLE);
        tmpopts = coption;
      else;
        tmpopts = poption;
      endif;
      for i = 1 to tmpopts.size;
        if (tmpopts.option(i) = '*EVENTF');
          sndEscapeMsgAboveCtlBdy(
             'Compile option *EVENTF is not +
              allowed with source member *TSTPGM, +
              because it does not work in RDi. Specify +
              the name of the source member.' );
        endif;
      endfor;
    endif;

    // Validate we have a source member type
    srcType = uCase(SrcMbr_getType(srcFile: srcMbrRslv));
    if (srcType = '');
      sndEscapeMsgAboveCtlBdy( 'Could not retrieve source type of member '
                             + %trim(srcMbrRslv)
                             + ' of file '
                             + %trim(srcFile.lib) + '/' + %trim(srcFile.nm)
                             + '.' );
    endif;
  endif;

  modules = resolveLibraries(bModules);

  isError = *off;

  monitor;

    select;
    when text = '*SRCMBRTXT';
      if (isStmf(localSrcStmf));
        textRslv = '';
      else;
        textRslv = SrcMbr_getDescription(qSrcfile: srcMbrRslv);
      endif;
    when text = '*BLANK';
      textRslv = '';
    when text = '*DEFAULT';
      textRslv = 'RPGUnit - Test Case';
    when not startsWith('RPGUnit' : text);
      textRslv = 'RPGUnit - ' + text;
    other;
      textRslv = text;
    endsl;

    startcompiletime = %timestamp();

    select;
    when (srcType = MBR_RPGLE or srcType = MBR_SQLRPGLE);
      addModule( modules : testPgm : *on); // Add to position #1.
      // QDEVTOOLS/QLNCMSG RNS9305 - Module &1 placed in library &2.
      crtRpgMod(testPgm: qSrcfile: srcMbrRslv: localSrcStmf: coption: dbgview:
                 pRpgPpOpt: poption: compileopt: targetRls: define: incDir: tgtCcsid: srcCcsid);
      modulescreated = getCreatedModulesFromJobLog(
                         MOD_CRT_RPG : startcompiletime );
      addModules( modules : modulescreated );
    when (srcType = MBR_CBLLE or srcType = MBR_SQLCBLLE);
      // There is no test case module to add for Cobol ==> See: *PGMID
      // QDEVTOOLS/QLNCMSG LNC0899 - Module &1 placed in library &2.
      crtCblMod(testPgm: qSrcfile: srcMbrRslv: localSrcStmf: coption: dbgview:
                 poption: compileopt: targetRls: define: incDir: tgtCcsid: srcCcsid);
      modulescreated = getCreatedModulesFromJobLog(
                         MOD_CRT_CBL : startcompiletime );
      addModules( modules : modulescreated );
    other;
      sndEscapeMsgAboveCtlBdy(
        'Source type ' + addQuotes(srcType) + ' is not supported.' );
    endsl;

    srvPgm = crtSrvPgm(
                testPgm : bndSrvPgm : bndDir : modules : bOption :
                actGrp : textRslv : targetRls);

      tagTstSrvPgm(srvPgm : qSrcfile : srcMbrRslv: localSrcStmf);
      // sndCompMsg( 'Updated (tagged) test suite ' + %trim(srvPgm.nm) + '.' );

    sndCompMsg( 'Test program ' + %trim(srvPgm.nm)
              + ' created in library ' + %trim(srvPgm.lib) + '.' );

  on-error;
    isError = *on;
  endmon;

  monitor;
    deleteModulesAndSpooledFiles(
      dltsplf : startcompiletime : modulescreated );
  on-error;
  endmon;

  if (isError);
    if (srvPgm.nm <> '' and srvPgm.lib <> '');
      sndEscapeMsgAboveCtlBdy( 'Unable to update (tag) test suite '
                               + %trim(srvPgm.nm) + '.' );
    else;
      sndEscapeMsgAboveCtlBdy( 'Unable to create test '
                               + %trim(testPgm.nm) + '.' );
    endif;
  endif;

  *inlr = *on;

end-proc;


dcl-proc isStmf;
  dcl-pi *N ind extproc(*dclcase);
    stmf   like(ifsStmf_t) const;
  end-pi;

  if (stmf <> '');
    return *on;
  else;
    return *off;
  endif;

end-proc;

dcl-proc resolveLibraries;
  dcl-pi *N likeds(objectArray_t);
    modules   likeds(objectArray_t) const;
  end-pi;

  dcl-s i int(10);
  dcl-ds rtnModules likeds(modules) inz;
  dcl-s libResolved char(10);

  clear rtnModules;

  for i = 1 to modules.size;

    if (startsWith( '*' : modules.object(i).lib));
      libResolved = Object_resolveLibrary(modules.object(i): '*MODULE');
    else;
      libResolved = modules.object(i).lib;
    endif;

    if (libResolved = '');
      sndEscapeMsgAboveCtlBdy( 'Could not resolve module '
                             +  Object_qName(modules.object(i)) );
    endif;

    rtnModules.size += 1;
    rtnModules.object(rtnModules.size).nm = modules.object(i).nm;
    rtnModules.object(rtnModules.size).lib = libResolved;
  endfor;

  return rtnModules;

end-proc;


dcl-proc getCreatedModulesFromJobLog;
  dcl-pi *N likeds(objectArray_t);
    crtmsgid        char(7) const;
    timelimit       timestamp const;
  end-pi;

  dcl-s hreader like(hjoblogreader_t);
  dcl-ds userdata likeds(jobLogUserData_t);

  clear userdata;
  userdata.timelimit = timelimit;
  userdata.crtmsgid = crtmsgid;

  hreader = JobLogReader_init(jl_rd_previous);
  joblogreader_addfield(hreader: OLJL_RPL_DATA);
  joblogreader_read(hreader: %paddr('jobLogCallback'): %addr(userdata));

  return userdata.modules;

end-proc;


dcl-proc jobLogCallback;
  dcl-pi *n ind extproc(*dclcase);
    i_hMsgInfo      pointer const;
    i_pUserData     pointer const;
    i_msgId         char(7) const;
    i_msgText       varchar(132) const;
    i_msgSentTime   timestamp const;
  end-pi;

  dcl-ds userData likeds(jobLogUserData_t) based(i_pUserData);

  dcl-s msgData char(100);
  dcl-ds module likeds(object_t);

  dcl-ds rns9305 qualified based(pMsgData);
    mod   char(10);
    lib   char(10);
  end-ds;

  dcl-ds lnc0899 qualified based(pMsgData);
    length   int(5);
    data     char(10);
  end-ds;

  if (i_msgSentTime < userData.timelimit);
    return *off;
  endif;

  if (i_msgId = userData.crtmsgid);

    msgData = JobLogReader_getCharValue(i_hMsgInfo: OLJL_RPL_DATA);
    pMsgData = %addr(msgData);

    select;
    when (userData.crtmsgid = MOD_CRT_RPG);
      module.nm = rns9305.mod;
      module.lib = rns9305.lib;
      addModule( userData.modules : module );
    when (userData.crtmsgid = MOD_CRT_CBL);
      module.nm = %subst(lnc0899.data: 1: lnc0899.length);
      pMsgData += lnc0899.length + %size(lnc0899.length); // push pointer to next *VARY field
      module.lib = %subst(lnc0899.data: 1: lnc0899.length);
      addModule( userData.modules : module );
    endsl;
  endif;

  return *on;

end-proc;


dcl-proc addModules;
  dcl-pi *N;
    modules   likeds(objectArray_t);
    items     likeds(objectArray_t);
  end-pi;

  dcl-s i int(10);


  for i = 1 to items.size;
    addModule(modules: items.object(i));
  endfor;

end-proc;


dcl-proc addModule;
  dcl-pi *N;
    modules      likeds(objectArray_t);
    module       likeds(object_t) const;
    isfirstmod   ind options(*nopass) const;
  end-pi;

  dcl-s i int(10);
  dcl-s r int(10);


  if (%parms() >= %parmnum(isfirstmod));
    // First remove module (if found)
    for i = 1 to modules.size;
      if (module.nm = modules.object(i).nm and
          module.lib = modules.object(i).lib);
        r = i;
      endif;
      if (r > 0 and  r < i);
        modules.object(r) = modules.object(i);
        clear modules.object(i);
        r = i;
      endif;
    endfor;
    if (r > 0 and r < i);
      modules.size -= (i - r);
    endif;
    // Shift modules 1 item up
    for i = modules.size downto 1;
      modules.object(i + 1) = modules.object(i);
      clear modules.object(i);
    endfor;
    modules.size += 1;
    modules.object(1) = module;
  else;
    for i = 1 to modules.size;
      if (module.nm = modules.object(i).nm and
          module.lib = modules.object(i).lib);
        return;
      endif;
    endfor;
    modules.size += 1;
    modules.object(modules.size) = module;
  endif;

end-proc;


dcl-proc crtRpgMod;
  dcl-pi *N;
    testpgm         const likeds(object_t);
    srcFile         const likeds(object_t);
    srcMbr          const like(srcMbr_t.mbr);
    srcStmf         like(ifsStmf_t) const;
    coption         const likeds(options_t);
    dbgview         const like(dbgView_t);
    prpgppopt       const like(rpgPpOpt_t);
    poption         const likeds(options_t);
    compileopt      const like(compileOpt_t);
    targetrls       const like(targetRelease_t);
    define          const likeds(defines_t);
    incDir          likeds(incDir_t) const;
    tgtCcsid        like(tgtCcsid_t) const;
    srcCcsid        like(cvtCcsid_t) const;
  end-pi;

  // A command to be executed.
  dcl-s cmd like(cmd_t);

  cmd = getCrtRpgModCmd(testpgm: srcFile: srcMbr: srcStmf: coption: dbgview:
                         prpgppopt: poption: compileopt: targetrls:
                         define: incDir: tgtCcsid: srcCcsid);
  sndCmdToJobLog(cmd);
  qcmdexc(cmd: %len(cmd));

end-proc;


dcl-proc sndCmdToJobLog;
  dcl-pi *N extproc(*dclcase);
    cmd   like(cmd_t) const options(*varsize);
  end-pi;

  dcl-s start int(10);
  dcl-s end int(10);
  dcl-s chunk varchar(74);

  dcl-c INDENT_2 '  ';

  // Send CL command
  start = 1;
  end = %scan(' ': cmd);
  if (end = 0);
    sndInfoMsg(cmd);
    return;
  endif;

  chunk = %subst(cmd: start: end - 1);
  sndInfoMsg(chunk);
  start = end + 1;

  // Send command parameters
  sndCmdParmToJobLog(%subst(cmd: start): INDENT_2);

end-proc;


dcl-proc sndCmdParmToJobLog;
  dcl-pi *N extproc(*dclcase);
    cmdParams     like(cmd_t) const options(*varsize);
    firstIndent   varchar(4) const;
  end-pi;

  dcl-s start int(10);
  dcl-s end int(10);
  dcl-s length int(10);
  dcl-s offset int(10);
  dcl-s chunk varchar(74);
  dcl-s count int(10);
  dcl-s indention varchar(4);

  dcl-c INDENT_2 '  ';

  start = 1;
  count = 0;

  dou (start > %len(cmdParams) or end = 0);

    // Skip keyword
    end = %scan('(': cmdParams: start);
    if (end > 0);
      // Find end of keywork parameters
      dow (end <= %len(cmdParams));
        if (%subst(cmdParams: end: 1) = '(');
          count += 1;
        elseif (%subst(cmdParams: end: 1) = ')');
          count -= 1;
          if (count = 0);
            // Send KEYWORD(...) to job log
            indention = firstIndent;
            length = end - start + 1;
            offset = 0;
            dow (length > 0);
              if (length + %len(indention) <= %len(chunk: *max));
                chunk = %subst(cmdParams: offset + start: length);
              else;
                chunk = %subst(cmdParams: offset + start: %len(chunk: *max) - %len(indention));
              endif;
              sndInfoMsg(indention + %trim(chunk));
              indention = firstIndent + INDENT_2;
              length -= %len(chunk);
              offset += %len(chunk);
            enddo;
            start = end + 1;
          endif;
        endif;
        end += 1;
      enddo;
    endif;

  enddo;

end-proc;


dcl-proc crtCblMod;
  dcl-pi *N;
    testpgm         likeds(object_t) const;
    srcFile         likeds(object_t) const;
    srcMbr          like(srcMbr_t.mbr) const;
    srcStmf         like(ifsStmf_t) const;
    coption         likeds(options_t) const;
    dbgview         like(dbgView_t) const;
    poption         likeds(options_t) const;
    compileopt      like(compileOpt_t) const;
    targetrls       like(targetRelease_t) const;
    define          likeds(defines_t) const;
    incDir          likeds(incDir_t) const;
    tgtCcsid        like(tgtCcsid_t) const;
    srcCcsid        like(cvtCcsid_t) const;
  end-pi;

  // A command to be executed.
  dcl-s cmd like(cmd_t);


  cmd = getCrtCblModCmd(testpgm: srcFile: srcMbr: srcStmf: coption: dbgview:
                        poption: compileopt: targetrls:
                        define: incDir: tgtCcsid: srcCcsid);
  sndInfoMsg(cmd);
  qcmdexc(cmd: %len(cmd));

end-proc;


dcl-proc deleteModulesAndSpooledFiles;
  dcl-pi *N;
    dltsplf         ind const;
    starttime       timestamp const;
    modules         const likeds(objectArray_t);
  end-pi;


  dcl-s i int(10);
  dcl-s cmd like(cmd_t);

  dcl-s hLister like(hsplflister_t);
  dcl-ds qJob likeds(job_t);

  clear qJob;
  qJob.name = '*';

  for i = 1 to modules.size;
    cmd = getDltModCmd( modules.object(i) );
    qcmdexc(cmd: %len(cmd));

    if (dltsplf);
      hLister = splflister_init(qJob);
      splfLister_list(hLister: %paddr('deleteSplfCallback'));
    endif;
  endfor;

end-proc;


dcl-proc deleteSplfCallback;
  dcl-pi *n ind extproc(*dclcase);
    i_hsplf         pointer const;
    i_puserdata     pointer const;
    i_splfnm        char(10) const;
    i_qJob          const likeds(job_t);
    i_splfnbr       int(10) const;
    i_filestatus    char(10) const;
  end-pi;

  dcl-s cmd             like(cmd_t);

  cmd = 'DLTSPLF FILE(' + %trim(i_splfnm) + ') +
           JOB(' + %trim(i_qJob.nbr) + '/' +
                   %trim(i_qJob.user) + '/' +
                   %trim(i_qJob.name) + ') +
           SPLNBR(' + %char(i_splfnbr) + ')';

  qcmdexc(cmd: %len(cmd));

  return *on;

end-proc;

dcl-proc crtSrvPgm;
  dcl-pi *N likeds(object_t);
    testPgm         const likeds(object_t);
    bndSrvPgm       const likeds(objectArray_t);
    bndDir          const likeds(objectArray_t);
    module          const likeds(objectArray_t);
    bOption         const likeds(options_t);
    actGrp          const like(activationGroup_t);
    text            const like(text_t);
    targetRls       const like(targetRelease_t);
  end-pi;

  // Export all procedures from the service program.
  dcl-c export_all const('*ALL');
  // A command to be executed.
  dcl-s cmd like(cmd_t);
  // Bound Service Programs, with RPGUnit services included.
  dcl-ds bndSrvPgmWithRU likeds(objectArray_t);
  // Completion message data.
  dcl-s compMsgData char(256);
  // Target service program.
  dcl-ds targetSrvPgm likeds(object_t);

  dcl-s i int(10);
  dcl-s haveRpgUnitRuntime ind;

  clear bndSrvPgmWithRU;
  haveRpgUnitRuntime = *off;
  for i = 1 to bndSrvPgm.size;
    bndSrvPgmWithRU.object = bndSrvPgm.object;
    bndSrvPgmWithRU.size += 1;
    if (bndSrvPgmWithRU.object(i).nm = 'RUTESTCASE');
      haveRpgUnitRuntime = *on;
    endif;
  endfor;

  if (not haveRpgUnitRuntime);
    bndSrvPgmWithRU.size += 1;
    bndSrvPgmWithRU.object(bndSrvPgmWithRU.size).nm = 'RUTESTCASE';
    bndSrvPgmWithRU.object(bndSrvPgmWithRU.size).lib = '*LIBL';
  endif;

  cmd = getCrtSrvPgmCmd( testPgm:
                         bndSrvPgmWithRU:
                         bndDir:
                         module :
                         bOption:
                         export_all :
                         actGrp:
                         text :
                         targetRls );
  sndInfoMsg( cmd );
  qcmdexc( cmd : %len(cmd) );

  compMsgData = rcvMsgData( '*COMP' );
  targetSrvPgm = %subst( compMsgData : 1 : 20 );

  return targetSrvPgm;

end-proc;


dcl-proc getCrtSrvPgmCmd export;
  dcl-pi *N       like(cmd_t);
    testpgm         const likeds(object_t);
    bndsrvpgm       const likeds(objectArray_t);
    bnddir          const likeds(objectArray_t);
    modules         const likeds(objectArray_t);
    options         const likeds(options_t);
    export          const like(export_t);
    actgrp          const like(activationGroup_t);
    text            const like(text_t );
    targetrls       const like(targetRelease_t);
  end-pi;

  // Command string accumulator.
  dcl-s cmd like(cmd_t);


  cmd = 'CRTSRVPGM SRVPGM(' + serializeObjectName( testpgm ) + ') ';
  cmd += serializeObjectArray( 'MODULE'    : modules   );
  cmd += serializeObjectArray( 'BNDSRVPGM' : bndsrvpgm );
  cmd += serializeObjectArray( 'BNDDIR'    : bnddir    );
  cmd += serializeOptions( 'OPTION' : options );
  cmd += serializeValue( 'ACTGRP' : actgrp );
  cmd += serializeString( 'TEXT' : text );
  cmd += serializeValue( 'TGTRLS' : targetrls );
  cmd += serializeString( 'DETAIL' : '*BASIC' );

  if export <> *blank;
    cmd += 'EXPORT(' + %trim(export) + ') ';
  endif;

  cmd = formatCommand(cmd);

  return cmd;

end-proc;


dcl-proc formatCommand;
  dcl-pi *N like(cmd_t);
    cmd   like(cmd_t) const;
  end-pi;

  dcl-ds optCtrlBlk likeds(qcapcmd_optCtrlBlk_t);

  dcl-s rtncmd char(32702);
  dcl-s rtncmdlenavl int(10);
  dcl-ds errcode likeds(percolateErrors_t) inz(*likeds);

  clear optCtrlBlk;
  optCtrlBlk.typeCmdPrc = 1;     // QCMDCHK API
  optCtrlBlk.dbcs_data = '0';    // ignore DBCS
  optCtrlBlk.prmtAction = '0';   // never prompt
  optCtrlBlk.cmdStrSyntax = '0'; // AS/400 Syntax
  optCtrlBlk.msgRtvKey = '';     // no msg key
  optCtrlBlk.res_01 = *allx'00';

  qcapcmd( cmd : %len(cmd) : optCtrlBlk : %size(optCtrlBlk) : 'CPOP0100'
         : rtncmd : %len(rtncmd) : rtncmdlenavl : errcode);

  return %subst(rtncmd: 1: rtncmdlenavl);

end-proc;


dcl-proc getCrtRpgModCmd export;
  dcl-pi *N       like(cmd_t);
    testPgm         likeds(object_t) const;
    srcFile         likeds(object_t) const;
    srcMbr          like(srcMbr_t.mbr) const;
    srcStmf         like(ifsStmf_t) const;
    cOption         likeds(options_t)const;
    dbgView         like(dbgView_t)const;
    pRpgPpOpt       like(rpgPpOpt_t)const;
    pOptions        likeds(options_t)const;
    compileOpt      like(compileOpt_t)const;
    targetRls       like(targetRelease_t)const;
    define          likeds(defines_t)const;
    incDir          likeds(incDir_t) const;
    tgtCcsid        like(tgtCcsid_t) const;
    srcCcsid        like(cvtCcsid_t) const;
  end-pi;

  // Command string accumulator.
  dcl-s cmd like(cmd_t);
  dcl-s dbgCompileOpt like(compileOpt);
  dcl-s srcType char(10);

  if (isStmf(srcStmf));
    srcType = uCase(getStmfType(srcStmf));
  else;
    srcType = uCase(getMemberType(srcFile.nm: srcFile.lib: srcMbr));
  endif;

  // source type determines the compile command
  select;
  // RPGLE
  when (srcType = MBR_RPGLE);
    cmd = 'CRTRPGMOD MODULE(' + serializeObjectName( testPgm ) + ') ';
    if (isStmf(srcStmf));
      cmd += 'SRCSTMF(' + serializeStmfPath( srcStmf ) + ') ';
      cmd += serializeIncDir(incDir);
    else;
      cmd += 'SRCFILE(' + serializeObjectName( srcFile ) + ') ';
      cmd += serializeValue( 'SRCMBR' : srcMbr );
    endif;
    cmd += serializeOptions( 'OPTION' : cOption );
    cmd += serializeValue( 'TGTRLS' : targetRls );
    cmd += serializeValue( 'DBGVIEW' : dbgView );
    cmd += serializeDefines(define);
    cmd += serializeTgtCcsid(tgtCcsid);

  // SQLRPGLE
  when (srcType = MBR_SQLRPGLE);
    cmd = 'CRTSQLRPGI OBJ(' + serializeObjectName( testPgm ) + ') ';
    if (isStmf(srcStmf));
      cmd += 'SRCSTMF(' + serializeStmfPath( srcStmf ) + ') ';
      cmd += serializeIncDir(incDir);
    else;
      cmd += 'SRCFILE(' + serializeObjectName( srcFile ) + ') ';
      cmd += serializeValue( 'SRCMBR' : srcMbr );
    endif;
    cmd += serializeOptions( 'OPTION' : pOptions );
    cmd += serializeValue('OBJTYPE': '*MODULE');
    cmd += serializeValue( 'TGTRLS' : targetRls );
    cmd += serializeValue( 'DBGVIEW' : dbgView);

    if (isStmf(srcStmf));
      // Check, if parameter CVTCCSID is present (release level/PTF status)
      if (haveCvtCcsidParam());
        cmd += serializeCvtCcsid(tgtCcsid: srcCcsid);
      else;
        if (srcCcsid = 1208);
          sndEscapeMsgAboveCtlBdy(
            'Stream file with CCSID 1208 cannot be compiled, +
             because command CRTSQLRPGI does not support +
             parameter CVTCCSID. Install missing PTFs and +
             try again.');
        endif;
      endif;
    endif;

    if (pRpgPpOpt <> '*DEFAULT');
      cmd += serializeValue( 'RPGPPOPT' : pRpgPpOpt);
    endif;

    if compileOpt <> '';
      dbgCompileOpt = %trim(removequotes(compileOpt)) + ' ';
      if (%scan( PARM_DEFINE + '(' : uCase( compileOpt )) = 0);
        dbgCompileOpt += serializeDefines(define);
      endif;
      if (%scan( PARM_TGTCCSID + '(' : uCase( compileOpt )) = 0);
        dbgCompileOpt += serializeTgtCcsid(tgtCcsid);
      endif;
      if (%scan( PARM_INCDIR + '(' : uCase( compileOpt )) = 0);
        dbgCompileOpt += serializeIncDir(incDir);
      endif;
      if (%scan( PARM_OPTION + '(' : uCase( cOption )) = 0);
        dbgCompileOpt += serializeOptions( 'OPTION' : cOption );
      endif;
    else;
      dbgCompileOpt = serializeDefines(define);
      dbgCompileOpt += serializeTgtCcsid(tgtCcsid);
      dbgCompileOpt += serializeIncDir(incDir);
      dbgCompileOpt += serializeOptions( 'OPTION' : cOption );
    endif;

    cmd += serializeString( 'COMPILEOPT' : dbgCompileOpt);

  // something we don't know about yet
  other;
    cmd = 'RUCRTRPG: Unknown source member type';
  endsl;

  cmd = formatCommand(cmd);

  return cmd;

end-proc;


dcl-proc getCrtCblModCmd export;
  dcl-pi *N       like(cmd_t);
    testpgm         const likeds(object_t);
    srcFile         const likeds(object_t);
    srcMbr          const like(srcMbr_t.mbr);
    srcStmf         like(ifsStmf_t) const;
    cOption         const likeds(options_t);
    dbgView         const like(dbgView_t);
    pOptions        const likeds(options_t);
    compileOpt      const like(compileOpt_t);
    targetRls       const like(targetRelease_t);
    define          const likeds(defines_t);
    incDir          likeds(incDir_t) const;
    tgtCcsid        like(tgtCcsid_t) const;
    srcCcsid        like(cvtCcsid_t) const;
  end-pi;

  // Command string accumulator.
  dcl-s cmd like(cmd_t);
  dcl-s dbgCompileOpt like(compileOpt);
  dcl-s srcType char(10);

  if (isStmf(srcStmf));
    srcType = uCase(getStmfType(srcStmf));
  else;
    srcType = uCase(getMemberType(srcFile.nm: srcFile.lib: srcMbr));
  endif;

  // source type determines the compile command
  select;
  // CBLLE
  when (srcType = MBR_CBLLE);
    cmd = 'CRTCBLMOD MODULE(*PGMID) ';
    if (isStmf(srcStmf));
      cmd += 'SRCSTMF(' + serializeStmfPath( srcStmf ) + ') ';
      cmd += serializeIncDir(incDir);
    else;
      cmd += 'SRCFILE(' + serializeObjectName( srcFile ) + ') ';
      cmd += serializeValue( 'SRCMBR' : srcMbr );
    endif;
    cmd += serializeOptions( 'OPTION' : cOption );
    cmd += serializeValue( 'TGTRLS' : targetRls );
    cmd += serializeValue( 'DBGVIEW' : dbgView );
    cmd += serializeDefines(define);
    cmd += serializeTgtCcsid(tgtCcsid);

  // SQLCBLLE
  when (srcType = MBR_SQLCBLLE);
    cmd = 'CRTSQLCBLI OBJ(' + serializeObjectName( testpgm ) + ') ';
    if (isStmf(srcStmf));
      cmd += 'SRCSTMF(' + serializeStmfPath( srcStmf ) + ') ';
      cmd += serializeIncDir(incDir);
    else;
      cmd += 'SRCFILE(' + serializeObjectName( srcFile ) + ') ';
      cmd += serializeValue( 'SRCMBR' : srcMbr );
    endif;
    cmd += serializeOptions( 'OPTION' : pOptions );
    cmd += serializeValue('OBJTYPE': '*MODULE');
    cmd += serializeValue( 'TGTRLS' : targetRls );
    cmd += serializeValue( 'DBGVIEW' : dbgView);

    if (isStmf(srcStmf));
      // Check, if parameter CVTCCSID is present (release level/PTF status)
      if (haveCvtCcsidParam());
        cmd += serializeCvtCcsid(tgtCcsid: srcCcsid);
      else;
        if (srcCcsid = 1208);
          sndEscapeMsgAboveCtlBdy(
            'Stream file with CCSID 1208 cannot be compiled, +
             because command CRTSQLCBLI does not support +
             parameter CVTCCSID. Install missing PTFs and +
             try again.');
        endif;
      endif;
    endif;

    if compileOpt <> '';
      dbgCompileOpt = %trim(removequotes(compileOpt)) + ' ';
      if (%scan( PARM_DEFINE + '(' : uCase( compileOpt )) = 0);
        dbgCompileOpt += serializeDefines(define);
      endif;
      if (%scan( PARM_TGTCCSID + '(' : uCase( compileOpt )) = 0);
        dbgCompileOpt += serializeTgtCcsid(tgtCcsid);
      endif;
      if (%scan( PARM_INCDIR + '(' : uCase( compileOpt )) = 0);
        dbgCompileOpt += serializeIncDir(incDir);
      endif;
      if (%scan( PARM_OPTION + '(' : uCase( cOption )) = 0);
        dbgCompileOpt += serializeOptions( 'OPTION' : cOption );
      endif;
    else;
      dbgCompileOpt = serializeDefines(define);
      dbgCompileOpt += serializeTgtCcsid(tgtCcsid);
      dbgCompileOpt += serializeIncDir(incDir);
      dbgCompileOpt += serializeOptions( 'OPTION' : cOption );
    endif;

    cmd += serializeString( 'COMPILEOPT' : dbgCompileOpt);

  // something we don't know about yet
  other;
    cmd = 'RUCRTCBL: Unknown source member type';
  endsl;

  cmd = formatCommand(cmd);

  return cmd;

end-proc;


dcl-proc getDltModCmd;
  dcl-pi *N like(cmd_t);
    testPgm   const likeds(object_t);
  end-pi;

  // Command string accumulator.
  dcl-s cmd like(cmd_t);


  cmd = 'DLTMOD MODULE(' + serializeObjectName( testPgm ) + ') ';

  cmd = formatCommand(cmd);

  return cmd;

end-proc;


dcl-proc serializeObjectArray;
  dcl-pi *N like(serializedArray_t) extproc(*dclcase);
    headtoken   const like(headToken_t);
    array       const likeds(objectArray_t);
  end-pi;

  // Serialized Object Array.
  dcl-s serialized like(serializedArray_t);
  // Counter.
  dcl-s i int(10);


  if array.size = 0;
    return '';
  endif;

  serialized = %trim(headtoken) + '(';

  for i = 1 to array.size;
    if (i >= 2);
       serialized += ' ';
    endif;
    serialized += serializeObjectName( array.object(i) );
  endfor;

  serialized += ') ';

  return serialized;

end-proc;


dcl-proc serializeObjectName export;
  dcl-pi *N like(serializedObject_t);
    object   likeds(object_t) const;
  end-pi;

  // Serialized object name.
  dcl-s serialized like(serializedObject_t) inz('');

  if object.lib <> *blank;
    serialized += %trim(object.lib) + '/';
  endif;

  serialized += %trim(object.nm);

  return serialized;

end-proc;


dcl-proc serializeStmfPath;
  dcl-pi *N like(serializedStmf_t) extproc(*dclcase);
    srcStmf   like(ifsStmf_t) options(*varsize) const;
  end-pi;

  // Serialized object name.
  dcl-s serialized like(serializedStmf_t) inz('');

  serialized = addQuotes(%trim(srcStmf));

  return serialized;

end-proc;


dcl-proc serializeOptions;
  dcl-pi *N like(serializedOptions_t) extproc(*dclcase);
    headtoken   const like(headToken_t);
    options     const likeds(options_t);
  end-pi;

  // Serialized Options.
  dcl-s serialized like(serializedOptions_t);
  // Counter.
  dcl-s i int(10);

  if options.size = 0;
    return '';
  endif;

  serialized = %trim(headtoken) + '(';

  for i = 1 to options.size;
    if (i >= 2);
       serialized += ' ';
    endif;
    serialized += %trim(options.option(i));
  endfor;

  if options.size > 0;
    serialized += ') ';
  endif;

  return serialized;

end-proc;


dcl-proc serializeDefines;
  dcl-pi *N like(serializedOptions_t) extproc(*dclcase);
    defines     const likeds(defines_t);
  end-pi;

  // Serialized Options.
  dcl-s serialized like(serializedOptions_t);
  // Counter.
  dcl-s i int(10);

  if defines.size = 0;
    return '';
  endif;

  serialized = 'DEFINE(';

  for i = 1 to defines.size;
    if (i >= 2);
       serialized += ' ';
    endif;
    serialized += %trim(defines.define(i));
  endfor;

  if defines.size > 0;
    serialized += ') ';
  endif;

  return serialized;

end-proc;


dcl-proc serializeTgtCcsid;
  dcl-pi *N like(serializedTgtCcsid_t) extproc(*dclcase);
    tgtCcsid    const like(tgtCcsid_t);
  end-pi;

  // Serialized Options.
  dcl-s serialized like(serializedTgtCcsid_t);

  if (tgtCcsid = 0);
    return '';
  endif;

  serialized = 'TGTCCSID(';

  select;
  when (tgtCcsid = -2);
    serialized += '*SRC';
  when (tgtCcsid = -1);
    serialized += '*JOB';
  other;
    serialized += %char(tgtCcsid);
  endsl;

  serialized += ') ';

  return serialized;

end-proc;


dcl-proc serializeCvtCcsid;
  dcl-pi *N like(serializedTgtCcsid_t) extproc(*dclcase);
    tgtCcsid    like(tgtCcsid_t) const;
    cvtCcsid    like(cvtCcsid_t) const;
  end-pi;

  // Serialized Options.
  dcl-s serialized like(serializedTgtCcsid_t);

  if (tgtCcsid = 0);
    return '';
  endif;

  serialized = 'CVTCCSID(';

  select;
  when (tgtCcsid = -2);
    serialized += %char(cvtCcsid);
  when (tgtCcsid = -1);
    serialized += '*JOB';
  other;
    serialized += %char(tgtCcsid);
  endsl;

  serialized += ') ';

  return serialized;

end-proc;


dcl-proc serializeIncDir;
  dcl-pi *N like(serializedIncDir_t) extproc(*dclcase);
    incDir      likeds(incDir_t) const;
  end-pi;

  // Serialized Options.
  dcl-s serialized like(serializedIncDir_t);
  // Counter.
  dcl-s i int(10);


  if incDir.size = 1 and incDir.path(1) = '*NONE';
    return '';
  endif;

  serialized = 'INCDIR(';

  for i = 1 to incDir.size;
    if (i >= 2);
       serialized += ' ';
    endif;
    serialized += addQuotes(%trim(incDir.path(i)));
  endfor;

  if incDir.size > 0;
    serialized += ') ';
  endif;

  return serialized;

end-proc;


dcl-proc serializeString;
  dcl-pi *N like(serializedString_t) extproc(*dclcase);
    headtoken   like(headToken_t) const;
    text        varchar(5000) options(*varsize) const;
  end-pi;

  // Serialized Options.
  dcl-s serialized like(serializedString_t);
  // Counter.
  dcl-s i int(10);

  if %len(%trimr(text)) = 0;
    return '';
  endif;

  if startsWith(QUOTE: %triml(text));
    serialized = %trim(headtoken) + '(' + text + ')';
    return serialized;
  endif;

  serialized = %trim(headtoken) + '(' + QUOTE;

  for i = 1 to %len(%trimr(text));
    serialized = serialized + %subst(text: i: 1);
    if %subst(text: i: 1) = QUOTE;
      serialized = serialized + QUOTE;
    endif;
  endfor;

  serialized = serialized + QUOTE + ') ';

  return serialized;

end-proc;

dcl-proc serializeValue;
  dcl-pi *N like(serializedString_t) extproc(*dclcase);
    headtoken   char(10) const;
    value       const like(string_t);
  end-pi;

  // Serialized Options.
  dcl-s serialized like(serializedString_t);

  if %len(%trim(value)) = 0;
    return '';
  endif;

  serialized = %trim(headtoken) + '(' + %trim(value) + ') ';

  return serialized;

end-proc;


dcl-proc haveCvtCcsidParam;
  dcl-pi *N ind extproc(*dclcase);
  end-pi;

  dcl-s osVersion char(6);
  dcl-s ptfLoadedStatus char(1);

  osVersion = OS_getVersion();

  // Check PTF loaded status:
  // 2 = applied
  // 3 = permanently applied
  // 6 = superseeded
  select;
  when (osVersion = 'V7R3M0');
    ptfLoadedStatus = OS_getPTFLoadedStatus('SI70935': '5770SS1');
    if (ptfLoadedStatus = '2' or ptfLoadedStatus = '3' or ptfLoadedStatus = '6');
      ptfLoadedStatus = OS_getPTFLoadedStatus('SI70937': '5770ST1');
    endif;

  when (osVersion = 'V7R4M0');
    ptfLoadedStatus = OS_getPTFLoadedStatus('SI70941': '5770SS1');
    if (ptfLoadedStatus = '2' or ptfLoadedStatus = '3' or ptfLoadedStatus = '6');
      ptfLoadedStatus = OS_getPTFLoadedStatus('SI70943': '5770ST1');
    endif;

  other;
    ptfLoadedStatus = '3'; // permanently applied, 7.5 and higher
  endsl;

  if (ptfLoadedStatus = '2' or ptfLoadedStatus = '3' or ptfLoadedStatus = '6');
    return *on;
  endif;

  return *off;

end-proc;

