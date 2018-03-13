      // =====================================================================
      //
      // Unit tests for RUCRTTST.
      //
      // =====================================================================
      //   >>PRE-COMPILER<<
      //     >>CMD<<    CRTBNDCL   PGM(QTEMP/MKCRTTSTT) SRCFILE(&SF);
      //     >>CMD<<    CALL       PGM(QTEMP/MKCRTTSTT) PARM(&LI);
      //   >>END-PRE-COMPILER<<
      // =====================================================================

     H NoMain


      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D setup...
     D                 pr                  extproc('setup')
     D tearDown...
     D                 pr                  extproc('tearDown')
     D testSrcFile...
     D                 pr                  extproc('testSrcFile')
     D testOneCompileOption...
     D                 pr                  extproc('testOneCompileOption')
     D testTwoCompileOptions...
     D                 pr                  extproc('testTwoCompileOptions')
     D testDbgView...
     D                 pr                  extproc('testDbgView')
     D testOneBndSrvPgm...
     D                 pr                  extproc('testOneBndSrvPgm')
     D testTwoBndSrvPgm...
     D                 pr                  extproc('testTwoBndSrvPgm')
     D testOneBndDir...
     D                 pr                  extproc('testOneBndDir')
     D testOneBindingOption...
     D                 pr                  extproc('testOneBindingOption')
     D testExport...
     D                 pr                  extproc('testExport')
     D testBndDirWithoutLibrary...
     D                 pr                  extproc('testBndDirWithoutLibrary')
     D testSerializeObjectNameWithLibrary...
     D                 pr                  extproc('testSerializeObjectNameWith+
     D                                     Library')
     D testSerializeObjectNameWithoutLibrary...
     D                 pr                  extproc('testSerializeObjectNameWith+
     D                                     outLibrary')


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNIT1,TESTCASE
      /copy RPGUNITY1,LIBL
      /copy RPGUNITY1,CRTTST
      /copy RPGUNITY1,TEMPLATES


      //----------------------------------------------------------------------
      //   Constants
      //----------------------------------------------------------------------

       // No debugging view given by user.
     D noDbgView       c                   const(*blank)
       // No export option.
     D noExport        c                   const(*blank)
       // No text.
     D noText          c                   const(*blank)


      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

       // No compile option.
     D noCOption       ds                  likeds(Options_t)
       // No SQL pre-compiler option.
     D noPOption       ds                  likeds(Options_t)
       // No service program to bind.
     D noBndSrvPgm     ds                  likeds(ObjectArray_t)
       // No binding directory.
     D noBndDir        ds                  likeds(ObjectArray_t)
       // No binding option.
     D noBOption       ds                  likeds(Options_t)
       // No modules.
     D noModule        ds                  likeds(ObjectArray_t)
       // No SQL pre-compiler compile option.
     D noCompileOpt    s              1a   varying

       // Command to create an RPG module.
     D crtRpgModCmd    s            256a
       // Command to create a Service Program object.
     D crtSrvPgmCmd    s            256a

     D liblList        ds                  likeds(LiblData_t)
     D newLiblList     ds                  likeds(LiblData_t)

     D QCMDEXC         pr                  ExtPgm('QCMDEXC')
     D  i_cmd                     32702A   const  options(*varsize)
     D  i_length                     15P 5 const

     D OVRSRCF         c                   'OVRDBF FILE(QRPGLESRC) +
     D                                      TOFILE(RPGUNIT/RPGUNIT1) +
     D                                      OVRSCOPE(*CALLLVL)'

      //----------------------------------------------------------------------
      //   Program Status Data Structure
      //----------------------------------------------------------------------

     D sds            SDS                  qualified
     D  pgmName                1     10A
     D  pgmLib                81     90A

      //----------------------------------------------------------------------
      //   Test Procedures
      //----------------------------------------------------------------------

     Psetup            b                   export
     Dsetup            pi
      /free

        clear crtRpgModCmd;

        clear noCOption;
        noCOption.size = 0;

        clear noBndSrvPgm;
        noBndSrvPgm.size = 0;

        clear noBndDir;
        noBndDir.size = 0;

        clear noBOption;
        noBOption.size = 0;

        clear noModule;
        noModule.size = 0;

        liblList = getLibl();
        newLiblList = liblList;
        newLiblList.curLib = sds.pgmLib;
        restoreLibl(newLiblList);

      /end-free
     Psetup            e

     PtearDown         b                   export
     D                 pi
      /free

        restoreLibl(liblList);

      /end-free
     P                 e


     PtestSrcFile      b                   export
     DtestSrcFile      pi
      /free

        crtRpgModCmd = getCrtRpgModCmd( 'ASSERTT   *CURLIB   ' :
                                        'RPGUNITT1 *LIBL     ' :
                                        'ASSERTT' :
                                        noCOption :
                                        noDbgView :
                                        noPOption :
                                        noCompileOpt );
        aEqual( 'CRTRPGMOD MODULE(*CURLIB/ASSERTT) '
              + 'SRCFILE(*LIBL/RPGUNITT1) SRCMBR(ASSERTT)' : crtRpgModCmd );

      /end-free
     PtestSrcFile      e


     PtestOneCompileOption...
     P                 b                   export
     DtestOneCompileOption...
     D                 pi

     DoneCOption       ds                  likeds(Options_t)

      /free

        oneCOption.size = 1;
        oneCOption.option(1) = '*SRCSTMT';

        crtRpgModCmd = getCrtRpgModCmd( 'ASSERTT   *CURLIB   ' :
                                        'RPGUNITT1 *LIBL     ' :
                                        'ASSERTT' :
                                        oneCOption :
                                        noDbgView :
                                        noPOption :
                                        noCompileOpt );
        aEqual( 'CRTRPGMOD MODULE(*CURLIB/ASSERTT) '
              + 'SRCFILE(*LIBL/RPGUNITT1) SRCMBR(ASSERTT) '
              + 'OPTION(*SRCSTMT )' : crtRpgModCmd );

      /end-free
     PtestOneCompileOption...
     P                 e


     PtestTwoCompileOptions...
     P                 b                   export
     DtestTwoCompileOptions...
     D                 pi

     DtwoCOptions      ds                  likeds(Options_t)

      /free

        twoCOptions.size = 2;
        twoCOptions.option(1) = '*SRCSTMT';
        twoCOptions.option(2) = '*NODEBUGIO';

        crtRpgModCmd = getCrtRpgModCmd( 'ASSERTT   *CURLIB   ' :
                                        'RPGUNITT1 *LIBL     ' :
                                        'ASSERTT' :
                                        twoCOptions :
                                        noDbgView :
                                        noPOption :
                                        noCompileOpt );
        aEqual( 'CRTRPGMOD MODULE(*CURLIB/ASSERTT) '
              + 'SRCFILE(*LIBL/RPGUNITT1) SRCMBR(ASSERTT) '
              + 'OPTION(*SRCSTMT *NODEBUGIO )' : crtRpgModCmd );

      /end-free
     PtestTwoCompileOptions...
     P                 e


     PtestDbgView      b                   export
     DtestDbgView      pi
      /free

        crtRpgModCmd = getCrtRpgModCmd( 'ASSERTT   *CURLIB   ' :
                                        'RPGUNITT1 *LIBL     ' :
                                        'ASSERTT' :
                                        noCOption :
                                        '*LIST'   :
                                        noPOption :
                                        noCompileOpt );
        aEqual( 'CRTRPGMOD MODULE(*CURLIB/ASSERTT) '
              + 'SRCFILE(*LIBL/RPGUNITT1) SRCMBR(ASSERTT) '
              + 'DBGVIEW(*LIST)' : crtRpgModCmd );

      /end-free
     PtestDbgView      e


     PtestOneBndSrvPgm...
     P                 b                   export
     DtestOneBndSrvPgm...
     D                 pi

      // Binding one Service Program.
     DoneBndSrvPgm     ds                  likeds(ObjectArray_t)

      /free

        // Setup.

        oneBndSrvPgm.size = 1;
        oneBndSrvPgm.object(1).nm = 'SRVPGM_NM';
        oneBndSrvPgm.object(1).lib = 'SRVPGM_LIB';

        // Execution.

        crtSrvPgmCmd = getCrtSrvPgmCmd( 'PGM_NAME  *CURLIB   ' :
                                        oneBndSrvPgm :
                                        noBndDir :
                                        noModule :
                                        noBOption :
                                        noExport :
                                        noText );

        // Control.

        aEqual( 'CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) MODULE(*CURLIB/PGM_NAME ) '
              + 'BNDSRVPGM(SRVPGM_LIB/SRVPGM_NM ) TEXT('''') DETAIL(''*BASIC'')'
              : crtSrvPgmCmd );

      /end-free
     PtestOneBndSrvPgm...
     P                 e


     PtestTwoBndSrvPgm...
     P                 b                   export
     DtestTwoBndSrvPgm...
     D                 pi

      // Binding two Service Programs.
     DtwoBndSrvPgm     ds                  likeds(ObjectArray_t)

      /free

        // Setup.

        twoBndSrvPgm.size = 2;
        twoBndSrvPgm.object(1).nm = 'SRVPGM_NM';
        twoBndSrvPgm.object(1).lib = 'SRVPGM_LIB';
        twoBndSrvPgm.object(2).nm = 'SRVPGM_NM2';
        twoBndSrvPgm.object(2).lib = 'SRVPGM_LB2';

        // Execution.

        crtSrvPgmCmd = getCrtSrvPgmCmd( 'PGM_NAME  *CURLIB   ' :
                                        twoBndSrvPgm :
                                        noBndDir :
                                        noModule :
                                        noBOption :
                                        noExport :
                                        noText );

        // Control.

        aEqual( 'CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) MODULE(*CURLIB/PGM_NAME ) '
              + 'BNDSRVPGM(SRVPGM_LIB/SRVPGM_NM SRVPGM_LB2/SRVPGM_NM2 ) '
              + 'TEXT('''') DETAIL(''*BASIC'')'
              : crtSrvPgmCmd );

      /end-free
     PtestTwoBndSrvPgm...
     P                 e


     PtestOneBndDir    b                   export
     DtestOneBndDir    pi

      // One binding directory.
     DoneBndDir        ds                  likeds(ObjectArray_t)

      /free

        // Setup.

        oneBndDir.size = 1;
        oneBndDir.object(1).nm = 'BNDDIR_NM';
        oneBndDir.object(1).lib = 'BNDDIR_LIB';

        // Execution.

        crtSrvPgmCmd = getCrtSrvPgmCmd( 'PGM_NAME  *CURLIB   ' :
                                        noBndSrvPgm :
                                        oneBndDir :
                                        noModule :
                                        noBOption :
                                        noExport :
                                        noText );

        // Control.

        aEqual( 'CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) MODULE(*CURLIB/PGM_NAME ) '
              + 'BNDDIR(BNDDIR_LIB/BNDDIR_NM ) TEXT('''') DETAIL(''*BASIC'')'
              : crtSrvPgmCmd );

      /end-free
     PtestOneBndDir    e


     PtestBndDirWithoutLibrary...
     P                 b                   export
     DtestBndDirWithoutLibrary...
     D                 pi

      // One binding directory.
     DoneBndDir        ds                  likeds(ObjectArray_t)

      /free

        // Setup.

        oneBndDir.size = 1;
        oneBndDir.object(1).nm = 'BNDDIR_NM';
        oneBndDir.object(1).lib = *blank;

        // Execution.

        crtSrvPgmCmd = getCrtSrvPgmCmd( 'PGM_NAME  *CURLIB   ' :
                                        noBndSrvPgm :
                                        oneBndDir :
                                        noModule :
                                        noBOption :
                                        noExport :
                                        noText );

        // Control.

        aEqual( 'CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) MODULE(*CURLIB/PGM_NAME ) +
                 BNDDIR(BNDDIR_NM ) TEXT('''') DETAIL(''*BASIC'')'
              : crtSrvPgmCmd );

      /end-free
     PtestBndDirWithoutLibrary...
     P                 e


     PtestOneBindingOption...
     P                 b                   export
     DtestOneBindingOption...
     D                 pi

      // One Binding Option.
     DoneBOption       ds                  likeds(Options_t)

      /free

        // Setup.

        oneBOption.size = 1;
        oneBOption.option(1) = '*DUPPROC';

        // Execute.

        crtSrvPgmCmd = getCrtSrvPgmCmd( 'PGM_NAME  *CURLIB   ' :
                                        noBndSrvPgm :
                                        noBndDir :
                                        noModule :
                                        oneBOption :
                                        noExport :
                                        noText );

        // Control.

        aEqual( 'CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) MODULE(*CURLIB/PGM_NAME ) '
              + 'OPTION(*DUPPROC ) TEXT('''') DETAIL(''*BASIC'')'
              : crtSrvPgmCmd );

      /end-free
     PtestOneBindingOption...
     P                 e


     PtestExport       b                   export
     DtestExport       pi

       // Export option.
     D export          s             10a

      /free

        // Setup.

        export = '*ALL';

        // Execute.

        crtSrvPgmCmd = getCrtSrvPgmCmd( 'PGM_NAME  *CURLIB   ' :
                                        noBndSrvPgm :
                                        noBndDir :
                                        noModule :
                                        noBOption :
                                        export :
                                        noText );

        // Control.

        aEqual( 'CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) MODULE(*CURLIB/PGM_NAME ) '
              + 'TEXT('''') DETAIL(''*BASIC'') '
              + 'EXPORT(*ALL)' : crtSrvPgmCmd );

      /end-free
     PtestExport       e


     PtestSerializeObjectNameWithLibrary...
     P                 b                   export
     DtestSerializeObjectNameWithLibrary...
     D                 pi

      // An object name.
     Dobject           ds                  likeds(Object_t)

      /free

        // Setup.

        object.nm = 'OBJNAME';
        object.lib = 'OBJLIB';

        // Execute and control.

        aEqual( 'OBJLIB/OBJNAME' : serializeObjectName(object) );

      /end-free
     PtestSerializeObjectNameWithLibrary...
     P                 e


     PtestSerializeObjectNameWithoutLibrary...
     P                 b                   export
     DtestSerializeObjectNameWithoutLibrary...
     D                 pi

      // An object name.
     Dobject           ds                  likeds(Object_t)

      /free

        // Setup.

        object.nm = 'OBJNAME';
        object.lib = *blank;

        // Execute and control.

        aEqual( 'OBJNAME' : serializeObjectName(object) );

      /end-free
     PtestSerializeObjectNameWithoutLibrary...
     P                 e
