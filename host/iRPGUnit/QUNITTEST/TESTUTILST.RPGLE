      // ==========================================================================
      //  iRPGUnit SelfTest - Test TESTUTILS.
      // ==========================================================================
      //  Copyright (c) 2013-2020 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================
      // >>PRE-COMPILER<<
      //   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM) +
      //                        RPGPPOPT(*LVL2);
      //   >>IMPORTANT<<
      //     >>PARM<<  COPTION(*EVENTF);
      //   >>END-IMPORTANT<<
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

     H NoMain Option(*SrcStmt)

      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D setUpSuite...
     D                 pr                  extproc('setUpSuite')
     D tearDownSuite...
     D                 pr                  extproc('tearDownSuite')

     d addMemberOfType...
     d                 pr
     d                                     extproc('addMemberOfType')
     d  srcType                      10a   const varying

     D test_getFullTimestamp...
     D                 pr                  extproc('test_getFullTimestamp')
     D test_waitSeconds...
     D                 pr                  extproc('test_waitSeconds')
     D test_getMemberType...
     D                 pr                  extproc('test_getMemberType')
     D test_getMemberType_error...
     D                 pr                  extproc('test_getMemberType_error')


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy qinclude,ASSERT
      /copy qinclude,TESTUTILS
      /copy qinclude,TEMPLATES

      /copy qsysinc,QCMDEXC


      //----------------------------------------------------------------------
      //   Private Procedure Prototypes
      //----------------------------------------------------------------------

      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

     D mustDeleteFile  s               n   inz(*off)

      //----------------------------------------------------------------------
      //   Setup/Teardown
      //----------------------------------------------------------------------

     P setUpSuite...
     P                 b                   export
     D                 pi

     D cmd             s            500a   varying
      /free

       mustDeleteFile = *off;

       monitor;
         cmd = 'CRTSRCPF FILE(QTEMP/RPGUNITTST) RCDLEN(112)';
         QCMDEXC( cmd : %len(cmd) );
         mustDeleteFile = *on;
       on-error;
         tearDownSuite();
       endmon;

       addMemberOfType(MBR_RPGLE);
       addMemberOfType(MBR_SQLRPGLE);
       addMemberOfType(MBR_CBLLE);
       addMemberOfType(MBR_SQLCBLLE);

      /free
     P                 e


     P tearDownSuite...
     P                 b                   export
     D                 pi

     D cmd             s            500a   varying
      /free

       monitor;
         cmd = 'DLTF FILE(QTEMP/RPGUNITTST)';
         QCMDEXC( cmd : %len(cmd) );
         mustDeleteFile = *off;
       on-error;
       endmon;

      /free
     P                 e


     p addMemberOfType...
     p                 b
     d                 pi
     d  srcType                      10a   const varying

     d cmd             s            500a   varying
      /free

       cmd = 'ADDPFM FILE(QTEMP/RPGUNITTST) MBR(' + srcType + ') +
                TEXT(''iRPGUnit Test Member'') +
                SRCTYPE(' + srcType + ')';

       QCMDEXC( cmd : %len(cmd) );

      /end-free
     p                 e


      //----------------------------------------------------------------------
      //   Tests
      //----------------------------------------------------------------------

     P test_waitSeconds...
     P                 b                   export
     D                 pi

     D startTime       s               z
     D endTime         s               z
     D lowerBoundary   s               z
     D upperBoundary   s               z
     D mSecsPassed     s             10u 0

     D WAIT_SECONDS    c                   1

      // Tolerance is +/- 0.2 seconds
     D TOLERANCE       c                   200000
      /free

        // Setup.

        startTime = %timestamp();

        // Run.

        waitSeconds(WAIT_SECONDS);

        // Check.

        endTime = %timestamp();

        mSecsPassed = %diff(endTime: startTime: *mseconds);

        lowerBoundary =
          startTime + %seconds(WAIT_SECONDS) - %mseconds(TOLERANCE);

        upperBoundary =
          startTime + %seconds(WAIT_SECONDS) + %mseconds(TOLERANCE);

        assert(endTime > lowerBoundary
               : 'Time passed must be greater than lower boundary.');

        assert(endTime < upperBoundary
               : 'Time passed must be greater than upper boundary.');

      /end-free
     P                 e


     P test_getFullTimestamp...
     P                 b                   export
     D                 pi

     D startTime       s               z
     D timestamp       s               z
     D mSecsAreValid   s               n

     D MAX_SECONDS     c                   5
      /free

        // Setup.

        mSecsAreValid = *off;
        startTime = %timestamp();

        // Run.

        dou (mSecsAreValid or maxTimeReached(startTime: MAX_SECONDS));
          timestamp = %timestamp();
          if (%subdt(timestamp: *mseconds) > 0);
            mSecsAreValid = *on;
          endif;
        enddo;

        // Check.

        assert(mSecsAreValid
               : 'No valid microseconds found in '
                 + %char(MAX_SECONDS) + ' seconds');

      /end-free
     P                 e


     P test_getMemberType...
     P                 b                   export
     D                 pi

     D srcType         s             10a   varying
      /free

       srcType = getMemberType( 'RPGUNITTST' : 'QTEMP' : MBR_RPGLE );
       assert( srcType = MBR_RPGLE : 'getMemberType() must return RPGLE' );

       srcType = getMemberType( 'RPGUNITTST' : 'QTEMP' : MBR_SQLRPGLE );
       assert( srcType = MBR_SQLRPGLE : 'getMemberType() must return SQLRPGLE');

       srcType = getMemberType( 'RPGUNITTST' : 'QTEMP' : MBR_CBLLE );
       assert( srcType = MBR_CBLLE : 'getMemberType() must return CBLLE' );

       srcType = getMemberType( 'RPGUNITTST' : 'QTEMP' : MBR_SQLCBLLE );
       assert( srcType = MBR_SQLCBLLE : 'getMemberType() must return SQLCBLLE');

      /end-free
     P                 e


     P test_getMemberType_error...
     P                 b                   export
     D                 pi

     D srcType         s             10a   varying
      /free

       monitor;
         srcType = getMemberType( 'RPGUNITTST' : 'QTEMP' : 'NOT.FOUND' );
         fail('getMember() should have raised an error');
       on-error;
         // Good, error seen.
       endmon;

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Returns TRUE, when the maximun processing time has been reached.
      //----------------------------------------------------------------------

     P maxTimeReached...
     P                 b
     D                 pi              n
     D  startTime                      z   const
     D  maxSecs                      10u 0 const
      /free

        if (startTime + %seconds(maxSecs) < %timestamp());
          return *on;
        endif;

        return *off;

      /end-free
     P                 e

