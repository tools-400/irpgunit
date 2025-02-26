**FREE
/if not defined (IRPGUNIT_USRSPC)
/define IRPGUNIT_USRSPC
// ==========================================================================
//  iRPGUnit - User Space Utilities.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

//
// Prototypes for USRSPC.
//

// Creates a User Space. Returns a pointer to it.
dcl-pr crtusrspc       pointer extproc('USRSPC_+
       crtUsrSpc+
       ');
   // qualified user space name.
  usrSpc          const likeds(object_t);
// User space text description.
text            char(50) const;
end-pr;

/endif
