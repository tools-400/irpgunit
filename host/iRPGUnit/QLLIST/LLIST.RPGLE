**FREE
//*
// \brief Linked List Implementation
//
// This is a typical Doubly-Linked List (Two-Way Linked List) Implementation
// using dynamic memory allocation. The list is particular suitable for
// character values but does also work with any other data (f. e. data
// structures).
//
// <br><br>
//
// Values are stored as null-terminated chars.
//
// <br><br>
//
// Operations that index into the list will traverse the list from
// the beginning or the end, whichever is closer to the specified index.
//
// <br><br>
//
// <b>Iteration:</b> With the procedure <em>getNext</em> the list is
// traversable in the top-bottom direction. Each call to <em>getNext</em>
// will return the next entry of the list till the end of the list.
// If the walk through the list should be stopped early (before the end
// of the list) the method <em>abortIteration</em> should be called.
// If the list is structurally modified at any time
// after an iteration has begun in any way, the result of the iteration
// can not be safely determined. If an iteratioj is not going to continue
// the procedure <em>abortIteration</em> should be called. After that
// call it is safe to modify the list again.
//
// <br><br>
//
// Throughout this service program a zero-based index is used.
//
// <br><br>
//
// This list implementation is not thread-safe.
//
// \author Mihael Schmidt
// \date   20.12.2007
//
// \rev 22.11.2009 Mihael Schmidt
//      Added sorting support <br>
//      Changed memory management to user created heap <br>
//      Added removeRange procedure <br>
//      Bug fix: list_addAll does not work if value has x'00'
//
// \rev 15.12.2009 Mihael Schmidx
//      Added merge procedure
//
// \rev 19.02.2011 Mihael Schmidt
//      Fixed list_sublist procedure <br>
//      Added list_resetIteration <br>
//      Deprecated list_abortIteration <br>
//      Added list_iterate <br>
//      Deprecated list_getNext <br>
//      Userdata parameter on list_foreach is now optional <br>
//      list_merge got new parameter to only optionally skip duplicate entries
///

//------------------------------------------------------------------------
//
// Copyright (c) 2007-2009 Mihael Schmidt
// All rights reserved.
//
// This file is part of the LLIST service program.
//
// LLIST is free software: you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// any later version.
//
// LLIST is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with LLIST.  If not, see http://www.gnu.org/licenses/.
//
//------------------------------------------------------------------------
//  >>PRE-COMPILER<<
//    >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//    >>IMPORTANT<<
//      >>PARM<<  INCDIR('/qsys.lib/&LI.lib/qllist.file/');
//      >>PARM<<  OPTION(*EVENTF);
//      >>PARM<<  DBGVIEW(*LIST);
//    >>END-IMPORTANT<<
//    >>EXECUTE<<
//  >>END-PRE-COMPILER<<
//------------------------------------------------------------------------



ctl-opt NOMAIN;
ctl-opt COPYRIGHT('Copyright (c) 2007-2011 Mihael Schmidt. All rights reserved.');


//-------------------------------------------------------------------------
// Prototypen
//-------------------------------------------------------------------------
/include qllist,llist_h
/include qllist,llist_in_h
/include qllist,ceeapi_h


//-------------------------------------------------------------------------
// Procedures
//-------------------------------------------------------------------------

//*
//  \brief Create list
//
// Creates a list. A header is generated for the list and the pointer to
// the list returned.
//
// <br><br>
//
// A list must be disposed via the procedure <em>dispose</em> to free all
// allocated memory.
//
// \author Mihael Schmidt
// \date   18.12.2007
//
// \return Pointer to the list
///
dcl-proc list_create export;
  dcl-pi *N pointer;
  end-pi;

  dcl-s listPtr         pointer;
  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s heapId          int(10);
  cee_createHeap(heapId : *omit : *omit : *omit : *omit);

  // allocate memory for list header
  cee_getStorage(heapId : %size(tmpl_header) : listPtr : *omit);

  header.id = LIST_ID;
  header.heapId = heapId;
  header.size = 0;
  header.bytes = 0;
  header.firstEntry = *null;
  header.lastEntry = *null;
  header.iteration = -1;
  header.iterNextEntry = *null;
  header.iterPrevEntry = *null;

  return listPtr;
end-proc;


//*
// \brief Dispose list
//
// The memory for whole list are is released
// (deallocated). The list pointer is set to *null;
//
// <br><br>
//
// If the passed pointer is already *null the procedure simply returns.
//
// \author Mihael Schmidt
// \date   18.12.2007
//
// \param Pointer to the list
///
dcl-proc list_dispose export;
  dcl-pi *N;
    listPtr   pointer;
  end-pi;
  dcl-ds header likeds(tmpl_header) based(listPtr);
  if (listPtr = *null);
  // do nothing
  else;

    if (isLinkedListImpl(listPtr));
      cee_discardHeap(header.heapId : *omit);
      listPtr = *null;
    endif;

  endif;
end-proc;


//*
// \brief Add list entry
//
// Adds an entry at an exact position in the list. If the position is
// outside the list the procedure returns <em>*off</em>. The current
// entry of the list at that position will be pushed one position down
// the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// \author Mihael Schmidt
// \date   18.12.2007
//
// \param Pointer to the list
// \param Pointer to the new value
// \param Length of the new value
// \param List position for the new value (optional)
//
// \return *on = entry added the list <br>
//         *off = error
///
dcl-proc list_add export;
  dcl-pi *N ind;
    listPtr    pointer const;
    ptrValue   pointer const;
    length     uns(10) const;
    pos        uns(10) const options(*nopass);
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s nextEntryPtr    pointer;
  dcl-ds nextEntry likeds(tmpl_entry)
  based(nextEntryPtr);
  dcl-s prevEntryPtr    pointer;
  dcl-ds prevEntry likeds(tmpl_entry)
  based(prevEntryPtr);
  dcl-s newEntryPtr     pointer;
  dcl-ds newEntry likeds(tmpl_entry)
  based(newEntryPtr);
  dcl-s tmpPtr          pointer;
  dcl-s retVal          ind inz(*on);
  if (%parms() = 4);

    if (isLinkedListImpl(listPtr));
      // check if the position is outside of the list
      if (pos < 0 or pos > header.size -1);
        sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      endif;

      nextEntryPtr = getListEntryDs(listPtr : pos);
      if (nextEntryPtr <> *null);
        if (nextEntry.prevE <> *null);
          prevEntryPtr = nextEntry.prevE;
        else;
          // must be the start of the list (which has no previous entry)
        endif;

        //
        // create new entry
        //

        // alloc memory for this entry
        cee_getStorage(header.heapId:%size(tmpl_entry):newEntryPtr:*omit);
        newEntry.length = length + 1;     // +1 for the null value
        cee_getStorage(header.heapId : length + 1 : newEntry.value :*omit);
        newEntry.nextE = *null;
        newEntry.prevE = *null;

        // copy value to the list entry
        memcpy(newEntry.value : ptrValue : length);

        // set null to the last byte
        tmpPtr = newEntry.value + length;
        memcpy(tmpPtr : %addr(hexNull) : 1);

        // set pointers so that the list is correctly linked again
        newEntry.prevE = prevEntryPtr;
        newEntry.nextE = nextEntryPtr;
        nextEntry.prevE = newEntryPtr;
        if (prevEntryPtr <> *null);
          prevEntry.nextE = newEntryPtr;
        endif;

        // update header
        header.size += 1;
        if (newEntry.prevE = *null);
          header.firstEntry = newEntryPtr;
        endif;

      else;
        // could not get entry at given position
        retVal = *off;
      endif;

    else;
      retVal = *off;
    endif;

  else; // append to the end of the list
    retVal = list_addLast(listPtr : ptrValue : length);
  endif;

  return retVal;
end-proc;


