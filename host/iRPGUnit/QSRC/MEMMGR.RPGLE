**FREE
// ==========================================================================
//  iRPGUnit - Memory Manager.
// ==========================================================================
//  Copyright (c) 2013-2025 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
//  Do not link this module to a service program or program.
//  !!! Always use service program RUMEMMGR !!!
//  Otherwise validating the allocated and deallocated resources
//  cannot correctly work.
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

/undefine ENABLE_DEBUG_MESSAGES

//----------------------------------------------------------------------
//   Exported Procedures
//----------------------------------------------------------------------

/include qinclude,MEMMGR

//----------------------------------------------------------------------
//   Imported Procedures
//----------------------------------------------------------------------

/include qinclude,pgmmsg
/include qinclude,string
/include qinclude,libc_h
/include qllist,llist_h

//----------------------------------------------------------------------
//   GLOBAL VARIABLES
//----------------------------------------------------------------------

dcl-ds g_status qualified inz;
  maxSizeAllocMem int(20);
  sizeAllocMem    int(20);
  numAllocs       int(10);
  numLists        int(10);
end-ds;

//----------------------------------------------------------------------
//   Type Definitions
//----------------------------------------------------------------------

dcl-c KB 1024;

dcl-c MEMMGR_ID '*MEMMGR';

// 48 bytes of memory managment data.
// The size of this data structure must be a
// multiple of 16 due to the pointer fields.
// Best is to keep the pointers atthe end, so
// that they will be aligned at a 16-byte
// boundary by the compiler.
dcl-ds hAlloc_t align qualified template;
  id    char(8) inz(MEMMGR_ID);
  size  int(10);
  pBase pointer;
  pExt  pointer;
end-ds;

//----------------------------------------------------------------------
// Resets the maximum size of allocated memory.
//----------------------------------------------------------------------
dcl-proc MemMgr_reset export;
  dcl-pi *n;
  end-pi;

  if (g_status.sizeAllocMem <> 0);
    sndEscapeMsgAboveCtlBdy('Reset: Cannot reset memory size. Not all pointers freed.');
  endif;

  g_status.maxSizeAllocMem = 0;

end-proc;

//----------------------------------------------------------------------
// Allocates a memory block of a given size.
//----------------------------------------------------------------------
dcl-proc MemMgr_alloc export;
  dcl-pi *n pointer;
    i_size   int(10) const;
    i_msg    varchar(64) options(*nopass: *omit) const;
  end-pi;

  dcl-s pMemory pointer;
  dcl-s sizeReq int(20);
  dcl-ds hAlloc likeds(hAlloc_t) based(pBase);

  sizeReq = i_size + %size(hAlloc);

  g_status.numAllocs += 1;
  g_status.sizeAllocMem += sizeReq;

  if (g_status.sizeAllocMem > g_status.maxSizeAllocMem);
    g_status.maxSizeAllocMem = g_status.sizeAllocMem;
  endif;

  pBase = %alloc(sizeReq);

  hAlloc.id = MEMMGR_ID;
  hAlloc.size = i_size;
  hAlloc.pBase = pBase;
  hAlloc.pExt = hAlloc.pBase + %size(hAlloc);

  memset(hAlloc.pExt: x'00': i_size);

  pMemory = hAlloc.pExt;

  sndPlainDbgMsg(crtDbgMsg('Alloc memory: ': i_msg: pMemory));

  return pMemory;

end-proc;

//----------------------------------------------------------------------
// Deallocates previously allocated memory.
//----------------------------------------------------------------------
dcl-proc MemMgr_dealloc export;
  dcl-pi *n;
    io_pMemory pointer;
    i_msg    varchar(64) options(*nopass: *omit) const;
  end-pi;

  dcl-s pMemory pointer;
  dcl-s sizeReq int(20);
  dcl-ds hAlloc likeds(hAlloc_t) based(pBase);

  sndPlainDbgMsg(crtDbgMsg('Dealloc memory: ': i_msg: io_pMemory));

  if (io_pMemory = *null);
    sndEscapeMsgAboveCtlBdy('Dealloc: Cannot deallocate a *NULL pointer.');
  endif;

  pBase = io_pMemory - %size(hAlloc);

  if (io_pMemory <> hAlloc.pExt);
    sndEscapeMsgAboveCtlBdy('Dealloc: Invalid external pointer.');
  endif;

  if (pBase <> hAlloc.pBase);
    sndEscapeMsgAboveCtlBdy('Dealloc: Invalid basing pointer.');
  endif;

  sizeReq = hAlloc.size + %size(hAlloc);

  g_status.numAllocs -= 1;
  g_status.sizeAllocMem -= sizeReq;

  select;
  when (g_status.numAllocs = 0);
    sndPlainDbgMsg('Num allocs: ' + %char(g_status.numAllocs));
  when (g_status.numAllocs < 0);
    sndPlainDbgMsg('Num allocs is negative: ' + %char(g_status.numAllocs));
  endsl;

  pMemory = hAlloc.pBase;

  dealloc(n) pMemory;

  io_pMemory = pMemory;

