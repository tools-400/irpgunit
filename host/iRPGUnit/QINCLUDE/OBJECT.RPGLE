**FREE
/if not defined (IRPGUNIT_OBJECT)
/define IRPGUNIT_OBJECT
// ==========================================================================
//  iRPGUnit - Object Utilities.
// ==========================================================================
//  Copyright (c) 2013-2020 iRPGUnit Project Team
//  All rights reserved. Ths program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

// Resolve object library.
dcl-pr Object_resolveLibrary char(10) extproc('Object_Object_resolveLibrary');
  object          const likeds(object_t);
  objType         char(10) const;
end-pr;

dcl-pr Object_getAttribute char(10) extproc('Object_Object_getAttribute');
  object          const likeds(object_t);
  objType         char(10) const;
end-pr;

dcl-pr Object_isDirty ind extproc('Object_Object_isDirty');
  object          const likeds(object_t);
  objType         char(10) const;
end-pr;

dcl-pr Object_exists ind extproc('Object_Object_exists');
  object          const likeds(object_t);
  objType         char(10) const;
  mbr             char(10) const options(*nopass);
end-pr;

dcl-pr Object_qName varchar(21) extproc('Object_Object_qName');
  object          const likeds(object_t);
end-pr;

dcl-pr TestSuite_exists ind extproc('Object_TestSuite_exists');
  srvPgm          char(10) const;
  library         char(10) const;
end-pr;

dcl-pr TestSuite_isDirty ind extproc('Object_TestSuite_isDirty');
  srvPgm          char(10) const;
  library         char(10) const;
end-pr;

/endif
