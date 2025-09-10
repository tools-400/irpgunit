**FREE
/if not defined(IRPGUNIT_STRING)
/define IRPGUNIT_STRING
// ==========================================================================
//  iRPGUnit - String Utilities.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Converts a string to uppercase characters
//
// Transforms all lowercase alphabetic characters in the input string to their
// uppercase equivalents. Non-alphabetic characters remain unchanged. Supports
// both ASCII and EBCDIC character sets based on the job's CCSID.
//
// @param string - Input string to convert to uppercase
//                 Can be any length supported by String_t template
//                 Special characters and numbers remain unchanged
//
// @return String with all alphabetic characters converted to uppercase
//         Original length and spacing preserved
//         Non-alphabetic characters unchanged
///
dcl-pr uCase like(String_t) extproc('STRING_uCase');
  string like(String_t) options(*varsize) const;
end-pr;

///
// Converts a string to lowercase characters
//
// Transforms all uppercase alphabetic characters in the input string to their
// lowercase equivalents. Non-alphabetic characters remain unchanged. Supports
// both ASCII and EBCDIC character sets based on the job's CCSID.
//
// @param string - Input string to convert to lowercase
//                 Can be any length supported by String_t template
//                 Special characters and numbers remain unchanged
//
// @return String with all alphabetic characters converted to lowercase
//         Original length and spacing preserved
//         Non-alphabetic characters unchanged
///
dcl-pr lCase like(String_t) extproc('STRING_lCase');
  string like(String_t) options(*varsize) const;
end-pr;

///
// Extracts the leftmost characters from a string
//
// Returns a substring containing the specified number of characters from the
// beginning (left side) of the input string. If the requested length exceeds
// the string length, the entire string is returned without error.
//
// @param string - Input string to extract characters from
//                 Can be any length supported by String_t template
//                 Empty string returns empty result
// @param length - Number of characters to extract from the left
//                 Must be >= 0; negative values treated as 0
//                 Values exceeding string length return entire string
//
// @return Substring containing the leftmost characters up to specified length
//         Empty string if length is 0 or input string is empty
//         Entire string if length exceeds actual string length
///
dcl-pr leftStr like(String_t) extproc('STRING_leftStr');
  string like(String_t) options(*varsize) const;
  length int(10) const;
end-pr;

///
// Checks if a string begins with the specified prefix
//
// Performs a case-sensitive comparison to determine if the input string starts
// with the specified prefix text. Both empty strings and null values are
// handled gracefully without causing errors.
//
// @param prefix - Prefix text to search for at the beginning of the string
//                 Can be any length; empty prefix always returns *ON
//                 Case-sensitive comparison performed
// @param string - String to check for the prefix
//                 Can be any length supported by String_t template
//                 Empty string only matches empty prefix
//
// @return *ON if string starts with the specified prefix (case-sensitive)
//         *OFF if string does not start with prefix
//         *ON if prefix is empty (empty prefix matches any string)
//         *OFF if string is empty but prefix is not empty
///
dcl-pr startsWith ind extproc('STRING_startsWith');
  prefix like(String_t) options(*varsize) const;
  string like(String_t) options(*varsize) const;
end-pr;

///
// Checks if a string ends with the specified suffix
//
// Performs a case-sensitive comparison to determine if the input string ends
// with the specified suffix text. Both empty strings and null values are
// handled gracefully without causing errors.
//
// @param suffix - Suffix text to search for at the end of the string
//                 Can be any length; empty suffix always returns *ON
//                 Case-sensitive comparison performed
// @param string - String to check for the suffix
//                 Can be any length supported by String_t template
//                 Empty string only matches empty suffix
//
// @return *ON if string ends with the specified suffix (case-sensitive)
//         *OFF if string does not end with suffix
//         *ON if suffix is empty (empty suffix matches any string)
//         *OFF if string is empty but suffix is not empty
///
dcl-pr endsWith ind extproc('STRING_endsWith');
  suffix like(String_t) options(*varsize) const;
  string like(String_t) options(*varsize) const;
end-pr;

///
// Checks if a string contains the specified text anywhere within it
//
// Performs a case-sensitive search to determine if the specified text appears
// anywhere within the input string. The search covers the entire string from
// beginning to end, not just at specific positions.
//
// @param text   - Text to search for within the string
//                 Can be any length; empty text always returns *ON
//                 Case-sensitive search performed
// @param string - String to search within for the specified text
//                 Can be any length supported by String_t template
//                 Empty string only contains empty text
//
// @return *ON if string contains the specified text anywhere within it
//         *OFF if string does not contain the text
//         *ON if text is empty (empty text is contained in any string)
//         *OFF if string is empty but text is not empty
///
dcl-pr contains ind extproc('STRING_contains');
  text   like(String_t) options(*varsize) const;
  string like(String_t) options(*varsize) const;
end-pr;

