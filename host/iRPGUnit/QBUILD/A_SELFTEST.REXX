/* =================================================================== */
/*  This Rexx script compiles and runs the iRPGUnit self- and          */
/*  acceptance tests.                                                  */
/*                                                                     */
/*  Usage:                                                             */
/*  a) Add the iRPGUnit library to your library list.                  */
/*  b) Start the Rexx script with the following command:               */
/*       STRREXPRC SRCMBR(A_SELFTEST) SRCFILE(QBUILD) PARM(prdLib)     */
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

 PARSE ARG prdLib dbgView tgtrls

 prdLib  = translate(strip(prdLib))
 dbgView = translate(strip(dbgView))
 tgtRls  = translate(strip(tgtRls))

 if (prdLib = "") then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Usage: STRREXPRC SRCMBR(A_SELFTEST) SRCFILE(QBUILD) PARM(prdLib)')",
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

 bndDir = 'IRPGUNIT'

 /* Create iRPGUnit binding directory. */

 Signal off Error
 "DLTBNDDIR BNDDIR("prdLib"/"bndDir")"
 Signal on Error

 if ("CHKOBJ OBJ("prdLib"/"bndDir") OBJTYPE(*BNDDIR)" = 1) then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('ERROR: Could not delete binding directory: 'bndDir) ",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"
 end

 "CRTBNDDIR BNDDIR("prdLib"/"bndDir") TEXT('iRPGUnit - Binding Directory')"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/ASSERT    *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/CALLPRC   *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/CMDRUN    *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/CMDRUNLOG *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/CMDRUNPRT *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/CMDRUNSRV *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/CMDRUNV   *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/CRTTST    *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/EXTPRC    *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/EXTTST    *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/LIBL      *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/OBJECT    *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/OSVERSION *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/PGMMSG    *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/PGMRMT    *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/RMTRUNSRV *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/SRCMBR    *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/STRING    *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/TAGTST    *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/TESTUTILS *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/USRSPC    *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/VERSION   *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/XMLWRITER *MODULE))"

 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/LLIST     *MODULE))"

 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/LIBLC     *MODULE))"
 "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/SPLF      *MODULE))"

 /* Compile iRPGUnit modules. */

 "CMPMOD MODULE("prdLib"/ASSERT   ) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/CALLPRC  ) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/CMDRUN   ) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/CMDRUNLOG) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/CMDRUNPRT) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/CMDRUNSRV) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/CMDRUNV  ) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/CRTTST   ) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/EXTPRC   ) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/EXTTST   ) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/LIBL     ) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/OBJECT   ) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/OSVERSION) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/PGMMSG   ) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/PGMRMT   ) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/RMTRUNSRV) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/SRCMBR   ) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/STRING   ) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/TAGTST   ) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/TESTUTILS) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/USRSPC   ) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/VERSION  ) SRCFILE(QSRC) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/XMLWRITER) SRCFILE(QSRC) DBGVIEW("dbgView")"

 "STRREXPRC SRCMBR(MKLLIST) SRCFILE(QLLIST) PARM('"prdLib" "dbgView" "tgtRls"')"

 "CMPMOD MODULE("prdLib"/LIBLC    ) SRCFILE(QUNITTEST) DBGVIEW("dbgView")"
 "CMPMOD MODULE("prdLib"/SPLF     ) SRCFILE(QUNITTEST) DBGVIEW("dbgView")"

 /* Create iRPGUnit SelfTest unit tests. */

 createUnitTest(prdLib, bndDir, 'ASSERTT', dbgView)
 createUnitTest(prdLib, bndDir, 'CALLPRCT', dbgView)
 createUnitTest(prdLib, bndDir, 'CMDRUNLOGT', dbgView)
 createUnitTest(prdLib, bndDir, 'CMDRUNT', dbgView)
 createUnitTest(prdLib, bndDir, 'CRTTSTT', dbgView)
 createUnitTest(prdLib, bndDir, 'EXTPRCT', dbgView)
 createUnitTest(prdLib, bndDir, 'EXTTSTT', dbgView)
 createUnitTest(prdLib, bndDir, 'JOBLOGT', dbgView)
 createUnitTest(prdLib, bndDir, 'LIBLT', dbgView)
 createUnitTest(prdLib, bndDir, 'MSGQT', dbgView)
 createUnitTest(prdLib, bndDir, 'PGMMSGT', dbgView)
 createUnitTest(prdLib, bndDir, 'RUNT', dbgView)
 createUnitTest(prdLib, bndDir, 'STRINGT', dbgView)

 createUnitTest(prdLib, bndDir, 'ACPTSTT', dbgView)

 /* Run iRPGUnit SelfTest unit tests. */

 runUnitTest(prdLib, 'ASSERTT')
 runUnitTest(prdLib, 'CALLPRCT')
 runUnitTest(prdLib, 'CMDRUNLOGT')
 runUnitTest(prdLib, 'CMDRUNT')
 runUnitTest(prdLib, 'CRTTSTT')
 runUnitTest(prdLib, 'EXTPRCT')
 runUnitTest(prdLib, 'EXTTSTT')
 runUnitTest(prdLib, 'JOBLOGT')
 runUnitTest(prdLib, 'LIBLT')
 runUnitTest(prdLib, 'MSGQT')
 runUnitTest(prdLib, 'PGMMSGT')
 runUnitTest(prdLib, 'RUNT')
 runUnitTest(prdLib, 'STRINGT')

 runUnitTest(prdLib, 'ACPTSTT')

 /* Delete modules and binding directory. */

 "STRREXPRC SRCMBR(A_INSTALL) SRCFILE("prdLib"/QBUILD) PARM('CLEAN "prdLib"')"

 /* Done! */

 "SNDPGMMSG ",
   "MSGID(CPF9897) ",
   "MSGF(QCPFMSG) ",
   "MSGDTA('Successfully executes iRPGUnit self-tests in library: "prdLib"')",
   "TOPGMQ(*PRV (*CTLBDY)) ",
   "MSGTYPE(*INFO)"

 EXIT

 /* ------------------------------------------------------------- */
 /*  Compiles a iRPGUnit unit test service program.               */
 /* ------------------------------------------------------------- */
 createUnitTest:
   PARSE ARG _prdLib, _bndDir, _unitTest, _dbgView

   "RUCRTRPG TSTPGM("_prdLib"/"_unitTest") ",
     "SRCFILE("_prdLib"/QUNITTEST) ",
     "DBGVIEW("_dbgView") ",
     "BNDDIR("_prdLib"/"_bndDir") ",
     "BOPTION(*DUPPROC)"

   return ''

 /* ------------------------------------------------------------- */
 /*  Runs a iRPGUnit unit test service program.                   */
 /* ------------------------------------------------------------- */
 runUnitTest:
   PARSE ARG _prdLib, _unitTest

   "RUCALLTST TSTPGM("_prdLib"/"_unitTest") ",
     "TSTPRC(*ALL) ",
     "OUTPUT(*ERROR)"

   return ''

 /* ------------------------------------------------------------- */
 /* Global Error handler                                          */
 /* ------------------------------------------------------------- */
 Error:
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('ERROR: Failed executing iRPGUnit self tests. Check the job log for details') ",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"

   EXIT

