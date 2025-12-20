**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test STRING.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  BNDDIR(&LI/IRPGUNIT);
//     >>PARM<<  COPTION(*SRCSTMT *EVENTF);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain Option(*SrcStmt);
// The following control options are required
// for test case testParseNum().
ctl-opt ExprOpts(*RESDECPOS) DecEdit('0,');

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,STRING
/include qinclude,TEMPLATES
/include qinclude,JSONWTR

//----------------------------------------------------------------------
//   Global Constants
//----------------------------------------------------------------------

dcl-c CRLF_EBCDIC x'0d25';
dcl-c CRLF_UTF8 x'0D0A';
dcl-c TAB_EBCDIC x'05';
dcl-c TAB_SIZE 4; // Json indention of XMLWRITER module

//----------------------------------------------------------------------
//   Tests
//----------------------------------------------------------------------

dcl-proc test_pure_array export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s text varchar(1024);
  dcl-s expected varchar(1024);

  dcl-c CRLF_UTF8 x'0D25';

  expected = '[' + CRLF_UTF8 +
             '    "value1",' + CRLF_UTF8 +
             '    "value2"' + CRLF_UTF8 +
             ']';

  Json_clear('': 0: 0: 0);
  Json_startArray();
  Json_addString('value1');
  Json_addString('value2');
  Json_endArray();

  text = Json_get();
  assertEqual(expected: text);

end-proc;

dcl-proc test_new_line_after_object export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s text varchar(1024);
  dcl-s expected varchar(1024);

  dcl-c CRLF_UTF8 x'0D25';

  expected = '{' + CRLF_UTF8 +
             '    "theInnerObject": {' + CRLF_UTF8 +
             '        "theInnerKey": "theInnerValue"' + CRLF_UTF8 +
             '    },' + CRLF_UTF8 +
             '    "theKey": "theValue"' + CRLF_UTF8 +
             '}';

  Json_clear('': 0: 0: 0);
  Json_startObject();

  Json_addKey('theInnerObject');
  Json_startObject();
  Json_addKey('theInnerKey');
  Json_addString('theInnerValue');
  Json_endObject();

  Json_addKey('theKey');
  Json_addString('theValue');

  Json_endObject();

  text = Json_get();
  assertEqual(expected: text);

end-proc;

dcl-proc test_new_line_after_array export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s text varchar(1024);
  dcl-s expected varchar(1024);

  dcl-c CRLF_UTF8 x'0D25';

  expected = '{' + CRLF_UTF8 +
             '    "theArray": [' + CRLF_UTF8 +
             '        "value1",' + CRLF_UTF8 +
             '        "value2"' + CRLF_UTF8 +
             '    ],' + CRLF_UTF8 +
             '    "theKey": "theValue"' + CRLF_UTF8 +
             '}';

  Json_clear('': 0: 0: 0);
  Json_startObject();

  Json_addKey('theArray');
  Json_startArray();
  Json_addString('value1');
  Json_addString('value2');
  Json_endArray();

  Json_addKey('theKey');
  Json_addString('theValue');

  Json_endObject();

  text = Json_get();
  assertEqual(expected: text);

end-proc;

dcl-proc test_no_pretty_print export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s text varchar(1024);

  Json_clear('': 0: 0: 0);
  Json_setPrettyPrintEnabled(*off);

  Json_startObject();
  Json_addKey('theKey');
  Json_addString('theString');
  Json_endObject();

  text = Json_get();
  assertEqual('{"theKey":"theString"}': text);

end-proc;

dcl-proc test_objects_array export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s text varchar(1024);

  // add key at the start of an object
  Json_clear();
  Json_setPrettyPrintEnabled(*off);
  Json_startObject();
  Json_addKey('theArray');
  Json_startArray();

  Json_startObject();
  Json_addKey('item1');
  Json_addString('Hello');
  Json_endObject();

  Json_startObject();
  Json_addKey('item2');
  Json_addString('World');
  Json_endObject();

  Json_endArray();
  Json_endObject();

  text = Json_get();
  assertEqual('{"theArray":[{"item1":"Hello"},{"item2":"World"}]}': text);

end-proc;

dcl-proc test_values_array export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s text varchar(1024);

  // add key at the start of an object
  Json_clear();
  Json_setPrettyPrintEnabled(*off);
  Json_startObject();
  Json_addKey('theArray');
  Json_startArray();

  Json_addString('Hello');
  Json_addString('World');

  Json_endArray();
  Json_endObject();

  text = Json_get();
  assertEqual('{"theArray":["Hello","World"]}': text);

end-proc;

dcl-proc test_addKey export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s text varchar(1024);

  // add key with integer value
  Json_clear();
  Json_setPrettyPrintEnabled(*off);

  Json_startObject();
  Json_addKey('theKey');
  Json_addInteger(1);
  Json_endObject();

  text = Json_get();
  assertEqual('{"theKey":1}': text);

  // add key with a quoted string value
  Json_clear();
  Json_setPrettyPrintEnabled(*off);

  Json_startObject();
  Json_addKey('theKey');
  Json_addString('"theValue"');
  Json_endObject();

  text = Json_get();
  assertEqual('{"theKey":"\"theValue\""}': text);

  // add key with Json object
  Json_clear();
  Json_setPrettyPrintEnabled(*off);
  Json_startObject();
  Json_addKey('theArray');
  Json_startArray();
  Json_addKey('theValue');
  Json_addInteger(1);
  Json_endArray();
  Json_endObject();

  text = Json_get();
  assertEqual('{"theArray":["theValue":1]}': text);

end-proc;

dcl-proc test_addValue export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s text varchar(1024);

  // add multiple string key/value pairs
  Json_clear();
  Json_setPrettyPrintEnabled(*off);
  Json_startObject();
  Json_addKey('theKey1');
  Json_addString('theValue1');
  Json_addKey('theKey2');
  Json_addString('theValue2');
  Json_endObject();

  text = Json_get();
  assertEqual('{"theKey1":"theValue1","theKey2":"theValue2"}': text);

  // add multiple integer key/value pairs
  Json_clear();
  Json_setPrettyPrintEnabled(*off);
  Json_startObject();
  Json_addKey('theKey1');
  Json_addInteger(123);
  Json_addKey('theKey2');
  Json_addInteger(456);
  Json_endObject();

  text = Json_get();
  assertEqual('{"theKey1":123,"theKey2":456}': text);

end-proc;

dcl-proc test_indent export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s text varchar(1024);

  Json_clear('': 0: 0: 1);
  text = Json_indent();
  assertEqual(TAB_SIZE * 1: %len(text));

  Json_clear('': 0: 0: 5);
  text = Json_indent();
  assertEqual(TAB_SIZE * 5: %len(text));

end-proc;

dcl-proc test_lastChar export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-s lastChar varchar(2);

  // last character, if it is a valid character
  Json_clear('Hello World');
  lastChar = Json_lastChar();
  assertEqual('d': lastChar);

  // last character, if it is a special value, such as CRLF
  Json_clear('Hello World' + CRLF_EBCDIC);
  lastChar = Json_lastChar();
  assertEqual(CRLF_UTF8: lastChar);

  // last character, if it is a special value, such as TAB
  Json_clear('Hello World' + TAB_EBCDIC);
  lastChar = Json_lastChar();
  assertEqual('d': lastChar);

end-proc;

