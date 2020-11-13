      /if not defined (IRPGUNIT_ASSERT)
      /define IRPGUNIT_ASSERT
      // ==========================================================================
      //  iRPGUnit - Assertion Facilities.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================


      /include qinclude,SDS
      /include qinclude,TESTCASE

       //----------------------------------------------------------------------
       //   Procedure Prototypes of Internal Procedures
       //----------------------------------------------------------------------
     D initialize...
     D                 pr                  extproc('ASSERT_+
     D                                     initialize+
     D                                     ')
     D  sds                                const likeds(sds)

       //----------------------------------------------------------------------
       //   Procedure Prototypes
       //----------------------------------------------------------------------
     D clrAssertFailEvt...
     D                 pr                  extproc('+
     D                                     clrAssertFailEvt+
     D                                     ')

     D getAssertCalled...
     D                 pr            10i 0 extproc('+
     D                                     getAssertCalled+
     D                                     ')

     D getAssertFailEvt...
     D                 pr                  extproc('+
     D                                     getAssertFailEvt+
     D                                     ')
     D                                     likeds(AssertFailEvt_t)

     D getAssertFailEvtLong...
     D                 pr                  extproc('+
     D                                     getAssertFailEvtLong+
     D                                     ')
     D                                     likeds(AssertFailEvtLong_t)

     D clearAssertCounter...
     D                 pr                  extproc('+
     D                                     clearAssertCounter+
     D                                     ')

      /endif

