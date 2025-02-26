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
/include qinclude,SYSTEMAPI
/include qinclude,TESTUTILS
/include qinclude,TAGTST
/include qinclude,OBJECT
/include qinclude,ERRORCODE

/include qsysinc,QCAPCMD


//----------------------------------------------------------------------
//   PUBLIC PROTOTYPES
//----------------------------------------------------------------------

/include qinclude,CRTTST


//----------------------------------------------------------------------
//   PRIVATE PROTOTYPES
//----------------------------------------------------------------------

dcl-pr joblogcallback
       ind
       extproc('jobLogCallback');
  i_hmsginfo      pointer const;
  i_puserdata     pointer const;
  i_msgid         char(7) const;
  i_msgtext       varchar(132) const;
  i_msgsenttime   timestamp const;
end-pr;

dcl-pr deletesplfcallback
       ind
       extproc('deleteSplfCallback');
  i_hsplf         pointer const;
  i_puserdata     pointer const;
  i_splfnm        char(10) const;
  i_qJob          const likeds(job_t);
  i_splfnbr       int(10) const;
  i_filestatus    char(10) const;
end-pr;


//----------------------------------------------------------------------
//   TYPE TEMPLATE
//----------------------------------------------------------------------

dcl-ds jobloguserdata_t
       qualified template;
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
    testpgm         const likeds(object_t);
    srcFile         const likeds(object_t);
    srcMbr          const like(srcMbr_t.mbr);
    text            const like(text_t);
    coption         const likeds(options_t);
    dbgview         const like(dbgView_t);
    bndsrvpgm       const likeds(objectArray_t);
    bnddir          const likeds(objectArray_t);
    boption         const likeds(options_t);
    define          const likeds(defines_t);
    dltsplf         const like(yesno_t);
    actgrp          const like(activationGroup_t);
    bmodules        const likeds(objectArray_t);
    prpgppopt       const like(rpgPpOpt_t);
    poption         const likeds(options_t);
    compileopt      const like(compileOpt_t);
    targetrls       const like(targetRelease_t);
  end-pi;

  dcl-ds modules likeds(bmodules) inz;
  dcl-s srcType         varchar(10);
  dcl-s textrslv        like(text) inz;
  dcl-s i               int(10);
  dcl-s mbrtype         char(10);
  dcl-ds tmpopts likeds(options_t) inz;
  dcl-ds qsrcfile likeds(object_t) inz;
  dcl-s librslv         char(10);
  dcl-s startcompiletime
        timestamp;
  dcl-ds modulescreated likeds(objectArray_t) inz;

  dcl-s iserror         ind;

  qsrcfile = srcFile;
  modules = resolvelibraries(bmodules);

  if (not Object_exists(qsrcfile: '*FILE'));
    sndEscapeMsgAboveCtlBdy(
       'Source file ' + %trim(qsrcfile.nm) + ' not found in library ' +
                        %trim(qsrcfile.lib) + '.' );
  endif;

  if (%subst(qsrcfile.lib: 1: 1) = '*');
    librslv = Object_resolveLibrary(qsrcfile: '*FILE');
  else;
    if (not Object_exists(qsrcfile: '*FILE'));
      librslv = '';
    else;
      librslv = qsrcfile.lib;
    endif;
  endif;

  if (librslv = '');
    sndEscapeMsgAboveCtlBdy(
      'Library ' + %trim(qsrcfile.lib) + ' not found.' );
  endif;

  qsrcfile.lib = librslv;

  if (not Object_exists(qsrcfile: '*FILE': srcMbr));
    sndEscapeMsgAboveCtlBdy(
       'Member ' + %trim(srcMbr) + ' not found in source file ' +
                   %trim(qsrcfile.lib) + '/' + %trim(qsrcfile.nm) + '.' );
  endif;

  if (srcMbr = '*TSTPGM');
    mbrtype = getMemberType(qsrcfile.nm: qsrcfile.lib: testpgm);
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

  iserror = *off;

  monitor;

    select;
    when text = '*SRCMBRTXT';
      textrslv = SrcMbr_getDescription(qsrcfile: srcMbr);
    when text = '*BLANK';
      textrslv = '';
    when text = '*DEFAULT';
      textrslv = 'RPGUnit - Test Case';
    when not startswith('RPGUnit' : text);
      textrslv = 'RPGUnit - ' + text;
    other;
      textrslv = text;
    endsl;

    srcType = SrcMbr_getType( qsrcfile : srcMbr );

    startcompiletime = %timestamp();

    select;
    when (srcType = MBR_RPGLE or srcType = MBR_SQLRPGLE);
      addModule( modules : testpgm : *on); // Add to position #1.
      // QDEVTOOLS/QLNCMSG RNS9305 - Module &1 placed in library &2.
      crtrpgmod( testpgm : qsrcfile : srcMbr : coption : dbgview :
                 prpgppopt : poption : compileopt : targetrls : define);
      modulescreated = getCreatedModulesFromJobLog(
                         MOD_CRT_RPG : startcompiletime );
      addModules( modules : modulescreated );
    when (srcType = MBR_CBLLE or srcType = MBR_SQLCBLLE);
      // There is no test case module to add for Cobol ==> See: *PGMID
      // QDEVTOOLS/QLNCMSG LNC0899 - Module &1 placed in library &2.
      crtCblMod( testpgm : qsrcfile : srcMbr : coption : dbgview :
                 poption : compileopt : targetrls : define);
      modulescreated = getCreatedModulesFromJobLog(
                         MOD_CRT_CBL : startcompiletime );
      addModules( modules : modulescreated );
    other;
      sndEscapeMsgAboveCtlBdy(
        'Source type ' + addquotes(srcType) + ' is not supported.' );
    endsl;

    srvPgm = crtSrvPgm(
                testpgm : bndsrvpgm : bnddir : modules : boption :
                actgrp : textrslv : targetrls);

    tagTstSrvPgm(srvPgm : qsrcfile : srcMbr);

    sndCompMsg( 'Test program ' + %trim(srvPgm.nm)
              + ' created in library ' + %trim(srvPgm.lib) + '.' );

  on-error;
    iserror = *on;
  endmon;

  monitor;
    deleteModulesAndSpooledFiles(
      dltsplf : startcompiletime : modulescreated );
  on-error;
  endmon;

  if (iserror);
    sndEscapeMsgAboveCtlBdy( 'Unable to create test '
                             + %trim(testpgm.nm) + '.' );
  endif;

  *inlr = *on;

