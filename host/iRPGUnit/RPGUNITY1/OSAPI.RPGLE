      /if not defined(QUSEC)
      /define QUSEC
      /copy QSYSINC/QRPGLESRC,QUSEC
      /endif

      /if not defined (OSAPI)
      /define OSAPI

      /copy RPGUNITY1,TEMPLATES

      *
      * List APIs
      *
     D api_listDatabaseRelations...
     D                 PR                  extpgm('QDBLDBR')
     D   userspace                   20A   const
     D   format                       8A   const
     D   filename                    20A   const
     D   member                      10A   const
     D   recordformat                10A   const
     D   error                             likeds(QUSEC)

     D api_listJobs...
     D                 PR                  extpgm('QUSLJOB')
     D   userspace                   20A   const
     D   format                       8A   const
     D   qualJobName                 26A   const
     D   status                      10A   const
     D   errorCode                32767A   options(*varsize)
     D   jobType                      1A   const options(*nopass)
     D   numFldsToRtn                10I 0 const options(*nopass)
     D   fldsToRtn                   10I 0 const options(*nopass)

     D api_listFileMembers...
     D                 PR                  extpgm('QUSLMBR')
     D  userspace                    20A   const
     D  format                        8A   const
     D  filename                     20A   const
     D  member                       10A   const
     D  ovrProcessing                 1A   const
     D  error                              likeds(QUSEC) options(*nopass)

     D api_listObjects...
     D                 PR                  extpgm('QUSLOBJ')
     D  userspace                    20A   const
     D  format                        8A   const
     D  objName                      20A   const
     D  objType                      10A   const
     D  apiError                           likeds(QUSEC) options(*nopass)
     D  objAut                       64A   options(*varsize : *nopass)
     D  selOmit                      64A   options(*varsize : *nopass)

     D api_listRecordFormats...
     D                 PR                  extpgm('QUSLRCD')
     D  userspace                    20A   const
     D  format                        8A   const
     D  filename                     20A   const
     D  ovrProcessing                 1A   const
     D  error                              likeds(QUSEC) options(*nopass)

     D api_closeList   PR                  extpgm('QGYCLST')
     D  listHandle                    4A   const
     D  error                              likeds(QUSEC)


      *
      * Job APIs
      *
     D api_retrieveJobInformation...
     D                 PR                  extpgm('QUSRJOBI')
     D   receiver                 65535A   options(*varsize)
     D   recLength                   10I 0 const
     D   format                       8A   const
     D   qualJobName                 26A   const
     D   intJobId                    16A   const
     D   error                             likeds(QUSEC) options(*nopass)


      *
      * Validation List APIs
      *
     D api_verifyValidationListEntry...
     D                 PR            10I 0 extproc('QsyVerifyValidation+
     D                                     LstEntry')
     D  VvLstNam                     20A   const
     D  VvEntId                        *   value
     D  VvEncDta                       *   value
      *
     D api_addValidationListEntry...
     D                 PR            10I 0 extproc('QsyAddValidation+
     D                                     LstEntry')
     D  AvLstNam                     20A   const
     D  AvEntId                        *   value
     D  AvEncDta                       *   value
     D  AvEntDta                       *   value
     D  AvAtrDta                       *   value
      *
     D api_findValidationListEntry...
     D                 PR            10I 0 extproc('QsyFindValidation+
     D                                     LstEntry')
     D  FvLstNam                     20A   const
     D  FvEntId                        *   value
     D  FvRtnDta                       *   value
      *
     D api_changeValidationListEntry...
     D                 PR            10I 0 extproc('QsyChangeValidation+
     D                                     LstEntry')
     D  CvLstNam                     20A   const
     D  CvEntId                        *   value
     D  CvEncDta                       *   value
     D  CvEntDta                       *   value
     D  CvAtrDta                       *   value
      *
     D api_removeValidationListEntry...
     D                 PR            10I 0 extproc('QsyRemoveValidation+
     D                                     LstEntry')
     D  RvLstNam                     20A   const
     D  RvEntId                        *   value
      *
     D api_openListValidationListEntries...
     D                 PR                  extpgm('QSYOLVLE')
     D  receiver                  65535A
     D  receiverLength...
     D                               10I 0 const
     D  listInfo                     80A
     D  numberRecordsToReturn...
     D                               10I 0 const
     D  format                        8A   const
     D  qualifiedValidtionListName...
     D                               20A   const
     D  error                              likeds(QUSEC)
      *
      *
      *
     D VLE0100         DS                  qualified template
     D  entryLength                  10I 0
     D  entryIdDisplacement...
     D                               10I 0
     D  entryIdLength                10I 0
     D  entryIdCCSID                 10I 0
     D  encDataDisplacement...
     D                               10I 0
     D  encDataCCSID                 10I 0
     D  entryDataDisplacement...
     D                               10I 0
     D  entryDataLength...
     D                               10I 0
     D  entryDataCCSID...
     D                               10I 0


      *
      * Message Handling API
      *
     D api_resendEscapeMessage...
     D                 PR                  extpgm('QMHRSNEM')
     D   messageKey                   4A   const
     D   error                             likeds(QUSEC)

      *
     D api_listJobLogMessages...
     D                 PR                  extpgm('QMHLJOBL')
     D  userspace                    20A   const
     D  format                        8A   const
     D  selection                    84A
     D  selectionSize                10I 0 const
     D  selFormat                     8A   const
     D  error                              likeds(QUSEC)
      *
      *
     D JSLT0100        DS                  qualified template
     D   maxMessages                 10I 0 inz(-1)
     D   listDirection...
     D                               10A   inz('*PRV')
     D   jobName                     10A   inz('*')
     D   userName                    10A
     D   jobNumber                    6A
     D   internalJobId...
     D                               16A
     D   messageKey                   4A   inz(x'FFFFFFFF')
     D   maxMessageLength...
     D                               10I 0 inz(-1)
     D   maxMessageHeaderLength...
     D                               10I 0
     D   offsetFieldReturned...
     D                               10I 0 inz(84)
     D   numberFieldsReturned...
     D                               10I 0 inz(1)
     D   offsetMessageQueue...
     D                               10I 0 inz(88)
     D   lengthMessageQueue...
     D                               10I 0 inz(4)
     D   field1                      10I 0 inz(0302)
     D   messageQueueName...
     D                                4A   inz('*')
      *
     D LJOB0100        DS                  qualified template
     D   nextEntryOffset...
     D                               10I 0
     D   fieldReturnedOffset...
     D                               10I 0
     D   numberFieldReturned...
     D                               10I 0
     D   messageSeverity...
     D                               10I 0
     D   messageId                    7A
     D   messageType                  2A
     D   messageKey                   4A
     D   messageFileName...
     D                               10A
     D   messageFileLibrary...
     D                               10A
     D   dateSent                     7A
     D   timeSent                     6A
     D   reserved                  8192A
      *
     D tmpl_messageEntry...
     D                 DS                  qualified template
     D   nextFieldOffset...
     D                               10I 0
     D   fieldInfoLength...
     D                               10I 0
     D   fieldId                     10I 0
     D   dataType                     1A
     D   dataStatus                   1A
     D   reserved2                   14A
     D   dataLength                  10I 0
     D   dataText                  1000A


      *
      * Misc. API
      *
     D api_executeCommand...
     D                 PR                  extpgm('QCMDEXC')
     D   cmdString                 1024A   const options(*varsize)
     D   cmdLength                   15P 5 const
     D   cmdOpt                       3A   const options(*nopass)
      *
     D api_retrieveObjectDescription...
     D                 PR                  extpgm('QUSROBJD')
     D  rtnData                   65535A   options(*varsize)
     D  nRtnDataLen                  10I 0 const
     D  Format                        8A   const
     D  QualObj                      20A   const
     D  ObjType                      10A   const
     D  error                              likeds(QUSEC) options(*nopass)
      *
     D api_retrieveMemberDescription...
     D                 PR                  extpgm('QUSRMBRD')
     D  rtnData                   65535A   options(*varsize)
     D  nRtnDataLen                  10I 0 const
     D  format                        8A   const
     D  qualObj                      20A   const
     D  member                       10A   const
     D  ovrProcessing                 1A   const
     D  error                              likeds(QUSEC) options(*nopass)
     D  findMember                    1A   const options(*nopass)
      *
      *  MBRD0100 Format
     D mbrd0100_t...
     D                 DS                  qualified               based(pDummy)
     D  bytRet                       10I 0
     D  bytAvl                       10I 0
     D  qFile                              likeds(Object_t)
     D  mbr                          10A
     D  attr                         10A
     D  srcType                      10A
     D  crtDatTim                    13A
     D  srcChgDatTim                 13A
     D  text                         50A
     D  isSrcFile                      N
      *
     D api_retrieveSystemValue...
     D                 PR                  extpgm('QWCRSVAL')
     D   receiver                 65535A   options(*varsize)
     D   recLength                   10I 0 const
     D   numberSysVal                10I 0 const
     D   sysValNames                 10A   const options(*varsize)
     D   errorcode                         likeds(QUSEC) options(*varsize)
      *
     D api_retrieveDatabaseFileDefinition...
     D                 PR                  extpgm('QDBRTVFD')
     D   receiver                 65535A   options(*varsize)
     D   length                      10I 0 const
     D   returnedQualifiedFileName...
     D                               10A
     D   format                       8A   const
     D   qualifiedFileName...
     D                               20A   const
     D   recordFormat                10A   const
     D   override                     1A   const
     D   system                      10A   const
     D   formatType                  10A   const
     D   error                             likeds(QUSEC) options(*varsize)
      *
     D api_convertDateTimeFormat...
     D                 PR                  extpgm('QWCCVTDT')
     D inputFormat                   10A   const
     D input                         26A   const options(*varsize)
     D outputFormat                  10A   const
     D output                        26A   options(*varsize)
     D error                               likeds(QUSEC) options(*varsize)
     D inputTimeZone                 10A   const options(*nopass)
     D outputTimezone                10A   const options(*nopass)
     D timeZoneInfo                 100A   const options(*varsize : *nopass)
     D timeZoneInfoLength...
     D                               10I 0 const options(*nopass)
     D precisionIndicator...
     D                                1A   const options(*nopass)
     D inputTimeIndicator...
     D                                1A   const options(*nopass)


      *
      * Common templates
      *
     D tmpl_listInfo   DS                  qualified template
     D   totalRecords                10I 0
     D   recordsReturned...
     D                               10I 0
     D   requestHandle...
     D                                4A
     D   recordLength                10I 0
     D   informationComplete...
     D                                 N
     D   created                     13A
     D   listStatus                    N
     D   reserved1                    1A
     D   returnedInfoLength...
     D                               10I 0
     D   firstRecord                 10I 0
     D   reserved2                   40A
      *
     D tmpl_userspace_header...
     D                 DS                  qualified template
     D   userArea                    64A
     D   headerSize                  10I 0
     D   releaseLevel                 4A
     D   formatName                   8A
     D   apiUsed                     10A
     D   dateCreated                 13A
     D   infoStatus                   1A
     D   usSizeUsed                  10I 0
     D   offsetInput                 10I 0
     D   sizeInput                   10I 0
     D   offsetHeader                10I 0
     D   headerSecSiz                10I 0
     D   offsetList                  10I 0
     D   listSecSize                 10I 0
     D   nmbrEntries                 10I 0
     D   entrySize                   10I 0
     D   entryCCSID                  10I 0
     D   regionID                     2A
     D   langID                       3A
     D   subListInd                   1A
     D   us_gen_reser                42A
      *---------------------------------------------------------------
      * Datenstruktur f r UserSpace Attribute  ndern OS400 API
      *---------------------------------------------------------------
     D tmpl_userspace_attributes...
     D                 DS                  qualified template
     D   size                        10I 0 inz(1)
     D   key                         10I 0 inz(3)
     D   dataLength                  10I 0 inz(1)
     D   data                         1A   inz('1')


      *
      * Userspace API
      *
      * generell: userspace = 10 stellen usname + 10 stellen lib name
      *
     D api_createUserspace...
     D                 PR                  extpgm('QUSCRTUS')
     D   usName                      20A   const
     D   usExtAtt                    10A   const
     D   usSize                      10I 0 const
     D   usInitValue                  1A   const
     D   usAuthority                 10A   const
     D   usDesc                      50A   const
     D   usReplace                   10A   const
     D   usError                           likeds(QUSEC) options(*varsize)
      *
     D api_deleteUserspace...
     D                 PR                  extpgm('QUSDLTUS')
     D   usname                      20A   const
     D   error                             likeds(QUSEC) options(*varsize)
      *
     D api_getUserspaceData...
     D                 PR                  extpgm('QUSRTVUS')
     D   usname                      20A   const
     D   startPos                    10I 0 const
     D   length                      10I 0 const
     D   receiver                 65535A   options(*varsize)
     D   error                             likeds(QUSEC)
     D                                     options(*varsize : *nopass)
      *
     D api_changeUserspaceAttributes...
     D                 PR                  extpgm('QUSCUSAT')
     D  retLib                       10A
     D  userspace                    20A   const
     D  usAttr                       64A   options(*varsize)
     D  error                              likeds(QUSEC) options(*varsize)
      *
     D api_retrieveUserspacePointer...
     D                 PR                  extpgm('QUSPTRUS')
     D  userspace                    20A   const
     D  pointer                        *
     D  error                       264A   const options(*nopass)
      *
     D api_changeUserspaceData...
     D                 PR                  extpgm('QUSCHGUS')
     D   userspace                   20A   const
     D   start                       10I 0 const
     D   length                      10I 0 const
     D   data                     65535A   const options(*varsize)
     D   forceChanges                 1A   const
     D   error                             likeds(QUSEC)
     D                                     options(*varsize : *nopass)
      *
     D api_retrieveUserspaceAttributes...
     D                 PR                  extpgm('QUSRUSAT')
     D  receiver                     30A   options(*varsize)
     D  length                       10I 0 const
     D  format                        8A   const
     D  qualUsName                   20A   const
     D  error                              likeds(QUSEC) options(*varsize)

      /endif

