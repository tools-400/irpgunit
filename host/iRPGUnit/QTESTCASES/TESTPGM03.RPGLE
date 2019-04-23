
     h NoMain Option(*SrcStmt: *NoDebugIo)

      /include qsrc,TESTCASE

     DtestFalse        pr
     DtestFalse2       pr

     PtestFalse        b                   export
     D                 pi
      /free

        iEqual(5: 2+2);

      /end-free
     P                 e

     PtestFalse2       b                   export
     D                 pi
      /free

        iEqual(6: 2+2);

      /end-free
     P                 e

