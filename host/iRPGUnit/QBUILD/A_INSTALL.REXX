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
/*                  CLEAN   : Deletes the iRPGUnit modules from        */
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
/* =================================================================== */
/*   >>PRE-COMPILER<<                                                  */
/*     >>CRTCMD<<  STRREXPRC SRCMBR(&SM) SRCFILE(&SL/&SF);             */
/*     >>IMPORTANT<<                                                   */
/*       >>PARM<< PARM('INSTALL &LI');                                 */
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
 TARGET_RELEASE = 'V7R1M0'

 PARSE ARG option prdLib dbgView tgtrls

 option  = translate(strip(option))
 prdLib  = translate(strip(prdLib))
 dbgView = translate(strip(dbgView))
 tgtRls  = translate(strip(tgtRls))

 if option = '' then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Usage: STRREXPRC SRCMBR(A_INSTALL) SRCFILE(QBUILD) PARM(option)')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"
 end

 if (option <> 'INSTALL' & option <> 'CLEAN' & option <> 'CLEANALL') then do
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
   deleteIRPGUnit(prdLib);

   /* - - - - - - - - - - - -   - - - - - - - - */
   /*  Create commands BUILD and CMPMOD.      */
   /* - - - - - - - - - - - - - - - - - - - - */
   "STRREXPRC SRCMBR(MKBUILD) SRCFILE(QBUILD) PARM('"prdLib" "dbgView" "tgtRls"')"

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create service program RUTESTCASE.     */
   /* - - - - - - - - - - - - - - - - - - - - */
   "STRREXPRC SRCMBR(MKTESTCASE) SRCFILE(QSRC) PARM('"prdLib" "dbgView" "tgtRls"')"

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create commands: RUCALLTST             */
   /* - - - - - - - - - - - - - - - - - - - - */
   "STRREXPRC SRCMBR(MKCALLTST) SRCFILE(QSRC) PARM('"prdLib" "dbgView" "tgtRls"')"

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create commands: RUCRTTST              */
   /* - - - - - - - - - - - - - - - - - - - - */
   "STRREXPRC SRCMBR(MKCRTTST) SRCFILE(QSRC) PARM('"prdLib" "dbgView" "tgtRls"')"

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create program RUPGMRMT (plug-in)      */
   /* - - - - - - - - - - - - - - - - - - - - */
   "STRREXPRC SRCMBR(MKRMTRUN) SRCFILE(QSRC) PARM('"prdLib" "dbgView" "tgtRls"')"

   deleteSelfTests(prdLib)
   deleteModules(prdLib)
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
 /* ------------------------------------------------------------- */
 clean:
   PARSE ARG prdLib

   deleteSelfTests(prdLib)
   deleteSelfTests('QTEMP')
   deleteModules(prdLib)
   deleteBuildObjects(prdLib)

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

   "DLTCMD CMD("_prdlib"/CMPMOD)"
   "DLTCMD CMD("_prdlib"/RUCALLTST)"
   "DLTCMD CMD("_prdlib"/RUCRTTST)"

   "DLTPNLGRP PNLGRP("_prdlib"/CMPMODHLP)"
   "DLTPNLGRP PNLGRP("_prdlib"/RUCALLTST)"
   "DLTPNLGRP PNLGRP("_prdlib"/RUCRTTST)"

   "DLTPGM PGM("_prdlib"/RUCALLTST)"
   "DLTPGM PGM("_prdlib"/RUCALLTSTV)"
   "DLTPGM PGM("_prdlib"/RUCRTTST)"
   "DLTPGM PGM("_prdlib"/RUPGMRMT)"
   "DLTSRVPGM SRVPGM("_prdlib"/RUTESTCASE)"

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
   "DLTPGM PGM("_prdlib"/A_METADATA)"

   "DLTPGM PGM("_prdlib"/CRTPKGCPR)"
   "DLTPGM PGM("_prdlib"/CRTPKGDBG)"
   "DLTPGM PGM("_prdlib"/CRTPKGMDT)"
   "DLTPGM PGM("_prdlib"/CRTPKGOWN)"

   return ''

 /* ------------------------------------------------------------- */
 /*  Deletes all iRPGUnit self tests from library iRPGUnit.       */
 /* ------------------------------------------------------------- */
 deleteSelfTests:
   PARSE ARG _prdLib

   Signal off Error

   bndDir = 'IRPGUNIT'

   "DLTBNDDIR BNDDIR("_prdlib"/"bndDir")"
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

   "DLTSRVPGM SRVPGM("_prdlib"/ACPTSTT)"
   "DLTSRVPGM SRVPGM("_prdlib"/ASSERTT)"
   "DLTSRVPGM SRVPGM("_prdlib"/CALLPRCT)"
   "DLTSRVPGM SRVPGM("_prdlib"/CMDRUNLOGT)"
   "DLTSRVPGM SRVPGM("_prdlib"/CMDRUNT)"
   "DLTSRVPGM SRVPGM("_prdlib"/CRTTSTT)"
   "DLTSRVPGM SRVPGM("_prdlib"/EXTPRCT)"
   "DLTSRVPGM SRVPGM("_prdlib"/EXTTSTT)"
   "DLTSRVPGM SRVPGM("_prdlib"/JOBLOGT)"
   "DLTSRVPGM SRVPGM("_prdlib"/LIBLT)"
   "DLTSRVPGM SRVPGM("_prdlib"/MSGQT)"
   "DLTSRVPGM SRVPGM("_prdlib"/PGMMSGT)"
   "DLTSRVPGM SRVPGM("_prdlib"/RUNT)"
   "DLTSRVPGM SRVPGM("_prdlib"/STRINGT)"

   "DLTSRVPGM SRVPGM("_prdlib"/SCRIPTST)"

   Signal on Error

   return ''

 /* ------------------------------------------------------------- */
 /*  Deletes the modules from the iRPGUnit library.               */
 /* ------------------------------------------------------------- */
 deleteModules:
   PARSE ARG _prdLib

   Signal off Error

   "DLTF FILE("_prdlib"/EVFEVENT)"

   "DLTMOD MODULE("_prdLib"/ACPTSTT)"
   "DLTMOD MODULE("_prdLib"/ASSERT)"
   "DLTMOD MODULE("_prdLib"/ASSERTT)"
   "DLTMOD MODULE("_prdLib"/CALLPRC)"
   "DLTMOD MODULE("_prdLib"/CALLPRCT)"
   "DLTMOD MODULE("_prdLib"/CMDRUN)"
   "DLTMOD MODULE("_prdLib"/CMDRUNT)"
   "DLTMOD MODULE("_prdLib"/CMDRUNLOG)"
   "DLTMOD MODULE("_prdLib"/CMDRUNLOGT)"
   "DLTMOD MODULE("_prdLib"/CMDRUNPRT)"
   "DLTMOD MODULE("_prdLib"/CMDRUNSRV)"
   "DLTMOD MODULE("_prdLib"/CMDRUNV)"
   "DLTMOD MODULE("_prdLib"/CRTTST)"
   "DLTMOD MODULE("_prdLib"/CRTTSTT)"
   "DLTMOD MODULE("_prdLib"/EXTPRC)"
   "DLTMOD MODULE("_prdLib"/EXTPRCT)"
   "DLTMOD MODULE("_prdLib"/EXTTST)"
   "DLTMOD MODULE("_prdLib"/EXTTSTT)"
   "DLTMOD MODULE("_prdLib"/JOBLOGT)"
   "DLTMOD MODULE("_prdLib"/LIBL)"
   "DLTMOD MODULE("_prdLib"/LIBLC)"
   "DLTMOD MODULE("_prdLib"/LIBLT)"
   "DLTMOD MODULE("_prdLib"/LLIST)"
   "DLTMOD MODULE("_prdLib"/MSGQT)"
   "DLTMOD MODULE("_prdLib"/OBJECT)"
   "DLTMOD MODULE("_prdLib"/OSVERSION)"
   "DLTMOD MODULE("_prdLib"/PGMMSG)"
   "DLTMOD MODULE("_prdLib"/PGMMSGT)"
   "DLTMOD MODULE("_prdLib"/PGMRMT)"
   "DLTMOD MODULE("_prdLib"/RMTRUNSRV)"
   "DLTMOD MODULE("_prdLib"/RUNT)"
   "DLTMOD MODULE("_prdLib"/SPLF)"
   "DLTMOD MODULE("_prdLib"/SRCMBR)"
   "DLTMOD MODULE("_prdLib"/STRING)"
   "DLTMOD MODULE("_prdLib"/STRINGT)"
   "DLTMOD MODULE("_prdLib"/TAGTST)"
   "DLTMOD MODULE("_prdLib"/TESTUTILS)"
   "DLTMOD MODULE("_prdLib"/USRSPC)"
   "DLTMOD MODULE("_prdLib"/VERSION)"
   "DLTMOD MODULE("_prdLib"/XMLWRITER)"

   "DLTMOD MODULE("_prdLib"/LLIST)"

   "DLTMOD MODULE("_prdLib"/LIBLC)"
   "DLTMOD MODULE("_prdLib"/SPLF)"

   "DLTMOD MODULE("_prdlib"/SCRIPTST)"

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

