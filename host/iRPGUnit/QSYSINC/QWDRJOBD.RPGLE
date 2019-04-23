      /IF NOT DEFINED(QWDRJOBD)
      /DEFINE QWDRJOBD
      *
      *  Retrieve Job Description Information (QWDRJOBD) API
     D QWDRJOBD...
     D                 PR                         extpgm('QWDRJOBD')
     D  o_rcvVar                  65535A          options(*varsize)
     D  i_lenRcvVar                  10I 0 const
     D  i_format                      8A   const
     D  i_qJobD                      20A   const
     D  io_errCode                65535A          options(*varsize)
      *
     D QWDRJOBD_qObj_t...
     D                 DS                  qualified               based(pDummy)
     D  name                         10A
     D  lib                          10A
      *
      *  JOBD0100 Format
     D jobd0100_t...
     D                 DS                  qualified               based(pDummy)
     D  bytRet                       10I 0
     D  bytAvl                       10I 0
     D  qJobD                              likeds(QWDRJOBD_qObj_t)
     D  user                         10A
     D  date                          8A
     D  sws                           8A
     D  qJobQ                              likeds(QWDRJOBD_qObj_t)
     D  jobPty                        2A
     D  hold                         10A
     D  qOutQ                              likeds(QWDRJOBD_qObj_t)
     D  outPty                        2A
     D  prtDev                       10A
     D  prtText                      30A
     D  syntax                       10I 0
     D  endSev                       10I 0
     D  logSev                       10I 0
     D  logLvl                        1A
     D  logText                      10A
     D  logClPgm                     10A
     D  inqMsgRpy                    10A
     D  devRcyAcn                    13A
     D  tsePool                      10A
     D  acgCde                       15A
     D  rtgDta                       80A
     D  text                         50A
     D  reserved_1                    1A
     D  ofsInlLibl                   10I 0
     D  numInlLiblE                  10I 0
     D  ofsRqsDta                    10I 0
     D  lenRqsDta                    10I 0
     D  jobMsgQMx                    10I 0
     D  jobMsgQFl                    10A
     D  dateCYMD                     10A
     D  alwMltThd                    10A
     D  splfAcn                      10A
     D  ofsInlAspGrp                 10I 0
     D  numInlAspGrpE                10I 0
     D  lenInlAspGrpE                10I 0
     D  ddmCnv                       10A
     D  logOutput                    10A
      *   Initial library list                  Array (*) of CHAR(11)
      *   Request data                          CHAR(*)
      *   Initial ASP group information entry   Array (*) of CHAR(*)
      *
      /ENDIF
