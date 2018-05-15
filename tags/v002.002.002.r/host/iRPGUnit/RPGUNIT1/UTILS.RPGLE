      //
      // String procedures.
      //

     H NoMain
      /copy RPGUNITY1,H_SPEC

      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNIT1,TESTCASE


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,MILIB
      /copy RPGUNITY1,PGMMSG
      /copy RPGUNITY1,OSAPI


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------


      //----------------------------------------------------------------------
      //   Type Templates
      //----------------------------------------------------------------------

      /copy RPGUNITY1,TEMPLATES


      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------


      //----------------------------------------------------------------------
      //   Procedure Definitions
      //----------------------------------------------------------------------


     P waitSeconds...
     P                 b                   export
     D                 pi
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
     D                 pi
     D  message                     132a   const varying
      /free

         sndStsMsg(message);

      /end-free
     P                 e


     P restoreStatusMessage...
     P                 b                   export
     D                 pi
      /free

         rstStsMsg();

      /end-free
     P                 e


     P clearStatusMessage...
     P                 b                   export
     D                 pi
      /free

         sndStsMsg('');

      /end-free
     P                 e


     P getMemberType...
     P                 b                   export
     D                 pi            10a
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

