       //
       // Prototype for QGYOLJBL API.
       //
       // Open List of Job Log Messages
       //
      // http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qgyoljbl.htm
       //

      /include qsysinc,OPNLIST

     D QGYOLJBL        pr                  ExtPgm('QGYOLJBL')
     D  o_rcvVar                  32766a         options(*varsize)
     D  i_rcvVarLen                  10i 0 const
     D  o_listInfo                               likeds(dsOpnList)
     D  i_nbrRcdToRtn                10i 0 const
     D  i_msgSelect               32766a   const options(*varsize)
     D  i_msgSelectLn                10i 0 const
     D  io_error                  32766a         options(*varsize)

       // Job log message field selection for QGYOLJBL API.
     D fldSelect_QGYOLJBL_t...
     D                 ds                  qualified based(template)
     D  listDirection                10a
     D  qlfJobNm                     26a
     D  intJobId                     16a
     D  startMsgKey                   4a
     D  maxMsgLen                    10i 0
     D  maxMsgHlpLen                 10i 0
     D  fldIdOff                     10i 0
     D  fldCnt                       10i 0
     D  callMsgqNmOff                10i 0
     D  callMsgqNmLen                10i 0
      *  Identifiers of fields to return
      *    ARRAY(*) of BINARY(4)
      *  Call message queue name
      *    CHAR(*)

     D dsOLJL0100EntHdr...
     D                 ds                  qualified based(template)
     D  nextEntOff                   10i 0
     D  retFldOff                    10i 0
     D  retFldCnt                    10i 0
     D  msgSeverity                  10i 0
     D  msgId                         7a
     D  msgType                       2a
     D  msgKey                        4a
     D  msgfNm                       10a
     D  msgfLib                      10a
     D  sentDate                      7a
     D  sentTime                      6a
     D  microseconds                  6a

     D dsOLJL0100FldHdr...
     D                 ds                  qualified based(template)
     D  nextFldOff                   10i 0
     D  fldInfoLen                   10i 0
     D  fldId                        10i 0
     D  dataType                      1a
     D  dataSts                       1a
     D  reserved_1                   14a
     D  dataLen                      10i 0

       // Number of records to return:
       // - All records are built synchronously in the list by the main job.
     D OLJL_FULL_SYNCHRONOUS_BUILD...
     D                 c                   const(-1)

       // Field Identifiers:
       // - replacement data or impromptu message text
     D OLJL_RPL_DATA   c                   const(0201)
       // - message
     D OLJL_MSG        c                   const(0301)
       // - message with replacement data
     D OLJL_MSG_WITH_RPL_DATA...
     D                 c                   const(0302)
       // - message help
     D OLJL_MSG_HELP   c                   const(0401)
       // - message help with replacement data
     D OLJL_MSG_HELP_WITH_RPL_DATA...
     D                 c                   const(0402)
       // - message help with formatting characters
     D OLJL_MSG_HELP_WITH_FORMAT_CHARS...
     D                 c                   const(0403)
       // - message help with replacement data and formatting characters
     D OLJL_MSG_HELP_WITH_RPL_DATA_AND_FORMAT_CHARS...
     D                 c                   const(0404)
       // - sending program name
     D OLJL_SND_PGM_NM...
     D                 c                   const(0603)
       // - receiving program name
     D OLJL_RCV_PGM_NM...
     D                 c                   const(0703)
