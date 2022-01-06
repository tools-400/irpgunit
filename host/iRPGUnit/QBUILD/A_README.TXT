--------------------------------------------
  i5 part of the RPGUnit plug-in for
  IBM Rational Developer for Power Systems
--------------------------------------------

The RPGUnit plug-in connects the IBM Rational Developer for Power Systems
with the RPGUnit, that was started by Lacton back in September 2006. It
adds a context menu item to the Remote Systems Explorer to let you run
your RPGUnit test suites directly from the explorer.

The plug-in bases on the code of the RPG Next Gen Editor that is
developed and provided by Mihael Schmidt at http://rpgnextgen.com/.

The i5 part of the plug-in uses an enhanced version of the RPGUnit plug-in
that was originally developed by Laction and continued by Cyril Clemenceau
at http://rpgunit.sourceforge.net/. Unfortunately it seems as if the project
is no longer alive. Nevertheless the original Internet pages at SourceForge
are still a good source of information.

In 2019 Mihael Schmidt and Thomas Raddatz joined iRPGUnit and ILEUnit to
iRPGUnit 3.0.

The Eclipse update site of the plug-in is at:
   https://irpgunit.sourceforge.io/eclipse/rdi8.0/

Let me know your experiences!


--------------------------------------
      Update to v3.0.0 Notice!
--------------------------------------
It is important to know that starting with v3.0.0 source member TESTCASE
has been moved from source file RPGUNIT1 to source file QINCLUDE. Currently
iRPGUnit is shipped with a proxy member in file RPGUNIT1 to ensure backward
compatibility at compile time. This proxy member will be removed after
31.12.2019 with a later version of iRPGUnit.

Ensure to refactor your test suites in time!</b>


--------------------------------------
      Installation Instructions
--------------------------------------

a) Call the A_INSTALL REXX script with:
   STRREXPRC SRCMBR(A_INSTALL) SRCFILE(RPGUNIT/QBUILD) PARM('INSTALL')

b) Optionally run the RPGUnit self tests:
   STRREXPRC SRCMBR(A_SELFTEST) SRCFILE(RPGUNIT/QBUILD) PARM('RPGUNIT')


--------------------------------------
      Creating Distribution Library
--------------------------------------

 Compile Developer Library

   STRREXPRC SRCMBR(A_INSTALL) SRCFILE(RPGUNITDVP/QBUILD)
     PARM('INSTALL RPGUNITDVP LIST')

 Create Distribution Save File

   CRTBNDCL PGM(RPGUNITDVP/A_CRTPKG) SRCFILE(RPGUNITDVP/QBUILD)
     DFTACTGRP(*NO) ACTGRP(*NEW) DBGVIEW(*LIST)

   CALL PGM(A_CRTPKG) PARM('RPGUNITDVP' 'RPGUNIT' '*NONE')
   *** Successfully create RPGUNIT library ***


--------------------------------------
              History
--------------------------------------

--------------------------

