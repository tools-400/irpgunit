      /if defined(libl)
      /eof
      /endif
      /define libl
      // ==========================================================================
      //  iRPGUnit - Library list Utilities.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

       // Retrieves the library list.
     D getLibl         pr                  likeds(LiblData_t   )
     D                                     extproc('LIBL_getLibl')

       // Load library list (from job description)
     D loadLibl        pr                  likeds(LiblData_t   )
     D                                     extproc('LIBL_loadLibl')
     D  qJobD                              const  likeds(Object_t  )

       // Restore library list.
     D restoreLibl     pr
     D                                     extproc('LIBL_restoreLibl')
     D  liblData                           const  likeds(LiblData_t)

       // Change library list.
     D changeLibl      pr
     D                                     extproc('LIBL_changeLibl')
     D  curLib                       10a   const
     D  libL                               const  likeds(LibL_t)

       // Change library list according to what the user requested.
     D setTestSuiteLibl...
     D                 pr              n
     D                                     extproc('LIBL_setTestSuiteLibl')
     D  libl                               value likeds(LibL_t)
     D  jobd                               value likeds(Object_t)
     D  testSuiteLib                 10a   Value

      /include qinclude,TEMPLATES

