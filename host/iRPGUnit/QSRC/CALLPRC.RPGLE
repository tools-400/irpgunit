**FREE
// ==========================================================================
//  iRPGUnit - Dynamically Call a Procedure in a SRVPGM.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
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
//   >>CMD<<     STRREXPRC SRCMBR(A_INSTALL) SRCFILE(&LI/QBUILD) +
//               PARM('CMPMOD &LI LIST');
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt nomain;
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   Exported Procedures
//----------------------------------------------------------------------

/include qinclude,CALLPRC

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,CMDRUNSRV
/include qinclude,ERRORCODE
/include qinclude,MILIB
/include qinclude,SYSTEMAPI
/include qinclude,TEMPLATES

//----------------------------------------------------------------------
//   Private Procedures
//----------------------------------------------------------------------

// Abstract procedure to dynamically call a procedure.
dcl-pr calldynproc extproc(callDynProc_p);
end-pr;


//----------------------------------------------------------------------
//   Global Variables
//----------------------------------------------------------------------

// Current procedure pointer.
dcl-s callDynProc_p   pointer(*proc);


//----------------------------------------------------------------------
//   Procedure Definitions
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// Get activation mark. See prototype.
//----------------------------------------------------------------------
dcl-proc activateSrvPgm export;
  dcl-pi *N int(10);
    srvPgm          value likeds(object_t);
  end-pi;

  // Activation mark.
  dcl-s actMark int(10) inz(0);
  // Authority mask.
  dcl-s auth char(2) inz(*loval);
  // Objet type as hexadecimal value.
  dcl-s hexType char(2) inz(*loval);
  // System pointer to a service program.
  dcl-s srvPgmSp pointer(*proc);

  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  if (srvPgm.lib = '');
    srvPgm.lib = '*LIBL';
  endif;

  // Get object type as hex value.
  qlicvttp( '*SYMTOHEX' : '*SRVPGM' : hexType : percolateErrors );

  // Retrieve system pointer.
  monitor;
    srvPgmSp = rslvsp( hexType:
                       srvPgm.nm:
                       srvPgm.lib:
                       auth );
  on-error;
    raiseRUError( 'Failed to retrieve system pointer for '
                      + %trimr(srvPgm.nm)
                      + '.' );
  endmon;

  // Activate service program.
  actMark = qleactbndpgm( srvPgmSp : *omit : *omit : *omit : *omit );

  return actMark;

end-proc;


dcl-proc callProcByPtr export;
  dcl-pi *N;
    procPtr         pointer(*proc) const;
  end-pi;

  if (procPtr <> *null);
    callDynProc_p = procPtr;
    calldynproc();
  endif;

end-proc;


dcl-proc rslvProc export;
  dcl-pi *N;
    proc            likeds(proc_t);
    actMark         const like(actMark_t);
  end-pi;

  // Type of export in a service program.
  dcl-s exportType      int(10) inz(0);
  // One export type is PROCEDURE.
  dcl-c procedure const(1);

  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  // Get export.
  qlegetexp( actMark :
             0 :
             %len(proc.procNm) :
             proc.procNm :
             proc.procPtr :
             exportType :
             percolateErrors );

  if (exportType <> procedure);
    proc.procPtr = *null;
  endif;

end-proc;

