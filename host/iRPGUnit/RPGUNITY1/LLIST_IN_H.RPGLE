      *-------------------------------------------------------------------------
      * Internally used Prototypes
      *-------------------------------------------------------------------------
     D memcpy          PR                  extproc('memcpy')
     D   source                        *   value
     D   dest                          *   value
     D   length                      10U 0 value
      *
     D memcmp          PR            10I 0 extproc('memcmp')
     D   buffer1                       *   value
     D   buffer2                       *   value
     D   length                      10U 0 value
      *
     D getToken        PR              *   extproc('strtok')
     D   string                        *   value options(*string)
     D   delim                         *   value options(*string)
      *
     D getStringLength...
     D                 PR            10U 0 extproc('strlen')
     D   string                        *   value
      *
     D isLinkedListImpl...
     D                 PR              N
     D   listPtr                       *   const
      *
     D sendEscapeMessage...
     D                 PR
     D   id                          10I 0 const
      *
     D getListEntryDs...
     D                 PR              *
     D   listPtr                       *   const
     D   pos                         10I 0 const
      *
     D internal_swap   PR              N
     D   listPtr                       *   const
     D   itemPos1                    10U 0 const options(*omit)
     D   itemPos2                    10U 0 const options(*omit)
     D   itemPtr1                      *   const options(*nopass)
     D   itemPtr2                      *   const options(*nopass)


      *-------------------------------------------------------------------------
      * Variables
      *-------------------------------------------------------------------------

      *
      * If the list has only one entry, the pointer for the first and last
      * entry points to the same entry. If the list has no entries both pointers
      * has a *null value.
      *
      * <br><br>
      *
      * The field iteration has the default value of -1. It means that no
      * iteration is currently going on.
      *
      */
     D tmpl_header     DS                  qualified based(nullPointer)
     D   id                          20A
     D   size                        10U 0
     D   bytes                       10U 0
     D   firstEntry                    *
     D   lastEntry                     *
     D   iteration                   10I 0
     D   iterNextEntry...
     D                                 *
     D   iterPrevEntry...
     D                                 *
     D   heapId                      10I 0
      *
     D tmpl_entry      DS                  qualified based(nullPointer)
     D   prev                          *
     D   next                          *
     D   value                         *
     D   length                      10I 0
      *
     D hexNull         S              1A   inz(HEX_NULL)


      *-------------------------------------------------------------------------
      * Constants
      *-------------------------------------------------------------------------
     D HEX_NULL        C                   x'00'
     D LIST_ID         C                   'LIST_IMPLEMENTATION'
      *
      * Message IDs
      *
     D MSG_NO_LIST_IMPL...
     D                 C                   1
     D MSG_POSITION_OUT_OF_BOUNDS...
     D                 C                   2
     D MSG_INVALID_VALUE_TYPE...
     D                 C                   3
