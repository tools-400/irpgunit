
       //
       // Open list structure
       //
       // Reference :
       // http://publib.boulder.ibm.com/iseries/v5r2/index.htm?info/apis/oli.htm
       //

     D dsOpnList       ds                  qualified based(template)
     D  totalRcdCnt                  10i 0
     D  retRcdCnt                    10i 0
     D  rqsHdl                        4a
     D  rcdLen                       10i 0
     D  infoCompInd                   1a
     D  crtDateTime                  13a
     D  listStatusInd                 1a
     D                                1a
     D  rtnInfoLen                   10i 0
     D  firstRcdIdx                  10i 0
     D                               40a

