**FREE
/if not defined (IRPGUNIT_ASSERT)
/define IRPGUNIT_ASSERT
// ==========================================================================
//  iRPGUnit - Assertion Facilities.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================


/include qinclude,TESTCASE

//----------------------------------------------------------------------
//   Procedure Prototypes
//----------------------------------------------------------------------

dcl-pr doAssert extproc('ASSERT_doAssert');
  condition       ind const;
  msgIfFalse      varchar(16384) const  options(*varsize);
  toCallStackE    int(10) const;
  startProc       varchar(256) const  options(*varsize);
end-pr;

/endif

