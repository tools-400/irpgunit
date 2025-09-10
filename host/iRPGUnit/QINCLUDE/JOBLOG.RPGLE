**FREE
// ==========================================================================
//  iRPGUnit - Job Log Reader.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

dCl-S hJobLogReader_t varchar(1024) template;

dcl-ds jl_rd_msgInfo_t qualified template;
  severity   int(10);
  id         char(7);
  type       char(10);
  key        char(4);
  file       char(10);
  lib        char(10);
  sndTime    timestamp;
  threadId   char(8);
  timeZone   char(10);
end-ds;

dcl-pr jl_rd_callback ind;
  i_hMsgInfo    pointer      const;
  i_pUserData   pointer      const;
  i_msgId       char(7)      const;
  i_msgText     varchar(132) const;
  i_msgSentTime timestamp    const;
end-pr;

dcl-c JL_RD_NEXT     '*NEXT';
dcl-c JL_RD_PREVIOUS '*PRV';
dcl-c JL_RD_MSG_EXT  '*EXT';
dcl-c JL_RD_MSG_ALL  '*';

///
// Initialize Job Log Reader Instance
//
// Creates and initializes a new job log reader instance for processing job log
// entries. Configures the reader to scan messages in the specified direction
// and optionally from a specific message queue.
//
// @param i_direction - Message reading direction (*NEXT or *PRV)
// @param i_msgQ      - Optional message queue name (defaults to current job log)
//
// @return Handle to the initialized job log reader instance
///
dcl-pr JobLogReader_init like(hJobLogReader_t) extproc('JOBLOG_JobLogReader_init');
  i_direction varchar(10) const;
  i_msgQ      varchar(10) options(*nopass) const;
end-pr;

///
// Add Field to Reader Configuration
//
// Registers a specific message field to be retrieved when reading job log entries.
// Multiple fields can be added to customize which message attributes are extracted
// during the reading process.
//
// @param io_hReader - Job log reader handle to configure (modified)
// @param i_fieldId  - Field identifier constant specifying which data to retrieve
//
// @return Status indicator (0=success, non-zero=error)
///
dcl-pr JobLogReader_addField int(10) extproc('JOBLOG_JobLogReader_addField');
  io_hReader like(hJobLogReader_t);
  i_fieldId  int(10) const;
end-pr;

///
// Read Job Log Messages with Callback
//
// Processes job log messages using the configured reader settings and calls
// a user-provided callback function for each message found. Supports optional
// user data parameter for maintaining state during callback processing.
//
// @param io_hReader  - Job log reader handle (updated with position info)
// @param i_callback  - Pointer to callback function for message processing
// @param i_pUserData - Optional pointer to user data passed to callback
//
// @return Success indicator (*ON=messages processed, *OFF=no more messages)
///
dcl-pr JobLogReader_read ind extproc('JOBLOG_JobLogReader_read');
  io_hReader  like(hJobLogReader_t);
  i_callback  pointer(*proc) const;
  i_pUserData pointer options(*nopass) const;
end-pr;

///
// Retrieve Specific Message by Key
//
// Fetches a specific job log message using its unique message key and processes
// it through a callback function. Allows selective retrieval of individual messages
// with configurable field extraction.
//
// @param i_msgKey - 4-byte message key identifying the specific message
// @param i_callback - Pointer to callback function for message processing
// @param i_pUserData - Optional pointer to user data passed to callback
// @param i_fieldId01 - Optional field ID for first additional field to retrieve
// @param i_fieldId02 - Optional field ID for second additional field to retrieve
// @param i_fieldId03 - Optional field ID for third additional field to retrieve
// @param i_fieldId04 - Optional field ID for fourth additional field to retrieve
// @param i_fieldId05 - Optional field ID for fifth additional field to retrieve
// @param i_fieldId06 - Optional field ID for sixth additional field to retrieve
// @param i_fieldId07 - Optional field ID for seventh additional field to retrieve
// @param i_fieldId08 - Optional field ID for eighth additional field to retrieve
// @param i_fieldId09 - Optional field ID for ninth additional field to retrieve
// @param i_fieldId10 - Optional field ID for tenth additional field to retrieve
// @param i_fieldId11 - Optional field ID for eleventh additional field to retrieve
// @param i_fieldId12 - Optional field ID for twelfth additional field to retrieve
// @param i_fieldId13 - Optional field ID for thirteenth additional field to retrieve
// @param i_fieldId14 - Optional field ID for fourteenth additional field to retrieve
// @param i_fieldId15 - Optional field ID for fifteenth additional field to retrieve
// @param i_fieldId16 - Optional field ID for sixteenth additional field to retrieve
//
// @return Success indicator (*ON=message found and processed, *OFF=message not found)
///
dcl-pr JobLogReader_getMsg ind extproc('JOBLOG_JobLogReader_getMsg');
  i_msgKey     char(4) const;
  i_callback   pointer(*proc) const;
  i_pUserData  pointer options(*nopass) const;
  i_fieldId01  int(10) options(*nopass) const;
  i_fieldId02  int(10) options(*nopass) const;
  i_fieldId03  int(10) options(*nopass) const;
  i_fieldId04  int(10) options(*nopass) const;
  i_fieldId05  int(10) options(*nopass) const;
  i_fieldId06  int(10) options(*nopass) const;
  i_fieldId07  int(10) options(*nopass) const;
  i_fieldId08  int(10) options(*nopass) const;
  i_fieldId09  int(10) options(*nopass) const;
  i_fieldId10  int(10) options(*nopass) const;
  i_fieldId11  int(10) options(*nopass) const;
  i_fieldId12  int(10) options(*nopass) const;
  i_fieldId13  int(10) options(*nopass) const;
  i_fieldId14  int(10) options(*nopass) const;
  i_fieldId15  int(10) options(*nopass) const;
  i_fieldId16  int(10) options(*nopass) const;
end-pr;

///
// Extract Message Information Structure
//
// Converts a message information handle into a structured format containing
// common message attributes like severity, ID, type, and timing information.
// Provides standardized access to message metadata.
//
// @param i_hMsgInfo - Handle to message information from callback processing
//
// @return Structured message information with standardized field layout
///
dcl-pr JobLogReader_getMsgInfo likeds(jl_rd_msgInfo_t) extproc('JobLogReader_getMsgInfo');
  i_hMsgInfo pointer const;
end-pr;

///
// Extract Character Field Value
//
// Retrieves the character value of a specific field from message information.
// Supports extraction of variable-length text fields with optional default
// value handling for missing or empty fields.
//
// @param i_hMsgInfo - Handle to message information containing the field data
// @param i_fieldId  - Field identifier specifying which character field to extract
// @param i_dftValue - Optional default value returned if field is empty or missing
//
// @return Character value of the specified field or default value if not found
///
dcl-pr JobLogReader_getCharValue varchar(3000) extproc('JOBLOG_JobLogReader_getCharValue');
  i_hMsgInfo  pointer const;
  i_fieldId   int(10) const;
  i_dftValue  varchar(256) options(*nopass) const;
end-pr;
