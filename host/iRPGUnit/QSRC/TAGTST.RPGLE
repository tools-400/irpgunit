      // ==========================================================================
      //  iRPGUnit - Tag Test Service Program.
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

     H nomain
      /include qinclude,h_spec
      /include qinclude,COPYRIGHT

       //----------------------------------------------------------------------
       //   Global Variables
       //----------------------------------------------------------------------

      /include qinclude,ERRORCODE

       //----------------------------------------------------------------------
       //   Prototypes
       //----------------------------------------------------------------------
      /include qinclude,TAGTST
      /include qinclude,TEMPLATES
      /include qsysinc,QLICOBJD
      /include qinclude,SRCMBR

     /**
      * \brief main procedure
      */
     P tagTstSrvPgm...
     P                 B                   export
     D                 PI
     D   qSrvPgm                           const likeds(Object_t)
     D   qSrcFile                          const likeds(Object_t)
     D   srcMbr                      10A   const
      *
     D rtnLib          S             10A

     D objInfo         ds                  qualified
     D   keys                        10I 0
     D   type                        10I 0
     D   length                      10I 0
     D   attribute                   30A

     D lastChgDate     s               Z
     D errorCode       ds                  likeds(errorCode_t) inz(*likeds)
      /free

       clear errorCode;
       errorCode.bytPrv = 0;

       // Change: user defined attribute
       objInfo.keys = 1;
       objInfo.type = 9;
       objInfo.length = 10;
       objInfo.attribute = 'RPGUNIT';
       QLICOBJD(rtnLib : qSrvPgm : '*SRVPGM' : objInfo : errorCode);

       // Change: source file and member
       objInfo.keys = 1;
       objInfo.type = 1;
       objInfo.length = 30;
       objInfo.attribute = qSrcFile + srcMbr;
       QLICOBJD(rtnLib : qSrvPgm : '*SRVPGM' : objInfo : errorCode);

       // Retrieve source member last changed date and time
       lastChgDate = SrcMbr_getLastChgDate(qSrcFile: srcMbr);

       // Change: last changed date and time
       objInfo.keys = 1;
       objInfo.type = 2;
       objInfo.length = 13;
       objInfo.attribute = %char(%date(lastChgDate): *cymd0) +
                           %char(%time(lastChgDate): *hms0);
       QLICOBJD(rtnLib : qSrvPgm : '*SRVPGM' : objInfo : errorCode);

      /end-free
     P                 E
