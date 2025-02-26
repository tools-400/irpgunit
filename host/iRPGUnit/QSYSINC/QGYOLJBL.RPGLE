**FREE
//
// Prototype for QGYOLJBL API.
//
// Open List of Job Log Messages
//
// http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qgyoljbl.htm
//

/include qsysinc,OPNLIST

dcl-pr qgyoljbl extpgm('QGYOLJBL');
  o_rcvVar        char(32766) options(*varsize);
  i_rcvVarLen     int(10) const;
  o_listInfo      likeds(dsOpnList);
  i_nbrRcdToRtn   int(10) const;
  i_msgSelect     char(32766) const options(*varsize);
  i_msgSelectLn   int(10) const;
  io_error        char(32766) options(*varsize);
end-pr;

// Job log message field selection for QGYOLJBL API.
dcl-ds fldselect_qgyoljbl_t qualified template;
  listDirection   char(10);
  qlfJobNm        char(26);
  intJobID        char(16);
  startMsgKey     char(4);
  maxMsgLen       int(10);
  maxMsgHlpLen    int(10);
  fldIdOffs       int(10);
  fldCnt          int(10);
  callMsgQNmOffs  int(10);
  callMsgQNmLen   int(10);
  //  Identifiers of fields to return
  //    ARRAY(*) of BINARY(4)
  //  Call message queue name
  //    CHAR(*)
end-ds;

dcl-ds dsOljl0100EntHdr qualified template;
  nextEntOffs     int(10);
  retFldOffs      int(10);
  retFldCnt       int(10);
  msgSeverity     int(10);
  msgID           char(7);
  msgType         char(2);
  msgKey          char(4);
  msgFNm          char(10);
  msgFLib         char(10);
  sentDate        char(7);
  sentTime        char(6);
  microSeconds    char(6);
  threadID        char(8);
  timezone        char(10);
end-ds;

dcl-ds dsOljl0100FldHdr qualified template;
  nextFldOffs     int(10);
  fldInfoLen      int(10);
  fldID           int(10);
  dataType        char(1);
  dataSts         char(1);
  reserved_1      char(14);
  dataLen         int(10);
end-ds;

// Number of records to return:
// - All records are built synchronously in the list by the main job.
dcl-c OLJL_FULL_SYNCHRONOUS_BUILD -1;

// Field Identifiers:

dcl-c OLJL_RPL_DATA                                0201; // - replacement data or impromptu message 
dcl-c OLJL_MSG                                     0301; // - message
dcl-c OLJL_MSG_WITH_RPL_DATA                       0302; // - message with replacement data
dcl-c OLJL_MSG_HELP                                0401; // - message help
dcl-c OLJL_MSG_HELP_WITH_RPL_DATA                  0402; // - message help with replacement data
dcl-c OLJL_MSG_HELP_WITH_FORMAT_CHARS              0403; // - message help with formatting character
dcl-c OLJL_MSG_HELP_WITH_RPL_DATA_AND_FORMAT_CHARS 0404; // message help with replacement data
                                                         // and formatting characters
dcl-c OLJL_SND_PGM_NM                              0603; // - sending program name
dcl-c OLJL_SND_PGM_LIB                             0608; // - sending program library
dcl-c OLJL_SND_MOD_NM                              0604; // - sending module name
dcl-c OLJL_SND_PROC_NM                             0605; // - sending procedure name
dcl-c OLJL_RCV_PGM_NM                              0703; // - receiving program name
dcl-c OLJL_RCV_PGM_LIB                             0708; // - receiving program library
dcl-c OLJL_RCV_MOD_NM                              0704; // - receiving module name
dcl-c OLJL_RCV_PROC_NM                             0705; // - receiving procedure name

