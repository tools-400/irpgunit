      /IF NOT DEFINED(QUSRJOBI)
      /DEFINE QUSRJOBI
      *
      /IF NOT DEFINED(qJob_t    )
      /DEFINE qJob_t
      *   Qualified job name
     D qJob_t          DS                  qualified           based(pDummy)
     D  name                         10A
     D  user                         10A
     D  nbr                           6A
      /ENDIF
      *
      *  Retrieve Job Information (QUSRJOBI) API
     D QUSRJOBI...
     D                 PR                  extpgm('QUSRJOBI')
     D  o_rcvVar                  65535A          options(*varsize)
     D  i_rcvVarLen                  10I 0 const
     D  i_format                      8A   const
     D  i_qJob                       26A   const
     D  i_intJobID                   16A   const
     D  io_errCode                65535A          options(*nopass: *varsize)    OptGrp 1
     D  i_resPrfStat                  1A   const  options(*nopass)              OptGrp 2
      *
      *  This format returns basic performance information about a job.
     D jobi0100_t      DS                  qualified           based(pDummy)
     D  bytRet                       10I 0
     D  bytAvl                       10I 0
     D  job                          10A
     D  user                         10A
     D  nbr                           6A
     D  intJobID                     16A
     D  status                       10A
     D  type                          1A
     D  subType                       1A
     D  reserved_1                    2A
     D  runPty                       10I 0
     D  timeSlice                    10I 0
     D  dftWait                      10I 0
     D  purge                        10A
      *
      *  This format returns information equivalent to that found on the
      *  Work with Active Jobs (WRKACTJOB) command.
     D jobi0200_t      DS                  qualified           based(pDummy)
     D  bytRet                       10I 0
     D  bytAvl                       10I 0
     D  job                          10A
     D  user                         10A
     D  nbr                           6A
     D  intJobID                     16A
     D  status                       10A
     D  type                          1A
     D  subType                       1A
     D  sbsDName                     10A
     D  runPty                       10I 0
     D  sysPoolID                    10I 0
     D  prcTimeUsd                   10I 0
     D  numAuxIORq                   10I 0
     D  numIntTact                   10I 0
     D  rspTimeTot                   10I 0
     D  fncType                       1A
     D  fncName                      10A
     D  actJobSts                     4A
     D  numDBLckW                    10I 0
     D  numIntLckW                   10I 0
     D  numNonDBLckW                 10I 0
     D  timeDBLckW                   10I 0
     D  timeIntLckW                  10I 0
     D  timeNonDBLckW                10I 0
     D  reserved_01                   1A
     D  currSysPoolID                10I 0
     D  thrdCount                    10I 0
     D  prcUntTmUsd                  20U 0
     D  numAuxIORqLng                20U 0
     D  prcUntTmUsdDB                20U 0
     D  pageFaults                   20U 0
     D  actJobStsJobEnd...
     D                                4A
     D  memPoolName                  10A
     D  msgRply                       1A
      *
      *  This format returns job queue and output queue information for a job, as
      *  well as information about the submitter's job if the job is a submitted batch job.
     D jobi0300_t      DS                  qualified           based(pDummy)
     D  bytRet                       10I 0
     D  bytAvl                       10I 0
     D  job                          10A
     D  user                         10A
     D  nbr                           6A
     D  intJobID                     16A
     D  status                       10A
     D  type                          1A
     D  subType                       1A
     D  jobQ                         10A
     D  jobQLib                      10A
     D  jobQPty                       2A
     D  outQ                         10A
     D  outQLib                      10A
     D  outQPty                       2A
     D  prtDev                       10A
     D  sbmJob                       10A
     D  sbmUser                      10A
     D  sbmNbr                        6A
     D  sbmMsgQ                      10A
     D  sbmMsgQLib                   10A
     D  stsOnJobQ                    10A
     D  datTimSbm                     8A
     D  jobDate                       7A
      *
      *  This format primarily returns job attribute types of information.
     D jobi0400_t      DS                  qualified           based(pDummy)
     D  bytRet                       10I 0
     D  bytAvl                       10I 0
     D  job                          10A
     D  user                         10A
     D  nbr                           6A
     D  intJobID                     16A
     D  status                       10A
     D  type                          1A
     D  subType                       1A
     D  dateTimeEnt                  13A
     D  dateTimeAct                  13A
     D  jobAcctCode                  15A
     D  jobD                         10A
     D  jobDLib                      10A
     D  unitOfWorkID                 24A
     D  mode                          8A
     D  inqMsgRply                   10A
     D  logCLPgms                    10A
     D  brkMsgHdl                    10A
     D  stsMsgHdl                    10A
     D  devRcvrAct                   13A
     D  ddmCnvHdl                    10A
     D  dateSep                       1A
     D  dateFmt                       4A
     D  prtText                      30A
     D  sbmJob                       10A
     D  sbmUser                      10A
     D  sbmNbr                        6A
     D  sbmMsgQ                      10A
     D  sbmMsgQLib                   10A
     D  timeSep                       1A
     D  ccsid                        10I 0
     D  dateTimeScd                   8A
     D  prtKeyFmt                    10A
     D  sortSeq                      10A
     D  sortSeqLib                   10A
     D  langID                        3A
     D  countryID                     2A
     D  complSts                      1A
     D  signedOnJob                   1A
     D  jobSws                        8A
     D  msgQFullAct                  10A
     D  reserved_01                   1A
     D  msgQMaxSize                  10I 0
     D  dftCcsid                     10I 0
     D  rtgData                      80A
     D  decFmt                        1A
     D  chrIDCtrl                    10A
     D  serverType                   30A
     D  alwMltThrds                   1A
     D  jobLogPnd                     1A
     D  reserved_02                   1A
     D  jobEndRsn                    10I 0
     D  jobTypeEnhncd                10I 0
     D  dateTimeEnd                  13A
     D  reserved_03                   1A
     D  splFActn                     10A
     D  ofsAspGrpInf                 10I 0
     D  numEAspGrpInf                10I 0
     D  lenAspGrpInfE                10I 0
     D  timeZoneDscNm                10A
     D  jobLogOutput                 10A
      *
      *  This format returns information about active jobs only.
      *  It is intended to supplement the JOBI0400 format.
     D jobi0600_t      DS                  qualified           based(pDummy)
     D  bytRet                       10I 0
     D  bytAvl                       10I 0
     D  job                          10A
     D  user                         10A
     D  nbr                           6A
     D  intJobID                     16A
     D  status                       10A
     D  type                          1A
     D  subType                       1A
     D  jobSws                        8A
     D  endStatus                     1A
     D  sbsD                         10A
     D  sbsDLib                      10A
     D  curUser                      10A
     D  dbcs                          1A
     D  exitKey                       1A
     D  cancelKey                     1A
     D  prdRetCode                   10I 0
     D  userRetCode                  10I 0
     D  pgmretCode                   10I 0
     D  spcEnv                       10A
     D  device                       10A
     D  grpPrf                       10A
     D  grpPrfAry                    10A   dim(15)
     D  jobUsrID                     10A
     D  jobUsrIDStg                   1A
      *
      *  This format returns library list information for an active job.
     D jobi0700_t      DS                  qualified           based(pDummy)
     D  bytRet                       10I 0
     D  bytAvl                       10I 0
     D  job                          10A
     D  user                         10A
     D  nbr                           6A
     D  intJobID                     16A
     D  status                       10A
     D  type                          1A
     D  subType                       1A
     D  reserved_1                    2A
     D  numSysLibE                   10I 0
     D  numPrdLibE                   10I 0
     D  numCurLibE                   10I 0
     D  numUsrLibE                   10I 0
      *   System library list                   Array (*) of CHAR(11)
      *   Product libraries                     Array (*) of CHAR(11)
      *   Current library                       Array (*) of CHAR(11)
      *   User library list                     Array (*) of CHAR(11)
      *
      /ENDIF
