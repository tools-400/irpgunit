      // ==========================================================================
      //  iRPGUnit - Implementation of RUCRT* commands.
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

      /include qinclude,STRING
      /include qinclude,PGMMSG
      /include qinclude,TEMPLATES
      /include qinclude,SRCMBR
      /include qinclude,SYSTEMAPI
      /include qinclude,TESTUTILS
      /include qinclude,TAGTST
      /include qinclude,OBJECT
      /include qinclude,ERRORCODE

      /include qsysinc,QCAPCMD


      //----------------------------------------------------------------------
      //   PUBLIC PROTOTYPES
      //----------------------------------------------------------------------

      /include qinclude,CRTTST


      //----------------------------------------------------------------------
      //   GLOBAL VARIABLES
      //----------------------------------------------------------------------

     D srvPgm          ds                  likeds(Object_t)


      //----------------------------------------------------------------------
      //   MAIN PROGRAM
      //----------------------------------------------------------------------

     P crtTst...
     P                 b                   export
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
     D  compileopt                 5000a   const varying options(*varsize)

     D module          ds                  likeds(bModules) inz
     D srcType         s             10a   varying
     D textRslv        s                   like(text) inz
     D i               s             10i 0
     D mbrType         s             10a
     D tmpOpts         ds                  likeds(Options_t) inz
     D qSrcFile        ds                  likeds(Object_t) inz
     D libRslv         s             10a
     D startCompileTime...
     D                 s               z
     D modulesCreated  ds                  likeds(ObjectArray_t) inz

     D isError         s               n
      /free

       qSrcFile = srcFile;
       module = resolveLibraries(bModules);

       if (not Object_exists(qSrcFile: '*FILE'));
         sndEscapeMsgAboveCtlBdy(
            'Source file ' + %trim(qSrcFile.nm) + ' not found in library ' +
                             %trim(qSrcFile.lib) + '.' );
       endif;

       if (%subst(qSrcFile.lib: 1: 1) = '*');
         libRslv = Object_resolveLibrary(qSrcFile: '*FILE');
       else;
         if (not Object_exists(qSrcFile: '*FILE'));
           libRslv = '';
         else;
           libRslv = qSrcFile.lib;
         endif;
       endif;

       if (libRslv = '');
         sndEscapeMsgAboveCtlBdy(
           'Library ' + %trim(qSrcFile.lib) + ' not found.' );
       endif;

       qSrcFile.lib = libRslv;

       if (not Object_exists(qSrcFile: '*FILE': srcMbr));
         sndEscapeMsgAboveCtlBdy(
            'Member ' + %trim(srcMbr) + ' not found in source file ' +
                        %trim(qSrcFile.lib) + '/' + %trim(qSrcFile.nm) + '.' );
       endif;

       if (srcMbr = '*TSTPGM');
          mbrType = getMemberType(qSrcFile.nm: qSrcFile.lib: testPgm);
          if (mbrType = MBR_RPGLE);
             tmpOpts = cOption;
          else;
             tmpOpts = pOption;
          endif;
          for i = 1 to tmpOpts.size;
             if (tmpOpts.option(i) = '*EVENTF');
                sndEscapeMsgAboveCtlBdy(
                   'Compile option *EVENTF is not +
                    allowed with source member *TSTPGM, +
                    because it does not work in RDi. Specify +
                    the name of the source member.' );
             endif;
          endfor;
       endif;

       isError = *off;

       monitor;

         select;
         when text = '*SRCMBRTXT';
            textRslv = SrcMbr_getDescription(qSrcFile: srcMbr);
         when text = '*BLANK';
            textRslv = '';
         when text = '*DEFAULT';
            textRslv = 'RPGUnit - Test Case';
         when not startsWith('RPGUnit' : text);
            textRslv = 'RPGUnit - ' + text;
         other;
            textRslv = text;
         endsl;

         srcType = SrcMbr_getType( qSrcFile : srcMbr );

         startCompileTime = %timestamp();

         select;
         when (srcType = MBR_RPGLE or srcType = MBR_SQLRPGLE);
           addModule( module : testPgm : *on); // Add to position #1.
           // QDEVTOOLS/QLNCMSG RNS9305 - Module &1 placed in library &2.
           crtRpgMod( testPgm : qSrcFile : srcMbr : cOption : dbgView :
                      pRpgPpOpt : pOption : compileopt );
           modulesCreated = getCreatedModulesFromJobLog(
                              MOD_CRT_RPG : startCompileTime );
           addModules( module : modulesCreated );
         when (srcType = MBR_CBLLE or srcType = MBR_SQLCBLLE);
           // There is no test case module to add for Cobol ==> See: *PGMID
           // QDEVTOOLS/QLNCMSG LNC0899 - Module &1 placed in library &2.
           crtCblMod( testPgm : qSrcFile : srcMbr : cOption : dbgView :
                      pOption : compileopt );
           modulesCreated = getCreatedModulesFromJobLog(
                              MOD_CRT_CBL : startCompileTime );
           addModules( module : modulesCreated );
         other;
           sndEscapeMsgAboveCtlBdy(
             'Source type ' + addQuotes(srcType) + ' is not supported.' );
         endsl;

         srvPgm = crtSrvPgm(
                     testPgm : bndSrvPgm : bndDir : module : bOption :
                     actGrp : textRslv);

         tagTstSrvPgm(srvPgm : qSrcFile : srcMbr);

         sndCompMsg( 'Test program ' + %trim(srvPgm.nm)
                   + ' created in library ' + %trim(srvPgm.lib) + '.' );

       on-error;
         isError = *on;
       endmon;

       monitor;
         deleteModules( modulesCreated );
       on-error;
       endmon;

       if (isError);
         sndEscapeMsgAboveCtlBdy( 'Unable to create test '
                                  + %trim(testPgm.nm) + '.' );
       endif;

       *inlr = *on;

      /end-free
     P                 e


     P resolveLibraries...
     P                 b
     D                 pi                  likeds(ObjectArray_t)
     D  modules                            const likeds(ObjectArray_t)

     D i               s             10i 0
     D rtnModules      ds                  likeds(modules) inz
     D libResolved     s             10a
      /free

       clear rtnModules;

       for i = 1 to modules.size;

         if (startsWith( '*' : modules.object(i).lib));
           libResolved = Object_resolveLibrary(modules.object(i): '*MODULE');
         else;
           libResolved = modules.object(i).lib;
         endif;

         if (libResolved = '');
           sndEscapeMsgAboveCtlBdy( 'Could not resolve module '
                                  +  Object_qName(modules.object(i)) );
         endif;

         rtnModules.size += 1;
         rtnModules.object(rtnModules.size).nm = modules.object(i).nm;
         rtnModules.object(rtnModules.size).lib = libResolved;
       endfor;

       return rtnModules;

      /end-free
     P                 e


     P getCreatedModulesFromJobLog...
     P                 b
     D                 pi                  likeds(ObjectArray_t)
     D  crtMsgId                      7a   const
     D  startCompileTime...
     D                                 z   const

       // Job log message field selection for QGYOLJBL API.
     D fldSelect       ds                  qualified
     D  listDirection                10a   inz('*PRV')
     D  qlfJobNm                     26a   inz('*')
     D  intJobId                     16a   inz(*blank)
     D  startMsgKey                   4a   inz(x'FFFFFFFF')
     D  maxMsgLen                    10i 0 inz(0)
     D  maxMsgHlpLen                 10i 0 inz(0)
     D  fldIdOff                     10i 0
     D  fldCnt                       10i 0 inz(1)
     D  callMsgqNmOff                10i 0
     D  callMsgqNmLen                10i 0 inz(%size(fldSelect.callMsgqNm))
     D  fldId1                       10i 0 inz(OLJL_RPL_DATA)
     D  callMsgqNm                    1a   inz('*')

     D listInfo        ds                  likeds(dsOpnList)
     D msgBasicInfo    ds                  likeds(dsOLJL0100EntHdr)
     D                                     based(p_msgBasicInfo)
     D p_msgBasicInfo  s               *
     D msgFldInfo      ds                  likeds(dsOLJL0100FldHdr)
     D                                     based(pMsgFldInfo)
     D pMsgFldInfo     s               *
     D sentDateAsIso   s              8a
     D msgSendTime     s               z
     D jobLogList      s          32766a
     D msgIdx          s             10i 0
     D percolateErrors...
     D                 ds                  likeds(percolateErrors_t)
     D                                     inz(*likeds)
     D i               s             10i 0
     D module          ds                  likeds(Object_t) inz

     D pMsgData        s               *

     D RNS9305         ds                  qualified based(pMsgData)
     D  mod                          10a
     D  lib                          10a

     D LNC0899         ds                  qualified based(pMsgData)
     D  length                        5i 0
     D  data                         10a

     D modules         ds                  likeds(ObjectArray_t) inz
      /free

       fldSelect.fldIdOff = %addr(fldSelect.fldId1) - %addr(fldSelect);
       fldSelect.callMsgqNmOff =
                        %addr(fldSelect.callMsgqNm) - %addr(fldSelect);

       QGYOLJBL( jobLogList :
                 %size( jobLogList ) :
                 listInfo :
                 OLJL_FULL_SYNCHRONOUS_BUILD :
                 fldSelect :
                 %size( fldSelect ) :
                 percolateErrors );

       p_msgBasicInfo = %addr( jobLogList );
       msgIdx = 1;

       dow 1=1;
         if msgIdx > listInfo.retRcdCnt;
           if listInfo.totalRcdCnt > listInfo.retRcdCnt;
             sndEscapeMsgAboveCtlBdy(
                   'Insufficient implementation. ' +
                   'Should use QGYGTLE to retrieve records after ' +
                                %char( listInfo.retRcdCnt ) + '. ' +
                                           'Please open an issue.' );
           else;
             leave;
           endif;
         endif;

         sentDateAsIso = %char( %date( msgBasicInfo.sentDate: *cymd0) : *iso0 );
         msgSendTime = %timestamp( sentDateAsIso
                                 + msgBasicInfo.sentTime
                                 + msgBasicInfo.microseconds: *iso0 );
         if (startCompileTime >= msgSendTime);
           leave;
         endif;

         if (msgBasicInfo.msgId = crtMsgId);

           pMsgFldInfo = %addr( jobLogList ) + msgBasicInfo.retFldOff;

           pMsgData = pMsgFldInfo + %size(msgFldInfo);

           select;
           when (crtMsgId = MOD_CRT_RPG);
             module.nm = RNS9305.mod;
             module.lib = RNS9305.lib;
             addModule( modules : module );
           when (crtMsgId = MOD_CRT_CBL);
             module.nm = %subst(LNC0899.data: 1: LNC0899.length);
             pMsgData += LNC0899.length + %size(LNC0899.length); // push pointer to next *VARY field
             module.lib = %subst(LNC0899.data: 1: LNC0899.length);
             addModule( modules : module );
           endsl;
         endif;

         // Go to next message in the job log.
         p_msgBasicInfo = %addr( jobLogList ) + msgBasicInfo.nextEntOff;
         msgIdx += 1;
       enddo;

       QGYCLST( listInfo.rqsHdl : percolateErrors );

       return modules;

      /end-free
     P                 e


     P addModules...
     P                 b
     D                 pi
     D  modules                                  likeds(ObjectArray_t)
     D  items                                    likeds(ObjectArray_t)

     D i               s             10i 0

      /free

       for i = 1 to items.size;
         addModule( modules : items.object(i) );
       endfor;

      /end-free
     P                 e


     p addModule...
     p                 b
     d                 pi
     d  modules                                  likeds(ObjectArray_t)
     D  module                             const likeds(Object_t)
     D  isFirstMod                     n   const options(*nopass)

     d p_isFirstMod    c                         3

     d i               s             10i 0
     d r               s             10i 0

      /free

       if (%parms() > p_isFirstMod);
         // First remove module (if found)
         for i = 1 to modules.size;
           if (module.nm = modules.object(i).nm and
               module.lib = modules.object(i).lib);
             r = i;
           endif;
           if (r < i);
             modules.object(r) = modules.object(i);
             clear modules.object(i);
             r = i;
           endif;
         endfor;
         if (r < i);
           modules.size -= (i - r);
         endif;
         // Shift modules 1 item up
         for i = modules.size downto 1;
           modules.object(i + 1) = modules.object(i);
         endfor;
         modules.object(1) = module;
       else;
         for i = 1 to modules.size;
           if (module.nm = modules.object(i).nm and
               module.lib = modules.object(i).lib);
             return;
           endif;
         endfor;
       endif;

       modules.size += 1;
       modules.object(modules.size) = module;

      /end-free
     p                 e


     P crtRpgMod...
     P                 b
     D                 pi
     D  testPgm                            const likeds(Object_t)
     D  srcFile                            const likeds(Object_t)
     D  srcMbr                             const like(SrcMbr_t.mbr)
     D  cOption                            const likeds(Options_t)
     D  dbgView                            const like(DbgView_t)
     D  pRpgPpOpt                          const like(RpgPpOpt_t)
     D  pOption                            const likeds(Options_t)
     D  compileopt                 5000a   const varying options(*varsize)

      // A command to be executed.
     D cmd             s                   like(Cmd_t)

      /free

         cmd = getCrtRpgModCmd( testPgm : srcFile : srcMbr : cOption : dbgView:
                                pRpgPpOpt : pOption : compileopt );
         sndInfoMsg( cmd );
         qcmdexc( cmd : %len(cmd) );

      /end-free
     P                 e


     P crtCblMod...
     P                 b
     D                 pi
     D  testPgm                            const likeds(Object_t)
     D  srcFile                            const likeds(Object_t)
     D  srcMbr                             const like(SrcMbr_t.mbr)
     D  cOption                            const likeds(Options_t)
     D  dbgView                            const like(DbgView_t)
     D  pOption                            const likeds(Options_t)
     D  compileopt                 5000a   const varying options(*varsize)

      // A command to be executed.
     D cmd             s                   like(Cmd_t)

      /free

         cmd = getCrtCblModCmd( testPgm : srcFile : srcMbr : cOption : dbgView:
                                pOption : compileopt );
         sndInfoMsg( cmd );
         qcmdexc( cmd : %len(cmd) );

      /end-free
     P                 e


     P deleteModules...
     P                 b
     D                 pi
     D  modules                            const likeds(ObjectArray_t)


     D i               s             10i 0
     D cmd             s                   like(Cmd_t)

      /free

       for i = 1 to modules.size;
         cmd = getDltModCmd( modules.object(i) );
         qcmdexc( cmd : %len(cmd) );
       endfor;

      /end-free
     P                 e


     P crtSrvPgm...
     P                 b
     D                 pi                  likeds(Object_t)
     D  testPgm                            const likeds(Object_t)
     D  bndSrvPgm                          const likeds(ObjectArray_t)
     D  bndDir                             const likeds(ObjectArray_t)
     D  module                             const likeds(ObjectArray_t)
     D  bOption                            const likeds(Options_t)
     D  actGrp                             const like(ActivationGroup_t)
     D  text                               const like(Text_t)

      // Export all procedures from the service program.
     D EXPORT_ALL      c                   const('*ALL')
      // A command to be executed.
     D cmd             s                   like(Cmd_t)
      // Bound Service Programs, with RPGUnit services included.
     D bndSrvPgmWithRU...
     D                 ds                  likeds(ObjectArray_t)
      // Completion message data.
     D compMsgData     s            256a
      // Target service program.
     D targetSrvPgm    ds                  likeds(Object_t)

      /free

         bndSrvPgmWithRU = bndSrvPgm;
         bndSrvPgmWithRU.size += 1;
         bndSrvPgmWithRU.object(bndSrvPgmWithRU.size).nm = 'RUTESTCASE';
         bndSrvPgmWithRU.object(bndSrvPgmWithRU.size).lib = '*LIBL';

         cmd = getCrtSrvPgmCmd( testPgm :
                                bndSrvPgmWithRU :
                                bndDir :
                                module :
                                bOption :
                                EXPORT_ALL :
                                actGrp :
                                text );
         sndInfoMsg( cmd );
         qcmdexc( cmd : %len(cmd) );

         compMsgData = rcvMsgData( '*COMP' );
         targetSrvPgm = %subst( compMsgData : 1 : 20 );

         return targetSrvPgm;

      /end-free
     P                 e


     P getCrtSrvPgmCmd...
     P                 b                   export
     D                 pi                        like(Cmd_t)
     D  testPgm                            const likeds(Object_t)
     D  bndSrvPgm                          const likeds(ObjectArray_t)
     D  bndDir                             const likeds(ObjectArray_t)
     D  modules                            const likeds(ObjectArray_t)
     D  options                            const likeds(Options_t)
     D  export                             const like(Export_t)
     D  actGrp                             const like(ActivationGroup_t)
     D  text                               const like(Text_t )

      // Command string accumulator.
     D cmd             s                   like(Cmd_t)

      /free

        cmd = 'CRTSRVPGM SRVPGM(' + serializeObjectName( testPgm ) + ') ';
        cmd += serializeObjectArray( 'MODULE'    : modules   );
        cmd += serializeObjectArray( 'BNDSRVPGM' : bndSrvPgm );
        cmd += serializeObjectArray( 'BNDDIR'    : bndDir    );
        cmd += serializeOptions( 'OPTION' : options );
        cmd += serializeValue( 'ACTGRP' : actGrp );
        cmd += serializeString( 'TEXT' : text );
        cmd += serializeString( 'DETAIL' : '*BASIC' );

        if export <> *blank;
          cmd += 'EXPORT(' + %trim(export) + ') ';
        endif;

        cmd = formatCommand(cmd);

        return cmd;

      /end-free
     P                 e

     p formatCommand...
     p                 b
     d                 pi                  like(Cmd_t)
     d  cmd                                const like(Cmd_t)

     d optCtrlBlk      ds                  likeds(QCAPCMD_optCtrlBlk_t)

     d rtnCmd          s          32702a
     d rtnCmdLenAvl    s             10i 0
     d errCode         ds                  likeds(percolateErrors_t)
     d                                     inz(*likeds)
      /free

       clear optCtrlBlk;
       optCtrlBlk.typeCmdPrc = 1;     // QCMDCHK API
       optCtrlBlk.DBCS_data = '0';    // ignore DBCS
       optCtrlBlk.prmtAction = '0';   // never prompt
       optCtrlBlk.cmdStrSyntax = '0'; // AS/400 Syntax
       optCtrlBlk.msgRtvKey = '';     // no msg key
       optCtrlBlk.res_01 = *ALLx'00';

       QCAPCMD( cmd : %len(cmd) : optCtrlBlk : %size(optCtrlBlk) : 'CPOP0100'
              : rtnCmd : %len(rtnCmd) : rtnCmdLenAvl : errCode);

       return %subst(rtnCmd: 1: rtnCmdLenAvl);

      /end-free
     P                 e


     P getCrtRpgModCmd...
     P                 b                   export
     D                 pi                        like(Cmd_t)
     D  testPgm                            const likeds(Object_t)
     D  srcFile                            const likeds(Object_t)
     D  srcMbr                             const like(SrcMbr_t.mbr)
     D  cOptions                           const likeds(Options_t)
     D  dbgView                            const like(DbgView_t)
     D  pRpgPpOpt                          const like(RpgPpOpt_t)
     D  pOptions                           const likeds(Options_t)
     D  compileopt                 5000a   const varying options(*varsize)

      // Command string accumulator.
     D cmd             s                   like(Cmd_t)
     D dbgCompileOpt   s                   like(compileOpt)
      // Counter.
     D i               s             10i 0

      /free

        // source type determines the compile command
        select;
          // RPGLE
          when getMemberType(srcFile.nm: srcFile.lib: testPgm) = MBR_RPGLE;
            cmd = 'CRTRPGMOD MODULE(' + serializeObjectName( testPgm ) + ') ';
            cmd += 'SRCFILE(' + serializeObjectName( srcFile ) + ') ';
            cmd += serializeValue( 'SRCMBR' : srcMbr );
            cmd += serializeOptions( 'OPTION' : cOptions );
            cmd += serializeValue( 'DBGVIEW' : dbgView );

          // SQLRPGLE
          when getMemberType(srcFile.nm: srcFile.lib: testPgm) = MBR_SQLRPGLE;
            cmd = 'CRTSQLRPGI OBJ(' + serializeObjectName( testPgm ) + ') ';
            cmd += 'SRCFILE(' + serializeObjectName( srcFile ) + ') ';
            cmd += serializeValue( 'SRCMBR' : srcMbr );
            cmd += serializeOptions( 'OPTION' : pOptions );
            cmd += serializeValue('OBJTYPE': '*MODULE');
            cmd += serializeValue( 'DBGVIEW' : '*NONE');

            if (pRpgPpOpt <> '*DEFAULT');
              cmd += serializeValue( 'RPGPPOPT' : pRpgPpOpt);
            endif;

            if compileopt <> *blank;
              dbgCompileOpt = removeQuotes(compileOpt);
              if (%scan( PARM_DBGVIEW + '(' : uCase( compileOpt )) = 0);
                dbgCompileOpt += ' ' + serializeValue( 'DBGVIEW' : dbgView );
              endif;
            else;
              dbgCompileOpt = serializeValue( 'DBGVIEW' : dbgView);
            endif;

            cmd += serializeString( 'COMPILEOPT' : dbgCompileOpt);

         // something we don't know about yet
         other;
            cmd = 'RUCRTRPG: Unknown source member type';
         endsl;

        cmd = formatCommand(cmd);

        return cmd;

      /end-free
     P                 e


     P getCrtCblModCmd...
     P                 b                   export
     D                 pi                        like(Cmd_t)
     D  testPgm                            const likeds(Object_t)
     D  srcFile                            const likeds(Object_t)
     D  srcMbr                             const like(SrcMbr_t.mbr)
     D  cOptions                           const likeds(Options_t)
     D  dbgView                            const like(DbgView_t)
     D  pOptions                           const likeds(Options_t)
     D  compileopt                 5000a   const varying options(*varsize)

      // Command string accumulator.
     D cmd             s                   like(Cmd_t)
     D dbgCompileOpt   s                   like(compileOpt)
      // Counter.
     D i               s             10i 0

      /free

        // source type determines the compile command
        select;
          // CBLLE
          when getMemberType(srcFile.nm: srcFile.lib: testPgm) = MBR_CBLLE;
            cmd = 'CRTCBLMOD MODULE(*PGMID) ';
            cmd += 'SRCFILE(' + serializeObjectName( srcFile ) + ') ';
            cmd += serializeValue( 'SRCMBR' : srcMbr );
            cmd += serializeOptions( 'OPTION' : cOptions );
            cmd += serializeValue( 'DBGVIEW' : dbgView );

          // SQLCBLLE
          when getMemberType(srcFile.nm: srcFile.lib: testPgm) = MBR_SQLCBLLE;
            cmd = 'CRTSQLCBLI OBJ(' + serializeObjectName( testPgm ) + ') ';
            cmd += 'SRCFILE(' + serializeObjectName( srcFile ) + ') ';
            cmd += serializeValue( 'SRCMBR' : srcMbr );
            cmd += serializeOptions( 'OPTION' : pOptions );
            cmd += serializeValue('OBJTYPE': '*MODULE');
            cmd += serializeValue( 'DBGVIEW' : '*NONE');

            if compileopt <> *blank;
              dbgCompileOpt = removeQuotes(compileOpt);
              if (%scan( PARM_DBGVIEW + '(' : uCase( compileOpt )) = 0);
                dbgCompileOpt += ' ' + serializeValue( 'DBGVIEW' : dbgView );
              endif;
            else;
              dbgCompileOpt = serializeValue( 'DBGVIEW' : dbgView);
            endif;

            cmd += serializeString( 'COMPILEOPT' : dbgCompileOpt);

         // something we don't know about yet
         other;
            cmd = 'RUCRTCBL: Unknown source member type';
         endsl;

        cmd = formatCommand(cmd);

        return cmd;

      /end-free
     P                 e


     P getDltModCmd...
     P                 b
     D                 pi                        like(Cmd_t)
     D  testPgm                            const likeds(Object_t)

      // Command string accumulator.
     D cmd             s                   like(Cmd_t)

      /free

        cmd = 'DLTMOD MODULE(' + serializeObjectName( testPgm ) + ') ';

        cmd = formatCommand(cmd);

        return cmd;

      /end-free
     P                 e


     PserializeObjectArray...
     P                 b
     D                 pi                        like(SerializedArray_t)
     D headToken                           const like(HeadToken_t)
     D array                               const likeds(ObjectArray_t)

      // Serialized Object Array.
     D serialized      s                   like(SerializedArray_t)
      // Counter.
     D i               s             10i 0

      /free

        if array.size = 0;
          return '';
        endif;

        serialized = %trim(headToken) + '(';

        for i = 1 to array.size;
          serialized += serializeObjectName( array.object(i) ) + ' ';
        endfor;

        serialized += ') ';

        return serialized;

      /end-free
     P                 e


     P serializeObjectName...
     P                 b                   export
     D                 pi                        like(SerializedObject_t)
     D  object                             const likeds(Object_t)

      // Serialized object name.
     D serialized      s                   like(SerializedObject_t) inz('')

      /free

        if object.lib <> *blank;
          serialized += %trim(object.lib) + '/';
        endif;

        serialized += %trim(object.nm);

        return serialized;

      /end-free
     P                 e


     PserializeOptions...
     P                 b
     D                 pi                        like(SerializedOptions_t)
     D headToken                           const like(HeadToken_t)
     D options                             const likeds(Options_t)

      // Serialized Options.
     D serialized      s                   like(SerializedOptions_t)
      // Counter.
     D i               s             10i 0

      /free

        if options.size = 0;
          return '';
        endif;

        serialized = %trim(headToken) + '(';

        for i = 1 to options.size;
          serialized += %trim(options.option(i)) + ' ';
        endfor;

        if options.size > 0;
          serialized += ') ';
        endif;

        return serialized;

      /end-free
     P                 e

     PserializeString...
     P                 b
     D                 pi                        like(SerializedString_t)
     D headToken                           const like(HeadToken_t)
     D text                        5000a   const varying options(*varsize)

      // Serialized Options.
     D serialized      s                   like(SerializedString_t)
      // Counter.
     D i               s             10i 0

      /free

        if %Len(%TrimR(text)) = 0;
          return '';
        endif;

        if startsWith(QUOTE: %trimL(text));
           serialized = %trim(headToken) + '(' + text + ')';
           return serialized;
        endif;

        serialized = %trim(headToken) + '(' + QUOTE;

        for i = 1 to %Len(%TrimR(text));
           serialized = serialized + %Subst(text: i: 1);
           if %Subst(text: i: 1) = QUOTE;
              serialized = serialized + QUOTE;
           endif;
        endfor;

        serialized = serialized + QUOTE + ') ';

        return serialized;

      /end-free
     P                 e

     PserializeValue...
     P                 b
     D                 pi                        like(SerializedString_t)
     D headToken                     10a   const
     D value                               const like(String_t)

      // Serialized Options.
     D serialized      s                   like(SerializedString_t)

      /free

        if %Len(%trim(value)) = 0;
          return '';
        endif;

        serialized = %trim(headToken) + '(' + %Trim(value) + ') ';

        return serialized;

      /end-free
     P                 e

