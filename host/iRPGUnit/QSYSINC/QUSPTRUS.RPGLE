       /if not defined (IRPGUNIT_QUSPTRUS)
       /define IRPGUNIT_QUSPTRUS

       //
       // Retrieve pointer to user space API
       //

     D QUSPTRUS        pr                  ExtPgm('QUSPTRUS')
     D   usrSpc                      20a   const
     D   pointer                       *

      /endif

