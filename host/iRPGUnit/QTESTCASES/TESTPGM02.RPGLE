
     h NoMain Option(*SrcStmt: *NoDebugIo)

      /include qsrc,TESTCASE

     DtestTrue         pr

     PtestTrue         b                   export
     DtestTrue         pi
      /free

        iEqual(4: 2+2);

      /end-free
     PtestTrue         e

