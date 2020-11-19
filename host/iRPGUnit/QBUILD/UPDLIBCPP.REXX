/* ========================================================================== */
/*  iRPGUnit - Update RPGUNIT library.                                        */
/* ========================================================================== */
/*  This Rexx script is the command processing script of                      */
/*  command UPDLIB.                                                           */
/* ========================================================================== */
/*  Copyright (c) 2013-2019 iRPGUnit Project Team                             */
/*  All rights reserved. This program and the accompanying materials          */
/*  are made available under the terms of the Common Public License v1.0      */
/*  which accompanies this distribution, and is available at                  */
/*  http://www.eclipse.org/legal/cpl-v10.htm                                  */
/* ========================================================================== */

 /* Register error handler */
 Signal on Error

 /* Setup ERROR,FAILURE & SYNTAX condition traps.*/
 SIGNAL on NOVALUE
 SIGNAL on SYNTAX

 PARSE ARG 'LIB('library')'

 library = translate(strip(library))

 if (library = "") then do
   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Usage: STRREXPRC SRCMBR(UPDLIBCPP) SRCFILE(QBUILD) PARM(library)')",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"
 end

 /* -------------------------------------------- */
 /*  Let's do it!                                */
 /* -------------------------------------------- */

 /* Update programs */
 "UPDPGM PGM("library"/RUCALLTST) MODULE(*NONE) SRVPGMLIB("library")"

 "UPDPGM PGM("library"/RUCRTTST) MODULE(*NONE) SRVPGMLIB("library")"

 "UPDPGM PGM("library"/RUPGMRMT) MODULE(*NONE) SRVPGMLIB("library")"

 /* Update commands */
 "CHGCMD CMD("library"/CMPMOD) PGM(*REXX) REXSRCFILE("library"/QBUILD) ",
   "HLPPNLGRP("library"/CMPMODHLP)"

 "CHGCMD CMD("library"/RUCALLTST) PGM("library"/RUCALLTST) ",
   "HLPPNLGRP("library"/RUCALLTST) ",
   "VLDCKR("library"/RUCALLTSTV)"

 "CHGCMD CMD("library"/RUCRTTST) PGM("library"/RUCRTTST) ",
   "HLPPNLGRP("library"/RUCRTTST)"

 /* Done */
 "SNDPGMMSG ",
   "MSGID(CPF9897) ",
   "MSGF(QCPFMSG) ",
   "MSGDTA('Successfully updated library "library".')",
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
     "MSGDTA('ERROR: Failed to update library "library". Check the job log for details') ",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)"

   EXIT

