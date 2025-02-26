**FREE
/if not defined(CEEAPI)
/define CEEAPI

// 12-byte CEE APIs feedback code.
dcl-ds fc_t template qualified;
  condition_id    char(4);
  msgSev          int(5) overlay(condition_id: 1);
  msgNo           int(5) overlay(condition_id: 3);
  inf_byte        char(1);
  facility_id     char(3);
  i_s_info        char(4);
end-ds;

// Retrieve Operational Descriptor Information (CEEDOD) API
dcl-pr ceedod
       pointer extproc('CEEDOD');
  i_posNbr        int(10) const;
  o_descType      int(10);
  o_dataType      int(10);
  o_descInf1      int(10);
  o_descInf2      int(10);
  o_dataLen       int(10);
  o_fc            likeds(fc_t) options(*omit);
end-pr;

dcl-ds ceedod_inf_t template qualified;
  descType        int(10);
  dataType        int(10);
  descInf1        int(10);
  descInf2        int(10);
  dataLen         int(10);
end-ds;

dcl-c DOD_DESC_ESC      1;
dcl-c DOD_DESC_ELMT     2;
dcl-c DOD_DESC_ARRAY    3;
dcl-c DOD_DESC_STRUCT   4;

dcl-c DOD_TYPE_ESC      1;
dcl-c DOD_TYPE_CHAR     2;
dcl-c DOD_TYPE_CHARZ    3;
dcl-c DOD_TYPE_CHARV2   4;
dcl-c DOD_TYPE_CHARV4   5;
dcl-c DOD_TYPE_BIT      6;
dcl-c DOD_TYPE_BITV2    7;
dcl-c DOD_TYPE_BITV4    8;
dcl-c DOD_TYPE_GCHAR    9;
dcl-c DOD_TYPE_GCHARZ   10;
dcl-c DOD_TYPE_GCHARV2  11;
dcl-c DOD_TYPE_GCHARV4  12;

// Get String Information (CEEGSI) API
dcl-pr ceegsi pointer extproc('CEEGSI');
  i_posNbr     int(10) const;
  o_dataType   int(10);
  o_curLen     int(10);
  o_maxLen     int(10);
  o_fc         likeds(fc_t) options(*omit);
end-pr;

dcl-ds ceegsi_inf_t template qualified;
  dataType   int(10);
  curLen     int(10);
  maxLen     int(10);
end-ds;
/endif
