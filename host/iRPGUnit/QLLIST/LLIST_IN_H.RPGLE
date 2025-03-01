**FREE
//-------------------------------------------------------------------------
// Internally used Prototypes
//-------------------------------------------------------------------------
dcl-pr memcpy extproc('memcpy');
  source          pointer value;
  dest            pointer value;
  length          uns(10) value;
end-pr;

dcl-pr memcmp int(10) extproc('memcmp');
  buffer1         pointer value;
  buffer2         pointer value;
  length          uns(10) value;
end-pr;

dcl-pr getToken pointer extproc('strtok');
  string          pointer value options(*string);
  delim           pointer value options(*string);
end-pr;

dcl-pr getStringLength uns(10) extproc('strlen');
  string          pointer value;
end-pr;

dcl-pr isLinkedListImpl ind;
  listPtr         pointer const;
end-pr;

dcl-pr sendEscapeMessage;
  id              int(10) const;
end-pr;

dcl-pr getListEntryDs pointer;
  listPtr         pointer const;
  pos             int(10) const;
end-pr;

dcl-pr internal_swap ind;
  listPtr         pointer const;
  itemPos1        uns(10) const options(*omit);
  itemPos2        uns(10) const options(*omit);
  itemPtr1        pointer const options(*nopass);
  itemPtr2        pointer const options(*nopass);
end-pr;


//-------------------------------------------------------------------------
// Variables
//-------------------------------------------------------------------------

//
// If the list has only one entry, the pointer for the first and last
// entry points to the same entry. If the list has no entries both pointers
// has a *null value.
//
// <br><br>
//
// The field iteration has the default value of -1. It means that no
// iteration is currently going on.
//
///
dcl-ds tmpl_header qualified based(nullPointer);
  id            char(20);
  size          uns(10);
  bytes         uns(10);
  firstEntry    pointer;
  lastEntry     pointer;
  iteration     int(10);
  iterNextEntry pointer;
  iterPrevEntry pointer;
  heapId        int(10);
end-ds;

dcl-ds tmpl_entry qualified based(nullPointer);
  prevE  pointer;
  nextE  pointer;
  value  pointer;
  length int(10);
end-ds;

dcl-s hexNull char(1) inz(HEX_NULL);


//-------------------------------------------------------------------------
// Constants
//-------------------------------------------------------------------------
dcl-c HEX_NULL x'00';
dcl-c LIST_ID 'LIST_IMPLEMENTATION';

// Message IDs

dcl-c MSG_NO_LIST_IMPL           1;
dcl-c MSG_POSITION_OUT_OF_BOUNDS 2;
dcl-c MSG_INVALID_VALUE_TYPE     3;