Version 4.0.0 - 05.01.2022
--------------------------
 * Compiled plug-in for RDP 9.5.1.3.
 * Added Cobol support.
 * Added parameter DLTSPLF to commands RUCRTRPG and RUCRTCBL.
 * Added test suite OPDESCT.
 * Added module JOBLOG.
 * Added module LSTSPLF.
 * Added TEMPLCBL.
 * Changed the RPGUnit view to set the background color of the result label
   to grey while executing a test suite.
 * Convert TEMPLATE to **free.
 * Convert TEMPLSQL to **free.
 * Refactored the iRPGUnit library to support Cobol.
   (assert, fail, aEqual)
 * Converted module STRINGT to **free and added procedure parseNum().
 * Fixed bug, that fail() did not create an error, when called in a monitor
   block from a deep stack entry.
 * Fixed bug, that OUTPUT(*NONE) and OUTPUT(*ERROR) incorrectly produced a
   spooled file.
 * Fixed self-test CMDRUNLOGT (related to: OUTPUT *ERROR/*NONE bug).
 * Added missing copyright footer to German help pages.
 * Changed MK' scripts to delete the spooled files after compiling an object.

Version 3.2.0 - 17.04.2020
--------------------------
 * Changed capturing of the callstack to exclude internal procedures of
   iRPGUnit such as iEqual() or fail()..

Version 3.1.0 - 18.11.2019
--------------------------
 * Added options '*SRCMBRTXT' and '*DEFAULT' to parameter TEXT of command
   RUCRTTST.
 * Changed iRPGUnit to accept 'RPGUNIT' and 'IRPGUNIT' as an marker for a
   unit test suite service program.
 * Changed default of parameter TEXT of command RUCRTTST from
   'RPGUnit - Test Case' to '*SRCMBRTXT'.
 * Changed default debug view of iRPGUnit self-tests to *ALL to better
   support code coverage.

Version 3.0.1 - 02.11.2019
--------------------------
 * Fixed runtime error 'I/O operation was applied to closed file QSYSPRT'
   when running unit tests with disabled report output.

Version 3.0.0 - 09.09.2019
--------------------------
 * Merged ILEUnit (Mihael Schmidt) with iRPGUnit.
 * Added option to create a XML stream file for capturing the result
   of a unit test, which can be read by the Jenkins build server.
 * Added option to upload the iRPGUnit product library to a named ASP device.
 * Added runtime error message to spooled file output.
 * Changed A_INSTALL from CLLE to Rexx.
 * Changed MK* from CLLE to Rexx.
 * Renamed source files to more intuitive names.
 * Bug fixes.

+==========================================================================+
|  Notice: Version 2.5 is the last version with an iRPGUnit library        |
|          compiled for V6R1. Upcoming versions will be compiled for 7.1,  |
|          when there is a need for changing the library.                  |
+==========================================================================+

Version 2.5.0 - 08.04.2019
--------------------------
 * Fixed problem of replacement variables that were not replaced by
   the substitution data.
 * Added option "Format job log entries".
 * Fixed missing name of sending program.
 * Fixed missing statement number of receiving program.
 * Added preference option for capturing job log messages.
 * Fixed problem that the "show view warning" was displayed to often.

Version 2.4.2 - 02.11.2018
--------------------------
 * Fixed compile issue when installing the utility into a different
   library (RUNRMTSVR, ticket: #1).

Version 2.4.1 - 24.11.2018
--------------------------
 * Added parameter ACTGRP to command RUCRTTST.
 * Added unit tests 'testActGrp' and 'testText'.
 * Added special value '*BLANK' to parameter 'TEXT' of command
   RUCRTTST.
 * Changed 'serializeString' to trim parameter 'text' before
   checking it for an empty string.

Version 2.3.0 - 21.09.2018
--------------------------
 * Added dialog for uploading the RPGUNIT library from the iRPGUnit
   preference page. (Button next to "Product library".)
 * Removed readme_first.txt because everything is described on
   the local update site.
 * Updated help text regarding the installation instructions.

Version 2.2.3 - 25.06.2018
--------------------------
 * Fixed CMDRUNLOGT to match the changed report layout.
 * Fixed RUACPTST to match the changed report layout.
 * Fixed rslvProc() to return procedure pointer for procedure
   names with trailing spaces.
 * Fixed RUPLUGINT1.testAllOK_4() test case.
 * Fixed  upload_savf.bat.
 * Added dummy procedure 'ET_testProc_3   ' to self-test EXTTSTT.
 * Changed name of preference page to "iRPGUnit".
 * Changed name of help manual to "iRPGUnit".


Version 2.2.2 - 08.02.2018
--------------------------
 * Improved error reporting when validating a service program or
   procedure.
 * Changed A_INSTALL to pass the TGTRLS parameter to all called
   MK* programs.


Version 2.2.1 - 14.06.2017
--------------------------
 * Changed RPGUnit view to display the number of assertions.
 * Fixed problem, that a test procedure had to start with 'test'
   in lower case. Now the case is ignored.
 * Now errors in setup/teardown procedures properly show up in RDi.
 * Added number of executed assertions to RPGUnit view.


Version 2.1.0 - 06.12.2016
--------------------------
 * Changed RUCRTTST to validate the combination *EVENTF/*TSTPGM for
   RPGLE and SQLRPGLE member types.
 * Updated copyright notice of LLIST_SORT.
 * Updated STRPREPRC header of source member TEMPLATE.
 * Added example source member TEMPLSQL.
 * Added number of assertions to RPGUnit view.


Version 2.0.0 - 29.11.2016
--------------------------
 * Changed length of message text from 256 to 1024 bytes.
 * Added unit test RUPLUGINT5.
 * Added procedure getAssertFailEvtLong() to retrieve the long
   message text.
 * Added new type definition AssertFailEvtLong_t for procedure
   getAssertFailEvtLong().
 * Fixed hard coded reference to library RPGUNIT in unit test RUCRTTSTT.
 * Fixed missing 'Export' keyword of procedure 'tearDown' of unit test 'CRTTSTT'.
 * Renamed RUN to CMDRUNSRV       (source member + module).
 * Renamed RUCRTTST to CRTTST     (source member + module).
 * Renamed RUPGMRMT to PGMRMT     (source member + module).
 * Renamed RURUNRMT to RMTRUNSRV  (source member + module).
 * Renamed RUSRCMBR to SRCMBR     (source member + module).
 * Renamed RUTAGTST to TAGTST     (source member + module).
 * Renamed MKRUNRMT to MKRMTRUN   (source member + program).
 * Renamed MKCMDRUN to MKCALLTST  (source member + program).
 * Renamed RUCRTTSTT to CRTTSTT   (source member + module).
 * Renamed RUCMDRUN to RUCALLTST  (object only, see: MKCALLTST).

The following errors are produced by units tests of version 1.10 and lower:

ASSERTT.testAssertWithFailure
   Expected '9800', but was '16800'.
   Reason: Refactoring of module ASSERT. Introduced new procedure doAssert().

ASSERTT.testAssertWithSuccess
   Expected '', but was '
   Reason: The new "assertFailEvt" (assertFailEvtLong_t) had to be mapped to the
           old "assertFailEvt" (assertFailEvt_t) structure, which properly sets
           the length bytes of "assertFailEvt_v1.msg" to x'0000'. These bytes
           had been set to x'4040' before. Procedure ASSERT.clrAssertFailEvt()
           now uses 'clear' instead of '*BLANKS' to initialize the assert fail
           event structure.

ASSERTT.testBigIntegerEquality
   Expected '', but was '
   Reason: see ASSERTT.testAssertWithSuccess

ASSERTT.testGoodByeIsNotHello
   Expected 'assert', but was 'aEqual'.
   Reason: see ASSERTT.testAssertWithFailure

ASSERTT.testHelloEqualsHello
   Expected '', but was '
   Reason: see ASSERTT.testAssertWithSuccess

ASSERTT.testTwoAndTwoEqualsFour
   Expected '', but was '
   Reason: see ASSERTT.testAssertWithSuccess

ASSERTT.testTwoAndTwoIsNotEqualToFive
   Expected 'assert', but was 'iEqual'.
   Reason: see ASSERTT.testAssertWithFailure

RUNT.test_loadTestSuite
   MCH3601 - Pointer not set for location referenced.
   Reason: Parameter srvPgm has been removed from procdure loadTestSuite().

RUNT.test_runTestProc_errorInSetup
   Expected 'E', but was 'F'.
   Reason: see ASSERTT.testAssertWithSuccess

RUNT.test_runTestProc_errorInTearDown
   Expected 'E', but was 'F'.
   Reason: see ASSERTT.testAssertWithSuccess

RUNT.test_runTestProc_errorInTest
   Expected 'E', but was 'F'.
   Reason: see ASSERTT.testAssertWithSuccess

RUNT.test_runTestProc_failureInTest
   Expected 'TEST_FAIL', but was 'fail'.
   Reason: Refactoring of module ASSERT. Introduced new procedure doFail().

RUNT.test_runTestProc_tearDownAfterErrorInSetup
   Expected 'E', but was 'F'.
   Reason: see ASSERTT.testAssertWithSuccess

RUACPTST.TESTBIGINTEGER
   Expected 'assert', but was 'iEqual'.
   Reason: see ASSERTT.testAssertWithFailure

RUACPTST.TESTCHOOSETEST
   Expected 'TEST2 (TESTPGM05', but was 'fail (RUTESTCASE'.
   Reason: Refactoring of module ASSERT. Introduced new procedure doFail().

RUACPTST.TESTFAILURES
   Expected 'assert', but was 'iEqual'.
   Reason: see ASSERTT.testAssertWithFailure

RUACPTST.TESTSTACKTRACE
   Expected 'assert', but was 'iEqual'.
   Reason: see ASSERTT.testAssertWithFailure


Version 1.10.0 - 26.01.2016
---------------------------
 * Restructured the RPGUnit utility for better maintenance.
 * Fixed self-test compile errors.


Version 1.9.1 - 06.02.2015
--------------------------
 * Enhanced the help text and described the new option that
   controls how the test suite service programs are validated.
 * Added warning message, when the user defined attribute could
   not be retrieved


Version 1.9.0 - 05.02.2015
--------------------------
 * Added preference option to select the type of validity
   checking of unit test service programs.


Version 1.8.0 - 25.01.2015
--------------------------
 * Changed the plug-in to select unit test procedures from
   the RSE tree.


Version 1.7.5 - 16.12.2014
--------------------------
 * Added message box that is displayed, when the statement
   identifier cannot be mapped to the source line number.


Version 1.7.4 - 09.12.2014
--------------------------
 * Fixed problem that the LPEX editor did not always position to
   source statement in error when opening a failed test case.


Version 1.7.3 - 26.08.2014
--------------------------
 * Fixed getCallStk() to respect the size of the call stack entry
   array.
 * Fixed runTestProc() to properly set the number of executed
   assertions per test case. (See also: RURUNRMT.fillUserSpace())
 * Changed getCallStk() to flag incomplete call stacks with
   '*INCOMPLETE' on the last call stack entry.
 * Thoroughly renamed field 'stmt' to 'specNB'.
 * Removed spaces for 'Initialize Printer' and 'Carriage Return'
   from RUWSCST.
 * Changed RUPLUGINT1 to produce a deeper call stack.
   (See: recursion of procInError())
 * Plug-in: Now passing special value *ALL instead of a null
   parameter to RUPGMRMT to execute all test cases.


Version 1.7.2 - 19.02.2014
--------------------------
 * Changed RURUNRMT to restore the library list after the test
   suite has been run. (System i)


Version 1.7.1 - 19.02.2014
--------------------------
 * Fixed RNX0100 in procedure hasSameBeginning() of module EXTTST.
   (System i)


Version 1.7.0 - 07.01.2014
--------------------------
 * Added option to do a RCLRSC at the end of the test suite.


Version 1.6.0 - 27.11.2013
--------------------------
 * Added option to open a source member from the RPGUnit view.
 * Fixed missing German internationalizations.


Version 1.5.3 - 22.11.2013
--------------------------
 * Fixed missing German tooltips of buttons of RPGUnit view.


Version 1.5.2 - 20.11.2013
--------------------------
 * Added German translation.


Version 1.5.1 - 19.11.2013
--------------------------
 * Added option to use a separate connection for running
   the unit tests. This way service entry points can be used
   for debugging unit tests.
   (See: Preferences -> RPGUnit -> Enforce new connection)


Version 1.5.0 - 17.11.2013
--------------------------
 * Added Spooled File Viewer to display the RPGUnit test report.
 * Changed RUCALLTST and plug-in to accept up to 250 procedure names.

    * ======================================================================= *
    /  Note: Please notice that you need to set your preferences again,       /
    /        because I had to change some keys. (I am still learning.)        /
    * ======================================================================= *


Version 1.4.2 - 07.11.2013
--------------------------
 * Removed invalid setting of "Bundle-RequiredExecutionEnvironment"
   of RPGUnit for WDSC 7.0.
 * Changed compiler of RPGUnit for WDSC 7.0 to original IBM J9
   compiler.


Version 1.4.1 - 06.11.2013
--------------------------
 * Added buttons "Collapse All" and "Expand All".
 * Added menue item "Remove Selected RPGUnit Test Suite".
 * Updated preferences page and added option to specify the
   product library. The product library is used to find program
   RURUNRMT, which executes the unit tests.


Version 1.4 - 31.10.2013
------------------------
 * Fixed: Now "Runs:" displays the correct number of executed test cases.
 * Changed RPGUnit view to get closer to JUnit.
 * Added: Special thank to Michael Calabro who enhanced RUCRTTST to
   compile SQLRPGLE source members.
 * Added procedure:  MsgInfo_t = getMonitoredMessage(*ON|*OFF)
     Usage:
                 monitor;
                   a = 10;
                   b = 0;     // Attempt made to divide by zero for
                   c = a / b; // fixed point operation. (MCH1211)
                   fail( 'Division by zero did not raise an error.' );
                 on-error;
                   msgInfo = getMonitoredMessage(*ON); // remove message
                 endmon;                               // from job log

                 aEqual( 'MCH1211': msgInfo.Id );


Version 1.3 - 15.08.2013
------------------------
 * Fixed errors in 'upload_src.bat'.
 * Fixed selftest unit test cases. The unit test cases had to be
   fixed because of internal changes that were required for the
   plug-in:

      Changed:     'assertFailEvt_t'.
      Changed:     Prototypes of setLogContext() and logCompMsg().
      Changed:     'ExcpMsgInfo' references 'Msg_t', now.
      Changed:     Now, handleSuccess() is called regardless of the
                   value of 'detail'. Affects: 'logIdx'.
      Changed:     Formatting of call stack entry.
      Bugfix:      Close spooled file after error (RUACPTST).
      Changed:     Prototypes of getCrtRpgModCmd() and getCrtSrvPgmCmd().
      Changed:     'TestResult_t'.

      Affected unit tests:

      ASSERTT      RUACPTST
      CMDRUNLOGT   RUCRTTSTT
      CMDRUNT      RUNT
      PGMMSGT

      New selftest unit tests:

      LIBLT        STRINGT

      New demonstration unit tests:

      RUPLUGINT1   RUPLUGINT3
      RUPLUGINT2   RUPLUGINT4


Version 1.2.2 - 12.08.2013
--------------------------
 * Replaced 'MKRPGUNIT' with 'A_INSTALL' in 'readme_first.txt'.
 * Removed unused code from plug-in.


Version 1.2.1 - 28.06.2013
--------------------------
 * Now the plug-in correctly passes parameter 'procedure' as a
   VARYING field to program RUPGMRMT.
 * Now the plug-in correctly enables/disables actions 'Rerun All
   Unit Tests' and 'Rerun Selected Unit Tests' when the view
   is opened.
 * Now the plug-in checks for job description 'RPGUNIT' when
   parameter 'LIBL' is set to '*JOBD'.
 * Ported plug-in back to WDSC 7.0.
 * Refactored plug-in as suggested in 'templates' by the original
   author and replaced 'ExcpMsgInfo_t' with 'Msg_t'.


Version 1.2.0 - 24.06.2013
--------------------------
 * Added call stack entries to the RPGUnit view, when the
   result of a test suite is displayed.


Version 1.1.2 - 21.06.2013
--------------------------
 * Compiled plug-in for RDP 8.0.


Version 1.1.1 - 21.06.2013
--------------------------
 * Added parameters LIBL and JOBD to the preferences page.
 * Removed unused program code.
 * Added parameter 'fieldName' to aEqual(), iEqual() und
   nEqual().
 * Added parameters LIBL and JOBD to RUPGMRMT and RURUNRMT.
 * Changed RURUNRMT to save and restore the library list.
 * Added utility procedures waitSeconds(), displayStatusMessage(),
   restoreStatusMessage() and clearStatusMessage().


Version 1.1.0 - 20.06.2013
--------------------------
 * Added screen shot to update site.


Version 1.0.6 - 08.06.2013
--------------------------
 * Now the character cases are correctly ignored when
   comparing the specified 'test procedure' name.
 * Added parameters LIBL and JOBD to command RUCALLTST.


Version 1.0.5 - 07.05.2013
--------------------------
 * Added parameter MODULE to command RUCRTTST.


Version 1.0.4 - 06.05.2013
--------------------------
 * First release of the 'RPGUnit Test for IBM Rational Developer
   for Power Systems 8.0' plug-in.
