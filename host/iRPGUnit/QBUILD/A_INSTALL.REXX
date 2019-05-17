
 /* Register error handler */
 Signal on Error

 /* Setup ERROR,FAILURE & SYNTAX condition traps.*/
 SIGNAL on NOVALUE
 SIGNAL on SYNTAX

 /* The utility that is installed */
 UTILITY = 'iRPGUnit'

 PARSE ARG prdLib option tgtrls

 prdLib = translate(strip(prdLib))
 option = translate(strip(option))
 tgtRls = translate(strip(tgtRls))

 if prdLib = "" then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Usage: STRREXPRC SRCMBR(A_INSTALL) SRCFILE(QBUILD) PARM(targetLibrary)')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"
 end

 if option = "" then do
   option = '*INSTALL'
 end

 if tgtRls = "" then do
   tgtRls = '*CURRENT'
 end

 /* -------------------------------------------- */
 /*  Install iRPGUnit Library.                   */
 /*  Compiles all iRPGUnit objects from source.  */
 /* -------------------------------------------- */
 if (option = '*INSTALL') then do
   dbgView = '*YES'
   install(prdLib, dbgView, tgtRls)
   EXIT
 end

 /* -------------------------------------------- */
 /*  Delete modules.                             */
 /*  Deletes all iRPGUnit modules.               */
 /* -------------------------------------------- */
 if (option = '*DLTMODS') then do
   dbgView = '*YES'
   deleteModules(prdLib)
   EXIT
 end

 "SNDPGMMSG ",
   "MSGID(CPF9898) ",
   "MSGF(QCPFMSG) ",
   "MSGDTA('Invalid ''option'' parameter value: "option". Use *INSTALL or *DLTMODS') ",
   "TOPGMQ(*PRV (*CTLBDY)) ",
   "MSGTYPE(*ESCAPE)"

 EXIT

 /* ------------------------------------------------------------- */
 /*  Install the iRPGUNit library.                                */
 /* ------------------------------------------------------------- */
 install:
   PARSE ARG prdLib, dbgView, tgtRls

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create commands BUILD and CMPMOD.      */
   /* - - - - - - - - - - - - - - - - - - - - */
   "CRTBNDCL PGM(QTEMP/MKBUILD) SRCFILE("prdLib"/QBUILD) SRCMBR(*PGM)"
   "CALL PGM(QTEMP/MKBUILD) PARM("prdLib" "dbgView" "tgtRls")"

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create service program RUTESTCASE.     */
   /* - - - - - - - - - - - - - - - - - - - - */
   "CRTBNDCL PGM(QTEMP/MKTESTCASE) SRCFILE("prdLib"/QSRC) SRCMBR(*PGM)"
   "CALL PGM(QTEMP/MKTESTCASE) PARM("prdLib" "dbgView" "tgtRls")"

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create commands: RUCALLTST             */
   /* - - - - - - - - - - - - - - - - - - - - */
   "CRTBNDCL PGM(QTEMP/MKCALLTST) SRCFILE("prdLib"/QSRC) SRCMBR(*PGM)"
   "CALL PGM(QTEMP/MKCALLTST) PARM("prdLib" "dbgView" "tgtRls")"

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create commands: RUCRTTST              */
   /* - - - - - - - - - - - - - - - - - - - - */
   "CRTBNDCL PGM(QTEMP/MKCRTTST) SRCFILE("prdLib"/QSRC) SRCMBR(*PGM)"
   "CALL PGM(QTEMP/MKCRTTST) PARM("prdLib" "dbgView" "tgtRls")"

   /* - - - - - - - - - - - - - - - - - - - - */
   /*  Create program RUPGMRMT (plug-in)      */
   /* - - - - - - - - - - - - - - - - - - - - */
   "CRTBNDCL PGM(QTEMP/MKRMTRUN) SRCFILE("prdLib"/QSRC) SRCMBR(*PGM)"
   "CALL PGM(QTEMP/MKRMTRUN) PARM("prdLib" "dbgView" "tgtRls")"

   "SNDPGMMSG ",
     "MSGID(CPF9897) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Successfully compiled the "UTILITY" library: "prdLib"')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*INFO)"

   return ''

 /* ------------------------------------------------------------- */
 /*  Deletes the modules from the iRPGUnit library.               */
 /* ------------------------------------------------------------- */
 deleteModules:
   PARSE ARG prdLib

   count = 0

   count = count + deleteModule(prdLib, 'ACPTST')
   count = count + deleteModule(prdLib, 'ASSERT')
   count = count + deleteModule(prdLib, 'ASSERTT')
   count = count + deleteModule(prdLib, 'CALLPROC')
   count = count + deleteModule(prdLib, 'CALLPROCT')
   count = count + deleteModule(prdLib, 'CMDRUN')
   count = count + deleteModule(prdLib, 'CMDRUNLOG')
   count = count + deleteModule(prdLib, 'CMDRUNLOGT')
   count = count + deleteModule(prdLib, 'CMDRUNPRT')
   count = count + deleteModule(prdLib, 'CMDRUNSRV')
   count = count + deleteModule(prdLib, 'CMDRUNT')
   count = count + deleteModule(prdLib, 'CRTTST')
   count = count + deleteModule(prdLib, 'CRTTSTT')
   count = count + deleteModule(prdLib, 'EXTPRC')
   count = count + deleteModule(prdLib, 'EXTPRCT')
   count = count + deleteModule(prdLib, 'EXTTST')
   count = count + deleteModule(prdLib, 'EXTTSTT')
   count = count + deleteModule(prdLib, 'JOBLOGT')
   count = count + deleteModule(prdLib, 'LIBL')
   count = count + deleteModule(prdLib, 'LIBLC')
   count = count + deleteModule(prdLib, 'LIBLT')
   count = count + deleteModule(prdLib, 'LLIST')
   ccount = count + deleteModule(prdLib, 'OBJECT')
   count = count + deleteModule(prdLib, 'PGMMSG')
   count = count + deleteModule(prdLib, 'PGMMSGT')
   count = count + deleteModule(prdLib, 'PGMRMT')
   count = count + deleteModule(prdLib, 'RMTRUNSRV')
   count = count + deleteModule(prdLib, 'RUNT')
   count = count + deleteModule(prdLib, 'SPLF')
   count = count + deleteModule(prdLib, 'SRCMBR')
   count = count + deleteModule(prdLib, 'STRING')
   count = count + deleteModule(prdLib, 'STRINGT')
   count = count + deleteModule(prdLib, 'TAGTST')
   count = count + deleteModule(prdLib, 'TESTUTILS')
   count = count + deleteModule(prdLib, 'USRSPC')
   count = count + deleteModule(prdLib, 'VERSION')
   count = count + deleteModule(prdLib, 'XMLWRITER')

   count = count + deleteModule(prdLib, 'LLIST')

   count = count + deleteModule(prdLib, 'LIBLC')
   count = count + deleteModule(prdLib, 'SPLF')

   "SNDPGMMSG ",
     "MSGID(CPF9897) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Successfully removed "count" modules from library: "prdLib"')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*INFO)"

   return ''

 /* ------------------------------------------------------------- */
 /*  Deletes a module from the iRPGUnit library.                  */
 /* ------------------------------------------------------------- */
 deleteModule:
   PARSE ARG prdLib, module

   Signal off Error
   "DLTMOD MODULE("prdLib"/"module")"
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

