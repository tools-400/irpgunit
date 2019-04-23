
      //------------------------------------------------------------------------
      //
      //    Test Assertion on Big Integer.
      //
      //------------------------------------------------------------------------

     H NoMain Option(*SrcStmt: *NoDebugIo)

      /include qsrc,TESTCASE

     Dtest_Equal       pr
     Dtest_Different   pr

     Ptest_Equal       b                   export
     Dtest_Equal       pi
      /free
             // 0000000001111111111222222222233
        iEqual( 1234567890123456789012345678901 :
                1234567890123456789012345678901 );
      /end-free
     Ptest_Equal       e

     Ptest_Different   b                   export
     Dtest_Different   pi
      /free
             // 0000000001111111111222222222233
        iEqual( 1234567890123456789012345678901 :
                1234567890123456789012345678900 );
      /end-free
     Ptest_Different   e