end-proc;

//----------------------------------------------------------------------
// Returns the number of allocated memory buffers.
//----------------------------------------------------------------------
dcl-proc MemMgr_getNumAllocs export;
  dcl-pi *n int(10);
  end-pi;

  return g_status.numAllocs;

end-proc;

//----------------------------------------------------------------------
// Returns the total size of allocated memory.
//----------------------------------------------------------------------
dcl-proc MemMgr_getSizeAllocMem export;
  dcl-pi *n like(memSize_t);
  end-pi;

  dcl-s memSize like(memSize_t);

  memSize = g_status.sizeAllocMem / KB;

  return memSize;

end-proc;

//----------------------------------------------------------------------
// Returns the maximum size of allocated memory.
//----------------------------------------------------------------------
dcl-proc MemMgr_getMaxSizeAllocMem export;
  dcl-pi *n like(memSize_t);
  end-pi;

  dcl-s memSize like(memSize_t);

  memSize = g_status.maxSizeAllocMem / KB;

  return memSize;

end-proc;

//----------------------------------------------------------------------
// Creates a linked list.
//----------------------------------------------------------------------
dcl-proc MemMgr_createList export;
  dcl-pi *n pointer;
    i_msg    varchar(64) options(*nopass: *omit) const;
  end-pi;

  dcl-s hList pointer;

  g_status.numLists += 1;

  hList = list_create();

  sndPlainDbgMsg(crtDbgMsg('Create list: ': i_msg: hList));

  return hList;

end-proc;

//----------------------------------------------------------------------
// Disposes a linked list.
//----------------------------------------------------------------------
dcl-proc MemMgr_disposeList export;
  dcl-pi *n;
    io_hlist pointer;
    i_msg    varchar(64) options(*nopass: *omit) const;
  end-pi;

  sndPlainDbgMsg(crtDbgMsg('Dispose list: ': i_msg: io_hList));

  if (io_hList = *null);
    sndEscapeMsgAboveCtlBdy('Dispose list: Cannot deallocate *NULL pointer.');
  endif;

  g_status.numLists -= 1;

  select;
  when (g_status.numLists = 0);
    sndPlainDbgMsg('Num lists: ' + %char(g_status.numLists));
  when (g_status.numLists < 0);
    sndPlainDbgMsg('Num lists is negative: ' + %char(g_status.numLists));
  endsl;

  list_dispose(io_hlist);

end-proc;

//----------------------------------------------------------------------
// Returns the total number of created linked lists.
//----------------------------------------------------------------------
dcl-proc MemMgr_getNumLists export;
  dcl-pi *n int(10);
  end-pi;

  return g_status.numLists;

end-proc;

//----------------------------------------------------------------------
// Produces a debug message.
//----------------------------------------------------------------------
dcl-proc crtDbgMsg;
  dcl-pi *n varchar(128) extproc(*dclcase);
    i_prefix  varchar(64) const;
    i_msg     varchar(64) const;
    i_pointer pointer const;
  end-pi;

  dcl-s msg varchar(256);

  if (%addr(i_msg) <> *null);
    msg = i_prefix + ' ' + i_msg + ' (' + ptrToStr(i_pointer) + ')';
  else;
    msg = i_prefix + ' (' + ptrToStr(i_pointer) + ')';
  endif;

  return msg;

end-proc;

//----------------------------------------------------------------------
// Sends a debug message to the job log.
//----------------------------------------------------------------------
dcl-proc sndPlainDbgMsg;
  dcl-pi *n extproc(*dclcase);
    i_msg varchar(256) const;
  end-pi;

/if defined(ENABLE_DEBUG_MESSAGES)
  snd-msg *INFO '[DEBUG] ' + i_msg %target(*caller);
/endif

end-proc;