end-proc;


dcl-proc resolvelibraries;
  dcl-pi *N likeds(objectArray_t);
    modules         const likeds(objectArray_t);
  end-pi;

  dcl-s i               int(10);
  dcl-ds rtnmodules likeds(modules) inz;
  dcl-s libresolved     char(10);

  clear rtnmodules;

  for i = 1 to modules.size;

    if (startswith( '*' : modules.object(i).lib));
      libresolved = Object_resolveLibrary(modules.object(i): '*MODULE');
    else;
      libresolved = modules.object(i).lib;
    endif;

    if (libresolved = '');
      sndEscapeMsgAboveCtlBdy( 'Could not resolve module '
                             +  Object_qName(modules.object(i)) );
    endif;

    rtnmodules.size += 1;
    rtnmodules.object(rtnmodules.size).nm = modules.object(i).nm;
    rtnmodules.object(rtnmodules.size).lib = libresolved;
  endfor;

  return rtnmodules;

end-proc;


dcl-proc getCreatedModulesFromJobLog;
  dcl-pi *N likeds(objectArray_t);
    crtmsgid        char(7) const;
    timelimit       timestamp const;
  end-pi;

  dcl-s hreader         like(hjoblogreader_t);
  dcl-ds userdata likeds(jobloguserdata_t);

  clear userdata;
  userdata.timelimit = timelimit;
  userdata.crtmsgid = crtmsgid;

  hreader = JobLogReader_init(jl_rd_previous);
  joblogreader_addfield(hreader: OLJL_RPL_DATA);
  joblogreader_read(hreader: %paddr('jobLogCallback'): %addr(userdata));

  return userdata.modules;

