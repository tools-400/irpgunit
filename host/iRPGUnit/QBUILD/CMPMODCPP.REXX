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
           'DBGVIEW('dbgView') TGTRLS('tgtRls') DEFINE('define') OPTIMIZE('optimize')'

 objLib = strip(objLib)
 objName = strip(objName)
 srcLib = strip(srcLib)
 srcFile = strip(srcFile)
 srcMbr = strip(srcMbr)
 dbgView = strip(dbgView)
 tgtRls = strip(tgtRls)
 define = strip(define)
 optimize = strip(optimize)

 dbgView = strip(dbgView,, '''')
 tgtRls = strip(tgtRls,, '''')

 if optimize = '*AUTO' then do
   if dbgView <> '*NONE' then
     optimize = '*NONE'
   else
     optimize = '*FULL'
 end

 if srcMbr = '*MODULE' then
   srcMbr = objName

 /* Get creation date of module */

 Signal off Error
 objDate= '0000-00-00-000000'
 'CHKOBJ OBJ(&objLib/&objName) OBJTYPE(*MODULE)'
 if rc = 0 then do
   'RTVOBJD OBJ(&objLib/&objName) OBJTYPE(*MODULE) SRCDATE(&objDate)'
   objDate=getTimestamp(objDate)

   modi0100 = getModuleAttributes(objLib, objName)
   SrcFile = STRIP(SUBSTR(modi0100, 52, 10), 'Trailing', ' ')  /* Source File starts at byte 13 */
   SrcLib  = STRIP(SUBSTR(modi0100, 62, 10), 'Trailing', ' ')  /* Source Lib starts at byte 23 */
   SrcMbr  = STRIP(SUBSTR(modi0100, 72, 10), 'Trailing', ' ')  /* Compiler ID starts at byte 53 */
   modAttr_optLvl = getOptLvl(modi0100)
 end
 else do
   modAttr_optLvl = ''
 end

 Signal on Error

 /* Get date when the source member was last changed */

 srcDate = '9999-99-99-999999'
 srcType = '          '  /* 10 spaces */
 'RTVMBRD FILE(&srcLib/&srcFile) MBR(&srcMbr) SRCCHGDATE(&srcDate) SRCTYPE(&srcType)'
 srcDate=getTimestamp(srcDate)

 if srcDate <= objDate & optimize = modAttr_optLvl then do
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
               'DBGVIEW(&dbgView) TRUNCNBR(*NO) TGTRLS(&tgtRls) DEFINE(&define)',
               'OPTIMIZE(&optimize)'
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
              'COMPILEOPT(''TRUNCNBR(*NO) DBGVIEW('dbgView') OPTIMIZE('optimize')'')',
              'DBGVIEW(*NONE) TGTRLS(&tgtRls)'
     deleteSpooledFile(objName)
     deleteSpooledFile(objName)
     sendCreatedMessage(objLib, objName)
     EXIT;
   end

 if srcType = 'CLLE' then
   do
     'CRTCLMOD MODULE(&objLib/&objName) SRCFILE(&srcFile) SRCMBR(&srcMbr)',
              'DBGVIEW(&dbgView) TGTRLS(&tgtRls)',
              'OPTIMIZE(&optimize)'
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

 /* ------------------------------------------------------------- */
 /* Retrieve module attributes                                    */
 /* ------------------------------------------------------------- */
getModuleAttributes:
   PARSE ARG objLib, objName

   /* REXX: Get RPG Module Attributes */
   QualMod = LEFT(objName, 10) || LEFT(objLib, 10)

   /* 1. Initialize receiver variable (Length 500 for MODI0100 format) */
   ReceiverSize = 500
   MODI0100 = COPIES(' ', ReceiverSize)

   /* 2. Call the QBNRMODI API */
   /* Parameters: Receiver, Length, Format, Qualified Module, Error Code */
   "CALL PGM(QBNRMODI) PARM(" ,
       "&MODI0100"            ,      /* Output buffer */
       "X'"D2X(ReceiverSize, 4)"'" , /* Length (Binary 4) */
       "MODI0100"             ,      /* Format Name */
       "&QualMod"             ,      /* Mod + Lib */
       "X'00000000'           )"     /* Error Code (Empty = Exception) */

   return MODI0100

 /* ------------------------------------------------------------- */
 /* Retrieves the optimization level from MODI0100 buffer         */
 /* ------------------------------------------------------------- */
getOptLvl:
   PARSE ARG modi0100
   optLvlDec = C2D(SUBSTR(modi0100, 205, 4))

   select
   when optLvlDec = 10 then return '*NONE'
   when optLvlDec = 20 then return '*BASIC'
   when optLvlDec = 30 then return '*FULL'
   otherwise
     return ''
   end

/* Error handler */
Error:

   "SNDPGMMSG ",
     "MSGID(CPF9898) ",
     "MSGF(QCPFMSG) ",
     "MSGDTA('ERROR: Failed to compile module "objName". Check the job log for details') ",
     "TOPGMQ(*PRV (*CTLBDY)) ",
     "MSGTYPE(*ESCAPE)";

   EXIT;

