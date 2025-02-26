**FREE
// ===================================================================
//  iRPGUnit - Create iRPGUnit Meta Data.
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
/define COPYRIGHT_DSPEC
/include qinclude,COPYRIGHT
// ===================================================================
dcl-f QAFDMBRL usropn extfile(g_outfile);

dcl-f QBUILD usage(*update:*delete:*output)
      usropn rename(QBUILD: FQBUILD) extfile(g_srcfile)
      extmbr(g_srcmbr  );

dcl-s g_outfile       varchar(20) inz('QTEMP/#CRTMBRD');
dcl-s g_srcfile       varchar(20) inz;
dcl-s g_srcmbr        varchar(10) inz('A_METADATA');
//
dcl-s g_copybooks     varchar(20) inz;

// ------------------------------------
//  External Prototypes
// ------------------------------------

//  ... Execute Command (QCMDEXC) API
dcl-pr QCMDEXC extpgm('QCMDEXC');
  i_cmd           char(32702) const  options(*varsize);
  i_length        packed(15:5) const;
  i_IGCprcCtrl    char(3) const  options(*nopass);
end-pr;

dcl-c QCMDEXC_IGC 'IGC';

// ------------------------------------
//  Global Fields
// ------------------------------------
dcl-c QUOTE '''';
dcl-c LEFT_MARGIN 13;
dcl-c LEFT_INDENT 26;
dcl-c TARGET_LIB '&TARGETLIB';

dcl-s g_header        char(80) dim(21) ctdata;

// ------------------------------------
//  Prototypes
// ------------------------------------
dcl-pr PGM_ENTRY_POINT extpgm('#CRTMBRD');
  gi_lib          char(10) const  options(*nopass);
  go_release      char(20) options(*nopass);
end-pr;

dcl-pr main extproc('main');
  i_lib           varchar(10) const;
  o_release       char(20);
end-pr;

//  Executes the DSPFD command for a given file and library.
dcl-pr File_exportMemberList extproc('File_exportMemberList');
  i_lib           varchar(10) const;
  i_file          varchar(10) const;
end-pr;

//  Appends a record to QBUILD.
dcl-pr SrcMbr_write extproc('SrcMbr_write');
  i_text          varchar(100) const   options(*varsize);
  i_spaces        int(10) const;
end-pr;

//  Appends command CHGPFM to the output source member.
dcl-pr SrcMbr_appendCmdChgPfm extproc('SrcMbr_appendCmdChgPfm');
  i_file          char(10) const;
  i_lib           char(10) const;
  i_mbr           char(10) const;
  i_type          char(10) const;
  i_text          char(50) const;
end-pr;

//  Appends command MONMSG to the output source member.
dcl-pr SrcMbr_appendCmdMonMsg extproc('SrcMbr_appendCmdMonMsg');
  i_msgId         char(7) const;
end-pr;

//  Appends and empty line to the output source member.
dcl-pr SrcMbr_appendEmptyLine extproc('SrcMbr_appendEmptyLine');
end-pr;

//  Doubles a single quote.
dcl-pr doubleQuotes varchar(100) extproc('doubleQuotes');
  i_text          char(50) const;
end-pr;

//  Sends a message to QCMD
dcl-pr sndMsg extproc('sndMsg');
  i_text          varchar(128) value;
end-pr;

//===============================================================*
//  Program Entry Point
//===============================================================*
dcl-pi PGM_ENTRY_POINT;
  gi_lib          char(10) const  options(*nopass);
  go_release      char(20) options(*nopass);
end-pi;

  dcl-s release char(20) inz;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if (%parms() >= 1);
    main(%trim(gi_lib): release);
  else;
    main('*LIBL': release);
  endif;

  if (%parms() >= 2);
    go_release = release;
  endif;

  *inlr = *on;

//===============================================================*
//  *** private ***
//  Sends a message to the caller.
//===============================================================*
dcl-proc sndMsg;
  dcl-pi *n;
    i_text          varchar(128) value;
  end-pi;

  //  Return value
  dcl-s pBuffer         pointer inz;

  //  Local fields
  dcl-s msgKey          char(4) inz;

  dcl-ds qMsgF qualified            inz;
    name            char(10);
    lib             char(10);
  end-ds;

  dcl-ds errCode qualified            inz;
    bytPrv          int(10);
    bytAvl          int(10);
    excID           char(7);
    reserved        char(1);
    excDta          char(256);
  end-ds;

  //  Send Program Message (QMHSNDPM) API
  dcl-pr QMHSNDPM        extpgm('QMHSNDPM');
    i_msgID         char(7) const;
    i_qMsgF         char(20) const;
    i_msgData       char(32767) const  options(*varsize );
    i_length        int(10) const;
    i_msgType       char(10) const;
    i_callStkE      char(32767) const  options(*varsize );
    i_callStkC      int(10) const;
    o_msgKey        char(4);
    io_ErrCode      char(32767) options(*varsize );
    i_lenStkE       int(10) const  options(*nopass  );
    i_callStkEQ     char(20) const  options(*nopass  );
    i_wait          int(10) const  options(*nopass  );
    i_callStkEDT    char(10) const  options(*nopass  );
    i_ccsid         int(10) const  options(*nopass  );
  end-pr;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  clear qMsgF;
  qMsgF.name = 'QCPFMSG';
  qMsgF.lib  = '*LIBL';

  clear errCode;
  errCode.bytPrv = %size(errCode);

  QMHSNDPM('CPF9897': qMsgF: i_text: %len(i_text): '*INFO'
           : '*CTLBDY': 1
           : msgKey: errCode);

end-proc;

//===============================================================*
//  Main procedure
//===============================================================*
dcl-proc main;
  dcl-pi *n;
    i_lib           varchar(10) const;
    o_release       char(20);
  end-pi;

  //  Helper fields
  dcl-s isFirstRcd      ind inz(*ON);
  dcl-s x               int(10) inz;
  dcl-s cmd             varchar(1024) inz;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   // Do until everything is done or an error occured
   monitor;

     // Check existance of output file and clear its content
     monitor;
       cmd = 'CHKOBJ OBJ(' + g_outfile + ') OBJTYPE(*FILE)';
       qcmdexc(cmd: %len(cmd));
       cmd = 'CLRPFM FILE(' + g_outfile + ')';
       qcmdexc(cmd: %len(cmd));
     on-error;
     endmon;

     // Check existance of output source member
     g_srcfile = %trim(i_lib) + '/QBUILD';

     monitor;
       cmd = 'CHKOBJ OBJ(' + g_srcfile + ') +
                 OBJTYPE(*FILE) MBR(' + g_srcmbr + ')';
       qcmdexc(cmd: %len(cmd));
       cmd = 'CLRPFM FILE(' + g_srcfile + ') MBR(' + g_srcmbr + ')';
       qcmdexc(cmd: %len(cmd));
     on-error;
       cmd = 'ADDPFM FILE(' + g_srcfile + ') MBR(' + g_srcmbr + ')';
       qcmdexc(cmd: %len(cmd));
     endmon;

     cmd = 'CHGPFM FILE(' + g_srcfile + ') MBR(' + g_srcmbr + ') +
             TEXT(' + QUOTE + 'iRPGUnit - Apply source member''''s metadata.' + QUOTE + ') +
             SRCTYPE(CLLE)';
     qcmdexc(cmd: %len(cmd));

     // Get member list into output file
     File_exportMemberList(i_lib: 'QBND');
     File_exportMemberList(i_lib: 'QBUILD');
     File_exportMemberList(i_lib: 'QCMD');
     File_exportMemberList(i_lib: 'QINCLUDE');
     File_exportMemberList(i_lib: 'QLLIST' );
     File_exportMemberList(i_lib: 'QMISC' );
     File_exportMemberList(i_lib: 'QPNLGRP' );
     File_exportMemberList(i_lib: 'QSRC' );
     File_exportMemberList(i_lib: 'QSYSINC' );
     File_exportMemberList(i_lib: 'QTESTCASES' );
     File_exportMemberList(i_lib: 'QUNITTEST' );

     // Write source member ...
     open QBUILD;
     clear FQBUILD;

     // ... header
     for x = 1 to %elem(g_header);
       SrcMbr_write(g_header(x): 0);
     endfor;

     SrcMbr_write('PGM        PARM(&TARGETLIB)': LEFT_MARGIN);
     SrcMbr_write('': 0);

     // ... commands
     open QAFDMBRL;

     setll 1 QAFDMBRL;
     dow (%found(QAFDMBRL));
       read QAFDMBRL;
       if (%eof(QAFDMBRL));
         leave;
       endif;

       if (isFirstRcd);
         SrcMbr_write('DCL VAR(' + TARGET_LIB + ') +
                         TYPE(*CHAR) LEN(10) VALUE(' + %trim(MLLIB) + ')': LEFT_MARGIN);

         SrcMbr_write('': 0);

         SrcMbr_write('CHGVAR VAR(' + TARGET_LIB + ') +
                         VALUE(' + TARGET_LIB + ')': LEFT_MARGIN);

         SrcMbr_write('MONMSG MSGID(MCH3601) EXEC(SNDPGMMSG MSGID(CPF9898) +': LEFT_MARGIN);
         SrcMbr_write('MSGF(QCPFMSG) MSGDTA(''Target library +': LEFT_INDENT);
         SrcMbr_write('parameter required.'') MSGTYPE(*ESCAPE))': LEFT_INDENT);
         SrcMbr_write('': 0);

         isFirstRcd = *OFF;
       endif;

       SrcMbr_appendCmdChgPfm(MLFILE: TARGET_LIB: MLNAME: MLSEU2: MLMTXT);
       SrcMbr_appendCmdMonMsg('CPF3288');
       SrcMbr_appendEmptyLine();
     enddo;

     close QAFDMBRL;

     // ... footer
     SrcMbr_write('ENDPGM': LEFT_MARGIN);

     close QBUILD;

     release = RPGUNIT_VERSION;

   on-error;
     sndMsg('*** Unexpected error! ***');
   endmon;

end-proc;

//===============================================================*
//  Executes the DSPFD command for a given file and library.
//===============================================================*
dcl-proc File_exportMemberList;
  dcl-pi *n;
    i_lib           varchar(10) const;
    i_file          varchar(10) const;
  end-pi;

  dcl-s cmd             varchar(1024) inz;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  // Get member list into output file
  cmd = 'DSPFD FILE(' + i_lib + '/' + i_file + ') +
          TYPE(*MBRLIST) OUTPUT(*OUTFILE) +
          OUTFILE(' + g_outfile + ') +
          OUTMBR(*FIRST *ADD)';
  qcmdexc(cmd: %len(cmd));

end-proc;

//===============================================================*
//  Appends a record to QBUILD.
//===============================================================*
dcl-proc SrcMbr_write;
  dcl-pi *n;
    i_text          varchar(100) const   options(*varsize);
    i_spaces        int(10) const;
  end-pi;

  //  Helper fields
  dcl-s spaces          char(100) inz;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  SRCSEQ = SRCSEQ + 1;
  SRCDAT = 0;
  SRCDTA = %subst(spaces: 1: i_spaces) + i_text;

  write FQBUILD;

end-proc;

//===============================================================*
//  Appends command CHGPFM to the output source member.
//===============================================================*
dcl-proc SrcMbr_appendCmdChgPfm;
  dcl-pi *n;
    i_file          char(10) const;
    i_lib           char(10) const;
    i_mbr           char(10) const;
    i_type          char(10) const;
    i_text          char(50) const;
  end-pi;

  //  Helper fields
  dcl-s line            char(80) inz;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  line = 'CHGPFM     FILE(' + %trim(i_lib) + '/' + %trim(i_file) + ') +';
  SrcMbr_write(line: LEFT_MARGIN);

  line = 'MBR(' + %trim(i_mbr) + ') +';
  SrcMbr_write(line: LEFT_INDENT);

  line = 'SRCTYPE(' + %trim(i_type) + ') +';
  SrcMbr_write(line: LEFT_INDENT);

  line = 'TEXT(' + QUOTE + doubleQuotes(i_text) + QUOTE + ')';
  SrcMbr_write(line: LEFT_INDENT);

end-proc;

//===============================================================*
//  Appends command MONMSG to the output source member.
//===============================================================*
dcl-proc SrcMbr_appendCmdMonMsg;
  dcl-pi *n;
    i_msgId         char(7) const;
  end-pi;

  //  Helper fields
  dcl-s line            char(80) inz;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  line = 'MONMSG     MSGID(' + %trim(i_msgId) + ') ';
  SrcMbr_write(line: LEFT_MARGIN);

end-proc;

//===============================================================*
//  Appends and empty line to the output source member.
//===============================================================*
dcl-proc SrcMbr_appendEmptyLine;
  dcl-pi *n;
  end-pi;

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  SrcMbr_write('': 0);

end-proc;

//===============================================================*
//  Doubles a single quote.
//===============================================================*
dcl-proc doubleQuotes;
  dcl-pi *n varchar(100);
    i_text          char(50) const;
  end-pi;

  //  Return value
  dcl-s text            varchar(100) inz;

  //  Helper fields
  dcl-s x               int(10) inz;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  for x = 1 to %len(%trimR(i_text));
    if (%subst(i_text: x: 1) = QUOTE);
      text = text + QUOTE + QUOTE;
    else;
      text = text + %subst(i_text: x: 1);
    endif;
  endfor;

  return text;

end-proc;

**ctdata g_header
     /* =================================================================== */
     /*  Regenerates source member's meta data (type and text).             */
     /*                                                                     */
     /*  Usage: CALL A_METADATA TARGETLIB                                   */
     /*    where TARGETLIB is the library containing the RPGUnit            */
     /*    source files.                                                    */
     /* =================================================================== */
     /*   >>PRE-COMPILER<<                                                  */
     /*     >>CRTCMD<<  CRTBNDCL      PGM(&LI/&OB) +                        */
     /*                               SRCFILE(&SL/&SF)  +                   */
     /*                               SRCMBR(&SM);                          */
     /*     >>COMPILE<<                                                     */
     /*       >>PARM<< DBGVIEW(*LIST);                                      */
     /*     >>END-COMPILE<<                                                 */
     /*     >>LINK<<                                                        */
     /*       >>PARM<< DFTACTGRP(*NO);                                      */
     /*       >>PARM<< ACTGRP(*NEW);                                        */
     /*     >>END-LINK<<                                                    */
     /*     >>EXECUTE<<                                                     */
     /*   >>END-PRE-COMPILER<<                                              */
     /* =================================================================== */
