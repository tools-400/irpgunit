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
      /include qinclude,SYSTEMAPI

      //----------------------------------------------------------------------
      //   PRIVATE PROTOTYPES
      //----------------------------------------------------------------------

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
     D  i_value                       2a   const
     D getRealParm_internal_use...
     D                 pr         16384a   varying
     D                                     extproc('getRealParm_internal_use')
     D  i_value                       2a

      //----------------------------------------------------------------------
      //   GLOBAL VARIABLES
      //----------------------------------------------------------------------

      // Number of assertions called.
     D assertCalled    s             10i 0

      // Latest assertion failure event information. Can be blank if no
      //  assertion failure event since last assertion.
     D assertFailEvt   ds                  likeds(AssertFailEvtLong_t)

      //----------------------------------------------------------------------
      // Assert equality between two alphanumeric variables.
      //----------------------------------------------------------------------
     P aEqual...
     P                 b                   export
     D                 pi
     D  expected                  32565a   const
     D  actual                    32565a   const
     D  fieldName                    64a   const varying options(*nopass: *omit)

     D msg             s                   like(msgText_t) inz

      /free

        if (%parms() >= 3 and %addr(fieldName) <> *NULL);
           msg = %trim(fieldName) + ': ';
        endif;

        msg = msg
            + 'Expected ' + QUOTE + %trimr(expected) + QUOTE + ','
            + ' but was ' + QUOTE + %trimr(actual  ) + QUOTE + '.';
        doAssert(expected = actual: msg: ONE_CALL_STK_LVL_ABOVE: 'aEqual');

      /end-free
     P                 e


      //----------------------------------------------------------------------
      // Assert equality between two integers.
      //----------------------------------------------------------------------
     P iEqual...
     P                 b                   export
     D                 pi
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
     D                 pi
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
      // Asserts that a condition is true. See prototype.
      //----------------------------------------------------------------------
     P assert...
     P                 b                   export
     D                 pi
     D  condition                      n   const
     D  msgIfFalse                  256a   const
      /free

        doAssert(
           condition: getParm(msgIfFalse): ONE_CALL_STK_LVL_ABOVE: 'assert');

      /end-free
     P                 e


      //----------------------------------------------------------------------
      // Signals a test failure and stops the test.
      //----------------------------------------------------------------------
     P fail...
     P                 b                   export
     d                 pi
     D  msg                         256a   const
      /free

        doFail(getParm(msg): TWO_CALL_STK_LVL_ABOVE: 'fail');

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


     P assertJobLogContains...
     P                 b                   export
     D                 pi
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
                  FULL_SYNCHRONOUS_BUILD :
                  fldSelect :
                  %size( fldSelect ) :
                  percolateErrors );

        p_msgBasicInfo = %addr( jobLogList );
        msgIdx = 1;

        dow 1=1;
          if msgIdx > listInfo.retRcdCnt;
            sndEscapeMsgToCaller( 'Insufficient implementation. ' +
                  'Should use QGYGTLE to retrieve records after ' +
                               %char( listInfo.retRcdCnt ) + '. ' +
                                          'Please open an issue.' );
          endif;

          sentTimeStamp = getSentTimeStamp( msgBasicInfo );

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

           if (ent.pgmNm = 'RUCALLTST');
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
           if (callStkE.sender.procNm = startProc);
              doReturnStckE = *on;
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
     D  i_value                       2a

     D oldStyle        s            256a   based(p_value)
     D newStyle        s          16384a   varying based(p_value)

       p_value = %addr(i_value);
       if (i_value > x'4000');
         return %trim(oldStyle);
       else;
         return %trim(newStyle);
       endif;
     P                 e


     P getSentTimeStamp...
     P                 b
     D                 pi              z
     D  msg                                const likeds(dsOLJL0100EntHdr)

     D sentDateAsIso   s              8a

        sentDateAsIso = %char( %date( msg.sentDate : *cymd0) : *iso0 );
        return %timestamp( sentDateAsIso +
                           msg.sentTime +
                           msg.microseconds :
                           *iso0 );
     P                 e
