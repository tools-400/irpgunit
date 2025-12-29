**free
/if defined(sax_h)
/eof
/endif
/define sax_h

dcl-c XML_SAX_CONTINUE 0;
dcl-c XML_SAX_ABORT 1;

dcl-c NUM_CALLBACK_HANDLER 16;
dcl-c NUM_TESTCASE 8;
dcl-c NUM_ASSERTION 8;
dcl-c NUM_STACK_ENTRY 8;

dcl-s xmlName_t varchar(64) template;
dcl-s xmlPath_t varchar(1024) template;
dcl-s xmlMessage_t varchar(128) template;
dcl-s xmlInteger_t varchar(10) template;
dcl-s xmlMsgId_t varchar(7) template;
dcl-s xmlProcName_t varchar(64) template;
dcl-s xmlObjName_t varchar(10) template;
dcl-s xmlQObjName_t varchar(32) template;
dcl-s xmlOutcome_t varchar(16) template;

dcl-ds handler_t qualified template;
  element         like(xmlName_t) inz;
  pHandler        pointer(*proc);
  pCurrentElement pointer;
end-ds;

dcl-ds xmlTestSuite_t qualified template;
  isNull         ind inz(*on);
  attr_errors    like(xmlInteger_t) inz;
  attr_failures  like(xmlInteger_t) inz;
  attr_hostname  varchar(200) inz;
  attr_id        varchar(10) inz;
  attr_name      like(xmlQObjName_t) inz;
  attr_tests     like(xmlInteger_t) inz;
  testcases likeds(xmlTestCases_t) inz(*likeds);
end-ds;

dcl-ds xmlTestCases_t qualified template;
  size     int(10) inz;
  testcase likeds(xmlTestCase_t) dim(NUM_TESTCASE) inz(*likeds);
end-ds;

dcl-ds xmlTestCase_t qualified template;
  isNull          ind inz(*on);
  attr_name       like(xmlProcName_t) inz;
  attr_assertions like(xmlInteger_t) inz;
  attr_classname  like(xmlObjName_t) inz;
  attr_time       like(xmlInteger_t) inz;
  attr_outcome    like(xmlOutcome_t) inz;
  assertions      likeds(xmlAssertions_t) inz(*likeds);
end-ds;

dcl-ds xmlAssertions_t qualified template;
  size   int(10) inz;
  assertion likeds(xmlAbstractAssertion_t) dim(NUM_ASSERTION) inz(*likeds);
end-ds;

dcl-ds xmlAbstractAssertion_t qualified template;
  isNull  ind inz(*on);
  attr_name    like(xmlProcName_t) inz;
  attr_outcome like(xmlOutcome_t) inz;
  failure      likeds(xmlFailureAssertion_t) pos(1);
  success      likeds(xmlSuccessAssertion_t) pos(1);
  error        likeds(xmlErrorAssertion_t) pos(1);
end-ds;

dcl-ds xmlFailureAssertion_t qualified template;
  isNull       ind inz(*on);
  attr_name    like(xmlProcName_t) inz;
  attr_outcome like(xmlOutcome_t) inz('Failure');
  attr_message like(xmlMessage_t) inz;
  attr_line    like(xmlInteger_t) inz;
  expected     likeds(xmlLogValue_t) inz(*likeds);
  actual       likeds(xmlLogValue_t) inz(*likeds);
  callstack    likeds(xmlCallstack_t) inz(*likeds);
end-ds;

dcl-ds xmlSuccessAssertion_t qualified template;
  isNull       ind inz(*on);
  attr_name    like(xmlProcName_t) inz;
  attr_outcome like(xmlOutcome_t) inz('Success');
  attr_line    like(xmlInteger_t) inz;
  expected     likeds(xmlLogValue_t) inz(*likeds);
end-ds;

dcl-ds xmlErrorAssertion_t qualified template;
  isNull       ind inz(*on);
  attr_name    like(xmlProcName_t) inz;
  attr_outcome like(xmlOutcome_t) inz('Error');
  attr_message like(xmlMessage_t) inz;
  attr_type    like(xmlMsgId_t) inz;
  sender       likeds(xmlCallstackEntry_t) inz(*likeds);
  receiver     likeds(xmlCallstackEntry_t) inz(*likeds);
end-ds;

dcl-ds xmlLogValue_t qualified template;
  isNull              ind inz(*on);
  attr_value          varchar(500) inz;
  attr_type           varchar(16) inz;
  attr_length         like(xmlInteger_t) inz;
  attr_originalLength like(xmlInteger_t) inz;
end-ds;

dcl-ds xmlCallstack_t qualified template;
  size       int(10) inz;
  stackEntry likeds(xmlCallstackEntry_t) dim(NUM_STACK_ENTRY) inz(*likeds);
end-ds;

dcl-ds xmlCallstackEntry_t qualified template;
  isNull         ind inz(*on);
  attr_program   like(xmlObjName_t) inz;
  attr_module    like(xmlObjName_t) inz;
  attr_procedure like(xmlProcName_t) inz;
  attr_line      like(xmlInteger_t) inz;
end-ds;

///
// Initializes the SAX parser.
///
dcl-pr SAX_initialize extproc('SAX_SAX_initialize');
end-pr;

///
// SAX parser handler
///
dcl-pr SAX_CallbackHandler int(10) extproc('SAX_SAX_CallbackHandler');
  testsuite   likeds(xmlTestSuite_t);
  event       int(10) value;
  pString     pointer value;
  stringLen   int(20) value;
  exceptionId int(10) value;
end-pr;

