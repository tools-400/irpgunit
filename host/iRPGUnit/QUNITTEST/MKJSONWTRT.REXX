/* =================================================================== */
/*  iRPGUnit SelfTest - Build JSONWTRT.                                */
/* =================================================================== */
/* Copyright (c) 2013-2025 iRPGUnit Project Team                       */
/* All rights reserved. This program and the accompanying materials    */
/* are made available under the terms of the Common Public License v1.0*/
/* which accompanies this distribution, and is available at            */
/* http://www.eclipse.org/legal/cpl-v10.html                           */
/* =================================================================== */
/*  Usage:                                                             */
/*  a) Add the iRPGUnit library to your library list.                  */
/*  b) Start the Rexx script with the following command:               */
/*       STRREXPRC SRCMBR(MKCMDRUNT) SRCFILE(QUNITTEST) PARM(prdLib)   */
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
/*       >>PARM<< PARM('&LI *LIST');                                   */
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
 UTILITY = 'JSONWTRT'

 PARSE ARG prdLib dbgView tgtrls

 prdLib  = translate(strip(prdLib))
 dbgView = translate(strip(dbgView))
 tgtRls  = translate(strip(tgtRls))

 if (prdLib = "") then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Usage: STRREXPRC SRCMBR(MKCMDRUNT) SRCFILE(QUNITTEST) PARM(prdLib)')",
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
 /*  Recreate the modules if needed.             */
 /* -------------------------------------------- */

 "STRREXPRC SRCMBR(A_INSTALL) SRCFILE(RPGUNITDVP/QBUILD) PARM('CMPMOD "prdLib" "dbgView" "tgtRls"')"

 /* -------------------------------------------- */
 /*  Let's do it!                                */
 /* -------------------------------------------- */

 "CMPMOD MODULE("prdLib"/JSONWTRT ) SRCFILE("prdLib"/QUNITTEST) DBGVIEW("dbgView") TGTRLS("tgtRls")"

 "CRTSRVPGM  SRVPGM("prdLib"/JSONWTRT)",
            "MODULE("prdLib"/JSONWTRT) ",
            "EXPORT(*ALL) ",
            "BNDDIR("prdLib"/IRPGUNIT) ",
            "TEXT('RPGUnit SelfTest - Test JSONWTR.')"

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

