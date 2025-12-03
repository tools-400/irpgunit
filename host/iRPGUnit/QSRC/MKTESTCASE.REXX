/* =================================================================== */
/*  This Rexx script compiles the RUTESTCASE service program.          */
/*                                                                     */
/*  Usage:                                                             */
/*  a) Add the iRPGUnit library to your library list.                  */
/*  b) Start the Rexx script with the following command:               */
/*       STRREXPRC SRCMBR(MKTESTCASE) SRCFILE(QSRC) PARM(prdLib)       */
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
/*       define   - Compiler conditions:                               */
/*                  DISABLE_ASSERT_EQUAL                               */
/*                          : Disable the assertEqual() protoptye      */
/*                            with the 'overload' keyword to compile   */
/*                            the library on 7.4 and 7.3 systems       */
/*                            without the required PTFs.               */
/*                            Required PTFs:                           */
/*                            7.4: ILE RPG runtime: SI71537            */
/*                                 ILE RPG compiler: SI71536           */
/*                            7.3: ILE RPG runtime: SI71535            */
/*                                 ILE RPG compiler: SI71534           */
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
 UTILITY = 'RUTESTCASE'

 PARSE ARG prdLib dbgView tgtrls define

 prdLib  = translate(strip(prdLib))
 dbgView = translate(strip(dbgView))
 tgtRls  = translate(strip(tgtRls))
 define  = translate(strip(define))

 if (prdLib = "") then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Usage: STRREXPRC SRCMBR(MKTESTCASE) SRCFILE(QSRC) PARM(prdLib)')",
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

 "CMPMOD MODULE("prdLib"/ASSERT   ) SRCFILE("prdLib"/QSRC  ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/ASSERTV2 ) SRCFILE("prdLib"/QSRC  ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/CALLSTACK) SRCFILE("prdLib"/QSRC  ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/JOBLOG   ) SRCFILE("prdLib"/QSRC  ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/LLIST    ) SRCFILE("prdLib"/QLLIST) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/OBJECT   ) SRCFILE("prdLib"/QSRC  ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/PGMMSG   ) SRCFILE("prdLib"/QSRC  ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/VERSION  ) SRCFILE("prdLib"/QSRC  ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/TESTUTILS) SRCFILE("prdLib"/QSRC  ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/STRING   ) SRCFILE("prdLib"/QSRC  ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/SRCMBR   ) SRCFILE("prdLib"/QSRC  ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/STMF     ) SRCFILE("prdLib"/QSRC  ) DBGVIEW("dbgView") TGTRLS("tgtRls")"
 "CMPMOD MODULE("prdLib"/USRSPC   ) SRCFILE("prdLib"/QSRC  ) DBGVIEW("dbgView") TGTRLS("tgtRls")"

 "CRTSRVPGM  SRVPGM("prdLib"/RUTESTCASE) ",
              "MODULE("prdLib"/ASSERT     ",
                       prdLib"/ASSERTV2   ",
                       prdLib"/CALLSTACK  ",
                       prdLib"/JOBLOG     ",
                       prdLib"/LLIST      ",
                       prdLib"/OBJECT     ",
                       prdLib"/PGMMSG     ",
                       prdLib"/VERSION    ",
                       prdLib"/TESTUTILS  ",
                       prdLib"/STRING     ",
                       prdLib"/SRCMBR     ",
                       prdLib"/STMF       ",
                       prdLib"/USRSPC)    ",
              "STGMDL(*INHERIT) ",
              "BNDSRVPGM("prdLib"/RUMEMMGR) ",
              "EXPORT(*SRCFILE) ",
              "SRCFILE("prdLib"/QBND) SRCMBR(RUTESTCASE) ",
              "TGTRLS("tgtRls") ",
              "TEXT('iRPGUnit - Test Suite Toolkit.')"

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

