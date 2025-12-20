/* =================================================================== */
/*  This Rexx script installs the iRPGUnit library.                    */
/*                                                                     */
/*  Usage:                                                             */
/*  a) Add the iRPGUnit library to your library list.                  */
/*  b) Start the Rexx script with the following command:               */
/*       STRREXPRC SRCMBR(A_INSTALL) SRCFILE(QBUILD) PARM(option)      */
/*     where 'prdLib' is the library containing the RPGUnit            */
/*     source files.                                                   */
/*                                                                     */
/*     Script parameters:                                              */
/*       option   - The possible values are:                           */
/*                  INSTALL : Default. Installs the iRPGUnit library.  */
/*                  CMPMOD  : Compiles the modules.                    */
/*                  CLEAN_SCRIPTST :                                   */
/*                            Deletes the iRPGUnit modules and other   */
/*                            unnecessary objects such as self-tests   */
/*                            from the iRPGUnit library excluding      */
/*                            library iRPGUnit library excluding       */
/*                            service program SCRIPTST.                */
/*                  CLEAN:    Deletes the iRPGUnit modules and other   */
/*                            unnecessary objects such as self-tests   */
/*                            from the iRPGUnit library excluding      */
/*                            library iRPGUnit library.                */
/*                  CLEANALL: Removes all objects from the iRPGUnit    */
/*                            product library.                         */
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
/*       >>PARM<< PARM('INSTALL &LI *LIST');                           */
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
 UTILITY = 'iRPGUnit'
 PRD_LIB = 'RPGUNIT'
 DEBUG_VIEW = '*NONE'
 TARGET_RELEASE = '*CURRENT'
 define = '*NONE'

 PARSE ARG option prdLib dbgView tgtrls define

 option  = translate(strip(option))
 prdLib  = translate(strip(prdLib))
 dbgView = translate(strip(dbgView))
 tgtRls  = translate(strip(tgtRls))
 define  = translate(strip(define))

 if option = '' then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Usage: STRREXPRC SRCMBR(A_INSTALL) SRCFILE(QBUILD) PARM(option)')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"
 end

 if (option <> 'INSTALL' & option <> 'CMPMOD' & option <> 'CLEAN_SCRIPTST' ,
     & option <> 'CLEAN' & option <> 'CLEANALL') then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Invalid option specfied: ''"option"''. Use INSTALL, CLEAN or CLEANALL')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"
 end

 select
 when dbgView = '' then dbgView = DEBUG_VIEW
 when dbgView = 'NONE' | dbgView = '*NONE' then dbgView = '*NONE'
 when dbgView = 'LIST' | dbgView = '*LIST' then dbgView = '*LIST'
 otherwise
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Invalid debug view specfied: ''"dbgView"''. Use NONE or LIST')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"
 end

 select
 when (tgtRls = '') then tgtRls = TARGET_RELEASE
 when (tgtRls = 'CURRENT' | tgtRls = '*CURRENT') then tgtRls = '*CURRENT'
 when (tgtRls = 'PRV' | tgtRls = '*PRV') then tgtRls = '*PRV'
 when (length(tgtRls) = 6 &,
       substr(tgtRls, 1, 1) = 'V' &,
       substr(tgtRls, 3, 1) = 'R' &,
       substr(tgtRls, 5, 1) = 'M') then tgtRls = tgtRls /* keep the value */
 otherwise
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Invalid version: ''"tgtRls"''. Use CURRENT, PRV or VxRxMx')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"
 end

 /* -------------------------------------------- */
 /*  Install iRPGUnit Library.                   */
 /*  Compiles all iRPGUnit objects from source.  */
 /* -------------------------------------------- */
 if (option = 'INSTALL') then do
   if prdLib = '' then prdLib = PRD_LIB
   install(prdLib, dbgView, tgtRls)
   EXIT
 end

 /* -------------------------------------------- */
 /*  Compile the modules.                        */
 /* -------------------------------------------- */
 if (option = 'CMPMOD') then do
   if prdLib = '' then prdLib = PRD_LIB
   compileModules(prdLib, dbgView, tgtRls)
   createBindingDirectory(prdLib, dbgView, tgtRls)
   EXIT
 end

 /* -------------------------------------------- */
 /*  Delete modules.                             */
 /*  Deletes all iRPGUnit modules.               */
 /* -------------------------------------------- */
 if (option = 'CLEAN_SCRIPTST') then do
   if prdLib = '' then prdLib = PRD_LIB
   cleanScriptst(prdLib)
   EXIT
 end

 /* -------------------------------------------- */
 /*  Delete modules.                             */
 /*  Deletes all iRPGUnit modules.               */
 /* -------------------------------------------- */
 if (option = 'CLEAN') then do
   if prdLib = '' then prdLib = PRD_LIB
   clean(prdLib)
   EXIT
 end

 /* -------------------------------------------- */
 /*  Cleans the iRPGUnit product library.        */
 /* -------------------------------------------- */
 if (option = 'CLEANALL') then do
   if prdLib = '' then prdLib = PRD_LIB
   cleanAll(prdLib)
   EXIT
 end

 EXIT

 /* ------------------------------------------------------------- */
 /*  Install the iRPGUNit library.                                */
 /* ------------------------------------------------------------- */
 install:
   PARSE ARG prdLib, dbgView, tgtRls

   deleteSelfTests(prdLib)
   deleteSelfTests('QTEMP')
   deleteModules(prdLib)
   deleteBuildObjects(prdLib)
   deleteIRPGUnit(prdLib)

   createBuildCOmmand(prdLib, dbgView, tgtRls)
   if (prdLib = 'RPGUNITDVP') then do
     compileModules(prdLib, dbgView, tgtRls)
     createBindingDirectory(prdLib, dbgView, tgtRls)
   end

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create service program RUMEMMGR.       */
   /* - - - - - - - - - - - - - - - - - - - - */
   "STRREXPRC SRCMBR(MKMEMMGR) SRCFILE("prdLib"/QSRC) ",
     "PARM('"prdLib" "dbgView" "tgtRls" "define"')"

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create service program RUTESTCASE.     */
   /* - - - - - - - - - - - - - - - - - - - - */
   "STRREXPRC SRCMBR(MKTESTCASE) SRCFILE("prdLib"/QSRC) ",
     "PARM('"prdLib" "dbgView" "tgtRls" "define"')"

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create commands: RUCALLTST             */
   /* - - - - - - - - - - - - - - - - - - - - */
   "STRREXPRC SRCMBR(MKCALLTST) SRCFILE("prdLib"/QSRC) ",
     "PARM('"prdLib" "dbgView" "tgtRls"')"

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create commands: RUCRTRPG/RUCRTCBL     */
   /* - - - - - - - - - - - - - - - - - - - - */
   "STRREXPRC SRCMBR(MKCRTCBL) SRCFILE("prdLib"/QSRC) ",
     "PARM('"prdLib" "dbgView" "tgtRls"')"

   "STRREXPRC SRCMBR(MKCRTRPG) SRCFILE("prdLib"/QSRC) ",
     "PARM('"prdLib" "dbgView" "tgtRls"')"

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create program RUPGMRMT (plug-in)      */
   /* - - - - - - - - - - - - - - - - - - - - */
   "STRREXPRC SRCMBR(MKRMTRUN) SRCFILE("prdLib"/QSRC) ",
     "PARM('"prdLib" "dbgView" "tgtRls"')"

   deleteSelfTests(prdLib)
   if (prdLib <> 'RPGUNITDVP') then do
     deleteModules(prdLib)
   end
   deleteBuildObjects(prdLib)

   "SNDPGMMSG ",
     "MSGID(CPF9897) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Successfully compiled the "UTILITY" library: "prdLib"')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*INFO)"

   return ''

 /* ------------------------------------------------------------- */
 /*  Deletes all unnecessary objects from library iRPGUnit.       */
 /*  Excluding self-test suite SCRIPTST.                          */
 /* ------------------------------------------------------------- */
 cleanScriptst:
   PARSE ARG prdLib

   deleteSelfTests(prdLib)
   deleteSelfTests('QTEMP')
   deleteModules(prdLib)
   deleteBuildObjects(prdLib)

   "SNDPGMMSG ",
     "MSGID(CPF9897) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Successfully clean library for running SCRIPTST: "prdLib"')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*INFO)"

   return ''

 /* ------------------------------------------------------------- */
 /*  Deletes all unnecessary objects from library iRPGUnit.       */
 /* ------------------------------------------------------------- */
 clean:
   PARSE ARG prdLib

   deleteSelfTests(prdLib)
   deleteSelfTests('QTEMP')
   deleteModules(prdLib)
   deleteBuildObjects(prdLib)
   deleteSpecialObjects(prdLib)

   "SNDPGMMSG ",
     "MSGID(CPF9897) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Successfully removed temporary objects from library: "prdLib"')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*INFO)"

   return ''

 /* ------------------------------------------------------------- */
 /*  Cleans the iRPGUnit product library.                         */
 /* ------------------------------------------------------------- */
 cleanAll:
   PARSE ARG prdLib

   deleteSelfTests(prdLib)
   deleteSelfTests('QTEMP')
   deleteModules(prdLib)
   deleteBuildObjects(prdLib)

   deleteIRPGUnit(prdLib);

   "SNDPGMMSG ",
     "MSGID(CPF9897) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Successfully cleaned library library: "prdLib"')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*INFO)"

   return ''

 /* ------------------------------------------------------------- */
 /*  Deletes all iRPGUnit self tests from library iRPGUnit.       */
 /* ------------------------------------------------------------- */
 deleteIRPGUnit:
   PARSE ARG _prdLib

   Signal off Error

   /* obsolete objects prior to 4.0.0 */
   "DLTCMD CMD("_prdlib"/RUCRTTST)"
   "DLTPNLGRP PNLGRP("_prdlib"/RUCRTTST)"
   "DLTPGM PGM("_prdlib"/RUCRTTST)"

   /* objects of 4.0.0+ */
   "DLTCMD CMD("_prdlib"/CMPMOD)"
   "DLTCMD CMD("_prdlib"/RUCALLTST)"
   "DLTCMD CMD("_prdlib"/RUCRTRPG)"
   "DLTCMD CMD("_prdlib"/RUCRTCBL)"
   "DLTCMD CMD("_prdlib"/UPDLIB)"

   "DLTPNLGRP PNLGRP("_prdlib"/CMPMODHLP)"
   "DLTPNLGRP PNLGRP("_prdlib"/RUCALLTST)"
   "DLTPNLGRP PNLGRP("_prdlib"/RUCRTRPG)"
   "DLTPNLGRP PNLGRP("_prdlib"/RUCRTCBL)"
   "DLTPNLGRP PNLGRP("_prdlib"/UPDLIBHLP)"

   "DLTPGM PGM("_prdlib"/RUCALLTST)"
   "DLTPGM PGM("_prdlib"/RUCALLTSTV)"
   "DLTPGM PGM("_prdlib"/RUCRTRPG)"
   "DLTPGM PGM("_prdlib"/RUCRTCBL)"
   "DLTPGM PGM("_prdlib"/RUPGMRMT)"
   "DLTSRVPGM SRVPGM("_prdlib"/RUTESTCASE)"
   "DLTSRVPGM SRVPGM("_prdlib"/RUMEMMGR)"

   "DLTJOBD JOBD("_prdLib"/RPGUNIT)"
   "DLTWSCST WSCST("_prdLib"/RUWSCST)"

   "DLTF FILE("_prdLib"/RPGUNIT)" /* RPGUNIT save file */

   Signal on Error

   return ''

 /* ------------------------------------------------------------- */
 /*  Deletes all iRPGUnit build helper objects.                   */
 /* ------------------------------------------------------------- */
 deleteBuildObjects:
   PARSE ARG _prdLib

   Signal off Error

   "DLTPGM PGM("_prdlib"/A_CRTPKG)"
   "DLTPGM PGM("_prdlib"/A_TESTRMT)"
   "DLTPGM PGM("_prdlib"/A_METADATA)"

   "DLTPGM PGM("_prdlib"/CRTPKGCPR)"
   "DLTPGM PGM("_prdlib"/CRTPKGDBG)"
   "DLTPGM PGM("_prdlib"/CRTPKGMDT)"
   "DLTPGM PGM("_prdlib"/CRTPKGOWN)"

   "DLTSRVPGM SRVPGM("_prdlib"/CBLEXAMPLE)"
   "DLTSRVPGM SRVPGM("_prdlib"/RPGEXAMPLE)"

   return ''

 /* ------------------------------------------------------------- */
 /*  Deletes all iRPGUnit self tests from library iRPGUnit.       */
 /* ------------------------------------------------------------- */
 deleteSelfTests:
   PARSE ARG _prdLib

   Signal off Error

   bndDir = 'IRPGUNIT'

   "DLTUSRSPC USRSPC("_prdlib"/RUSPOOL)"
   "DLTUSRSPC USRSPC("_prdlib"/RUPROCLIST)"

   "DLTSRVPGM SRVPGM("_prdlib"/SRVPGM1)"
   "DLTSRVPGM SRVPGM("_prdlib"/SRVPGM2)"

   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM01)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM02)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM03)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM04)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM05)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM06)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM07)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM08)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM09)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM10)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM11)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM12)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM13)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM14)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM15)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM16)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM17)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM18)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM19)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM20)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTPGM21)"

   "DLTSRVPGM SRVPGM("_prdlib"/ACPTSTT)"
   "DLTSRVPGM SRVPGM("_prdlib"/ASSERTT)"
   "DLTSRVPGM SRVPGM("_prdlib"/CALLPRCT)"
   "DLTSRVPGM SRVPGM("_prdlib"/CMDRUNLOGT)"
   "DLTSRVPGM SRVPGM("_prdlib"/CMDRUNT)"
   "DLTSRVPGM SRVPGM("_prdlib"/CMPTPLT)"
   "DLTSRVPGM SRVPGM("_prdlib"/CPLTSTT)"
   "DLTSRVPGM SRVPGM("_prdlib"/CRTTSTT)"
   "DLTSRVPGM SRVPGM("_prdlib"/EXTPRCT)"
   "DLTSRVPGM SRVPGM("_prdlib"/EXTTSTT)"
   "DLTSRVPGM SRVPGM("_prdlib"/JOBLOGT)"
   "DLTSRVPGM SRVPGM("_prdlib"/JSONWTRT)"
   "DLTSRVPGM SRVPGM("_prdlib"/LIBLT)"
   "DLTSRVPGM SRVPGM("_prdlib"/LSTSPLFT)"
   "DLTSRVPGM SRVPGM("_prdlib"/MSGQT)"
   "DLTSRVPGM SRVPGM("_prdlib"/OPDESCT)"
   "DLTSRVPGM SRVPGM("_prdlib"/PGMMSGT)"
   "DLTSRVPGM SRVPGM("_prdlib"/RUNT)"
   "DLTSRVPGM SRVPGM("_prdlib"/SRCMBRT)"
   "DLTSRVPGM SRVPGM("_prdlib"/STMFT)"
   "DLTSRVPGM SRVPGM("_prdlib"/STRINGT)"
   "DLTSRVPGM SRVPGM("_prdlib"/TESTUTILST)"

   "DLTSRVPGM SRVPGM("_prdlib"/CBL)"
   "DLTSRVPGM SRVPGM("_prdlib"/CBLSQL)"
   "DLTSRVPGM SRVPGM("_prdlib"/RPG)"
   "DLTSRVPGM SRVPGM("_prdlib"/RPGSQL)"
   "DLTSRVPGM SRVPGM("_prdlib"/RPGSQLSTMF)"
   "DLTSRVPGM SRVPGM("_prdlib"/RPGSTMF)"

   Signal on Error

   return ''

 /* ------------------------------------------------------------- */
 /*  Deletes the modules from the iRPGUnit library.               */
 /* ------------------------------------------------------------- */
 deleteModules:
   PARSE ARG _prdLib

   Signal off Error

   "DLTF FILE("_prdlib"/EVFEVENT)"

   "DLTMOD MODULE("_prdLib"/A_TESTRMT)"
   "DLTMOD MODULE("_prdLib"/ACPTSTT)"
   "DLTMOD MODULE("_prdLib"/ASSERT)"
   "DLTMOD MODULE("_prdLib"/ASSERTT)"
   "DLTMOD MODULE("_prdLib"/ASSERTV2)"
   "DLTMOD MODULE("_prdLib"/CALLPRC)"
   "DLTMOD MODULE("_prdLib"/CALLPRCT)"
   "DLTMOD MODULE("_prdLib"/CALLSTACK)"
   "DLTMOD MODULE("_prdLib"/CMDRUN)"
   "DLTMOD MODULE("_prdLib"/CMDRUNLOG)"
   "DLTMOD MODULE("_prdLib"/CMDRUNLOGT)"
   "DLTMOD MODULE("_prdLib"/CMDRUNPRT)"
   "DLTMOD MODULE("_prdLib"/CMDRUNSRV)"
   "DLTMOD MODULE("_prdLib"/CMDRUNT)"
   "DLTMOD MODULE("_prdLib"/CMDRUNV)"
   "DLTMOD MODULE("_prdLib"/CMPTPLT)"
   "DLTMOD MODULE("_prdLib"/CRTCBL)"
   "DLTMOD MODULE("_prdLib"/CRTRPG)"
   "DLTMOD MODULE("_prdLib"/CRTTST)"
   "DLTMOD MODULE("_prdLib"/CRTTSTT)"
   "DLTMOD MODULE("_prdLib"/EXTPRC)"
   "DLTMOD MODULE("_prdLib"/EXTPRCT)"
   "DLTMOD MODULE("_prdLib"/EXTTST)"
   "DLTMOD MODULE("_prdLib"/EXTTSTT)"
   "DLTMOD MODULE("_prdLib"/JENKINS)"
   "DLTMOD MODULE("_prdLib"/JOBLOG)"
   "DLTMOD MODULE("_prdLib"/JOBLOGT)"
   "DLTMOD MODULE("_prdLib"/JSONWTR)"
   "DLTMOD MODULE("_prdLib"/JSONWTRT)"
   "DLTMOD MODULE("_prdLib"/LIBL)"
   "DLTMOD MODULE("_prdLib"/LIBLC)"
   "DLTMOD MODULE("_prdLib"/LIBLT)"
   "DLTMOD MODULE("_prdLib"/LLIST)"
   "DLTMOD MODULE("_prdLib"/LSTSPLF)"
   "DLTMOD MODULE("_prdLib"/LSTSPLFT)"
   "DLTMOD MODULE("_prdLib"/MEMMGR)"
   "DLTMOD MODULE("_prdLib"/MSGQT)"
   "DLTMOD MODULE("_prdLib"/OBJECT)"
   "DLTMOD MODULE("_prdLib"/OPDESCT)"
   "DLTMOD MODULE("_prdLib"/OSVERSION)"
   "DLTMOD MODULE("_prdLib"/PGMMSG)"
   "DLTMOD MODULE("_prdLib"/PGMMSGT)"
   "DLTMOD MODULE("_prdLib"/PGMRMT)"
   "DLTMOD MODULE("_prdLib"/RMTRUNSRV)"
   "DLTMOD MODULE("_prdLib"/RUNT)"
   "DLTMOD MODULE("_prdLib"/SPLF)"
   "DLTMOD MODULE("_prdLib"/SRCMBR)"
   "DLTMOD MODULE("_prdLib"/STMF)"
   "DLTMOD MODULE("_prdLib"/STMFT)"
   "DLTMOD MODULE("_prdLib"/STRING)"
   "DLTMOD MODULE("_prdLib"/STRINGT)"
   "DLTMOD MODULE("_prdLib"/TAGTST)"
   "DLTMOD MODULE("_prdLib"/TESTUTILS)"
   "DLTMOD MODULE("_prdLib"/TESTUTILST)"
   "DLTMOD MODULE("_prdLib"/USRSPC)"
   "DLTMOD MODULE("_prdLib"/VERSION)"
   "DLTMOD MODULE("_prdLib"/VSCODE)"
   "DLTMOD MODULE("_prdLib"/XMLWRITER)"

   "DLTMOD MODULE("_prdlib"/CBL)"
   "DLTMOD MODULE("_prdlib"/CBLSQL)"
   "DLTMOD MODULE("_prdlib"/RPG)"
   "DLTMOD MODULE("_prdlib"/RPGSQL)"
   "DLTMOD MODULE("_prdlib"/RPGSQLSTMF)"
   "DLTMOD MODULE("_prdlib"/RPGSTMF)"

   "DLTMOD MODULE("_prdlib"/SCRIPTST)"

   Signal on Error

   return ''

 /* ------------------------------------------------------------- */
 /*  Deletes special objects, e.g. test suite SCRIPTST.           */
 /* ------------------------------------------------------------- */
 deleteSpecialObjects:
   PARSE ARG _prdLib

   Signal off Error

   "DLTSRVPGM SRVPGM("_prdlib"/SCRIPTST)"
   "DLTBNDDIR BNDDIR("_prdlib"/"bndDir")"

   Signal on Error

   return ''

 /* ------------------------------------------------------------- */
 /*  Create CMPMOD command.                                       */
 /* ------------------------------------------------------------- */
