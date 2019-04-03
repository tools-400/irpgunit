     /**
      * \brief Tag service program as unit test
      *
      * The user defined attribute of the object description will be set
      * to RPGUNIT to mark the service program as a unit test. The
      * text value will be left as it is (probably blank).
      *
      * \author Mihael Schmidt
      * \date 2010-10-01
      */

      *dftactgrp(*no) actgrp(*caller)
      /copy RPGUNITY1,COPYRIGHT

       //----------------------------------------------------------------------
       //   Global Variables
       //----------------------------------------------------------------------

      /copy RPGUNITY1,ERRORCODE

       //----------------------------------------------------------------------
       //   Prototypes
       //----------------------------------------------------------------------
      /copy RPGUNITY1,TAGTST

     D QLICOBJD...
     D                 PR                  extpgm('QLICOBJD')
     D   rtnLib                      10A
     D   qObj                        20A   const
     D   type                        10A   const
     D   chgObjInf                32767A   const options(*varsize)
     D   errCode                  32767A   const options(*varsize)

     D main            PR
     D   object                      10A   const
     D   library                     10A   const
     D   srcFile                           const likeds(Object_t)
     D   srcMbr                      10A   const

       //----------------------------------------------------------------------
       //   PEP
       //----------------------------------------------------------------------
     D RUTAGTST...
     D                 PI
     D   object                      10A   const
     D   library                     10A   const
     D   srcFile                           const likeds(Object_t)
     D   srcMbr                      10A   const

      /free

       main(object : library : srcFile : srcMbr );

       *inlr = *on;
       return;
      /end-free


     /**
      * \brief main procedure
      */
     P main...
     P                 B
     D                 PI
     D   object                      10A   const
     D   library                     10A   const
     D   srcFile                           const likeds(Object_t)
     D   srcMbr                      10A   const
      *
     D lib             S             10A

     D srcFileAndMbr...
     D                 ds                  qualified
     D   name                        10A
     D   lib                         10A
     D   mbr                         10A

     D objInfo         ds                  qualified
     D   keys                        10I 0
     D   type                        10I 0
     D   length                      10I 0
     D   attribute                   30A

      /free

       clear errorCode;
       errorCode.bytesP = 0;

       // Change: user defined attribute
       objInfo.keys = 1;
       objInfo.type = 9;
       objInfo.length = 10;
       objInfo.attribute = 'RPGUNIT';
       QLICOBJD(lib : object + library : '*SRVPGM' : objInfo : errorCode);

       // Change: source file
       srcFileAndMbr.name = srcFile.nm;
       srcFileAndMbr.lib = srcFile.lib;
       srcFileAndMbr.mbr = srcMbr;

       objInfo.keys = 1;
       objInfo.type = 1;
       objInfo.length = 30;
       objInfo.attribute = srcFileAndMbr;
       // QLICOBJD(lib : object + library : '*SRVPGM' : objInfo : errorCode);

      /end-free
     P                 E
