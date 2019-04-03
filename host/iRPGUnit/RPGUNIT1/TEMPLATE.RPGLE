      *=====================================================================*
      *  Empty Unit Test Case. Prints a protocol of the execution flow.     *
      *=====================================================================*
      *  Command to create the service program:                             *
      *  RUCRTTST TSTPGM(RPGUNIT/TEMPLATE) SRCFILE(RPGUNIT/RPGUNIT1)        *
      *=====================================================================*
      *  Tools/400 STRPREPRC instructions:                                  *
      *   >>PRE-COMPILER<<                                                  *
      *     >>CRTCMD<<  RUCRTTST    TSTPGM(&LI/&OB) +                       *
      *                             SRCFILE(&SL/&SF) +                      *
      *                             SRCMBR(&SM);                            *
      *     >>COMPILE<<                                                     *
      *       >>PARM<< COPTION(*EVENTF);                                    *
      *       >>PARM<< DBGVIEW(*LIST);                                      *
      *       >>PARM<< BNDDIR(*N);                                          *
      *     >>END-COMPILE<<                                                 *
      *     >>EXECUTE<<                                                     *
      *   >>END-PRE-COMPILER<<                                              *
      *=====================================================================*
      *  Compile options:                                                   *
      *    *SrcStmt       - Assign SEU line numbers when compiling the      *
      *                     source member. This option is required to       *
      *                     position the LPEX editor to the line in error   *
      *                     when the source member is opened from the       *
      *                     RPGUnit view.                                   *
      *    *NoDebugIO     - Do not generate breakpoints for input and       *
      *                     output specifications. Optional but useful.     *
      *=====================================================================*
     H NoMain Option(*SrcStmt : *NoDebugIO)
     FQSYSPRT   O    F   80        printer usropn oflind(*in70)

      /copy RPGUNIT1,TESTCASE                     RPGUnit

     D sds            sds                  qualified
     D  pgmName                1     10a
     D  pgmLib                81     90a

     D openPrinter...
     D                 pr                  extproc('openPrinter')

     D print...
     D                 pr                  extproc('print')
     D  text                        128a   value  varying options(*nopass)

     D closePrinter...
     D                 pr                  extproc('closePrinter')

     D setUpSuite...
     D                 pr                  extproc('setUpSuite')

     D tearDownSuite...
     D                 pr                  extproc('tearDownSuite')

     D setUp...
     D                 pr                  extproc('setUp')

     D tearDown...
     D                 pr                  extproc('tearDown')

     D testWhatever_1...
     D                 pr                  extproc('+
     D                                     testWhatever_1+
     D                                     ')

     D testWhatever_2...
     D                 pr                  extproc('+
     D                                     testWhatever_2+
     D                                     ')

      // ============================================================
      //  Opens the printer.
      // ============================================================
     P openPrinter...
     P                 b                   export
     D                 pi
      /free

         open QSYSPRT;

      /end-free
     P                 e

      // ============================================================
      //  Prints a message.
      // ============================================================
     P print...
     P                 b                   export
     D                 pi
     D  text                        128a   value  varying options(*nopass)

     D lineOutput      DS            80    inz
      /free

         if (%parms() >= 1);
            lineOutput = text;
         else;
            lineOutput = '';
         endif;
         write QSYSPRT lineOutput;

      /end-free
     P                 e

      // ============================================================
      //  Closes the printer.
      // ============================================================
     P closePrinter...
     P                 b                   export
     D                 pi
      /free

         if (%open(QSYSPRT));
            close QSYSPRT;
         endif;

      /end-free
     P                 e

      // ============================================================
      //  Set up test suite. Executed once per RUCALLTST.
      // ============================================================
     P setUpSuite...
     P                 b                   export
     D                 pi

     D rc              S              1A
      /free

         runCmd('OVRPRTF FILE(QSYSPRT) TOFILE(*FILE) +
                 SPLFNAME(PROC_FLOW) OVRSCOPE(*JOB)');
         monitor;
            openPrinter();
            print('Executing:   setUpSuite()');
         on-error;
            // ignore errors ...
         endmon;

         // ... but try to remove the override.
         monitor;
            runCmd('DLTOVR FILE(QSYSPRT) LVL(*JOB)');
         on-error;
            dsply '*** Failed to delete QSYSPRT override! ***' rc;
         endmon;

      /end-free
     P                 e

      // ============================================================
      //  Tear down test suite.
      // ============================================================
     P tearDownSuite...
     P                 b                   export
     D                 pi
      /free

         print('Executing:   tearDownSuite()');
         closePrinter();

      /end-free
     P                 e

      // ============================================================
      //  Set up test case.
      // ============================================================
     P setUp...
     P                 b                   export
     D                 pi
      /free

         print('Executing:   - setUp()');

      /end-free
     P                 e

      // ============================================================
      //  Tear down test case.
      // ============================================================
     P tearDown...
     P                 b                   export
     D                 pi
      /free

         print('Executing:   - tearDown()');

      /end-free
     P                 e

      // ============================================================
      //  RPGUnit test case.
      // ============================================================
     P testWhatever_1...
     P                 b                   export
     D                 pi
      /free

         print('Executing:       * testWhatever_1()');

         // Place your assertions here.

      /end-free
     P                 e

      // ============================================================
      //  RPGUnit test case.
      // ============================================================
     P testWhatever_2...
     P                 b                   export
     D                 pi
      /free

         print('Executing:       * testWhatever_2()');

         // Place your assertions here.

      /end-free
     P                 e
