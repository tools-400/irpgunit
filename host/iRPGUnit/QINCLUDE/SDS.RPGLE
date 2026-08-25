**free
/if NOT defined(SDS)
/define SDS
// ==========================================================================
//  Programm Status Data Structure.
// ==========================================================================
//  Copyright (c) 2013-2026 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

/if defined(IRPGUNIT_STMF)
/include qinclude/TYPES_H.rpgle
/else
/include qinclude,TYPES_H
/endif

dcl-ds sds likeds(sds_t) psds;

/endif
