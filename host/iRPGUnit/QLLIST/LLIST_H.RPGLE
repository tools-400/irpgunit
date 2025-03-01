**FREE
/if not defined(LLIST)
/define LLIST

//------------------------------------------------------------------------
//
// Copyright (c) 2007-2011 Mihael Schmidt
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


//-------------------------------------------------------------------------
// Prototypes for Linked List
//-------------------------------------------------------------------------
dcl-pr list_create pointer extproc('list_create');
end-pr;

dcl-pr list_dispose extproc('list_dispose');
  listPtr         pointer;
end-pr;

dcl-pr list_add ind extproc('list_add');
  listPtr         pointer const;
  ptrValue        pointer const;
  length          uns(10) const;
  pos             uns(10) const options(*nopass);
end-pr;

dcl-pr list_addFirst ind extproc('list_addFirst');
  listPtr         pointer;
  valuePtr        pointer const;
  length          uns(10) const;
end-pr;

dcl-pr list_addLast ind extproc('list_addLast');
  listPtr         pointer const;
  valuePtr        pointer const;
  length          uns(10) const;
end-pr;

dcl-pr list_addAll ind extproc('list_addAll');
  listPtr         pointer const;
  srcListPtr      pointer const;
end-pr;

dcl-pr list_remove ind extproc('list_remove');
  listPtr         pointer const;
  index           uns(10) const;
end-pr;

dcl-pr list_removeFirst ind extproc('list_removeFirst');
  listPtr         pointer const;
end-pr;

dcl-pr list_removeLast ind extproc('list_removeLast');
  listPtr         pointer const;
end-pr;

dcl-pr list_clear ind extproc('list_clear');
  listPtr         pointer const;
end-pr;

dcl-pr list_isEmpty ind extproc('list_isEmpty');
  listPtr         pointer const;
end-pr;

dcl-pr list_replace ind extproc('list_replace');
  listPtr         pointer const;
  ptrValue        pointer const;
  lengthValue     uns(10) const;
  index           uns(10) const;
end-pr;

dcl-pr list_get pointer extproc('list_get');
  listPtr         pointer const;
  index           uns(10) const;
end-pr;

dcl-pr list_getFirst pointer extproc('list_getFirst');
  listPtr         pointer const;
end-pr;

dcl-pr list_getLast pointer extproc('list_getLast');
  listPtr         pointer const;
end-pr;

dcl-pr list_getNext pointer extproc('list_getNext');
  listPtr         pointer const;
end-pr;

dcl-pr list_iterate pointer extproc('list_iterate');
  listPtr         pointer const;
end-pr;

dcl-pr list_getPrev pointer extproc('list_getPrev');
  listPtr         pointer const;
end-pr;

dcl-pr list_abortIteration extproc('list_abortIteration');
  listPtr         pointer const;
end-pr;

dcl-pr list_resetIteration extproc('list_resetIteration');
  listPtr         pointer const;
end-pr;

dcl-pr list_contains ind extproc('list_contains');
  listPtr         pointer const;
  valuePtr        pointer const;
  valueLength     uns(10) const;
end-pr;

dcl-pr list_indexOf int(10) extproc('list_indexOf');
  listPtr         pointer const;
  valuePtr        pointer const;
  valueLength     uns(10) const;
end-pr;

dcl-pr list_lastIndexOf int(10) extproc('list_lastIndexOf');
  listPtr         pointer const;
  valuePtr        pointer const;
  valueLength     uns(10) const;
end-pr;

dcl-pr list_toCharArray extproc('list_toCharArray');
  listPtr         pointer const;
  arrayPtr        pointer const;
  count           uns(10) const;
  length          uns(10) const;
end-pr;

dcl-pr list_size       uns(10) extproc('list_size');
  listPtr         pointer const;
end-pr;

dcl-pr list_sublist pointer extproc('list_sublist');
  listPtr         pointer const;
  startIndex      uns(10) const;
  length          uns(10) const options(*nopass);
end-pr;

dcl-pr list_rotate extproc('list_rotate');
  listPtr         pointer const;
  rotatePos       int(10) const;
end-pr;

dcl-pr list_swap ind extproc('list_swap');
  listPtr         pointer const;
  itemPos1        uns(10) const;
  itemPos2        uns(10) const;
end-pr;

