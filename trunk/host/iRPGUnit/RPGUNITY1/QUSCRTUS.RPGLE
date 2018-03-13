
       //
       // Create User Space API
       //

     D QUSCRTUS        PR                  ExtPgm('QUSCRTUS')
     D   usrSpc                      20a   const
     D   extAttr                     10a   const
     D   initSize                    10i 0 const
     D   initVal                      1a   const
     D   publicAuth                  10a   const
     D   text                        50a   const
     D   replace                     10a   const
     D   error                    32766a   options(*varsize) noopt

       // User Space creation parameters.
     D UsrSpcCrtParm_t...
     D                 ds                  qualified based(template)
     D  nm                           20a
     D  attribute                    10a
     D  size                         10i 0
     D  value                         1a
     D  auth                         10a
     D  text                         50a
     D  replace                      10a

