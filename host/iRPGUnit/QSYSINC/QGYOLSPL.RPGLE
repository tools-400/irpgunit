      //
      // Prototype for QGYOLSPL API.
      //
      // Open List of Spooled Files
      //
      // http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qgyolspl.htm
      //

     D QGYOLSPL        pr                  ExtPgm('QGYOLSPL')
     D  o_rcvVar                  32766a         options(*varsize)
     D  i_rcvVarLen                  10i 0 const
     D  o_listInfo                   80a
     D  i_nbrRcdToRtn                10i 0 const
     D  i_sortInfo                  256a   const options(*varsize)
     D  i_filterInfo                256a   const options(*varsize)
     D  i_qlfJobNm                         const like(QlfJobNm_t)
     D  i_listFmt                     8a   const
     D  io_error                  32766a         options(*varsize)
     D  i_filterFmt                   8a   const options(*nopass)

     D dsOSPL0100      ds                  qualified based(template)
     D  splfNm                       10a
     D  jobNm                        10a
     D  usrNm                        10a
     D  jobNb                         6a
     D  splfNb                       10i 0
     D  pgCnt                        10i 0
     D  curPg                        10i 0
     D  copiesToPrt                  10i 0
     D  outqNm                       10a
     D  outqLibNm                    10a
     D  usrData                      10a
     D  status                       10a
     D  formType                     10a
     D  priority                      2a
     D  intJobId                     16a
     D  intSplfId                    16a
     D  deviceType                   10a
     D                                2a
     D  extOff                       10i 0
     D  extLen                       10i 0
     D                                4a

     D dsOSPL0300      ds                  qualified based(template)
     D  jobNm                        10a
     D  usrNm                        10a
     D  jobNb                         6a
     D  splfNm                       10a
     D  splfNb                       10i 0
     D  fileStatus                   10i 0
     D  splfOpnDate                   7a
     D  splfOpnTime                   6a
     D  splfSchedule                  1a
     D  jobSysNm                     10a
     D  usrData                      10a
     D  splfFormType                 10a
     D  outqNm                       10a
     D  outqLibNm                    10a
     D  asp                          10i 0
     D  splfSize                     10i 0
     D  splfSizeMult                 10i 0
     D  pgCnt                        10i 0
     D  copiesToPrt                  10i 0
     D  priority                      1a
     D                                3a

       // Sort Information.
     D sortInfo_t      ds                  qualified based(template)
     D  keyCnt                       10i 0
     D  keys                               likeds(SortKey_t)
     D                                     Dim(64)

       // Sort Keys. Refer to QLGSORT API.
     D sortKey_t       ds                  qualified based(template)
     D  fieldStartPos                10i 0
     D  fieldLen                     10i 0
        // Data types: 0=signed binary, 6=character... Refer to QLGSORT.
     D  fieldDataType                 5i 0
        // Sort order: 1=ascending, 2=descending.
     D  sortOrder                     1a
     D  reserved                      1a
