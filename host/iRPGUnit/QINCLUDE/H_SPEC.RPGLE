      // ==========================================================================
      //  iRPGUnit H-Specifications.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================
     H DEBUG
     H OPTION(*SRCSTMT : *NODEBUGIO)
      /IF NOT DEFINED(NO_DECEDIT)
     H DECEDIT('0,')
      /ENDIF
     H DATEDIT(*DMY.)
     H DATFMT(*ISO ) TIMFMT(*ISO )
     H EXPROPTS(*RESDECPOS)
     H EXTBININT(*YES)
     H CCSID(*CHAR: *JOBRUN)
