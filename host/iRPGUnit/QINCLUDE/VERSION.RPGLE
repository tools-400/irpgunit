      /if not defined(IRPGUNIT_VERSION)
      /define IRPGUNIT_VERSION
      // ==========================================================================
      //  iRPGUnit - Product Version Utilities.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

     D getVersion...
     D                 pr                  extproc('+
     D                                     getVersion+
     D                                     ')
     D  version                      20a
     D  date                         10a

      /endif
