**FREE
// ==========================================================================
//  File information data structures.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
/if defined(fileInfDS_DB)
/if defined(infDS_DB_t)
/eof
/endif
/define infDS_DB_t
/endif

/if defined(fileInfDS_prtF)
/if defined(infDS_prtF_t)
/eof
/endif
/define infDS_prtF_t
/endif

/if defined(fileInfDS_dspF)
/if defined(infDS_dspF_t)
/eof
/endif
/define infDS_dspF_t
/endif

//===============================================================*
//  File information data structure                              *
//===============================================================*
/if defined(fileInfDS_DB)
dcl-ds infDS_DB_t qualified template;
/ELSEIF DEFINED(fileInfDS_PRTF)
dcl-ds  infDS_prtF_t qualified template;
/ELSEIF DEFINED(fileInfDS_DSPF)
dcl-ds  infDS_dspF_t qualified template;
/endif
  // Reserved 01
  reserved_01     char(8)  pos(1);
  // Open indication 1=open
  isOpen          char(1)  pos(9);
  // End of file 1=EOF
  isEOF           char(1)  pos(10);
  // Status
  status          zoned(5) pos(11);
  // Operation code, first 5 pos.
  opCode          char(5)  pos(16);
  // IO-Type:
  //   F=The last operation was specified for a file name
  //   R=The last operation was specified for a record
  //   I=The last operation was an implicit file operation.
  IO_type         char(1)  pos(21);
  // Routine of operation code
  routine         char(8)  pos(22);
  // RPG source listing line nbr
  srcSeq          char(8)  pos(30);
  // Record format
  rcdFormat       char(8)  pos(38);
  // System message number
  sysMsgNbr       char(7)  pos(46);
  // Reserved 02
  reserved_02     char(14) pos(53);
  //
  // Valid after post:
  //    Screen size (product of the number of rows
  //    and the number of columns on the device screen).
  screenSize      zoned(4) pos(67);
  //    The display's keyboard type.
  //       00 = alphanumeric or katakana
  //       10 = ideographic
  kbdType         zoned(2) pos(71);
  //    The display type.
  //       00 = alphanumeric or katakana
  //       10 = ideographic
  //       20 = DBCS
  displayType     zoned(2) pos(73);
  //    Always set to 00.
  mode            zoned(2) pos(75);
  // Reserved_03
  reserved_03     char(4)  pos(77);

  //  -----------------------------------------
  //    Open Feedback            81 - 240
  //  -----------------------------------------
  openFB          likeds(openFeedback_t);

  //  -----------------------------------------
  //    Input/Output Feedback      241 - 366
  //  -----------------------------------------
  IO_FB           likeds(IO_feedback_t );

  //  -----------------------------------------
  //    Device Specific Feedback   367 -
  //  -----------------------------------------
/if defined(fileInfDS_DB)
  deviceFB_DB likeds(deviceFeedback_DB_t);
/ELSEIF DEFINED(fileInfDS_PRTF)
  deviceFB_PrtF likeds(deviceFeedback_PrtF_t);
/ELSEIF DEFINED(fileInfDS_DSPF)
  deviceFB_DspF likeds(deviceFeedback_DspF_t);
/endif
end-ds;

