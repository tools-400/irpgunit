      /if not defined (IRPGUNIT_OBJECT)
      /define IRPGUNIT_OBJECT
      // ==========================================================================
      //  iRPGUnit - Object Utilities.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. Ths program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

       // Resolve object library.
     D Object_resolveLibrary...
     D                 pr            10a
     D                                     extproc('OBJECT_+
     D                                     Object_resolveLibrary+
     D                                     ')
     D  object                             const likeds(Object_t)
     D  objType                      10a   const

     D Object_isDirty...
     D                 pr              n
     D                                     extproc('OBJECT_+
     D                                     Object_isDirty+
     D                                     ')
     D  object                             const likeds(Object_t)
     D  objType                      10a   const

     D Object_exists...
     D                 pr              n
     D                                     extproc('OBJECT_+
     D                                     Object_exists+
     D                                     ')
     D  object                             const likeds(Object_t)
     D  objType                      10a   const

     D TestSuite_exists...
     D                 pr              n
     D                                     extproc('OBJECT_+
     D                                     TestSuite_exists+
     D                                     ')
     D  srvPgm                       10a   const
     D  library                      10a   const

     D TestSuite_isDirty...
     D                 pr              n
     D                                     extproc('OBJECT_+
     D                                     TestSuite_isDirty+
     D                                     ')
     D  srvPgm                       10a   const
     D  library                      10a   const

      /endif