end-proc;


dcl-proc joblogcallback;
  dcl-pi *N              ind;
    i_hmsginfo      pointer const;
    i_puserdata     pointer const;
    i_msgid         char(7) const;
    i_msgtext       varchar(132) const;
    i_msgsenttime   timestamp const;
  end-pi;

  dcl-ds userdata likeds(jobloguserdata_t)
  based(i_puserdata);

  dcl-s msgData         char(100);
  dcl-ds module likeds(object_t);

  dcl-ds rns9305 qualified based(pmsgdata);
    mod             char(10);
    lib             char(10);
  end-ds;

  dcl-ds lnc0899 qualified based(pmsgdata);
    length          int(5);
    data            char(10);
  end-ds;

  if i_msgsenttime < userdata.timelimit;
    return *off;
  endif;

  if (i_msgid = userdata.crtmsgid);

    msgData = JobLogReader_getCharValue(i_hmsginfo: OLJL_RPL_DATA);
    pmsgdata = %addr(msgData);

    select;
    when (userdata.crtmsgid = MOD_CRT_RPG);
      module.nm = rns9305.mod;
      module.lib = rns9305.lib;
      addModule( userdata.modules : module );
    when (userdata.crtmsgid = MOD_CRT_CBL);
      module.nm = %subst(lnc0899.data: 1: lnc0899.length);
      pmsgdata += lnc0899.length + %size(lnc0899.length); // push pointer to next *VARY field
      module.lib = %subst(lnc0899.data: 1: lnc0899.length);
      addModule( userdata.modules : module );
    endsl;
  endif;

  return *on;

end-proc;


dcl-proc addModules;
  dcl-pi *N;
    modules         likeds(objectArray_t);
    items           likeds(objectArray_t);
  end-pi;

  dcl-s i               int(10);


  for i = 1 to items.size;
    addModule( modules : items.object(i) );
  endfor;

end-proc;


dcl-proc addModule;
  dcl-pi *N;
    modules         likeds(objectArray_t);
    module          const likeds(object_t);
    isfirstmod      ind const options(*nopass);
  end-pi;

  dcl-s i               int(10);
  dcl-s r               int(10);


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


dcl-proc crtrpgmod;
  dcl-pi *N;
    testpgm         const likeds(object_t);
    srcFile         const likeds(object_t);
    srcMbr          const like(srcMbr_t.mbr);
    coption         const likeds(options_t);
    dbgview         const like(dbgView_t);
    prpgppopt       const like(rpgPpOpt_t);
    poption         const likeds(options_t);
    compileopt      const like(compileOpt_t);
    targetrls       const like(targetRelease_t);
    define          const likeds(defines_t);
  end-pi;

  // A command to be executed.
  dcl-s cmd             like(cmd_t);


  cmd = getCrtRpgModCmd( testpgm : srcFile : srcMbr : coption : dbgview:
                         prpgppopt : poption : compileopt : targetrls :
                         define);
  sndInfoMsg( cmd );
  qcmdexc( cmd : %len(cmd) );

end-proc;


dcl-proc crtCblMod;
  dcl-pi *N;
    testpgm         const likeds(object_t);
    srcFile         const likeds(object_t);
    srcMbr          const like(srcMbr_t.mbr);
    coption         const likeds(options_t);
    dbgview         const like(dbgView_t);
    poption         const likeds(options_t);
    compileopt      const like(compileOpt_t);
    targetrls       const like(targetRelease_t);
    define          const likeds(defines_t);
  end-pi;

  // A command to be executed.
  dcl-s cmd             like(cmd_t);


  cmd = getCrtCblModCmd( testpgm : srcFile : srcMbr : coption : dbgview:
                         poption : compileopt : targetrls :
                         define);
  sndInfoMsg( cmd );
  qcmdexc( cmd : %len(cmd) );