///IF NOT DEFINED(openFeedback_t)
///define openFeedback_t
//  -----------------------------------------
//    Open Feedback
//  -----------------------------------------
dcl-ds openFeedback_t len(160) qualified template;
  // DS=Display DB=File SP=Spooled File
  ODP_type        char(2)  pos(1);
  // Qualified file name
  qFile           likeds(infds_qFile_t);
  // File name
  file            char(10) pos(3);
  // Library
  lib             char(10) pos(13);
  // Spool file name
  spooledFile     char(10) pos(23);
  // Spool file library
  spooledFileLib  char(10) pos(33);
  // Spool file number
  spoolNbr        int(5)   pos(43);
  // Record length
  maxRcdLength    int(5)   pos(45);
  // Key length
  maxKeyLength    int(5)   pos(47);
  // Member
  mbr             char(10) pos(49);
  // Reserved
  reserved_01     int(10)  pos(59);
  // Reserved
  reserved_02     int(10)  pos(63);
  // File type
  //     1  =  Display
  //     2  =  Printer
  //     4  =  Diskette
  //     5  =  Tape
  //     9  =  Save
  //    10  =  DDM
  //    11  =  ICF
  //    20  =  Inline data
  //    21  =  Database
  fileType        int(5)   pos(67);
  // Reserved
  reserved_03     char(3)  pos(69);
  // Number of lines on a display screen or       (Display, printer)
  // number of lines on a printed page.
  rows            int(5)   pos(72);
  // Length of the null field byte map.           (Database)
  lenNullFldMap   int(5)   pos(72);
  // Number of positions on a display screen or   (Display, printer)
  // number of characters on a printed line.
  columns         int(5)   pos(74);
  // Length of the null key field byte map.       (Database)
  lenKeyFldMap    int(5)   pos(74);
  // Number of records in the member at open
  // at open time.
  numRcdsAtOpen   int(10)  pos(76);
  // Access type
  accessType      char(2)  pos(80);
  // Duplicate key?
  isDupKey        char(1)  pos(82);
  // Source file?
  isSrcFile       char(1)  pos(83);
  // Reserved
  reserved_04     char(10) pos(84);
  // Reserved
  reserved_05     char(10) pos(94);
  // Offset to volume label fields of open
  // feedback area.
  ofsVolLblFld    int(5)   pos(104);
  // Max rcds in blk
  maxBlkRcds      int(5)   pos(106);
  // Overflow line
  overflow        int(5)   pos(108);
  // Blk increment
  blkInc          int(5)   pos(110);
  // Reserved
  reserved_06     char(4)  pos(112);
  // Miscellaneous flags
  flags1          char(1)  pos(116);
  // Requester name
  requester       char(10) pos(117);
  // Open count
  openCount       int(5)   pos(127);
  // Reserved
  reserved_07     int(5)   pos(129);
  // Num based mbrs
  numBasedMbrs    int(5)   pos(131);
  // Miscellaneous flags
  flags2          char(1)  pos(133);
  // Open identifier
  openID          char(2)  pos(134);
  // Max rcd fmt length
  maxRcdFmtLen    int(5)   pos(136);
  // Database CCSID
  CCSID           int(5)   pos(138);
  // Miscellaneous flags
  flags3          char(1)  pos(140);
  // Reserved
  reserved_08     char(6)  pos(141);
  // Num devs defined
  numDevices      int(5)   pos(147);
  // Device name definition list
  devices         char(12) pos(149);
end-ds;

dcl-ds infds_qFile_t qualified template;
  name            char(10) pos(1);
  lib             char(10) pos(11);
end-ds;
/endif

/if not defined(IO_feedback_t)
/define IO_feedback_t
//  -----------------------------------------
//    Input/Output Feedback
//  -----------------------------------------
dcl-ds IO_feedback_t len(126) qualified template;
  // Offset to file dependant feedback
  ofsFileDepFB    int(5)   pos(1);
  // Write count
  writeCount      int(10)  pos(3);
  // Read count
  readCount       int(10)  pos(7);
  // Write/read count
  writeReadCount  int(10)  pos(11);
  // Other I/O count
  otherCount      int(10)  pos(15);
  // Reserved
  reserved_01     char(1)  pos(19);
  // Current operation
  //   hex 01 =  Read or read block or read from invited devices
  //   hex 02 =  Read direct
  //   hex 03 =  Read by key
  //   hex 05 =  Write or write block
  //   hex 06 =  Write-read
  //   hex 07 =  Update
  //   hex 08 =  Delete
  //   hex 09 =  Force-end-of-data
  //   hex 0A =  Force-end-of-volume
  //   hex 0D =  Release record lock
  //   hex 0E =  Change end-of-data
  //   hex 0F =  Put deleted record
  //   hex 11 =  Release device
  //   hex 12 =  Acquire device
  operation       char(1)  pos(20);
  // Rcd format name
  IO_rcdFmt       char(10) pos(21);
  // Device class
  deviceClass     char(2)  pos(31);
  // Pgm device name
  IO_pgmDevice    char(10) pos(33);
  // Rcd len of I/O
  IO_rcdLength    int(10)  pos(43);
  // Reserved
  reserved_02     char(80) pos(47);
end-ds;