//*
// \brief Add list entry to the top of the list
//
// \author Mihael Schmidt
// \date   18.12.2007
//
// \param Pointer to the list
// \param Pointer to new value
// \param Length of new value
//
// \return *on = successful <br>
//         *off = error
///
dcl-proc list_addFirst export;
  dcl-pi *N ind;
    listPtr    pointer;
    valuePtr   pointer const;
    length     uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s newEntryPtr     pointer;
  dcl-ds newEntry likeds(tmpl_entry)
  based(newEntryPtr);
  dcl-s nextEntryPtr    pointer;
  dcl-ds nextEntry likeds(tmpl_entry)
  based(nextEntryPtr);
  dcl-s tmpPtr          pointer;
  dcl-s retVal          ind inz(*on);
  if (isLinkedListImpl(listPtr));

    //
    // create new entry
    //

    // alloc memory for this entry
    cee_getStorage(header.heapId:%size(tmpl_entry):newEntryPtr:*omit);
    newEntry.length = length + 1;     // +1 for the null value
    cee_getStorage(header.heapId : length + 1 : newEntry.value :*omit);
    newEntry.nextE = *null;
    newEntry.prevE = *null;

    // copy value to the list entry
    memcpy(newEntry.value : valuePtr : length);

    // add null
    tmpPtr = newEntry.value + length;
    memcpy(tmpPtr : %addr(hexNull) : 1);

    if (header.size > 0);
      nextEntryPtr = getListEntryDs(listPtr : 0);
      nextEntry.prevE = newEntryPtr;
      newEntry.nextE = nextEntryPtr;
    endif;

    // update header
    header.size += 1;
    header.firstEntry = newEntryPtr;
    if (header.size = 1);
      header.lastEntry = newEntryPtr;
    endif;

  endif;

  return retVal;
end-proc;


//*
// \brief Add list entry to the end of the list
//
// \author Mihael Schmidt
// \date   18.12.2007
//
// \param Pointer to the list
// \param Pointer to new value
// \param Length of new value
//
// \return *on = successful <br>
//         *off = error
///
dcl-proc list_addLast export;
  dcl-pi *N ind;
    listPtr    pointer const;
    valuePtr   pointer const;
    length     uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s newEntryPtr     pointer;
  dcl-ds newEntry likeds(tmpl_entry)
  based(newEntryPtr);
  dcl-s prevEntryPtr    pointer;
  dcl-ds prevEntry likeds(tmpl_entry)
  based(prevEntryPtr);
  dcl-s tmpPtr          pointer;
  dcl-s retVal          ind inz(*on);
  if (isLinkedListImpl(listPtr));

    //
    // create new entry
    //

    // alloc memory for this entry
    cee_getStorage(header.heapId:%size(tmpl_entry):newEntryPtr:*omit);
    newEntry.length = length + 1;     // +1 for the null value
    cee_getStorage(header.heapId : length + 1 : newEntry.value :*omit);
    newEntry.nextE = *null;
    newEntry.prevE = *null;

    // copy value to the list entry
    memcpy(newEntry.value : valuePtr : length);

    // add null
    tmpPtr = newEntry.value + length;
    memcpy(tmpPtr : %addr(hexNull) : 1);

    if (header.size > 0);
      prevEntryPtr = getListEntryDs(listPtr : header.size -1);
      prevEntry.nextE = newEntryPtr;
      newEntry.prevE = prevEntryPtr;
    endif;

    // update header
    header.size += 1;
    header.lastEntry = newEntryPtr;
    if (header.size = 1);
      header.firstEntry = newEntryPtr;
    endif;

  endif;

  return retVal;
end-proc;


//*
// \brief Add all elements of a list
//
// Adds all elements of the passed list to the end of this list.
// Elements will not be referenced but storage newly allocated.
//
// \author Mihael Schmidt
// \date   18.12.2007
//
// \param Pointer to the destination list
// \param Pointer to the source list
//
// \return *on = all elements added to list <br>
//         *off = not all or none elements added
///
dcl-proc list_addAll export;
  dcl-pi *N ind;
    listPtr      pointer const;
    srcListPtr   pointer const;
  end-pi;

  dcl-s retVal          ind inz(*on);
  dcl-ds header likeds(tmpl_header) based(srcListPtr);
  dcl-s entryPtr        pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  if (isLinkedListImpl(listPtr) and
      isLinkedLIstImpl(srcListPtr));

    entryPtr = header.firstEntry;
    dow (entryPtr <> *null);

      // entry.length -1 => dont include the null value
      if (not list_add(listPtr : entry.value : entry.length-1));
        retVal = *off;
        leave;
      endif;

      entryPtr = entry.nextE;
    enddo;
  endif;

  return retVal;
end-proc;


//*
// \brief Remove list entry
//
// Removes an entry from the list at the given position. If the
// position is outside of the list the return value will be <em>*off</em>.
//
// <br><br>
//
// The index is 0 (zero) based.
//
// \author Mihael Schmidt
// \date   18.12.2007
//
// \param Pointer to the list
// \param index of the entry in the list (zero-based)
//
// \return *on = entry removed
//         *off = error
///
dcl-proc list_remove export;
  dcl-pi *N ind;
    listPtr   pointer const;
    index     uns(10) const;
  end-pi;
  //
  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s ptr             pointer;
  dcl-ds entry likeds(tmpl_entry) based(ptr);
  dcl-s nextEntryPtr    pointer;
  dcl-ds nextEntry likeds(tmpl_entry)
  based(nextEntryPtr);
  dcl-s prevEntryPtr    pointer;
  dcl-ds prevEntry likeds(tmpl_entry)
  based(prevEntryPtr);
  dcl-s retVal          ind inz(*on);

  if (isLinkedListImpl(listPtr));

  // check if the position is outside of the list
  if (index < 0 or index > header.size -1);
  return *off;
  endif;

  ptr = getListEntryDs(listPtr : index);
  if (ptr = *null);
  return *off;
  endif;

  nextEntryPtr = entry.nextE;
  prevEntryPtr = entry.prevE;

  if (prevEntryPtr <> *null);
  prevEntry.nextE = nextEntryPtr;
  endif;

  if (nextEntryPtr <> *null);
  nextEntry.prevE = prevEntryPtr;
  endif;

  // free memory
  cee_freeStorage(entry.value : *omit);
  cee_freeStorage(ptr : *omit);

  // update header
  header.size -= 1;
  if (nextEntryPtr = *null);
  header.lastEntry = prevEntryPtr;
  endif;
  if (prevEntryPtr = *null);
  header.firstEntry = nextEntryPtr;
  endif;

  endif;

  return retVal;
end-proc;


//*
// \brief Remove first list entry
//
// Removes the first entry from the list.
//
// \author Mihael Schmidt
// \date   18.12.2007
//
// \param Pointer to the list
//
// \return *on = entry removed <br>
//         *off = error
///
dcl-proc list_removeFirst export;
  dcl-pi *N ind;
    listPtr   pointer const;
  end-pi;

  return list_remove(listPtr : 0);
end-proc;


//*
// \brief Remove last list entry
//
// Removes the last entry from the list.
//
// \author Mihael Schmidt
// \date   18.12.2007
//
// \param Pointer to the list
//
// \return *on = entry removed <br>
//         *off = error (escape message)
///
dcl-proc list_removeLast export;
  dcl-pi *N ind;
    listPtr   pointer const;
  end-pi;
  //
  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s retVal ind inz(*off);

  if (isLinkedListImpl(listPtr));
  retVal = list_remove(listPtr : header.size - 1);
  endif;

  return retVal;
end-proc;


//*
// \brief Clear list
//
// Deletes all entries in the list.
//
// \author Mihael Schmidt
// \date   18.12.2007
//
// \param Pointer to the list
//
// \return *on = successful <br>
//         *off = error
///
dcl-proc list_clear export;
  dcl-pi *N ind;
    listPtr   pointer const;
  end-pi;
  //
  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s tmpPtr          pointer;
  dcl-s ptr             pointer;
  dcl-ds entry likeds(tmpl_entry) based(ptr);
  dcl-s retVal          ind inz(*off);
  if (isLinkedListImpl(listPtr));

    ptr = header.lastEntry;
    dow (ptr <> *null);
      tmpPtr = entry.prevE;

      if (entry.value <> *null);
        cee_freeStorage(entry.value : *omit);
      endif;

      cee_freeStorage(ptr : *omit);
      ptr = tmpPtr;
    enddo;

    // update header
    header.size = 0;
    header.firstEntry = *null;
    header.lastEntry = *null;
    header.bytes = %size(tmpl_header);
    header.iteration = -1;
    header.iterNextEntry = *null;
    header.iterPrevEntry = *null;

  endif;

  return retVal;
