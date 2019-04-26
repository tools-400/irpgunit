      // ==========================================================================
      //  iRPGUnit - Extract Test Cases.
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
      //   Exported Procedures
      //----------------------------------------------------------------------

      /include qinclude,EXTTST

      //---------------f------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /include qinclude,CALLPROC
      /include qinclude,EXTPRC
      /include qinclude,TEMPLATES
      /include qinclude,STRING
      /include qllist,llist_h

     D memset          PR              *          extproc('memset')
     D  i_pDest                        *   value
     D  i_char                       10I 0 value
     D  i_count                      10U 0 value

      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

     D cnt             pr            10i 0 extproc(cnt_p)
     D  procNmListHandle...
     D                                 *   const

     D getNm           pr                  like(ProcNm_t) extproc(getNm_p)
     D  procNmListHandle...
     D                                 *   const

     D getTestCasePtr  pr              *
     D  testSuite                          const likeds(TestSuite_t)
     D  testIdx                      10i 0 const

     D goToNext        pr                  extproc(goToNext_p)
     D  procNmListHandle...
     D                                 *   const

     D isTest          pr              n
     D  nm                                 const like(ProcNm_t)


      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

       // Procedure pointers for ProcNmList_t.
     D cnt_p           s               *   procptr
     D getNm_p         s               *   procptr
     D goToNext_p      s               *   procptr


      //----------------------------------------------------------------------
      //   Procedure Definitions
      //----------------------------------------------------------------------

     P activateTestSuite...
     P                 b                   export
     D                 pi
     D  testSuite                          likeds(TestSuite_t)
     D  actMark                            const like(ActMark_t)

     D testCase        ds                  likeds(Proc_t) based(testCase_p)
     D testCase_p      s               *
     D testIdx         s             10i 0

      /free

        rslvProc( testSuite.setUpSuite : actMark );
        rslvProc( testSuite.setUp      : actMark );

        for testIdx = 1 to testSuite.testCasesCnt;
          testCase_p = getTestCasePtr( testSuite : testIdx );
          rslvProc( testCase : actMark );
        endfor;

        rslvProc( testSuite.tearDown      : actMark );
        rslvProc( testSuite.tearDownSuite : actMark );

      /end-free
     P                 e


     P getTestCasePtr...
     P                 b
     D                 pi              *
     D  testSuite                          const likeds(TestSuite_t)
     D  testIdx                      10i 0 const
      /free

        return testSuite.testList + %size( Proc_t ) * ( testIdx - 1 );

      /end-free
     P                 e


     P getTestNm...
     P                 b                   export
     D                 pi                  like(ProcNm_t)
     D  testSuite                          const likeds(TestSuite_t)
     D  testIdx                      10i 0 const

     D testProc        ds                  likeds(Proc_t)

      /free

        testProc = getTestProc( testSuite : testIdx );
        return testProc.procNm;

      /end-free
     P                 e


     P getTestProc...
     P                 b                   export
     D                 pi                  likeds(Proc_t)
     D  testSuite                          const likeds(TestSuite_t)
     D  testIdx                      10i 0 const

     D testCase        ds                  likeds(Proc_t) based(testCase_p)
     D testCase_p      s               *

      /free

        testCase_p = getTestCasePtr( testSuite : testIdx );
        return testCase;

      /end-free
     P                 e


     P getTestSuite...
     P                 b                   export
     D                 pi                  likeds(TestSuite_t)
     D  procNmList                         const likeds(ProcNmList_t)

     D testSuite       ds                  likeds(TestSuite_t)
     D testCase        ds                  likeds(Proc_t)
     D                                     based(testCase_p)
     D testCase_p      s               *

     D privateData     s               *   based(procNmList.handle)
     D procCnt         s             10i 0
     D procIdx         s             10i 0
     D procNm          s                   like(ProcNm_t)

      /free

        cnt_p      = procNmList.cnt;
        getNm_p    = procNmList.getNm;
        goToNext_p = procNmList.goToNext;

        procCnt = cnt( privateData );

        clear testSuite;
        testSuite.testList = %alloc( procCnt * %size( Proc_t ) );
        memset(testSuite.testList : x'00' : procCnt * %size( Proc_t ));
        testSuite.testResults = list_create();

        for procIdx = 1 to procCnt;
          procNm = getNm( privateData );
          select;
            when isTest( procNm );
              testSuite.testCasesCnt += 1;
              testCase_p = getTestCasePtr( testSuite :
                                           testSuite.testCasesCnt );
              clear testCase;
              testCase.procNm = procNm;
            when uCase(procNm) = 'SETUPSUITE';
              testSuite.setUpSuite.procNm = procNm;
            when uCase(procNm) = 'SETUP';
              testSuite.setUp.procNm = procNm;
            when uCase(procNm) = 'TEARDOWN';
              testSuite.tearDown.procNm = procNm;
            when uCase(procNm) = 'TEARDOWNSUITE';
              testSuite.tearDownSuite.procNm = procNm;
          endsl;
          goToNext( privateData );
        endfor;

        return testSuite;

      /end-free
     P                 e


     P isTest...
     P                 b
     D                 pi              n
     D  nm                                 const like(ProcNm_t)

     D nmPrefix        s                   like(ProcNm_t)

      /free

        return startsWith(TEST_PREFIX: nm);

      /end-free
     P isTest          e