/endif
/if not defined(deviceFeedback_DB_t)
/define deviceFeedback_DB_t
//  -----------------------------------------
//    Device Specific Feedback of
//    Database Files.
//  -----------------------------------------
dcl-ds deviceFeedback_DB_t qualified template;
  // Size of feedback information
  size               int(10)  pos(1);  // (Pos. 367)
  // Join logical file bits
  JFILE_bits         int(10)  pos(5);  // (Pos. 371)
  // Offset from the beginning of the I/O feedback area
  // for database files to the null key field byte map.
  ofsNullKeyFldMap   int(5)   pos(9);  // (Pos. 375)
  // Number of locked records
  numLckRcds         int(5)   pos(11); // (Pos. 377)
  // Maximum number of fields
  maxNumFlds         int(5)   pos(13); // (Pos. 379)
  // Offset to the field-mapping error-bit map.
  ofsFldMapErrBitMap int(10)  pos(15); // (Pos. 381)
  // Current file position indication.
  *N                 char(1)  pos(19); // (Pos. 385)
  // Current record deleted indication
  *N                 char(1)  pos(20); // (Pos. 386)
  // Number of key fields
  nbrOfKeyFlds       int(5)   pos(21); // (Pos. 387)
  // Reserved
  resreved_1         char(4)  pos(23); // (Pos. 389)
  // Key length
  keyLength          int(5)   pos(27); // (Pos. 393)
  // Data member number
  dtaMbrNum          int(5)   pos(29); // (Pos. 395)
  // Relative record number in data member
  rcdNbr             uns(10)  pos(31); // (Pos. 397)
  // Key value                char(*)
  // Null key field byte map  char(*)
end-ds;

/endif
/if not defined(deviceFeedback_PrtF_t)
/define deviceFeedback_PrtF_t
//  -----------------------------------------
//    Device Specific Feedback of
//    Printer Files.
//  -----------------------------------------
dcl-ds deviceFeedback_PrtF_t qualified template;
  // Current line number in a page
  curLine            int(5)   pos(1);  // (Pos. 367)
  // Current page count
  curPage            int(10)  pos(3);  // (Pos. 369)
  // Spooled file bits
  splF_bits          char(1)  pos(7);  // (Pos. 373)
  // Reserved
  reserved_1         char(27) pos(8);  // (Pos. 374)
  // Major return code
  majorRtnCode       char(2)  pos(35); // (Pos. 401)
  // Minor return code
  minorRtnCode       char(2)  pos(37); // (Pos. 403)
end-ds;

/endif
/if not defined(deviceFeedback_DspF_t)
/define deviceFeedback_DspF_t
//  -----------------------------------------
//    Device Specific Feedback of
//    Display Files.
//  -----------------------------------------
dcl-ds deviceFeedback_DspF_t qualified template;
  // Flag bits
  flag_bits          char(2)  pos(1);  // pos(367)
  // AID byte
  aid_byte           char(1)  pos(3);  // pos(369)
  // Cursor location (line and position)
  cursorPos          uns(5)   pos(4);  // pos(370)
  // Actual data length
  dataLength         int(10)  pos(6);  // pos(372)
  // Relative record number of a subfile record
  rrn                int(5)   pos(10); // pos(376)
  // Lowest subfile
  rrn_lowest         int(5)   pos(12); // pos(378)
  // Total number of records in a subfile
  numRcds            int(5)   pos(14); // pos(380)
  // Cursor location (line and position) within active window
  cursorPosWdw       uns(5)   pos(16); // pos(382)
  // Reserved
  reserved_1         char(17) pos(18); // pos(384)
  // Major return code
  majorRtnCode       char(2)  pos(35); // pos(401)
  // Minor return code
  minorRtnCode       char(2)  pos(37); // pos(403)
  // Systems Network Architecture (SNA) sense return code              (I only)
  snaCode            char(8)  pos(39); // pos(405)
  // Safe indicator                                                    (I only)
  saveInd            char(1)  pos(47); // pos(413)
  // Reserved
  reserved_2         char(1)  pos(48); // pos(414)
  // Request Write (RQSWRT) command from remote system/application     (I only)
  rqsWrt             char(1)  pos(49); // pos(415)
  // Record format name received from the remote system                (I only)
  rcdFormat          char(10) pos(50); // pos(416)
  // Reserved
  reserved_3         char(4)  pos(60); // pos(426)
  // Mode name                                                         (I only)
  mode               char(8)  pos(64); // pos(430)
  // Reserved
  reserved_4         char(9)  pos(72); // pos(458)
end-ds;

/endif