createBuildCommand:
   PARSE ARG prdLib, dbgView, tgtRls

   "STRREXPRC SRCMBR(MKBUILD) SRCFILE("prdLib"/QBUILD) ",
     "PARM('"prdLib" "dbgView" "tgtRls"')"

 /* ------------------------------------------------------------- */
 /*  Create binding directory and compile modules.                */
 /* ------------------------------------------------------------- */
createBindingDirectory:
   PARSE ARG prdLib, dbgView, tgtRls

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
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/CALLPRC   *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/CMDRUN    *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/CMDRUNLOG *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/CMDRUNPRT *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/CMDRUNSRV *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/CMDRUNV   *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/CRTTST    *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/EXTPRC    *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/EXTTST    *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/JENKINS   *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/JOBLOG    *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/JSONWTR   *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/LIBL      *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/LSTSPLF   *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/OBJECT    *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/OSVERSION *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/PGMMSG    *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/PGMRMT    *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/RMTRUNSRV *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/SRCMBR    *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/STMF      *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/STRING    *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/TAGTST    *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/USRSPC    *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/VSCODE    *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/XMLWRITER *MODULE))"

   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/LLIST     *MODULE))"

   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/LIBLC     *MODULE))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/SPLF      *MODULE))"

   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/RUTESTCASE *SRVPGM))"
   "ADDBNDDIRE BNDDIR("prdLib"/"bndDir") OBJ(("prdLib"/RUMEMMGR  *SRVPGM))"

   return ''

 /* ------------------------------------------------------------- */
 /*  Compile the modules.                                         */
 /* ------------------------------------------------------------- */
