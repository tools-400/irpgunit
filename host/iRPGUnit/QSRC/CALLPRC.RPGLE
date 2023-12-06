      // ==========================================================================
      //  iRPGUnit - Dynamically Call a Procedure in a SRVPGM.
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
      //   Exported Procedures
      //----------------------------------------------------------------------

      /include qinclude,CALLPRC

      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /include qinclude,CMDRUNSRV
      /include qinclude,ERRORCODE
      /include qinclude,MILIB
      /include qinclude,SYSTEMAPI
      /include qinclude,TEMPLATES

      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

       // Abstract procedure to dynamically call a procedure.
     D callDynProc     pr                  extproc(callDynProc_p)


      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

       // Current procedure pointer.
     D callDynProc_p   s               *   procptr


      //----------------------------------------------------------------------
      //   Procedure Definitions
      //----------------------------------------------------------------------

       //----------------------------------------------------------------------
       // Get activation mark. See prototype.
       //----------------------------------------------------------------------
     P activateSrvPgm...
     P                 b                   export
     D                 pi            10i 0
     D  srvPgm                             value likeds(Object_t)

       // Activation mark.
     D actMark         s             10i 0 inz(0)
       // Authority mask.
     D auth            s              2a   inz(*LoVal)
       // Objet type as hexadecimal value.
     D hexType         s              2a   inz(*LoVal)
       // System pointer to a service program.
     D srvPgmSP        s               *   procptr

     D percolateErrors...
     D                 ds                  likeds(percolateErrors_t)
     D                                     inz(*likeds)
      /free

        if srvPgm.lib = *blank;
          srvPgm.lib = '*LIBL';
        endif;

        // Get object type as hex value.
        QLICVTTP( '*SYMTOHEX' : '*SRVPGM' : hexType : percolateErrors );

        // Retrieve system pointer.
        monitor;
          srvpgmSP = rslvSP( hexType:
                             srvPgm.nm:
                             srvPgm.lib:
                             auth );
        on-error;
          raiseRUError( 'Failed to retrieve system pointer for '
                            + %trimr(srvPgm.nm)
                            + '.' );
        endmon;

        // Activate service program.
        actMark = QleActBndPgm( srvpgmSP : *omit : *omit : *omit : *omit );

        return actMark;

      /end-free
     P                 e


     P callProcByPtr...
     P                 b                   export
     D                 pi
     D  procPtr                        *   const procptr
      /free

        if procPtr <> *null;
          callDynProc_p = procPtr;
          callDynProc();
        endif;

      /end-free
     P                 e


     P rslvProc...
     P                 b                   export
     D                 pi
     D  proc                               likeds(Proc_t)
     D  actMark                            const like(ActMark_t)

       // Type of export in a service program.
     D exportType      s             10i 0 inz(0)
       // One export type is PROCEDURE.
     D PROCEDURE       c                   const(1)

     D percolateErrors...
     D                 ds                  likeds(percolateErrors_t)
     D                                     inz(*likeds)
      /free

        // Get export.
        QleGetExp( actMark :
                   0 :
                   %len(proc.procNm) :
                   proc.procNm :
                   proc.procPtr :
                   exportType :
                   percolateErrors );

        if exportType <> PROCEDURE;
          proc.procPtr = *null;
        endif;

      /end-free
     P                 e

