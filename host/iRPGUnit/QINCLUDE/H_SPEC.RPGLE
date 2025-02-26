**FREE
// ==========================================================================
//  iRPGUnit H-Specifications.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
ctl-opt debug option(*srcstmt: *nodebugio);
/if not defined(NO_DECEDIT)
ctl-opt decedit('0,');
/endif
ctl-opt datedit(*dmy.);
ctl-opt datFmt(*iso ) timFmt(*iso );
ctl-opt expropts(*resdecpos);
ctl-opt extbinint(*yes);
ctl-opt ccsid(*char: *jobrun);
ctl-opt reqprexp(*require);
