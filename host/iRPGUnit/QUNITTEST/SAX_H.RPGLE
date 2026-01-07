**free
/if defined(sax_h)
/eof
/endif
/define sax_h

// ----------------------------------------------------
// 1. Events discovered before the first XML element
dcl-c XML_VERSION_INFO 25;
dcl-c XML_ENCODING_DECL 10;
dcl-c XML_STANDALONE_DECL '?';
dcl-c XML_DOCTYPE_DECL '?';
dcl-c XML_START_DOCUMENT 20;

// 2. Events related to XML elements
dcl-c XML_START_ELEMENT 21;
dcl-c XML_CHARS 5;
dcl-c XML_PREDEF_REF '?';
dcl-c XML_UCS2_REF '?';
dcl-c XML_UNKNOWN_REF '?';
dcl-c XML_END_ELEMENT 13;

// 3. Events related to XML attributes
dcl-c XML_ATTR_NAME 2;
dcl-c XML_ATTR_CHARS 4;
dcl-c XML_ATTR_PREDEF_REF '?';
dcl-c XML_ATTR_UCS2_REF '?';
dcl-c XML_UNKNOWN_ATTR_REF '?';
dcl-c XML_END_ATTR 26;

// 4. Events related to XML processing instructions
dcl-c XML_PI_TARGET '?';
dcl-c XML_PI_DATA '?';

// 5. Events related to XML CDATA sections
dcl-c XML_START_CDATA '?';
// dcl-c XML_CHARS 5;
dcl-c XML_END_CDATA '?';

// 6. Other events
dcl-c XML_COMMENT '?';
dcl-c XML_EXCEPTION '?';
dcl-c XML_END_DOCUMENT 12;
// ----------------------------------------------------

dcl-c SAX_CONTINUE 0;
dcl-c SAX_ABORT 1;

dcl-c NUM_CALLBACK_HANDLERS 16;
dcl-c NUM_TESTCASES 8;
dcl-c NUM_ASSERTIONS 8;
dcl-c NUM_STACK_ENTRIES 8;
dcl-c NUM_PROPERTIES 8;
dcl-c NUM_DIAGNOSTIC_MESSAGES 4;
dcl-c NUM_ELEMENT_LINES 16;

dcl-s saxElemName_t varchar(128) template;
dcl-s saxElementText_t varchar(1024) template;
dcl-s saxElementLine_t varchar(128) template;
dcl-s saxAttrName_t varchar(64) template;
dcl-s saxAttrValue_t varchar(512) template;
dcl-s saxPath_t varchar(1024) template;
dcl-s saxMessage_t varchar(128) template;
dcl-s saxInteger_t varchar(10) template;
dcl-s saxMsgId_t varchar(7) template;
dcl-s saxProcName_t varchar(64) template;
dcl-s saxObjName_t varchar(10) template;
dcl-s saxQObjName_t varchar(32) template;
dcl-s saxOutcome_t varchar(16) template;
dcl-s saxBuffer_t varchar(2048) template;
dcl-s saxDiagnosticMessage_t varchar(64) template;

dcl-ds handler_t qualified template;
  elemName        like(saxElemName_t) inz;
  pHandler        pointer(*proc);
  pCurrentElement pointer;
end-ds;

dcl-ds saxTestSuite_t qualified template;
  isNull         ind inz(*on);
  attr_errors    like(saxInteger_t) inz;
  attr_failures  like(saxInteger_t) inz;
  attr_hostname  varchar(200) inz;
  attr_id        varchar(10) inz;
  attr_name      like(saxQObjName_t) inz;
  attr_tests     like(saxInteger_t) inz;
  properties     likeds(saxProperties_t) inz(*likeds);
  testcases likeds(saxTestCases_t) inz(*likeds);
end-ds;

dcl-ds saxTestCases_t qualified template;
  size     int(10) inz;
  testcase likeds(saxTestCase_t) dim(NUM_TESTCASES) inz(*likeds);
end-ds;

dcl-ds saxTestCase_t qualified template;
  isNull          ind inz(*on);
  attr_name       like(saxProcName_t) inz;
  attr_assertions like(saxInteger_t) inz;
  attr_classname  like(saxObjName_t) inz;
  attr_time       like(saxInteger_t) inz;
  attr_outcome    like(saxOutcome_t) inz;
  events          likeds(saxTestCaseEvents_t) inz(*likeds);
