**FREE
/if not defined (IRPGUNIT_CALLSTACK)
/define IRPGUNIT_CALLSTACK
// ==========================================================================
//  iRPGUnit - Callstack.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================

///
// Returns the pointer of an allocated callstack memory buffer.
//
// @param numE - number of callstack entries
// @param msg  - debug message
///
dcl-pr Callstack_alloc pointer extproc('CALLSTACK_Callstack_alloc');
  numE int(10) const;
  msg  varchar(64) options(*nopass: *omit) const;
end-pr;

///
// Frees the memory of an allocated callstack buffer.
//
// @param pCallstk - pointer of the callstack buffer
// @param msg  - debug message.
//               Should match the message of Callstack_alloc().
///
dcl-pr Callstack_dealloc extproc('CALLSTACK_Callstack_dealloc');
  pCallstk pointer;
  msg      varchar(64) options(*nopass: *omit) const;
end-pr;

///
// Returns the number of stack entries of a given callstack.
//
// @param pCallstk - pointer of the callstack buffer
///
dcl-pr Callstack_getNumE int(10) extproc('CALLSTACK_Callstack_getNumE');
  pCallstk pointer const;
end-pr;

///
// Adds a callstack entry to the callstack.
//
// @param pCallstk - pointer of the callstack buffer
// @param entry    - Callstack entry that is added to the callstack
///
dcl-pr Callstack_addEntry extproc('CALLSTACK_Callstack_addEntry');
  pCallstk   pointer const;
  callstkEnt likeds(callStkEnt_t) const;
end-pr;

///
// Resets the internal iteration state of the list so that the next
// call to 'list_iterate</em> will return the first element.
//
// @param pCallstk - pointer of the callstack buffer
///
dcl-pr Callstack_resetIteration extproc('CALLSTACK_Callstack_resetIteration');
  pCallstk pointer const;
end-pr;

///
// Iterates through the list and gets the next callstack entry. If the
// iterator is at the end of the list, *off is returned, otherwise *on.
//
// @param pCallstk   - pointer of the callstack buffer
// @param callstkEnt - callstack entry
///
dcl-pr Callstack_getNext ind extproc('CALLSTACK_Callstack_getNext');
  pCallstk   pointer const;
  callstkEnt likeds(callStkEnt_t);
end-pr;

///
// Returns the callstack entry addressed by the specified index.
//
// @param pCallstk - pointer of the callstack buffer
// @param dx       - index number of the callstack entry
//
// @return callstack entry
///
dcl-pr Callstack_get likeds(callStkEnt_t) extproc('CALLSTACK_Callstack_get');
  pCallstk pointer const;
  idx      int(10) const;
end-pr;

/include qinclude,TEMPLATES

/endif
