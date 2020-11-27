      /if not defined(CEEAPI)
      /define CEEAPI

       // 12-byte CEE APIs feedback code.
     D fc_t            ds                  based(template) qualified
     D  condition_id                  4a
     D  inf_byte                      1a
     D  facility_id                   3a
     D  i_s_info                      4a

      // Get String Information (CEEGSI) API
     d CEEGSI...
     d                 pr              *   extproc('CEEGSI')
     d  i_posNbr                     10i 0 const
     d  o_dataType                   10i 0
     d  o_curLen                     10i 0
     d  o_maxLen                     10i 0
     d  o_fc                                     likeds(fc_t)

     d ceegsi_inf_t    ds                  based(template) qualified
     d  dataType                     10i 0
     d  curLen                       10i 0
     d  maxLen                       10i 0
      /endif
