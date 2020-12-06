      /if not defined(CEEAPI)
      /define CEEAPI

       // 12-byte CEE APIs feedback code.
     D fc_t            ds                  based(template) qualified
     D  condition_id                  4a
     D   msgSev                       5i 0 overlay(condition_id: 1)
     D   msgNo                        5i 0 overlay(condition_id: 3)
     D  inf_byte                      1a
     D  facility_id                   3a
     D  i_s_info                      4a

      // Retrieve Operational Descriptor Information (CEEDOD) API
     d CEEDOD...
     d                 pr              *   extproc('CEEDOD')
     d  i_posNbr                     10i 0 const
     d  o_descType                   10i 0
     d  o_dataType                   10i 0
     d  o_descInf1                   10i 0
     d  o_descInf2                   10i 0
     d  o_dataLen                    10i 0
     d  o_fc                                     likeds(fc_t) options(*omit)

     d ceedod_inf_t    ds                  based(template) qualified
     d  descType                     10i 0
     d  dataType                     10i 0
     d  descInf1                     10i 0
     d  descInf2                     10i 0
     d  dataLen                      10i 0

     d DOD_DESC_ESC...
     d                 c                   1
     d DOD_DESC_ELMT...
     d                 c                   2
     d DOD_DESC_ARRAY...
     d                 c                   3
     d DOD_DESC_STRUCT...
     d                 c                   4

     d DOD_TYPE_ESC...
     d                 c                   1
     d DOD_TYPE_CHAR...
     d                 c                   2
     d DOD_TYPE_CHARZ...
     d                 c                   3
     d DOD_TYPE_CHARV2...
     d                 c                   4
     d DOD_TYPE_CHARV4...
     d                 c                   5
     d DOD_TYPE_BIT...
     d                 c                   6
     d DOD_TYPE_BITV2...
     d                 c                   7
     d DOD_TYPE_BITV4...
     d                 c                   8
     d DOD_TYPE_GCHAR...
     d                 c                   9
     d DOD_TYPE_GCHARZ...
     d                 c                   10
     d DOD_TYPE_GCHARV2...
     d                 c                   11
     d DOD_TYPE_GCHARV4...
     d                 c                   12

      // Get String Information (CEEGSI) API
     d CEEGSI...
     d                 pr              *   extproc('CEEGSI')
     d  i_posNbr                     10i 0 const
     d  o_dataType                   10i 0
     d  o_curLen                     10i 0
     d  o_maxLen                     10i 0
     d  o_fc                                     likeds(fc_t) options(*omit)

     d ceegsi_inf_t    ds                  based(template) qualified
     d  dataType                     10i 0
     d  curLen                       10i 0
     d  maxLen                       10i 0
      /endif
