**FREE
// ==========================================================================
//  iRPGUnit - RUCALLTST Validity checking program.
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

ctl-opt main(cmdRunV);
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   Exported Procedures
//----------------------------------------------------------------------

/include qinclude,CMDRUNV

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,TEMPLATES
/include qinclude,PGMMSG
/include qsysinc,strftime
/include qsysinc,time
/include qsysinc,stat

//----------------------------------------------------------------------
//   Private Prototypes
//----------------------------------------------------------------------

// Replace all occurences of a given search argument.
dcl-pr replace varchar(2048) extproc('replace');
  i_string        varchar(2048) const  options(*varsize);
  i_searchArg     varchar(512) const  options(*varsize);
  i_replaceArg    varchar(512) const  options(*varsize);
end-pr;

dcl-pr validateReplacementVariables varchar(256);
  i_xmlStmf       const like(stmf_t);
end-pr;

dcl-pr getDirectory like(stmf_t) extproc('getDirectory');
  i_path          const like(stmf_t);
end-pr;

//----------------------------------------------------------------------
//   Main Procedure
//----------------------------------------------------------------------

dcl-proc cmdrunv;
  dcl-pi cmdrunv;
    gi_testSuite    const likeds(object_t);
    gi_testProcs    const likeds(procNms_t);
    gi_order        const like(order_t);
    gi_detail       const like(detail_t);
    gi_output       const like(output_t);
    gi_libl         const likeds(libl_t);
    gi_jobD         const likeds(object_t);
    gi_rclRsc       const like(rclrsc_t);
    gi_xmlStmf      const like(stmf_t);
  end-pi;

  dcl-s errMsg varchar(256);

  if (gi_xmlStmf <> '');

    errMsg = validateXmlStmf(gi_xmlStmf: gi_testSuite);
    if (errMsg <> '');
      sndVldChkMsg( errMsg : 2 );
    endif;

  endif;

  *inlr = *on;

end-proc;


//----------------------------------------------------------------------
//   Procedures
//----------------------------------------------------------------------

dcl-proc validateXmlStmf export;
  dcl-pi *N varchar(256);
    i_xmlStmf       const like(stmf_t);
    i_testSuite     const likeds(object_t );
  end-pi;

  dcl-s errMsg varchar(256);
  dcl-s xmlStmfRpl like(i_xmlStmf);
  dcl-s dir like(i_xmlStmf);
  dcl-ds st_stat likeds(st_stat_t);

  // Validate replacement variables
  errMsg = validateReplacementVariables(i_xmlStmf);
  if (errMsg <> '');
    return errMsg;
  endif;

  // Replace variables
  monitor;
    xmlStmfRpl = resolvePathVariables(i_xmlStmf : i_testSuite);
  on-error;
    errMsg = rcvMsgTxt('*ESCAPE');
    if (errMsg <> '');
      return errMsg;
    endif;
  endmon;

  // Ensure all replacement variables have been replaced
  if (%scan('<': xmlStmfRpl) > 0 or %scan('>': xmlStmfRpl) > 0);
    errMsg = 'Not all replacement variables have been replaced. +
              Check parameter TSTPGM.';
    return errMsg;
  endif;

  // Ensure directory exists
  dir = getDirectory(xmlStmfRpl);
  if (stat(dir: st_stat)  < 0);
    errMsg = 'Directory does not exist. +
              Check parameter ''XML stream file'' (XMLSTMF).';
    return errMsg;
  endif;

  return '';

end-proc;

