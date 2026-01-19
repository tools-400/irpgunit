**FREE
//
// Prototype for QGYOLSPL API.
//
// Open List of Spooled Files
//
// http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qgyolspl.htm
//

/include qinclude,TYPES_H
/include qsysinc,OPNLIST

dcl-pr qgyolspl extpgm('QGYOLSPL');
  o_rcvVar        char(32766) options(*varsize);
  i_rcvVarLen     int(10) const;
  o_listInfo      char(80);
  i_nbrRcdToRtn   int(10) const;
  i_sortInfo      char(256) const options(*varsize);
  i_filterInfo    char(256) const options(*varsize);
  i_qlfJobNm      const like(qlfJobNm_t);
  i_listFmt       char(8) const;
  io_error        char(32766) options(*varsize);
  i_filterFmt     char(8) const options(*nopass);
end-pr;

dcl-ds ospf0200_t qualified template;
  lenFltrInf      int(10);
  offsUsrNm       int(10);
  numUsrNm        int(10);
  lenUsrNme       int(10) inz(10);
  offsOutQNm      int(10);
  numOutQNm       int(10);
  lenOutQNm       int(10) inz(20);
  offsSplfSts     int(10);
  numSplfSts      int(10);
  lenSplfSts      int(10) inz(10);
  offsPrtDevNm    int(10);
  numPrtDevNm     int(10);
  lenPrtDevNm     int(10) inz(10);
  frmType         char(10) inz('*ALL');
  usrSpcDta       char(10);
  sysNm           char(8) inz('*CURRENT');
  strSplfCrtDt    char(7) inz('*ALL');
  strSplfCrtTm    char(6);
  endSplfCrtDt    char(7) inz('*LAST');
  endSplfCrtTm    char(6);
  reserved_01     char(4) inz(x'00');
end-ds;

dcl-ds ospf0200_userNameE_t qualified template;
  usrNm           char(10);
end-ds;

dcl-ds ospf0200_outQueueE_t qualified template;
  outQNm          char(10);
  outQLb          char(10);
end-ds;

dcl-ds ospf0200_fileStatusE_t qualified template;
  status          char(10);
end-ds;

dcl-ds ospf0200_prtDevNameE_t qualified template;
  prtDevNm        char(10);
end-ds;

dcl-ds dsOspl0100 qualified template;
  splfNm          char(10);
  jobNm           char(10);
  usrNm           char(10);
  jobNb           char(6);
  splfNb          int(10);
  pgCnt           int(10);
  curPg           int(10);
  copiesToPrt     int(10);
  outQNm          char(10);
  outQLibNm       char(10);
  usrDta          char(10);
  status          char(10);
  formType        char(10);
  priority        char(2);
  intJobID        char(16);
  intSplfID       char(16);
  deviceType      char(10);
  *N              char(2);
  extOffs         int(10);
  extLen          int(10);
  *N              char(4);
end-ds;

dcl-ds dsOspl0300 qualified template;
  jobNm           char(10);
  usrNm           char(10);
  jobNb           char(6);
  splfNm          char(10);
  splfNb          int(10);
  fileStatus      int(10);
  splfOpnDate     char(7);
  splfOpnTime     char(6);
  splfSchedule    char(1);
  jobSysNm        char(10);
  usrDta          char(10);
  splfFormType    char(10);
  outQNm          char(10);
  outQLibNm       char(10);
  asp             int(10);
  splfSize        int(10);
  splfSizeMult    int(10);
  pgCnt           int(10);
  copiesToPrt     int(10);
  priority        char(1);
  *N              char(3);
end-ds;

// Sort Information.
dcl-ds sortInfo_t qualified template;
  keyCnt          int(10);
  keys            likeds(sortKey_t)
dim(16);
end-ds;

// Sort Keys. Refer to QLGSORT API.
dcl-ds sortKey_t qualified template;
  fieldStartPos   int(10);
  fieldLen        int(10); // Data types: 0=signed binary, 6=character... Refer to QLGSORT.
  fieldDataType   int(5);
  sortOrder       char(1); // Sort order: 1=ascending, 2=descending.
  reserved        char(1);
end-ds;

// Number of records to return:
// - All records are built synchronously in the list by the main job.
dcl-c OLSL_FULL_SYNCHRONOUS_BUILD -1;

