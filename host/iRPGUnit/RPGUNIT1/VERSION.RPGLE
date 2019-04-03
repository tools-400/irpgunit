       //----------------------------------------------------------------------
       // Product Version Procedures Definitions.
       //----------------------------------------------------------------------

     H NoMain
      /copy RPGUNITY1,H_SPEC


       //----------------------------------------------------------------------
       //   IMPORTS
       //----------------------------------------------------------------------

      /copy RPGUNITY1,VERSION

      /define COPYRIGHT_DSPEC
      /copy RPGUNITY1,COPYRIGHT
      /undefine COPYRIGHT_DSPEC

       //----------------------------------------------------------------------
       //   CONSTANTS
       //----------------------------------------------------------------------

       //----------------------------------------------------------------------
       //   GLOBAL VARIABLES
       //----------------------------------------------------------------------

       //----------------------------------------------------------------------
       //   PROCEDURES
       //----------------------------------------------------------------------

     D convertDateToISO...
     D                 pr            10a   extproc('convertDateToISO')
     D  euro                         10a   const

       //--------------------------------------------------------------------
       //        Get Version Number
       //--------------------------------------------------------------------
     P getVersion...
     P                 b                   export
     D                 pi
     D  version                      20a
     D  date                         10a

     D p_date          c                   1

      /free

         if (%parms() >= p_date);
            date = convertDateToISO(cRPGUNIT_DATE);
         endif;

         version = cRPGUNIT_VERSION;

      /end-free
     P                 e


       //--------------------------------------------------------------------
       //        Convert Date to ISO Format
       //--------------------------------------------------------------------
     P convertDateToISO...
     P                 b
     D                 pi            10a
     D  euro                         10a   const

     D iso             s             10a
     D date            s               d

      /free

         date = %date(euro: *EUR);
         iso = %char(date: *ISO);

         return iso;

      /end-free
     P                 e
