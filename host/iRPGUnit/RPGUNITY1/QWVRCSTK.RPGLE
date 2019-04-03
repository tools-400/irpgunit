
      // Prototype for API QWVRCSTK (Retrieve Call Stack).

     DQWVRCSTK         pr                  ExtPgm('QWVRCSTK')
     D rawCallStk                 32766a   options(*varsize)
     D rawCallStkLen                 10i 0 const
     D fmtRcvInfo                     8a   const
     D jobIdInfo                           const likeds(dsJIDF0100)
     D fmtJobIdInfo                   8a   const
     D errors                     32766a   options(*varsize) noopt

     D dsJIDF0100      ds                  qualified based(template)
     D  jobNm                        10a
     D  usrNm                        10a
     D  jobNb                         6a
     D  intJobId                     16a
     D  reserved                      2a
     D  threadInd                    10i 0
     D  threadId                      8a

     D dsCSTK0100Hdr   ds                  qualified based(template)
     D  bytesP                       10i 0
     D  bytesA                       10i 0
     D  nbCallStkEntForThread...
     D                               10i 0
     D  callStkOff                   10i 0
     D  nbCallStkEntRtn...
     D                               10i 0
     D  threadId                      8a
     D  infoSts                       1a

     D dsCSTK0100Ent   ds                  qualified based(template)
     D  len                          10i 0
     D  dsplToSttId                  10i 0
     D  nbSttId                      10i 0
     D  dsplToProcNm                 10i 0
     D  procNmLen                    10i 0
     D  rqsLvl                       10i 0
     D  pgmNm                        10a
     D  pgmLibNm                     10a
     D  miInstNb                     10i 0
     D  modNm                        10a
     D  modLibNm                     10a
     D  ctlBndry                      1a
     D                                3a
     D  actGrpNb                     10u 0
     D  actGrpNm                     10a
     D                                2a
     D  pgmAspNm                     10a
     D  pgmLibAspNm                  10a
     D  pgmAspNb                     10i 0
     D  pgmLibAspNb                  10i 0


