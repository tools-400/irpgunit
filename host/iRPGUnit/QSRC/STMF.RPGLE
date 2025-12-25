**FREE
///
// ==========================================================================
//  iRPGunit - Stream File Utilities.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
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
/include qinclude,STMF
/include qinclude,PGMMSG
/include qinclude,STRING
/include qinclude,TEMPLATES
/include qsysinc,GETCWD
/include qsysinc,STAT
/include qsysinc,STRFTIME

//----------------------------------------------------------------------
//   Global Constants
//----------------------------------------------------------------------

dcl-c LCL_DOT '.';
dcl-c LCL_SLASH '/';
dcl-c LCL_BACKSLASH '\';

//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

//----------------------------------------------------------------------
//  Returns the current directory.
//----------------------------------------------------------------------
dcl-proc Stmf_getCurrentDirectory export;
  dcl-pi *n like(ifsStmf_t);
  end-pi;

  dcl-s dirBuff char(4096);
  dcl-s currDir like(ifsStmf_t);

  if (getcwd(dirBuff: %size(dirBuff)) = *NULL);
    sndEscapeMsgAboveCtlBdy('Error: Could not get current directory.');
  endif;

  currDir = %trim(%str(%addr(dirBuff)));

  return currDir;

end-proc;

//----------------------------------------------------------------------
//  Resolves the path of the stream file.
//----------------------------------------------------------------------
dcl-proc Stmf_resolvePath export;
  dcl-pi *n like(ifsStmf_t);
    stmf   like(ifsStmf_t) const;
  end-pi;

  dcl-s resolvedPath like(ifsStmf_t);

  resolvedPath = %trim(%xlate(LCL_BACKSLASH: LCL_SLASH: stmf));
  if (startsWith(LCL_SLASH: resolvedPath));
    return resolvedPath;
  endif;

  if (startsWith('./': resolvedPath));
    resolvedPath = %subst(resolvedPath: 3);
  endif;

  resolvedPath = Stmf_getCurrentDirectory() + LCL_SLASH + resolvedPath;

  return resolvedPath;

end-proc;

//----------------------------------------------------------------------
//  Tests whether the specified stream file or directory exists.
//----------------------------------------------------------------------
dcl-proc Stmf_exists export;
  dcl-pi *n ind;
    stmf   like(ifsStmf_t) const;
  end-pi;

  dcl-s exists ind;

  dcl-ds st_stat likeds(st_stat_t) inz;
  dcl-s rc int(10);

  rc = stat(Stmf_resolvePath(stmf): st_stat); // -1 = error, not found
  if (rc = -1);
    exists = *off;
  else;
    exists = *on;
  endif;

  return exists;

end-proc;

//----------------------------------------------------------------------
//  Returns the date and time the stream file was last changed.
//----------------------------------------------------------------------
dcl-proc Stmf_getLastChgDate export;
  dcl-pi *n timestamp;
    stmf   like(ifsStmf_t) const;
  end-pi;

  dcl-s lastChgDate timestamp;

  dcl-s localSrcStmf like(ifsStmf_t);
  dcl-ds st_stat likeds(st_stat_t) inz;
  dcl-s rc int(10);

  localSrcStmf = Stmf_resolvePath(stmf);

  rc = stat(Stmf_resolvePath(localSrcStmf): st_stat);
  if (rc = -1);
    sndEscapeMsgAboveCtlBdy('Stream file not found: ' + stmf);
  else;
    lastChgDate = convertEpochDate(st_stat.mtime);
  endif;

  return lastChgDate;

end-proc;

//----------------------------------------------------------------------
//  Returns the ccsid of a given stream file.
//----------------------------------------------------------------------
dcl-proc Stmf_getCcsid export;
  dcl-pi *n like(ccsid_t);
    stmf   like(ifsStmf_t) const;
  end-pi;

  dcl-s ccsid like(ccsid_t);

  dcl-s localSrcStmf like(ifsStmf_t);
  dcl-ds st_stat likeds(st_stat_t) inz;
  dcl-s rc int(10);

  localSrcStmf = Stmf_resolvePath(stmf);

  rc = stat(Stmf_resolvePath(localSrcStmf): st_stat);
  if (rc = -1);
    sndEscapeMsgAboveCtlBdy('Stream file not found: ' + stmf);
  else;
    ccsid = st_stat.ccsid;
  endif;

  return ccsid;

end-proc;

//----------------------------------------------------------------------
//  Returns the type (file extension) of the stream file.
//----------------------------------------------------------------------
dcl-proc Stmf_getType export;
  dcl-pi *n varchar(10);
    stmf   like(ifsStmf_t) const;
  end-pi;

  dcl-s fileExtension varchar(10);

  dcl-s localSrcStmf like(ifsStmf_t);
  dcl-s i int(10);

  localSrcStmf = Stmf_resolvePath(stmf);

  i = %scanr(LCL_DOT: localSrcStmf);
  if (%scanr(LCL_SLASH: localSrcStmf) > i);
    return '';
  endif;

  if (i = %len(localSrcStmf));
    return '';
  endif;

  fileExtension = %subst(localSrcStmf: i+1);

  return fileExtension;

end-proc;


dcl-proc convertEpochDate;
  dcl-pi *n timestamp extproc(*dclcase);
    epochTime   int(10) const;
  end-pi;

  dcl-s tmStmp timestamp;

  dcl-c ftimef '%Y-%m-%d%H.%M.%S';

  dcl-ds ftimest qualified inz;
    date char(10);
    time char(8);
    null char(1) inz(x'00');
  end-ds;

  dcl-ds time likeds(tm_t) inz;

  if (localtime_r(epochTime: time) <> *null);
    if (strftime(%addr(ftimest): %size(ftimest): %trim(ftimef): time) > 0);
       tmStmp=%timestamp(ftimest.date + '-' + ftimest.time + '.000000');
    endif;
  endif;

 return tmStmp;


end-proc;
