
      // ==========================================================================
      //  iRPGUnit - Printing Facilities for CMDRUN.
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
      //   Files
      //----------------------------------------------------------------------

     FQSYSPRT   o    f   80        printer OFLIND(*INOF) UsrOpn
     F                                     InfDS(logFile)


     D logFile         ds                  likeds(infDS_prtF_t)

      //----------------------------------------------------------------------
      //   Prototypes
      //----------------------------------------------------------------------

      /include qinclude,CMDRUNPRT
      /include qinclude,FDINFDS_PF
      /include qinclude,ERRORCODE
      /include qinclude,SYSTEMAPI
      /include qinclude,TESTUTILS


      //----------------------------------------------------------------------
      //   Templates
      //----------------------------------------------------------------------

      /include qinclude,TEMPLATES


       // Program Information Data Structure.
      /include qinclude,SDS

       // Line for printing in log.
     D SPLF_NAME       c                   'RPGUNIT'
     D logLine         s             80a

       // Current log spooled file.
     D curr_splf       ds                  likeds(sprl0100_t) inz

     OQSYSPRT   e            ExcpLine    1
     O                       logLine             80

      //----------------------------------------------------------------------
      //   Procedures
      //----------------------------------------------------------------------

       //----------------------------------------------------------------------
       // Close the printer file. See prototype.
       //----------------------------------------------------------------------
     P clsPrt...
     P                 b                   export
     D                 pi
      /free

        close QSYSPRT;
        runCmd( 'DLTOVR FILE(QSYSPRT)' );

      /end-free
     P                 e


     P getSplF...
     P                 b                   export
     D                 pi                  likeds(splF_t)

     D splF            ds                  likeds(SplF_t)
      /free

        clear splF;

        if (not %open(QSYSPRT));
           return splF;
        endif;

        splF.system = curr_splf.system;
        splF.nm = curr_splf.name;
        splF.nbr = curr_splf.splfNbr;
        splF.job.name = curr_splf.job;
        splF.job.user = curr_splf.user;
        splF.job.nbr = curr_splf.jobNbr;

        return splF;

      /end-free
     P                 e


     P getPrtWidth...
     P                 b                   export
     D                 pi            10i 0
      /free

        return %len( logLine );

      /end-free
     P                 e


     P opnPrt...
     P                 b                   export
     D                 pi
     D  testPgmNm                          const like(Object_t.nm)

     D percolateErrors...
     D                 ds                  likeds(percolateErrors_t)
     D                                     inz(*likeds)
      /free

        runCmd( 'OVRPRTF FILE(QSYSPRT) '
             + 'USRDTA(' + testPgmNm + ') '
             + 'SPLFNAME(' + SPLF_NAME + ')' );
        open QSYSPRT;

        QSPRILSP(curr_splf: %size(curr_splf): 'SPRL0100': percolateErrors);

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Print a line. See prototype.
       //----------------------------------------------------------------------
     P prtLine...
     P                 b                   export
     D                 pi
     D  line                         80a   const
      /free

        logLine = line;
        except ExcpLine;

      /end-free
     P                 e


