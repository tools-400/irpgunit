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

The Eclipse update site of the plug-in is at:
   http://www.tools400.de/rpgunit/

Let me know your experiences!


--------------------------------------
      Installation Instructions
--------------------------------------

a) Compile the A_INSTALL CL program:
   CRTBNDCL   PGM(RPGUNIT/A_INSTALL) SRCFILE(RPGUNIT1)

b) Call the installation program:
   CALL       PGM(RPGUNIT/A_INSTALL) PARM('RPGUNIT')

c) Optionally delete the installation program:
   DLTPGM     PGM(RPGUNIT/A_INSTALL)

d) Optionally run the RPGUnit self tests:
   CRTBNDCL   PGM(RPGUNIT/MKUT) SRCFILE(RPGUNITT1)
   CALL       PGM(RPGUNIT/MKUT) PARM('RPGUNIT')
   DLTPGM     PGM(RPGUNIT/MKUT)


--------------------------------------
              History
--------------------------------------


Version 2.2.1 - 14.06.2017
--------------------------
New:     Now displaying the number of assertions in the result view.
Fixed:   Now errors in setup/tearDown procedures properly show up in RDi.


Version 2.1.0 - 06.12.2016
--------------------------
Changed: Changed RUCRTTST to validate the combination *EVENTF/*TSTPGM for
         RPGLE and SQLRPGLE member types. 
Changed: Updated copyright notice of LLIST_SORT.
Changed: Updated STRPREPRC header of source member TEMPLATE.
Added:   Added example source member TEMPLSQL.
Added:   Number of assertions to RPGUnit view.


Version 2.0.0 - 29.11.2016
--------------------------
Changed: Changed length of message text from 256 to 1024 bytes.
Added unit test RUPLIGINT5.
Added procedure getAssertFailEvtLong() to retrieve the long message text.
Added new type definition AssertFailEvtLong_t for procedure getAssertFailEvtLong().
Fixed hard coded reference to library RPGUNIT in unit test RUCRTTSTT.
Fixed missing 'Export' keyword of procedure 'tearDown' of unit test 'CRTTSTT'.
Renamed RUN to CMDRUNSRV       (source member + module).
Renamed RUCRTTST to CRTTST     (source member + module).
Renamed RUPGMRMT to PGMRMT     (source member + module).
Renamed RURUNRMT to RMTRUNSRV  (source member + module).
Renamed RUSRCMBR to SRCMBR     (source member + module).
Renamed RUTAGTST to TAGTST     (source member + module).
Renamed MKRUNRMT to MKRMTRUN   (source member + program).
Renamed MKCMDRUN to MKCALLTST  (source member + program).
Renamed RUCRTTSTT to CRTTSTT   (source member + module).
Renamed RUCMDRUN to RUCALLTST  (object only, see: MKCALLTST).

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
Changed: Restructured the RPGUnit utility for better maintenance.
Fixed:   Self-test compile errors.


Version 1.9.1 - 06.02.2015
--------------------------
Changed: Enhanced the help text and described the new option that
         controls how the test suite service programs are validated.
Added:   Added warning message, when the user defined attribute could
         not be retrieved


Version 1.9.0 - 05.02.2015
--------------------------
Changed: Added preference option to select the type of validity
         checking of unit test service programs.


Version 1.8.0 - 25.01.2015
--------------------------
Changed: Changed the plug-in to select unit test procedures from
         the RSE tree.


Version 1.7.5 - 16.12.2014
--------------------------
Changed: Added message box that is displayed, when the statement
         identifier can not be mapped to the source line number.


Version 1.7.4 - 09.12.2014
--------------------------
Fixed:   Fixed problem that the LPEX editor did not always position to
         source statement in error when opening a failed test case.


Version 1.7.3 - 26.08.2014
--------------------------
Fixed:   Fixed getCallStk() to respect the size of the call stack entry
         array.
Fixed:   Fixed runTestProc() to properly set the number of executed
         assertions per test case. (See also: RURUNRMT.fillUserSpace())
Changed: Changed getCallStk() to flag incomplete call stacks with
         '*INCOMPLETE' on the last call stack entry.
Changed: Thoroughly renamed field 'stmt' to 'specNB'.
Changed: Removed spaces for 'Initialize Printer' and 'Carriage Return'
         from RUWSCST.
Changed: Changed RUPLUGINT1 to produce a deeper call stack.
         (See: recursion of procInError())
Changed: Plug-in: Now passing special value *ALL instead of a null
         parameter to RUPGMRMT to execute all test cases.


Version 1.7.2 - 19.02.2014
--------------------------
Fixed:   Changed RURUNRMT to restore the library after the test
         suite has been run. (System i)


Version 1.7.1 - 19.02.2014
--------------------------
Fixed:   RNX0100 in procedure hasSameBeginning() of module EXTTST.
         (System i)


Version 1.7.0 - 07.01.2014
--------------------------
Added:   Added option to do a RCLRSC at the end of the test suite.


Version 1.6.0 - 27.11.2013
--------------------------
Added:   Option to open a source member from the RPGUnit view.
Fixed:   Fixed missing German internationalizations.


Version 1.5.3 - 22.11.2013
--------------------------
Fixed:   Fixed missing German tooltips of buttons of RPGUnit view.


Version 1.5.2 - 20.11.2013
--------------------------
Added:   German translation.


Version 1.5.1 - 19.11.2013
--------------------------
Added:   Added option to use a separate connection for running
         the unit tests. This way service entry points can be used
         for debugging unit tests.
         See: Preferences -> RPGUnit -> Enforce new conenction


Version 1.5.0 - 17.11.2013
--------------------------
Added:   Spooled File Viewer to display the RPGUnit test report.
Changed: Changed RUCALLTST and plug-in to accept up to 250 procedure names.

    * ======================================================================= *
    /  Note: Please notice that you need to set your preferences again,       /
    /        because I had to change some keys. (I am still learning.)        /
    * ======================================================================= *


Version 1.4.2 - 07.11.2013
--------------------------
Added:   Removed invalid setting of "Bundle-RequiredExecutionEnvironment"
         of RPGUnit for WDSC 7.0.
Fixed:   Changed compiler of RPGUnit for WDSC 7.0 to original IBM J9
         compiler.


Version 1.4.1 - 06.11.2013
--------------------------
Added:   New buttons "Collapse All" and "Expand All".
         New menue item "Remove Selected RPGUnit Test Suite".
         Updated preferences page and added option to specify the
         product library. The product library is used to find program
         RURUNRMT, which executes the unit tests.


Version 1.4 - 31.10.2013
------------------------
Fixed:   Now "Runs:" displays the correct number of executed test cases.
Changed: Changed RPGUnit view to get closer to JUnit.
Added:   Special thank to Michael Calabro who enhanced RUCRTTST to
         compile SQLRPGLE source members.
Added:   Procedure:  MsgInfo_t = getMonitoredMessage(*ON|*OFF)
         Usage:
                     monitor;
                       a = 10;
                       b = 0;     // Attempt made to divide by zero for
                       c = a / b; // fixed point operation. (MCH1211)
                       fail( 'Division by zero did not raise an error.' );
                     on-error;
                       msgInfo = getMonitoredMsg(*ON); // remove message
                     endmon;                           // from job log

                     aEqual( 'MCH1211': msgInfo.Id );


Version 1.3 - 15.08.2013
------------------------
Fixed:   Errors in 'upload_src.bat'.
Fixed:   Fixed selftest unit test cases. The unit test cases had to be
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
Fixed:   Replaced 'MKRPGUNIT' with 'A_INSTALL' in 'readme_first.txt'.
Changed: Removed unused code from plug-in.


Version 1.2.1 - 28.06.2013
--------------------------
Fixed:   Now the plug-in correctly passes parameter 'procedure' as a
         VARYING field to program RUPGMRMT.
Fixed:   Now the plug-in correctly enables/disables actions 'Rerun All
         Unit Tests' and 'Rerun Selected Unit Tests' when the view
         is opened.
New:     Now the plug-in checks for job description 'RPGUNIT' when
         parameter 'LIBL' is set to '*JOBD'.
New:     Ported plug-in back to WDSC 7.0.
Changed: Refactored plug-in as suggested in 'templates' by the original
         author and replaced 'ExcpMsgInfo_t' with 'Msg_t'.


Version 1.2.0 - 24.06.2013
--------------------------
New:     Added call stack entries to the RPGUnit view, when the
         result of a test suite is displayed.


Version 1.1.2 - 21.06.2013
--------------------------
Fixed:   Compiled plug-in for RDP 8.0.


Version 1.1.1 - 21.06.2013
--------------------------
Changed: Added parameters LIBL and JOBD to the preferences page.
Changed: Removed unused program code.
Changed: Added parameter 'fieldName' to aEqual(), iEqual() und
         nEqual().
New:     Added parameters LIBL and JOBD to RUPGMRMT and RURUNRMT.
         Changed RURUNRMT to save and restore the library list.
New:     Added utility procedures waitSeconds(), displayStatusMessage(),
         restoreStatusMessage() and clearStatusMessage().


Version 1.1.0 - 20.06.2013
--------------------------
Changed: Added screen shot to update site.


Version 1.0.6 - 08.06.2013
--------------------------
Fixed:   Now the character cases are correctly ignored when
         comparing the specified 'test procedure' name.
New:     Added parameters LIBL and JOBD to command RUCALLTST.


Version 1.0.5 - 07.05.2013
--------------------------
New:     Added parameter MODULE to command RUCRTTST.


Version 1.0.4 - 06.05.2013
--------------------------
New:     First release of the 'RPGUnit Test for IBM Rational Developer
         for Power Systems 8.0' plug-in.
