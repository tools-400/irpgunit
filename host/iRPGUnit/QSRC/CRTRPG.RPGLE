      // ==========================================================================
      //  iRPGUnit - Create RPG Unit Test Suite CPP.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================
      // >>PRE-COMPILER<<
      //   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
      //   >>IMPORTANT<<
      //     >>PARM<<  OPTION(*EVENTF);
      //     >>PARM<<  DBGVIEW(*LIST);
      //   >>END-IMPORTANT<<
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

      /include qinclude,H_SPEC
      /include qinclude,COPYRIGHT


      //----------------------------------------------------------------------
      //   IMPORTS
      //----------------------------------------------------------------------

      /include qinclude,CRTTST
      /include qinclude,PGMMSG
      /include qinclude,TEMPLATES
      /include qinclude,TESTUTILS


      //----------------------------------------------------------------------
      //   MAIN PROGRAM
      //----------------------------------------------------------------------

     D crtRpg...
     D                 pr
     D  testPgm                            const likeds(Object_t)
     D  srcFile                            const likeds(Object_t)
     D  srcMbr                             const like(SrcMbr_t.mbr)
     D  text                               const like(Text_t)
     D  cOption                            const likeds(Options_t)
     D  dbgView                            const like(DbgView_t)
     D  bndSrvPgm                          const likeds(ObjectArray_t)
     D  bndDir                             const likeds(ObjectArray_t)
     D  bOption                            const likeds(Options_t)
     D  actGrp                             const like(ActivationGroup_t)
     D  bModules                           const likeds(ObjectArray_t)
     D  pRpgPpOpt                          const like(RpgPpOpt_t)
     D  pOption                            const likeds(Options_t)
     D  compileOpt                 5000a   const varying options(*varsize)

     D crtRpg...
     D                 pi
     D  testPgm                            const likeds(Object_t)
     D  srcFile                            const likeds(Object_t)
     D  srcMbr                             const like(SrcMbr_t.mbr)
     D  text                               const like(Text_t)
     D  cOption                            const likeds(Options_t)
     D  dbgView                            const like(DbgView_t)
     D  bndSrvPgm                          const likeds(ObjectArray_t)
     D  bndDir                             const likeds(ObjectArray_t)
     D  bOption                            const likeds(Options_t)
     D  actGrp                             const like(ActivationGroup_t)
     D  bModules                           const likeds(ObjectArray_t)
     D  pRpgPpOpt                          const like(RpgPpOpt_t)
     D  pOption                            const likeds(Options_t)
     D  compileOpt                 5000a   const varying options(*varsize)

     D srcMbrRslv      s                   like(srcMbr)
     D srcType         s             10a
      /free

       if (srcMbr = '*TSTPGM');
         srcMbrRslv = testPgm.nm;
       else;
         srcMbrRslv = srcMbr;
       endif;

       srcType = getMemberType( srcFile.nm : srcFile.lib : srcMbrRslv );

       if (srcType <> MBR_RPGLE and srcType <> MBR_SQLRPGLE );
         sndEscapeMsgAboveCtlBdy( 'Source type ' + %trim(srcType)
                                + ' is not supported by command RUCRTRPG' );
       endif;

       crtTst( testPgm : srcFile : srcMbrRslv : text : cOption : dbgView
              : bndSrvPgm : bndDir : bOption : actGrp : bModules : pRpgPpOpt
              : pOption : compileOpt );

       *inlr = *on;

      /end-free

