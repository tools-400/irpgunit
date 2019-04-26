      // ==========================================================================
      //  iRPGunit - Source Member Utilities.
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
      /include qinclude,H_SPEC
      /include qinclude,COPYRIGHT

       //----------------------------------------------------------------------
       //   IMPORTS
       //----------------------------------------------------------------------
      /include qinclude,SRCMBR
      /include qinclude,TEMPLATES
      /include qinclude,USRSPC
      /include qinclude,SYSTEMAPI
      /include qinclude,ERRORCODE

     D getOPMSourceMember...
     D                 pr            10a
     D                                     extproc('getOPMSourceMember')
     D  qPgm                               const  likeds(Object_t )
     D  qSrcMbr                                   likeds(SrcMbr_t)

     D getObjectType...
     D                 pr            10a
     D                                     extproc('getObjectType')
     D  object                             const  likeds(Object_t )

      //----------------------------------------------------------------------
      //   Global Constants
      //----------------------------------------------------------------------

     D TYPE_OPM_PGM    c                   '*OPM'
     D TYPE_ILE_PGM    c                   '*PGM'
     D TYPE_ILE_SRVPGM...
     D                 c                   '*SRVPGM'

      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

       // User Space.
     D g_usrSpc        ds                  likeds(Object_t)

       // API List Header.
     D g_modList       ds                  likeds(ListHdr_t)
     D                                     based(g_pModList)

       // Last pgm/srvPgm.
     D g_lastObject    ds                  qualified inz
     D  qObj                               likeds(Object_t)
     D  qMod                               likeds(Object_t)

      //----------------------------------------------------------------------
      //  Initializes this module.
      //----------------------------------------------------------------------
     P SrcMbr_initialize...
     P                 b                   export
     D                 pi
      /free

         g_usrSpc.nm  = 'RUMODLIST';
         g_usrSpc.lib = 'QTEMP';
         g_pModList = crtUsrSpc( g_usrSpc: 'RPGUnit - Module list.');

         clear g_lastObject;

      /end-free
     P                 e

      //----------------------------------------------------------------------
      //  Returns the source member of a given unit test suite.
      //----------------------------------------------------------------------
     P SrcMbr_getTestSuiteSrc...
     P                 b                   export
     D                 pi                         likeds(SrcMbr_t)
     D  qObj                               const  likeds(Object_t)

     D qMod            ds                  likeds(Object_t)
      /free

         qMod.nm = qObj.nm;
         qMod.lib = '*LIBL';
         return SrcMbr_getModSrc(qObj: qMod);

      /end-free
     P                 e

      //----------------------------------------------------------------------
      //  Returns the source member of a given program or
      //  service program.
      //----------------------------------------------------------------------
     P SrcMbr_getModSrc...
     P                 b                   export
     D                 pi                         likeds(SrcMbr_t)
     D  qObj                               const  likeds(Object_t )
     D  qMod                               const  likeds(Object_t )

       // Return Value: Source member.
     D qSrcMbr         ds                  likeds(SrcMbr_t)

     D objType         s             10a
     D count           s             10i 0

       // QBNLSPGM and QBNLPGMI items (identical formats)
     D module          ds                  likeds(SPGL0100_t)
     D                                     based(pModule)
     D errorCode       ds                  likeds(errorCode_t) inz(*likeds)
      /free

         clear qSrcMbr;

         dou '1';

            clear errorCode;
            errorCode.bytPrv = %size(errorCode);

            objType = getObjectType(qObj);

            select;
            when (objType = TYPE_ILE_SRVPGM);
               if (qObj <> g_lastObject.qObj);
                  QBNLSPGM(g_usrSpc: 'SPGL0100': qObj: errorCode);
               endif;
            when (objType = TYPE_ILE_PGM);
               if (qObj <> g_lastObject.qObj);
                  QBNLPGMI(g_usrSpc: 'PGML0100': qObj: errorCode);
               endif;
            when (objType = TYPE_OPM_PGM);
               getOPMSourceMember(qObj: qSrcMbr);
               leave;
            other;
               leave;
            endsl;

            count = 0;
            dow (errorCode.bytAvl = 0 and count < g_modList.entCnt);
               count += 1;
               if (count = 1);
                  pModule = g_pModList + g_modList.listOff;
               else;
                  pModule += g_modList.entSize;
               endif;
               if (module.mod = qMod.nm and
                   (qMod.lib = '*LIBL' or qMod.lib = module.modLib));
                  qSrcMbr.file = module.srcFile;
                  qSrcMbr.lib = module.srcLib;
                  qSrcMbr.mbr = module.srcMbr;
                  leave;
               endif;
            enddo;

         enddo;

         g_lastObject.qObj = qObj;
         g_lastObject.qMod = qMod;

         return qSrcMbr;

      /end-free
     P                 e

      //----------------------------------------------------------------------
      //  Returns the date and time the member was last changed.
      //----------------------------------------------------------------------
     P SrcMbr_getLastChgDate...
     P                 b                   export
     D                 pi              z
     D  qSrcFile                           const  likeds(Object_t )
     D  srcMbr                       10a   const

     D mbrd0100        ds                  likeds(mbrd0100_t) inz
     D apiDateTime     ds                  qualified
     D  date                          7a
     D  time                          6a
     D lastChgDate     s               z
      /free

         api_retrieveMemberDescription(
            mbrd0100: %size(mbrd0100): 'MBRD0100': qSrcFile: srcMbr: '0');

         apiDateTime = mbrd0100.srcChgDatTim;

         lastChgDate = %date(apiDateTime.date: *cymd0) +
                       %time(apiDateTime.time: *hms0);

         return lastChgDate;

      /end-free
     P                 e

      //----------------------------------------------------------------------
      //  Returns the source member of a given OPM program.
      //----------------------------------------------------------------------
     P getOPMSourceMember...
     P                 b
     D                 pi            10a
     D  qPgm                               const  likeds(Object_t)
     D  qSrcMbr                                   likeds(SrcMbr_t)

       // QCLRPGMI API.
     D pgmi0100        ds                  likeds(pgmi0100_t)
     D errorCode       ds                  likeds(errorCode_t) inz(*likeds)
      /free

         clear qSrcMbr;

         clear errorCode;
         errorCode.bytPrv = %size(errorCode);
         QCLRPGMI(pgmi0100: %size(pgmi0100): 'PGMI0100': qPgm: errorCode);
         if (errorCode.bytAvl > 0);
            return *OFF;
         endif;

         qSrcMbr.file = pgmi0100.srcFile;
         qSrcMbr.lib = pgmi0100.srcLib;
         qSrcMbr.mbr = pgmi0100.srcMbr;

         return *ON;

      /end-free
     P                 e


      //----------------------------------------------------------------------
      //  Returns *OPM, *PGM or *SRVPGM depending on the type
      //  of a given object.
      //----------------------------------------------------------------------
     P getObjectType...
     P                 b
     D                 pi            10a
     D  qObj                               const  likeds(Object_t )

       // QUSROBJD API.
     D objd0100        ds                  likeds(objd0100_t)

       // QCLRPGMI API.
     D pgmi0100        ds                  likeds(pgmi0100_t)
     D errorCode       ds                  likeds(errorCode_t) inz(*likeds)
      /free

         clear errorCode;
         errorCode.bytPrv = %size(errorCode);

         QUSROBJD(objd0100: %size(objd0100): 'OBJD0100'
                  : qObj: '*SRVPGM': errorCode);
         if (errorCode.bytAvl > 0);
            clear errorCode;
            errorCode.bytPrv = %size(errorCode);
            QCLRPGMI(pgmi0100: %size(pgmi0100): 'PGMI0100': qObj: errorCode);
            if (errorCode.bytAvl > 0);
               return '';
            endif;

            if (pgmi0100.type = 'B');
               return TYPE_ILE_PGM;
            else;
               return TYPE_OPM_PGM;
            endif;
         else;
            return TYPE_ILE_SRVPGM;
         endif;

      /end-free
     P                 e

