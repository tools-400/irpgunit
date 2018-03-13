      //
      // Prototype for QGYOLJBL API.
      //
      // Open List of Job Log Messages
      //
      // http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qgyoljbl.htm
      //

     DQGYOLJBL         pr                  ExtPgm('QGYOLJBL')
     D jobLogList                 32766a   options(*varsize)
     D jobLogListLen                 10i 0 const
     D listInfo                            likeds(dsOpnList)
     D nbOfRcdToRtn                  10i 0 const
     D msgSelect                  32766a   const options(*varsize)
     D msgSelectLen                  10i 0 const
     D error                      32766a   options(*varsize: *omit) noopt

     DdsOLJL0100EntHdr...
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
     D sentDate                       7a
     D sentTime                       6a
     D microseconds                   6a

     DdsOLJL0100FldHdr...
     D                 ds                  qualified based(template)
     D nextFldOff                    10i 0
     D fldInfoLen                    10i 0
     D fldId                         10i 0
     D dataType                       1a
     D dataSts                        1a
     D                               14a
     D dataLen                       10i 0

       // Number of records to return:
       // - All records are built synchronously in the list by the main job.
     D FULL_SYNCHRONOUS_BUILD...
     D                 c                   const(-1)

       // Field Identifiers:
       // - replacement data or impromptu message text
     D OLJL_RPL_DATA   c                   const(0201)
       // - message
     D OLJL_MSG        c                   const(0301)
       // - message with replacement data
     D OLJL_MSG_WITH_RPL_DATA...
     D                 c                   const(0302)
       // - sending program name
     D OLJL_SND_PGM_NM...
     D                 c                   const(0603)
       // - receiving program name
     D OLJL_RCV_PGM_NM...
     D                 c                   const(0703)
