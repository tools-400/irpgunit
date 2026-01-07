**FREE
// ==========================================================================
//  iRPGUnit - Extract Procedures From a SRVPGM.
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

//----------------------------------------------------------------------
//   Public Procedure Prototypes
//----------------------------------------------------------------------

/include qinclude,EXTPRC
/include qinclude,TEMPLATES
/include qinclude,ERRORCODE

//----------------------------------------------------------------------
//   Private Procedure Prototypes
//----------------------------------------------------------------------

// Retrieve Procedure Info.
// Stores procedure info in a user space.
dcl-pr rtvProcInfo;
  // Service program to analyze.
  srvPgm          value likeds(object_t);
  // Qualified user space name.
  usrSpc          const likeds(object_t);
end-pr;

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,SYSTEMAPI
/include qinclude,USRSPC

//----------------------------------------------------------------------
// Counts the number of procedure in the liste. See prototype.
//----------------------------------------------------------------------
dcl-proc cntProc export;
  dcl-pi *N              int(10);
    proclist        const likeds(procList_t);
  end-pi;

  // Procedure list header.
  dcl-ds proclisthdr likeds(listhdr_t)
  based(proclist.hdr);


  return proclisthdr.entcnt;

end-proc;


//----------------------------------------------------------------------
// Returns a list of the procedures. See prototype.
//----------------------------------------------------------------------
dcl-proc loadProcList export;
  dcl-pi *N likeds(procList_t);
    srvPgm          const likeds(object_t);
  end-pi;

  // List header structure.
  dcl-ds listhdr likeds(listhdr_t) based(procList.hdr);
  // Extracted procedure list.
  dcl-ds procList likeds(procList_t);
  // Qualified name of the user space that stores the proc info.
  dcl-ds usrSpc likeds(object_t);


  usrSpc.nm  = 'RUPROCLIST';
  usrSpc.lib = 'QTEMP';

  procList.hdr = crtUsrSpc( usrSpc: 'RPGUnit - Procedure list.');
  rtvProcInfo( srvPgm: usrSpc );

  procList.current = procList.hdr + listhdr.listOffs;

  return procList;

end-proc;


//----------------------------------------------------------------------
// Adapts a ProcList_t interface into a ProcNmList_t. See prototype.
//----------------------------------------------------------------------
dcl-proc getProcNmList export;
  dcl-pi *N likeds(procNmList_t);
    proclist        likeds(procList_t);
  end-pi;

  dcl-ds procnmlist likeds(procNmList_t);


  procnmlist.handle   = %addr( proclist );
  procnmlist.cnt      = %paddr( cntProc );
  procnmlist.getnm    = %paddr( getProcNm );
  procnmlist.gotonext = %paddr( goToNextProc );

  return procnmlist;

end-proc;


//----------------------------------------------------------------------
// Returns the current procedure name. See prototype.
//----------------------------------------------------------------------
dcl-proc getProcNm export;
  dcl-pi *N like(procNm_t);
    proclist        const likeds(procList_t);
  end-pi;

  // Procedure description.
  dcl-ds procdesc likeds(spgl0610_t)
  based(proclist.current);
  // A buffer and its pointer to access the procedure name.
  dcl-s procnmbuffer    char(256) based(procnm_p);
  dcl-s procnm_p        pointer;
  // The procedure name, to be returned.
  dcl-s procnm          like(procNm_t);


  procnm_p = proclist.hdr + procdesc.procnmoff;
  procnm = %subst(procnmbuffer: 1: procdesc.procnmsize);

  return procnm;

end-proc;


//----------------------------------------------------------------------
// Go to the next procedure info entry. See prototype.
//----------------------------------------------------------------------
dcl-proc goToNextProc export;
  dcl-pi *N;
    procList likeds(procList_t);
  end-pi;

  dcl-ds procDesc likeds(spgl0610_t)
  based(procList.current);


  procList.current += procDesc.size;

end-proc goToNextProc;


//----------------------------------------------------------------------
// Stores procedure info in a user space. See prototype.
//----------------------------------------------------------------------
dcl-proc rtvProcInfo;
  dcl-pi *N;
    srvPgm          value likeds(object_t);
    usrSpc          const likeds(object_t);
  end-pi;
  dcl-ds percolateErrors
         likeds(percolateErrors_t)
  inz(*likeds);

  if srvPgm.lib = *blank;
    srvPgm.lib = '*LIBL';
  endif;

  qbnlspgm( usrSpc :
            'SPGL0610' :
            srvPgm :
            percolateErrors );

end-proc;
