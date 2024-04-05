      // ==========================================================================
      //  iRPGUnit - Utilities.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================
      // >>PRE-COMPILER<<
      //   >>CRTCMD<<  CRTSQLRPGI OBJ(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM) +
      //                 OBJTYPE(*MODULE);
      //   >>IMPORTANT<<
      //     >>PARM<<  OPTION(*EVENTF);
      //     >>PARM<<  DBGVIEW(*NONE);
      //     >>PARM<<  RPGPPOPT(*LVL2);
      //     >>PARM<<  COMPILEOPT('TRUNCNBR(*NO) DBGVIEW(*ALL)');
      //   >>END-IMPORTANT<<
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

     H NoMain
      /include qinclude,H_SPEC
      /include qinclude,COPYRIGHT

      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /include qinclude,TESTUTILS
      /include qinclude,MILIB
      /include qinclude,OBJECT
      /include qinclude,PGMMSG
      /include qinclude,SYSTEMAPI


      //----------------------------------------------------------------------
      //   Type Templates
      //----------------------------------------------------------------------

      /include qinclude,TEMPLATES


      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

       // Message key of the latest message in the
       // job log, when a test case was started.
     D g_lowMsgKey     s              4a

      //----------------------------------------------------------------------
      //   Procedure Definitions
      //----------------------------------------------------------------------


     P waitSeconds...
     P                 b                   export
     D                 pi                  opdesc
     D  seconds                      10i 0 const
     D  message                      50a   const varying options(*nopass: *omit)

     D mi_time         s                   like(mi_time_t) inz(*ALLx'00')
      /free

        if (seconds = 0);
           return;
        endif;

        if (%parms() >= 2 and %addr(message) <> *NULL);
           displayStatusMessage(message);
        endif;

        mitime(mi_time: 0: 0: seconds: 0);
        waittime(mi_time :cWAIT_SIGNALS);

        if (%parms() >= 2 and %addr(message) <> *NULL);
           rstStsMsg();
        endif;

      /end-free
     P                 e


     P displayStatusMessage...
     P                 b                   export
     D                 pi                  opdesc
     D  message                     132a   const varying
      /free

         sndStsMsg(message);

      /end-free
     P                 e


     P restoreStatusMessage...
     P                 b                   export
     D                 pi                  opdesc
      /free

         rstStsMsg();

      /end-free
     P                 e


     P clearStatusMessage...
     P                 b                   export
     D                 pi                  opdesc
      /free

         sndStsMsg('');

      /end-free
     P                 e


     P getMemberType...
     P                 b                   export
     D                 pi            10a   opdesc
     D  srcFile                      10a   const
     D  srcFileLib                   10a   const
     D  mbr                          10a   const

     D qSrcFile        ds                  likeds(Object_t)
     D mbrd0100        ds                  likeds(mbrd0100_t)
      /free

         qSrcFile.nm = srcFile;
         qSrcFile.lib = srcFileLib;

         api_retrieveMemberDescription(
               mbrd0100: %size(mbrd0100): 'MBRD0100': qSrcFile: mbr: '0');

         return mbrd0100.srcType;

      /end-free
     P                 e

     P getFullTimeStamp...
     P                 b                   export
     D                 pi              z   opdesc

     D now             s               z
       exec sql SET :now = CURRENT_TIMESTAMP;
       return now;
     P                 e


       //--------------------------------------------------------------------
       //        Reclaim Activation Group
       //--------------------------------------------------------------------
     P rclactgrp...
     P                 b                   export
     D                 pi                  opdesc
     D  w1actGrpNm                   10a   const

     D w1cmd           s          32702a   varying

      /free

        runCmd( 'RCLACTGRP ' + %trim(w1actGrpNm) );

      /end-free
     P                 e


       //--------------------------------------------------------------------
       //        Run Command
       //--------------------------------------------------------------------
     P runCmd...
     P                 b                   export
     D                 pi                  opdesc
     D  w1cmd                     32702a   const varying
      /free

        qcmdexc( w1cmd : %len(w1cmd) );

      /end-free
     P                 e


     P clrpfm...
     P                 b                   export
     D                 pi                  opdesc
     D  w1fileNm                     10a   const
     D  w1mbrNm                      10a   const options(*NoPass)

     D w1cmd           s          32702a   varying

      /free

        if %parms = 1;
          runCmd( 'CLRPFM FILE(*CURLIB/' + %trim(w1fileNm) + ')' );
        else;
          runCmd( 'CLRPFM FILE(*CURLIB/' + %trim(w1fileNm) + ')'
                + ' MBR(' + %trim(w1mbrNm) + ')' );
        endif;

      /end-free
     P                 e


     P setLowMessageKey...
     P                 b                   export
     D                 pi                  opdesc
     D  msgKey                        4a   const options(*nopass)

     D p_msgKey        c                   1
      /free

       if (%parms() >= p_msgKey);
          g_lowMsgKey = msgKey;
       else;
          g_lowMsgKey = getHighestMsgKey();
       endif;

      /end-free
     P                 e


     P getMonitoredMessage...
     P                 b                   export
     D                 pi                  likeds(MsgInfo_t)
     D                                     opdesc
     D  doRmvMsg                       n   const options(*nopass)

     D  msgInfo        ds                  likeds(MsgInfo_t)
     D  msg            ds                  likeds(Msg_t)

      /free

       if (%parms() >= 1 and %addr(doRmvMsg) <> *null);
          msg = getLatestEscMsg(g_lowMsgKey: doRmvMsg);
       else;
          msg = getLatestEscMsg(g_lowMsgKey: *OFF);
       endif;
       msgInfo.id     = msg.id;
       msgInfo.txt    = msg.txt;
       msgInfo.pgm    = msg.qSndStmt.qPgm.nm;
       msgInfo.mod    = msg.qSndStmt.qMod.nm;
       msgInfo.proc   = msg.qSndStmt.procNm;
       msgInfo.specNb = msg.qSndStmt.specNb;
       Return msgInfo;

      /end-free
     P                 e
