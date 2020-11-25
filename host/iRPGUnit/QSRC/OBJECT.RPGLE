      // ==========================================================================
      //  iRPGUnit - Object Utilities.
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
      /include qinclude,OBJECT
      /include qinclude,TEMPLATES
      /include qinclude,SYSTEMAPI
      /include qinclude,ERRORCODE

     D retrieveObjectDescription...
     D                 pr          4096a
     D                                     extproc('retrieveObjectDescription')
     D  object                             const likeds(Object_t)
     D  objType                      10a   const
     D  format                        8a   const
     D  errorCode                                likeds(errorCode_t)
     D                                           options(*nopass: *omit)

     D retrieveMemberDescription...
     D                 pr          4096a
     D                                     extproc('retrieveMemberDescription')
     D  file                               const likeds(Object_t)
     D  member                       10a   const
     D  format                        8a   const
     D  errorCode                                likeds(errorCode_t)
     D                                           options(*nopass: *omit)

      //----------------------------------------------------------------------
      //  Returns *ON when the specified iRPGUnit test suite does not
      //  exist or is dirty. A test suite is considered as dirty, when
      //  the source code has been changed since the object has been created.
      //----------------------------------------------------------------------
     P TestSuite_isDirty...
     P                 b                   export
     D                 pi              n
     D  srvPgm                       10a   const
     D  library                      10a   const

     D qSrvPgm         ds                  likeds(Object_t)
      /free

         qSrvPgm.nm = srvPgm;
         qSrvPgm.lib = library;

         if (not Object_exists(qSrvPgm: '*SRVPGM'));
            return *ON;
         endif;

         return Object_isDirty(qSrvPgm: '*SRVPGM');

      /end-free
     P                 e

      //----------------------------------------------------------------------
      //  Returns *ON when the specified iRPGUnit test suite does not exist.
      //----------------------------------------------------------------------
     P TestSuite_exists...
     P                 b                   export
     D                 pi              n
     D  srvPgm                       10a   const
     D  library                      10a   const

     D qSrvPgm         ds                  likeds(Object_t)
      /free

         qSrvPgm.nm = srvPgm;
         qSrvPgm.lib = library;

         return Object_exists(qSrvPgm: '*SRVPGM');

      /end-free
     P                 e

      //----------------------------------------------------------------------
      //  Resolves the object library.
      //----------------------------------------------------------------------
     P Object_resolveLibrary...
     P                 b                   export
     D                 pi            10a
     D  object                             const likeds(Object_t)
     D  objType                      10a   const

     D objd0100        ds                  likeds(objd0100_t) inz
     D errorCode       ds                  likeds(errorCode_t) inz(*likeds)
      /free

         clear errorCode;
         errorCode.bytPrv = %size(errorCode);
         objd0100 = retrieveObjectDescription(
                       object: objType: 'OBJD0100': errorCode);

         if (errorCode.bytAvl > 0);
            return '';
         endif;

         if (objd0100.bytRet = 0);
            return '';
         endif;

         return objd0100.rtnLib;

      /end-free
     P                 e

      //----------------------------------------------------------------------
      //  Returns *ON when the source member is younger than the object.
      //----------------------------------------------------------------------
     P Object_isDirty...
     P                 b                   export
     D                 pi              n
     D  object                             const likeds(Object_t)
     D  objType                      10a   const

     D objd0300        ds                  likeds(objd0300_t) inz
     D apiDateTime     ds                  qualified
     D  date                          7a
     D  time                          6a
     D qSrcFile        ds                  likeds(Object_t)
     D srcMbr          s             10a
     D obj             ds                  qualified
     D  crtDate                        z
     D  srcLastChgDate...
     D                                 z
     D src             ds                  qualified
     D  lastChgDate                    z
      /free

         objd0300 = retrieveObjectDescription(
                       object: objType: 'OBJD0300');

         apiDateTime = objd0300.crtDatTim;
         obj.crtDate = %date(apiDateTime.date: *cymd0) +
                       %time(apiDateTime.time: *hms0);

         if (objd0300.srcFile = '' or
             objd0300.srcLib = '' or
             objd0300.srcMbr = '');
            return *ON;
         endif;

         if (objd0300.srcFDatTim <> '');
            apiDateTime = objd0300.srcFDatTim;
            obj.srcLastChgDate = %date(apiDateTime.date: *cymd0) +
                                 %time(apiDateTime.time: *hms0);
         else;
            obj.srcLastChgDate = *loval;
         endif;

         qSrcFile.nm = objd0300.srcFile;
         qSrcFile.lib = objd0300.srcLib;
         srcMbr = objd0300.srcMbr;

         src.lastChgDate = SrcMbr_getLastChgDate(qSrcFile: srcMbr);

         if (src.lastChgDate > obj.crtDate or
             src.lastChgDate > obj.srcLastChgDate);
            return *ON;
         endif;

         return *OFF;

      /end-free
     P                 e

      //----------------------------------------------------------------------
      //  Returns *ON when the specified object exists, else *OFF.
      //----------------------------------------------------------------------
     P Object_exists...
     P                 b                   export
     D                 pi              n
     D  object                             const likeds(Object_t)
     D  objType                      10a   const
     D  mbr                          10a   const options(*nopass)

     D p_mbr           c                   3

     D objd0100        ds                  likeds(objd0100_t) inz
     D mbrd0100        ds                  likeds(mbrd0100_t) inz
     D errorCode       ds                  likeds(errorCode_t) inz(*likeds)
      /free

         if (%parms() >= p_mbr and %addr(mbr) <> *null);
           mbrd0100 = retrieveMemberDescription(
                         object: mbr: 'MBRD0100': errorCode);
         else;
           objd0100 = retrieveObjectDescription(
                         object: objType: 'OBJD0100': errorCode);
         endif;

         if (errorCode.bytAvl = 0);
            return *ON;
         endif;

         return *OFF;

      /end-free
     P                 e

      //----------------------------------------------------------------------
      //  Returns the qualified object name.
      //----------------------------------------------------------------------
     P Object_qName...
     P                 b                   export
     D                 pi            21a   varying
     D  object                             const likeds(Object_t)

     D qName           s             21a   varying
      /free

       qName = %trim(object.lib) + '/' + %trim(object.nm);

       return qName;

      /end-free
     P                 e

      //----------------------------------------------------------------------
      //  Returns the object description of a given object.
      //----------------------------------------------------------------------
     P retrieveObjectDescription...
     P                 b                   export
     D                 pi          4096a
     D  object                             const likeds(Object_t)
     D  objType                      10a   const
     D  format                        8a   const
     D  errorCode                                likeds(errorCode_t)
     D                                           options(*nopass: *omit)

     D objDesc         ds          4096
     D  bytRet                       10I 0
     D  bytAvl                       10I 0
      /free

         clear objDesc;

         if (%parms() >= %parmnum(errorCode) and %addr(errorCode) <> *null);
            QUSROBJD(objDesc:%size(objDesc):format:object:objType:errorCode);
         else;
            QUSROBJD(objDesc:%size(objDesc):format:object:objType);
         endif;

         return objDesc;

      /end-free
     P                 e

      //----------------------------------------------------------------------
      //  Returns the object description of a given object.
      //----------------------------------------------------------------------
     P retrieveMemberDescription...
     P                 b                   export
     D                 pi          4096a
     D  file                               const likeds(Object_t)
     D  member                       10a   const
     D  format                        8a   const
     D  errorCode                                likeds(errorCode_t)
     D                                           options(*nopass: *omit)

     D fileDesc        ds          4096
     D  bytRet                       10I 0
     D  bytAvl                       10I 0
      /free

         clear fileDesc;

         if (%parms() >= %parmnum(errorCode) and %addr(errorCode) <> *null);
           QUSRMBRD(
             fileDesc: %size(fileDesc): format: file: member: '0': errorCode);
         else;
           QUSRMBRD(
             fileDesc: %size(fileDesc): format: file: member:'0');
         endif;

         return fileDesc;

      /end-free
     P                 e

