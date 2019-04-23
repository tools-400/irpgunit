
     H NoMain Option(*SrcStmt: *NoDebugIo)

      /include qsrc,TESTCASE

     D failingProc     pr
     D testStack       pr

     P failingProc     b
     D                 pi
      /free

        iEqual(5:2+2);

      /end-free
     P                 e

     P testStack       b                   export
     D                 pi
      /free

        failingProc();

      /end-free
     P                 e