dcl-proc validateReplacementVariables;
  dcl-pi *N varchar(256);
    i_xmlStmf       const like(stmf_t);
  end-pi;

  dcl-s errMsg varchar(256);

  dcl-s illegalRplVar varchar(10);
  dcl-s illegalMsg varchar(128);

  select;
  when (%scan('%c': i_xmlStmf) > 0);
    illegalRplVar = '%c';   // Date/Time in the format of the locale.
    illegalMsg = 'may contain illegal characters';
  when (%scan('%D': i_xmlStmf) > 0);
    illegalRplVar = '%D';   // Date Format, same as %m/%d/%y.
    illegalMsg = 'contains forward SLASHes';
  when (%scan('%e': i_xmlStmf) > 0);
    illegalRplVar = '%e';   // Same as %d, except single digit is
    // preceded by a space [1-31].
    illegalMsg = 'contains spaces';
  when (%scan('%G': i_xmlStmf) > 0);
    illegalRplVar = '%G';   // 4 digit year portion of ISO week date.
    // Can be negative.
    illegalMsg = 'can be negative';
  when (%scan('%n': i_xmlStmf) > 0);
    illegalRplVar = '%n';   // Newline character.
    illegalMsg = 'newline character';
  when (%scan('%r': i_xmlStmf) > 0);
    illegalRplVar = '%r';   // Time in AM/PM format of the locale.
    illegalMsg = 'may contain illegal characters';
  when (%scan('%t': i_xmlStmf) > 0);
    illegalRplVar = '%t';   // Tab character.
    illegalMsg = 'tab character';
  when (%scan('%x': i_xmlStmf) > 0);
    illegalRplVar = '%x';   // Date in the format of the locale.
    illegalMsg = 'may contain illegal characters';
  when (%scan('%X': i_xmlStmf) > 0);
    illegalRplVar = '%X';   // Time in the format of the locale.
    illegalMsg = 'may contain illegal characters';
  when (%scan('%Y': i_xmlStmf) > 0);
    illegalRplVar = '%Y';   // 4-digit year. Can be negative.
    illegalMsg = 'can be negative';
  when (%scan('%%': i_xmlStmf) > 0);
    illegalRplVar = '%%';   // % character.
    illegalMsg = '% character';
  other;
    illegalRplVar = '';
    illegalMsg = '';
  endsl;

  if (illegalRplVar <> '');
    errMsg = 'Illegal replacement variable in XML stream file name: ' +
             illegalRplVar;
    if (illegalMsg <> '');
      errMsg = %trimr(errMsg) + ' (' + illegalMsg + ')';
    endif;
  endif;

  return errMsg;

end-proc;

dcl-proc resolvePathVariables export;
  dcl-pi *N like(stmf_t);
    i_path          const like(stmf_t);
    i_testSuite     const likeds(object_t);
  end-pi;

  dcl-s resolvedPath like(stmf_t);

  dcl-s microSeconds zoned(6);
  dcl-ds tm likeds(tm_t) based(ptm);
  dcl-s tmpPathBuf char(1024) inz;
  dcl-s size int(10);

  ptm = localtime(time(*null));
  microSeconds = %subdt(%timestamp(*sys: 6): *MSECONDS);
  size = strftime(%addr(tmpPathBuf): %size(tmpPathBuf): i_path: tm);
  resolvedPath = %subst(tmpPathBuf: 1: size);
  resolvedPath = replace(resolvedPath: '<TSTPGM>': i_testSuite.nm);
  resolvedPath = replace(resolvedPath: '<TSTLIB>': i_testSuite.lib);
  resolvedPath = replace(resolvedPath: '<MSECONDS>': %editc(microSeconds: 'X'));
  resolvedPath = replace(resolvedPath: ':': '.');
  resolvedPath = replace(resolvedPath: %char(BACK_SLASH): '/');

  return resolvedPath;

end-proc;

dcl-proc replace;
  dcl-pi *N varchar(2048);
    i_string        varchar(2048) const  options(*varsize);
    i_searchArg     varchar(512) const  options(*varsize);
    i_replaceArg    varchar(512) const  options(*varsize);
  end-pi;

  dcl-s result varchar(2048);
  dcl-s startPos int(10) inz(1);
  dcl-s x int(10);
  dcl-s theSearchArg like(i_searchArg);
  dcl-c UC 'ABCDEFGHIJKLMNOPQRSTUVWXYC';
  dcl-c LC 'abcdefghijklmnopqrstuvwxyz';

  result = i_string;

  theSearchArg = %xlate(LC: UC: i_searchArg);
  exsr performreplace;

  theSearchArg = %xlate(UC: LC: i_searchArg);
  exsr performreplace;

  return result;

  begsr performreplace;

    x = %scan(theSearchArg: result: startPos);
    dow (x > 0);
      result = %replace(i_replaceArg: result: x: %len(theSearchArg));
      x = x + %len(i_replaceArg);
      if (x <= %len(result));
        x = %scan(theSearchArg: result: x);
      else;
        leave;
      endif;
    enddo;

  endsr;

end-proc;

dcl-proc getDirectory;
  dcl-pi *N like(stmf_t);
    i_path          const like(stmf_t);
  end-pi;

  dcl-s directory like(stmf_t);

  dcl-s tPath like(i_path);
  dcl-s char char(1);
  dcl-s pathLength int(10);
  dcl-s x int(10);
  // ---------------------------------------------------------

  tPath = %trimr(i_path);

  char = %subst(tPath: %len(tPath): 1);
  if (char = %char(SLASH));
    return i_path;
  else;
    pathLength = %len(tPath);
    for x = pathLength downto 1;
      char = %subst(tPath: x: 1);
      if (char = %char(COLON) or char = %char(SLASH));
        tPath = %subst(tPath: 1: x);
        return tPath;
      endif;
    endfor;
  endif;

  return directory;

end-proc;

