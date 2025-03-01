**FREE
/if not defined (CEEAPI)
/define CEEAPI

//-------------------------------------------------------------------------
// ILE CEE API Prototypes
//-------------------------------------------------------------------------

dcl-pr cee_getOpDescInfo extproc('CEEDOD');
  position        int(10) const;
  descType        int(10);
  dataType        int(10);
  descInfo1       int(10);
  descInfo2       int(10);
  length          int(10);
  feedback        char(12) options(*omit);
end-pr;


//-------------------------------------------------------------------------
// Date API Prototypes
//-------------------------------------------------------------------------
dcl-pr cee_getLilianDate extproc('CEEDAYS') opdesc;
  charDate        char(20) const options(*varsize);
  formatString    char(20) const options(*varsize);
  lilianDate      int(10);
  errorCode       char(32767) options(*varsize : *nopass);
end-pr;

dcl-pr cee_getDateFromLilian extproc('CEEDATE') opdesc;
  lilianDate      int(10) const;
  formatString    char(20) const options(*varsize);
  dateString      char(20) options(*varsize);
  errorCode       char(32767) options(*varsize : *nopass);
end-pr;

// CEEDYWK returns the weekday as a number between 1 and 7
//
// 1 = Sonntag    / Sunday
// 2 = Montag     / Monday
// 3 = Dienstag   / Tuesday
// 4 = Mittwoch   / Wednesday
// 5 = Donnerstag / Thursday
// 6 = Freitag    / Friday
// 7 = Samstag    / Saturday
//
// 0 = Fehler bei der Berechnung / ungltiges Datum

dcl-pr cee_getDayOfWeekNumeric extproc('CEEDYWK') opdesc;
  lilianDate      int(10) const;
  dayOfWeek       int(10);
  errorCode       char(32767) options(*varsize : *nopass);
end-pr;


//-------------------------------------------------------------------------
// Memory Management API Prototypes
//-------------------------------------------------------------------------
// Interface to the CEEGTST API (Get Heap Storage).
//  1) HeapId = Id of the heap.
//  2) Size   = Number of bytes to allocate
//  3) RetAddr= Return address of the allocated storage
//  4) *OMIT  = The feedback parameter.  Specifying *OMIT here
//              means that we will receive an exception from
//              the API if it cannot satisfy our request.
//              Since we do not monitor for it, the calling
//              procedure will receive the exception.
//-------------------------------------------------------------------------
dcl-pr cee_getStorage extproc('CEEGTST');
  heapId          int(10) const;
  size            int(10) const;
  retAddr         pointer;
  feedback        char(12) options(*omit);
end-pr;

//-------------------------------------------------------------------------
// Interface to the CEEFRST API (Free Storage).
//  1) Addr   = Address of the allocated storage to be freed
//  2) *OMIT  = The feedback parameter.  Specifying *OMIT here
//              means that we will receive an exception from
//              the API if it cannot satisfy our request.
//              Since we do not monitor for it, the calling
//              procedure will receive the exception.
//-------------------------------------------------------------------------
dcl-pr cee_freeStorage extproc('CEEFRST');
  address         pointer;
  feedback        char(12) options(*omit);
end-pr;

//-------------------------------------------------------------------------
// Interface to the CEECZST API (Reallocate Storage).
//  1) Addr   = Address of the allocated storage
//  2) Size   = New size (number of bytes) of the allocated storage
//  3) *OMIT  = The feedback parameter.  Specifying *OMIT here
//              means that we will receive an exception from
//              the API if it cannot satisfy our request.
//              Since we do not monitor for it, the calling
//              procedure will receive the exception.
//-------------------------------------------------------------------------
dcl-pr cee_reallocateStorage extproc('CEECZST');
  address         pointer;
  size            int(10) const;
  feedback        char(12) options(*omit);
end-pr;

//-------------------------------------------------------------------------
// Interface to the CEECRHP API (Create Heap).
//  1) HeapId     = Id of the heap.
//  2) InitSize   = Initial size of the heap.
//  3) Incr       = Number of bytes to increment if heap must be
//                  enlarged.
//  4) AllocStrat = Allocation strategy for this heap.  We will
//                  specify a value of 0 which allows the system
//                  to choose the optimal strategy.
//  5) *OMIT      = The feedback parameter.  Specifying *OMIT here
//                  means that we will receive an exception from
//                  the API if it cannot satisfy our request.
//                  Since we do not monitor for it, the calling
//                  procedure will receive the exception.
//-------------------------------------------------------------------------
dcl-pr cee_createHeap extproc('CEECRHP');
  heapId          int(10);
  initSize        int(10) const options(*omit);
  increment       int(10) const options(*omit);
  allocStrat      int(10) const options(*omit);
  feedback        char(12) options(*omit);
end-pr;

//-------------------------------------------------------------------------
// Interface to the CEEDSHP API (Discard Heap).
//  1) HeapId     = Id of the heap.
//  2) *OMIT      = The feedback parameter.  Specifying *OMIT here
//                  means that we will receive an exception from
//                  the API if it cannot satisfy our request.
//                  Since we do not monitor for it, the calling
//                  procedure will receive the exception.
//-------------------------------------------------------------------------
dcl-pr cee_discardHeap extproc('CEEDSHP');
  heapId          int(10);
  feedback        char(12) options(*omit);
end-pr;

/endif