end-ds;

dcl-ds saxTestCaseEvents_t qualified template;
  size          int(10) inz;
  testCaseEvent likeds(saxAbstractTestCaseEvent_t) dim(NUM_ASSERTIONS) inz(*likeds);
end-ds;

dcl-ds saxAbstractTestCaseEvent_t qualified template;
  isNull       ind inz(*on);
  attr_name    like(saxProcName_t) inz;
  failure      likeds(saxFailureEvent_t) pos(1);
  success      likeds(saxSuccessEvent_t) pos(1);
  error        likeds(saxRuntimeErrorEvent_t) pos(1);
end-ds;

dcl-ds saxFailureEvent_t qualified template;
  isNull       ind inz(*on);
  attr_name    like(saxProcName_t) inz;
  attr_message like(saxMessage_t) inz;
  attr_line    like(saxInteger_t) inz;
  expected     likeds(saxLogValue_t) inz(*likeds);
  actual       likeds(saxLogValue_t) inz(*likeds);
  callstack    likeds(saxCallstack_t) inz(*likeds);
  elementText  like(saxElementText_t) inz;
  diagMsgs     likeds(saxDiagnosticMessages_t) inz(*likeds);
end-ds;

dcl-ds saxSuccessEvent_t qualified template;
  isNull       ind inz(*on);
  attr_name    like(saxProcName_t) inz;
  attr_line    like(saxInteger_t) inz;
  expected     likeds(saxLogValue_t) inz(*likeds);
end-ds;

dcl-ds saxRuntimeErrorEvent_t qualified template;
  isNull       ind inz(*on);
  attr_name    like(saxProcName_t) inz;
  attr_message like(saxMessage_t) inz;
  attr_type    like(saxMsgId_t) inz;
  sender       likeds(saxCallstackEntry_t) inz(*likeds);
  receiver     likeds(saxCallstackEntry_t) inz(*likeds);
  elementText  like(saxElementText_t) inz;
end-ds;

dcl-ds saxLogValue_t qualified template;
  isNull              ind inz(*on);
  attr_value          varchar(500) inz;
  attr_type           varchar(16) inz;
  attr_length         like(saxInteger_t) inz;
  attr_originalLength like(saxInteger_t) inz;
end-ds;

dcl-ds saxCallstack_t qualified template;
  size       int(10) inz;
  stackEntry likeds(saxCallstackEntry_t) dim(NUM_STACK_ENTRIES) inz(*likeds);
end-ds;

dcl-ds saxCallstackEntry_t qualified template;
  isNull         ind inz(*on);
  attr_program   like(saxObjName_t) inz;
  attr_module    like(saxObjName_t) inz;
  attr_procedure like(saxProcName_t) inz;
  attr_line      like(saxInteger_t) inz;
end-ds;

dcl-ds saxProperties_t qualified template;
  size     int(10) inz;
  property likeds(saxProperty_t) dim(NUM_PROPERTIES) inz(*likeds);
end-ds;

dcl-ds saxProperty_t qualified template;
  isNull      ind inz(*on);
  attr_key    varchar(32) inz;
  attr_value  varchar(1024) inz;
end-ds;

dcl-ds saxDiagnosticMessages_t qualified template;
  size     int(10) inz;
  message  like(saxDiagnosticMessage_t) dim(NUM_DIAGNOSTIC_MESSAGES) inz;
end-ds;

dcl-ds saxElementLines_t qualified template;
  size int(10) inz;
  line like(saxElementLine_t) dim(NUM_ELEMENT_LINES) inz;
end-ds;

///
// Initializes the SAX parser.
///
dcl-pr SAX_initialize extproc('SAX_SAX_initialize');
end-pr;

///
// Returns the value of the current XML element as an array
// of text lines.
///
dcl-pr SAX_getElementTextLines likeds(saxElementLines_t) extproc('SAX_SAX_getElementTextLines');
  elemValue like(saxElementText_t) const;
end-pr;

///
// SAX parser handler
///
dcl-pr SAX_CallbackHandler int(10) extproc('SAX_SAX_CallbackHandler');
  testsuite   likeds(saxTestSuite_t);
  event       int(10) value;
  pString     pointer value;
  stringLen   int(20) value;
  exceptionId int(10) value;
end-pr;

