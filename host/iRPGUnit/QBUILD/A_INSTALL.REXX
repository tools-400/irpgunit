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
/*                            library QTEMP.                           */
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

 /* Register error handler */
 Signal on Error

 /* Setup ERROR,FAILURE & SYNTAX condition traps.*/
 SIGNAL on NOVALUE
 SIGNAL on SYNTAX

 /* The utility that is installed */
 UTILITY = 'iRPGUnit'
 PRD_LIB = 'RPGUNIT'

 PARSE ARG option prdLib dbgView tgtrls

 option  = translate(strip(option))
 prdLib  = translate(strip(prdLib))
 dbgView = translate(strip(dbgView))
 tgtRls  = translate(strip(tgtRls))

 if option = "" then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Usage: STRREXPRC SRCMBR(A_INSTALL) SRCFILE(QBUILD) PARM(option)')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"
 end

 if option = '' then do
   option = 'INSTALL'
 end

 if (option <> 'INSTALL' & option <> 'CLEAN' & option <> 'CLEANALL') then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Invalid option specfied: ''"option"''. Use INSTALL or CLEAN')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"
 end

 if dbgView = '' | dbgView = 'NONE' | dbgView = '*NONE' then do
   dbgView = '*NONE'
 end

 if dbgView = 'LIST' | dbgView = '*LIST' then do
   dbgView = '*LIST'
 end

 if (dbgView <> '*NONE' & dbgView <> '*LIST') then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Invalid debug view specfied: ''"dbgView"''. Use NONE or LIST')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"
 end

 select
 when (tgtRls = '' | tgtRls = 'CURRENT') then tgtRls = '*CURRENT'
 when (tgtRls = 'PRV') then tgtRls = '*PRV'
 otherwise
 end

 /* -------------------------------------------- */
 /*  Install iRPGUnit Library.                   */
 /*  Compiles all iRPGUnit objects from source.  */
 /* -------------------------------------------- */
 if (option = 'INSTALL') then do
   if prdLib = '' then prdLib = PRD_LIB
   rc = deleteModules('QTEMP')
   install(prdLib, dbgView, tgtRls)
   rc = deleteModules('QTEMP')
   EXIT
 end

 /* -------------------------------------------- */
 /*  Delete modules.                             */
 /*  Deletes all iRPGUnit modules.               */
 /* -------------------------------------------- */
 if (option = 'CLEAN') then do
   if (prdLib = '') then prdLib = 'QTEMP'
   clean(prdLib)
   EXIT
 end

 /* -------------------------------------------- */
 /*  Cleans the iRPGUnit product library.        */
 /* -------------------------------------------- */
 if (option = 'CLEANALL') then do
   cleanAll(prdLib)
   EXIT
 end

 EXIT

 /* ------------------------------------------------------------- */
 /*  Install the iRPGUNit library.                                */
 /* ------------------------------------------------------------- */
 install:
   PARSE ARG _prdLib, _dbgView, _tgtRls

   /* - - - - - - - - - - - -   - - - - - - - - */
   /*  Create commands BUILD and CMPMOD.      */
   /* - - - - - - - - - - - - - - - - - - - - */
   "STRREXPRC SRCMBR(MKBUILD) SRCFILE(QBUILD) PARM('"_prdLib" "_dbgView" "_tgtRls"')"

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create service program RUTESTCASE.     */
   /* - - - - - - - - - - - - - - - - - - - - */
   "STRREXPRC SRCMBR(MKTESTCASE) SRCFILE(QSRC) PARM('"_prdLib" "_dbgView" "_tgtRls"')"

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create commands: RUCALLTST             */
   /* - - - - - - - - - - - - - - - - - - - - */
   "STRREXPRC SRCMBR(MKCALLTST) SRCFILE(QSRC) PARM('"_prdLib" "_dbgView" "_tgtRls"')"

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create commands: RUCRTTST              */
   /* - - - - - - - - - - - - - - - - - - - - */
   "STRREXPRC SRCMBR(MKCRTTST) SRCFILE(QSRC) PARM('"_prdLib" "_dbgView" "_tgtRls"')"

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create program RUPGMRMT (plug-in)      */
   /* - - - - - - - - - - - - - - - - - - - - */
   "STRREXPRC SRCMBR(MKRMTRUN) SRCFILE(QSRC) PARM('"_prdLib" "_dbgView" "_tgtRls"')"

   "SNDPGMMSG ",
     "MSGID(CPF9897) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Successfully compiled the "UTILITY" library: "_prdLib"')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*INFO)"

   return ''

 /* ------------------------------------------------------------- */
 /*  Deletes the modules from the iRPGUnit library.               */
 /* ------------------------------------------------------------- */
 deleteModules:
   PARSE ARG _prdLib

   count = 0

   count = count + deleteModule(_prdLib, 'ACPTSTT')
   count = count + deleteModule(_prdLib, 'ASSERT')
   count = count + deleteModule(_prdLib, 'ASSERTT')
   count = count + deleteModule(_prdLib, 'CALLPRC')
   count = count + deleteModule(_prdLib, 'CALLPRCT')
   count = count + deleteModule(_prdLib, 'CMDRUN')
   count = count + deleteModule(_prdLib, 'CMDRUNLOG')
   count = count + deleteModule(_prdLib, 'CMDRUNLOGT')
   count = count + deleteModule(_prdLib, 'CMDRUNPRT')
   count = count + deleteModule(_prdLib, 'CMDRUNSRV')
   count = count + deleteModule(_prdLib, 'CMDRUNT')
   count = count + deleteModule(_prdLib, 'CRTTST')
   count = count + deleteModule(_prdLib, 'CRTTSTT')
   count = count + deleteModule(_prdLib, 'EXTPRC')
   count = count + deleteModule(_prdLib, 'EXTPRCT')
   count = count + deleteModule(_prdLib, 'EXTTST')
   count = count + deleteModule(_prdLib, 'EXTTSTT')
   count = count + deleteModule(_prdLib, 'JOBLOGT')
   count = count + deleteModule(_prdLib, 'LIBL')
   count = count + deleteModule(_prdLib, 'LIBLC')
   count = count + deleteModule(_prdLib, 'LIBLT')
   count = count + deleteModule(_prdLib, 'LLIST')
   count = count + deleteModule(_prdLib, 'OBJECT')
   count = count + deleteModule(_prdLib, 'PGMMSG')
   count = count + deleteModule(_prdLib, 'PGMMSGT')
   count = count + deleteModule(_prdLib, 'PGMRMT')
   count = count + deleteModule(_prdLib, 'RMTRUNSRV')
   count = count + deleteModule(_prdLib, 'RUNT')
   count = count + deleteModule(_prdLib, 'SPLF')
   count = count + deleteModule(_prdLib, 'SRCMBR')
   count = count + deleteModule(_prdLib, 'STRING')
   count = count + deleteModule(_prdLib, 'STRINGT')
   count = count + deleteModule(_prdLib, 'TAGTST')
   count = count + deleteModule(_prdLib, 'TESTUTILS')
   count = count + deleteModule(_prdLib, 'USRSPC')
   count = count + deleteModule(_prdLib, 'VERSION')
   count = count + deleteModule(_prdLib, 'XMLWRITER')

   count = count + deleteModule(_prdLib, 'LLIST')

   count = count + deleteModule(_prdLib, 'LIBLC')
   count = count + deleteModule(_prdLib, 'SPLF')

   return count

 /* ------------------------------------------------------------- */
 /*  Deletes all unnecessary objects from library iRPGUnit.       */
 /* ------------------------------------------------------------- */
 clean:
   PARSE ARG _prdLib

   bndDir = 'IRPGUNIT'

   Signal off Error
   "DLTBNDDIR BNDDIR("_prdlib"/"bndDir")"

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
   "DLTSRVPGM SRVPGM("_prdlib"/PGMMSGT)"
   "DLTSRVPGM SRVPGM("_prdlib"/RUNT)"
   "DLTSRVPGM SRVPGM("_prdlib"/STRINGT)"

   "DLTUSRSPC USRSPC("_prdlib"/RUPROCLIST)"
   "DLTUSRSPC USRSPC("_prdlib"/RUSPOOL)"
   Signal on Error

   count = deleteModules(_prdLib)

   "SNDPGMMSG ",
     "MSGID(CPF9897) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Successfully removed temporary objects from library: "_prdLib"')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*INFO)"

   return ''

 /* ------------------------------------------------------------- */
 /*  Cleans the iRPGUnit product library.                         */
 /* ------------------------------------------------------------- */
 cleanAll:
   PARSE ARG _prdLib

   Signal off Error
   "DLTCMD CMD("_prdlib"/CMPMOD)"
   "DLTCMD CMD("_prdlib"/RUCALLTST)"
   "DLTCMD CMD("_prdlib"/RUCRTTST)"

   "DLTPNLGRP PNLGRP("_prdlib"/CMPMODHLP)"
   "DLTPNLGRP PNLGRP("_prdlib"/RUCALLTST)"
   "DLTPNLGRP PNLGRP("_prdlib"/RUCRTTST)"

   "DLTPGM PGM("_prdlib"/RUCALLTST)"
   "DLTPGM PGM("_prdlib"/RUCRTTST)"
   "DLTPGM PGM("_prdlib"/RUPGMRMT)"
   "DLTSRVPGM SRVPGM("_prdlib"/RUTESTCASE)"

   "DLTF FILE("_prdlib"/EVFEVENT)"
   Signal on Error

   clean(_prdLib)

   "SNDPGMMSG ",
     "MSGID(CPF9897) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Successfully cleaned library library: "_prdLib"')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*INFO)"

   return ''

 /* ------------------------------------------------------------- */
 /*  Deletes a module from the iRPGUnit library.                  */
 /* ------------------------------------------------------------- */
 deleteModule:
   PARSE ARG _prdLib, _module

   Signal off Error
   "DLTMOD MODULE("_prdLib"/"_module")"
   Signal on Error

   if (rc = 0) then do
      return 1
   end
   else do
      return 0
   end

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

