
       // List API generic header structure (template).
     D ListHdr_t       ds                   qualified based(template)
         // Filler
     D   filler1                    103a
         // Status (I=Incomplete,C=Complete,F=Partially Complete)
     D   status                       1a
         // Filler
     D   filler2                     12a
         // Header Offset
     D   hdrOff                      10i 0
         // Header Size
     D   hdrSize                     10i 0
         // List Offset
     D   listOff                     10i 0
         // List Size
     D   listSize                    10i 0
         // Count of Entries in List
     D   entCnt                      10i 0
         // Size of a single entry
     D   entSize                     10i 0