end-proc;


//*
// \brief Get next entry
//
// Iterates through the list and gets the next entry. If the iterator is
// at the end of the list this method will return <em>null</em>. The
// iteration can be aborted early with the procedure <em>
// list_resetIteration</em>.
//
// \author Mihael Schmidt
// \date   18.12.2007
//
// \param Pointer to the list
//
// \return Pointer to entry or *null if no more entries in list
//
// \deprecated Use <em>list_iterate</em> instead.
///
dcl-proc list_getNext export;
  dcl-pi *N pointer;
    listPtr   pointer const;
  end-pi;

  return list_iterate(listPtr);
end-proc;


//*
// \brief Iterate list
//
// Iterates through the list and returns the next entry. If the iterator is
// at the end of the list this method will return <em>null</em>. The
// iteration can be aborted early with the procedure <em>list_resetIteration</em>.
//
// \author Mihael Schmidt
// \date   19.2.2011
//
// \param Pointer to the list
//
// \return Pointer to entry or *nll if no more entries in list
///
dcl-proc list_iterate export;
  dcl-pi *N pointer;
    listPtr   pointer const;
  end-pi;
  //
  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr        pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s retVal          pointer;
  if (isLinkedListImpl(listPtr));

    if (header.iteration + 1 = header.size);
      list_resetIteration(listPtr);
      retVal = *null;
    else;
      header.iteration += 1;

      if (header.iterNextEntry = *null);
        entryPtr = getListEntryDs(listPtr : header.iteration);
      else;
        entryPtr = header.iterNextEntry;
      endif;

      header.iterNextEntry = entry.nextE;
      header.iterPrevEntry = entry.prevE;

      retVal = entry.value;
    endif;

  endif;

  return retVal;
end-proc;


//*
// \brief Get previous entry
//
// Iterates through the list and gets the previous entry. If the iterator is
// before the start of the list this method will return <em>null</em>. The
// iteration can be aborted early with the procedure <em>list_resetIteration</em>.
//
// \author Mihael Schmidt
// \date   18.12.2007
//
// \param Pointer to the list
//
// \return Pointer to entry or *null if no more entries in list
///
dcl-proc list_getPrev export;
  dcl-pi *N pointer;
    listPtr   pointer const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s retVal pointer;
  if (isLinkedListImpl(listPtr));

    if (header.iteration = 0);
      list_resetIteration(listPtr);
      retVal = *null;
    else;

      if (header.iteration = -1);
        header.iteration = header.size;
      endif;

      header.iteration -= 1;

      if (header.iterPrevEntry = *null);
        entryPtr = getListEntryDs(listPtr : header.iteration);
      else;
        entryPtr = header.iterPrevEntry;
      endif;

      if (entryPtr = *null);
        retVal = *null;
      else;
        header.iterNextEntry = entry.nextE;
        header.iterPrevEntry = entry.prevE;

        retVal = entry.value;
      endif;
    endif;

  endif;

  return retVal;
end-proc;


//*
// \brief Abort iteration
//
// If the iteration through the list should be aborted early this
// procedure should be called.
//
// \author Mihael Schmidt
// \date   18.12.2007
//
// \param Pointer to the list
//
// \deprecated Use <em>list_resetIteration</em> instead.
///
dcl-proc list_abortIteration export;
  dcl-pi *N;
    listPtr   pointer const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  list_resetIteration(listPtr);
end-proc;


//*
// \brief Reset iteration
//
// Resets the internal iteration state of the list so that the next
// call to <em>list_iterate</em> will return the first element.
//
// \author Mihael Schmidt
// \date   19.2.2011
//
// \param Pointer to the list
///
dcl-proc list_resetIteration export;
  dcl-pi *N;
    listPtr   pointer const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  if (isLinkedListImpl(listPtr));
    header.iteration = -1;
    header.iterNextEntry = *null;
    header.iterPrevEntry = *null;
  endif;
end-proc;


//*
// \brief Replaces an entry in the list
//
// An element in the list will be replaced. If there is no element
// at that position the return value will be <em>*off</em>.
//
// \author Mihael Schmidt
// \date   19.12.2007
//
// \param Pointer to the list
// \param Pointer to new value
// \param Length of new value
// \param index of new value
//
// \return *on = entry successfully replaced <br>
//         *off = error
///
dcl-proc list_replace export;
  dcl-pi *N ind;
    listPtr       pointer const;
    ptrValue      pointer const;
    lengthValue   uns(10) const;
    index         uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s retVal ind inz(*on);
  if (isLinkedListImpl(listPtr));

  // check if the position is outside of the list
  if (index < 0 or index > header.size -1);
  return *off;
  endif;

  entryPtr = getListEntryDs(listPtr : index);
  entry.length = lengthValue + 1;
  cee_reallocateStorage(entry.value : lengthValue + 1 : *omit); // +1 for the null byte

  // copy value to the list entry
  memcpy(ptrValue : entry.value : lengthValue);

  // set null to the last byte
  memcpy(entry.value + lengthValue : %addr(hexNull) : 1);
  endif;

  return retVal;
end-proc;


//*
// \brief Contains entry
//
// Checks if this list contains the passed entry.
//
// \author Mihael Schmidt
// \date   19.12.2007
//
// \param Pointer to the list
// \param Pointer to value
// \param Length of value
//
// \return *on = list contains value <br>
//         *off = list does not contain value
///
dcl-proc list_contains export;
  dcl-pi *N ind;
    listPtr       pointer const;
    valuePtr      pointer const;
    valueLength   uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s retVal ind inz(*off);
  if (isLinkedListImpl(listPtr));

    entryPtr = header.firstEntry;
    dow (entryPtr <> *null);
      if (valueLength = entry.length - 1 and
          memcmp(valuePtr : entry.value : valueLength) = 0); // dont include the null
        retVal = *on;
        leave;
      endif;

      entryPtr = entry.nextE;
    enddo;

  endif;

  return retVal;
end-proc;


//*
// \brief Check if list is empty
//
// Checks if the list is empty.
//
// \author Mihael Schmidt
// \date   19.12.2007
//
// \param Pointer to the list
//
// \return *on = list is empty <br>
//         *off = list is not empty
///
dcl-proc list_isEmpty export;
  dcl-pi *N ind;
    listPtr   pointer const;
  end-pi;
  //
  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s retVal ind;
  if (isLinkedListImpl(listPtr));

  if (header.size = 0);
    retVal = *on;
  else;
    retVal = *off;
  endif;

  endif;

  return retVal;
end-proc;


//*
// \brief Get entry
//
// Returns a list entry specified by the passed index.
//
// \author Mihael Schmidt
// \date   19.12.2007
//
// \param Pointer to the list
// \param List position
//
// \return Pointer to a null terminated string or
//         *null if an error occured or there is no
//         entry at that position
///
dcl-proc list_get export;
  dcl-pi *N pointer;
    listPtr   pointer const;
    index     uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s retVal pointer;
  dcl-s tmp char(1000) based(entry.value);
  if (isLinkedListImpl(listPtr));
    // check if list is empty or the position is outside of the list
    if (header.size = 0);
      return *null;
    elseif (index < 0 or index > header.size -1);
      return *null;
    endif;

    entryPtr = getListEntryDs(listPtr : index);
    retVal = entry.value;
  endif;

  return retVal;
end-proc;


//*
// \brief Get first entry
//
// Returns the first entry of the list.
//
// \author Mihael Schmidt
// \date   19.12.2007
//
// \param Pointer to the list
//
// \return Pointer to a null terminated string or
//         *null if the list is empty or an error occured
///
dcl-proc list_getFirst export;
  dcl-pi *N pointer;
    listPtr   pointer const;
  end-pi;

  dcl-s retVal pointer inz(*null);
  if (isLinkedListImpl(listPtr));
    retVal = list_get(listPtr : 0);
  endif;

  return retVal;
