      //
      // Prototype for QGYOLSPL API.
      //
      // Open List of Spooled Files
      //
      // http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qgyolspl.htm
      //

     DQGYOLSPL         pr                  ExtPgm('QGYOLSPL')
     D splfListEnt                32766a   options(*varsize)
     D splfListEntLen                10i 0 const
     D listInfo                      80a
     D nbOfRcdToRtn                  10i 0 const
     D sortInfo                     256a   const options(*varsize)
     D filterInfo                   256a   const options(*varsize)
     D qlfJobNm                            const like(QlfJobNm_t)
     D listFmt                        8a   const
     D error                      32766a   options(*varsize: *omit) noopt

     DdsOSPL0100       ds                  qualified based(template)
     D splfNm                        10a
     D jobNm                         10a
     D usrNm                         10a
     D jobNb                          6a
     D splfNb                        10i 0
     D pgCnt                         10i 0
     D curPg                         10i 0
     D copiesToPrt                   10i 0
     D outqNm                        10a
     D outqLibNm                     10a
     D usrData                       10a
     D status                        10a
     D formType                      10a
     D priority                       2a
     D intJobId                      16a
     D intSplfId                     16a
     D deviceType                    10a
     D                                2a
     D extOff                        10i 0
     D extLen                        10i 0
     D                                4a

     DdsOSPL0300       ds                  qualified based(template)
     D jobNm                         10a
     D usrNm                         10a
     D jobNb                          6a
     D splfNm                        10a
     D splfNb                        10i 0
     D fileStatus                    10i 0
     D splfOpnDate                    7a
     D splfOpnTime                    6a
     D splfSchedule                   1a
     D jobSysNm                      10a
     D usrData                       10a
     D splfFormType                  10a
     D outqNm                        10a
     D outqLibNm                     10a
     D asp                           10i 0
     D splfSize                      10i 0
     D splfSizeMult                  10i 0
     D pgCnt                         10i 0
     D copiesToPrt                   10i 0
     D priority                       1a
     D                                3a

       // Sort Information.
     D SortInfo_t      ds                  qualified based(template)
     D  keyCnt                       10i 0
     D  keys                               likeds(SortKey_t)
     D                                     Dim(64)

       // Sort Keys. Refer to QLGSORT API.
     D SortKey_t       ds                  qualified based(template)
     D  fieldStartPos                10i 0
     D  fieldLen                     10i 0
        // Data types: 0=signed binary, 6=character... Refer to QLGSORT.
     D  fieldDataType                 5i 0
        // Sort order: 1=ascending, 2=descending.
     D  sortOrder                     1a
     D  reserved                      1a
