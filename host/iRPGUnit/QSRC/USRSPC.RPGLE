      //
      // User Space utilities.
      //

     H NoMain
      /include qinclude,H_SPEC


       //----------------------------------------------------------------------
       //   Public Procedure Prototypes
       //----------------------------------------------------------------------

      /include qinclude,USRSPC


       //----------------------------------------------------------------------
       //   Imported Procedures
       //----------------------------------------------------------------------

      /include qinclude,QUSCRTUS
      /include qinclude,QUSPTRUS


       //----------------------------------------------------------------------
       //   Global DS
       //----------------------------------------------------------------------

      /include qinclude,ERRORCODE
      /include qinclude,TEMPLATES


       //----------------------------------------------------------------------
       //   Procedures Definition
       //----------------------------------------------------------------------

     P crtUsrSpc       b                   export
      //----------------------------------------------------------------------
      // Creates a user space. See prototype.
      //----------------------------------------------------------------------
     D crtUsrSpc...
     D                 pi              *
     D  usrSpc                             const likeds(Object_t)
     D  text                         50a   const

       // User Space to store proc list.
     D usrSpcCrtParm   ds                  likeds(UsrSpcCrtParm_t)
       // Pointer to the user space.
     D usrSpc_p        s               *

      /free

        usrSpcCrtParm.nm        = usrSpc;
        usrSpcCrtParm.attribute = 'USRSPC';
        usrSpcCrtParm.size      = 1024;
        usrSpcCrtParm.value     = x'00';
        usrSpcCrtParm.auth      = '*ALL';
        usrSpcCrtParm.text      = text;
        usrSpcCrtParm.replace   = '*YES';

        QUSCRTUS( usrSpcCrtParm.nm :
                  usrSpcCrtParm.attribute :
                  usrSpcCrtParm.size :
                  usrSpcCrtParm.value :
                  usrSpcCrtParm.auth :
                  usrSpcCrtParm.text :
                  usrSpcCrtParm.replace :
                  percolateErrors );

        QUSPTRUS( usrSpc : usrSpc_p );

        return usrSpc_p;

      /end-free
     P                 e
