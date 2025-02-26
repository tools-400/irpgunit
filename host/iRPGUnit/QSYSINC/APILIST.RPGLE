**FREE
/if not defined (IRPGUNIT_APILIST)
/define IRPGUNIT_APILIST

// List API generic header structure (template).
dcl-ds listhdr_t  qualified template;
  filler1         char(103); // Filler
  status          char(1);   // Status (I=Incomplete,C=Complete,F=Partially Complete)
  filler2         char(12);  // Filler
  hdrOffs         int(10);   // Header Offset
  hdrSize         int(10);   // Header Size
  listOffs        int(10);   // List Offset
  listSize        int(10);   // List Size
  entCnt          int(10);   // Count of Entries in List
  entSize         int(10);   // Size of a single entry
end-ds;

/endif

