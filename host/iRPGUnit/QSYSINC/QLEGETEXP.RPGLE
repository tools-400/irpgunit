**FREE
//
// Prototype for QleGetExp API.
//
// Get export pointer.
//
// http://publib.boulder.ibm.com/iseries/v5r2/ic2924/info/apis/qlegetexp.htm
//

dcl-pr qlegetexp pointer(*proc) extproc('QleGetExp');
  actMark         int(10) const options(*omit);
  expNo           int(10) const options(*omit);
  expNmLen        int(10) const options(*omit);
  expNm           char(32767) const options(*varsize: *omit);
  pExp            pointer(*proc) options(*omit);
  expType         int(10) options(*omit);
  error           char(32767) options(*varsize: *omit) noopt;
end-pr;

// Named callable procedure.
dcl-ds qlegetexp_proc_t qualified template;
  procNm    like(procNm_t);
  procPtr   pointer(*proc);
end-ds;

