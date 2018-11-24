 
     H NoMain Option(*SrcStmt)
 
      /copy RPGUNIT1,TESTCASE
 
     DtestError        pr
 
     PtestError        b                   export
     DtestError        pi
     D x               s             10i 0
     D zero            s             10i 0 inz(*zero)
      /free
 
        x = 1 / zero;
 
      /end-free
     PtestError        e
 