end-proc;


dcl-proc deleteModulesAndSpooledFiles;
  dcl-pi *N;
    dltsplf         ind const;
    starttime       timestamp const;
    modules         const likeds(objectArray_t);
  end-pi;


  dcl-s i               int(10);
  dcl-s cmd             like(cmd_t);

  dcl-s hlister         like(hsplflister_t);
  dcl-ds qjob likeds(job_t);

  clear qjob;
  qjob.name = '*';

  for i = 1 to modules.size;
    cmd = getdltmodcmd( modules.object(i) );
    qcmdexc( cmd : %len(cmd) );

    if (dltsplf);
      hlister = splflister_init(qjob);
      splflister_list(hlister: %paddr('deleteSplfCallback'));
    endif;
  endfor;

end-proc;


dcl-proc deletesplfcallback;
  dcl-pi *N              ind;
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

  qcmdexc( cmd : %len(cmd) );

  return *on;

end-proc;

dcl-proc crtSrvPgm;
  dcl-pi *N likeds(object_t);
    testpgm         const likeds(object_t);
    bndsrvpgm       const likeds(objectArray_t);
    bnddir          const likeds(objectArray_t);
    module          const likeds(objectArray_t);
    boption         const likeds(options_t);
    actgrp          const like(activationGroup_t);
    text            const like(text_t);
    targetrls       const like(targetRelease_t);
  end-pi;

  // Export all procedures from the service program.
  dcl-c export_all const('*ALL');
  // A command to be executed.
  dcl-s cmd             like(cmd_t);
  // Bound Service Programs, with RPGUnit services included.
  dcl-ds bndsrvpgmwithru
         likeds(objectArray_t);
  // Completion message data.
  dcl-s compmsgdata     char(256);
  // Target service program.
  dcl-ds targetsrvpgm likeds(object_t);


  bndsrvpgmwithru = bndsrvpgm;
  bndsrvpgmwithru.size += 1;
  bndsrvpgmwithru.object(bndsrvpgmwithru.size).nm = 'RUTESTCASE';
  bndsrvpgmwithru.object(bndsrvpgmwithru.size).lib = '*LIBL';

  cmd = getCrtSrvPgmCmd( testpgm :
                         bndsrvpgmwithru :
                         bnddir :
                         module :
                         boption :
                         export_all :
                         actgrp :
                         text :
                         targetrls );
  sndInfoMsg( cmd );
  qcmdexc( cmd : %len(cmd) );

  compmsgdata = rcvMsgData( '*COMP' );
  targetsrvpgm = %subst( compmsgdata : 1 : 20 );

  return targetsrvpgm;

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
  dcl-s cmd             like(cmd_t);


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
    cmd             const like(cmd_t);
  end-pi;

  dcl-ds optCtrlBlk likeds(qcapcmd_optCtrlBlk_t);

  dcl-s rtncmd          char(32702);
  dcl-s rtncmdlenavl    int(10);
  dcl-ds errcode likeds(percolateErrors_t)
  inz(*likeds);

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
    testpgm         const likeds(object_t);
    srcFile         const likeds(object_t);
    srcMbr          const like(srcMbr_t.mbr);
    coptions        const likeds(options_t);
    dbgview         const like(dbgView_t);
    prpgppopt       const like(rpgPpOpt_t);
    poptions        const likeds(options_t);
    compileopt      const like(compileOpt_t);
    targetrls       const like(targetRelease_t);
    define          const likeds(defines_t);
  end-pi;

  // Command string accumulator.
  dcl-s cmd             like(cmd_t);
  dcl-s dbgcompileopt   like(compileopt);


  // source type determines the compile command
  select;
  // RPGLE
  when getMemberType(srcFile.nm: srcFile.lib: testpgm) = MBR_RPGLE;
    cmd = 'CRTRPGMOD MODULE(' + serializeObjectName( testpgm ) + ') ';
    cmd += 'SRCFILE(' + serializeObjectName( srcFile ) + ') ';
    cmd += serializeValue( 'SRCMBR' : srcMbr );
    cmd += serializeOptions( 'OPTION' : coptions );
    cmd += serializeValue( 'TGTRLS' : targetrls );
    cmd += serializeValue( 'DBGVIEW' : dbgview );
    cmd += serializedefines( 'DEFINE' : define );

  // SQLRPGLE
  when getMemberType(srcFile.nm: srcFile.lib: testpgm) = MBR_SQLRPGLE;
    cmd = 'CRTSQLRPGI OBJ(' + serializeObjectName( testpgm ) + ') ';
    cmd += 'SRCFILE(' + serializeObjectName( srcFile ) + ') ';
    cmd += serializeValue( 'SRCMBR' : srcMbr );
    cmd += serializeOptions( 'OPTION' : poptions );
    cmd += serializeValue('OBJTYPE': '*MODULE');
    cmd += serializeValue( 'TGTRLS' : targetrls );
    cmd += serializeValue( 'DBGVIEW' : '*NONE');

    if (prpgppopt <> '*DEFAULT');
      cmd += serializeValue( 'RPGPPOPT' : prpgppopt);
    endif;

    if compileopt <> *blank;
      dbgcompileopt = removequotes(compileopt);
      if (%scan( PARM_DBGVIEW + '(' : uCase( compileopt )) = 0);
        dbgcompileopt += ' ' + serializeValue( 'DBGVIEW' : dbgview );
      endif;
      if (%scan( PARM_DEFINE + '(' : uCase( compileopt )) = 0);
        dbgcompileopt += ' ' + serializedefines( 'DEFINE' : define );
      endif;
    else;
      dbgcompileopt = serializeValue( 'DBGVIEW' : dbgview);
      dbgcompileopt += serializedefines( 'DEFINE' : define);
    endif;

    cmd += serializeString( 'COMPILEOPT' : dbgcompileopt);

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
    coptions        const likeds(options_t);
    dbgview         const like(dbgView_t);
    poptions        const likeds(options_t);
    compileopt      const like(compileOpt_t);
    targetrls       const like(targetRelease_t);
    define          const likeds(defines_t);
  end-pi;

  // Command string accumulator.
  dcl-s cmd             like(cmd_t);
  dcl-s dbgcompileopt   like(compileopt);


  // source type determines the compile command
  select;
  // CBLLE
  when getMemberType(srcFile.nm: srcFile.lib: testpgm) = MBR_CBLLE;
    cmd = 'CRTCBLMOD MODULE(*PGMID) ';
    cmd += 'SRCFILE(' + serializeObjectName( srcFile ) + ') ';
    cmd += serializeValue( 'SRCMBR' : srcMbr );
    cmd += serializeOptions( 'OPTION' : coptions );
    cmd += serializeValue( 'TGTRLS' : targetrls );
    cmd += serializeValue( 'DBGVIEW' : dbgview );
    cmd += serializedefines( 'DEFINE' : define );

  // SQLCBLLE
  when getMemberType(srcFile.nm: srcFile.lib: testpgm) = MBR_SQLCBLLE;
    cmd = 'CRTSQLCBLI OBJ(' + serializeObjectName( testpgm ) + ') ';
    cmd += 'SRCFILE(' + serializeObjectName( srcFile ) + ') ';
    cmd += serializeValue( 'SRCMBR' : srcMbr );
    cmd += serializeOptions( 'OPTION' : poptions );
    cmd += serializeValue('OBJTYPE': '*MODULE');
    cmd += serializeValue( 'TGTRLS' : targetrls );
    cmd += serializeValue( 'DBGVIEW' : '*NONE');

    if compileopt <> *blank;
      dbgcompileopt = removequotes(compileopt);
      if (%scan( PARM_DBGVIEW + '(' : uCase( compileopt )) = 0);
        dbgcompileopt += ' ' + serializeValue( 'DBGVIEW' : dbgview );
      endif;
      if (%scan( PARM_DEFINE + '(' : uCase( compileopt )) = 0);
        dbgcompileopt += ' ' + serializedefines( 'DEFINE' : define );
      endif;
    else;
      dbgcompileopt = serializeValue( 'DBGVIEW' : dbgview);
      dbgcompileopt += serializedefines( 'DEFINE' : define);
    endif;

    cmd += serializeString( 'COMPILEOPT' : dbgcompileopt);

  // something we don't know about yet
  other;
    cmd = 'RUCRTCBL: Unknown source member type';
  endsl;

  cmd = formatCommand(cmd);

  return cmd;

