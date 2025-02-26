**FREE
/IF NOT DEFINED(MEMCPY)
/DEFINE MEMCPY

// memcpy() -- Copy Bytes
//    The behavior is undefined if copying takes place
//    between objects that overlap.
//    The memcpy() function returns a pointer to dest.
dcl-pr memcpy pointer extproc('memcpy');
  i_pDest   pointer value options(*string);
  i_pSrc    pointer value options(*string);
  i_count   uns(10) value;
end-pr;

/ENDIF
