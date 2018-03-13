      //
      // Command Line Runner logging facilities.
      //

     H NoMain
      /copy RPGUNITY1,H_SPEC

      //----------------------------------------------------------------------
      //   Exports
      //----------------------------------------------------------------------

      /copy RPGUNITY1,CMDRUNLOG


      //----------------------------------------------------------------------
      //   Imports
      //----------------------------------------------------------------------

      /copy RPGUNITY1,CMDRUNPRT
      /copy RPGUNITY1,TEMPLATES
      /copy RPGUNITY1,STRING
      /copy RPGUNITY1,VERSION


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

       // Log a header message.
     D logHdr          pr                  extproc('logHdr')
        // Name of the service program containing the tests.
     D  srvPgm                             const likeds(Object_t)

     D getFormattedJob...
     D                 pr            32A   varying
     D                                     extproc('getFormattedJob')

     D getLeftMargin...
     D                 pr            32A   varying
     D                                     extproc('getLeftMargin')

      //----------------------------------------------------------------------
      //   Constants
      //----------------------------------------------------------------------

     D indent          c                   const('  ')
     D separator       c                   const(' - ')
     D lineSeparator   c                   const('-----------------------')


      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

       // Was the spool file header already printed?
     D hdrWasPrinted   s               n
       // Test service program being run.
     D g_srvPgm        ds                  likeds(Object_t)
       // Specifies how detailed the test run report should be.
     D g_detail        s             10a   inz(DETAIL_BASIC)
       // Specifies whether a report is created.
     D g_output        s             10a   inz(OUTPUT_ALLWAYS)

       //----------------------------------------------------------------------
       //   Program Status Data Structure
       //----------------------------------------------------------------------

      /define SDS_EXTENDED
      /copy RPGUNITY1,SDS
      /undefine SDS_EXTENDED

      //----------------------------------------------------------------------
      //   Procedures
      //----------------------------------------------------------------------

       //----------------------------------------------------------------------
       // Linefeed.
       //----------------------------------------------------------------------
     P linefeed...
     P                 b                   export
     D                 pi
      /free

        if (g_output = OUTPUT_NONE);
           return;
        endif;

        prtLine('');

      /end-free
     P                 e

       //----------------------------------------------------------------------
       // Log the completion message. See prototype.
       //----------------------------------------------------------------------
     P logCompMsg...
     P                 b                   export
     D                 pi
     D  msg                       16384a   const varying options(*Varsize)
     D  failures                     10i 0 const
     D  errors                       10i 0 const
      /free

        if (g_output = OUTPUT_NONE);
           return;
        endif;

        if (g_output = OUTPUT_ERROR and (failures + errors = 0));
           return;
        endif;

        logHdr( g_srvPgm );
        logRawLine( msg );
        clsPrt();
        clear hdrWasPrinted;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Log an error event. See prototype.
       //----------------------------------------------------------------------
     P logError...
     P                 b                   export
     D                 pi
     D  testNm                             const like(ProcNm_t)
     D  excpMsgInfo                        const likeds(Msg_t)

     D line            s           2048a   varying
      /free

        if (g_output = OUTPUT_NONE);
          return;
        endif;

        logHdr( g_srvPgm );

        prtLine( getLeftMargin() + %trimr(testNm) + separator + 'ERROR' );

        line = '';
        if excpMsgInfo.id <> *blank;
          line += excpMsgInfo.id;
          line += separator;
        endif;
        line += excpMsgInfo.txt;
        logRawLine( line );

        if ( excpMsgInfo.sender.procNm <> *blank and
             excpMsgInfo.sender.qPgm.nm  <> *blank and
             excpMsgInfo.sender.specNb <> *blank );
          logStackEntry( excpMsgInfo.sender );
        endif;

        prtLine( getLeftMargin() + lineSeparator );
        linefeed();

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Log a failure event. See prototype.
       //----------------------------------------------------------------------
     P logFailure...
     P                 b                   export
     D                 pi
     D  testNm                             const like(ProcNm_t)
     D  failure                            const
     D                                     likeds(AssertFailEvtLong_t)

       // Index.
     D i               s             10i 0
      /free

        if (g_output = OUTPUT_NONE);
          return;
        endif;

        logHdr( g_srvPgm );

        logRawLine( %trimr(testNm) + separator + 'FAILURE' );
        logRawLine( failure.msg );

        for i = 1 to failure.callStk.numE;
          logStackEntry( failure.callStk.entry(i).sender );
        endfor;

        prtLine( getLeftMargin() + lineSeparator );
        linefeed();

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Print the report header.
       //----------------------------------------------------------------------
     P logHdr...
     P                 b
     D                 pi
     D  srvPgm                             const likeds(Object_t)

     D version         s             20a
     D date            s             10a
      /free

        if not hdrWasPrinted;
          getVersion(version: date);
          opnPrt( srvPgm );
          logRawLine( '*** Tests from ' + %trim(srvPgm.nm) + ' ***' +
                      ' (iRPGUnit v' + %trim(version) + ')' );
          logRawLine('Date : ' + %char(%date()) + ' / ' + %char(%time(): *HMS));
          logRawLine('Job  : ' + getFormattedJob());
          logRawLine('User : ' + %trimR(sds.currUser));
          logRawLine('iRPGUnit : ' + %trimR(sds.currUser));
          linefeed();
          hdrWasPrinted = *on;
        endif;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Append a line to the report. Splitt long lines.
       // !!INFO!! Exported for self-test only.
       //----------------------------------------------------------------------
     P logRawLine...
     P                 b                   export
     D                 pi
     D  line                       2048a   Value varying

       // Printing area width (in characters).
     D prtWidth        s             10i 0
     D leftMargin      s             32a   varying

     D RIGHT_MARGIN    c                   5
      /free

        if line = *blank;    // Do not log blank lines.
          return;
        endif;

        line = %trimr(line);
        leftMargin = getLeftMargin();

        prtWidth = getPrtWidth() - %len(leftMargin) - RIGHT_MARGIN;

        dow %len(line) > prtWidth;
          prtLine( leftMargin + %subst( line : 1 : prtWidth ) );
          line = %subst( line : prtWidth+1 );
        enddo;

        if (%len(%trimR(line)) > 0);
          prtLine( leftMargin + line );
        endif;

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Append a SUCCESS message to the report.
       //----------------------------------------------------------------------
     P logSuccess...
     P                 b                   export
     D                 pi
     D  testNm                             const like(ProcNm_t)
     D  assertionCnt                 10i 0 const
      /free

        if (g_detail <> DETAIL_ALL);
           return;
        endif;

        if (g_output <> OUTPUT_ALLWAYS);
           return;
        endif;

        logHdr( g_srvPgm );

        logRawLine( %trimr(testNm) + ' - Success' );
        logRawLine( indent + %char(assertionCnt) + ' assertions' );
        logRawLine( lineSeparator );
        linefeed();

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Print a call stack entry.
       //----------------------------------------------------------------------
     P logStackEntry...
     P                 b                   export
     D                 pi
     D  sender                             const likeds(MsgSender_t)

     D line            s            256a   varying
      /free

          line = fmtStackEntry( sender );
          logRawLine( line );

      /end-free
     P                 e


       //----------------------------------------------------------------------
       // Formats a call stack entry.
       //----------------------------------------------------------------------
     P fmtStackEntry...
     P                 b
     D                 pi                  like(Line_t)
     D  sender                             const likeds(MsgSender_t)

     D line            s                   like(Line_t)
       // Specification number. Special value '*N' if not available.
     D specNb          s             10a   varying
      /free

          if (%trim(sender.specNb) = '');
             specNb = '*N';
          else;
             specNb = %trimL(%trim(sender.specNb): '0');
          endif;

          line = indent
               + %trim(sender.procNm)
               + ' ('
               + %trim(sender.qPgm.nm)
               + '->'
               + %trim(sender.qMod.nm)
               + ':'
               + %trim(specNb)
               + ')';
          Return line;

      /end-free
     P                 e


     P setLogContext...
     P                 b                   export
     D                 pi
     D  testPgm                            const likeds(Object_t)
     D  detail                       10a   const
     D  output                       10a   const
      /free

        g_srvPgm = testPgm;
        g_detail = detail;
        g_output = output;

        if (g_output = OUTPUT_NONE);
           return;
        endif;

        logHdr( g_srvPgm );

      /end-free
     P                 e


     P getLogSplF...
     P                 b                   export
     D                 pi                  likeds(SplF_t)

     D splF            ds                  likeds(SplF_t)
      /free

         clear splF;

         if (hdrWasPrinted);
            splF = getSplF();
         endif;

         return getSplF();

      /end-free
     P                 e


     P getFormattedJob...
     P                 b                   export
     D                 pi            32A   varying
      /free

         return %editc(sds.nbr: 'X') + '/' +
                %trimR(sds.user) + '/' +
                %trim(sds.job);

      /end-free
     P                 e


     P getLeftMargin...
     P                 b                   export
     D                 pi            32A   varying

     D leftMargin      s             32A   varying static

     D LEFT_MARGIN     c                   5
      /free

        if (%len(leftMargin) <> LEFT_MARGIN);
          leftMargin = spaces(LEFT_MARGIN);
        endif;

        return leftMargin;

      /end-free
     P                 e

