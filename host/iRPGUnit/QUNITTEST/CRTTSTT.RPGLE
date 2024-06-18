      // ==========================================================================
      //  iRPGUnit SelfTest - Test CRTTSTT.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================
      // >>PRE-COMPILER<<
      //   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
      //   >>IMPORTANT<<
      //     >>PARM<<  MODULE(&LI/CRTTST    +
      //                      &LI/JOBLOG    +
      //                      &LI/LIBL      +
      //                      &LI/LSTSPLF   +
      //                      &LI/OBJECT    +
      //                      &LI/PGMMSG    +
      //                      &LI/SRCMBR    +
      //                      &LI/STRING    +
      //                      &LI/TAGTST    +
      //                      &LI/USRSPC    +
      //                      );
      //     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
      //   >>END-IMPORTANT<<
      //   >>CMD<<     CMPMOD MODULE(&LI/CRTTST   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/JOBLOG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/LIBL     ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/LSTSPLF  ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/OBJECT   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/STRING   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/TAGTST   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/USRSPC   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

     H NoMain Option(*SrcStmt)

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
     D testActGrp...
     D                 pr                  extproc('testActGrp')
     D testText...
     D                 pr                  extproc('testText')
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

      /copy qinclude,ASSERT
      /copy qinclude,LIBL
      /copy qinclude,CRTTST
      /copy qinclude,TEMPLATES


      //----------------------------------------------------------------------
      //   Constants
      //----------------------------------------------------------------------

       // No debugging view given by user.
     D noDbgView       c                   const(*blank)
       // RPG preprocessor options.
     D rpgPpOptLvl2    c                   const('*LVL2')
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
       // No activation group.
     D noActGrp        s             10a   varying

       // Command to create an RPG module.
     D crtRpgModCmd    s            256a
       // Command to create a Service Program object.
     D crtSrvPgmCmd    s            256a

     D liblList        ds                  likeds(LiblData_t)
     D newLiblList     ds                  likeds(LiblData_t)


      //----------------------------------------------------------------------
      //   Program Status Data Structure
      //----------------------------------------------------------------------

      /copy qinclude,SDS


      //----------------------------------------------------------------------
      //   Test Procedures
      //----------------------------------------------------------------------

     Psetup            b                   export
     D                 pi
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
     P                 e

     PtearDown         b                   export
     D                 pi
      /free

        restoreLibl(liblList);

      /end-free
     P                 e


     PtestSrcFile      b                   export
     D                 pi
      /free

        crtRpgModCmd = getCrtRpgModCmd( 'SYSTYPES  *CURLIB   ' :
                                        'QRPGLESRC QSYSINC   ' :
                                        'SYSTYPES' :
                                        noCOption :
                                        noDbgView :
                                        rpgPpOptLvl2 :
                                        noPOption :
                                        noCompileOpt );
        aEqual( 'CRTRPGMOD MODULE(*CURLIB/SYSTYPES) '
              + 'SRCFILE(QSYSINC/QRPGLESRC) SRCMBR(SYSTYPES)' : crtRpgModCmd );

      /end-free
     P                 e


     PtestOneCompileOption...
     P                 b                   export
     D                 pi

     DoneCOption       ds                  likeds(Options_t)

      /free

        oneCOption.size = 1;
        oneCOption.option(1) = '*SRCSTMT';

        crtRpgModCmd = getCrtRpgModCmd( 'SYSTYPES  *CURLIB   ' :
                                        'QRPGLESRC QSYSINC   ' :
                                        'SYSTYPES'  :
                                        oneCOption :
                                        noDbgView :
                                        rpgPpOptLvl2 :
                                        noPOption :
                                        noCompileOpt );
        aEqual( 'CRTRPGMOD MODULE(*CURLIB/SYSTYPES) '
              + 'SRCFILE(QSYSINC/QRPGLESRC) SRCMBR(SYSTYPES) '
              + 'OPTION(*SRCSTMT)' : crtRpgModCmd );

      /end-free
     P                 e


     PtestTwoCompileOptions...
     P                 b                   export
     D                 pi

     DtwoCOptions      ds                  likeds(Options_t)

      /free

        twoCOptions.size = 2;
        twoCOptions.option(1) = '*SRCSTMT';
        twoCOptions.option(2) = '*NODEBUGIO';

        crtRpgModCmd = getCrtRpgModCmd( 'SYSTYPES  *CURLIB   ' :
                                        'QRPGLESRC QSYSINC   ' :
                                        'SYSTYPES'  :
                                        twoCOptions :
                                        noDbgView :
                                        rpgPpOptLvl2 :
                                        noPOption :
                                        noCompileOpt );
        aEqual( 'CRTRPGMOD MODULE(*CURLIB/SYSTYPES) '
              + 'SRCFILE(QSYSINC/QRPGLESRC) SRCMBR(SYSTYPES) '
              + 'OPTION(*SRCSTMT *NODEBUGIO)' : crtRpgModCmd );

      /end-free
     P                 e


     PtestDbgView      b                   export
     D                 pi
      /free

        crtRpgModCmd = getCrtRpgModCmd( 'SYSTYPES  *CURLIB   ' :
                                        'QRPGLESRC QSYSINC   ' :
                                        'SYSTYPES'  :
                                        noCOption :
                                        '*LIST'   :
                                        rpgPpOptLvl2 :
                                        noPOption :
                                        noCompileOpt );
        aEqual( 'CRTRPGMOD MODULE(*CURLIB/SYSTYPES) '
              + 'SRCFILE(QSYSINC/QRPGLESRC) SRCMBR(SYSTYPES) '
              + 'DBGVIEW(*LIST)' : crtRpgModCmd );

      /end-free
     P                 e


     PtestOneBndSrvPgm...
     P                 b                   export
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
                                        noActGrp :
                                        noText );

        // Control.

        aEqual( 'CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) '
              + 'BNDSRVPGM((SRVPGM_LIB/SRVPGM_NM)) DETAIL(''*BASIC'')'
              : crtSrvPgmCmd );

      /end-free
     P                 e


     PtestTwoBndSrvPgm...
     P                 b                   export
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
                                        noActGrp :
                                        noText );

        // Control.

        aEqual( 'CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) '
              + 'BNDSRVPGM((SRVPGM_LIB/SRVPGM_NM) (SRVPGM_LB2/SRVPGM_NM2)) '
              + 'DETAIL(''*BASIC'')'
              : crtSrvPgmCmd );

      /end-free
     P                 e


     PtestOneBndDir    b                   export
     D                 pi

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
                                        noActGrp :
                                        noText );

        // Control.

        aEqual( 'CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) '
              + 'BNDDIR(BNDDIR_LIB/BNDDIR_NM) DETAIL(''*BASIC'')'
              : crtSrvPgmCmd );

      /end-free
     P                 e


     PtestBndDirWithoutLibrary...
     P                 b                   export
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
                                        noActGrp :
                                        noText );

        // Control.

        aEqual( 'CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) '
              + 'BNDDIR(BNDDIR_NM) DETAIL(''*BASIC'')'
              : crtSrvPgmCmd );

      /end-free
     P                 e


     PtestOneBindingOption...
     P                 b                   export
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
                                        noActGrp :
                                        noText );

        // Control.

        aEqual( 'CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) '
              + 'OPTION(*DUPPROC) DETAIL(''*BASIC'')'
              : crtSrvPgmCmd );

      /end-free
     P                 e


     PtestExport       b                   export
     D                 pi

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
                                        noActGrp :
                                        noText );

        // Control.

        aEqual( 'CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) '
              + 'EXPORT(*ALL) DETAIL(''*BASIC'')'
              : crtSrvPgmCmd );

      /end-free
     P                 e


     PtestActGrp       b                   export
     D                 pi

       // Export option.
     D actGrp          s             10a

      /free

        // Setup.

        actGrp = 'QTEST';

        // Execute.

        crtSrvPgmCmd = getCrtSrvPgmCmd( 'PGM_NAME  *CURLIB   ' :
                                        noBndSrvPgm :
                                        noBndDir :
                                        noModule :
                                        noBOption :
                                        noExport :
                                        actGrp :
                                        noText );

        // Control.

        aEqual( 'CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) '
              + 'ACTGRP(QTEST) DETAIL(''*BASIC'')'
              : crtSrvPgmCmd );

      /end-free
     P                 e


     PtestText         b                   export
     D                 pi

       // Export option.
     D text            s             50a

      /free

        // Setup.

        text = 'Object ''description'' text';

        // Execute.

        crtSrvPgmCmd = getCrtSrvPgmCmd( 'PGM_NAME  *CURLIB   ' :
                                        noBndSrvPgm :
                                        noBndDir :
                                        noModule :
                                        noBOption :
                                        noExport :
                                        noActGrp :
                                        text );

        // Control.

        aEqual( 'CRTSRVPGM SRVPGM(*CURLIB/PGM_NAME) '
              + 'TEXT(''Object ''''description'''' text'') DETAIL(''*BASIC'')'
              : crtSrvPgmCmd );

      /end-free
     P                 e


     PtestSerializeObjectNameWithLibrary...
     P                 b                   export
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
     P                 e


     PtestSerializeObjectNameWithoutLibrary...
     P                 b                   export
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
     P                 e
