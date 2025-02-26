**FREE

//
// Open Spooled File API
//

dcl-pr qspopnsp extpgm('QSPOPNSP');
  splfHdl         int(10);
  qlfJobNm        const like(qlfJobNm_t);
  intJobID        char(16) const;
  intSplfID       char(16) const;
  splfNm          char(10) const;
  splfNb          int(10) const;
  nbOfBuffers     int(10) const;
  error           char(32766) options(*varsize) noopt;
end-pr;
