/* =================================================================== */
/*  This Rexx script compiles the EXTTSTT unit test.                   */
/*                                                                     */
/*  Usage:                                                             */
/*  a) Add the iRPGUnit library to your library list.                  */
/*  b) Start the Rexx script with the following command:               */
/*       STRREXPRC SRCMBR(MKEXTTSTT) SRCFILE(QUNITTEST) PARM(prdLib)   */
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
 UTILITY = 'EXTTSTT'

 PARSE ARG prdLib dbgView tgtrls

 prdLib  = translate(strip(prdLib))
 dbgView = translate(strip(dbgView))
 tgtRls  = translate(strip(tgtRls))

 if (prdLib = "") then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Usage: STRREXPRC SRCMBR(MKEXTTSTT) SRCFILE(QUNITTEST) PARM(prdLib)')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"
 end

 select
 when (dbgView = '') then dbgView = '*LIST'
 when (dbgView = 'NONE' | dbgView = '*NONE') then dbgView = '*NONE'
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
 "STRREXPRC SRCMBR(MKLLIST) SRCFILE(QLLIST) PARM('"prdLib" "dbgView" "tgtRls"')"

 "CMPMOD MODULE(QTEMP/EXTTSTT  ) SRCFILE(QUNITTEST) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE(QTEMP/CALLPRC  ) SRCFILE(QSRC     ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE(QTEMP/CMDRUNSRV) SRCFILE(QSRC     ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE(QTEMP/EXTPRC   ) SRCFILE(QSRC     ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE(QTEMP/EXTTST   ) SRCFILE(QSRC     ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE(QTEMP/PGMMSG   ) SRCFILE(QSRC     ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE(QTEMP/STRING   ) SRCFILE(QSRC     ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE(QTEMP/USRSPC   ) SRCFILE(QSRC     ) DBGVIEW("dbgView") TGTRLS("tgtRls")"

 "CRTSRVPGM  SRVPGM("prdLib"/EXTTSTT) ",
            "MODULE(QTEMP/EXTTSTT   ",
                   "QTEMP/CALLPRC   ",
                   "QTEMP/CMDRUNSRV ",
                   "QTEMP/EXTPRC    ",
                   "QTEMP/EXTTST    ",
                   "QTEMP/LLIST     ",
                   "QTEMP/PGMMSG    ",
                   "QTEMP/STRING    ",
                   "QTEMP/USRSPC)   ",
            "EXPORT(*ALL) ",
            "OPTION(*DUPPROC) ",
            "BNDSRVPGM(*LIBL/RUTESTCASE) ",
            "TEXT('RPGUnit SelfTest - Test EXTTST.')"

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