end-proc;


//*
// \brief Get last entry
//
// Returns the last entry of the list.
//
// \author Mihael Schmidt
// \date   19.12.2007
//
// \param Pointer to the list
//
// \return Pointer to a null terminated string or
//         *null if the list is empty or an error occured
///
dcl-proc list_getLast export;
  dcl-pi *N pointer;
    listPtr   pointer const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s retVal pointer inz(*null);
  if (isLinkedListImpl(listPtr));
    retVal = list_get(listPtr : header.size -1);
  endif;

  return retVal;
end-proc;


//*
// \brief Index of entry
//
// Returns the index of the passed entry or -1 if the entry could not
// be found in the list.
//
// \author Mihael Schmidt
// \date   19.12.2007
//
// \param Pointer to the list
// \param Pointer to the value
// \param Length of the value
//
// \return index of the entry or -1 if entry not in list
///
dcl-proc list_indexOf export;
  dcl-pi *N int(10);
  listPtr       pointer const;
  valuePtr      pointer const;
  valueLength   uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s i int(10) inz(-1);
  dcl-s retVal int(10) inz(-1);
  if (isLinkedListImpl(listPtr));

    entryPtr = header.firstEntry;
    dow (entryPtr <> *null);
      i += 1;

      if (valueLength = entry.length - 1 and
        memcmp(valuePtr : entry.value : valueLength) = 0); // dont include the null
        retVal = i;
        leave;
      endif;

      entryPtr = entry.nextE;
    enddo;

  endif;

  return retVal;
end-proc;


//*
// \brief Last index of entry
//
// Returns the last indes of the passed entry or -1 if the entry
// could not be found in the list.
//
// \author Mihael Schmidt
// \date   19.12.2007
//
// \param Pointer to the list
// \param Pointer to the value
// \param Length of the value
//
// \return index of the entry or -1 if entry not in list
///
dcl-proc list_lastIndexOf export;
  dcl-pi *N int(10);
    listPtr       pointer const;
    valuePtr      pointer const;
    valueLength   uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s i int(10);
  dcl-s retVal int(10) inz(-1);
  if (isLinkedListImpl(listPtr));

    entryPtr = header.lastEntry;
    i = header.size;
    dow (entryPtr <> *null);
      i -= 1;

      if (valueLength = entry.length - 1 and
        memcmp(valuePtr : entry.value : valueLength) = 0); // dont include the null
        retVal = i;
        leave;
      endif;

      entryPtr = entry.prevE;
    enddo;

  endif;

  return retVal;
end-proc;


//*
// \brief To character array
//
// Copies all entries of this list to the passed array. Entries will be
// truncated if they are too big for the array. If the array is not big
// enough, the last entries will be silently dropped.
//
// \author Mihael Schmidt
// \date   19.12.2007
//
// \param Pointer to the list
// \param Pointer to the array
// \param Element count
// \param Element length
//
///
dcl-proc list_toCharArray export;
  dcl-pi *N;
    listPtr    pointer const;
    arrayPtr   pointer const;
    count      uns(10) const;
    length     uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s i int(10);
  dcl-s arrayElemPtr pointer;
  dcl-s tmpLength int(10);
  if (isLinkedListImpl(listPtr));
    if (header.size = 0);
      return;
    endif;

    for i = 0 to header.size;
      if (count > i);
        entryPtr = getListEntryDs(listPtr : i);
        arrayElemPtr = arrayPtr + (i * length);

        if (entry.length < length);
          tmpLength = entry.length;
        else;
          tmpLength = length;
        endif;

        memcpy(arrayElemPtr : entry.value : tmpLength);

      endif;
    endfor;

  endif;
end-proc;


//*
// \brief Check for linked list implementation
//
// Checks if the pointer points to a linked list implementation.
// The linked list implementation of this service program has
// an id in the first 20 bytes of the list header.
//
// <br><br>
//
// If the pointer does not point to a list implementation an
// escape message will be sent.
//
// \author Mihael Schmidt
// \date   23.12.2007
//
// \param Pointer to the list
//
// \return *on = is linked list implementation <br>
//         *off = is no linked list implementation (escape message)
///
dcl-proc isLinkedListImpl export;
  dcl-pi *N ind;
    listPtr   pointer const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s isList ind;
  monitor;
    if (header.id = LIST_ID);
      isList = *on;
    else;
      isList = *off;
    endif;

    on-error *all;
      isList = *off;
  endmon;

  if (not isList);
    sendEscapeMessage(MSG_NO_LIST_IMPL);
  endif;

  return isList;
end-proc;


//*
// \brief Send Escape Message
//
// Sends an escape message with the specified id.
//
// \author Mihael Schmidt
// \date   23.12.2007
//
// \param Message id
///
dcl-proc sendEscapeMessage export;
  dcl-pi *N;
    id   int(10) const;
  end-pi;

  dcl-pr sendProgramMessage extpgm('QMHSNDPM');
    szMsgID               char(7) const;
    szMsgFile             char(20) const;
    szMsgData             char(6000) options(*varsize) const;
    nMsgDataLen           int(10) const;
    szMsgType             char(10) const;
    szCallStkEntry        char(10) const;
    nRelativeCallStkEntry int(10) const;
    szRtnMsgKey           char(4);
    error                 char(265) options(*varsize);
  end-pr;

  dcl-s msgData char(512);
  dcl-s msgKey char(4);
  dcl-s apiError char(265);
  if (id = MSG_NO_LIST_IMPL);
    msgData = 'The pointer does not point to a list data structure.';
  elseif (id = MSG_POSITION_OUT_OF_BOUNDS);
    msgData = 'The index points outside the list. No such element in the list.';
  elseif (id = MSG_INVALID_VALUE_TYPE);
    msgData = 'The requested type does not correspond to the list entry type.';
  endif;

  sendProgramMessage('CPF9898': 'QCPFMSG   *LIBL     ': %trimr(msgData): %len(%trimr(msgData)):
                     '*ESCAPE   ': '*': 1: msgKey: apiError);
end-proc;


//*
// \brief Get list entry data structure
//
// Returns the data structure of a list entry.
//
// \author Mihael Schmidt
// \date   23.12.2007
//
// \param Pointer to the list
// \param List position (zero-based)
//
// \return Pointer to list entry or *null
///
dcl-proc getListEntryDs export;
  dcl-pi *N pointer;
    listPtr   pointer const;
    pos       int(10) const;
  end-pi;

  dcl-s i int(10);
  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  monitor;
    if (pos < header.size / 2);
    // walk through the list from the start to the end
    entryPtr = header.firstEntry;
    for i = 0 to pos-1;
      if (entryPtr = *null);
        leave;
      endif;

      entryPtr = entry.nextE;
    endfor;

    else;
    // walk through the list from the end to the start
    entryPtr = header.lastEntry;
    for i = header.size -1 downto pos + 1;
      if (entryPtr = *null);
        leave;
      endif;

      entryPtr = entry.prevE;
    endfor;

    endif;

  on-error *all;
    entryPtr = *null;
  endmon;

  return entryPtr;
end-proc;

//*
// \brief Get list size
//
// Returns the number elements in the list.
//
// \author Mihael Schmidt
// \date   16.01.2008
//
// \param Pointer to the list
//
// \return number of elements in the list or -1 if an error occurs
///
dcl-proc list_size export;
  dcl-pi *N uns(10);
    listPtr pointer const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  if (isLinkedListImpl(listPtr));
    return header.size;
  else;
    return -1;
  endif;
end-proc;


