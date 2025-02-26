**FREE
//
// Prototype for QGYOLMSG API.
//
// Open List of Messages
//
// https://www.ibm.com/support/knowledgecenter/ssw_ibm_i_73/apis/QGYOLMSG.htm
//

/include qinclude,templates
/include qsysinc,opnlist

dcl-pr qgyolmsg extpgm('QGYOLMSG');
  o_rcvVar        char(32766) options(*varsize);
  i_rcvVarLen     int(10) const;
  o_listInfo      likeds(dsOpnList);
  i_nbrRcdToRtn   int(10) const;
  i_msgSort       char(1) const;
  i_msgSelect     char(32766) const options(*varsize);
  i_msgSelectLn   int(10) const;
  i_userQInf      char(21) const;
  o_msgQUsed      char(44);
  io_error        char(32766) options(*varsize);
end-pr;

dcl-ds dsLstm0100EntHdr_t qualified template;
  nextEntOffs     int(10);
  retFldOffs      int(10);
  retFldCnt       int(10);
  msgSeverity     int(10);
  msgID           char(7);
  msgType         char(2);
  msgKey          char(4);
  msgFNm          char(10);
  msgFLib         char(10);
  msgQueueNm      char(10);
  msgQueueLib     char(10);
  sentDate        char(7);
  sentTime        char(6);
  microSeconds    char(6);
  timezone        char(10);
end-ds;

dcl-ds dsUserQueueInf_t_t qualified template;
  nextFldOffs      int(10);
  fldInfoLen      int(10);
  fldID           int(10);
  dataType        char(1);
  dataSts         char(1);
  reserved_1      char(14);
  dataLen         int(10);
end-ds;

// User or queue information
dcl-ds dsUserQueueInf qualified template;
  ind             char(1);
  userOrQueueNm   char(10);
  libraryNm       char(10);
end-ds;

// Message queues used
dcl-ds dsMsgQueuesUsed_t qualified template;
  queuesCnt       int(10);
  msgQueues       likeds(object_t) dim(2);
end-ds;

// Sort information
dcl-c LSTM_SORT_NONE '0';
dcl-c LSTM_SORT_TYPE '1';

// User or queue information
dcl-c LSTM_USER_NAME      '0';
dcl-c LSTM_MSG_QUEUE_NAME '1';

// Number of records to return:
// - All records are built synchronously in the list by the main job.
dcl-c LSTM_FULL_SYNCHRONOUS_BUILD -1;

// Field Identifiers:

dcl-c LSTM_RPLY_STATUS            1001; // - reply status
dcl-c LSTM_RPL_DATA               0201; // - replacement data or impromptu message text
dcl-c LSTM_MSG                    0301; // - message
dcl-c LSTM_MSG_WITH_RPL_DATA      0302; // - message with replacement data
dcl-c LSTM_MSG_HELP               0401; // - message help
dcl-c LSTM_MSG_HELP_WITH_RPL_DATA 0402; // - message help with replacement data
dcl-c LSTM_SND_PGM_NM             0603; // - sending program name
dcl-c LSTM_SND_USER_PROFILE       0607; // - sending user profile
dcl-c LSTM_RCV_PGM_NM             0703; // - receiving program name
