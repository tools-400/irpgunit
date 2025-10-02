**FREE
// ==========================================================================
//  iRPGUnit - Json Memory Writer.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Clears (initializes) the Json memory writer.
//
// @param value        - Initial value of the memory buffer
// @param count_object - Number of open Json objects. Used for self-tests only
// @param count_array  - Number of open Json arrays. Used for self-tests only
// @param count_indent - Current indention level if pretty-print is enabled
///
dcl-pr Json_clear extproc(*dclcase);
  value        varchar(50000) options(*varsize: *nopass) const; // self-tests only!
  count_object int(10) options(*nopass) const;                  // self-tests only!
  count_array  int(10) options(*nopass) const;                  // self-tests only!
  count_indent int(10) options(*nopass) const;                  // self-tests only!
end-pr;

///
// Enables or disabled pretty-print.
//
// @param enabled - '*on' enabled pretty-print
///
dcl-pr Json_setPrettyPrintEnabled ind extproc(*dclcase);
  enabled  ind const;
end-pr;

///
// Returns the Json data.
///
dcl-pr Json_get varchar(50000) extproc(*dclcase);
end-pr;

///
// Starts a new Json object.
///
dcl-pr Json_startObject extproc(*dclcase);
end-pr;

///
// Ends the current Json object.
///
dcl-pr Json_endObject extproc(*dclcase);
end-pr;

///
// Starts a new Json array.
///
dcl-pr Json_startArray extproc(*dclcase);
end-pr;

///
// Ends the current Json array.
///
dcl-pr Json_endArray extproc(*dclcase);
end-pr;

///
// Adds a Json key.
//
// @param key - Key value
///
dcl-pr Json_addKey extproc(*dclcase);
  key like(string_t) const;
end-pr;

///
// Adds a Json 'String' value that is assigned to the previously added key.
//
// @param value - Value that is assigned to the key
///
dcl-pr Json_addString extproc(*dclcase);
  value like(string_t) const;
end-pr;

///
// Adds a Json 'Integer' value that is assigned to the previously added key.
//
// @param value - Value that is assigned to the key
///
dcl-pr Json_addInteger extproc(*dclcase);
  integer int(20) const;
end-pr;

///
// Returns the number of spaces required for pretty-print.
// Exported for self-tests only.
///
dcl-pr Json_indent varchar(1024)  extproc(*dclcase);
end-pr;

///
// Returns the last character added to the Json object. Can be
// a legal character or CRLF.
// Exported for self-tests only.
///
dcl-pr Json_lastChar varchar(2) extproc(*dclcase);
end-pr;

/include qinclude,TESTCASE