//*
// \brief Create sublist
//
// Creates a list with copies of a part of the passed list.
//
// \author Mihael Schmidt
// \date   16.1.2008
//
// \param Pointer to the list
// \param start of the index to copy
// \param number of elements to copy
//
// \return new list
///
dcl-proc list_sublist export;
  dcl-pi *N pointer;
    listPtr      pointer const;
    startIndex   uns(10) const;
    length       uns(10) const options(*nopass);
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s newListPtr pointer;
  dcl-s i int(10);
  dcl-s endIndex int(10);
  if (isLinkedListImpl(listPtr));

    if (%parms() = 2);
      endIndex = header.size -1;
    else;
      endIndex = startIndex + length - 1;
    endif;

    if (startIndex < 0);
      return *null;
    endif;

    newListPtr = list_create();

    entryPtr = getListEntryDs(listPtr : startIndex);

    for i = startIndex to endIndex;
      if (header.size > i);
        list_add(newListPtr : entry.value : entry.length - 1);
        entryPtr = entry.nextE;
      else;
        leave;
      endif;
    endfor;

    return newListPtr;

  else;
    return *null;
  endif;
end-proc;


//*
// \brief Rotate list by n positions
//
// Rotatas items in the list by the given number.
//
// <br><br>
//
// The elements from the end will be pushed to the front.
// A rotation of one will bring the last element to the first
// position and the first element will become the second element
// (pushed one position down the list).
//
// <br><br>
//
// Only a forward rotation is possible. No negative number of
// rotations are valid.
//
// <br><br>
//
// The number of rotations may even be greater than the size of
// the list. Example: List size 4, rotation number 5 = rotation
// number 1.
//
// \author Mihael Schmidt
// \date   23.01.2008
//
// \param Pointer to the list
// \param Number positions to rotate list
///
dcl-proc list_rotate export;
  dcl-pi *N;
    listPtr     pointer const;
    rotatePos   int(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s newStartPtr pointer;
  dcl-ds newStartEntry likeds(tmpl_entry) based(newStartPtr);
  dcl-s newEndPtr pointer;
  dcl-ds newEndEntry likeds(tmpl_entry) based(newEndPtr);
  dcl-s firstPtr pointer;
  dcl-ds firstEntry likeds(tmpl_entry) based(firstPtr);
  dcl-s lastPtr pointer;
  dcl-ds lastEntry likeds(tmpl_entry) based(lastPtr);
  dcl-s absRotPos int(10);
  if (isLinkedListImpl(listPtr));
    if (header.size = 0);
      return;
    endif;

    absRotPos = %rem(rotatePos : list_size(listPtr));

    if (absRotPos > 0);
      firstPtr = header.firstEntry;
      lastPtr = header.lastEntry;

      // connect the ends of the list
      firstEntry.prevE = lastPtr;
      lastEntry.nextE = firstPtr;

      // set new start entry
      newStartPtr = getListEntryDs(listPtr :
      list_size(listPtr) - absRotPos);
      // set new end entry
      newEndPtr = newStartEntry.prevE;

      // disconnect new end and new start entry
      newEndEntry.nextE = *null;
      newStartEntry.prevE = *null;

      // update header
      header.firstEntry = newStartPtr;
      header.lastEntry = newEndPtr;
    endif;

  endif;
end-proc;


//*
// \brief Swap list items
//
//
// \author Mihael Schmidt
// \date   23.01.2008
//
// \param Pointer to the list
// \param List item to swap
// \param List item to swap
///
dcl-proc list_swap export;
  dcl-pi *N ind;
    listPtr    pointer const;
    itemPos1   uns(10) const;
    itemPos2   uns(10) const;
  end-pi;
  if (isLinkedListImpl(listPtr));
    return internal_swap(listPtr : itemPos1 : itemPos2);
  else;
    return *off;
  endif;
end-proc;


dcl-proc internal_swap export;
  dcl-pi *N ind;
    listPtr    pointer const;
    itemPos1   uns(10) const options(*omit);
    itemPos2   uns(10) const options(*omit);
    itemPtr1   pointer const options(*nopass);
    itemPtr2   pointer const options(*nopass);
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);

  dcl-s entryPtr1 pointer;
  dcl-ds entry1 likeds(tmpl_entry) based(entryPtr1);
  dcl-s entryPtr1P pointer;
  dcl-ds entry1P likeds(tmpl_entry) based(entryPtr1P);
  dcl-s entryPtr1N pointer;
  dcl-ds entry1N likeds(tmpl_entry) based(entryPtr1N);

  dcl-s entryPtr2 pointer;
  dcl-ds entry2 likeds(tmpl_entry) based(entryPtr2);
  dcl-s entryPtr2P pointer;
  dcl-ds entry2P likeds(tmpl_entry) based(entryPtr2P);
  dcl-s entryPtr2N pointer;
  dcl-ds entry2N likeds(tmpl_entry) based(entryPtr2N);

  dcl-s tmpPtr pointer;
  if (%parms() = 3);

    // check both items point to the same entry
    if (itemPos1 = itemPos2);
      return *on;
    endif;

    // check if item is out of bounds
    if (itemPos1 < 0 or
      itemPos2 < 0 or
      itemPos1 >= header.size or
      itemPos2 >= header.size);
      return *off;
    endif;

    entryPtr1 = getListEntryDs(listPtr : itemPos1);
    entryPtr2 = getListEntryDs(listPtr : itemPos2);

    elseif (%parms() = 5);
      entryPtr1 = itemPtr1;
      entryPtr2 = itemPtr2;
    else;
      return *off;
    endif;

    // check if the entries are valid
    if (entryPtr1 <> *null and entryPtr2 <> *null);
      entryPtr1P = entry1.prevE;
      entryPtr1N = entry1.nextE;
      entryPtr2P = entry2.prevE;
      entryPtr2N = entry2.nextE;


      // check if the two nodes are neighbouring nodes
      if (entry1.nextE = entryPtr2);
        entry1.nextE = entry2.nextE;
        entry2.nextE = entryPtr1;

        entry2.prevE = entry1.prevE;
        entry1.prevE = entryPtr2;

        if (entryPtr1P <> *null);
          entry1P.nextE = entryPtr2;
        endif;

        if (entryPtr2N <> *null);
          entry2N.prevE = entryPtr1;
        endif;

      elseif (entry1.prevE = entryPtr2); // neighbouring nodes (other way round)
        entry2.nextE = entry1.nextE;
        entry1.nextE = entryPtr2;

        entry1.prevE = entry2.prevE;
        entry2.prevE = entryPtr1;


        if (entryPtr1N <> *null);
          entry1N.prevE = entryPtr2;
        endif;

        if (entryPtr2P <> *null);
          entry2P.nextE = entryPtr1;
        endif;

      else; // no neighbours
        tmpPtr = entry1.nextE;
        entry1.nextE = entry2.nextE;
        entry2.nextE = tmpPtr;

        tmpPtr = entry1.prevE;
        entry1.prevE = entry2.prevE;
        entry2.prevE = tmpPtr;

        if (entryPtr1P <> *null);
          entry1P.nextE = entryPtr2;
        endif;

        if (entryPtr1N <> *null);
          entry1N.prevE = entryPtr2;
        endif;

        if (entryPtr2P <> *null);
          entry2P.nextE = entryPtr1;
        endif;

        if (entryPtr2N <> *null);
          entry2N.prevE = entryPtr1;
        endif;

    endif;


    if (entry1.prevE = *null);         // check if it is the first item
      header.firstEntry = entryPtr1;
    endif;

    if (entry2.prevE = *null);         // check if it is the first item
      header.firstEntry = entryPtr2;
    endif;

    if (entry1.nextE = *null);         // check if it is the last item
      header.lastEntry = entryPtr1;
    endif;

    if (entry2.nextE = *null);         // check if it is the last item
      header.lastEntry = entryPtr2;
    endif;

    return *on;
  else;
    return *off;
  endif;

end-proc;


