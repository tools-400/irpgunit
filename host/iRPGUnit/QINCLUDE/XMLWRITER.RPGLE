**FREE
// ==========================================================================
//  iRPGUnit - XML File Writer.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

dcl-pr writeXmlFile extproc('XMLWRITER_writeXmlFile');
  filepath char(1024) const;
  testSuite likeds(testSuite_t) const;
  testSuiteName likeds(Object_t) const;
  result likeds(result_t) const;
end-pr;

