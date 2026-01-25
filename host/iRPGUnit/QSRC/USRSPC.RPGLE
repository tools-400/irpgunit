**FREE
// ==========================================================================
//  iRPGUnit - User Space Utilities.
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

/include qinclude,USRSPC
/include qinclude,ERRORCODE

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,SYSTEMAPI


//----------------------------------------------------------------------
//   Global DS
//----------------------------------------------------------------------

/include qinclude,TYPES_H

//----------------------------------------------------------------------
//   Procedures Definition
//----------------------------------------------------------------------

dcl-proc crtUsrSpc export;
  //----------------------------------------------------------------------
  // Creates a user space. See prototype.
  //----------------------------------------------------------------------
  dcl-pi crtUsrSpc pointer;
    qUsrSpc   const likeds(object_t);
    text     char(50) const;
  end-pi;

  // User Space to store proc list.
  dcl-ds usrSpcCrtParm likeds(usrSpcCrtParm_t);
  // Pointer to the user space.
  dcl-s pUsrSpc pointer;
  dcl-ds percolateErrors likeds(percolateErrors_t) inz(*likeds);

  usrSpcCrtParm.nm = qUsrSpc;
  usrSpcCrtParm.attribute = 'USRSPC';
  usrSpcCrtParm.size = 16384;
  usrSpcCrtParm.value = x'00';
  usrSpcCrtParm.auth = '*ALL';
  usrSpcCrtParm.text = text;
  usrSpcCrtParm.replace = '*YES';

  quscrtus( usrSpcCrtParm.nm :
            usrSpcCrtParm.attribute :
            usrSpcCrtParm.size :
            usrSpcCrtParm.value :
            usrSpcCrtParm.auth :
            usrSpcCrtParm.text :
            usrSpcCrtParm.replace :
            percolateErrors );

  qusptrus( qUsrSpc : pUsrSpc );

  return pUsrSpc;

end-proc;
