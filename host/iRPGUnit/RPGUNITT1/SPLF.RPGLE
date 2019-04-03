      // =====================================================================
      //
      // Spool file test helper.
      //
      // =====================================================================
      //   >>PRE-COMPILER<<
      //     >>CRTCMD<<  RUCRTTST   TSTPGM(&LI/&OB) SRCFILE(&SF);
      //     >>COMPILE<<
      //       >>PARM<< DBGVIEW(*LIST);
      //     >>END-COMPILE<<
      //     >>EXECUTE<<
      //   >>END-PRE-COMPILER<<
      // =====================================================================

     H NoMain Option(*SrcStmt)


      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,SPLF


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

     D bufEqual        pr              *
     D  expBuf                      256a   const varying
     D  actBuf_p                       *   const

     D findInSpool     pr              *
     D  charToFind                    1a   const
     D  startPos                       *   const
     D  endPos                         *   const

     D rtvJobUsrNm     pr                  like(UsrNm_t)

     D rtvLatestSplf   pr                  likeds(SplfId_t)
     D  usrNm                              const like(UsrNm_t)
     D  usrData                      10a   const

     D rtvSplfHdl      pr            10i 0
     D  splfNm                       10a   const
     D  usrData                      10a   const


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,ERRORCODE
      /copy RPGUNITY1,QGYCLST
      /copy RPGUNITY1,QGYGTLE
      /copy RPGUNITY1,QGYOLSPL
      /copy RPGUNITY1,OPNLIST
      /copy RPGUNITY1,QSPCLOSP
      /copy RPGUNITY1,QSPGETSP
      /copy RPGUNITY1,QSPOPNSP
      /copy RPGUNITY1,QWCRTVCA
      /copy RPGUNITY1,TEMPLATES
      /copy RPGUNITY1,USRSPC
      /copy RPGUNIT1,TESTCASE


      //----------------------------------------------------------------------
      //   Constants
      //----------------------------------------------------------------------

       // SNA Character String (in spool files).
       // - New Line
     D NL              c                   const(x'15')


      //----------------------------------------------------------------------
      //   Templates
      //----------------------------------------------------------------------

     D SplfId_t        ds                  qualified based(template)
     D  qlfJobNm                           likeds(QlfJobNm_t)
     D  nm                           10a
     D  nb                           10i 0


      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

       // Spool file.
     D splf            ds                  qualified
         // - Handle
     D   hdl                         10i 0 inz(-1)
         // - Print Data User Space Current Position Pointer
     D   bufPos_p                      *
         // - Print Data User Space End Pointer
     D   usrSpcEnd_p                   *


      //----------------------------------------------------------------------
      //   Procedure Definition
      //----------------------------------------------------------------------

     PbufEqual         b
     DbufEqual         pi              *
     D expBuf                       256a   const varying
     D actBuf_p                        *   const

       // Actual buffer contents.
     D actBuf          s            256a   based(actBuf_p)

      /free

        aEqual( expBuf :
                %subst( actBuf : 1 : %len(expBuf) ) );

        return actBuf_p + %len(expBuf);

      /end-free
     P                 e


     PchkAndCloSplF    b                   export
     DchkAndCloSplF    pi
      /free

        if (splf.hdl <> -1);
           cloSplf();
        endif;

      /end-free
     P                 e


     PcloSplf          b                   export
     DcloSplf          pi
      /free

        QSPCLOSP( splf.hdl : percolateErrors );
        clear splf;
        splf.hdl = -1;

      /end-free
     P                 e


     PfindInSpool      b
     DfindInSpool      pi              *
     D charToFind                     1a   const
     D startPos                        *   const
     D endPos                          *   const

       // Character at current position.
     D currentChar_p   s               *
     D currentChar     s              1a   based(currentChar_p)

      /free

        currentChar_p = startPos;

        dow currentChar_p <= endPos;
          if currentChar = charToFind;
            return currentChar_p;
          endif;
          currentChar_p += 1;
        enddo;

        fail( 'Character "' + charToFind + '" not found in buffer' );

      /end-free
     P                 e


     P opnSplf         b                   export
     D opnSplf         pi
     D  splfNm                       10a   const
     D  usrData                      10a   const

       // QSPGETSP API: Reading an entire spooled file.
     D READ_ENTIRE_SPLF...
     D                 c                   const(-1)
       // QSP API generic header.
     D qspGenHdr_p     s               *
     D qspGenHdr       ds                  likeds(qspGenHdr_t)
     D                                     based(qspGenHdr_p)
       // User Space to store spool contents.
     D usrSpcNm        ds                  likeds(Object_t)

      /free

        clear splf;
        splf.hdl = rtvSplfHdl( splfNm : usrData );

        usrSpcNm.nm  = 'RUSPOOL';
        usrSpcNm.lib = 'QTEMP';

        qspGenHdr_p = crtUsrSpc( usrSpcNm :
                                 'RPGUnit - SelfTest - Spool File Contents.' );

        QSPGETSP( splf.hdl :
                  usrSpcNm :
                  'SPFR0300' :
                  READ_ENTIRE_SPLF :
                  '*ERROR' :
                  percolateErrors );

        aEqual( 'C' : qspGenHdr.compInd );

        splf.bufPos_p    = qspGenHdr_p + qspGenHdr.firstBufOff;
        splf.usrSpcEnd_p = qspGenHdr_p + qspGenHdr.usrSpcSizeUsed;

      /end-free
     P                 e


     PrtvJobUsrNm      b
     DrtvJobUsrNm      pi            10a

       // Job attributes.
     D jobAttribs      ds                  likeds(dsRTVC0100)
       // Job attribute keys.
     D attribKeys      s             10i 0 Dim(1)
       // Current user profile name job attribute entry.
     D usrNmEnt        ds                  likeds(dsRTVC0100Ent)

      /free

        attribKeys(1) = CUR_USR_NM;

        QWCRTVCA( jobAttribs :
                  %size(jobAttribs) :
                  'RTVC0100' :
                  %elem(attribKeys) :
                  attribKeys :
                  percolateErrors );

        if (jobAttribs.attribCnt <> 1);
          fail( 'QWCRTVCA returned an unexpected number of job attributes' );
        endif;

        usrNmEnt = jobAttribs.attribEnts;

        if (usrNmEnt.key <> CUR_USR_NM) or
           (usrNmEnt.dataType <> 'C') or
           (usrNmEnt.dataLen <> 10);
          fail( 'QWCRTVA returned an unexpected attribute format' );
        endif;

        return usrNmEnt.data;

      /end-free
     P                 e


     P rtvLatestSplf   b
     D rtvLatestSplf   pi                  likeds(SplfId_t)
     D  usrNm                              const like(UsrNm_t)
     D  usrData                      10a   const

       // Retrieve only one record.
     D ONE_RECORD      c                   const(1)
       // Retrieve spool files from all jobs.
     D ALL_JOBS        c                   const(*blank)
       // Do not retrieve any record.
     D NO_RETRIEVAL    c                   const(*zero)
       // The entire list is build synchronously.
     D BUILD_ENTIRE_LIST_SYNCHRONOUSLY...
     D                 c                   const(-1)
       // Latest spool file id.
     D latestSplfId    ds                  likeds(SplfId_t)
       // Latest spool file info from QGYOLSPL API.
     D latestSplfInfo  ds                  likeds(dsOSPL0300)
       // Open list information for QGYOLSPL API.
     D listInfo        ds                  likeds(dsOpnList)
       // Open list handle.
     D opnListHdl      s                   like(dsOpnList.rqsHdl)
       // Last spool file record index.
     D lastRcdIdx      s             10i 0
       // Spool file sorting information.
     D sortInfo        ds                  likeds(SortInfo_t)
       // Spool file filtering information, according to OSPF0100 format.
     D filterInfo      ds                  qualified
     D  usrNmCnt                     10i 0 inz(1)
     D   usrNm                       10a
     D                                2a   inz(x'00')
     D  outqNmCnt                    10i 0 inz(1)
     D   outqNm                      10a   inz('*ALL')
     D   outqLibNm                   10a   inz(*blank)
     D  formType                     10a   inz('*ALL')
     D  usrData                      10a
     D  statusCnt                    10i 0 inz(1)
     D   splfStatus                  10a   inz('*READY')
     D                                2a   inz(x'00')
     D  deviceNmCnt                  10i 0 inz(1)
     D   deviceNm                    10a   inz('*ALL')
     D                                2a   inz(x'00')

      /free

        filterInfo.usrNm   = usrNm;
        filterInfo.usrData = usrData;

        sortInfo = *allx'00';

        QGYOLSPL( latestSplfInfo :
                  NO_RETRIEVAL :
                  listInfo :
                  BUILD_ENTIRE_LIST_SYNCHRONOUSLY :
                  sortInfo :
                  filterInfo :
                  ALL_JOBS :
                  'OSPL0300' :
                  percolateErrors );

        if ( listInfo.retRcdCnt <> 0 );
          fail( 'QGYOLSPL unexpectedly returned a record' );
        endif;

        if ( listInfo.infoCompInd <> 'C' );
          fail( 'QGYOLSPL could not retrieve complete info. ' +
                'Indicator=' + listInfo.infoCompInd );
        endif;

        if ( listInfo.firstRcdIdx <> 0 );
          fail( 'QGYOLSPL unexpectedly returned a first record' );
        endif;

        assert( listInfo.totalRcdCnt > 0 :
                'No spool file found for user ' + %trimr(usrNm)
                + ' and user data ' + %trimr(usrData) );

        opnListHdl = listInfo.rqsHdl;
        lastRcdIdx = listInfo.totalRcdCnt;

        QGYGTLE( latestSplfInfo :
                 %size(latestSplfInfo) :
                 opnListHdl :
                 listInfo :
                 ONE_RECORD :
                 lastRcdIdx :
                 percolateErrors );

        QGYCLST( listInfo.rqsHdl : percolateErrors );

        latestSplfId.qlfJobNm.jobNm = latestSplfInfo.jobNm;
        latestSplfId.qlfJobNm.usrNm = latestSplfInfo.usrNm;
        latestSplfId.qlfJobNm.jobNb = latestSplfInfo.jobNb;
        latestSplfId.nm             = latestSplfInfo.splfNm;
        latestSplfId.nb             = latestSplfInfo.splfNb;

        return latestSplfId;

      /end-free
     P                 e


     P rtvSplfHdl      b
     D rtvSplfHdl      pi            10i 0
     D  splfNm                       10a   const
     D  usrData                      10a   const

       // Latest spool file handle.
     D latestSplfHdl   s             10i 0
       // Latest spool file id.
     D latestSplfId    ds                  likeds(SplfId_t)
       // Current user profile name.
     D curUsrNm        s                   like(UsrNm_t)

      /free

        // A simple QSPOPNSP( splfHdl : '*' : *blank : *blank : splfNm : -1 : 1 : percolateErr
        // would be enough for regular (i.e., interactive and submitted) jobs, but it does
        // not work for remote commands (a.k.a. server jobs).  In the latter, the spool file
        // is created by a special job named QPRTJOB.

        curUsrNm = rtvJobUsrNm();
        latestSplfId = rtvLatestSplf( curUsrNm : usrData );

        QSPOPNSP( latestSplfHdl :
                  latestSplfId.qlfJobNm :
                  *blank :
                  *blank :
                  latestSplfId.nm :
                  latestSplfId.nb :
                  1 :
                  percolateErrors );

        return latestSplfHdl;

      /end-free
     P                 e


     PsplfLineStartsWith...
     P                 b                   export
     DsplfLineStartsWith...
     D                 pi
     D expString                    256a   const varying

      /free

        splf.bufPos_p = findInSpool( NL : splf.bufPos_p : splf.usrSpcEnd_p );
        splf.bufPos_p = bufEqual( expString : splf.bufPos_p + 1 + 3 );

      /end-free
     P                 e


     PsplfSkipLine...
     P                 b                   export
     D                 pi

      /free

        splf.bufPos_p = findInSpool( NL : splf.bufPos_p : splf.usrSpcEnd_p );
        splf.bufPos_p = splf.bufPos_p + %size( NL );

      /end-free
     P                 e

