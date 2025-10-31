**FREE
/if defined(IRPGUNIT_STMF_INCLUDE)
/eof
/endif
/define IRPGUNIT_STMF_INCLUDE
// ==========================================================================
//  iRPGunit - Stream File Utilities.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Retrieves the current working directory path
//
// Returns the current working directory of the job in the Integrated File System.
// This is useful for resolving relative paths and establishing a base directory
// for file operations during test execution. The path is always returned in
// Unix-style format with forward slashes.
//
// @return Current working directory path as an IFS path string
//         Returns fully qualified IFS path (e.g., '/home/user', '/tmp', '/QSYS.LIB')
//         Always uses forward slashes as path separators
///
dcl-pr Stmf_getCurrentDirectory like(ifsStmf_t) extproc('STMF_Stmf_getCurrentDirectory');
end-pr;

///
// Resolves and normalizes a stream file path to its absolute form
//
// Converts relative paths to absolute paths by combining them with the current
// working directory. Handles path normalization including forward/backward slash
// conversion, current directory notation (./) and parent directory notation (../).
// Essential for consistent file path handling across different environments.
//
// @param stmf - Stream file path to resolve (relative or absolute)
//               Can include relative notation like './' or '../'
//               Backslashes are automatically converted to forward slashes
//               Can be up to 5000 characters in length
//
// @return Fully qualified IFS path string
//         Always returns absolute path starting with '/'
//         Path separators normalized to forward slashes
//         Redundant path components removed (e.g., '/./dir' becomes '/dir')
///
dcl-pr Stmf_resolvePath like(ifsStmf_t) extproc('STMF_Stmf_resolvePath');
  stmf like(ifsStmf_t) const;
end-pr;

///
// Checks if a stream file or directory exists in the IFS
//
// Verifies the existence of a stream file or directory in the Integrated File System.
// This procedure resolves the path before checking existence, so both relative
// and absolute paths are supported. Works for all IFS file system types including
// root, QOpenSys, QSYS.LIB, and QDLS.
//
// @param stmf - Stream file or directory path to check for existence
//               Can be relative or absolute path
//               Path is automatically resolved before existence check
//               Supports all IFS file system types
//
// @return *ON if the stream file or directory exists and is accessible
//         *OFF if the stream file or directory does not exist or is not accessible
///
dcl-pr Stmf_exists ind extproc('STMF_Stmf_exists');
  stmf like(ifsStmf_t) const;
end-pr;

///
// Returns the last modification timestamp of a stream file
//
// @param stmf - Stream file path to get modification timestamp for
//               Can be relative or absolute path
//               Path is automatically resolved before timestamp retrieval
//               Must be a file, not a directory
//
// @return Timestamp of when the stream file data was last modified
//         Returns precise timestamp with microsecond accuracy
//         Reflects actual data modification time, not access time
///
dcl-pr Stmf_getLastChgDate timestamp extproc('STMF_Stmf_getLastChgDate');
  stmf like(ifsStmf_t) const;
end-pr;

///
// Returns the ccsid of a given stream file
//
// @param stmf - Stream file path to get the ccsid for
//               Can be relative or absolute path
//
// @return ccsid of the stream file
///
dcl-pr Stmf_getCcsid like(ccsid_t) extproc('STMF_Stmf_getCcsid');
  stmf like(ifsStmf_t) const;
end-pr;

///
// Extracts the file type (extension) from a stream file path
//
// Extracts the file extension from a stream file path, which is useful for
// determining file type and appropriate processing methods. The extension
// is determined by the text following the last dot (.) in the filename portion
// of the path. Does not validate file existence or actual content type.
//
// @param stmf - Stream file path to extract extension from
//               Can be relative or absolute path
//               Path is automatically resolved before extension extraction
//               Can include directory components
//
// @return File extension without the leading dot (e.g., 'txt', 'xml', 'csv', 'rpg')
//         Returns empty string if no extension is found
//         Returns empty string if path ends with a dot
//         Case is preserved as found in the path
///
dcl-pr Stmf_getType varchar(10) extproc('STMF_Stmf_getType');
  stmf like(ifsStmf_t) const;
end-pr;

/include qinclude,TEMPLATES

