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

     D getParm         pr         16384a   varying
     D                                     extproc('getRealParm_internal_use')
     D  i_value                            const like(OldMsg_t) options(*omit)
     D  i_curLen                     10i 0 const

     D getParm32       pr         32565a   varying
     D                                     extproc('getParm32')
     D  value                     32565a   const options(*varsize)
     D  parm_inf                           const likeds(ceegsi_inf_t)

     D getRealParm_internal_use...
     D                 pr         16384a   varying
     D                                     extproc('getRealParm_internal_use')
     D  i_value                       2a         options(*omit)
     D  i_curLen                     10i 0 const

     D getSentTimeJobLogMsg...
     D                 pr              z
     D                                     extproc('getSentTimeJobLogMsg')
     D  msg                                const likeds(dsOLJL0100EntHdr)

     D getSentTimeMsgQMsg...
     D                 pr              z
     D                                     extproc('getSentTimeMsgQMsg')
     D  msg                                const likeds(dsLSTM0100EntHdr)

     D fixParameterLength...
     D                 pr                  extproc('fixParameterLength')
     D  fc                                 const likeds(fc_t)
     D  length                       10i 0 const
     D  parm_inf                                 likeds(ceegsi_inf_t)

       //----------------------------------------------------------------------
       //   GLOBAL CONSTANTS
       //----------------------------------------------------------------------

     D ASSERT_NO_MSG   c                   'assert() called without message'
     D FAIL_NO_MSG     c                   'fail() called without message'

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
     D  fieldName                    64a   const varying options(*nopass: *omit)

     D p_expected      c                   1
     D p_actual        c                   2
     D p_fieldName     c                   3

     D tExpected       s          32565a   varying
     D tActual         s          32565a   varying
     D msg             s                   like(msgText_t) inz

     D expectedDesc...
     D                 ds                  likeds(ceegsi_inf_t) inz
     D actualDesc...
     D                 ds                  likeds(ceegsi_inf_t) inz
     D fieldNameDesc...
     D                 ds                  likeds(ceegsi_inf_t) inz
     D fc              ds                  likeds(fc_t) inz

      /free

       CEEGSI(p_expected: expectedDesc.dataType
              : expectedDesc.curLen: expectedDesc.maxLen: fc);
       fixParameterLength(fc: %len(expected): expectedDesc);
       tExpected = getParm32(expected: expectedDesc);

       CEEGSI(p_actual: actualDesc.dataType
              : actualDesc.curLen: actualDesc.maxLen: fc);
       fixParameterLength(fc: %len(actual): actualDesc);
       tActual = getParm32(actual: actualDesc);

       if (%parms() >= p_fieldName and %addr(fieldName) <> *NULL);

         CEEGSI(p_fieldName: fieldNameDesc.dataType
                : fieldNameDesc.curLen: fieldNameDesc.maxLen: fc);

         // Check fc for errors and set fieldName_inf.curLen to
         // %len(fieldName) because aEqual() must have been called by old
         // RPG unit tests.
         fixParameterLength(fc: 64: fieldNameDesc);

         msg = %trim(getParm32(fieldName: fieldNameDesc)) + ': ';
       endif;

       msg = msg
           + 'Expected ' + QUOTE + %trimr(tExpected) + QUOTE + ','
           + ' but was ' + QUOTE + %trimr(tActual  ) + QUOTE + '.';
       doAssert(tExpected = tActual: msg: ONE_CALL_STK_LVL_ABOVE: 'aEqual');

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
       doAssert(expected = actual: msg: ONE_CALL_STK_LVL_ABOVE: 'iEqual');

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
       doAssert(expected = actual: msg: ONE_CALL_STK_LVL_ABOVE: 'nEqual');


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

     D msgIfFalseDesc...
     D                 ds                  likeds(ceegsi_inf_t) inz...
     D fc              ds                  likeds(fc_t) inz
      /free

       if (%parms() >= p_msgIfFalse);
         // Called by old RPG or Cobol, because msgIfFalse is present.
         // msgIfFalse became optional when iRPGUnit was enabled for Cobol.

         CEEGSI(p_msgIfFalse: msgIfFalseDesc.dataType
                : msgIfFalseDesc.curLen: msgIfFalseDesc.maxLen: fc);

         // Check fc for errors and set tMsgIfFalse_inf.curLen to
         // %len(msgIfFalse) because assert() must have been called by old
         // RPG unit tests.
         fixParameterLength(fc: %len(msgIfFalse): msgIfFalseDesc);

         doAssert(
           condition: getParm(msgIfFalse: msgIfFalseDesc.curLen)
           : ONE_CALL_STK_LVL_ABOVE: 'assert');
       else;
         // Called by Cobol or new RPG after iRPGUnit v4.
         doAssert(
           condition: getParm(ASSERT_NO_MSG: %len(ASSERT_NO_MSG ))
           : ONE_CALL_STK_LVL_ABOVE: 'assert');
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

     D msgDesc...
     D                 ds                  likeds(ceegsi_inf_t) inz
     D fc              ds                  likeds(fc_t) inz
      /free

       if (%parms() >= p_msg);
         // Called by old RPG or Cobol, because msg is present.
         // msg became optional when iRPGUnit was enabled for Cobol.

         CEEGSI(p_msg: msgDesc.dataType
                : msgDesc.curLen: msgDesc.maxLen: fc);

         // Check fc for errors and set tMsgIfFalse_inf.curLen to
         // %len(msg) because fail() must have been called by old
         // RPG unit tests.
         fixParameterLength(fc: %len(msg): msgDesc);

         doFail(getParm(msg: msgDesc.curLen)
                : TWO_CALL_STK_LVL_ABOVE: 'fail');
       else;
         // Called by Cobol or new RPG after iRPGUnit v4.
         doFail(getParm(FAIL_NO_MSG: %len(FAIL_NO_MSG))
                : TWO_CALL_STK_LVL_ABOVE: 'fail');
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
       // Check fc of CEEGSI and fix parameter length, when procedure
       // was called by old RPG.
       //----------------------------------------------------------------------
     P fixParameterLength...
     P                 b
     D                 pi
     D  fc                                 const likeds(fc_t)
     D  length                       10i 0 const
     D  parm_inf                                 likeds(ceegsi_inf_t)
      /free

       if (fc.msgSev > 0 and fc.msgNo = x'0502'); // Missing operational descriptor.
         parm_inf.dataType = 2;
         parm_inf.curLen = length;
         parm_inf.maxLen = length;
       endif;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Returns the value of a given string depending on the
       // descriptor information.
       //----------------------------------------------------------------------
     P getParm32...
     P                 b
     D                 pi         32565a   varying
     D  value                     32565a   const options(*varsize)
     D  parm_inf                           const likeds(ceegsi_inf_t)
      /free

       if (parm_inf.curLen = 0);
         return '';
       endif;

       return %subst(value: 1: parm_inf.curLen);

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Taken from Scott Klement's HTTPAPI.
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
     P getRealParm_internal_use...
     P                 b                   export
     D                 pi         16384A   varying
     D  i_value                       2a   options(*omit)
     D  i_curLen                     10i 0 const

     D oldStyle        s                   like(OldMsg_t) based(p_value)
     D newStyle        s          16384a         varying based(p_value)
      /free

       if (%addr(i_value) = *null);
         return '*N';
       endif;

       p_value = %addr(i_value);
       if (i_value > x'4000'); // old style or Cobol
         return leftStr(%trim(oldStyle): i_curLen);
       else;
         return %trim(newStyle);
       endif;
      /end-free
     P                 e

