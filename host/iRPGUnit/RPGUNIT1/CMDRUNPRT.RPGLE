      //
      // Command Line Runner Printing Facilities.
      //
      // Design choice: this program should not contain any logic, because it is not tested.
      //

     H NoMain
      /copy RPGUNITY1,H_SPEC

      //----------------------------------------------------------------------
      //   Files
      //----------------------------------------------------------------------

     FQSYSPRT   o    f   80        printer OFLIND(*INOF) UsrOpn
     F                                     InfDS(logFile)

     D logFile         ds                  likeds(infDS_prtF_t)

      //----------------------------------------------------------------------
      //   Exports
      //----------------------------------------------------------------------

      /copy RPGUNITY1,CMDRUNPRT
      /copy RPGUNITY1,FDINFDS_PF
      /copy RPGUNITY1,TEMPLATES
      /copy RPGUNITY1,ERRORCODE
      /copy RPGUNITY1,QSPRILSP
      /copy RPGUNIT1,TESTCASE


      //----------------------------------------------------------------------
      //   Imports
      //----------------------------------------------------------------------

      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

      //----------------------------------------------------------------------
      //   Constants
      //----------------------------------------------------------------------

      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

       // Program Information Data Structure.
      /define SDS_EXTENDED
      /copy RPGUNITY1,SDS
      /undefine SDS_EXTENDED

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
      /free

        runCmd( 'OVRPRTF FILE(QSYSPRT) '
             + 'USRDTA(' + testPgmNm + ') '
             + 'SPLFNAME(' + SPLF_NAME + ')' );
        open QSYSPRT;

        clear errorCode;
        QSPRILSP(curr_splf: %size(curr_splf): 'SPRL0100': errorCode);

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


