      /if not defined(QUSRMBRD)
      /define QUSRMBRD
      *
      *  Retrieve Member Description (QUSRMBRD) API
     d QUSRMBRD...
     d                 pr                         extpgm('QUSRMBRD')
     d  o_rcvVar                  65535a          options(*varsize)
     d  i_lenRcvVar                  10i 0 const
     d  i_format                      8a   const
     d  i_qFile                      20A   const
     d  i_mbr                        10a   const
     d  i_ovrPrc                      1a   const
     d  io_errCode                65535a          options(*nopass: *varsize)    | OptGrp 1
     d  i_findMbrPrc                  1a   const  options(*nopass)              | OptGrp 2
      *
      *  MBRD0100 Format
     d mbrd0100_t...
     d                 ds                  qualified               based(pDummy)
     d  bytRet                       10i 0
     d  bytAvl                       10i 0
     d  qFile                        20a
     d  mbr                          10a
     d  attr                         10a
     d  srcType                      10a
     d  crtDatTim                    13A
     d  srcChgDatTim                 13A
     d  text                         50A
     d  isSrcFile                      N
      *
      *  MBRD0200 Format
     d mbrd0200_t...
     d                 ds                  qualified               based(pDummy)
     d  bytRet                       10i 0
     d  bytAvl                       10i 0
     d  qFile                        20a
     d  mbr                          10a
     d  attr                         10a
     d  srcType                      10a
     d  crtDatTim                    13A
     d  srcChgDatTim                 13A
     d  text                         50A
     d  isSrcFile                      N
     d  isRemoteFile                   N
     d  isLogicalFile                  N
     d  isODPShareAlw                  N
     d  reserved_1                    2a
     d  numTotRcds                   10i 0
     d  numDltRcds                   10i 0
     d  dtaSpcSize                   10i 0
     d  accPathSize                  10i 0
     d  numBasedMbr                  10i 0
     d  chgDatTim                    13A
     d  savDatTim                    13A
     d  rstDatTim                    13A
     d  expDate                       7a
     d  reserved_2                    6a
     d  numDaysUsed                  10i 0
     d  dateLastUsed                  7a
     d  useResetDate                  7a
     d  reserved_3                    2a
     d  dtaSpcSizeMlt                10i 0
     d  accPathSizeMlt...
     d                               10i 0
     d  textCcsid                    10i 0
     d  ofsAddInf                    10i 0
     d  lenAddInf                    10i 0
     d  numTotRcdsU                  10u 0
     d  numDltRcdsU                  10u 0
     d  reserved_4                    6a
      *
      /endif
