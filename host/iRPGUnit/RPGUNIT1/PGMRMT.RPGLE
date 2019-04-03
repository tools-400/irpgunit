     /**
      * \brief Run Remote Unit Test
      *
      * This program executes the passed unit test. For execution the
      * unit test service programs must be in the library list.
      *
      * \author Mihael Schmidt, Thomas Raddatz
      * \date   19.10.2010
      */

      *DftActGrp(*No) ActGrp(*new) BndDir('MY_BND_DIR')
      /copy RPGUNITY1,COPYRIGHT

      /copy RPGUNITY1,PGMRMT

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
      /copy RPGUNITY1,RMTRUNSRV

      /copy RPGUNITY1,TEMPLATES
      /free

         returnValue =
            rpgunit_runTestSuite(
               userspace: testSuiteName: procNames:
               order :detail: output: libl: qJobD: rclrsc);

         *inlr = *on;

         return;

      /end-free
