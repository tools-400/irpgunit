      //
      // Extract exported procedures from a service program.
      //

     H NoMain
      /copy RPGUNITY1,H_SPEC


       //----------------------------------------------------------------------
       //   Public Procedure Prototypes
       //----------------------------------------------------------------------

      /copy RPGUNITY1,EXTPRC
      /copy RPGUNITY1,TEMPLATES


       //----------------------------------------------------------------------
       //   Private Procedure Prototypes
       //----------------------------------------------------------------------

       // Retrieve Procedure Info.
       // Stores procedure info in a user space.
     D rtvProcInfo     pr
        // Service program to analyze.
     D  srvPgm                             value likeds(Object_t)
        // Qualified user space name.
     D  usrSpc                             const likeds(Object_t)


       //----------------------------------------------------------------------
       //   Imported Procedures
       //----------------------------------------------------------------------

      /copy RPGUNITY1,APILIST
      /copy RPGUNITY1,QBNLSPGM
      /copy RPGUNITY1,USRSPC


       //----------------------------------------------------------------------
       //   Global DS
       //----------------------------------------------------------------------

      /copy RPGUNITY1,ERRORCODE


       //----------------------------------------------------------------------
       //   Procedures Definition
       //----------------------------------------------------------------------

       //----------------------------------------------------------------------
       // Counts the number of procedure in the liste. See prototype.
       //----------------------------------------------------------------------
     P cntProc...
     P                 b                   export
     D                 pi            10i 0
     D  procList                           const likeds(ProcList_t)

       // Procedure list header.
     D procListHdr     ds                  likeds(ListHdr_t)
     D                                     based(procList.hdr)

      /free

        return procListHdr.entCnt;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Returns a list of the procedures. See prototype.
       //----------------------------------------------------------------------
     P loadProcList...
     P                 b                   export
     D                 pi                  likeds(ProcList_t)
     D  srvPgm                             const likeds(Object_t)

       // List header structure.
     D listHdr         ds                  likeds(ListHdr_t)
     D                                     based(procList.hdr)
       // Extracted procedure list.
     D procList        ds                  likeds(ProcList_t)
       // Qualified name of the user space that stores the proc info.
     D usrSpc          ds                  likeds(Object_t)

      /free

        usrSpc.nm  = 'RUPROCLIST';
        usrSpc.lib = 'QTEMP';

        procList.hdr = crtUsrSpc( usrSpc: 'RPGUnit - Procedure list.');
        rtvProcInfo( srvPgm: usrSpc );

        procList.current = procList.hdr + listHdr.listOff;

        return procList;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Adapts a ProcList_t interface into a ProcNmList_t. See prototype.
       //----------------------------------------------------------------------
     P getProcNmList...
     P                 b                   export
     D                 pi                  likeds(ProcNmList_t)
     D  procList                           likeds(ProcList_t)

     D procNmList      ds                  likeds(ProcNmList_t)

      /free

        procNmList.handle   = %addr( procList );
        procNmList.cnt      = %paddr( cntProc );
        procNmList.getNm    = %paddr( getProcNm );
        procNmList.goToNext = %paddr( goToNextProc );

        return procNmList;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Returns the current procedure name. See prototype.
       //----------------------------------------------------------------------
     P getProcNm...
     P                 b                   export
     D                 pi                  like(ProcNm_t)
     D  procList                           const likeds(ProcList_t)

       // Procedure description.
     D procDesc        ds                  likeds(SPGL0610_t)
     D                                     based(procList.current)
       // A buffer and its pointer to access the procedure name.
     D procNmBuffer    s            256a   based(procNm_p)
     D procNm_p        s               *
       // The procedure name, to be returned.
     D procNm          s                   like(ProcNm_t)

      /free

        procNm_p = procList.hdr + procDesc.procNmOff;
        procNm = %subst(procNmBuffer: 1: procDesc.procNmSize);

        return procNm;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Go to the next procedure info entry. See prototype.
       //----------------------------------------------------------------------
     P goToNextProc...
     P                 b                   export
     D                 pi
     D  procList                            likeds(ProcList_t)

     D procDesc        ds                  likeds(SPGL0610_t)
     D                                     based(procList.current)

      /free

        procList.current += procDesc.size;

      /end-free
     P goToNextProc    e


       //----------------------------------------------------------------------
       // Stores procedure info in a user space. See prototype.
       //----------------------------------------------------------------------
     P rtvProcInfo...
     P                 b
     D                 pi
     D  srvPgm                             value likeds(Object_t)
     D  usrSpc                             const likeds(Object_t)

      /free

        if srvPgm.lib = *blank;
          srvPgm.lib = '*LIBL';
        endif;

        QBNLSPGM( usrSpc :
                  'SPGL0610' :
                  srvPgm :
                  percolateErrors );

      /end-free
     P                 e
