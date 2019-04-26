      // ==========================================================================
      //  iRPGUnit - User Space Utilities.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================
      // >>PRE-COMPILER<<
      //   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
      //   >>IMPORTANT<<
      //     >>PARM<<  OPTION(*EVENTF);
      //     >>PARM<<  DBGVIEW(*LIST);
      //   >>END-IMPORTANT<<
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

     H NoMain
      /include qinclude,H_SPEC
      /include qinclude,COPYRIGHT

       //----------------------------------------------------------------------
       //   Public Procedure Prototypes
       //----------------------------------------------------------------------

      /include qinclude,USRSPC
      /include qinclude,ERRORCODE

       //----------------------------------------------------------------------
       //   Imported Procedures
       //----------------------------------------------------------------------

      /include qinclude,SYSTEMAPI


       //----------------------------------------------------------------------
       //   Global DS
       //----------------------------------------------------------------------

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
     D percolateErrors...
     D                 ds                  likeds(percolateErrors_t)
     D                                     inz(*likeds)
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