///
// Compares two strings for exact equality
//
// Performs a case-sensitive, character-by-character comparison of two strings
// to determine if they are identical. Handles different string lengths and
// both fixed-length and variable-length strings properly.
//
// @param generic - First string to compare
//                  Can be any length supported by String_t template
//                  Trailing spaces in fixed-length strings are significant
// @param string  - Second string to compare
//                  Can be any length supported by String_t template
//                  Must match first string exactly for equality
//
// @return *ON if both strings are identical in content and length
//         *OFF if strings differ in any way (content, length, case)
//         *ON if both strings are empty
///
dcl-pr compare ind extproc('STRING_compare');
  generic like(String_t) options(*varsize) const;
  string  like(String_t) options(*varsize) const;
end-pr;

///
// Checks if a string is enclosed in double quotes
//
// Determines whether the input string begins and ends with double quote (")
// characters. The string must have at least 2 characters and both the first
// and last characters must be double quotes for this to return *ON.
//
// @param string - String to check for enclosing double quotes
//                 Must be at least 2 characters long to be considered quoted
//                 Only double quotes (") are recognized, not single quotes
//
// @return *ON if string is enclosed in double quotes ("text")
//         *OFF if string is not quoted, too short, or uses other quote types
//         *OFF if string has quotes only at beginning OR end, but not both
///
dcl-pr isQuoted ind extproc('STRING_isQuoted');
  string like(String_t) options(*varsize) const;
end-pr;

///
// Encloses a string in double quotes
//
// Adds double quote characters (") at the beginning and end of the input string.
// If the string is already quoted, additional quotes are still added. This is
// useful for preparing strings for output where quoting is required.
//
// @param string - String to enclose in double quotes
//                 Can be empty string (results in empty quotes "")
//                 Existing quotes are not removed or escaped
//
// @return String enclosed in double quotes: "original string"
//         Empty input results in empty quotes: ""
//         Already quoted strings get additional quotes: ""quoted""
///
dcl-pr addQuotes like(String_t) extproc('STRING_addQuotes');
  string like(String_t) options(*varsize) const;
end-pr;

///
// Removes enclosing double quotes from a string
//
// Removes double quote characters (") from the beginning and end of a string
// if both are present. If the string is not properly quoted (missing quotes
// at either end), no modification is performed.
//
// @param string - Quoted string to process and remove quotes from
//                 Must have quotes at both beginning and end for removal
//                 Partially quoted strings remain unchanged
//
// @return String with enclosing quotes removed if properly quoted
//         Original string unchanged if not properly quoted
//         Empty string if input was empty quotes ""
///
dcl-pr removeQuotes like(String_t) extproc('STRING_removeQuotes');
  string like(String_t) options(*varsize) const;
end-pr;

///
// Generates a string of repeated characters
//
// Creates a string containing the specified number of repeated characters.
// By default, generates spaces, but can generate any single character when
// the optional character parameter is provided. Useful for formatting and
// alignment operations.
//
// @param length - Number of characters to generate in the result string
//                 Must be >= 0; negative values return empty string
//                 Zero length returns empty string
// @param char   - Character to repeat in the generated string (optional parameter)
//                 Defaults to space character if not specified
//                 Can be any single character including special characters
//
// @return String containing the specified number of repeated characters
//         Empty string if length is 0 or negative
//         String of spaces if char parameter not provided
///
dcl-pr spaces like(String_t) extproc('STRING_spaces');
  length int(10) const;
  char   char(1) options(*nopass) const;
end-pr;

///
// Parses a string representation of a number into numeric value
//
// Converts a string containing numeric data into a numeric value, handling
// various formatting options including decimal points, thousands separators,
// and currency symbols. Provides flexible parsing for different numeric
// formats commonly found in business applications.
//
// @param i_string   - String containing numeric data to parse
//                     Can include digits, signs, decimal points, and separators
//                     Leading and trailing spaces are automatically trimmed
// @param i_decPoint - Decimal point character (optional parameter)
//                     Defaults to period (.) if not specified
//                     Can be any single character (e.g., comma for European format)
// @param i_comma    - Thousands separator character (optional parameter)
//                     Defaults to comma (,) if not specified
//                     Can be any single character (e.g., space or period)
// @param i_curSym   - Currency symbol character (optional parameter)
//                     Currency symbol to ignore during parsing
//                     Can be any single character (e.g., $, €, £)
//
// @return Parsed numeric value with up to 20 decimal places precision
//         Zero if string cannot be parsed or contains no numeric data
//         Supports very large numbers (up to 63 total digits)
///
dcl-pr parseNum zoned(63:20) extproc('STRING_parseNum');
  i_string   varchar(96) options(*trim) const;
  i_decPoint char(1) options(*nopass) const;
  i_comma    char(1) options(*nopass) const;
  i_curSym   char(1) options(*nopass) const;
end-pr;

///
// Formats a numeric value as a readable string
//
// Converts a numeric value into a formatted string representation suitable
// for display or output. Handles various numeric data types and provides
// consistent formatting for test assertions and reporting purposes.
//
// @param numericValue - Numeric value to format as a string
//                       Can be any numeric type supported by assertNumeric_t
//                       Includes integers, decimals, packed, and zoned numbers
//
// @return Formatted numeric string with appropriate precision
//         Uses standard formatting rules for the numeric type
//         Includes decimal places only when necessary
///
dcl-pr formatNumeric varchar(128) extproc('formatNumeric');
  numericValue like(assertNumeric_t) const;
end-pr;

/endif

