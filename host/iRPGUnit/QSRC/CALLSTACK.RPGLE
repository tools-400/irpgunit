**FREE
// ==========================================================================
//  iRPGUnit - Callstack.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
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

/include qinclude,CALLSTACK
/include qinclude,MEMMGR
/include qinclude,PGMMSG
/include qsysinc,MEMCPY

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,TEMPLATES

//----------------------------------------------------------------------
// Returns the pointer of an allocated callstack memory buffer.
//----------------------------------------------------------------------
dcl-proc Callstack_alloc export;
  dcl-pi *N pointer;
    numE int(10) const;
    msg  varchar(64) options(*nopass: *omit) const;
  end-pi;

  dcl-ds callstk likeds(callstk_t) based(pCallstk);

  dcl-s size int(10);

  size = getSize(numE);
  pCallstk = MemMgr_alloc(size: msg);
  callstk.header.id = CALLSTACK_ID;
  callstk.header.iteration = -1;
  callstk.header.numE = 0;
  callstk.header.maxE = numE;

  checkType(pcallstk);

  return pCallstk;

end-proc;

//----------------------------------------------------------------------
// Frees the memory of an allocated callstack buffer.
//----------------------------------------------------------------------
dcl-proc Callstack_dealloc export;
  dcl-pi *N;
    pCallstk pointer;
    msg      varchar(64) options(*nopass: *omit) const;
  end-pi;

  MemMgr_dealloc(pCallstk: msg);

end-proc;

//----------------------------------------------------------------------
// Returns the number of stack entries of a given callstack.
//----------------------------------------------------------------------
dcl-proc Callstack_getNumE export;
  dcl-pi *N int(10);
    pCallstk pointer const;
  end-pi;

  dcl-ds callstk likeds(callstk_t) based(pCallstk);
  dcl-s numE int(10);

  checkType(pCallstk);

  numE = callStk.header.numE;

  return numE;

end-proc;

//----------------------------------------------------------------------
// Adds a callstack entry to the callstack.
//----------------------------------------------------------------------
dcl-proc Callstack_AddEntry export;
  dcl-pi *N;
    pCallstk   pointer const;
    callstkEnt likeds(callStkEnt_t) const;
  end-pi;

  dcl-ds callstk likeds(callstk_t) based(pCallstk);
  dcl-s size int(10);

  checkType(pCallstk);

  if (callstk.header.numE = callstk.header.maxE);
    sndEscapeMsgAboveCtlBdy('ERROR: No space left for another callstack entry.');
  endif;

  callstk.header.numE += 1;
  callstk.entry(callstk.header.numE) = callstkEnt;

end-proc;

//----------------------------------------------------------------------
// Resets the internal iteration state of the list so that the next
// call to 'list_iterate</em> will return the first element.
//----------------------------------------------------------------------
dcl-proc Callstack_resetIteration export;
  dcl-pi *N;
    pCallstk pointer const;
  end-pi;

  dcl-ds callstk likeds(callstk_t) based(pCallstk);

  checkType(pCallstk);

  callstk.header.iteration = -1;

end-proc;

//----------------------------------------------------------------------
// Iterates through the list and gets the next callstack entry. If the
// iterator is at the end of the list, *off is returned, otherwise *on.
//----------------------------------------------------------------------
dcl-proc Callstack_getNext export;
  dcl-pi *N ind;
    pCallstk   pointer const;
    callstkEnt likeds(callStkEnt_t);
  end-pi;

  dcl-ds callstk likeds(callstk_t) based(pCallstk);

  checkType(pCallstk);

  if (callstk.header.numE = 0);
    clear callstkEnt;
    return *off;
  endif;

  if (callstk.header.iteration + 1 > callstk.header.numE);
    clear callstkEnt;
    return *off;
  endif;

  if (callstk.header.iteration = -1);
    callstk.header.iteration = 1;
  else;
    callstk.header.iteration += 1;
  endif;

  callstkEnt = callstk.entry(callstk.header.iteration);

  return *on;

end-proc;

//----------------------------------------------------------------------
// Returns the callstack entry addressed by the specified index.
//----------------------------------------------------------------------
dcl-proc Callstack_get export;
  dcl-pi *N likeds(callStkEnt_t);
    pCallstk pointer const;
    idx      int(10) const;
  end-pi;

  dcl-ds callstk likeds(callstk_t) based(pCallstk);
  dcl-ds callstkEnt likeds(callStkEnt_t) inz;

  checkType(pCallstk);

  if (callstk.header.numE = 0);
    clear callstkEnt;
    return callstkEnt;
  endif;

  if (callstk.header.iteration + 1 > callstk.header.numE);
    clear callstkEnt;
    return callstkEnt;
  endif;

  callstkEnt = callstk.entry(idx);

  return callstkEnt;

end-proc;

//----------------------------------------------------------------------
// Returns the memory size in bytes of a given callstack.
//----------------------------------------------------------------------
dcl-proc getSize;
  dcl-pi *N int(10) extproc(*dclcase);
    numE int(10) const;
  end-pi;

  dcl-s size int(10);

  size = %size(callStk_t.header) + (numE * %size(callStkEnt_t));

  return size;

end-proc;

//----------------------------------------------------------------------
// Checks for a callstack list implementation.
//----------------------------------------------------------------------
dcl-proc checkType;
  dcl-pi *N;
    pCallstk pointer const;
  end-pi;

  dcl-ds callstk likeds(callstk_t) based(pCallstk);

  if (callstk.header.id <> CALLSTACK_ID);
    sndEscapeMsgAboveCtlBdy('The pointer does not point to a callstack data structure.');
  endif;

end-proc;

