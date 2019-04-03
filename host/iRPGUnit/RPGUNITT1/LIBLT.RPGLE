      // =====================================================================
      //
      // Unit tests for LIBL.
      //
      // =====================================================================
      //   >>PRE-COMPILER<<
      //     >>CMD<<    CRTBNDCL   PGM(QTEMP/MKLIBLT) SRCFILE(&SF);
      //     >>CMD<<    CALL       PGM(QTEMP/MKLIBLT) PARM(&LI);
      //   >>END-PRE-COMPILER<<
      // =====================================================================

     H NoMain Option(*SrcStmt) BndDir('QC2LE')


      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D setUpSuite...
     D                 pr                  extproc('setUpSuite')
     D tearDownSuite...
     D                 pr                  extproc('tearDownSuite')
     D testGetLibl...
     D                 pr                  extproc('testGetLibl')
     D testLoadLibl...
     D                 pr                  extproc('testLoadLibl')
     D testRestoreLibl...
     D                 pr                  extproc('testRestoreLibl')


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNIT1,TESTCASE
      /copy RPGUNITY1,ASSERT
      /copy RPGUNITY1,LIBL
      /copy RPGUNITY1,TEMPLATES

     D LIBLC           pr                  extproc('LIBLC')
     D  curLib                       10a
     D  usrLibl                    2750a

     D system          PR            10I 0 extproc('system')
     D  i_clCommand                    *   value options(*string)

     D EXCP_MSGID      S              7A   import('_EXCP_MSGID')


      //----------------------------------------------------------------------
      //   Private Procedure Prototypes
      //----------------------------------------------------------------------

      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

     D expected        ds                  qualified
     D  curLib                 1     10a
     D  usrLibl               11   2760a   dim(250)
     D  usrLiblArray          11   2760a

      //----------------------------------------------------------------------
      //   Set up & Tear down
      //----------------------------------------------------------------------

     P setUpSuite      b                   export
     D                 pi
      /free

         system('DLTJOBD JOBD(QTEMP/RPGUNITT)');
         system('CRTJOBD JOBD(QTEMP/RPGUNITT) INLLIBL(QGPL QTEMP)');

         callp LIBLC(expected.curLib: expected.usrLiblArray);

      /end-free
     P                 e


     P tearDownSuite   b                   export
     D                 pi
      /free

         system('DLTJOBD JOBD(QTEMP/RPGUNITT)');

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Tests
      //----------------------------------------------------------------------

     P testGetLibl...
     P                 b                   export
     D                 pi

     D liblData        ds                  likeds(LiblData_t)
     D i               s             10i 0
     D prvLib          s             11a   inz
     D numLibs         s             10i 0 inz
      /free

        // Setup.


        // Run.

        liblData = getLibl();

        // Check.

        assert(liblData.libL.numE > 0:
           'Number of libraries shoud be greater than 0');

        for i = 1 to liblData.libL.numE;
           assert(liblData.libL.lib(i) = expected.usrLibl(i):
              'Library list entry ' + %char(i) +
              ' does not match expected value');
           if (i > 1);
              assert(prvLib <> liblData.libL.lib(i):
                 'Previous library list entry must not match current entry');
           endif;
           prvLib = liblData.libL.lib(i);
        endfor;

        for i = liblData.libL.numE + 1 to MAX_NUM_LIB;
           assert(liblData.libL.lib(i) = '':
              'Library list entry ' + %char(i) + ' should be empty');
        endfor;

        assert(liblData.curLib = expected.curLib:
           'Current library ' + %char(i) + ' does not match expected value');

      /end-free
     P                 e


     P testLoadLibl...
     P                 b                   export
     D                 pi

     D qJobD           ds                  likeds(Object_t)
     D liblData        ds                  likeds(LiblData_t)
      /free

        // Setup.


        // Run.

        qJobD.nm = 'RPGUNITT';
        qJobD.lib = 'QTEMP';
        liblData = loadLibl(qJobD);

        // Check.

        assert(liblData.libL.numE = 2:
           'Number of libraries shoud equal 2');

        assert(liblData.libL.lib(1) = 'QGPL':
           'First library list entry should match: QGPL');

        assert(liblData.libL.lib(2) = 'QTEMP':
           'Third library list entry should match: QTEMP');

      /end-free
     P                 e


     P testRestoreLibl...
     P                 b                   export
     D                 pi

     D qJobD           ds                  likeds(Object_t)
     D savedLibl       ds                  likeds(LiblData_t)
     D currentLibl     ds                  likeds(LiblData_t)
     D newLibl         ds                  likeds(LiblData_t)
     D restoredLibl    ds                  likeds(LiblData_t)
      /free

        // Setup.


        // Run.

        // Save library list
        savedLibl = getLibl();

        // Change library list
        qJobD.nm = 'RPGUNITT';
        qJobD.lib = 'QTEMP';
        newLibl = loadLibl(qJobD);
        changeLibl(newLibl.curLib: newLibl.libL);

        currentLibl = getLibl();

        // Restore library list
        changeLibl(savedLibl.curLib: savedLibl.libL);

        // Get final library list
        restoredLibl = getLibl();

        // Check.
        assert(savedLibl <> newLibl:
           'Library list had not been properly changed for testing');

        assert(savedLibl = restoredLibl:
           'Restored library list does not match saved library list');


      /end-free
     P                 e


      //----------------------------------------------------------------------
      //   Private Helper Procedures
      //----------------------------------------------------------------------
