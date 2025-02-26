**FREE
// ===================================================================
//  iRPGUnit - Update Copyright Information
// ===================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ===================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<< CRTBNDRPG    PGM(&LI/&OB) +
//                           SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>COMPILE<<
//     >>PARM<< OPTION(*EVENTF);
//     >>PARM<< TRUNCNBR(*NO);
//     >>PARM<< DBGVIEW(*LIST);
//   >>END-COMPILE<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ===================================================================
/include qinclude,H_SPEC
ctl-opt DFTACTGRP(*NO) ACTGRP(*NEW);
// ===================================================================

dcl-f QSRC DISK(512) usage(*update:*delete) usropn extfile(g_extFile)
      extmbr(g_member) infds(g_srcInfo);

dcl-s g_extFile       char(21);
dcl-s g_member        char(10);
dcl-ds g_srcInfo likeds(srcInfo_t);

dcl-ds srcInfo_t qualified based(pTemplate);
  file            char(10) pos(83);
  lib             char(10);
  rcdLen          int(5) pos(125);
  mbr             char(10) pos(129);
  recNo           int(10) pos(397);
end-ds;

dcl-ds srcLine_t qualified based(pTemplate);
  seq             zoned(6);
  date            zoned(6);
  data            char(500);
end-ds;

/copy qsysinc,regex

// Replace function
dcl-pr replace extproc('replace');
  i_file          char(10) const;
  i_lib           char(10) const;
  i_mbr           char(10) const;
  i_cbReplace     pointer(*proc) const;
end-pr;

// Replace *EUR and *ISO dates.
dcl-pr replaceDates ind extproc('replaceDates');
  io_srcLine      likeds(srcLine_t);
  i_srcInfo       const likeds(srcInfo_t);
end-pr;

// Replace callback

dcl-s g_cbReplace     pointer(*proc);
dcl-pr cbReplace ind extproc(g_cbReplace);
  io_srcLine      likeds(srcLine_t);
  i_srcInfo       const likeds(srcInfo_t);
end-pr;

dcl-pr open extproc('open');
  i_file          char(10) const;
  i_lib           char(10) const;
  i_mbr           char(10) const;
end-pr;

dcl-pr close extproc('close');
end-pr;

dcl-pr CRTPKGCPR extpgm('CRTPKGCPR');
  gi_lib          char(10) const;
  go_date         char(10);
end-pr;

dcl-s g_now timestamp;

//===============================================================*
// Program Entry Point
//===============================================================*
dcl-pi CRTPKGCPR;
  gi_lib          char(10) const;
  go_date         char(10);
end-pi;

g_now = %timestamp();

replace('QINCLUDE': gi_lib: 'COPYRIGHT': %paddr('replaceDates'));

go_date = %char(%date(g_now): *EUR);

*inlr = *on;

//===============================================================*
// Read file member add call replace function for each statement.
//===============================================================*
dcl-proc replace;
  dcl-pi *n;
    i_file          char(10) const;
    i_lib           char(10) const;
    i_mbr           char(10) const;
    i_cbReplace     pointer(*proc) const;
  end-pi;

  dcl-ds srcLine likeds(srcLine_t) inz;

  g_cbReplace = i_cbReplace;

  callp open(i_file: i_lib: i_mbr);

  dou (%eof());
    read QSRC srcLine;
    if (not %eof());
      if (cbReplace(srcLine: g_srcInfo));
        update QSRC srcLine;
      endif;
    endif;
  enddo;

  callp close();

end-proc;

//===============================================================*
// Replace *EUR and *ISO dates.
//===============================================================*
dcl-proc replaceDates;
  dcl-pi *n ind;
    io_srcLine      likeds(srcLine_t);
    i_srcInfo       const likeds(srcInfo_t);
  end-pi;

  dcl-s isDirty         ind;

  dcl-s date_eur        char(10);
  dcl-s date_iso        char(10);
  dcl-s date_year       char(4);

  dcl-s length          int(10);

  dcl-ds hRegex_eur likeds(regex_t) inz;
  dcl-ds hRegex_iso likeds(regex_t) inz;
  dcl-ds hRegex_year likeds(regex_t) inz;
  dcl-s rc              int(10);
  dcl-s cflags          int(10);
  dcl-s nmatch          uns(10) inz(2);
  dcl-ds regmatch likeds(regmatch_t) dim(2) inz;

  isDirty = *off;

  length = i_srcInfo.rcdLen -
           (%size(io_srcLine.seq) + %size(io_srcLine.date));

  date_eur = %char(%date(g_now): *EUR);
  date_iso = %char(%date(g_now): *ISO);
  date_year = %char(%subdt(g_now: *YEARS));

  dou '1';

    // Compile regular expressions

    cflags = REG_EXTENDED + REG_ICASE;

    rc = regcomp(hRegex_eur
                 : '([0-9x]{2}.[0-9x]{2}.[0-9x]{4})': cflags);
    if (rc <> 0);
      leave;
    endif;

    rc = regcomp(hRegex_iso
                 : '([0-9x]{4}-[0-9x]{2}-[0-9x]{2})': cflags);
    if (rc <> 0);
      leave;
    endif;

    rc = regcomp(hRegex_year
                 : '2013-([0-9x]{4})': cflags);
    if (rc <> 0);
      leave;
    endif;

    // Execute regular expressions

    rc = regexec(hRegex_eur: %subst(io_srcLine.data: 1: length)
                 : nmatch: regmatch: 0);
    if (rc = 0);
      // Replace whole expression
      io_srcLine.data =
         %replace(date_eur: %subst(io_srcLine.data: 1: length)
                  : regmatch(1).rm_so + 1
                  : regmatch(1).rm_eo - regmatch(1).rm_so);
      isDirty = *on;
    endif;

    rc = regexec(hRegex_iso: io_srcLine.data
                 : nmatch: regmatch: 0);
    if (rc = 0);
      // Replace whole expression
      io_srcLine.data =
         %replace(date_iso: io_srcLine.data
                  : regmatch(1).rm_so + 1
                  : regmatch(1).rm_eo - regmatch(1).rm_so);
      isDirty = *on;
    endif;

    rc = regexec(hRegex_year: io_srcLine.data
                 : nmatch: regmatch: 0);
    if (rc = 0);
      // Replace first group
      io_srcLine.data =
         %replace(date_year: io_srcLine.data
                  : regmatch(2).rm_so + 1
                  : regmatch(2).rm_eo - regmatch(2).rm_so);
      isDirty = *on;
    endif;

  enddo;

  //===============================================================*
  // Clear regular expressions
  //===============================================================*
  if (hRegex_eur.re_comp <> *null);
    regfree(hRegex_eur);
  endif;

  if (hRegex_iso.re_comp <> *null);
    regfree(hRegex_iso);
  endif;

  if (hRegex_year.re_comp <> *null);
    regfree(hRegex_year);
  endif;

  return isDirty;

end-proc;

//===============================================================*
// Open file member.
//===============================================================*
dcl-proc open;
dcl-pi *n;
  i_file          char(10) const;
  i_lib           char(10) const;
  i_mbr           char(10) const;
end-pi;

  callp close();

  g_extFile = %trim(i_lib) + '/' + %trim(i_file);
  g_member = %trim(i_mbr);

  open QSRC;

end-proc;

//===============================================================*
// Close file member.
//===============================================================*
dcl-proc close;
  dcl-pi *n;
  end-pi;

  if (not %open(QSRC));
    return;
  endif;

  close QSRC;

  g_extFile = '';
  g_member = '';

end-proc;

