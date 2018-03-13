      //
      // Dynamically call a procedure in a service program.
      //

     H NoMain
      /copy RPGUNITY1,H_SPEC

      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,CALLPROC
      /copy RPGUNITY1,RUNNER
      /copy RPGUNITY1,TEMPLATES


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,ERRORCODE
      /copy RPGUNITY1,QLEACTBNDP
      /copy RPGUNITY1,QLEGETEXP
      /copy RPGUNITY1,QLICVTTP
      /copy RPGUNITY1,RSLVSP


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
                   %len(%trimr(proc.procNm)) :
                   %trimr(proc.procNm) :
                   proc.procPtr :
                   exportType :
                   percolateErrors );

        if exportType <> PROCEDURE;
          proc.procPtr = *null;
        endif;

      /end-free
     P                 e

