/* =================================================================== */
/*  This Rexx script compiles the RUCALLTST command.                   */
/*                                                                     */
/*  Usage:                                                             */
/*  a) Add the iRPGUnit library to your library list.                  */
/*  b) Start the Rexx script with the following command:               */
/*       STRREXPRC SRCMBR(MKCALLTST) SRCFILE(QSRC) PARM(prdLib)        */
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
 UTILITY = 'RUCALLTST'

 PARSE ARG prdLib dbgView tgtrls

 prdLib  = translate(strip(prdLib))
 dbgView = translate(strip(dbgView))
 tgtRls  = translate(strip(tgtRls))

 if (prdLib = "") then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Usage: STRREXPRC SRCMBR(MKCALLTST) SRCFILE(QSRC) PARM(prdLib)')",
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
 /*  Recreate the modules if needed.             */
 /* -------------------------------------------- */

 "STRREXPRC SRCMBR(A_INSTALL) SRCFILE(RPGUNITDVP/QBUILD) PARM('CMPMOD "prdLib" "dbgView"')"

 /* -------------------------------------------- */
 /*  Let's do it!                                */
 /* -------------------------------------------- */

 "CRTPGM PGM("prdLib"/RUCALLTST) ",
        "MODULE("prdLib"/CMDRUN) ",
        "ENTMOD("prdLib"/CMDRUN) ",
        "BNDDIR("prdLib"/IRPGUNIT) ",
        "ACTGRP(*NEW) ",
        "ALWUPD(*YES) ",
        "ALWLIBUPD(*YES) ",
        "TGTRLS("tgtRls") ",
        "STGMDL(*SNGLVL) ",
        "TEXT('iRPGUnit - Execute Test Suite.') ",
        "DETAIL(*NONE) "

 "CRTPGM PGM("prdLib"/RUCALLTSTV) ",
        "MODULE("prdLib"/CMDRUNV    ",
                 prdLib"/JOBLOG     ",
                 prdLib"/PGMMSG     ",
                 prdLib"/STRING)    ",
        "ENTMOD("prdLib"/CMDRUNV) ",
        "BNDSRVPGM("prdLib"/RUTESTCASE) ",
        "ACTGRP(*NEW) ",
        "ALWUPD(*YES) ",
        "ALWLIBUPD(*YES) ",
        "DETAIL(*NONE) ",
        "TGTRLS("tgtRls") ",
        "TEXT('iRPGUnit - RUCALLTST Validity checking program.')"

 "CRTPNLGRP  PNLGRP("prdLib"/RUCALLTST) SRCFILE("prdLib"/QPNLGRP)"
 deleteSpooledFile('RUCALLTST')

 "CRTCMD CMD("prdLib"/RUCALLTST) ",
        "PGM("prdLib"/RUCALLTST) ",
        "SRCFILE(*LIBL/QCMD) ",
        "VLDCKR("prdLib"/RUCALLTSTV) ",
        "HLPPNLGRP("prdLib"/RUCALLTST) ",
        "HLPID(RUCALLTST)"
 deleteSpooledFile('RUCALLTST')

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

