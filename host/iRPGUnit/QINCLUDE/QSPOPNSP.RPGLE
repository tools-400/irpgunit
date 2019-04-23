
       //
       // Open Spooled File API
       //

     D QSPOPNSP        pr                  ExtPgm('QSPOPNSP')
     D   splfHdl                     10i 0
     D   qlfJobNm                          const like(QlfJobNm_t)
     D   intJobId                    16a   const
     D   intSplfId                   16a   const
     D   splfNm                      10a   const
     D   splfNb                      10i 0 const
     D   nbOfBuffers                 10i 0 const
     D   error                    32766a   options(*varsize) noopt
