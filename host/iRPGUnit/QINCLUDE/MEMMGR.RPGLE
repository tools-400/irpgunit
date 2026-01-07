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

///
// Resets the maximum size of allocated memory.
///
dcl-pr MemMgr_reset extproc('MEMMGR_MemMgr_reset');
end-pr;

///
// Allocates a memory block of a given size.
//
// @param i_size - SIze of the memory to allocate
//
// @return pointer to allocated memory
///
dcl-pr MemMgr_alloc pointer extproc('MEMMGR_MemMgr_alloc');
  i_size int(10) const;
  i_msg  varchar(64) options(*nopass: *omit) const;
end-pr;

///
// Deallocates previously allocated memory.
//
// @param io_pMemory - Pointer of the allocated memory
///
dcl-pr MemMgr_dealloc extproc('MEMMGR_MemMgr_dealloc');
  io_pMemory pointer;
  i_msg      varchar(64) options(*nopass: *omit) const;
end-pr;

///
// Returns the number of allocated memory buffers.
//
// @return number of allocated memory pointers
///
dcl-pr MemMgr_getNumAllocs int(10) extproc('MEMMGR_MemMgr_getNumAllocs');
end-pr;

///
// Returns the total size of allocated memory.
//
// @return total size of allocated memory
///
dcl-pr MemMgr_getSizeAllocMem like(memSize_t) extproc('MEMMGR_MemMgr_getSizeAllocMem');
end-pr;

///
// Returns the maximum size of allocated memory.
///
dcl-pr MemMgr_getMaxSizeAllocMem like(memSize_t) extproc('MEMMGR_MemMgr_getMaxSizeAllocMem');
end-pr;

///
// Creates a linked list.
//
// @param i_size - SIze of the memory to allocate
//
// @return pointer to allocated memory
///
dcl-pr MemMgr_createList pointer extproc('MEMMGR_MemMgr_createList');
  i_msg varchar(64) options(*nopass: *omit) const;
end-pr;

///
// Disposes a linked list.
//
// @param io_pMemory - Pointer of the allocated memory
///
dcl-pr MemMgr_disposeList extproc('MEMMGR_MemMgr_disposeList');
  io_pMemory pointer;
  i_msg varchar(64) options(*nopass: *omit) const;
end-pr;

///
// Returns the total number of linked lists.
//
// @return numer of allocated memory pointers
///
dcl-pr MemMgr_getNumLists int(10) extproc('MEMMGR_MemMgr_getNumLists');
end-pr;

