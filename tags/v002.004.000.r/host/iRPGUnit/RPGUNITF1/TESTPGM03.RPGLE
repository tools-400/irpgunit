 
     h NoMain Option(*SrcStmt)
 
      /copy RPGUNIT1,TESTCASE
 
     DtestFalse        pr
     DtestFalse2       pr
 
     PtestFalse        b                   export
     DtestFalse        pi
      /free
 
        iEqual(5: 2+2);
 
      /end-free
     PtestFalse        e
 
     PtestFalse2       b                   export
     DtestFalse2       pi
      /free
 
        iEqual(6: 2+2);
 
      /end-free
     PtestFalse2       e
 
