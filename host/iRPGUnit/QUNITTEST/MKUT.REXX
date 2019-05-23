/* =================================================================== */
/*  iRPGUnit SelfTest - Build and run all self tests.                  */
/* =================================================================== */
/* Copyright (c) 2013-2019 iRPGUnit Project Team                       */
/* All rights reserved. This program and the accompanying materials    */
/* are made available under the terms of the Common Public License v1.0*/
/* which accompanies this distribution, and is available at            */
/* http://www.eclipse.org/legal/cpl-v10.html                           */
/* =================================================================== */
/*  Usage:                                                             */
/*  a) Add the iRPGUnit library to your library list.                  */
/*  b) Start the Rexx script with the following command:               */
/*       STRREXPRC SRCMBR(MKUT) SRCFILE(QUNITTEST) PARM(prdLib)        */
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
     "MSGDTA('Usage: STRREXPRC SRCMBR(MKUT) SRCFILE(QUNITTEST) PARM(prdLib)')",
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

 /* Self-Tests. */

 executeUnitTest('MKLIBLT', 'LIBLT')
 executeUnitTest('MKPGMMSGT', 'PGMMSGT')
 executeUnitTest('MKSTRINGT', 'STRINGT')
 executeUnitTest('MKCRTTSTT', 'CRTTSTT')
 executeUnitTest('MKASSERTT', 'ASSERTT')
 executeUnitTest('MKCALLPRCT', 'CALLPRCT')
 executeUnitTest('MKEXTPRCT', 'EXTPRCT')
 executeUnitTest('MKEXTTSTT', 'EXTTSTT')
 executeUnitTest('MKJOBLOGT', 'JOBLOGT')
 executeUnitTest('MKRUNT', 'RUNT')
 executeUnitTest('MKCMDRUNT', 'CMDRUNT')
 executeUnitTest('MKCMDRUNLT', 'CMDRUNLOGT')

 "SNDPGMMSG ",
   "MSGID(CPF9897) ",
   "MSGF(QCPFMSG) ",
   "MSGDTA('Successfully executed self-tests: "prdLib"')",
   "TOPGMQ(*PRV (*CTLBDY)) ",
   "MSGTYPE(*INFO)"

 EXIT

 /* ------------------------------------------------------------- */
 /* Executes a given test case.                                   */
 /* ------------------------------------------------------------- */
 executeUnitTest:
   PARSE ARG buildScript, unitTest

   "STRREXPRC SRCMBR("buildScript") SRCFILE(QUNITTEST) PARM('"prdLib" "dbgView" "tgtRls"')"
   "RUCALLTST  TSTPGM("prdLib"/"unitTest")"

   return ''

 /* ------------------------------------------------------------- */
 /* Global Error handler                                          */
 /* ------------------------------------------------------------- */
 Error:
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('ERROR: Failed to run self-tests. Check the job log for details') ",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"

   EXIT