//*
// \brief Execute procedure for every list item
//
// The passed procedure will be executed for every item
// in the list.
//
// <br><br>
//
// The user can pass data through a pointer to the procedure.
// The pointer will not be touched by this procedure itself, so it
// can be *null.
//
// <br><br>
//
// The value of list entry can be changed through the passed procedure
// but not the size of the entry/allocated memory.
//
// \author Mihael Schmidt
// \date   23.01.2008
//
// \param Pointer to the list
// \param Procedure pointer
// \param Pointer to user data (optional)
///
dcl-proc list_foreach export;
  dcl-pi *N;
    listPtr    pointer const;
    procPtr    pointer(*proc) const;
    userData   pointer const options(*nopass);
  end-pi;

  dcl-pr foreachProc extproc(procPtr);
    valuePtr pointer const;
    userData pointer const options(*nopass);
  end-pr;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s ptr pointer;
  dcl-ds entry likeds(tmpl_entry) based(ptr);
  dcl-s userDataPassed ind;
  userDataPassed = (%parms() = 3);

  if (isLinkedListImpl(listPtr));
    ptr = header.firstEntry;
    dow (ptr <> *null);

      if (userDataPassed);
        foreachProc(entry.value : userData);
      else;
        foreachProc(entry.value);
      endif;

      ptr = entry.nextE;
    enddo;
  endif;
end-proc;


//*
// \brief Return character representation of list
//
// Returns a string with the list items separated either by
// the passed or default separator. The items can be
// enclosed by a passed character. The maximum character length
// returned is 65535. Every character/item after that will be
// dropped silently. Items will not be trimmed for this operation.
//
// <br><br>
//
// If the third parameter is passed, the third parameter will be
// pre- and appended to the item. If the fourth parameter is also
// passed the third parameter will be prepended to the item and the
// fourth parameter will be appended to the item.
//
// \author Mihael Schmidt
// \date   08.02.2008
//
// \param Pointer to the list
// \param separator (default: ,)
// \param enclosing character (default: nothing)
// \param enclosing character at the end of item (default: nothing)
//
// \return character representation of all list items
///
dcl-proc list_toString export;
  dcl-pi *N varchar(65535);
    listPtr         pointer const;
    pSeparator      varchar(1) const  options(*omit:*nopass);
    pEnclosing      varchar(100) const  options(*nopass);
    pEnclosingEnd   varchar(100) const  options(*nopass);
  end-pi;

  dcl-s noSeparator     ind inz(*off);
  dcl-s separator       char(1) inz(',');
  dcl-s enclosingStart
  varchar(100);
  dcl-s enclosingEnd
  varchar(100);
  dcl-s valuePtr        pointer;
  dcl-s retVal          varchar(65535);
  if (isLinkedListImpl(listPtr));

    // check if separator is passed
    if (%parms() >= 2 and %addr(pSeparator) <> *null);
      noSeparator = (%len(pSeparator) = 0);
      separator = pSeparator;
    endif;

    // check if enclosing characters are passed
    if (%parms() >= 3);
      enclosingStart = pEnclosing;
      enclosingEnd = pEnclosing;
    endif;

    // check if we should use different chars for start and end of item
    if (%parms() = 4);
      enclosingEnd = pEnclosingEnd;
    endif;

    // process list items
    valuePtr = list_getNext(listPtr);
    dow (valuePtr <> *null);
      if (noSeparator);
        retVal += enclosingStart + %str(valuePtr) + enclosingEnd;
      else;
        retVal += enclosingStart + %str(valuePtr) + enclosingEnd +
        separator;
      endif;

      valuePtr = list_getNext(listPtr);
    enddo;

    // remove the last separator
    if (not noSeparator and %len(retVal) > 0);
      %len(retVal) = %len(retVal) -1;
    endif;
  endif;

  return retVal;
end-proc;


//*
// \brief Split character string
//
// The passed character string will be split into tokens by either
// a passed or the default separator. All tokens will be added to
// a new list which will be returned.
//
// <br><br>
//
// Empty (but not blank) values will be dropped silently.
//
// \author Mihael Schmidt
// \date   08.02.2008
//
// \param Character string (null-terminated)
// \param Separator (default: ;)
//
// \return Pointer to the filled list
///
dcl-proc list_split export;
  dcl-pi *N pointer opdesc;
    pString      char(65535) const options(*varsize);
    pSeparator   char(1) const options(*nopass);
  end-pi;

  dcl-s descType  int(10);
  dcl-s dataType  int(10);
  dcl-s descInfo1 int(10);
  dcl-s descInfo2 int(10);
  dcl-s length    int(10);

  dcl-s list      pointer;
  dcl-s token     pointer;
  dcl-s separator char(1) inz(';');
  dcl-s string    char(65535) inz(*blank);
  cee_getOpDescInfo(1: descType: dataType: descInfo1: descInfo2: length: *omit);
  string = %subst(pString: 1: length);

  if (%parms() = 2);
    separator = pSeparator;
  endif;

  list = list_create();

  token = getToken(string : separator);
  dow (token <> *null);
    list_add(list : token : getStringLength(token));
    token = getToken(*null : separator);
  enddo;

  return list;
end-proc;


//*
// \brief Reverse list
//
// Reverse the order of the list by simply switching the previous and
// next pointers of each element.
//
// \param Pointer to the list
///
dcl-proc list_reverse export;
  dcl-pi *N;
    listPtr   pointer const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s ptr pointer;
  dcl-ds entry likeds(tmpl_entry) based(ptr);
  dcl-s tmp pointer;
  ptr = header.lastEntry;

  dow (ptr <> *null);
    tmp = entry.prevE;
    entry.prevE = entry.nextE;
    entry.nextE = tmp;
    ptr = tmp;
  enddo;

  // update header
  tmp = header.firstEntry;
  header.firstEntry = header.lastEntry;
  header.lastEntry = tmp;
end-proc;


//*
// \brief Create a copy of a list
//
// Creates a list with copies of all elements of the list.
//
// \author Mihael Schmidt
// \date   7.4.2008
//
// \param Pointer to the list
//
// \return Pointer to te new list
///
dcl-proc list_copy export;
  dcl-pi *N pointer;
    listPtr   pointer const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s newListPtr pointer inz(*null);
  if (isLinkedListImpl(listPtr));

    newListPtr = list_create();

    entryPtr = header.firstEntry;

    dow (entryPtr <> *null);
      list_add(newListPtr : entry.value : entry.length - 1);
      entryPtr = entry.nextE;
    enddo;

    return newListPtr;

  endif;

  return newListPtr;
end-proc;


//*
// \brief Frequency of a value in the list
//
// Returns the number of times the passed value
// can be found in the list.
//
// \author Mihael Schmidt
// \date   05.04.2008
//
// \param Pointer to the list
// \param Pointer to the value
// \param Length of the value
//
// \return number of copies of passed value in the list
///
dcl-proc list_frequency export;
  dcl-pi *N uns(10);
    listPtr       pointer const;
    valuePtr      pointer const;
    valueLength   uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s count uns(10) inz(0);
  if (isLinkedListImpl(listPtr));

    entryPtr = header.firstEntry;
    dow (entryPtr <> *null);

      if (valueLength = entry.length - 1 and
        memcmp(valuePtr : entry.value : valueLength) = 0); // dont include the null
        count += 1;
      endif;

      entryPtr = entry.nextE;
    enddo;

  endif;

  return count;
end-proc;


//*
// \brief Add character list entry
//
// Adds a character entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param Character value
// \param List position for the new value (optional)
//
// \return *on = entry added the list <br>
//         *off = error
///
dcl-proc list_addString export;
  dcl-pi *N ind opdesc;
    listPtr   pointer const;
    value     char(65535) const options(*varsize);
    index     uns(10) const options(*nopass);
  end-pi;

  dcl-s descType  int(10);
  dcl-s dataType  int(10);
  dcl-s descInfo1 int(10);
  dcl-s descInfo2 int(10);
  dcl-s length    int(10);

  dcl-s string char(65535) inz(*blank);
  cee_getOpDescInfo(2: descType: dataType: descInfo1: descInfo2: length: *omit);
  string = %subst(value: 1: length);

  if (%parms() = 2);
    return list_add(listPtr : %addr(string) : length);
  elseif (%parms() = 3);
    return list_add(listPtr : %addr(string) : length : index);
  else;
    return *off;
  endif;
end-proc;