dcl-pr list_foreach extproc('list_foreach');
  listPtr         pointer const;
  procPtr         pointer(*proc) const;
  userData        pointer const options(*nopass);
end-pr;

dcl-pr list_toString varchar(65535) extproc('list_toString');
  listPtr         pointer const;
  separator       varchar(1) const  options(*omit:*nopass);
  enclosing       varchar(100) const  options(*nopass);
  enclosingEnd    varchar(100) const  options(*nopass);
end-pr;

dcl-pr list_split pointer extproc('list_split') opdesc;
  string          char(65535) const options(*varsize);
  separator       char(1) const options(*nopass);
end-pr;

dcl-pr list_reverse extproc('list_reverse');
  listPtr         pointer const;
end-pr;

dcl-pr list_copy pointer extproc('list_copy');
  listPtr         pointer const;
end-pr;

dcl-pr list_frequency uns(10) extproc('list_frequency');
  listPtr         pointer const;
  valuePtr        pointer const;
  valueLength     uns(10) const;
end-pr;

dcl-pr list_addString ind extproc('list_addString') opdesc;
  listPtr         pointer const;
  value           char(65535) const options(*varsize);
  index           uns(10) const options(*nopass);
end-pr;

dcl-pr list_addInteger ind extproc('list_addInteger');
  listPtr         pointer const;
  value           int(10) const;
  index           uns(10) const options(*nopass);
end-pr;

dcl-pr list_addLong ind extproc('list_addLong');
  listPtr         pointer const;
  value           int(20) const;
  index           uns(10) const options(*nopass);
end-pr;

dcl-pr list_addShort ind extproc('list_addShort');
  listPtr         pointer const;
  value           int(5) const;
  index           uns(10) const options(*nopass);
end-pr;

dcl-pr list_addFloat ind extproc('list_addFloat');
  listPtr         pointer const;
  value           float(4) const;
  index           uns(10) const options(*nopass);
end-pr;

dcl-pr list_addDouble ind extproc('list_addDouble');
  listPtr         pointer const;
  value           float(8) const;
  index           uns(10) const options(*nopass);
end-pr;

dcl-pr list_addBoolean ind extproc('list_addBoolean');
  listPtr         pointer const;
  value           ind const;
  index           uns(10) const options(*nopass);
end-pr;

dcl-pr list_addDecimal ind extproc('list_addDecimal');
  listPtr         pointer const;
  value           packed(15:5) const;
  index           uns(10) const options(*nopass);
end-pr;

dcl-pr list_addDate ind extproc('list_addDate');
  listPtr         pointer const;
  value           date const;
  index           uns(10) const options(*nopass);
end-pr;

dcl-pr list_getString char(65535) extproc('list_getString');
  listPtr         pointer const;
  index           uns(10) const;
end-pr;

dcl-pr list_getInteger int(10) extproc('list_getInteger');
  listPtr         pointer const;
  index           uns(10) const;
end-pr;

dcl-pr list_getShort int(5) extproc('list_getShort');
  listPtr         pointer const;
  index           uns(10) const;
end-pr;

dcl-pr list_getLong
       int(20) extproc('list_getLong');
  listPtr         pointer const;
  index           uns(10) const;
end-pr;

dcl-pr list_getFloat float(4) extproc('list_getFloat');
  listPtr         pointer const;
  index           uns(10) const;
end-pr;

dcl-pr list_getDouble float(8) extproc('list_getDouble');
  listPtr         pointer const;
  index           uns(10) const;
end-pr;

dcl-pr list_getBoolean ind extproc('list_getBoolean');
  listPtr         pointer const;
  index           uns(10) const;
end-pr;

dcl-pr list_getDecimal packed(15:5) extproc('list_getDecimal');
  listPtr         pointer const;
  index           uns(10) const;
end-pr;

dcl-pr list_getDate date extproc('list_getDate');
  listPtr         pointer const;
  index           uns(10) const;
end-pr;

dcl-pr list_sort extproc('list_sort');
  listPtr         pointer const;
  sortAlgo        pointer(*proc) const;
end-pr;

dcl-pr list_removeRange extproc('list_removeRange');
  listPtr         pointer const;
  index           uns(10) const;
  numberElements  uns(10) const;
end-pr;

dcl-pr list_merge extproc('list_merge');
  destList        pointer const;
  sourceList      pointer const;
  skipDuplicates  ind options(*nopass) const;
end-pr;

/endif
