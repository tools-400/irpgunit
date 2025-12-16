**FREE
// ==========================================================================
//  iRPGUnit - Plug-in Test Runner.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  CRTBNDRPG PGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  OPTION(*EVENTF);
//     >>PARM<<  DBGVIEW(*LIST);
//     >>PARM<<  TGTRLS(V7R3M0);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt main(tstwrtstmf) dftactgrp(*no) actgrp(*new);

dcl-pr tstwrtstmf extpgm('tstwrtstmf');
end-pr;

/include qinclude,ifsio_h
/include qinclude,LIBC_H

dcl-c CRLF x'0d25';

dcl-s GERMAN_UMLAUTE varchar(30) ccsid(1208);
dcl-s CDATA_START varchar(30) ccsid(1208);
dcl-s CDATA_END varchar(30) ccsid(1208);
dcl-s LEFT_CURLY_BRACKET varchar(30) ccsid(1208);
dcl-s RIGHT_CURLY_BRACKET varchar(30) ccsid(1208);

dcl-s DATA_JOB_CCSID varchar(30);

dcl-proc tstwrtstmf;
  dcl-pi *n;
  end-pi;

  dcl-s fileHandle int(10);
  dcl-s flags int(10);
  dcl-s mode int(10);
  dcl-s errorNumber int(10) based(errorPtr);
  dcl-s text_dft varchar(1000);
  dcl-s text_1208 varchar(1000) ccsid(1208);
  dcl-s rc int(10);

  // Use hex constants to define variant character in UTF-8.
  // This way RPG correctly translates the strings to the current job CCSID.
  GERMAN_UMLAUTE = u'00C400D600DC';
  CDATA_START = u'003C0021005B00430044004100540041005B';
  CDATA_END = u'005D005D003E';
  LEFT_CURLY_BRACKET = u'007B';
  RIGHT_CURLY_BRACKET = u'007D';

  DATA_JOB_CCSID = 'Hello Wordl!' + ' (' + GERMAN_UMLAUTE + ')';

  // create file 1, pure EBCDIC characters
  flags = O_WRONLY + O_CREAT + O_TRUNC + O_CCSID +
          O_TEXTDATA + O_TEXT_CREAT;
  mode =  S_IRUSR + S_IWUSR + S_IRGRP;
  fileHandle = open(%trimr('tstwrtstmf_1_ebcdic.xml') : flags : mode : 1208 : 0);
  if (fileHandle < 0);
    errorPtr = errno();
    snd-msg *escape  'Open file error: ' + %str(strError(errorNumber));
  endif;

  text_dft = '<?xml version="1.0" encoding="UTF-8" ?>' + CRLF;
  text_dft += '<failure>'
           + '<![CDATA['
           + '{'
           + ' "message": "' + DATA_JOB_CCSID + '" '
           + '}'
           + ']]>'
           + '</failure>';

  rc = write(fileHandle : %addr(text_dft : *data) : %len(text_dft));

  rc = close(fileHandle);

  // -----------------------------------------------
  // create file 2, critical characters as UTF-8
  // this approach produces the correct result
  flags = O_WRONLY + O_CREAT + O_TRUNC + O_CCSID +
          O_TEXTDATA + O_TEXT_CREAT;
  mode =  S_IRUSR + S_IWUSR + S_IRGRP;
  fileHandle = open(%trimr('tstwrtstmf_2_mixed.xml') : flags : mode : 1208 : 0);
  if (fileHandle < 0);
    errorPtr = errno();
    snd-msg *escape  'Open file error: ' + %str(strError(errorNumber));
  endif;

  text_dft = '<?xml version="1.0" encoding="UTF-8" ?>' + CRLF;
  text_dft += '<failure>'
           + CDATA_START
           + LEFT_CURLY_BRACKET
           + ' "message": "' + DATA_JOB_CCSID + '" '
           + RIGHT_CURLY_BRACKET
           + CDATA_END
           + '</failure>';

  rc = write(fileHandle : %addr(text_dft : *data) : %len(text_dft));

  rc = close(fileHandle);
  // -----------------------------------------------

  // -----------------------------------------------
  // create file 3, all characters as UTF-8
  // this approach produces the correct result as well
  flags = O_WRONLY + O_CREAT + O_TRUNC + O_CCSID;
  mode =  S_IRUSR + S_IWUSR + S_IRGRP;
  fileHandle = open(%trimr('tstwrtstmf_3_utf-8.xml') : flags : mode : 1208);
  if (fileHandle < 0);
    errorPtr = errno();
    snd-msg *escape  'Open file error: ' + %str(strError(errorNumber));
  endif;

  text_1208 = '<?xml version="1.0" encoding="UTF-8" ?>' + CRLF;
  text_1208 += '<failure>'
           + CDATA_START
           + LEFT_CURLY_BRACKET
           + ' "message": "' + DATA_JOB_CCSID + '" '
           + RIGHT_CURLY_BRACKET
           + CDATA_END
           + '</failure>';

  rc = write(fileHandle : %addr(text_1208 : *data) : %len(text_1208));

  rc = close(fileHandle);
  // -----------------------------------------------

  // create file 4, original code with ccsid 819
  flags = O_WRONLY + O_CREAT + O_TRUNC + O_CCSID +
          O_TEXTDATA + O_TEXT_CREAT;
  mode =  S_IRUSR + S_IWUSR + S_IRGRP;
  fileHandle = open(%trimr('tstwrtstmf_4_original-819.xml') : flags : mode : 819 : 0);
  if (fileHandle < 0);
    errorPtr = errno();
    snd-msg *escape  'Open file error: ' + %str(strError(errorNumber));
  endif;

  text_dft = '<?xml version="1.0" encoding="UTF-8" ?>' + CRLF;
  text_dft += '<failure>'
           + '<![CDATA['
           + '{ "message": "' + DATA_JOB_CCSID + '" }'
           + ']]>'
           + '</failure>';

  rc = write(fileHandle : %addr(text_dft : *data) : %len(text_dft));

  rc = close(fileHandle);

end-proc;

