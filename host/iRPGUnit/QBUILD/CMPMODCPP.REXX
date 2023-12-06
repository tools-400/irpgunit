/* ========================================================================== */
/*  iRPGUnit - Compile module.                                                */
/* ========================================================================== */
/*  This Rexx script is the command processing script of                      */
/*  command CMPMOD.                                                           */
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
 SIGNAL ON SYNTAX

 PARSE ARG 'MODULE('objLib'/'objName') SRCFILE('srcLib'/'srcFile') SRCMBR('srcMbr')',
           'DBGVIEW('dbgView') TGTRLS('tgtRls')'

 objLib = strip(objLib)
 objName = strip(objName)
 srcLib = strip(srcLib)
 srcFile = strip(srcFile)
 srcMbr = strip(srcMbr)
 dbgView = strip(dbgView)
 tgtRls = strip(tgtRls)

 dbgView = strip(dbgView,, '''')
 tgtRls = strip(tgtRls,, '''')

 if srcMbr = '*MODULE' then
   srcMbr = objName

 /* Get creation date of module */

 Signal off Error
 objDate= '0000-00-00-000000'
 'CHKOBJ OBJ(&objLib/&objName) OBJTYPE(*MODULE)'
 if rc = 0 then do
   'RTVOBJD OBJ(&objLib/&objName) OBJTYPE(*MODULE) SRCDATE(&objDate)'
   objDate=getTimestamp(objDate)
 end

 Signal on Error

 /* Get date when the source member was last changed */

 srcDate = '9999-99-99-999999'
 srcType = '          '  /* 10 spaces */
 'RTVMBRD FILE(&srcLib/&srcFile) MBR(&srcMbr) SRCCHGDATE(&srcDate) SRCTYPE(&srcType)'
 srcDate=getTimestamp(srcDate)

 if srcDate <= objDate then do
   "SNDPGMMSG ",
     "MSGID(CPF9897) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Object "objLib"/"objName" is up to date.') ",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*INFO)";
   EXIT;
 end

 /* Compile dirty module */

 if srcType = 'RPGLE' then
   do
     'CRTRPGMOD MODULE(&objLib/&objName) SRCFILE(&srcFile) SRCMBR(&srcMbr)',
               'DBGVIEW(&dbgView) TRUNCNBR(*NO) TGTRLS(&tgtRls)'
     deleteSpooledFile(objName)
     sendCreatedMessage(objLib, objName)
     EXIT;
   end

 if srcType = 'SQLRPGLE' then
   do
     if dbgView <> '*NONE' then
       dbgView = '*ALL'

     'CRTSQLRPGI OBJ(&objLib/&objName) SRCFILE(&srcFile) SRCMBR(&srcMbr)',
              'OBJTYPE(*MODULE) RPGPPOPT(*LVL2)',
              'COMPILEOPT(''TRUNCNBR(*NO) DBGVIEW('dbgView')'')',
              'DBGVIEW(*NONE) TGTRLS(&tgtRls)'
     deleteSpooledFile(objName)
     deleteSpooledFile(objName)
     sendCreatedMessage(objLib, objName)
     EXIT;
   end

 if srcType = 'CLLE' then
   do
     'CRTCLMOD MODULE(&objLib/&objName) SRCFILE(&srcFile) SRCMBR(&srcMbr)',
              'DBGVIEW(&dbgView) TGTRLS(&tgtRls)'
     deleteSpooledFile(objName)
     sendCreatedMessage(objLib, objName)
     EXIT;
   end

 "SNDPGMMSG ",
   "MSGID(CPF9898) ",
   "MSGF(QCPFMSG) ",
   "MSGDTA('ERROR: Unknown source type: "srcType".",
   "TOPGMQ(*PRV (*CTLBDY)) ",
   "MSGTYPE(*ESCAPE)";

 EXIT;

deleteSpooledFile:
   PARSE ARG splfName

     Signal off Error
     'DLTSPLF FILE('splfName') JOB(*) SPLNBR(*LAST)'
     Signal on Error

   return ''

 /* ------------------------------------------------------------- */
 /* Send "Object created" message.                                */
 /* ------------------------------------------------------------- */
sendCreatedMessage:
   PARSE ARG objLib, objName

   "SNDPGMMSG ",
     "MSGID(CPF9897) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('Object "objLib"/"objName" created.') ",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*INFO)";

   return ''

 /* ------------------------------------------------------------- */
 /* Converts a given date of format CYMDHMS to an *ISO timestamp  */
 /* ------------------------------------------------------------- */
getTimestamp:
   ARG CYMDHMS

   SRC_CYMD = substr(CYMDHMS, 1, 7)
   SRC_HMS = substr(CYMDHMS, 8, 6)
   DATE_ISO = '0000-00-00'

   'CVTDAT  DATE(&SRC_CYMD) TOVAR(&DATE_ISO) FROMFMT(*CYMD) TOFMT(*ISO)'
   TIME_ISO = SRC_HMS
   TIMESTAMP = DATE_ISO'-'TIME_ISO

   return TIMESTAMP

/* Error handler */
Error:

   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('ERROR: Failed to compile module "objName". Check the job log for details') ",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)";

   EXIT;

