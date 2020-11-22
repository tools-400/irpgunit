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
      //   >>CRTCMD<<  RUCRTTST TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM) +
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

     D test_getFullTimestamp...
     D                 pr                  extproc('test_getFullTimestamp')


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy qinclude,ASSERT
      /copy qinclude,TESTUTILS
      /copy qinclude,TEMPLATES


      //----------------------------------------------------------------------
      //   Private Procedure Prototypes
      //----------------------------------------------------------------------

      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

      //----------------------------------------------------------------------
      //   Tests
      //----------------------------------------------------------------------

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

