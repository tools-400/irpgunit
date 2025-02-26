**FREE

// Prototype for API QWCRTVCA (Retrieve Current Attributes).

dcl-pr qwcrtvca extpgm('QWCRTVCA');
  rawAttribs      char(32766) options(*varsize);
  rawAttribsLen   int(10) const;
  fmtNm           char(8) const;
  attribCnt       int(10) const;
  attribKeys      int(10) const dim(255) options(*varsize);
  errors          char(32766) options(*varsize) noopt;
end-pr;

dcl-ds dsRtvc0100 qualified template;
  attribCnt       int(10);     // Job attribute entry count.
  attribEnts      char(32766); // Job attribute entries.
end-ds;

// Job attribute entry.
dcl-ds dsRtvc0100Ent  qualified template;
  len             int(10);
  key             int(10);
  dataType        char(1);
  *N              char(3);
  dataLen         int(10);
  data            char(32766);
end-ds;

// Attribute Keys:
// - Current User Profile
dcl-c CUR_USR_NM  0305;

// - Output Queue Name
dcl-c OUTQ_NM     1501;

