       // MI procedure prototypes.

       // The following values can be OR'd for the Wait Options parameter
       // on the WAITTIME invocation.
     D cWAIT_NORMAL...
     D                 C                   0                                    x'0000'
     D cWAIT_MOD_AS_ENTER...
     D                 C                   32768                                x'8000'
     D cWAIT_MOD_AS_LEAVE...
     D                 C                   16384                                x'4000'
     D cWAIT_MPL_SET...
     D                 C                   8192                                 x'2000'
     D cWAIT_SIGNALS...
     D                 C                   4096                                 x'1000'

       // Wait On Time (WAITTIME)
     D waitTime        PR                  extproc('waittime')
     D  pmi_time                           const  like(mi_time_t)
     D  option                        5I 0 value

       // Use mitime function to form an AS/400 system value for time
     D mitime          PR              *   extproc('mitime')
     D  mi_time                            const  like(mi_time_t)
     D  hour                         10I 0 value
     D  min                          10I 0 value
     D  sec                          10I 0 value
     D  hsec                         10I 0 value

       // The standard definition for time in the MI library (QSYSINC/MIH.MICOMMON):
     D mi_time_t       S              8A   inz

