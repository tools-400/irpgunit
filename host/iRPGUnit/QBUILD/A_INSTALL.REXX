/* =================================================================== */
/*  This Rexx script installs the iRPGUnit library.                    */
/*                                                                     */
/*  Usage:                                                             */
/*  a) Add the iRPGUnit library to your library list.                  */
/*  b) Start the Rexx script with the following command:               */
/*       STRREXPRC SRCMBR(A_INSTALL) SRCFILE(QBUILD) PARM(prdLib)      */
/*     where 'prdLib' is the library containing the RPGUnit            */
/*     source files.                                                   */
/*                                                                     */
/*     Script parameters:                                              */
/*       prdLib   - Name of the iRPGUnit product library.              */
/*       option   - The possible values are:                           */
/*                  INSTALL : Default. Installs the iRPGUnit library.  */
/*                  DLTMODS : Deletes the iRPGUnit modules from the    */
/*                            specified library (prdLib).              */
/*       tgtRls   - The possible values are:                           */
/*                  CURRENT : The objects are compiled with the        */
/*                            release of the operating system          */
/*                            currently running on your system.        */
/*                  PRV     : The objects are compiled for the         */
/*                            previous release of the operating system */
/*                            currently running on your system.        */
/*                  VxRxMx  : Release in the format of VxRxMx.         */
/*       dbgView  - The possible values are:                           */
/*                  NONE    : Default. Compiles the obejcts without    */
/*                            debug views.                             */
/*                  LIST    : Generates a listing view when compiling  */
/*                            the objects.                             */
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

 PARSE ARG prdLib option tgtrls dbgView

 prdLib  = translate(strip(prdLib))
 option  = translate(strip(option))
 tgtRls  = translate(strip(tgtRls))
 dbgView = translate(strip(dbgView))

 if prdLib = "" then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Usage: STRREXPRC SRCMBR(A_INSTALL) SRCFILE(QBUILD) PARM(targetLibrary)')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"
 end

 if option = '' then do
   option = 'INSTALL'
 end

 if (option <> 'INSTALL' & option <> 'DLTMODS') then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Invalid option specfied: ''"option"''. Use INSTALL or DLTMODS')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"
 end

 select
 when (tgtRls = '' | tgtRls = 'CURRENT') then tgtRls = '*CURRENT'
 when (tgtRls = 'PRV') then tgtRls = '*PRV'
 end

 if dbgView = '' then do
   dbgView = 'NONE'
 end

 if (dbgView <> 'NONE' & dbgView <> 'LIST') then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Invalid debug view specfied: ''"dbgView"''. Use NONE or LIST')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"
 end

 /* -------------------------------------------- */
 /*  Install iRPGUnit Library.                   */
 /*  Compiles all iRPGUnit objects from source.  */
 /* -------------------------------------------- */
 if (option = 'INSTALL') then do
   install(prdLib, dbgView, tgtRls)
   EXIT
 end

 /* -------------------------------------------- */
 /*  Delete modules.                             */
 /*  Deletes all iRPGUnit modules.               */
 /* -------------------------------------------- */
 if (option = 'DLTMODS') then do
   deleteModules(prdLib)
   EXIT
 end

 EXIT

 /* ------------------------------------------------------------- */
 /*  Install the iRPGUNit library.                                */
 /* ------------------------------------------------------------- */
 install:
   PARSE ARG prdLib, dbgView, tgtRls

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

