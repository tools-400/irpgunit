      // ==========================================================================
      //  iRPGUnit SelfTest - Test Message Queue.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================
      // >>PRE-COMPILER<<
      //   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM) +
      //                 COPTION(*EVENTF);
      //   >>IMPORTANT<<
      //     >>PARM<<  MODULE(&LI/JOBLOG +
      //                      &LI/PGMMSG );
      //     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
      //   >>END-IMPORTANT<<
      //   >>CMD<<     CMPMOD MODULE(&LI/JOBLOG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

     H NoMain Option(*SrcStmt)

      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D setUp...
     D                 pr                  extproc('setUp')
     D tearDown...
     D                 pr                  extproc('tearDown')
     D testNoMsgInMessageQueue...
     D                 pr                  extproc('testNoMsgInMessageQueue')
     D testMsgInMessageQueue...
     D                 pr                  extproc('testMsgInMessageQueue')
     D testMsgTooOldInMessageQueue...
     D                 pr                  extproc('+
     D                                     testMsgTooOldInMessageQueue')
     D testSpecialValueEmpty...
     D                 pr                  extproc('testSpecialValueEmpty')


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy qinclude,ASSERT
      /copy qinclude,PGMMSG
      /copy qinclude,TESTUTILS
      /copy qinclude,TEMPLATES


      //----------------------------------------------------------------------
      //   Private Procedure Prototypes
      //----------------------------------------------------------------------

     D sndQueueMsg...
     D                 pr                  extproc('sndQueueMsg')
     D  queueNm                      10a   const
     D  queueLb                      10a   const
     D  text                        256a   const varying


      //----------------------------------------------------------------------
      //   Global Constants
      //----------------------------------------------------------------------

     D MSG_QUEUE_QNM   c                   'QTEMP/MSGQT'
     D MSG_QUEUE_NM    c                   'MSGQT'
     D MSG_QUEUE_LB    c                   'QTEMP'


      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

     D testStartTime   s               z
     D assertCntBefore...
     D                 s             10i 0
     D assertCntAfter  s             10i 0


      //----------------------------------------------------------------------
      //   Tests
      //----------------------------------------------------------------------

     P setUp           b                   export
     D                 pi
      /free

        testStartTime = getFullTimeStamp();
        clear assertCntBefore;
        clear assertCntAfter;

        monitor;
          runCmd('DLTMSGQ MSGQ(' + MSG_QUEUE_QNM + ')');
        on-error;
          // Ignore errors
        endmon;

        runCmd('CRTMSGQ MSGQ(' + MSG_QUEUE_QNM + ') +
                TEXT(''IRPGUnit SelfTest - Tet Message Queue.'')');

      /end-free
     P                 e


     P tearDown        b                   export
     D                 pi
      /free

        runCmd('DLTMSGQ MSGQ(' + MSG_QUEUE_QNM + ')');

      /end-free
     P                 e


     P testNoMsgInMessageQueue...
     P                 b                   export
     D                 pi

     D assertFailEvt   ds                  likeds(AssertFailEvt_t)

      /free

        // Setup.

        assertCntBefore = getAssertCalled();

        // Run.

        monitor;
          assertMessageQueueContains( MSG_QUEUE_NM : MSG_QUEUE_LB :
            *omit : 'MSGQUEUET*' : *omit : testStartTime );
          fail('assertMessageQueueContains(...) should have raised a failure.');
        on-error;
          // Exception message, as expected.
          assertFailEvt  = getAssertFailEvt();
          assertCntAfter = getAssertCalled();
        endmon;

        // Check.

        iEqual( assertCntBefore + 1 : assertCntAfter );
        aEqual( 'Message not found in message queue.' :
                assertFailEvt.msg );

        assertMessageQueueContains( MSG_QUEUE_NM : MSG_QUEUE_LB :
          '*EMPTY' : *omit : *omit : testStartTime );

      /end-free
     P                 e


     P testMsgInMessageQueue...
     P                 b                   export
     D                 pi
      /free

        // Setup.

        sndQueueMsg(MSG_QUEUE_NM : MSG_QUEUE_LB : 'MSGQT - iRPGUnit' + '.1' );
        assertCntBefore = getAssertCalled();

        sndQueueMsg(MSG_QUEUE_NM : MSG_QUEUE_LB : 'MSGQT - iRPGUnit' + '.2' );
        assertCntBefore = getAssertCalled();

        sndQueueMsg(MSG_QUEUE_NM : MSG_QUEUE_LB : 'MSGQT - iRPGUnit' + '.3' );
        assertCntBefore = getAssertCalled();

        // Run.

        // exact match
        assertMessageQueueContains( MSG_QUEUE_NM : MSG_QUEUE_LB :
          *omit : 'MSGQT - iRPGUnit.1' : *omit : testStartTime );

        // any message starting with 'MSGQT'
        assertMessageQueueContains( MSG_QUEUE_NM : MSG_QUEUE_LB :
          *omit : 'MSGQT*' : *omit : testStartTime );

        // any message starting containing 'iRPGUnit'
        assertMessageQueueContains( MSG_QUEUE_NM : MSG_QUEUE_LB :
          *omit : '*iRPGUnit*' : *omit : testStartTime );

        // message ending with '.2'
        assertMessageQueueContains( MSG_QUEUE_NM : MSG_QUEUE_LB :
          *omit : '*.2' : *omit : testStartTime );

        // Check.

        assertCntAfter = getAssertCalled();
        iEqual( assertCntBefore + 4 : assertCntAfter );

      /end-free
     P                 e


     P testMsgTooOldInMessageQueue...
     P                 b                   export
     D                 pi

     D assertFailEvt   ds                  likeds(AssertFailEvt_t)
      /free

        // Setup.

        sndQueueMsg(MSG_QUEUE_NM : MSG_QUEUE_LB : 'MSGQT - iRPGUnit - too old');

        // Ensure message is in queue
        assertMessageQueueContains( MSG_QUEUE_NM : MSG_QUEUE_LB :
          *omit : 'MSGQT - iRPGUnit - too old' : *omit : testStartTime );

        // Set new start time
        testStartTime = getFullTimeStamp();

        // Add a valid message
        sndQueueMsg(MSG_QUEUE_NM : MSG_QUEUE_LB : 'MSGQT - iRPGUnit - new');

        assertCntBefore = getAssertCalled();

        // Run.

        assertMessageQueueContains( MSG_QUEUE_NM : MSG_QUEUE_LB :
          *omit : 'MSGQT - iRPGUnit - new' : *omit : testStartTime );

        monitor;
          assertMessageQueueContains( MSG_QUEUE_NM : MSG_QUEUE_LB :
            *omit : 'MSGQT - iRPGUnit - too old' : *omit : testStartTime );
          fail('testMsgTooOldInMessageQueue(..) should have raised a failure.');
        on-error;
          // Exception message, as expected.
          assertFailEvt  = getAssertFailEvt();
          assertCntAfter = getAssertCalled();
        endmon;

        // Check.

        iEqual( assertCntBefore + 2 : assertCntAfter );
        aEqual( 'Message not found in message queue.' :
                assertFailEvt.msg );

      /end-free
     P                 e


     P testSpecialValueEmpty...
     P                 b                   export
     D                 pi

     D assertFailEvt   ds                  likeds(AssertFailEvt_t)
     D msgInfo         ds                  likeds(MsgInfo_t)
      /free

        // Setup.

        assertCntBefore = getAssertCalled();
        setLowMessageKey(getHighestMsgKey());

        // Run.

        monitor;
          assertMessageQueueContains( MSG_QUEUE_NM : MSG_QUEUE_LB :
            '*EMPTY' : 'MSGQUEUET*' : *omit : testStartTime );
          fail('Other parameters must be omitted when msgId = *EMPTY');
        on-error;
          // Exception message, as expected.
          assertFailEvt  = getAssertFailEvt();
          assertCntAfter = getAssertCalled();
          msgInfo = getMonitoredMessage();
        endmon;

        // Check.

        iEqual( assertCntBefore : assertCntAfter );
        aEqual( '' : assertFailEvt.msg );
        aEqual( 'All other selection parameters must +
                 be omitted, when msgId is set to ''*EMPTY''' : msgInfo.txt);

        assertMessageQueueContains( MSG_QUEUE_NM : MSG_QUEUE_LB :
          '*EMPTY' : *omit : *omit : testStartTime );

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Private Helper Procedures
      //----------------------------------------------------------------------

     P sndQueueMsg     b
     D                 pi
     D  queueNm                      10a   const
     D  queueLb                      10a   const
     D  text                        256a   const varying

     D cmd             s           1024a   varying
      /free

        cmd = 'SNDMSG MSG(''' + %trim(text) + ''') +
                 TOMSGQ(' + %trim(queueLb) + '/' + %trim(queueNm) + ') +
                 MSGTYPE(*INFO)';

        runCmd(cmd);

      /end-free
     P                 e