//*
// \brief Add integer list entry
//
// Adds an integer entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param Integer value
// \param List position for the new value (optional)
//
// \return *on = entry added the list <br>
//         *off = error
///
dcl-proc list_addInteger export;
  dcl-pi *N ind;
    listPtr   pointer const;
    value     int(10) const;
    index     uns(10) const options(*nopass);
  end-pi;

  dcl-s integer int(10);
  integer = value;

  if (%parms() = 2);
    return list_add(listPtr: %addr(integer): 4);
  elseif (%parms() = 3);
    return list_add(listPtr: %addr(integer): 4 : index);
  else;
    return *off;
  endif;
end-proc;


//*
// \brief Add long list entry
//
// Adds a long entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param Long value
// \param List position for the new value (optional)
//
// \return *on = entry added the list <br>
//         *off = error
///
dcl-proc list_addLong export;
  dcl-pi *N ind;
    listPtr   pointer const;
    value     int(20) const;
    index     uns(10) const options(*nopass);
  end-pi;

  dcl-s local int(20);
  local = value;

  if (%parms() = 2);
    return list_add(listPtr: %addr(local): 8);
  elseif (%parms() = 3);
    return list_add(listPtr: %addr(local): 8: index);
  else;
    return *off;
  endif;
end-proc;


//*
// \brief Add short list entry
//
// Adds a short entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param Short value
// \param List position for the new value (optional)
//
// \return *on = entry added the list <br>
//         *off = error
///
dcl-proc list_addShort export;
  dcl-pi *N ind;
    listPtr   pointer const;
    value     int(5) const;
    index     uns(10) const options(*nopass);
  end-pi;

  dcl-s local int(5);
  local = value;

  if (%parms() = 2);
    return list_add(listPtr: %addr(local): 2);
  elseif (%parms() = 3);
    return list_add(listPtr: %addr(local): 2: index);
  else;
    return *off;
  endif;
end-proc;


//*
// \brief Add float list entry
//
// Adds a float entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param Float value
// \param List position for the new value (optional)
//
// \return *on = entry added the list <br>
//         *off = error
///
dcl-proc list_addFloat export;
  dcl-pi *N ind;
    listPtr   pointer const;
    value     float(4) const;
    index     uns(10) const options(*nopass);
  end-pi;

  dcl-s local float(4);
  local = value;

  if (%parms() = 2);
    return list_add(listPtr: %addr(local): %size(local));
  elseif (%parms() = 3);
    return list_add(listPtr: %addr(local): %size(local): index);
  else;
    return *off;
  endif;
end-proc;


//*
// \brief Add double list entry
//
// Adds a double entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param Double value
// \param List position for the new value (optional)
//
// \return *on = entry added the list <br>
//         *off = error
///
dcl-proc list_addDouble export;
  dcl-pi *N ind;
    listPtr   pointer const;
    value     float(8) const;
    index     uns(10) const options(*nopass);
  end-pi;

  dcl-s local float(8);
  local = value;

  if (%parms() = 2);
    return list_add(listPtr: %addr(local): %size(local));
  elseif (%parms() = 3);
    return list_add(listPtr: %addr(local): %size(local): index);
  else;
    return *off;
  endif;
end-proc;


//*
// \brief Add boolean list entry
//
// Adds a boolean entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param Boolean value
// \param List position for the new value (optional)
//
// \return *on = entry added the list <br>
//         *off = error
///
dcl-proc list_addBoolean export;
  dcl-pi *N ind;
    listPtr   pointer const;
    value     ind const;
    index     uns(10) const options(*nopass);
  end-pi;

  dcl-s local ind;
  local = value;

  if (%parms() = 2);
    return list_add(listPtr: %addr(local): %size(local));
  elseif (%parms() = 3);
    return list_add(listPtr: %addr(local): %size(local): index);
  else;
    return *off;
  endif;
end-proc;


//*
// \brief Add packed decimal list entry
//
// Adds a packed decimal entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param Packed decimal value
// \param List position for the new value (optional)
//
// \return *on = entry added the list <br>
//         *off = error
///
dcl-proc list_addDecimal export;
  dcl-pi *N ind;
    listPtr   pointer const;
    value     packed(15:5) const;
    index     uns(10) const options(*nopass);
  end-pi;

  dcl-s local packed(15:5);
  local = value;

  if (%parms() = 2);
    return list_add(listPtr: %addr(local): %size(local));
  elseif (%parms() = 3);
    return list_add(listPtr: %addr(local): %size(local): index);
  else;
    return *off;
  endif;
end-proc;


//*
// \brief Add date list entry
//
// Adds a date entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param Date value
// \param List position for the new value (optional)
//
// \return *on = entry added the list <br>
//         *off = error
///
dcl-proc list_addDate export;
  dcl-pi *N ind;
    listPtr   pointer const;
    value     date const;
    index     uns(10) const options(*nopass);
  end-pi;

  dcl-s local date;
  local = value;

  if (%parms() = 2);
    return list_add(listPtr: %addr(local): %size(local));
  elseif (%parms() = 3);
    return list_add(listPtr: %addr(local): %size(local): index);
  else;
    return *off;
  endif;
end-proc;


//*
// \brief Get character entry
//
// Returns a character list entry specified by the passed index.
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param List position
//
// \return Character string of the specified position
///
dcl-proc list_getString export;
  dcl-pi *N char(65535);
    listPtr   pointer const;
    index     uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s temp char(65535) based(entry.value);
  dcl-s testVar char(65535);
  if (isLinkedListImpl(listPtr));
    // check if list is empty or the position is outside of the list
    if (header.size = 0);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *blank;
    elseif (index < 0 or index > header.size -1);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *blank;
    endif;

    entryPtr = getListEntryDs(listPtr : index);

    monitor;
      // test if the temp variable is filled with the right data for the type
      // by moving the data from temp to another var (testVar in this case)
      testVar = %subst(temp: 1: entry.length - 1); // subtract the appended null value
      return testVar;
    on-error *all;
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
      return *blank;
    endmon;
  endif;
end-proc;


//*
// \brief Get integer entry
//
// Returns an integer list entry specified by the passed index.
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param List position
//
// \return Integer value of the specified position
///
dcl-proc list_getInteger export;
  dcl-pi *N int(10);
    listPtr   pointer const;
    index     uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s temp int(10) based(entry.value);
  dcl-s testVar int(10);
  if (isLinkedListImpl(listPtr));
    // check if list is empty or the position is outside of the list
    if (header.size = 0);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *loval;
    elseif (index < 0 or index > header.size -1);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *loval;
    endif;

    entryPtr = getListEntryDs(listPtr : index);

    if (entry.length -1 <> 4);  // integer = 4 byte
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
    endif;

    monitor;
      // test if the temp variable is filled with the right data for the type
      // by moving the data from temp to another var (testVar in this case)
      testVar = temp;
      return testVar;
    on-error *all;
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
      return *loval;
    endmon;
  endif;
end-proc;


//*
// \brief Get short entry
//
// Returns a short list entry specified by the passed index.
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param List position
//
// \return Short value of the specified position
///
dcl-proc list_getShort export;
  dcl-pi *N int(5);
    listPtr   pointer const;
    index     uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s temp int(5) based(entry.value);
  dcl-s testVar int(5);
  if (isLinkedListImpl(listPtr));
    // check if list is empty or the position is outside of the list
    if (header.size = 0);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *loval;
    elseif (index < 0 or index > header.size -1);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *loval;
    endif;

    entryPtr = getListEntryDs(listPtr : index);

    if (entry.length -1 <> 2);  // short = 2 byte
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
    endif;

    monitor;
      // test if the temp variable is filled with the right data for the type
      // by moving the data from temp to another var (testVar in this case)
      testVar = temp;
      return testVar;
    on-error *all;
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
      return *loval;
    endmon;
  endif;
end-proc;


