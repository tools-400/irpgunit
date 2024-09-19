      // ==========================================================================
      //  iRPGUnit - ACPTSTT Unit Test Helper.
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
      //     >>PARM<<  OPTION(*SRCSTMT *EVENTF);
      //     >>PARM<<  DBGVIEW(*LIST);
      //   >>END-IMPORTANT<<
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

     H NoMain Option(*SrcStmt)

      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

      /include qunittest,SPLF_H

      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------

     D getNextLine     pr           256a   varying
     D                                     extproc('getNextLine')

     D rtvJobUsrNm     pr                  extproc('rtvJobUsrNm')
     D                                     like(UsrNm_t)

     D rtvLatestSplf   pr                  extproc('rtvLatestSplf')
     D                                     likeds(SplfId_t)
     D  usrNm                              const like(UsrNm_t)
     D  usrData                      10a   const

     D rtvSplfHdl      pr                  likeds(SplfId_t)
     D  splfNm                       10a   const
     D  usrData                      10a   const

     D listSplfCallback...
     D                 pr              n
     D                                     extproc('listSplfCallback')
     D  i_hSplF                        *   const
     D  i_pUserData                    *   const
     D  i_name                       10a   const
     D  i_qJob                             const likeds(Job_t)
     D  i_splFNbr                    10i 0 const
     D  i_status                     10a   const varying

     D readSplfBuf...
     D                 pr                  extproc('readSplfBuf')

      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy qinclude,ASSERT
      /copy qinclude,ERRORCODE
      /copy qinclude,SYSTEMAPI
      /copy qinclude,TEMPLATES
      /copy qinclude,USRSPC

      /copy qinclude,LSTSPLF

      //----------------------------------------------------------------------
      //   Constants
      //----------------------------------------------------------------------

       // SNA Character String (in spool files).
       // - New Line
     D NULL            c                   const(x'00')
     D NL              c                   const(x'15')
     D PP              c                   const(x'34')
     D CR              c                   const(x'0D')
     D FF              c                   const(x'0C')

      //----------------------------------------------------------------------
      //   Templates
      //----------------------------------------------------------------------

     D SplfId_t        ds                  qualified template
     D  qJob                               likeds(QlfJobNm_t)
     D  name                         10a
     D  number                       10i 0
     D  handle                       10i 0

     D userData_t      ds                  qualified template
     D  countDeleted                 10i 0

      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

       // Spool file.
     D splf            ds                  qualified
     D   qJob                              likeds(QlfJobNm_t)
     D   name                        10a
     D   number                      10i 0
     D   usrSpcNm                          likeds(Object_t)
     D   pUsrSpc                       *
         // - Handle
     D   hdl                         10i 0 inz(-1)
         // - Print Data User Space Current Position Pointer
     D   bufPos_p                      *
         // - Print Data User Space End Pointer
     D   usrSpcEnd_p                   *

      //----------------------------------------------------------------------
      //   Procedure Definition
      //----------------------------------------------------------------------

     P chkAndCloSplF...
     P                 b                   export
     D                 pi
      /free

        if (splf.hdl <> -1);
           cloSplf();
        endif;

      /end-free
     P                 e


     P cloSplf...
     P                 b                   export
     D                 pi

     D percolateErrors...
     D                 ds                  likeds(percolateErrors_t)
     D                                     inz(*likeds)
     D cmd             s            100a   varying
      /free

        QSPCLOSP( splf.hdl : percolateErrors );

        cmd = 'DLTSPLF FILE(' + %trim(splf.name) + ') ' +
                      'JOB(' + %trim(splf.qJob.jobNb) + '/' +
                               %trim(splf.qJob.usrNm) +'/' +
                               %trim(splf.qJob.jobNm) + ') ' +
                      'SPLNBR(' + %char(splf.number) + ')';

        qcmdexc(cmd: %len(cmd));

        clear splf;
        splf.hdl = -1;

      /end-free
     P                 e


     P dltSplfs...
     P                 b                   export
     D                 pi            10i 0
     D  splfNm                             const like(UsrNm_t)
     D  usrData                      10a   const

     D hLister         s                   like(hSplFLister_t)
     D userData        ds                  likeds(userData_t)
      /free

        clear userData;
        userData.countDeleted = 0;

        hLister = SplFLister_init('*': splFNm: usrData);
        // filterInfo.usrNm   = rtvJobUsrNm();
        SplFLister_list(hLister: %paddr('listSplfCallback'): %addr(userData));

        return userData.countDeleted;

      /end-free
     P                 e


     P listSplfCallback...
     P                 b                   export
     D                 pi              n
     D  i_hSplF                        *   const
     D  i_pUserData                    *   const
     D  i_name                       10a   const
     D  i_qJob                             const likeds(Job_t)
     D  i_splFNbr                    10i 0 const
     D  i_status                     10a   const varying

     D userData        ds                  likeds(userData_t)
     D                                     based(i_pUserData)
     D cmd             s            512a   varying
      /free

       cmd = 'DLTSPLF FILE(' + %trim(i_name) + ') +
              JOB(' + %trim(i_qJob.nbr) + '/' +
                      %trim(i_qJob.user) + '/' +
                      %trim(i_qJob.name) + ') +
              SPLNBR(' + %char(i_splFNbr) + ')';

       qcmdexc( cmd: %len(cmd) );

       userData.countDeleted += 1;

       return *on;

      /end-free
     P                 e


     P getNextLine...
     P                 b
     D                 pi           256a   varying

       // Character at current position.
     D currentChar     s              1a   based(splf.bufPos_p)
     D line            s            256a   varying
     D isLine          s               n

      /free

        isLine = *off;

        dow (splf.bufPos_p <= splf.usrSpcEnd_p);
          select;
          when (currentChar = NULL);
            splf.bufPos_p += %size( NULL );
            if (isLine);
              isLine = *off;
              return line;
            endif;
          when (currentChar = NL);
            splf.bufPos_p += %size( NL );
            isLine = *on;
          when (currentChar = PP);
            splf.bufPos_p = splf.bufPos_p + %size( PP ) + 2;
          when (currentChar = CR);
            splf.bufPos_p += %size( CR );
          when (currentChar = FF);
            splf.bufPos_p += %size( FF );
          when (currentChar >= x'40' and currentChar <= x'FE');
            if (isLine);
              line += currentChar;
            endif;
            splf.bufPos_p += %size( currentChar );
          other;
            splf.bufPos_p += 1;
          endsl;
        enddo;

        if (splf.bufPos_p > splf.usrSpcEnd_p);
          monitor;
            readSplfBuf();
            return getNextLine();
          on-error;
          endmon;
        endif;

        fail( 'Reached end of spooled file.' );

      /end-free
     P                 e


     P opnSplf...
     P                 b                   export
     D                 pi
     D  splfNm                       10a   const
     D  usrData                      10a   const


     D splfId          ds                  likeds(SplfId_t) inz
      /free

        clear splf;
        splfId = rtvSplfHdl( splfNm : usrData );

        splf.qJob = splfId.qJob;
        splf.name = splfId.name;
        splf.number = splfId.number;
        splf.hdl = splfId.handle;

        splf.usrSpcNm.nm  = 'RUSPOOL';
        splf.usrSpcNm.lib = 'QTEMP';

        splf.pUsrSpc = crtUsrSpc( splf.usrSpcNm :
                                 'RPGUnit - SelfTest - Spool File Contents.' );

        readSplfBuf();

        // Skip first 15 bytes according to "Decoding a Spooled File after Using the QSPGETSP API":
        // https://www.ibm.com/support/pages/decoding-spooled-file-after-using-qspgetsp-api
        splf.bufPos_p += 15;

      /end-free
     P                 e


     P readSplfBuf...
     P                 b
     D                 pi
       // QSPGETSP API: Reading an entire spooled file.
     D READ_ENTIRE_SPLF...
     D                 c                   const(-1)
       // QSP API generic header.
     D qspGenHdr       ds                  likeds(qspGenHdr_t)
     D                                     based(splf.pUsrSpc)
       // User Space to store spool contents.
     D percolateErrors...
     D                 ds                  likeds(percolateErrors_t)
     D                                     inz(*likeds)
      /free

        QSPGETSP( splf.hdl :
                  splf.usrSpcNm :
                  'SPFR0300' :
                  READ_ENTIRE_SPLF :
                  '*ERROR' :
                  percolateErrors );

        aEqual( 'C' : qspGenHdr.compInd );

        splf.bufPos_p    = splf.pUsrSpc + qspGenHdr.firstBufOff;
        splf.usrSpcEnd_p = splf.pUsrSpc + qspGenHdr.usrSpcSizeUsed;

      /end-free
     P                 e


     P rtvJobUsrNm...
     P                 b
     D                 pi            10a

       // Job attributes.
     D jobAttribs      ds                  likeds(dsRTVC0100)
       // Job attribute keys.
     D attribKeys      s             10i 0 Dim(1)
       // Current user profile name job attribute entry.
     D usrNmEnt        ds                  likeds(dsRTVC0100Ent)
     D percolateErrors...
     D                 ds                  likeds(percolateErrors_t)
     D                                     inz(*likeds)
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


     P rtvLatestSplf...
     P                 b
     D                 pi                  likeds(SplfId_t)
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

     D percolateErrors...
     D                 ds                  likeds(percolateErrors_t)
     D                                     inz(*likeds)
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

        latestSplfId.qJob.jobNm = latestSplfInfo.jobNm;
        latestSplfId.qJob.usrNm = latestSplfInfo.usrNm;
        latestSplfId.qJob.jobNb = latestSplfInfo.jobNb;
        latestSplfId.name           = latestSplfInfo.splfNm;
        latestSplfId.number         = latestSplfInfo.splfNb;

        return latestSplfId;

      /end-free
     P                 e


     P rtvSplfHdl...
     P                 b
     D                 pi                  likeds(SplfId_t)
     D  splfNm                       10a   const
     D  usrData                      10a   const

       // Latest spool file handle.
     D latestSplfHdl   s             10i 0
       // Latest spool file id.
     D latestSplfId    ds                  likeds(SplfId_t)
       // Current user profile name.
     D curUsrNm        s                   like(UsrNm_t)
     D percolateErrors...
     D                 ds                  likeds(percolateErrors_t)
     D                                     inz(*likeds)
      /free

        // A simple QSPOPNSP( splfHdl : '*' : *blank : *blank : splfNm : -1 : 1 : percolateErr
        // would be enough for regular (i.e., interactive and submitted) jobs, but it does
        // not work for remote commands (a.k.a. server jobs).  In the latter, the spool file
        // is created by a special job named QPRTJOB.

        curUsrNm = rtvJobUsrNm();
        latestSplfId = rtvLatestSplf( curUsrNm : usrData );

        QSPOPNSP( latestSplfHdl :
                  latestSplfId.qJob :
                  *blank :
                  *blank :
                  latestSplfId.name :
                  latestSplfId.number :
                  1 :
                  percolateErrors );

        latestSplfId.handle = latestSplfHdl;

        return latestSplfId;

      /end-free
     P                 e


     P splfLineStartsWith...
     P                 b                   export
     D                 pi
     D expString                    256a   const varying

     D line            s            256a   varying
      /free

        line = getNextLine();
        assertEqual( expString : %subst(line: 1: %len(expString)) );


      /end-free
     P                 e


     P splfContains...
     P                 b                   export
     D                 pi
     D expString                    256a   const varying

     D line            s            256a   varying
      /free

        dow (*on);
          line = getNextLine();
          if (%scan(expString: line) > 0);
            return;
          endif;
        enddo;


      /end-free
     P                 e


     P splfSkipLine...
     P                 b                   export
     D                 pi

      /free

        getNextLine();

      /end-free
     P                 e

