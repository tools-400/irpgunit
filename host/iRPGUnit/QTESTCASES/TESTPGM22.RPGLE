**free
// ==========================================================================
//  iRPGUnit Fixture - Test Message Sender/Receiver.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
//    >>PRE-COMPILER<<
//      >>CRTCMD<<  RUCRTRPG    TSTPGM(&LI/&OB) +
//                              SRCFILE(&SL/&SF) SRCMBR(&SM);
//      >>IMPORTANT<<
//        >>PARM<< COPTION(*SRCSTMT *EVENTF);
//        >>PARM<< DBGVIEW(*LIST);
//      >>END-IMPORTANT<<
//      >>EXECUTE<<
//    >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt nomain option(*srcstmt: *nodebugio);

/include qinclude,TESTCASE
/include qinclude,CMDRUNSRV

dcl-ds qObj_t qualified template;
  name char(10);
  lib  char(10);
end-ds;

dcl-ds errCode_t qualified template;
  bytPrv          int(10);
  bytAvl          int(10);
  excID           char(7);
  reserved_1      char(1);
  excDta          char(240);
end-ds;

//  Retrieve Object Description (QUSROBJD) API
dcl-pr qusrobjd extpgm('QUSROBJD');
  o_rcvVar        char(65535) options(*varsize);
  i_lenRcvVar     int(10) const;
  i_format        char(8) const;
  i_qobj          char(20) const;
  i_type          char(10) const;
  io_errCode      char(65535) options(*nopass: *varsize);
  i_auxStgCtrl    char(65535) options(*nopass: *varsize) const;
end-pr;

dcl-ds objd0100_t qualified template;
  bytRet          int(10);
  bytAvl          int(10);
  name            char(10);
  lib             char(10);
  type            char(10);
  rtnLib          char(10);
  auxStgP         int(10);
  owner           char(10);
  domain          char(2);
  crtDatTim       char(13);
  chgDatTim       char(13);
end-ds;

///
// Produces a runtime error because of an incorrect object type.
// Validates the content of the message receiver.
///
dcl-proc testRuntimeError export;
  dcl-pi *n extproc(*dclcase);
  end-pi;

  dcl-c INVALID_OBJECT_TYPE '*FOO';
  dcl-ds objd0100 likeds(objd0100_t) inz;

  objd0100 = getObjectDescription('TESTPGM22': '*LIBL': INVALID_OBJECT_TYPE);
  fail('getObjectDescription() should have thrown an *ESCAPE message.');

end-proc;

///
// Returns the object description of a given object name and type.
///
dcl-proc getObjectDescription;
  dcl-pi *n likeds(objd0100_t) extproc(*dclcase);
    name    char(10) const;
    lib     char(10) const;
    objType char(10) const;
  end-pi;

  dcl-ds qObj likeds(qObj_t) inz;
  dcl-ds objd0100 likeds(objd0100_t) inz;
  dcl-ds errCode likeds(errCode_t) inz;

  qObj.name = name;
  qObj.lib = lib;

  clear objd0100;
  clear errCode;

  qusrobjd(objd0100: %size(objd0100): qObj: objType: errCode);

  return objd0100;

end-proc;
