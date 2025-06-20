/* =================================================================== */
/*  This Rexx script compiles the RUPLIGIN* example test suites.       */
/*  These test suites are mainly used for testing plug-in features.    */
/*                                                                     */
/*  Usage:                                                             */
/*  a) Add the iRPGUnit library to your library list.                  */
/*  b) Start the Rexx script with the following command:               */
/*       STRREXPRC SRCMBR(MKEXAMPLE) SRCFILE(QEXAMPLE) PARM(prdLib)    */
/*     where 'prdLib' is the library containing the RPGUnit            */
/*     source files.                                                   */
/*                                                                     */
/*     Script parameters:                                              */
/*       prdLib   - Name of the iRPGUnit product library.              */
/*       dbgView  - The possible values are:                           */
/*                  ALL     : Default. Generates all debug views when  */
/*                            compiling the objects.                   */
/*                  NONE    : Compiles the obejcts without debug       */
/*                            views.                                   */
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
 UTILITY = 'PLUG-IN EXAMPLES'

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
 when (dbgView = '' | dbgView = 'ALL' | dbgView = '*ALL') then dbgView = '*ALL'
 when (dbgView = 'STMT' | dbgView = '*STMT') then dbgView = '*STMT'
 when (dbgView = 'SOURCE' | dbgView = '*SOURCE') then dbgView = '*SOURCE'
 when (dbgView = 'LIST' | dbgView = '*LIST') then dbgView = '*LIST'
 when (dbgView = 'COPY' | dbgView = '*COPY') then dbgView = '*COPY'
 when (dbgView = 'NONE' | dbgView = '*NONE') then dbgView = '*NONE'
 otherwise do
     "SNDPGMMSG ",
       "MSGID(CPF9898) ",
       "MSGF(QCPFMSG) ",
       "MSGDTA('Invalid debug view specfied: ''"dbgView"''.')",
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
 compileTestSuite(prdLib, 'RUPLUGINT1', dbgView)
 compileTestSuite(prdLib, 'RUPLUGINT2', dbgView)
 compileTestSuite(prdLib, 'RUPLUGINT3', dbgView)
 compileTestSuite(prdLib, 'RUPLUGINT4', dbgView)
 compileTestSuite(prdLib, 'RUPLUGINT5', dbgView)
 compileTestSuite(prdLib, 'RUPLUGINT6', dbgView)
 compileTestSuite(prdLib, 'RUPLUGINT7', dbgView)
 compileTestSuite(prdLib, 'RUPLUGINT8', dbgView)

 "SNDPGMMSG ",
   "MSGID(CPF9897) ",
   "MSGF(QCPFMSG) ",
   "MSGDTA('Successfully compiled "UTILITY" in library: "prdLib"')",
   "TOPGMQ(*PRV (*CTLBDY)) ",
   "MSGTYPE(*INFO)"

 EXIT

 /* ------------------------------------------------------------- */
 /* Compile iRPGUnit test suite.                                  */
 /* ------------------------------------------------------------- */
 compileTestSuite:
   PARSE ARG _prdLib, _tstPgm, _dbgView

   "RUCRTRPG TSTPGM("_prdLib"/"_tstPgm") ",
     "SRCFILE("prdLib"/QEXAMPLE) SRCMBR("_tstPgm") ",
     "COPTION(*SRCSTMT *EVENTF) DBGVIEW("_dbgView")"

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

