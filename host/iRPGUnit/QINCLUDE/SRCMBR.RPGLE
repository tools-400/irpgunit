      /if defined(IRPGUNIT_SRCMBR)
      /eof
      /endif
      /define IRPGUNIT_SRCMBR
      // ==========================================================================
      //  iRPGunit - Source Member Utilities.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

      /include qinclude,TEMPLATES

     D SrcMbr_initialize...
     D                 pr
     D                                     extproc('SRCMBR_+
     D                                     SrcMbr_initialize+
     D                                     ')

     D SrcMbr_getTestSuiteSrc...
     D                 pr                         likeds(SrcMbr_t)
     D                                     extproc('SRCMBR_+
     D                                     SrcMbr_getTestSuiteSrc+
     D                                     ')
     D  object                             const  likeds(Object_t)

     D SrcMbr_getModSrc...
     D                 pr                         likeds(SrcMbr_t)
     D                                     extproc('SRCMBR_+
     D                                     SrcMbr_getModSrc+
     D                                     ')
     D  object                             const  likeds(Object_t)
     D  module                             const  likeds(Object_t)

     D SrcMbr_getLastChgDate...
     D                 pr              z
     D                                     extproc('SRCMBR_+
     D                                     SrcMbr_getLastChgDate+
     D                                     ')
     D  qSrcFile                           const  likeds(Object_t )
     D  srcMbr                       10a   const

     D SrcMbr_getDescription...
     D                 pr            50a   varying
     D                                     extproc('SRCMBR_+
     D                                     SrcMbr_getDescription+
     D                                     ')
     D  qSrcFile                           const  likeds(Object_t )
     D  srcMbr                       10a   const

