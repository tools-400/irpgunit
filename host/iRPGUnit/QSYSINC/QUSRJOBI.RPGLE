**free
/if not defined(QUSRJOBI)
/define QUSRJOBI

//  Retrieve Job Information (QUSRJOBI) API
dcl-pr QUSRJOBI extpgm('QUSRJOBI');
  o_rcvVar     char(65535) options(*varsize);
  i_rcvVarLen  int(10) const;
  i_format     char(8) const;
  i_qJob       char(26) const;
  i_intJobID   char(16) const;
  io_errCode   char(65535) options(*nopass: *varsize); // OptGrp 1
  i_resPrfStat char(1) const  options(*nopass);        // OptGrp 2
end-pr;

//  This format returns basic performance information about a job.
dcl-ds jobi0100_t qualified template;
  bytRet          int(10);
  bytAvl          int(10);
  job             char(10);
  user            char(10);
  nbr             char(6);
  intJobID        char(16);
  status          char(10);
  type            char(1);
  subType         char(1);
  reserved_1      char(2);
  runPty          int(10);
  timeSlice       int(10);
  dftWait         int(10);
  purge           char(10);
end-ds;

//  This format returns information equivalent to that found on the
//  Work with Active Jobs (WRKACTJOB) command.
dcl-ds jobi0200_t qualified template;
  bytRet          int(10);
  bytAvl          int(10);
  job             char(10);
  user            char(10);
  nbr             char(6);
  intJobID        char(16);
  status          char(10);
  type            char(1);
  subType         char(1);
  sbsDName        char(10);
  runPty          int(10);
  sysPoolID       int(10);
  prcTimeUsd      int(10);
  numAuxIORq      int(10);
  numInttAct      int(10);
  rspTimeTot      int(10);
  fncType         char(1);
  fncName         char(10);
  actJobSts       char(4);
  numDBLckW       int(10);
  numIntLckW      int(10);
  numNonDBLckW    int(10);
  timeDBLckW      int(10);
  timeIntLckW     int(10);
  timeNonDBLckW   int(10);
  reserved_01     char(1);
  currSysPoolID   int(10);
  thrdCount       int(10);
  prcUnttmUsd     uns(20);
  numAuxIORqLng   uns(20);
  prcUnttmUsdDB   uns(20);
  pageFaults      uns(20);
  actJobStsJobEnd char(4);
  memPoolName     char(10);
  msgRply         char(1);
end-ds;

//  This format returns job queue and output queue information for a job, as
//  well as information about the submitter's job if the job is a submitted batch job.
dcl-ds jobi0300_t qualified template;
  bytRet          int(10);
  bytAvl          int(10);
  job             char(10);
  user            char(10);
  nbr             char(6);
  intJobID        char(16);
  status          char(10);
  type            char(1);
  subType         char(1);
  jobQ            char(10);
  jobQLib         char(10);
  jobQPty         char(2);
  outQ            char(10);
  outQLib         char(10);
  outQPty         char(2);
  prtDev          char(10);
  sbmJob          char(10);
  sbmUser         char(10);
  sbmNbr          char(6);
  sbmMsgQ         char(10);
  sbmMsgQLib      char(10);
  stsOnJobQ       char(10);
  datTimSbm       char(8);
  jobDate         char(7);
end-ds;

//  This format primarily returns job attribute types of information.
dcl-ds jobi0400_t qualified template;
  bytRet          int(10);
  bytAvl          int(10);
  job             char(10);
  user            char(10);
  nbr             char(6);
  intJobID        char(16);
  status          char(10);
  type            char(1);
  subType         char(1);
  dateTimeEnt     char(13);
  dateTimeAct     char(13);
  jobAcctCode     char(15);
  jobD            char(10);
  jobDLib         char(10);
  unitOfWorkID    char(24);
  mode            char(8);
  inqMsgRply      char(10);
  logCLPgms       char(10);
  brkMsgHdl       char(10);
  stsMsgHdl       char(10);
  devRcvrAct      char(13);
  ddmCnvHdl       char(10);
  dateSep         char(1);
  dateFmt         char(4);
  prtText         char(30);
  sbmJob          char(10);
  sbmUser         char(10);
  sbmNbr          char(6);
  sbmMsgQ         char(10);
  sbmMsgQLib      char(10);
  timeSep         char(1);
  ccsid           int(10);
  dateTimeScd     char(8);
  prtKeyFmt       char(10);
  sortSeq         char(10);
  sortSeqLib      char(10);
  langID          char(3);
  countryID       char(2);
  complSts        char(1);
  signedOnJob     char(1);
  jobSws          char(8);
  msgQFullAct     char(10);
  reserved_01     char(1);
  msgQMaxSize     int(10);
  dftCcsid        int(10);
  rtgData         char(80);
  decFmt          char(1);
  chridCtrl       char(10);
  serverType      char(30);
  alwMltThrds     char(1);
  jobLogPnd       char(1);
  reserved_02     char(1);
  jobEndRsn       int(10);
  jobTypeEnhncd   int(10);
  dateTimeEnd     char(13);
  reserved_03     char(1);
  splFActn        char(10);
  offsAspGrpInf   int(10);
  numEAspGrpInf   int(10);
  lenAspGrpInfE   int(10);
  timeZoneDscNm   char(10);
  jobLogOutput    char(10);
  jobDLibASPGrp   char(10);
  //   ASP group information entry
  //   System library list                   Array (*) of char(10)
end-ds;

//  This format returns information about active jobs only.
//  It is intended to supplement the JOBI0400 format.
dcl-ds jobi0600_t qualified template;
  bytRet          int(10);
  bytAvl          int(10);
  job             char(10);
  user            char(10);
  nbr             char(6);
  intJobID        char(16);
  status          char(10);
  type            char(1);
  subType         char(1);
  jobSws          char(8);
  endStatus       char(1);
  sbsD            char(10);
  sbsDLib         char(10);
  curUser         char(10);
  dbcs            char(1);
  exitKey         char(1);
  cancelKey       char(1);
  prdRetCode      int(10);
  userRetCode     int(10);
  pgmretCode      int(10);
  spcEnv          char(10);
  device          char(10);
  grpPrf          char(10);
  grpPrfAry       char(10) dim(15);
  jobUsrID        char(10);
  jobUsrIDStg     char(1);
end-ds;

//  This format returns library list information for an active job.
dcl-ds jobi0700_t qualified template;
  bytRet          int(10);
  bytAvl          int(10);
  job             char(10);
  user            char(10);
  nbr             char(6);
  intJobID        char(16);
  status          char(10);
  type            char(1);
  subType         char(1);
  reserved_1      char(2);
  numSysLibE      int(10);
  numPrdLibE      int(10);
  numCurLibE      int(10);
  numUsrLibE      int(10);
  //   System library list                   Array (*) of char(11)
  //   Product libraries                     Array (*) of char(11)
  //   Current library                       Array (*) of char(11)
  //   User library list                     Array (*) of char(11)
end-ds;

/endif