//*
// \brief Get long entry
//
// Returns a long list entry specified by the passed index.
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \parem Pointer to the list
// \param List position
//
// \return Long value of the specified position
///
dcl-proc list_getLong export;
  dcl-pi *N int(20);
    listPtr   pointer const;
    index     uns(10) const;
  end-pi;
  //
  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s temp int(20) based(entry.value);
  dcl-s testVar int(20);
  if (isLinkedListImpl(listPtr));
    // check if list is empty or the position is outside of the list
    if (header.size = 0);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *loval;
    elseif (index < 0 or index > header.size -1);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *loval;
    endif;

    entryPtr = getListEntryDs(listPtr : index);

    if (entry.length -1 <> 8);  // long = 8 byte
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
    endif;

    monitor;
      // test if the temp variable is filled with the right data for the type
      // by moving the data from temp to another var (testVar in this case)
      testVar = temp;
      return testVar;
    on-error *all;
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
      return *loval;
    endmon;
  endif;
end-proc;


//*?
// \brief Get float entry
//
// Returns a float list entry specified by the passed index.
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param List position
//
// \return Float value of the specified position
///
dcl-proc list_getFloat export;
  dcl-pi *N float(4);
    listPtr   pointer const;
    index     uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s temp float(4) based(entry.value);
  dcl-s testVar float(4);
  if (isLinkedListImpl(listPtr));
    // check if list is empty or the position is outside of the list
    if (header.size = 0);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *loval;
    elseif (index < 0 or index > header.size -1);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *loval;
    endif;

    entryPtr = getListEntryDs(listPtr : index);

    if (entry.length -1 <> %size(temp));
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
    endif;

    monitor;
      // test if the temp variable is filled with the right data for the type
      // by moving the data from temp to another var (testVar in this case)
      testVar = temp;
      return testVar;
    on-error *all;
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
      return *loval;
    endmon;
  endif;
end-proc;


//*
// \brief Get double entry
//
// Returns a double list entry specified by the passed index.
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param List position
//
// \return Double value of the specified position
///
dcl-proc list_getDouble export;
  dcl-pi *N float(8);
    listPtr   pointer const;
    index     uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s temp float(8) based(entry.value);
  dcl-s testVar float(8);
  if (isLinkedListImpl(listPtr));
    // check if list is empty or the position is outside of the list
    if (header.size = 0);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *loval;
    elseif (index < 0 or index > header.size -1);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *loval;
    endif;

    entryPtr = getListEntryDs(listPtr : index);

    if (entry.length -1 <> %size(temp));
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
    endif;

    monitor;
      // test if the temp variable is filled with the right data for the type
      // by moving the data from temp to another var (testVar in this case)
      testVar = temp;
      return testVar;
    on-error *all;
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
      return *loval;
    endmon;
  endif;
end-proc;


//*
// \brief Get boolean entry
//
// Returns a boolean list entry specified by the passed index.
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param List position
//
// \return Boolean value of the specified position
///
dcl-proc list_getBoolean export;
  dcl-pi *N ind;
    listPtr   pointer const;
    index     uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s temp ind based(entry.value);
  dcl-s testVar ind;
  if (isLinkedListImpl(listPtr));
    // check if list is empty or the position is outside of the list
    if (header.size = 0);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *loval;
    elseif (index < 0 or index > header.size -1);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *loval;
    endif;

    entryPtr = getListEntryDs(listPtr : index);

    if (entry.length -1 <> 1);
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
    endif;

    monitor;
      // test if the temp variable is filled with the right data for the type
      // by moving the data from temp to another var (testVar in this case)
      testVar = temp;
      return testVar;
    on-error *all;
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
      return *loval;
    endmon;
  endif;
end-proc;


//*
// \brief Get packed decimal entry
//
// Returns a packed decimal list entry specified by the passed index.
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param List position
//
// \return Packed decimal value of the specified position
///
dcl-proc list_getDecimal export;
  dcl-pi *N packed(15:5);
    listPtr   pointer const;
    index     uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s temp packed(15:5) based(entry.value);
  dcl-s testVar packed(15:5);
  if (isLinkedListImpl(listPtr));
    // check if list is empty or the position is outside of the list
    if (header.size = 0);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *loval;
    elseif (index < 0 or index > header.size -1);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *loval;
    endif;

    entryPtr = getListEntryDs(listPtr : index);

    if (entry.length -1 <> %size(temp));
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
    endif;

    monitor;
      // test if the temp variable is filled with the right data for the type
      // by moving the data from temp to another var (testVar in this case)
      testVar = temp;
      return testVar;
    on-error *all;
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
      return *loval;
    endmon;
  endif;
end-proc;


//*
// \brief Get date entry
//
// Returns a date list entry specified by the passed index.
//
// \author Mihael Schmidt
// \date   21.09.2008
//
// \param Pointer to the list
// \param List position
//
// \return Date value of the specified position
///
dcl-proc list_getDate export;
  dcl-pi *N date;
    listPtr   pointer const;
    index     uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  dcl-s temp date based(entry.value);
  dcl-s testVar date;
  if (isLinkedListImpl(listPtr));
    // check if list is empty or the position is outside of the list
    if (header.size = 0);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *loval;
    elseif (index < 0 or index > header.size -1);
      sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
      return *loval;
    endif;

    entryPtr = getListEntryDs(listPtr : index);

    if (entry.length -1 <> %size(temp));
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
    endif;

    monitor;
      // test if the temp variable is filled with the right data for the type
      // by moving the data from temp to another var (testVar in this case)
      testVar = temp;
      return testVar;
    on-error *all;
      sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
      return *loval;
    endmon;
  endif;
end-proc;


//*
// \brief Remove range of elements
//
// Removes a number of elements from the list.
//
// \param Pointer to the list
// \param Starting index
// \param Number of elements to remove
//
// \throws CPF9898 Position out of bounds
///
dcl-proc list_removeRange export;
  dcl-pi *N;
    listPtr         pointer const;
    index           uns(10) const;
    pNumberElements uns(10) const;
  end-pi;

  dcl-ds header likeds(tmpl_header) based(listPtr);
  dcl-s numberElements uns(10);
  dcl-s i uns(10);
  isLinkedListImpl(listPtr);

  // check if the start is in the range of the list
  if (index > header.size - 1);
    sendEscapeMessage(MSG_POSITION_OUT_OF_BOUNDS);
  endif;

  if (index + pNumberElements > header.size -1);
    numberElements = header.size - index;
  else;
    numberElements = pNumberElements;
  endif;

  for i = 1 to numberElements;
    list_remove(listPtr : index);
  endfor;

end-proc;

//*
// \brief Sort list
//
// Sorts the list with the passed procedure.
//
// <br>
//
// The passed procedure should have the list pointer as its
// only parameter (const) and should sort the list in-place.
//
// \param Pointer to the list
// \param Procedure pointer to the sort procedure
///
dcl-proc list_sort export;
  dcl-pi *N;
    listPtr         pointer const;
    sortAlgorithm   pointer(*proc) const;
  end-pi;

  dcl-pr sort extproc(sortAlgorithm);
    listPtr   pointer const;
  end-pr;
  if (isLinkedListImpl(listPtr));
    sort(listPtr);
  endif;
end-proc;


//*
// \brief Merge lists
//
// Merges the elements of second list with the first list. Elements which
// are already in the first list are not added by default (see third parameter).
//
// \author Mihael Schmidt
// \date   15.12.2009
//
// \param Destination list
// \param Source list
// \param Skip duplicates (default: *off)
///
dcl-proc list_merge export;
  dcl-pi *N;
    destList        pointer const;
    sourceList      pointer const;
    pSkipDuplicates ind const options(*nopass);
  end-pi;

  dcl-s skipDuplicates
  ind inz(*off);
  dcl-ds header likeds(tmpl_header) based(sourceList);
  dcl-s entryPtr pointer;
  dcl-ds entry likeds(tmpl_entry) based(entryPtr);
  if (%parms() = 3);
    skipDuplicates = pSkipDuplicates;
  endif;

  if (isLinkedListImpl(destList) and isLinkedListImpl(sourceList));

    entryPtr = header.firstEntry;
    dow (entryPtr <> *null);

      if (skipDuplicates);
        if (not list_contains(destList : entry.value : entry.length - 1));
          list_add(destList : entry.value : entry.length - 1); // dont include the null value
        endif;
      else;
        list_add(destList : entry.value : entry.length - 1); // dont include the null value
      endif;

      entryPtr = entry.nextE;
    enddo;

  endif;
end-proc;
