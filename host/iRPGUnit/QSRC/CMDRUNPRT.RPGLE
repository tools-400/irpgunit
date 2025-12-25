**FREE

// ==========================================================================
//  iRPGUnit - Printing Facilities for CMDRUN.
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
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt nomain;
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//---------------------------------------------------------------------
//   Prototypes
//---------------------------------------------------------------------

/include qinclude,CMDRUNPRT
/include qinclude,ERRORCODE
/include qinclude,SYSTEMAPI
/include qinclude,TESTUTILS


dcl-pr Ropen pointer extproc('_Ropen');                        // _RFILE
  i_filename      pointer value  options(*string);
  i_mode          pointer value  options(*string);
end-pr;

dcl-pr Rwrite pointer extproc('_Rwrite');                       // _RIOFB_T
  i_fp            pointer value;
  i_pbuffer       pointer value;
  i_size          uns(10) value;
end-pr;

dcl-pr Rclose int(10) extproc('_Rclose');
  i_fp            pointer value;
end-pr;


//----------------------------------------------------------------------
//   Templates
//----------------------------------------------------------------------

/include qinclude,TEMPLATES


// Program Information Data Structure.
/include qinclude,SDS

// Line for printing in log.
dcl-c splf_name 'RPGUNIT';
dcl-s logLine char(80);

// Current log spooled file.
dcl-ds curr_splf likeds(sprl0100_t) inz;

dcl-ds handle_t qualified template;
  hfile           pointer inz(*null);
end-ds;

dcl-ds handle likeds(handle_t) inz(*likeds);

//QSYSPRT   e            ExcpLine    1
//                       logLine             80

//---------------------------------------------------------------------
//   Procedures
//---------------------------------------------------------------------

//---------------------------------------------------------------------
// Close the printer file. See prototype.
//---------------------------------------------------------------------
dcl-proc clsPrt export;
  dcl-pi *N;
  end-pi;

  //close QSYSPRT;
  Rclose(handle.hfile);
  runCmd( 'DLTOVR FILE(QSYSPRT)' );

end-proc;


dcl-proc getSplF export;
  dcl-pi *N likeds(splf_t);
  end-pi;

  dcl-ds splf likeds(splf_t);

  clear splf;

  //if (not %open(QSYSPRT));
  //   return splF;
  //endif;
  handle.hfile = Ropen('*LIBL/QSYSPRT': 'wr');
  if (handle.hfile = *null);
    return splf;
  endif;

  splf.system = curr_splf.system;
  splf.nm = curr_splf.name;
  splf.nbr = curr_splf.splfNbr;
  splf.job.name = curr_splf.job;
  splf.job.user = curr_splf.user;
  splf.job.nbr = curr_splf.jobNbr;

  return splf;

end-proc;


dcl-proc getPrtWidth export;
  dcl-pi *N              int(10);
  end-pi;

  return %len( logLine );

end-proc;


dcl-proc opnPrt export;
  dcl-pi *N;
    testPgmNm       const like(object_t.nm);
  end-pi;

  dcl-ds percolateErrors
         likeds(percolateErrors_t)
  inz(*likeds);

  runCmd( 'OVRPRTF FILE(QSYSPRT) '
       + 'USRDTA(' + testPgmNm + ') '
       + 'SPLFNAME(' + splf_name + ')' );
  // open qsysprt;
  handle.hfile = Ropen('*LIBL/QSYSPRT': 'wr');

  qsprilsp(curr_splf: %size(curr_splf): 'SPRL0100': percolateErrors);

end-proc;


//----------------------------------------------------------------------
// Print a line. See prototype.
//----------------------------------------------------------------------
dcl-proc prtLine export;
  dcl-pi *N;
    line            char(80) const;
  end-pi;

  dcl-s pRioFB pointer;

  logLine = line;
  // except ExcpLine;
  pRioFB = Rwrite(handle.hfile: %addr(logLine): %len(line));

end-proc;


