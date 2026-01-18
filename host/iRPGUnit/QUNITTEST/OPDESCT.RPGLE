**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Operational Desc. for Cobol.
// ==========================================================================
//  Copyright (c) 2013-2020 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,ASSERT
/include qinclude,TEMPLATES

//----------------------------------------------------------------------
//   v3 and v4 prototypes.
//----------------------------------------------------------------------

// assert() prototypes old style, new style
// and brand new style with 'opdesc' (v4).
dcl-pr assert_v3_oldStyle extproc('assert');
  condition       ind const;
  msgIfFalse      like(OldMsg_t) options(*nopass) const;
end-pr;

dcl-pr assert_v3_newStyle extproc('assert');
  condition       ind const;
  msgIfFalse      varchar(16384) options(*varsize: *nopass) const;
end-pr;

dcl-pr assert_v4_fix_length extproc('assert') opdesc;
  condition       ind const;
  msgIfFalse      char(16384) options(*varsize: *nopass) const;
end-pr;

dcl-pr assert_v4_varying_length extproc('assert') opdesc;
  condition       ind const;
  msgIfFalse      varchar(16384) options(*varsize: *nopass) const;
end-pr;

// aEqual() prototypes with and without 'opdesc'.
dcl-pr aEqual_v3 extproc('aEqual');
  expected        char(32565) const;
  actual          char(32565) const;
  fieldName       varchar(64) options(*nopass: *omit) const;
end-pr;

dcl-pr aEqual_v4_fix_length extproc('aEqual') opdesc;
  expected        char(32565) const;
  actual          char(32565) const;
  fieldName       char(64) options(*nopass: *omit) const;
end-pr;

dcl-pr aEqual_varying_length extproc('aEqual') opdesc;
  expected        varchar(32565) const;
  actual          varchar(32565) const;
  fieldName       varchar(64) options(*nopass: *omit) const;
end-pr;

//----------------------------------------------------------------------
//   Test Procedures
//----------------------------------------------------------------------

//----------------------------------------------------------------------
//  Test the old v3 style of parameter 'msgIfFalse', which was a
//  128-byte fix-length field.
//----------------------------------------------------------------------
dcl-proc testAssert_v3_oldStyle export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s expectedMsg varchar(500);
  dcl-ds assertFailEvtLong_v2 likeds(assertFailEvtLong_t);

  // Setup.

  expectedMsg = 'Successfully called old style assert()';

  // Execution.

  monitor;
    assert_v3_oldStyle(*off:  expectedMsg);
    fail('Should have thrown an error');
  on-error;
  endmon;

  // Controls.

  assertFailEvtLong_v2 = getAssertFailEvtLong();

  assert(assertFailEvtLong_v2.msg = expectedMsg
         : 'Message does not match the expected value');
  assert(%len(assertFailEvtLong_v2.msg) = %len(expectedMsg)
         : 'Message lengths do not match');

end-proc;


//----------------------------------------------------------------------
//  The the new v3 style of parameter 'msgIfFalse', which is a
//  16384-byte varying-length field.
//----------------------------------------------------------------------
dcl-proc testAssert_v3_newStyle export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s expectedMsg varchar(500);
  dcl-ds assertFailEvtLong_v2 likeds(assertFailEvtLong_t);

  // Setup.

  expectedMsg = 'Successfully called new style assert()';

  // Execution.

  monitor;
    assert_v3_newStyle(*off:  expectedMsg);
    fail('Should have thrown an error');
  on-error;
  endmon;

  // Controls.

  assertFailEvtLong_v2 = getAssertFailEvtLong();

  assert(assertFailEvtLong_v2.msg = expectedMsg
         : 'Message does not match the expected value');
  assert(%len(assertFailEvtLong_v2.msg) = %len(expectedMsg)
         : 'Message lengths do not match');

end-proc;


