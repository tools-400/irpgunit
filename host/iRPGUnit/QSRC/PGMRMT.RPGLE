      // ==========================================================================
      //  iRPGUnit - Plug-in Test Runner.
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

      /include qinclude,H_SPEC
      /include qinclude,COPYRIGHT

      /include qinclude,PGMRMT

      *-------------------------------------------------------------------------
      * PEP
      *-------------------------------------------------------------------------

     D PGMRMT...
     D                 PI
     D  returnValue                  10I 0
     D  userspace                          const  likeds(object_t )
     D  testSuiteName                      const  likeds(object_t )
     D  procNames                          const  likeds(ProcNms_t)
     D  order                              const  like(order_t    )
     D  detail                             const  like(detail_t   )
     D  output                             const  like(output_t   )
     D  libl                               const  likeDs(libL_t   )
     D  qJobD                              const  likeDs(Object_t )
     D  rclrsc                             const  like(rclrsc_t   )

      *-------------------------------------------------------------------------
      * Prototypen
      *-------------------------------------------------------------------------
      /include qinclude,RMTRUNSRV
      /include qinclude,TEMPLATES

        returnValue =
            rpgunit_runTestSuite(
               userspace: testSuiteName: procNames:
               order :detail: output: libl: qJobD: rclrsc);
        *inlr = *on;