end-proc;


dcl-proc getdltmodcmd;
  dcl-pi *N       like(cmd_t);
    testpgm         const likeds(object_t);
  end-pi;

  // Command string accumulator.
  dcl-s cmd             like(cmd_t);


  cmd = 'DLTMOD MODULE(' + serializeObjectName( testpgm ) + ') ';

  cmd = formatCommand(cmd);

  return cmd;

end-proc;


dcl-proc serializeObjectArray;
  dcl-pi *N       like(serializedArray_t);
    headtoken       const like(headToken_t);
    array           const likeds(objectArray_t);
  end-pi;

  // Serialized Object Array.
  dcl-s serialized      like(serializedArray_t);
  // Counter.
  dcl-s i               int(10);


  if array.size = 0;
    return '';
  endif;

  serialized = %trim(headtoken) + '(';

  for i = 1 to array.size;
    serialized += serializeObjectName( array.object(i) ) + ' ';
  endfor;

  serialized += ') ';

  return serialized;

end-proc;


dcl-proc serializeObjectName export;
  dcl-pi *N       like(serializedObject_t);
    object          const likeds(object_t);
  end-pi;

  // Serialized object name.
  dcl-s serialized      like(serializedObject_t) inz('');


  if object.lib <> *blank;
    serialized += %trim(object.lib) + '/';
  endif;

  serialized += %trim(object.nm);

  return serialized;

