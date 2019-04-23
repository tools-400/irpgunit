
     h NoMain Option(*SrcStmt: *NoDebugIo)

      /include qsrc,TESTCASE

     Dtest1            pr
     Dtest2            pr
     Dnot_a_test       pr

     Ptest1            b                   export
     Dtest1            pi
     Ptest1            e

     Ptest2            b                   export
     Dtest2            pi
     Ptest2            e

     Pnot_a_test       b                   export
     Dnot_a_test       pi
      /free

        fail('not_a_test should not be called.');

      /end-free
     Pnot_a_test       e

