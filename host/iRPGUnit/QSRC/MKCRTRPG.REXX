/* =================================================================== */
/*  This Rexx script compiles the RUCRT* commands.                     */
/*                                                                     */
/*  Usage:                                                             */
/*  a) Add the iRPGUnit library to your library list.                  */
/*  b) Start the Rexx script with the following command:               */
/*       STRREXPRC SRCMBR(MKCRTRPG) SRCFILE(QSRC) PARM(prdLib)         */
/*     where 'prdLib' is the library containing the RPGUnit            */
/*     source files.                                                   */
/*                                                                     */
/*     Script parameters:                                              */
/*       prdLib   - Name of the iRPGUnit product library.              */
/*       dbgView  - The possible values are:                           */
/*                  NONE    : Default. Compiles the obejcts without    */
/*                            debug views.                             */
/*                  LIST    : Generates a listing view when compiling  */
/*                            the objects.                             */
/*       tgtRls   - The possible values are:                           */
/*                  CURRENT : The objects are compiled with the        */
/*                            release of the operating system          */
/*                            currently running on your system.        */
/*                  PRV     : The objects are compiled for the         */
/*                            previous release of the operating system */
/*                            currently running on your system.        */
/*                  VxRxMx  : Release in the format of VxRxMx.         */
/* =================================================================== */
/*   >>PRE-COMPILER<<                                                  */
/*     >>CRTCMD<<  STRREXPRC SRCMBR(&SM) SRCFILE(&SL/&SF);             */
/*     >>IMPORTANT<<                                                   */
/*       >>PARM<< PARM('&LI *LIST');                                   */
/*     >>END-IMPORTANT<<                                               */
/*     >>EXECUTE<<                                                     */
/*   >>END-PRE-COMPILER<<                                              */
/* =================================================================== */

 /* Register error handler */
 Signal on Error

 /* Setup ERROR,FAILURE & SYNTAX condition traps.*/
 SIGNAL on NOVALUE
 SIGNAL on SYNTAX

 /* The utility that is installed */
 UTILITY = 'RUCRTRPG'

 PARSE ARG prdLib dbgView tgtrls

 prdLib  = translate(strip(prdLib))
 dbgView = translate(strip(dbgView))
 tgtRls  = translate(strip(tgtRls))

 if (prdLib = "") then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Usage: STRREXPRC SRCMBR(MKCRTRPG) SRCFILE(QSRC) PARM(prdLib)')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"
 end

 select
 when (dbgView = '' | dbgView = 'NONE' | dbgView = '*NONE') then dbgView = '*NONE'
 when (dbgView = 'LIST' | dbgView = '*LIST') then dbgView = '*LIST'
 otherwise do
     "SNDPGMMSG ",
       "MSGID(CPF9898) ",
       "MSGF(QCPFMSG) ",
       "MSGDTA('Invalid debug view specfied: ''"dbgView"''. Use NONE or LIST')",
       "TOPGMQ(*PRV (*CTLBDY)) ",
       "MSGTYPE(*ESCAPE)"
   end
 end

 select
 when (tgtRls = '' | tgtRls = 'CURRENT') then tgtRls = '*CURRENT'
 when (tgtRls = 'PRV') then tgtRls = '*PRV'
 otherwise
 end

 /* -------------------------------------------- */
 /*  Let's do it!                                */
 /* -------------------------------------------- */
 "STRREXPRC SRCMBR(MKLLIST) SRCFILE("prdLib"/QLLIST) PARM('"prdLib" "dbgView" "tgtRls"')"

 "CMPMOD MODULE("prdLib"/CRTRPG   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/CRTTST   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/JOBLOG   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/LSTSPLF  ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/OBJECT   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/OSVERSION) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/PGMMSG   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/SRCMBR   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/STMF     ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/STRING   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/TAGTST   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/USRSPC   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"

 "CRTPGM PGM("prdLib"/RUCRTRPG) ",
        "MODULE("prdLib"/CRTTST     ",
                 prdLib"/CRTRPG     ",
                 prdLib"/JOBLOG     ",
                 prdLib"/LSTSPLF    ",
                 prdLib"/OBJECT     ",
                 prdLib"/OSVERSION  ",
                 prdLib"/PGMMSG     ",
                 prdLib"/SRCMBR     ",
                 prdLib"/STRING     ",
                 prdLib"/STMF       ",
                 prdLib"/TAGTST     ",
                 prdLib"/USRSPC   ) ",
        "ENTMOD("prdLib"/CRTRPG) ",
        "STGMDL(*SNGLVL) ",
        "BNDSRVPGM("prdLib"/RUTESTCASE "prdLib"/RUMEMMGR) ",
        "ACTGRP(*NEW) ",
        "ALWUPD(*YES) ",
        "ALWLIBUPD(*YES) ",
        "DETAIL(*NONE) ",
        "TGTRLS("tgtRls") ",
        "TEXT('iRPGUnit - Create Test Suite.')"

 "CRTPNLGRP  PNLGRP("prdLib"/RUCRTRPG) SRCFILE("prdLib"/QPNLGRP)"
 deleteSpooledFile('RUCRTRPG')

 "CRTCMD CMD("prdLib"/RUCRTRPG) ",
        "PGM("prdLib"/RUCRTRPG) ",
        "SRCFILE(*LIBL/QCMD) ",
        "HLPPNLGRP("prdLib"/RUCRTRPG) ",
        "HLPID(RUCRTRPG)"
 deleteSpooledFile('RUCRTRPG')

 /* Ensure backward compatibility */
 Signal off Error
 "DLTCMD CMD("prdLib"/RUCRTTST)"
 Signal on Error

 "CRTDUPOBJ OBJ(RUCRTRPG) ",
           "FROMLIB("prdLib") ",
           "OBJTYPE(*CMD) ",
           "TOLIB("prdLib") ",
           "NEWOBJ(RUCRTTST)"

 "SNDPGMMSG ",
   "MSGID(CPF9897) ",
   "MSGF(QCPFMSG) ",
   "MSGDTA('Successfully compiled "UTILITY" in library: "prdLib"')",
   "TOPGMQ(*PRV (*CTLBDY)) ",
   "MSGTYPE(*INFO)"

 EXIT

 /* ------------------------------------------------------------- */
 /* Delete specified spooled file.                                */
 /* ------------------------------------------------------------- */
deleteSpooledFile:
   PARSE ARG _splf

   Signal off Error
   'DLTSPLF FILE('_splf') JOB(*) SPLNBR(*LAST)'
   Signal on Error

   return ''

 /* ------------------------------------------------------------- */
 /* Global Error handler                                          */
 /* ------------------------------------------------------------- */
 Error:
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('ERROR: Failed to install "UTILITY". Check the job log for details') ",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"

   EXIT

