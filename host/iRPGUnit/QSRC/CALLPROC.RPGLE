      //
      // Dynamically call a procedure in a service program.
      //

     H NoMain
      /include qinclude,H_SPEC

      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

      /include qinclude,CALLPROC
      /include qinclude,RUNNER
      /include qinclude,TEMPLATES


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /include qinclude,ERRORCODE
      /include qsysinc,QLEACTBNDP
      /include qsysinc,QLEGETEXP
      /include qsysinc,QLICVTTP
      /include qsysinc,RSLVSP


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

