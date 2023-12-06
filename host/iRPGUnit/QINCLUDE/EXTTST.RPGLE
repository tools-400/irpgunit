      // ==========================================================================
      //  iRPGUnit - Extract Test Cases.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

     D activateTestSuite...
     D                 pr                  extproc('EXTTST_+
     D                                     activateTestSuite+
     D                                     ')
     D  testSuite                          likeds(TestSuite_t)
     D  actMark                            const like(ActMark_t)

     D getTestProc     pr                  likeds(Proc_t)
     D                                     extproc('EXTTST_+
     D                                     getTestProc+
     D                                     ')
     D  testSuite                          const likeds(TestSuite_t)
     D  testIdx                      10i 0 const

     D getTestSuite    pr                  likeds(TestSuite_t)
     D                                     extproc('EXTTST_+
     D                                     getTestSuite+
     D                                     ')
     D  procNmList                         const likeds(ProcNmList_t)

      // Get a test case's name.
     D getTestNm       pr                  extproc('EXTTST_+
     D                                     getTestNm+
     D                                     ')
     D                                     like(ProcNm_t)
     D  testSuite                          const likeds(TestSuite_t)
     D  testIdx                      10i 0 const
