**free
      // =====================================================================
      //  Unit tests with really long assertion messages.
      // =====================================================================
      //    >>PRE-COMPILER<<
      //      >>CRTCMD<<  RUCRTTST    TSTPGM(&LI/&OB) +
      //                              SRCFILE(&SL/&SF) SRCMBR(&SM);
      //      >>COMPILE<<
      //        >>PARM<< COPTION(*SRCSTMT *EVENTF);
      //        >>PARM<< DBGVIEW(*LIST);
      //      >>END-COMPILE<<
      //      >>EXECUTE<<
      //    >>END-PRE-COMPILER<<
      // =====================================================================

ctl-opt option(*srcstmt);
ctl-opt nomain;

/include RPGUNIT1,TESTCASE

dcl-proc Test_BadCall export;
   dcl-pr bad_pgm extpgm;
   end-pr;
   bad_pgm();
   assert (%status() = 0 : 'Expect status <> 0');
end-proc;