//----------------------------------------------------------------------
//  Test the new v4 style of parameter 'msgIfFalse' with an
//  operational descriptor and a fix-length field.
//  Most likely used by Cobol test cases.
//----------------------------------------------------------------------
dcl-proc testAssert_v4_fix_length export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s expectedMsg varchar(500);
  dcl-ds assertFailEvtLong_v2 likeds(assertFailEvtLong_t);

  // Setup.

  expectedMsg = 'Successfully called new style assert()';

  // Execution.

  monitor;
    assert_v4_fix_length(*off:  expectedMsg);
    fail('Should have thrown an error');
  on-error;
  endmon;

  // Controls.

  assertFailEvtLong_v2 = getAssertFailEvtLong();

  assert(assertFailEvtLong_v2.msg = expectedMsg
         : 'Message does not match the expected value');
  assert(%len(assertFailEvtLong_v2.msg) = %len(expectedMsg)
         : 'Message lengths do not match');

end-proc;


//----------------------------------------------------------------------
//  Test the new v4 style of parameter 'msgIfFalse' with an
//  operational descriptor and a varying length field.
//----------------------------------------------------------------------
dcl-proc testAssert_v4_varying_length export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s expectedMsg varchar(500);
  dcl-ds assertFailEvtLong_v2 likeds(assertFailEvtLong_t);

  // Setup.

  expectedMsg = 'Successfully called new style assert()';

  // Execution.

  monitor;
    assert_v4_varying_length(*off:  expectedMsg);
    fail('Should have thrown an error');
  on-error;
  endmon;

  // Controls.

  assertFailEvtLong_v2 = getAssertFailEvtLong();

  assert(assertFailEvtLong_v2.msg = expectedMsg
         : 'Message does not match the expected value');
  assert(%len(assertFailEvtLong_v2.msg) = %len(expectedMsg)
         : 'Message lengths do not match');

end-proc;


//----------------------------------------------------------------------
//  Test aEqual() with v3 parameter types and without the
//  'opdesc' keyword.
//----------------------------------------------------------------------
dcl-proc testAEqual_v3 export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s expectedMsg varchar(500);
  dcl-ds assertFailEvtLong_v2 likeds(assertFailEvtLong_t);

  // Setup.

  expectedMsg = 'aFieldName: Expected ''A'', but was ''B''.';

  // Execution.

  monitor;
    aEqual_v3('A': 'B':  'aFieldName');
    fail('Should have thrown an error');
  on-error;
  endmon;

  // Controls.

  assertFailEvtLong_v2 = getAssertFailEvtLong();

  assert(assertFailEvtLong_v2.msg = expectedMsg
         : 'Message does not match the expected value');
  assert(%len(assertFailEvtLong_v2.msg) = %len(expectedMsg)
         : 'Message lengths do not match');

end-proc;


//----------------------------------------------------------------------
//  Test the new v4 style with an
//  operational descriptor and a fix-length fields.
//  Most likely used by Cobol test cases.
//----------------------------------------------------------------------
dcl-proc testAEqual_v4_fix_length export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s expectedMsg varchar(500);
  dcl-ds assertFailEvtLong_v2 likeds(assertFailEvtLong_t);

  // Setup.

  expectedMsg = 'aFieldName: Expected ''A'', but was ''B''.';

  // Execution.

  monitor;
    aEqual_v4_fix_length('A': 'B':  'aFieldName');
    fail('Should have thrown an error');
  on-error;
  endmon;

  // Controls.

  assertFailEvtLong_v2 = getAssertFailEvtLong();

  assert(assertFailEvtLong_v2.msg = expectedMsg
         : 'Message does not match the expected value');
  assert(%len(assertFailEvtLong_v2.msg) = %len(expectedMsg)
         : 'Message lengths do not match');

end-proc;


//----------------------------------------------------------------------
//  Test the new v4 style with an
//  operational descriptor and a varying-length fields.
//----------------------------------------------------------------------
dcl-proc testAEqual_v4_varying_length export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s expectedMsg varchar(500);
  dcl-ds assertFailEvtLong_v2 likeds(assertFailEvtLong_t);

  // Setup.

  expectedMsg = 'aFieldName: Expected ''A'', but was ''B''.';

  // Execution.

  monitor;
    aEqual_varying_length('A': 'B':  'aFieldName');
    fail('Should have thrown an error');
  on-error;
  endmon;

  // Controls.

  assertFailEvtLong_v2 = getAssertFailEvtLong();

  assert(assertFailEvtLong_v2.msg = expectedMsg
         : 'Message does not match the expected value');
  assert(%len(assertFailEvtLong_v2.msg) = %len(expectedMsg)
         : 'Message lengths do not match');

end-proc;

