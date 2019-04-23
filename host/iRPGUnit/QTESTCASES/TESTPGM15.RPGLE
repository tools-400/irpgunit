
     h NoMain Option(*SrcStmt: *NoDebugIo)

      /include qsrc,TESTCASE

     DtestTrue         pr
     DtestTrue2        pr

     PtestTrue         b                   export
     DtestTrue         pi
      /free

        iEqual(4: 2+2);

      /end-free
     PtestTrue         e

     PtestTrue2        b                   export
     DtestTrue2        pi
      /free

        iEqual(2: 1+1);
        iEqual(4: 2+2);

      /end-free
     PtestTrue2        e

