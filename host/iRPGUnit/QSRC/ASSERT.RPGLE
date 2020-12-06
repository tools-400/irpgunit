      // ==========================================================================
       //  iRPGUnit - Assertion Facilities.
      // ==========================================================================
       //  Copyright (c) 2013-2019 iRPGUnit Project Team
       //  All rights reserved. This program and the accompanying materials
       //  are made available under the terms of the Common Public License v1.0
       //  which accompanies this distribution, and is available at
       //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================
       // >>PRE-COMPILER<<
       //   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
       //   >>IMPORTANT<<
       //     >>PARM<<  OPTION(*EVENTF);
       //     >>PARM<<  DBGVIEW(*LIST);
       //   >>END-IMPORTANT<<
       //   >>EXECUTE<<
       // >>END-PRE-COMPILER<<
      // ==========================================================================

     H NoMain
      /include qinclude,H_SPEC
      /include qinclude,COPYRIGHT

       //----------------------------------------------------------------------
       //   IMPORTS
       //----------------------------------------------------------------------

      /define RPGUNIT_INTERNAL
      /include qinclude,ASSERT
      /include qinclude,ERRORCODE
      /include qinclude,PGMMSG
      /include qinclude,TEMPLATES
      /include qinclude,STRING
      /include qinclude,SYSTEMAPI

      /include qinclude,SDS

      /include qsysinc,CEEAPI

       //----------------------------------------------------------------------
       //   PRIVATE PROTOTYPES
       //----------------------------------------------------------------------

     D checkStartPgm   pr                  extproc('checkStartPgm')

     D doAssert        pr                  extproc('doAssert')
     D  condition                      n   const
     D  msgIfFalse                16384a   const varying options(*Varsize)
     D  toCallStacKE                 10i 0 const
     D  startProc                   256a   const varying options(*varsize)


     D doFail          pr                  extproc('doFail')
     D  msg                       16384a   const varying options(*Varsize)
     D  toCallStacKE                 10i 0 const
     D  startProc                   256a   const varying options(*varsize)

     D getCallStk      pr                  extproc('getCallStk')
     D                                     likeds(CallStk_t)
     D  startProc                   256a   const varying options(*varsize)

     D getSentTimeJobLogMsg...
     D                 pr              z
     D                                     extproc('getSentTimeJobLogMsg')
     D  msg                                const likeds(dsOLJL0100EntHdr)

     D getSentTimeMsgQMsg...
     D                 pr              z
     D                                     extproc('getSentTimeMsgQMsg')
     D  msg                                const likeds(dsLSTM0100EntHdr)

     D getValueFromDesc...
     D                 pr         32565a   varying
     D                                     extproc(
     D                                       'getValueFromDescriptor_internal')
     D  descInf                            const likeds(ceedod_inf_t)
     D  strInf                             const likeds(ceegsi_inf_t)
     D  fc                                 const likeds(fc_t)
     D  value                     32565a   const options(*varsize)
     D  dftLen                       10i 0 const

     D getValueFromDescriptor_internal...
     D                 pr         32565a   varying
     D                                     extproc(
     D                                       'getValueFromDescriptor_internal')
     D  descInf                            const likeds(ceedod_inf_t)
     D  strInf                             const likeds(ceegsi_inf_t)
     D  fc                                 const likeds(fc_t)
     D  value                     32565a         options(*varsize)
     D  dftLen                       10i 0 const

     d descTypeToExt...
     d                 pr            20a   varying
     d                                     extproc('descTypeToExt')
     d  dataType                     10i 0 const

       //----------------------------------------------------------------------
       //   GLOBAL CONSTANTS
       //----------------------------------------------------------------------

     D NO_MSG_TEXT     c                   '*N'

     D START_PROC_AEQUAL...
     D                 c                   'aEqual'
     D START_PROC_IEQUAL...
     D                 c                   'iEqual'
     D START_PROC_NEQUAL...
     D                 c                   'nEqual'
     D START_PROC_ASSERT...
     D                 c                   'assert'
     D START_PROC_FAIL...
     D                 c                   'fail'


       //----------------------------------------------------------------------
       //   GLOBAL VARIABLES
       //----------------------------------------------------------------------

       // Number of assertions called.
     D assertCalled    s             10i 0

       // Latest assertion failure event information. Can be blank if no
       //  assertion failure event since last assertion.
     D assertFailEvt   ds                  likeds(AssertFailEvtLong_t)

     D status          ds                  qualified
     D  qStartPgm                          likeds(Object_t)

       //----------------------------------------------------------------------
       // Registers the start program RUPGMRMT or RUCALLTST for
       // using the RUTESTCASE service program.
       //----------------------------------------------------------------------
     P registerStartPgm...
     P                 b                   export
     D                 pi
     D  lib                          10a   const
     D  pgm                          10a   const

      /free

       status.qStartPgm.nm = pgm;
       status.qStartPgm.lib = lib;

      /end-free
     P                 e

       //----------------------------------------------------------------------
       // Check, whether this instance of RUTESTCASE has been registered
       // with a start program. If that is not the case, the start progam
       // uses another RUTESTCASE service  program, which leads to errors.
       //----------------------------------------------------------------------
     P checkStartPgm...
     P                 b                   export
     D                 pi

     D msg             s            256a   varying
      /free

       if (status.qStartPgm.lib <> sds.pgmLib);
         msg = 'Start program RUCALLTST or RUPGMRMT was not +
                registered with service program ' +
                %trim(sds.pgmLib) + '/' + %trim(sds.pgmName) + '. +
                Make sure that there are no duplicate iRPGUnit +
                objects in the library list. +
                Compare the library list with the product library +
                on the iRPGUnit preference page.';
         sndEscapeMsgAboveCtlBdy(msg);
       endif;

      /end-free
     P                 e

       //----------------------------------------------------------------------
       // Cobol enabled.
       // Assert equality between two alphanumeric variables.
       //----------------------------------------------------------------------
     P aEqual...
     P                 b                   export
     D                 pi                  opdesc
     D  expected                  32565a   const
     D  actual                    32565a   const
     D  fieldName                    64a   const         options(*nopass: *omit)

     D p_expected      c                   1
     D p_actual        c                   2
     D p_fieldName     c                   3

     D tExpected       s          32565a   varying
     D tActual         s          32565a   varying
     D tFieldName      s                   like(fieldName)
     D msg             s                   like(msgText_t) inz

     D descInf...
     D                 ds                  likeds(ceedod_inf_t) inz
     D strInf...
     D                 ds                  likeds(ceegsi_inf_t) inz

     D expectedDesc...
     D                 ds                  likeds(ceegsi_inf_t) inz
     D actualDesc...
     D                 ds                  likeds(ceegsi_inf_t) inz
     D fieldNameDesc...
     D                 ds                  likeds(ceegsi_inf_t) inz
     D fc              ds                  likeds(fc_t) inz

      /free

       CEEDOD(p_expected: descInf.descType: descInf.dataType
              : descInf.descInf1: descInf.descInf2: descInf.dataLen: fc);
       CEEGSI(p_expected: strInf.dataType
              : strInf.curLen: strInf.maxLen: fc);
       tExpected = getValueFromDesc(
                     descInf: strInf: fc: expected: %size(expected));

       CEEDOD(p_actual: descInf.descType: descInf.dataType
              : descInf.descInf1: descInf.descInf2: descInf.dataLen: fc);
       CEEGSI(p_actual: strInf.dataType
              : strInf.curLen: strInf.maxLen: fc);
       tActual = getValueFromDesc(descInf: strInf: fc: actual: %size(actual));

       if (%parms() >= p_fieldName and %addr(fieldName) <> *NULL);


         CEEDOD(p_fieldName: descInf.descType: descInf.dataType
                : descInf.descInf1: descInf.descInf2: descInf.dataLen: fc);
         CEEGSI(p_fieldName: strInf.dataType
                : strInf.curLen: strInf.maxLen: fc);
         tFieldName = getValueFromDesc(
                        descInf: strInf: fc: fieldName: %size(fieldName));

         msg = %trim(tFieldName) + ': ';
       endif;

       msg = msg
           + 'Expected ' + QUOTE + %trimr(tExpected) + QUOTE + ','
           + ' but was ' + QUOTE + %trimr(tActual  ) + QUOTE + '.';
       doAssert(tExpected = tActual: msg
                : ONE_CALL_STK_LVL_ABOVE: START_PROC_AEQUAL);

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Assert equality between two integers.
       //----------------------------------------------------------------------
     P iEqual...
     P                 b                   export
     D                 pi                  opdesc
     D  expected                     31s 0 const
     D  actual                       31s 0 const
     D  fieldName                    64a   const varying options(*nopass: *omit)

     D msg             s                   like(msgText_t) inz

      /free

       if (%parms() >= 3 and %addr(fieldName) <> *NULL);
         msg = %trim(fieldName) + ': ';
       endif;

       msg = msg
           + 'Expected ' + %char(expected) + ','
           + ' but was ' + %char(actual  ) + '.';
       doAssert(expected = actual: msg
                : ONE_CALL_STK_LVL_ABOVE: START_PROC_IEQUAL);

      /end-free
     P                 e

       //----------------------------------------------------------------------
       // Assert equality between two alphanumeric variables.
       //----------------------------------------------------------------------
     P nEqual...
     P                 b                   export
     D                 pi                  opdesc
     D  expected                       n   const
     D  actual                         n   const
     D  fieldName                    64a   const varying options(*nopass: *omit)

     D msg             s                   like(msgText_t) inz

      /free

       if (%parms() >= 3 and %addr(fieldName) <> *NULL);
         msg = %trim(fieldName) + ': ';
       endif;

       msg = msg
           + 'Expected ' + QUOTE + expected + QUOTE + ','
           + ' but was ' + QUOTE + actual   + QUOTE + '.';
       doAssert(expected = actual: msg
                : ONE_CALL_STK_LVL_ABOVE: START_PROC_NEQUAL);


      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Cobol enabled.
       // Asserts that a condition is true. See prototype.
       //----------------------------------------------------------------------
     P assert...
     P                 b                   export
     D                 pi                  opdesc
     D  condition                      n   const
     D  msgIfFalse                         const like(OldMsg_t) options(*nopass)

     D p_msgIfFalse    c                   2

     D tMsgIfFalse     s          16384a   varying

     D descInf...
     D                 ds                  likeds(ceedod_inf_t) inz...
     D strInf...
     D                 ds                  likeds(ceegsi_inf_t) inz...
     D fc              ds                  likeds(fc_t) inz
      /free

       if (%parms() >= p_msgIfFalse);

         CEEDOD(p_msgIfFalse: descInf.descType: descInf.dataType
                : descInf.descInf1: descInf.descInf2: descInf.dataLen: fc);
         CEEGSI(p_msgIfFalse: strInf.dataType
                : strInf.curLen: strInf.maxLen: fc);
         tMsgIfFalse = getValueFromDesc(
                         descInf: strInf: fc: msgIfFalse: %len(msgIfFalse));

         doAssert(condition: tMsgIfFalse
                  : ONE_CALL_STK_LVL_ABOVE: START_PROC_ASSERT);
       else;
         // Called by Cobol or new RPG after iRPGUnit v4.
         doAssert(condition: NO_MSG_TEXT
                  : ONE_CALL_STK_LVL_ABOVE: START_PROC_ASSERT);
       endif;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Cobol enabled.
       // Signals a test failure and stops the test.
       //----------------------------------------------------------------------
     P fail...
     P                 b                   export
     d                 pi                  opdesc
     D  msg                                const like(OldMsg_t) options(*nopass)

     D p_msg           c                   1

     D tMsg            s          16384a   varying

     D descInf...
     D                 ds                  likeds(ceedod_inf_t) inz...
     D strInf...
     D                 ds                  likeds(ceegsi_inf_t) inz...
     D fc              ds                  likeds(fc_t) inz
      /free

       if (%parms() >= p_msg);

         CEEDOD(p_msg: descInf.descType: descInf.dataType
                : descInf.descInf1: descInf.descInf2: descInf.dataLen: fc);
         CEEGSI(p_msg: strInf.dataType
                : strInf.curLen: strInf.maxLen: fc);
         tMsg = getValueFromDesc(descInf: strInf: fc: msg: %len(msg));

         doFail(tMsg: -1: START_PROC_FAIL);
       else;
         // Called by Cobol or new RPG after iRPGUnit v4.
         doFail(NO_MSG_TEXT: -1: START_PROC_FAIL);
       endif;

      /end-free
     P                 e


     P doAssert...
     P                 b
     D                 pi
     D  condition                      n   const
     D  msgIfFalse                16384a   const varying options(*Varsize)
     D  toCallStacKE                 10i 0 const
     D  startProc                   256a   const varying options(*varsize)
      /free

       checkStartPgm();

       assertCalled += 1;
       clrAssertFailEvt();

       if not condition;
         doFail( msgIfFalse :  toCallStacKE + 1: startProc);
       endif;

      /end-free
     P                 e


     P doFail...
     P                 b
     D                 pi
     D  msg                       16384a   const varying options(*Varsize)
     D  toCallStacKE                 10i 0 const
     D  startProc                   256a   const varying options(*varsize)
      /free

       assertFailEvt.msg = %trimR( msg );
       assertFailEvt.callStk = getCallStk(startProc);

         sndEscapeMsg( msg : toCallStacKE + 1 );

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Clear the latest assertion failure event.
       //----------------------------------------------------------------------
     P clrAssertFailEvt...
     P                 b                   export
     D                 pi
      /free

       clear assertFailEvt;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Returns the number of time assertions were called. See prototype.
       //----------------------------------------------------------------------
     P getAssertCalled...
     P                 b                   export
     D                 pi            10i 0
      /free
       return assertCalled;

      /end-free
     P                 e

       //----------------------------------------------------------------------
       // Return information about the latest assertion failure event.
       //----------------------------------------------------------------------
     P getAssertFailEvt...
     P                 b                   export
     D                 pi
     D                                     likeds(AssertFailEvt_t)

       // Assert Failure Event of version 1
     D assertFailEvt_v1...
     D                 ds                  likeds(assertFailEvt_t) inz
      /free

       assertFailEvt_v1.msg = assertFailEvt.msg;
       assertFailEvt_v1.callStk = assertFailEvt.callStk;

       return assertFailEvt_v1;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Return information about the latest assertion failure event.
       //----------------------------------------------------------------------
     P getAssertFailEvtLong...
     P                 b                   export
     D                 pi
     D                                     likeds(AssertFailEvtLong_t)
      /free

       return assertFailEvt;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Resets the counter of the failed assertions.
       //----------------------------------------------------------------------
     P clearAssertCounter...
     P                 b                   export
     D                 pi
      /free

       assertCalled = 0;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Searches the job log backwards for a specific message key, starting
       // with the most recent message and back to a given timestamp.
       //----------------------------------------------------------------------
     P assertJobLogContains...
     P                 b                   export
     D                 pi                  opdesc
     D  msgId                         7a   const
     D  timeLimit                      z   const

       // Job log message field selection for QGYOLJBL API.
     D fldSelect       ds                  qualified
     D  listDirection                10a   inz('*PRV')
     D  qlfJobNm                     26a   inz('*')
     D  intJobId                     16a   inz(*blank)
     D  startMsgKey                   4a   inz(x'FFFFFFFF')
     D  maxMsgLen                    10i 0 inz(0)
     D  maxMsgHlpLen                 10i 0 inz(0)
     D  fldIdOff                     10i 0
     D  fldCnt                       10i 0 inz(1)
     D  callMsgqNmOff                10i 0
     D  callMsgqNmLen                10i 0 inz(%size(fldSelect.callMsgqNm))
     D  fldId1                       10i 0 inz(OLJL_SND_PGM_NM)
     D  callMsgqNm                    1a   inz('*')

     D listInfo        ds                  likeds(dsOpnList)
     D msgBasicInfo    ds                  likeds(dsOLJL0100EntHdr)
     D                                     based(p_msgBasicInfo)
     D p_msgBasicInfo  s               *
     D jobLogList      s          32766a
     D sentTimeStamp   s               z
     D msgIdx          s             10i 0
     D msgFound        s               n   inz(*off)
     D percolateErrors...
     D                 ds                  likeds(percolateErrors_t)
     D                                     inz(*likeds)
      /free

       fldSelect.fldIdOff = %addr(fldSelect.fldId1) - %addr(fldSelect);
       fldSelect.callMsgqNmOff =
                        %addr(fldSelect.callMsgqNm) - %addr(fldSelect);

       QGYOLJBL( jobLogList :
                 %size( jobLogList ) :
                 listInfo :
                 OLJL_FULL_SYNCHRONOUS_BUILD :
                 fldSelect :
                 %size( fldSelect ) :
                 percolateErrors );

       p_msgBasicInfo = %addr( jobLogList );
       msgIdx = 1;

       dow 1=1;
         if msgIdx > listInfo.retRcdCnt;
           if listInfo.totalRcdCnt > listInfo.retRcdCnt;
             sndEscapeMsgToCaller( 'Insufficient implementation. ' +
                   'Should use QGYGTLE to retrieve records after ' +
                                %char( listInfo.retRcdCnt ) + '. ' +
                                           'Please open an issue.' );
           else;
             leave;
           endif;
         endif;

         sentTimeStamp = getSentTimeJobLogMsg( msgBasicInfo );

         if sentTimeStamp < timeLimit;
           leave;
         endif;

         if msgBasicInfo.msgId = msgId;
           msgFound = *on;
           leave;
         endif;

         // Go to next message in the job log.
         p_msgBasicInfo = %addr( jobLogList ) + msgBasicInfo.nextEntOff;
         msgIdx += 1;
       enddo;

       QGYCLST( listInfo.rqsHdl : percolateErrors );

       assert( msgFound : 'Message ' + msgId + ' not found in the job log.' );

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Searches a given message queue backwards for a message identified
       // by 'Id', 'text' or 'help text' starting with the most recent message
       // and back to a given timestamp.
       //----------------------------------------------------------------------
     P assertMessageQueueContains...
     P                 b                   export
     D                 pi                  opdesc
     D  userOrQueue                  10a   const
     D  library                      10a   const options(*omit)
     D  msgId                         7a   const options(*omit)
     D  msgText                     132a   const varying options(*omit)
     D  msgHelp                     256a   const varying options(*omit)
     D  timeLimit                      z   const

       // Message queue message field selection for QGYOLMSG API.
     D fldSelect       ds                  qualified
     D  listDirection                10a   inz('*PRV')
     D  reserved_1                    2a   inz
     D  severity                     10i 0 inz(0)
     D  maxMsgLen                    10i 0 inz(132)
     D  maxMsgHlpLen                 10i 0 inz(0)
     D  selectOff                    10i 0
     D  selectCnt                    10i 0 inz(1)
     D  strMsgKeyOff                 10i 0
     D  fldIdOff                     10i 0
     D  fldCnt                       10i 0 inz(0)
     D  msgSelect                    10a   inz('*ALL')
     D  strMsgKey1                    4a   inz(x'FFFFFFFF')
     D  fldId                        10i 0 dim(4) inz

     D checkMsgId      s               n   inz(*off)
     D checkMsgText    s               n   inz(*off)
     D checkMsgHelp    s               n   inz(*off)
     D checkCount      s             10i 0 inz(0)
     D checkMatch      s             10i 0 inz(0)

     D msgQueueInf     ds                  likeds(dsUserQueueInf)
     D msgQueuesUsed   ds                  likeds(dsMsgQueuesUsed)
     D listInfo        ds                  likeds(dsOpnList)
     D msgBasicInfo    ds                  likeds(dsLSTM0100EntHdr)
     D                                     based(p_msgBasicInfo)
     D p_msgBasicInfo  s               *
     D fldInfo         ds                  likeds(dsLSTM0100FldHdr)
     D                                     based(p_fldInfo)
     D p_fldInfo       s               *
     D fldData         s          32766a   based(p_fldData)
     D p_fldData       s               *

     D i               s             10i 0
     D msgQueueList    s          32766a
     D sentTimeStamp   s               z
     D msgIdx          s             10i 0
     D msgFound        s               n   inz(*off)
     D percolateErrors...
     D                 ds                  likeds(percolateErrors_t)
     D                                     inz(*likeds)
      /free

       fldSelect.selectOff = %addr(fldSelect.msgSelect) - %addr(fldSelect);
       fldSelect.strMsgKeyOff = %addr(fldSelect.strMsgKey1) - %addr(fldSelect);
       fldSelect.fldIdOff = %addr(fldSelect.fldId) - %addr(fldSelect);

       clear msgQueueInf;
       if (%parms() >= %parmnum(library) and %addr(library) <> *null);
         msgQueueInf.ind = LSTM_MSG_QUEUE_NAME;
         msgQueueInf.userOrQueueNm = userOrQueue;
         msgQueueInf.libraryNm = library;
       else;
         msgQueueInf.ind = LSTM_USER_NAME;
         msgQueueInf.userOrQueueNm = userOrQueue;
       endif;

       fldSelect.fldCnt = 1;
       fldSelect.fldId(fldSelect.fldCnt) = LSTM_RPLY_STATUS;

       fldSelect.fldCnt += 1;
       fldSelect.fldId(fldSelect.fldCnt) = LSTM_SND_USER_PROFILE;

       if (%parms() >= %parmnum(msgId) and %addr(msgId) <> *null);
         checkMsgId = *on;
         checkCount += 1;
       endif;

       if (%parms() >= %parmnum(msgText) and %addr(msgText) <> *null);
         checkMsgText = *on;
         checkCount += 1;
         fldSelect.fldCnt += 1;
         fldSelect.fldId(fldSelect.fldCnt) = LSTM_MSG_WITH_RPL_DATA;
       endif;

       if (%parms() >= %parmnum(msgHelp) and %addr(msgHelp) <> *null);
         checkMsgHelp = *on;
         checkCount += 1;
         fldSelect.fldCnt += 1;
         fldSelect.fldId(fldSelect.fldCnt) = LSTM_MSG_HELP_WITH_RPL_DATA;
       endif;

       if (checkMsgId);
         if msgId = '*EMPTY' and checkCount > 1;
           sndEscapeMsgToCaller('All other selection parameters must be +
                                 omitted, when msgId is set to ''*EMPTY''');
         endif;
       endif;

       QGYOLMSG( msgQueueList :
                 %size( msgQueueList ) :
                 listInfo :
                 OLJL_FULL_SYNCHRONOUS_BUILD :
                 LSTM_SORT_NONE :
                 fldSelect :
                 %size( fldSelect ) :
                 msgQueueInf :
                 msgQueuesUsed :
                 percolateErrors );

       p_msgBasicInfo = %addr( msgQueueList );
       msgIdx = 1;

       checkMatch = 0;
       p_fldInfo = *null;

       if checkMsgId and msgId = '*EMPTY' and listInfo.totalRcdCnt = 0;
         return;
       endif;

       dow listInfo.totalRcdCnt > 0;
         if msgIdx > listInfo.retRcdCnt;
           if listInfo.totalRcdCnt > listInfo.retRcdCnt;
             sndEscapeMsgToCaller( 'Insufficient implementation. ' +
                   'Should use QGYGTLE to retrieve records after ' +
                                %char( listInfo.retRcdCnt ) + '. ' +
                                           'Please open an issue.' );
           else;
             leave;
           endif;
         endif;

         sentTimeStamp = getSentTimeMsgQMsg( msgBasicInfo );

         if sentTimeStamp < timeLimit;
           leave;
         endif;

         if checkMsgId;
           checkMatch += 1;
         endif;

         if (msgBasicInfo.retFldCnt > 0);
           p_fldInfo = %addr( msgQueueList ) + msgBasicInfo.retFldOff;
           for i = 1 to msgBasicInfo.retFldCnt;
             if fldInfo.dataLen > 0;
               p_fldData = p_fldInfo + %size(fldInfo);
               select;
               when fldInfo.fldId = LSTM_MSG_WITH_RPL_DATA;
                 if checkMsgText;
                   if compare(msgText: %subst(fldData: 1: fldInfo.dataLen));
                     checkMatch += 1;
                   endif;
                 endif;
               when fldInfo.fldId = LSTM_MSG_HELP_WITH_RPL_DATA;
                 if checkMsgHelp;
                   if compare(msgHelp: %subst(fldData: 1: fldInfo.dataLen));
                     checkMatch += 1;
                   endif;
                 endif;
               endsl;
             endif;

             p_fldInfo = %addr( msgQueueList ) + fldInfo.nextFldOff;
           endfor;
         endif;

         if checkMatch = checkCount;
           msgFound = *on;
           leave;
         endif;

         // Go to next message in the job log.
         p_msgBasicInfo = %addr( msgQueueList ) + msgBasicInfo.nextEntOff;
         msgIdx += 1;
       enddo;

       QGYCLST( listInfo.rqsHdl : percolateErrors );

       assert( msgFound : 'Message not found in message queue.' );

      /end-free
     P                 e


       //----------------------------------------------------------------------
       //  Returns the call stack. Excludes stack entries RURUNNER
       //  and the lower levels to QCMD.
       //----------------------------------------------------------------------
     P getCallStk...
     P                 b
     D                 pi                  likeds(CallStk_t)
     D  startProc                   256a   const varying options(*varsize)

       // Call stack entries.
     D callStk         ds                  likeds(CallStk_t) inz
       // Job id.
     D jobIdInfo       ds                  likeds(dsJIDF0100)
       // Call stack info header.
     D hdr             ds                  likeds(dsCSTK0100Hdr)
     D                                     based(hdr_p)
     D hdr_p           s               *
       // Call stack info entry.
     D ent             ds                  likeds(dsCSTK0100Ent)
     D                                     based(ent_p)
     D ent_p           s               *
       // Big buffer to receive call stack info.
     D rawCallStk      s          16383a
       // Statement Id.
     D sttId           s             10a   based(sttId_p)
     D sttId_p         s               *
       // Procedure name buffer.
     D procNmBuffer_p  s               *
     D procNmBuffer    s            256a   based(procNmBuffer_p)
       // Index.
     D i               s             10i 0
     D maxStkEnt       s             10i 0
     D callStkE        ds                  likeds(CallStkEnt_t)
     D doReturnStckE   s               n   inz(*off)
     D percolateErrors...
     D                 ds                  likeds(percolateErrors_t)
     D                                     inz(*likeds)
      /free

       jobIdInfo.jobNm = '*';
       jobIdInfo.usrNm = *blank;
       jobIdInfo.jobNb = *blank;
       jobIdInfo.intJobId = *blank;
       jobIdInfo.reserved = *loval;
       jobIdInfo.threadInd = 1;
       jobIdInfo.threadId  = *loval;

       QWVRCSTK( rawCallStk :
                 %size(rawCallStk) :
                 'CSTK0100' :
                 jobIdInfo :
                 'JIDF0100' :
                 percolateErrors );

       hdr_p = %addr(rawCallStk);
       ent_p = hdr_p + hdr.callStkOff;

       maxStkEnt = hdr.nbCallStkEntRtn - 2;
       if (maxStkEnt > MAX_CALL_STK_SIZE);
         maxStkEnt = MAX_CALL_STK_SIZE;
       endif;

       for i = 1 to maxStkEnt;

         if (ent.pgmNm = 'RUCALLTST' or ent.pgmNm = 'RUPGMRMT');
           leave;
         endif;

         clear callStkE;

         if (i = maxStkEnt);
           callStkE.level = 0;
           callStkE.sender.procNm = CALL_STACK_INCOMPLETE;
         else;
           callStkE.level = 0;
           callStkE.sender.qPgm.nm = ent.pgmNm;
           callStkE.sender.qPgm.lib = ent.pgmLibNm;
           callStkE.sender.qMod.nm = ent.modNm;
           callStkE.sender.qMod.lib = ent.modLibNm;

           if ent.procNmLen <> 0;
             procNmBuffer_p = ent_p + ent.dsplToProcNm;
             callStkE.sender.procNm =
                %subst( procNmBuffer: 1: ent.procNmLen );
           else;
             callStkE.sender.procNm = '';
           endif;

           if ent.nbSttId > 0;
             sttId_p = ent_p + ent.dsplToSttId;
             callStkE.sender.specNb = %trimL(%trim(sttId): '0');
           else;
             callStkE.sender.specNb = '*N';
           endif;
         endif;

         // Skip all procedures until we saw the
         // assertion procedure
         if (callStkE.sender.qPgm.nm = 'RUTESTCASE' and
             callStkE.sender.qMod.nm = 'ASSERT' and
             callStkE.sender.procNm = startProc);
           doReturnStckE = *on;
           ent_p += ent.len;
           iter;
         endif;

         if (not doReturnStckE);
           ent_p += ent.len;
           iter;
         endif;

         callStk.numE += 1;
         callStk.entry(callStk.numE) = callStkE;

         ent_p += ent.len;

       endfor;

       return callStk;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Converts the time a job log entry was added from the internal
       // format CYMD to the ISO format.
       //----------------------------------------------------------------------
     P getSentTimeJobLogMsg...
     P                 b
     D                 pi              z
     D  msg                                const likeds(dsOLJL0100EntHdr)

     D sentDateAsIso   s              8a
      /free

       sentDateAsIso = %char( %date( msg.sentDate : *cymd0) : *iso0 );
       return %timestamp( sentDateAsIso +
                          msg.sentTime +
                          msg.microseconds :
                          *iso0 );
      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Converts the time a message was sent from the internal
       // format CYMD to the ISO format.
       //----------------------------------------------------------------------
     P getSentTimeMsgQMsg...
     P                 b
     D                 pi              z
     D  msg                                const likeds(dsLSTM0100EntHdr)

     D sentDateAsIso   s              8a
      /free

       sentDateAsIso = %char( %date( msg.sentDate : *cymd0) : *iso0 );
       return %timestamp( sentDateAsIso +
                          msg.sentTime +
                          msg.microseconds :
                          *iso0 );
      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Returns the value of a given string depending on the
       // descriptor information.
       //----------------------------------------------------------------------
       // Patially taken from Scott Klement's HTTPAPI.
       //----------------------------------------------------------------------
       // getRealSA(): Okay, this one's hard to explain :)
       //
       // The original peSoapAction parameter to HTTPAPI was defined as
       // fixed length "64A CONST".  This was problematic because people
       // needed to be able to specify longer strings.  So they'd use
       // XPROC -- but that's really cumbersome.
       //
       // I wanted to allow longer SoapAction, but I don't want to break
       // backward compatibility?  This is where it gets tricky...  how
       // can old programs pass a 64A, and new programs pass a 16384A
       // and have the routine work in either case??
       //
       // If the parameter is "16384A VARYING" the first two bytes must
       // be the length of the data.  Since the original peSoapAction
       // wasn't VARYING, the first two bytes would be actual data.
       // and due to the nature of a Soap-Action, they'd have to be
       // human readable.  That means the first character in the
       // SoapAction would have to be > x'40' (Blank in EBCDIC)
       //
       // So a VARYING string that's 16384 long would be hex x'4000'
       // in the first two bytes, but the lowest valid soap-action would
       // be x'4040'
       //
       // This routine uses that fact to distinguish between the two
       // types of SoapAction parameters and return the correct result
       // (is this clever? or ugly?)
       //
       // NOTE: This is now used for content-type and useragent as well
       //----------------------------------------------------------------------
     P getValueFromDescriptor_internal...
     P                 b                   export
     D                 pi         32565a   varying
     D  descInf                            const likeds(ceedod_inf_t)
     D  strInf                             const likeds(ceegsi_inf_t)
     D  fc                                 const likeds(fc_t)
     D  value                     32565a         options(*varsize)
     D  dftLen                       10i 0 const

     D length          s              2a           based(p_value)
     D fixLength       s          32565a           based(p_value)
     D varying2        s          32563a   varying based(p_value)
      /free

       p_value = %addr(value);

       // Get value without an operational descriptor.
       // Version: 3.2 and before

       // Missing operational descriptor.
       if (fc.msgSev > 0 and fc.msgNo = x'0502');
         // Check if we have:
         //  a) an incorrect Cobol call without opdesc or
         //  b) an old RPG call from assert() or fail()
         //     with a message parameter defined as OldMsg_t.
         if (length > x'4000');
           return %subst(fixLength: 1: dftLen);
         else;
           // New style with a varying field, but without
           // an operational descriptor. Before: 4.0
           return varying2;
         endif;
       endif;

       // Get value from a descriptor.
       // Version: 4.0+

       select;
       when (descInf.dataType = DOD_TYPE_CHAR); // SBCS characters
         return %subst(value: 1: strInf.curLen);
       when (descInf.dataType = DOD_TYPE_CHARV2); // 2-byte-length + SBCS characters
         return %subst(value: 3: strInf.curLen);
       other;
         sndEscapeMsgAboveCtlBdy(
           'Unsupported data type: ' + descTypeToExt(descInf.dataType));
       endsl;

      /end-free
     P                 e


     p descTypeToExt...
     p                 b
     d                 pi            20a   varying
     d  dataType                     10i 0 const
      /free

       select;
       when (dataType = DOD_TYPE_ESC);
         return 'unknown';
       when (dataType = DOD_TYPE_CHAR);
         return 'typeChar';      // SBCS characters
       when (dataType = DOD_TYPE_CHARZ);
         return 'typeCharZ';     // SBCS characters x'00' terminated
       when (dataType = DOD_TYPE_CHARV2);
         return 'typeCharV2';    // 2-byte varying SBCS characters
       when (dataType = DOD_TYPE_CHARV4);
         return 'typeCharV4';    // 4-byte varying SBCS characters
       when (dataType = DOD_TYPE_BIT);
         return 'typeBit';       // bits with values of 0 or 1
       when (dataType = DOD_TYPE_BITV2);
         return 'typeBitV2';     // 2-byte varying bits with values of 0 or 1
       when (dataType = DOD_TYPE_BITV4);
         return 'typeBitV4';     // 4-byte varying bits with values of 0 or 1
       when (dataType = DOD_TYPE_GCHAR);
         return 'typeGChar';     // DBCS characters
       when (dataType = DOD_TYPE_GCHARZ);
         return 'typeGCharZ';    // DBCS characters x'00' terminated
       when (dataType = DOD_TYPE_GCHARV2);
         return 'typeGCharV2';   // 2-byte varying DBCS characters
       when (dataType = DOD_TYPE_GCHARV4);
         return 'typeGCharV4';   // 4-byte varying DBCS characters
       other;
         return '*N';
       endsl;

      /end-free
     p                 e