end-proc;


dcl-proc serializeOptions;
  dcl-pi *N       like(serializedOptions_t);
    headtoken       const like(headToken_t);
    options         const likeds(options_t);
  end-pi;

  // Serialized Options.
  dcl-s serialized      like(serializedOptions_t);
  // Counter.
  dcl-s i               int(10);


  if options.size = 0;
    return '';
  endif;

  serialized = %trim(headtoken) + '(';

  for i = 1 to options.size;
    serialized += %trim(options.option(i)) + ' ';
  endfor;

  if options.size > 0;
    serialized += ') ';
  endif;

  return serialized;

end-proc;


dcl-proc serializedefines;
  dcl-pi *N       like(serializedOptions_t);
    headtoken       const like(headToken_t);
    defines         const likeds(defines_t);
  end-pi;

  // Serialized Options.
  dcl-s serialized      like(serializedOptions_t);
  // Counter.
  dcl-s i               int(10);


  if defines.size = 0;
    return '';
  endif;

  serialized = %trim(headtoken) + '(';

  for i = 1 to defines.size;
    serialized += %trim(defines.define(i)) + ' ';
  endfor;

  if defines.size > 0;
    serialized += ') ';
  endif;

  return serialized;

end-proc;


dcl-proc serializeString;
  dcl-pi *N       like(serializedString_t);
    headtoken       const like(headToken_t);
    text            varchar(5000) const  options(*varsize);
  end-pi;

  // Serialized Options.
  dcl-s serialized      like(serializedString_t);
  // Counter.
  dcl-s i               int(10);


  if %len(%trimr(text)) = 0;
    return '';
  endif;

  if startswith(QUOTE: %triml(text));
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
  dcl-pi *N       like(serializedString_t);
    headtoken       char(10) const;
    value           const like(string_t);
  end-pi;

  // Serialized Options.
  dcl-s serialized      like(serializedString_t);


  if %len(%trim(value)) = 0;
    return '';
  endif;

  serialized = %trim(headtoken) + '(' + %trim(value) + ') ';

  return serialized;

end-proc;

