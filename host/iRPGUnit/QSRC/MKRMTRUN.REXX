/* =================================================================== */
/*  This Rexx script compiles the RUPGMRMT program.                    */
/*                                                                     */
/*  Usage:                                                             */
/*  a) Add the iRPGUnit library to your library list.                  */
/*  b) Start the Rexx script with the following command:               */
/*       STRREXPRC SRCMBR(MKRMTRUN) SRCFILE(QSRC) PARM(prdLib)         */
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
/*       >>PARM<< PARM('&LI');                                         */
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
 UTILITY = 'RUPGMRMT'

 PARSE ARG prdLib dbgView tgtrls

 prdLib  = translate(strip(prdLib))
 dbgView = translate(strip(dbgView))
 tgtRls  = translate(strip(tgtRls))

 if (prdLib = "") then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Usage: STRREXPRC SRCMBR(MKRMTRUN) SRCFILE(QSRC) PARM(prdLib)')",
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

 "CMPMOD MODULE("prdLib"/PGMRMT   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/CALLPRC  ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/CMDRUN   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/CMDRUNLOG) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/CMDRUNPRT) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/CMDRUNSRV) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/CMDRUNV  ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/EXTPRC   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/EXTTST   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/JOBLOG   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/LIBL     ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/OBJECT   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/OSVERSION) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/PGMMSG   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/SRCMBR   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/STMF     ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/STRING   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/USRSPC   ) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/RMTRUNSRV) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/XMLWRITER) SRCFILE("prdLib"/QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"

 "CRTPGM PGM("prdLib"/RUPGMRMT) ",
        "MODULE("prdLib"/PGMRMT     ",
                 prdLib"/CALLPRC    ",
                 prdLib"/CMDRUN     ",
                 prdLib"/CMDRUNLOG  ",
                 prdLib"/CMDRUNPRT  ",
                 prdLib"/CMDRUNSRV  ",
                 prdLib"/CMDRUNV    ",
                 prdLib"/EXTPRC     ",
                 prdLib"/EXTTST     ",
                 prdLib"/JOBLOG     ",
                 prdLib"/LIBL       ",
                 prdLib"/LLIST      ",
                 prdLib"/OBJECT     ",
                 prdLib"/OSVERSION  ",
                 prdLib"/PGMMSG     ",
                 prdLib"/RMTRUNSRV  ",
                 prdLib"/STRING     ",
                 prdLib"/SRCMBR     ",
                 prdLib"/STMF       ",
                 prdLib"/USRSPC     ",
                 prdLib"/XMLWRITER) ",
        "ENTMOD("prdLib"/PGMRMT) ",
        "BNDSRVPGM("prdLib"/RUTESTCASE) ",
        "ACTGRP(*NEW) ",
        "ALWUPD(*YES) ",
        "ALWLIBUPD(*YES) ",
        "DETAIL(*NONE) ",
        "TGTRLS("tgtRls") ",
        "TEXT('iRPGUnit - Execute Test Suite.')"

 Signal off Error

 "DLTWSCST WSCST("prdLib"/RUWSCST)"
 "DLTJOBD JOBD("prdLib"/RPGUNIT)"

 Signal on Error

 "CRTWSCST WSCST("prdLib"/RUWSCST) ",
        "SRCFILE("prdLib"/QSRC)"

 "CRTJOBD JOBD("prdLib"/RPGUNIT) ",
        "TEXT('iRPGUnit - Library list for test cases') ",
        "INLLIBL("prdLib")"

 "SNDPGMMSG ",
   "MSGID(CPF9897) ",
   "MSGF(QCPFMSG) ",
   "MSGDTA('Successfully compiled "UTILITY" in library: "prdLib"')",
   "TOPGMQ(*PRV (*CTLBDY)) ",
   "MSGTYPE(*INFO)"

 EXIT

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

