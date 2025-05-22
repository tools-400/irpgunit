**FREE
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

dcl-pr SrcMbr_initialize extproc('SRCMBR_SrcMbr_initialize');
end-pr;

dcl-pr SrcMbr_getTestSuiteSrc likeds(srcInf_t) extproc('SRCMBR_SrcMbr_getTestSuiteSrc');
  object          const  likeds(object_t);
end-pr;

dcl-pr SrcMbr_getModSrc likeds(srcInf_t) extproc('SRCMBR_SrcMbr_getModSrc');
  object          const  likeds(object_t);
  module          const  likeds(object_t);
end-pr;

dcl-pr SrcMbr_getLastChgDate timestamp extproc('SRCMBR_SrcMbr_getLastChgDate');
  qsrcfile        const  likeds(object_t );
  srcMbr          char(10) const;
end-pr;

dcl-pr SrcMbr_getDescription varchar(50) extproc('SRCMBR_SrcMbr_getDescription');
  qsrcfile        const  likeds(object_t );
  srcMbr          char(10) const;
end-pr;

dcl-pr SrcMbr_getType varchar(10) extproc('SRCMBR_SrcMbr_getType');
  qsrcfile        const  likeds(object_t );
  srcMbr          char(10) const;
end-pr;

