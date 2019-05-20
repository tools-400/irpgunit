      // ==========================================================================
      //  iRPGUnit - Product Version Procedures Definitions.
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

     H NoMain
      /include qinclude,H_SPEC
      /include qinclude,COPYRIGHT

      //----------------------------------------------------------------------
      //   IMPORTS
      //----------------------------------------------------------------------

      /include qinclude,VERSION

      /define COPYRIGHT_DSPEC
      /include qinclude,COPYRIGHT
      /undefine COPYRIGHT_DSPEC


     P getVersion...
     P                 b                   export
     D                 pi
     D  version                      20a
     D  date                         10a

         if (cRPGUNIT_DATE = 'xx.xx.xxxx'); // Date of dev. library
            date = %char(%date(): *iso);
         else;
            date = convertDateToISO(cRPGUNIT_DATE);
         endif;

         version = cRPGUNIT_VERSION;

     P                 e


     P convertDateToISO...
     P                 b
     D                 pi            10a
     D  euro                         10a   const

     D iso             s             10a
     D date            s               d

         date = %date(euro: *EUR);
         iso = %char(date: *ISO);

         return iso;

     P                 e
