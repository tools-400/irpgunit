 
     H NoMain Option(*SrcStmt)
 
      /copy RPGUNIT1,TESTCASE
 
     DfailingProc      pr
     DtestStack        pr
 
     PfailingProc      b
     DfailingProc      pi
      /free
 
        iEqual(5:2+2);
 
      /end-free
     PfailingProc      e
 
     PtestStack        b                   export
     DtestStack        pi
      /free
 
        failingProc();
 
      /end-free
     PtestStack        e
 
