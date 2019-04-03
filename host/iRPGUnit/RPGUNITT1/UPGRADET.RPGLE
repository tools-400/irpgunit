      //
      // Unit Tests for Upgrading to iRPGUnit 2.0
      //

     h nomain option(*srcstmt)


      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     d testAssertSuccess...
     d                 pr
     d testAssertFailure...
     d                 pr
     d testAEqualSuccess...
     d                 pr
     d testAEqualFailure...
     d                 pr
     d testIEqualSuccess...
     d                 pr
     d testIEqualFailure...
     d                 pr
     d testFail...
     d                 pr


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNIT1,TESTCASE


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------


     d theFailingProcdure...
     d                 pr                  extproc('theFailingProcdure')

     d kill...
     d                 pr                  extproc('kill')
     d  msg                         100a   const varying


      //----------------------------------------------------------------------
      //   Tests
      //----------------------------------------------------------------------


     p testAssertSuccess...
     p                 b                   export
     d                 pi
      /free

        monitor;
           assert( 1 = 1 : '1 is equal to 1');
        on-error;
           kill('testAssertSuccess() has seen a false exception');
        endmon;

      /end-free
     P                 e


     p testAssertFailure...
     p                 b                   export
     d                 pi
      /free

        monitor;
           assert( 1 = 5 : '1 is not equal to 5');
           kill('testAssertFailure() has not seen the exception');
        on-error;
           // Error expected!
        endmon;

      /end-free
     P                 e


     p testAEqualSuccess...
     p                 b                   export
     d                 pi
      /free

        monitor;
           aEqual( 'RPGUNIT' : 'RPGUNIT' );
        on-error;
           kill('testAEqualSuccess() has seen a false exception');
        endmon;

      /end-free
     P                 e


     p testAEqualFailure...
     p                 b                   export
     d                 pi
      /free

        monitor;
           aEqual( 'RPGUNIT' : 'iRPGUNIT' );
           kill('testAEqualFailure() has not seen the exception');
        on-error;
           // Error expected!
        endmon;

      /end-free
     P                 e


     p testIEqualSuccess...
     p                 b                   export
     d                 pi
      /free

        monitor;
           iEqual( 123 : 123 );
        on-error;
           kill('testIEqualSuccess() has seen a false exception');
        endmon;

      /end-free
     P                 e


     p testIEqualFailure...
     p                 b                   export
     d                 pi
      /free

        monitor;
           iEqual( 123 : 456 );
           kill('testIEqualFailure() has not seen the exception');
        on-error;
           // Error expected!
        endmon;

      /end-free
     P                 e


     p testFail...
     p                 b                   export
     d                 pi
      /free

        monitor;
           theFailingProcdure();
           kill('fail() did not terminate the test case');
        on-error;
           // Success!
        endmon;

      /end-free
     P                 e


     p theFailingProcdure...
     p                 b                   export
     d                 pi
      /free

        monitor;
           fail( 'fail() cannot be monitored' );
           kill('fail() did send an *ESCAPE message');
        on-error;
           kill('fail() incorrectly monitored');
        endmon;

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Private Helper Procedures
      //----------------------------------------------------------------------

     p kill...
     p                 b
     d                 pi
     d  msg                         100a   const varying

     d msgKey          s              4A                        inz

     d qMsgF           ds                  qualified            inz
     d  name                         10A
     d  lib                          10A

     d errCode         ds                  qualified            inz
     d  bytPrv                       10I 0
     d  bytAvl                       10I 0
     d  excID                         7A
     d  reserved                      1A
     d  excDta                      256A

?     // Send Program Message (QMHSNDPM) API
     d QMHSNDPM        pr                         extpgm('QMHSNDPM')
     d   i_msgID                      7A   const
     d   i_qMsgF                     20A   const
     d   i_msgData                32767A   const  options(*varsize )
     d   i_length                    10I 0 const
     d   i_msgType                   10A   const
     d   i_callStkE               32767A   const  options(*varsize )
     d   i_callStkC                  10I 0 const
     d   o_msgKey                     4A
     d   io_ErrCode               32767A          options(*varsize )
     d   i_lenStkE                   10I 0 const  options(*nopass  )
     d   i_callStkEQ                 20A   const  options(*nopass  )
     d   i_wait                      10I 0 const  options(*nopass  )
     d   i_callStkEDT                10A   const  options(*nopass  )
     d   i_ccsid                     10I 0 const  options(*nopass  )
      /free

         clear qMsgF;
         qMsgF.name = 'QCPFMSG';
         qMsgF.lib  = '*LIBL';

         clear errCode;
         errCode.bytPrv = %size(errCode);

         QMHSNDPM('CPF9898': qMsgF: msg: %len(msg): '*ESCAPE'
                  : '*CTLBDY': 1: msgKey: errCode);

      /end-free
     p                 e
