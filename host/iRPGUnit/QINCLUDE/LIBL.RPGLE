**FREE
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
dcl-pr getLibl likeds(liblData_t) extproc('LIBL_getLibl');
end-pr;

// Load library list (from job description)
dcl-pr loadLibl likeds(liblData_t) extproc('LIBL_loadLibl');
  qJobD           const  likeds(object_t  );
end-pr;

// Restore library list.
dcl-pr restoreLibl extproc('LIBL_restoreLibl');
  libldata        const  likeds(liblData_t);
end-pr;

// Change library list.
dcl-pr changeLibl extproc('LIBL_changeLibl');
  curlib          char(10) const;
  libl            const  likeds(libl_t);
end-pr;

// Change library list according to what the user requested.
dcl-pr setTestSuiteLibl ind extproc('LIBL_setTestSuiteLibl');
  libl            value likeds(libl_t);
  jobD            value likeds(object_t);
  testsuitelib    char(10) value;
end-pr;

/include qinclude,TEMPLATES

