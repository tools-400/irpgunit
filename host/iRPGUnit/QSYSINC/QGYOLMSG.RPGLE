      //
      // Prototype for QGYOLMSG API.
      //
      // Open List of Messages
      //
      // https://www.ibm.com/support/knowledgecenter/ssw_ibm_i_73/apis/QGYOLMSG.htm
      //

      /include qinclude,templates

     DQGYOLMSG         pr                  ExtPgm('QGYOLMSG')
     D msgList                    32766a   options(*varsize)
     D msgListLen                    10i 0 const
     D listInfo                            likeds(dsOpnList)
     D nbOfRcdToRtn                  10i 0 const
     D msgSort                        1a   const
     D msgSelect                  32766a   const options(*varsize)
     D msgSelectLen                  10i 0 const
     D userQueueInf                  21a   const
     D msgQueuesUsed                 44a
     D error                      32766a   options(*varsize: *omit) noopt

     DdsLSTM0100EntHdr...
     D                 ds                  qualified based(template)
     D nextEntOff                    10i 0
     D retFldOff                     10i 0
     D retFldCnt                     10i 0
     D msgSeverity                   10i 0
     D msgId                          7a
     D msgType                        2a
     D msgKey                         4a
     D msgfNm                        10a
     D msgfLib                       10a
     D msgQueueNm                    10a
     D msgQueueLib                   10a
     D sentDate                       7a
     D sentTime                       6a
     D microseconds                   6a
     D timezone                      10a

     DdsLSTM0100FldHdr...
     D                 ds                  qualified based(template)
     D nextFldOff                    10i 0
     D fldInfoLen                    10i 0
     D fldId                         10i 0
     D dataType                       1a
     D dataSts                        1a
     D reserved_1                    14a
     D dataLen                       10i 0

       // User or queue information
     DdsUserQueueInf   ds                  qualified based(template)
     D  ind                           1a
     D  userOrQueueNm                10a
     D  libraryNm                    10a

       // Message queues used
     DdsMsgQueuesUsed  ds                  qualified based(template)
     D  queuesCnt                    10i 0
     D  msgQueues                          likeds(Object_t) dim(2)

       // Sort information
     D LSTM_SORT_NONE...
     D                 c                   '0'
     D LSTM_SORT_TYPE...
     D                 c                   '1'

       // User or queue information
     D LSTM_USER_NAME...
     D                 c                   '0'
     D LSTM_MSG_QUEUE_NAME...
     D                 c                   '1'

       // Number of records to return:
       // - All records are built synchronously in the list by the main job.
     D LSTM_FULL_SYNCHRONOUS_BUILD...
     D                 c                   const(-1)

       // Field Identifiers:
       // - reply status
     D LSTM_RPLY_STATUS...
     D                 c                   const(1001)
       // - replacement data or impromptu message text
     D LSTM_RPL_DATA   c                   const(0201)
       // - message
     D LSTM_MSG        c                   const(0301)
       // - message with replacement data
     D LSTM_MSG_WITH_RPL_DATA...
     D                 c                   const(0302)
       // - message help
     D LSTM_MSG_HELP   c                   const(0401)
       // - message help with replacement data
     D LSTM_MSG_HELP_WITH_RPL_DATA...
     D                 c                   const(0402)
       // - sending program name
     D LSTM_SND_PGM_NM...
     D                 c                   const(0603)
       // - sending user profile
     D LSTM_SND_USER_PROFILE...
     D                 c                   const(0607)
       // - receiving program name
     D LSTM_RCV_PGM_NM...
     D                 c                   const(0703)
