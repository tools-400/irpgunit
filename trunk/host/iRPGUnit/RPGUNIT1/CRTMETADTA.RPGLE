      * ===================================================================
      *  Create RPGUnit Meta Data (Member Description and Type).
      * ===================================================================
      * >>PRE-COMPILER<<
      *   >>CRTCMD<< CRTRPGMOD    MODULE(&LI/&OB) +
      *                           SRCFILE(&SL/&SF) +
      *                           SRCMBR(&SM);
      *   >>COMPILE<<
      *     >>PARM<< OPTION(*EVENTF);
      *     >>PARM<< TRUNCNBR(*NO);
      *     >>PARM<< DBGVIEW(*LIST);
      *   >>END-COMPILE<<
      *   >>EXECUTE<<
      *   >>CMD<<    CRTPGM       PGM(&LI/&OB) +
      *                           MODULE(&LI/&OB ) +
      *                           BNDDIR(*LIBL/QC2LE) +
      *                           DETAIL(*BASIC);
      * >>END-PRE-COMPILER<<
      * ===================================================================
      /copy RPGUNITY1,H_SPEC
      * ===================================================================
     FQAFDMBRL  IF   E             DISK    usropn
     F                                     extfile(g_outfile)
      *
     FRPGUNIT1  UF A E             DISK    usropn
     F                                     rename(RPGUNIT1: FRPGUNIT1)
     F                                     extfile(g_srcfile)
     F                                     extmbr(g_srcmbr  )
      *
     D g_outfile       S             20A   varying inz('QTEMP/#CRTMBRD')
     D g_srcfile       S             20A   varying inz
     D g_srcmbr        S             10A   varying inz('MKMETADATA')
      *
     D g_copybooks     S             20A   varying inz
      * ------------------------------------
      *  Type definitions
      * ------------------------------------
      /define COPYRIGHT_DSPEC
      /copy RPGUNITY1,COPYRIGHT
      /undefine COPYRIGHT_DSPEC
      *
      * ------------------------------------
      *  External Prototypes
      * ------------------------------------
      *
      *  ... Execute Command (QCMDEXC) API
     D QCMDEXC...
     D                 PR                  extpgm('QCMDEXC')
     D  i_cmd                     32702A   const  options(*varsize)
     D  i_length                     15P 5 const
     D  i_IGCprcCtrl                  3A   const  options(*nopass)
      *
     D QCMDEXC_IGC     C                   'IGC'
      *
      * ------------------------------------
      *  Global Fields
      * ------------------------------------
     D QUOTE           C                   ''''
     D LEFT_MARGIN     C                   13
     D LEFT_INDENT     C                   26
     D TARGET_LIB      C                   '&TARGETLIB'
      *
     D g_header        S             80A   dim(21) ctdata
      *
      * ------------------------------------
      *  Globale Konstanten
      * ------------------------------------
      *
      * ------------------------------------
      *  Prototypes
      * ------------------------------------
     D PGM_ENTRY_POINT...
     D                 PR                  extpgm('#CRTMBRD')
     D  gi_lib                       10A   const  options(*nopass)
     D  go_release                   20A          options(*nopass)
      *
     D main...
     D                 PR                  extproc('main')
     D  i_lib                        10A   const  varying
     D  o_release                    20A
      *
      *  Executes the DSPFD command for a given file and library.
     D File_exportMemberList...
     D                 PR                  extproc('File_exportMemberList')
     D  i_lib                        10A   const  varying
     D  i_file                       10A   const  varying
      *
      *  Appends a record to RPGUNIT1.
     D SrcMbr_write...
     D                 PR                  extproc('SrcMbr_write')
     D  i_text                      100A   const  varying options(*varsize)
     D  i_spaces                     10I 0 const
      *
      *  Appends command CHGPFM to the output source member.
     D SrcMbr_appendCmdChgPfm...
     D                 PR                  extproc('SrcMbr_appendCmdChgPfm')
     D  i_file                       10A   const
     D  i_lib                        10A   const
     D  i_mbr                        10A   const
     D  i_type                       10A   const
     D  i_text                       50A   const
      *
      *  Appends command MONMSG to the output source member.
     D SrcMbr_appendCmdMonMsg...
     D                 PR                  extproc('SrcMbr_appendCmdMonMsg')
     D  i_msgId                       7A   const
      *
      *  Appends and empty line to the output source member.
     D SrcMbr_appendEmptyLine...
     D                 PR                  extproc('SrcMbr_appendEmptyLine')
      *
      *  Doubles a single quote.
     D doubleQuotes...
     D                 PR           100A   varying
     D                                     extproc('doubleQuotes')
     D  i_text                       50A   const
      *
      *  Sends a message to QCMD
     D sndMsg...
     D                 PR                         extproc('sndMsg')
     D  i_text                      128A   value  varying
      *
      *===============================================================*
      *  Program Entry Point
      *===============================================================*
     D PGM_ENTRY_POINT...
     D                 PI
     D  gi_lib                       10A   const  options(*nopass)
     D  go_release                   20A          options(*nopass)
      *
     D release         S             20A   inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         if (%parms() >= 1);
            main(%trim(gi_lib): release);
         else;
            main('*LIBL': release);
         endif;

         if (%parms() >= 2);
            go_release = release;
         endif;

         *inlr = *on;

         return;

      /END-FREE
      *
      *===============================================================*
      *  *** private ***
      *  Sends a message to the caller.
      *===============================================================*
     P sndMsg...
     P                 B
      *
     D sndMsg...
     D                 PI
     D  i_text                      128A   value  varying
      *
      *  Return value
     D pBuffer         S               *   inz
      *
      *  Local fields
     D msgKey          S              4A                        inz
      *
     D qMsgF           DS                  qualified            inz
     D  name                         10A
     D  lib                          10A
      *
     D errCode         DS                  qualified            inz
     D  bytPrv                       10I 0
     D  bytAvl                       10I 0
     D  excID                         7A
     D  reserved                      1A
     D  excDta                      256A
      *
      *  Send Program Message (QMHSNDPM) API
     D QMHSNDPM        PR                         extpgm('QMHSNDPM')
     D   i_msgID                      7A   const
     D   i_qMsgF                     20A   const
     D   i_msgData                32767A   const  options(*varsize )
     D   i_length                    10I 0 const
     D   i_msgType                   10A   const
     D   i_callStkE               32767A   const  options(*varsize )
     D   i_callStkC                  10I 0 const
     D   o_msgKey                     4A
     D   io_ErrCode               32767A          options(*varsize )
     D   i_lenStkE                   10I 0 const  options(*nopass  )
     D   i_callStkEQ                 20A   const  options(*nopass  )
     D   i_wait                      10I 0 const  options(*nopass  )
     D   i_callStkEDT                10A   const  options(*nopass  )
     D   i_ccsid                     10I 0 const  options(*nopass  )
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         clear qMsgF;
         qMsgF.name = 'QCPFMSG';
         qMsgF.lib  = '*LIBL';

         clear errCode;
         errCode.bytPrv = %size(errCode);

         QMHSNDPM('CPF9897': qMsgF: i_text: %len(i_text): '*INFO'
                  : '*CTLBDY': 1
                  : msgKey: errCode);

         return;

      /END-FREE
      *
     P sndMsg...
     P                 E
      *
      *===============================================================*
      *  Main procedure
      *===============================================================*
     P main...
     P                 B
      *
     D main...
     D                 PI
     D  i_lib                        10A   const  varying
     D  o_release                    20A
      *
      *  Helper fields
     D isFirstRcd      S               N   inz(*ON)
     D x               S             10I 0 inz
     D cmd             S           1024A   varying inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

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
            g_srcfile = %trim(i_lib) + '/RPGUNIT1';

            monitor;
               cmd = 'CHKOBJ OBJ(' + g_srcfile + ') +
                             OBJTYPE(*FILE) MBR(' + g_srcmbr + ')';
               qcmdexc(cmd: %len(cmd));
               cmd = 'CLRPFM FILE(' + g_srcfile + ') MBR(' + g_srcmbr + ')';
               qcmdexc(cmd: %len(cmd));
            on-error;
               cmd = 'ADDPFM FILE(' + g_srcfile + ') MBR(' + g_srcmbr + ') +
                        TEXT(' + QUOTE +
                          'RPGUnit - Regenerate source member''s metadata.' +
                          QUOTE + ') +
                        SRCTYPE(CLLE)';
               qcmdexc(cmd: %len(cmd));
            endmon;

            // Get member list into output file
            File_exportMemberList(i_lib: 'RPGUNITC1');
            File_exportMemberList(i_lib: 'RPGUNITF1');
            File_exportMemberList(i_lib: 'RPGUNITT1');
            File_exportMemberList(i_lib: 'RPGUNITY1');
            File_exportMemberList(i_lib: 'RPGUNIT1' );

            qcmdexc(cmd: %len(cmd));

            // Write source member ...
            open RPGUNIT1;
            clear FRPGUNIT1;

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
                  SrcMbr_write('DCL        +
                                  VAR(' + TARGET_LIB + ') +
                                  TYPE(*CHAR) LEN(10) +
                                  VALUE(' + %trim(MLLIB) + ')': LEFT_MARGIN);
                  SrcMbr_write('': 0);

                  SrcMbr_write('CHGVAR     +
                                  VAR(' + TARGET_LIB + ') +
                                  VALUE(' + TARGET_LIB + ')': LEFT_MARGIN);

                  SrcMbr_write('MONMSG     +
                                 MSGID(MCH3601) EXEC(SNDPGMMSG MSGID(CPF9898) +'
                                : LEFT_MARGIN);
                  SrcMbr_write('MSGF(QCPFMSG) MSGDTA(''Target library +'
                                : LEFT_INDENT);
                  SrcMbr_write('parameter required.'') MSGTYPE(*ESCAPE))'
                                : LEFT_INDENT);
                  SrcMbr_write('': 0);

                  isFirstRcd = *OFF;
               endif;

               SrcMbr_appendCmdChgPfm(
                              MLFILE: TARGET_LIB: MLNAME: MLSEU2: MLMTXT);
               SrcMbr_appendCmdMonMsg('CPF3288');
               SrcMbr_appendEmptyLine();
            enddo;

            close QAFDMBRL;

            // ... footer
            SrcMbr_write('ENDPGM': LEFT_MARGIN);

            close RPGUNIT1;

            release = cRPGUNIT_VERSION;

         on-error;
            sndMsg('*** Unexpected error! ***');
         endmon;

         return;

      /END-FREE
      *
     P main...
     P                 E
      *
      *===============================================================*
      *  Executes the DSPFD command for a given file and library.
      *===============================================================*
     P File_exportMemberList...
     P                 B
      *
     D File_exportMemberList...
     D                 PI
     D  i_lib                        10A   const  varying
     D  i_file                       10A   const  varying
      *
     D cmd             S           1024A   varying inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         // Get member list into output file
         cmd = 'DSPFD FILE(' + i_lib + '/' + i_file + ') +
                      TYPE(*MBRLIST) OUTPUT(*OUTFILE) +
                      OUTFILE(' + g_outfile + ') +
                      OUTMBR(*FIRST *ADD)';
         qcmdexc(cmd: %len(cmd));

         return;

      /END-FREE
      *
     P File_exportMemberList...
     P                 E
      *
      *===============================================================*
      *  Appends a record to RPGUNIT1.
      *===============================================================*
     P SrcMbr_write...
     P                 B
      *
     D SrcMbr_write...
     D                 PI
     D  i_text                      100A   const  varying options(*varsize)
     D  i_spaces                     10I 0 const
      *
      *  Helper fields
     D spaces          S            100A   inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         SRCSEQ = SRCSEQ + 1;
         SRCDAT = 0;
         SRCDTA = %subst(spaces: 1: i_spaces) + i_text;

         write FRPGUNIT1;

         return;

      /END-FREE
      *
     P SrcMbr_write...
     P                 E
      *
      *===============================================================*
      *  Appends command CHGPFM to the output source member.
      *===============================================================*
     P SrcMbr_appendCmdChgPfm...
     P                 B
      *
     D SrcMbr_appendCmdChgPfm...
     D                 PI
     D  i_file                       10A   const
     D  i_lib                        10A   const
     D  i_mbr                        10A   const
     D  i_type                       10A   const
     D  i_text                       50A   const
      *
      *  Helper fields
     D line            S             80A   inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         line = 'CHGPFM     FILE(' + %trim(i_lib) + '/' + %trim(i_file) + ') +';
         SrcMbr_write(line: LEFT_MARGIN);

         line = 'MBR(' + %trim(i_mbr) + ') +';
         SrcMbr_write(line: LEFT_INDENT);

         line = 'SRCTYPE(' + %trim(i_type) + ') +';
         SrcMbr_write(line: LEFT_INDENT);

         line = 'TEXT(' + QUOTE + doubleQuotes(i_text) + QUOTE + ')';
         SrcMbr_write(line: LEFT_INDENT);

         return;

      /END-FREE
      *
     P SrcMbr_appendCmdChgPfm...
     P                 E
      *
      *===============================================================*
      *  Appends command MONMSG to the output source member.
      *===============================================================*
     P SrcMbr_appendCmdMonMsg...
     P                 B
      *
     D SrcMbr_appendCmdMonMsg...
     D                 PI
     D  i_msgId                       7A   const
      *
      *  Helper fields
     D line            S             80A   inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         line = 'MONMSG     MSGID(' + %trim(i_msgId) + ') ';
         SrcMbr_write(line: LEFT_MARGIN);

         return;

      /END-FREE
      *
     P SrcMbr_appendCmdMonMsg...
     P                 E
      *
      *===============================================================*
      *  Appends and empty line to the output source member.
      *===============================================================*
     P SrcMbr_appendEmptyLine...
     P                 B
      *
     D SrcMbr_appendEmptyLine...
     D                 PI
      *
      *  Helper fields
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         SrcMbr_write('': 0);

         return;

      /END-FREE
      *
     P SrcMbr_appendEmptyLine...
     P                 E
      *
      *===============================================================*
      *  Doubles a single quote.
      *===============================================================*
     P doubleQuotes...
     P                 B
      *
     D doubleQuotes...
     D                 PI           100A   varying
     D  i_text                       50A   const
      *
      *  Return value
     D text            S            100A   varying inz
      *
      *  Helper fields
     D x               S             10I 0 inz
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      /FREE

         for x = 1 to %len(%trimR(i_text));
            if (%subst(i_text: x: 1) = QUOTE);
               text = text + QUOTE + QUOTE;
            else;
               text = text + %subst(i_text: x: 1);
            endif;
         endfor;

         return text;

      /END-FREE
      *
     P doubleQuotes...
     P                 E
      *
**ctdata g_header
     /* =================================================================== */
     /*  Regenerates source member's meta data (type and text).             */
     /*                                                                     */
     /*  Usage: CALL MKMETADATA TARGETLIB                                   */
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
