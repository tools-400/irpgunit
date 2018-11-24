 
     H NoMain Option(*SrcStmt)
 
      /copy RPGUNIT1,TESTCASE
 
     Dtest             pr
     Dteardown         pr
 
     Ptest             b                   export
     Dtest             pi
     Ptest             e
 
     Pteardown         b                   export
     Dteardown         pi
     D x               s             10i 0
     D zero            s             10i 0 inz(*zero)
      /free
 
        x = 1 / zero;
 
      /end-free
     Pteardown         e
