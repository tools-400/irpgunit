**free
// ==========================================================================
//  iRPGUnit - Assertion Facility V2 Disabled.
//  Dummy member for 7.3 and 7.4 without PTFs.
//  Will be copied to ASSERTV2 before installation on systems with 7.3 and 7.4.
// ==========================================================================
//  Copyright (c) 2013-2024 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  OPTION(*EVENTF);
//     >>PARM<<  DBGVIEW(*LIST);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain;
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   IMPORTS
//----------------------------------------------------------------------

/include qinclude,TESTCASE
/include qinclude,PGMMSG
/include qinclude,TEMPLATES

//----------------------------------------------------------------------
//   PRIVATE PROTOTYPES
//----------------------------------------------------------------------

//----------------------------------------------------------------------
//   GLOBAL CONSTANTS
//----------------------------------------------------------------------

//----------------------------------------------------------------------
//   TYPE TEMPLATE
//----------------------------------------------------------------------

//----------------------------------------------------------------------
//   GLOBAL VARIABLES
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// Assert equality between two alphanumeric variables - V2.
//----------------------------------------------------------------------
dcl-proc assertEqual_string export;
  dcl-pi *n opdesc;
    expected   like(assertString_t) options(*varsize) const;
    actual     like(assertString_t) options(*varsize) const;
    message    like(msgText_t) options(*nopass: *omit) const;
  end-pi;

  notImplemented();

end-proc;

//----------------------------------------------------------------------
// Assert equality between two numeric variables - V2.
//----------------------------------------------------------------------
dcl-proc assertEqual_numeric export;
  dcl-pi *n opdesc;
    expected   zoned(63: 20) options(*exact) const;
    actual     zoned(63: 20) options(*exact) const;
    message    like(msgText_t) options(*nopass: *omit) const;
  end-pi;

  notImplemented();

end-proc;

//----------------------------------------------------------------------
// Assert equality between two float variables - V2.
//----------------------------------------------------------------------
dcl-proc assertEqual_float export;
  dcl-pi *n opdesc;
    expected   float(8) options(*exact) const;
    actual     float(8) options(*exact) const;
    message    like(msgText_t) options(*nopass: *omit) const;
  end-pi;

  notImplemented();

end-proc;

//----------------------------------------------------------------------
// Assert equality between two date variables - V2.
//----------------------------------------------------------------------
dcl-proc assertEqual_date export;
  dcl-pi *n opdesc;
    expected   date const;
    actual     date const;
    message    like(msgText_t) options(*nopass: *omit) const;
  end-pi;

  notImplemented();

end-proc;

//----------------------------------------------------------------------
// Assert equality between two time variables - V2.
//----------------------------------------------------------------------
dcl-proc assertEqual_time export;
  dcl-pi *n opdesc;
    expected   time const;
    actual     time const;
    message    like(msgText_t) options(*nopass: *omit) const;
  end-pi;

  notImplemented();

end-proc;

//----------------------------------------------------------------------
// Assert equality between two timestamp variables - V2.
//----------------------------------------------------------------------
dcl-proc assertEqual_timestamp export;
  dcl-pi *n opdesc;
    expected   timestamp(12) const;
    actual     timestamp(12) const;
    message    like(msgText_t) options(*nopass: *omit) const;
  end-pi;

  notImplemented();

end-proc;

//----------------------------------------------------------------------
// Assert equality using a matcher callback procedure - V2.
//----------------------------------------------------------------------
dcl-proc assertThat export;
  dcl-pi *n opdesc;
    expected   pointer const;
    actual     pointer const;
    matcher    pointer(*proc) const;
    message    like(msgText_t) options(*nopass: *omit) const;
  end-pi;

  notImplemented();

end-proc;

//----------------------------------------------------------------------
// Kills the program with a "not implemented" message.
//----------------------------------------------------------------------
dcl-proc notImplemented;
  dcl-pi *n opdesc extproc(*dclcase);
  end-pi;

  sndEscapeMsgAboveCtlBdy(
    'Procedure ' + %proc() + ' has not been implemented for this OS400 release.');

end-proc;

