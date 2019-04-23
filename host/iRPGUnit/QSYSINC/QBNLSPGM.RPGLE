
       // List ILE service program information API
     D QBNLSPGM        pr                  ExtPgm('QBNLSPGM')
     D   usrSpc                      20a   const
     D   fmt                          8a   const
     D   srvPgm                      20a   const
     D   errors                   32766a   options(*varsize) noopt

       // Structure of an entry in a QBNLSPGM list.
     D SPGL0100_t      ds                  qualified based(template)
     D  srvPgm                       10a
     D  srvPgmLib                    10a
     D  mod                          10a
     D  modLib                       10a
     D  srcFile                      10a
     D  srcLib                       10a
     D  srcMbr                       10a
     D  modAttr                      10a
     D  modCrtDatTim                 13a
     D  srcUpdDatTim                 13a
     D  srtSeqTbl                    10a
     D  srtSeqTblLib                 10a
     D  langId                       10a
     D  optLvl                       10i 0
     D  maxOptLvl                    10i 0
     D  dbgDta                       10a
     D  rlsCrtOn                      6a
     D  rlsCrtFor                     6a
     D  reserved_1                   20a
     D  usrModInd                     1a
     D  licPgm                       13a
     D  ptfNbr                        5a
     D  aparId                        6a
     D  crtDta                        1a
     D  modCcsid                     10i 0
     D  objCtlLvl                     8a
     D  enablePrfCol                  1a
     D  profilingDta                 10a
     D  reserved_2                    1a
      *   ...

       // Structure of an entry in a QBNLSPGM list.
     D SPGL0610_t      ds                  qualified based(template)
        // Size of this entry. Each entry has a different size.
     D  size                         10i 0
     D  srvPgm                       20a
     D  ccsid                        10i 0
        // Memory offset to reach the procedure name.
     D  procNmOff                    10i 0
        // Longueur du nom de la procedure.
     D  procNmSize                   10i 0