compileModules:
   PARSE ARG prdLib, dbgView, tgtRls

   "CMPMOD MODULE("prdLib"/ASSERT   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/ASSERTV2 ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/CALLSTACK) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/CALLPRC  ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/CMDRUN   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/CMDRUNLOG) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/CMDRUNPRT) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/CMDRUNSRV) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/CMDRUNV  ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/CRTCBL   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/CRTRPG   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/CRTTST   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/JENKINS  ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/JOBLOG   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/JSONWTR  ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/EXTPRC   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/EXTTST   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/LIBL     ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/LSTSPLF  ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/MEMMGR   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/OBJECT   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/OSVERSION) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/PGMMSG   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/PGMRMT   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/RMTRUNSRV) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/SRCMBR   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/STMF     ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/STRING   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/TAGTST   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/TESTUTILS) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/USRSPC   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/VERSION  ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/VSCODE   ) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/XMLWRITER) SRCFILE(QSRC) DBGVIEW("dbgView") TGTRLS("tgtRls")"

   "CMPMOD MODULE("prdLib"/LIBLC    ) SRCFILE(QUNITTEST) DBGVIEW("dbgView") TGTRLS("tgtRls")"
   "CMPMOD MODULE("prdLib"/SPLF     ) SRCFILE(QUNITTEST) DBGVIEW("dbgView") TGTRLS("tgtRls")"

   "CMPMOD MODULE("prdLib"/LLIST    ) SRCFILE(QLLIST) DBGVIEW("dbgView") TGTRLS("tgtRls")"

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

