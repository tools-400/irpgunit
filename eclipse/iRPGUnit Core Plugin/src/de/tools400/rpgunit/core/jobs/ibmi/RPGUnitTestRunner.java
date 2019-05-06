/*******************************************************************************
 * Copyright (c) 2013-2017 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.jobs.ibmi;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import com.ibm.as400.access.AS400;
import com.ibm.as400.access.AS400Bin4;
import com.ibm.as400.access.AS400Message;
import com.ibm.as400.access.Job;
import com.ibm.as400.access.JobLog;
import com.ibm.as400.access.MessageFile;
import com.ibm.as400.access.MessageQueue;
import com.ibm.as400.access.ObjectList;
import com.ibm.as400.access.ProgramCall;
import com.ibm.as400.access.ProgramParameter;
import com.ibm.as400.access.QSYSObjectPathName;
import com.ibm.as400.access.QueuedMessage;
import com.ibm.as400.access.UserSpace;
import com.ibm.etools.iseries.subsystems.qsys.api.IBMiConnection;
import com.ibm.etools.iseries.subsystems.qsys.commands.QSYSCommandSubSystem;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.exceptions.InvalidVersionException;
import de.tools400.rpgunit.core.handler.UnitTestException;
import de.tools400.rpgunit.core.helpers.StringHelper;
import de.tools400.rpgunit.core.model.ibmi.I5Library;
import de.tools400.rpgunit.core.model.ibmi.I5LibraryList;
import de.tools400.rpgunit.core.model.ibmi.I5Object;
import de.tools400.rpgunit.core.model.ibmi.I5ObjectName;
import de.tools400.rpgunit.core.model.ibmi.I5ServiceProgram;
import de.tools400.rpgunit.core.model.local.UnitTestCallStackEntry;
import de.tools400.rpgunit.core.model.local.UnitTestCase;
import de.tools400.rpgunit.core.model.local.UnitTestReportFile;
import de.tools400.rpgunit.core.model.local.UnitTestSuite;
import de.tools400.rpgunit.core.preferences.Preferences;

@SuppressWarnings("unused")
public class RPGUnitTestRunner extends AbstractUnitTestRunner {

    private static final String IBM_NULL = "*N"; //$NON-NLS-1$
    private static final String NEW_LINE = "\n"; //$NON-NLS-1$

    UnitTestSuite testResult = null;

    /*
     * Remote test driver: Object properties.
     */

    /**
     * User space version number 1. Introduced 22.04.2013.<br>
     * Changed because of enhancements for RPGUnit plug-in.
     */
    private static int VERSION_1 = 1;

    /**
     * User space version number 2. Introduced 10.10.2016.<br>
     * Changed exception message to varsize up to 1024 bytes.
     */
    private static int VERSION_2 = 2;

    /**
     * User space version number 3. Introduced 23.04.2017.<br>
     * Added 'tmpl_testSuite.numTestCasesRtn'.
     */
    private static int VERSION_3 = 3;

    /**
     * Name of the remote test suite driver program.
     */
    private static final String PROGRAM = "RUPGMRMT"; //$NON-NLS-1$

    /**
     * Type of the remote test suite driver program.
     */
    private static final String TYPE = "*PGM"; //$NON-NLS-1$

    /*
     * Remote test driver: Parameter list.
     */

    /**
     * Return code, 1. parameter of the test suite.
     */
    private static final int PARM_RETURN_CODE = 0;

    /**
     * User Space, 2. parameter of the test suite driver program.
     */
    private static final int PARM_USER_SPACE = 1;

    /**
     * Test suite service program, 3. parameter of the test suite driver
     * program.
     */
    private static final int PARM_SERVICE_PROGRAM = 2;

    /**
     * Name of the test case to run, 4. parameter of the test suite.
     */
    private static final int PARM_PROCEDURE_NAME = 3;

    /**
     * Order for running the test cases, 5. parameter of the test suite driver
     * program.
     */
    private static final int PARM_ORDER = 4;

    /**
     * Level of details of the test report, 6. parameter of the test suite
     * driver program.
     */
    private static final int PARM_DETAIL = 5;

    /**
     * Specifies whether a report is created, 7. parameter of the test suite
     * driver program.
     */
    private static final int PARM_OUTPUT = 6;

    /**
     * Library list for unit tests, 8. parameter of the test suite.
     */
    private static final int PARM_LIBRARY_LIST = 7;

    /**
     * Qualified name of the job description, 9. parameter of the test suite.
     */
    private static final int PARM_JOB_DESCRIPTION = 8;

    /**
     * Name of the test case to run, 10. Reclaim resources.
     */
    private static final int PARM_RECLAIM_RESOURCES = 9;

    /**
     * Number of parameters of the remote test driver program.
     */
    private static final int PARM_NUM_ENTRIES = 10;

    /*
     * User space: Properties of the user space object.
     */

    /**
     * Prefix that is used to produce a user space name.
     */
    private static final String USERSPACE_PREFIX = "RU"; //$NON-NLS-1$

    /**
     * Name of the library that contains the result user space.
     */
    private static final String USERSPACE_LIBRARY = "QTEMP"; //$NON-NLS-1$

    /**
     * Type of the result user space object.
     */
    private static final String USERSPACE_OBJ_TYPE = "USRSPC"; //$NON-NLS-1$

    /**
     * User defined attribute of the result user space.
     */
    private static final String USERSPACE_EXT_ATTRIBUTE = "RPGUNIT"; //$NON-NLS-1$

    /**
     * Public authority of the result user space.
     */
    private static final String USERSPACE_AUTHORITY = "*ALL"; //$NON-NLS-1$

    /**
     * Initial size of the result user space.
     */
    private static final int USERSPACE_INITIAL_SIZE = 524288; // 65535

    /**
     * Description of the result user space.
     */
    private static final String USERSPACE_DESCRIPTION = Messages.RPGUnit_Userspace_for_Result_of_Unit_Test;

    /**
     * Length of 'ProcNms_t.name' of member 'TEMPLATES'.
     */
    private static final int PROCNMS_T_NAME_LENGTH = 256;

    /**
     * Special value of command RUCALLTST of parameter 'Test procedure' TSTPRC.
     */
    private static final String TSTPRC_ALL = "*ALL"; //$NON-NLS-1$

    /*
     * User space: Header of test sute.
     */

    /**
     * Total length of the header of the test result in the response user space.
     */
    private static final int HEADER_LENGTH = 256;

    /**
     * Integer. Total size of the user space.
     */
    private static final int HEADER_TOTAL_LENGTH = 4;

    /**
     * Integer. Header version number.
     */
    private static final int HEADER_VERSION = 4;

    /**
     * String. Qualified name of the test suite service program.
     */
    private static final int HEADER_TEST_SUITE = 20;

    /**
     * Integer. Number of executed test cases.
     */
    private static final int HEADER_NUM_RUNS = 4;

    /**
     * Integer. Number of assertions in the test case.
     */
    private static final int HEADER_NUM_ASSERTIONS = 4;

    /**
     * Integer. Number of failed assertions.
     */
    private static final int HEADER_NUM_FAILURES = 4;

    /**
     * Integer. Number of test cases that were cancled by an *ESCAPE message.
     */
    private static final int HEADER_NUM_ERRORS = 4;

    /**
     * Integer. Offset from the start of the user space to the first test case
     * entry.
     */
    private static final int HEADER_OFFSET_TESTCASES = 4;

    /**
     * Integer. Total number of test cases of test suite.
     */
    private static final int HEADER_NUM_TESTCASES = 4;

    /**
     * String. Spooled File: Name of the iSeries System.
     */
    private static final int HEADER_SYSTEM = 10;

    /**
     * String. Spooled File: Name.
     */
    private static final int HEADER_SPLF_NAME = 10;

    /**
     * Integer. Spooled File: Number.
     */
    private static final int HEADER_SPLF_NUMBER = 4;

    /**
     * String. Job: Name.
     */
    private static final int HEADER_JOB_NAME = 10;

    /**
     * String. Job: User.
     */
    private static final int HEADER_JOB_USER = 10;

    /**
     * String. Job: Number.
     */
    private static final int HEADER_JOB_NUMBER = 6;

    /**
     * String. Source Member: File Name
     */
    private static final int HEADER_SOURCE_FILE = 10;

    /**
     * String. Source Member: Library
     */
    private static final int HEADER_SOURCE_LIBRARY = 10;

    /**
     * String. Source Member: Member Name
     */
    private static final int HEADER_SOURCE_MEMBER = 10;

    /**
     * Integer. Number of test cases returned.
     */
    private static final int HEADER_NUM_TEST_CASES_RTN = 4;

    /**
     * String. Reserved.
     */
    private static final int HEADER_RESERVED = 120;

    /*
     * User space: Test case entries.
     */

    /**
     * Total length of a test case entry in the response user space.
     */
    private static final int ENTRY_LENGTH = 384;

    /**
     * Integer. Length of the test case entry.
     */
    private static final int ENTRY_TOTAL_LENGTH = 4;

    /**
     * String. Outcome (result) of a test case in the response user space.
     */
    private static final int ENTRY_OUTCOME = 1;

    /**
     * String. Reserved.
     */
    private static final int ENTRY_RESERVED_1 = 1;

    /**
     * String. Statement number of the assertion.
     */
    private static final int ENTRY_STATEMENT_NUMBER = 10;

    /**
     * Integer. Number of assertions of a test case in the response user space.
     */
    private static final int ENTRY_ASSERTIONS = 4;

    /**
     * Integer. Number of call stack entries.
     */
    private static final int ENTRY_NUM_CALL_STACK_ENTRIES = 4;

    /**
     * Integer. Offset from the beginning of the user space to the next test
     * case entry.
     */
    private static final int ENTRY_OFFSET_NEXT = 4;

    /**
     * String. Reserved.
     */
    private static final int ENTRY_LENGTH_PROCEDURE = 2;

    /**
     * Short. Length of exception message.
     */
    private static final int ENTRY_LENGTH_EXCP_MESSAGE = 2;

    /**
     * String. Name of the test case (procedure) in the response user space.
     */
    private static final int ENTRY_PROCEDURE = 100;

    /**
     * String. Exception message of a test case that ended with an error.
     */
    private static final int ENTRY_EXCP_MESSAGE = 200;

    /**
     * Long Integer. Execution time of the test case.
     */
    private static final int ENTRY_EXCP_TIME = 8;

    /**
     * String. Reserved.
     */
    private static final int ENTRY_RESERVED_2 = 40;

    private UserSpace userSpace = null;

    /*
     * User space: Call Stack Entries
     */

    /**
     * String. Name of the program that contains the module.
     */
    private static final int CALL_STACK_PROGRAM = 10;

    /**
     * String. Name of the library that contains the program that contains the
     * module.
     */
    private static final int CALL_STACK_PROGRAM_LIB = 10;

    /**
     * String. Name of the module that contains the procedure.
     */
    private static final int CALL_STACK_MODULE = 10;

    /**
     * String. Name of the library that contains the module that contains the
     * procedure.
     */
    private static final int CALL_STACK_MODULE_LIB = 10;

    /**
     * String. Statement number.
     */
    private static final int CALL_STACK_STATEMENT_NUMBER = 10;

    /**
     * Integer. Length of the call stack entry.
     */
    private static final int CALL_STACK_LENGTH = 4;

    /**
     * Integer. Offset from the beginning of the user space to the next call
     * stack entry.
     */
    private static final int CALL_STACK_OFFSET_NEXT = 4;

    /**
     * String. Reserved.
     */
    private static final int CALL_STACK_RESERVED_1 = 8;

    /**
     * Short. Length of the procedure name.
     */
    private static final int CALL_STACK_LENGTH_PROCEDURE = 2;

    /**
     * String. Name of the procedure.
     */
    private static final int CALL_STACK_PROCEDURE = 256;

    /**
     * String. Source Member: File Name
     */
    private static final int CALL_STACK_SOURCE_FILE = 10;

    /**
     * String. Source Member: Library
     */
    private static final int CALL_STACK_SOURCE_LIBRARY = 10;

    /**
     * String. Source Member: Member Name
     */
    private static final int CALL_STACK_SOURCE_MEMBER = 10;

    /**
     * Constructor of the test suite driver program.
     * 
     * @param aConnection Connection to the i5.
     */
    public RPGUnitTestRunner(IBMiConnection aConnection) {
        super(new I5Object(PROGRAM, TYPE, new I5Library(Preferences.getInstance().getProductLibrary(), aConnection)));
        userSpace = null;
    }

    /**
     * Produces the parameter list of the remote driver program.
     * 
     * @param aServiceProgram Name of the service program (test suite).
     * @param aProcedure Name of the procedure (test case).
     * @return Parameter list of the remote test suite driver program.
     * @throws Exception
     */
    private ProgramParameter[] getParameterList(I5ServiceProgram aServiceProgram, ArrayList<String> aListOfProcedure, String[] aLibraryList)
        throws Exception {

        QSYSObjectPathName usPath = new QSYSObjectPathName(userSpace.getPath());

        ProgramParameter[] parameter = new ProgramParameter[PARM_NUM_ENTRIES];

        // Parameter 1: Return Code
        parameter[PARM_RETURN_CODE] = new ProgramParameter(ProgramParameter.PASS_BY_REFERENCE, 4);

        // Parameter 2: User space name
        parameter[PARM_USER_SPACE] = produceStringParameter(usPath.toQualifiedObjectName(), 20);

        // Parameter 3: Service program name
        parameter[PARM_SERVICE_PROGRAM] = produceStringParameter(aServiceProgram.getPathName().toQualifiedObjectName(), 20);

        // Parameter 4: Optional. Procedure name
        if (aListOfProcedure != null && aListOfProcedure.size() > 0) {
            parameter[PARM_PROCEDURE_NAME] = produceVarlenStringArrayParameter(aListOfProcedure, PROCNMS_T_NAME_LENGTH);
        } else {
            // parameter[PARM_PROCEDURE_NAME] = produceNullParameter();
            ArrayList<String> tListOfProcedure = new ArrayList<String>();
            tListOfProcedure.add(TSTPRC_ALL);
            parameter[PARM_PROCEDURE_NAME] = produceVarlenStringArrayParameter(tListOfProcedure, PROCNMS_T_NAME_LENGTH);
        }

        // Parameter 5: Order
        parameter[PARM_ORDER] = produceStringParameter(Preferences.getInstance().getRunOrder(), 10);

        // Parameter 6: Detail
        parameter[PARM_DETAIL] = produceStringParameter(Preferences.getInstance().getDetail(), 10);

        // Parameter 7: Output
        if (Preferences.getInstance().isReportDisabled()) {
            parameter[PARM_OUTPUT] = produceStringParameter(Preferences.OUTPUT_NONE, 10);
        } else {
            parameter[PARM_OUTPUT] = produceStringParameter(Preferences.getInstance().getOutput(), 10);
        }

        // Parameter 8: Library list
        parameter[PARM_LIBRARY_LIST] = produceStringArrayParameter(aLibraryList, 10);
        // TODO: remove debug code
        // System.out.println("Using library list: " + new
        // I5LibraryList(aLibraryList).toString());

        // Parameter 9: Qualified job description name
        parameter[PARM_JOB_DESCRIPTION] = producesQualifiedObjectName(Preferences.getInstance().getJobDescription());

        // Parameter 10: Reclaim resources
        parameter[PARM_RECLAIM_RESOURCES] = produceStringParameter(Preferences.getInstance().getReclaimResources(), 10);

        return parameter;
    }

    /**
     * Retrieves the return code from the parameter list of the remote test
     * suite driver program.
     * 
     * @param aProgram Remote test site driver program.
     * @return Return code that indicates the final status of the test suite.
     */
    private int getReturnCode(ProgramCall aProgram) {
        AS400Bin4 intConv = new AS400Bin4();
        int tReturnCode = intConv.toInt(aProgram.getParameterList()[PARM_RETURN_CODE].getOutputData());
        return tReturnCode;
    }

    @Override
    protected UnitTestSuite retrieveUnitTestResult(I5ServiceProgram aServiceprogram, ArrayList<String> aListOfProcedure) throws Exception {

        if (testResult != null) {
            return testResult;
        }

        testResult = new UnitTestSuite(aServiceprogram);

        // @formatter:off
        /*
         * Structure of user space:
         *  
         *   tmpl_testSuite
         *     tmpl_testCase         Array(n)
         *       tmpl_callStkEnt     Array(0..64)
         *
         * Structure of test suite header: 
         * 
         * D tmpl_testSuite  DS           256    qualified
         * D  length...                           
         * D                               10I 0          
         * D  version...                          
         * D                               10I 0          
         * D  testSuite                    20A
         * D  numberRuns...                          
         * D                               10I 0          
         * D  numberAssertions...                         
         * D                               10I 0          
         * D  numberFailures...                           
         * D                               10I 0          
         * D  numberErrors...                             
         * D                               10I 0          
         * D  offsetTestCases...                          
         * D                               10I 0          
         * D  numberTestCases...                          
         * D                               10I 0
         * D  system                       10A
         * D  splF_name                    10A  
         * D  splF_nbr                     10I 0
         * D  job_name                     10A  
         * D  job_user                     10A  
         * D  job_nbr                       6A
         * D  srcFile                      10A
         * D  srcLib                       10A
         * D  srcMbr                       10A
         * D  numTestCasesRtn...
         * D                               10I 0
         * D  reserved1                   120A
         * 
         *   Length over all: 256
         */
        // @formatter:on

        // Get total size of user space
        byte[] bytes = new byte[4];
        userSpace.read(bytes, 0);

        int tTotalSizeUserSpace = extractInt(bytes, new int[] { 0 });

        bytes = new byte[tTotalSizeUserSpace];
        userSpace.read(bytes, 0);

        int[] offset = new int[] { 0 };
        offset[0] = offset[0] + HEADER_TOTAL_LENGTH;
        int tVersion = extractInt(bytes, offset);
        if (tVersion != VERSION_1 && tVersion != VERSION_2 && tVersion != VERSION_3) {
            throw new InvalidVersionException(tVersion);
        }

        String tSrvPgm = extractString(bytes, offset, HEADER_TEST_SUITE);
        int tNumberRuns = extractInt(bytes, offset);
        int tNumberAssertions = extractInt(bytes, offset);
        int tNumberFailures = extractInt(bytes, offset);
        int tNumberErrors = extractInt(bytes, offset);
        int tOffsetTestCases = extractInt(bytes, offset);
        int tNumberTestCases = extractInt(bytes, offset);

        String tSystem = extractString(bytes, offset, HEADER_SYSTEM).trim();
        String tSplfName = extractString(bytes, offset, HEADER_SPLF_NAME).trim();
        int tSplfNumber = extractInt(bytes, offset);
        String tJobName = extractString(bytes, offset, HEADER_JOB_NAME).trim();
        String tJobUser = extractString(bytes, offset, HEADER_JOB_USER).trim();
        String tJobNumber = extractString(bytes, offset, HEADER_JOB_NUMBER).trim();

        String tSrcFile = extractString(bytes, offset, HEADER_SOURCE_FILE).trim();
        String tSrcLibrary = extractString(bytes, offset, HEADER_SOURCE_LIBRARY).trim();
        String tSrcMember = extractString(bytes, offset, HEADER_SOURCE_MEMBER).trim();

        int numTestCasesRtn;
        if (tVersion >= VERSION_3) {
            numTestCasesRtn = extractInt(bytes, offset);
        } else {
            numTestCasesRtn = tNumberRuns;
        }

        testResult.setRuns(tNumberRuns);
        testResult.setNumberTestCases(tNumberTestCases);

        testResult.getServiceProgram().setSourceFile(tSrcFile);
        testResult.getServiceProgram().setSourceLibrary(tSrcLibrary);
        testResult.getServiceProgram().setSourceMember(tSrcMember);

        if (tSplfName != null && tSplfName.trim().length() > 0) {
            UnitTestReportFile tSpooledFile = new UnitTestReportFile(aServiceprogram.getPath());
            tSpooledFile.setSystem(getConnection().getConnectionName());
            tSpooledFile.setName(tSplfName);
            tSpooledFile.setNumber(tSplfNumber);
            tSpooledFile.setJobName(tJobName);
            tSpooledFile.setJobUser(tJobUser);
            tSpooledFile.setJobNumber(tJobNumber);
            testResult.setSpooledFile(tSpooledFile);
        } else {
            testResult.setSpooledFile(null);
        }

        retrieveTestCases(bytes, tTotalSizeUserSpace, tOffsetTestCases, numTestCasesRtn, testResult, tVersion);

        assert tNumberAssertions == testResult.getNumberAssertions() : "Number of assertions does not match"; //$NON-NLS-1$
        // assert tNumberFailures == tTestSuite.getNumberFailures() :
        // "Number of failed assertions does not match";
        // assert tNumberErrors == tTestSuite.getNumberErrors() :
        // "Number of errors does not match";

        return testResult;
    }

    private void retrieveTestCases(byte[] aUserSpaceBytes, int aTotalLength, int anOffsetTestCases, int numTestCasesRtn, UnitTestSuite aTestSuite,
        int aVersion) throws Exception {

        // @formatter:off
        /* 
         * Structure of test case entry: 
         *   
         *   D tmpl_testCase   DS           384    qualified
         *   D  length                       10I 0
         *   D  result                        1A            
         *   D  reserved_1                    1A
         *   D  stmt                         10A
         *   D  numberAssertions...                         
         *   D                               10I 0
         *   D  numCallStkEnt                10I 0
         *   D  offsCallStkEnt...           
         *   D                               10I 0
         *   D  offsNext                     10I 0
         *   D  lenTestCase                   5I 0
         *   D  lenExcpMessage...                   
         *   D                                5I 0  
         *   D  testCase                    100A    
         *   D  excpMessage                 200A           (varying length up to 1024 with v2)
         *   D  execTime                     20I 0
         *   D  reserved_2                   40A           (removed with v2)
         *   
         *   Length over all: 384
         */
        // @formatter:on

        String tOutcome = null;
        String tReserved_1 = null;
        String tStatementNumber = null;
        int tAssertions = 0;
        short tLenExcpMessage = 0;
        String tExcpMessage = null;
        long tExecutionTime = 0;
        int tNumCallStkEnt = 0;
        int tOffsCallStkEnt = 0;
        int tEntryLength = 0;
        int tOffsetNext = 0;
        short tLenProcName = 0;
        String tProcedure = null;

        int[] tOffset = { anOffsetTestCases };

        Date tLastRunDate = new Date();

        for (int i = 0; i < numTestCasesRtn; i++) {
            tEntryLength = extractInt(aUserSpaceBytes, tOffset);
            tOutcome = extractString(aUserSpaceBytes, tOffset, ENTRY_OUTCOME);
            tReserved_1 = extractString(aUserSpaceBytes, tOffset, ENTRY_RESERVED_1);
            tStatementNumber = extractString(aUserSpaceBytes, tOffset, ENTRY_STATEMENT_NUMBER);
            tAssertions = extractInt(aUserSpaceBytes, tOffset);
            tNumCallStkEnt = extractInt(aUserSpaceBytes, tOffset);
            tOffsCallStkEnt = extractInt(aUserSpaceBytes, tOffset);
            tOffsetNext = extractInt(aUserSpaceBytes, tOffset);
            tLenProcName = extractShort(aUserSpaceBytes, tOffset);
            tLenExcpMessage = extractShort(aUserSpaceBytes, tOffset);
            tProcedure = extractString(aUserSpaceBytes, tOffset, ENTRY_PROCEDURE).trim();

            if (aVersion == 1) {
                tExcpMessage = extractString(aUserSpaceBytes, tOffset, ENTRY_EXCP_MESSAGE).trim();
                tExecutionTime = extractLong(aUserSpaceBytes, tOffset);
                tOffset[0] = tOffset[0] + ENTRY_RESERVED_2;
            } else {
                tExcpMessage = extractString(aUserSpaceBytes, tOffset, tLenExcpMessage).trim();
                tExecutionTime = extractLong(aUserSpaceBytes, tOffset);
            }
            UnitTestCase testCase = new UnitTestCase(tProcedure);
            testCase.setOutcome(tOutcome);
            testCase.setStatistics(tLastRunDate, tExecutionTime);
            testCase.setAssertions(tAssertions);
            testCase.setMessage(tExcpMessage);
            testCase.setStatementNumber(tStatementNumber);
            aTestSuite.addUnitTestCase(testCase);

            retrieveTestCaseCallStack(aUserSpaceBytes, tEntryLength, tOffsCallStkEnt, tNumCallStkEnt, testCase, aVersion);

            tOffset[0] = tOffsetNext;
        }
    }

    private void retrieveTestCaseCallStack(byte[] aUserSpaceBytes, int aTotalLength, int anOffsetCallStackEntries, int aNumCallStackEntries,
        UnitTestCase aTestCase, int aVersion) throws Exception {

        // @formatter:off
        /* 
         * Structure of test case entry: 
         *   
         *   D tmpl_callStkEnt...
         *   D                 DS           354    qualified
         *   D  pgmNm                        10A            
         *   D  pgmLibNm                     10a
         *   D  modNm                        10A            
         *   D  modLibNm                     10A
         *   D  specNb                       10A
         *   D  length                       10I 0            
         *   D  offsNext                     10I 0
         *   D  reserved_1                     8A
         *   D  lenProcNm                     5I 0
         *   D  procNm                      256A
         *   D  srcFile                      10A
         *   D  srcLib                       10A
         *   D  srcMbr                       10A
         *
         *   Length over all: 354
         */
        // @formatter:on

        int[] tOffset = { anOffsetCallStackEntries };

        for (int s = 0; s < aNumCallStackEntries; s++) {
            String tPgmNm = extractString(aUserSpaceBytes, tOffset, CALL_STACK_PROGRAM);
            String tPgmLibNm = extractString(aUserSpaceBytes, tOffset, CALL_STACK_PROGRAM_LIB).trim();
            String tModNm = extractString(aUserSpaceBytes, tOffset, CALL_STACK_MODULE);
            String tModLibNm = extractString(aUserSpaceBytes, tOffset, CALL_STACK_MODULE_LIB).trim();
            String tSpecNb = extractString(aUserSpaceBytes, tOffset, CALL_STACK_STATEMENT_NUMBER);
            int tLength = extractInt(aUserSpaceBytes, tOffset);
            int tOffsNext = extractInt(aUserSpaceBytes, tOffset);
            String tReserved_1 = extractString(aUserSpaceBytes, tOffset, CALL_STACK_RESERVED_1);
            short tLenProcNm = extractShort(aUserSpaceBytes, tOffset);
            String tProcNm = extractString(aUserSpaceBytes, tOffset, CALL_STACK_PROCEDURE).trim();

            String tSrcFile = extractString(aUserSpaceBytes, tOffset, CALL_STACK_SOURCE_FILE).trim();
            String tSrcLibrary = extractString(aUserSpaceBytes, tOffset, CALL_STACK_SOURCE_LIBRARY).trim();
            String tSrcMember = extractString(aUserSpaceBytes, tOffset, CALL_STACK_SOURCE_MEMBER).trim();

            UnitTestCallStackEntry tStackEntry = new UnitTestCallStackEntry(tPgmNm, tModNm, tProcNm, tSpecNb, tSrcFile, tSrcLibrary, tSrcMember);
            aTestCase.addCallStackEntry(tStackEntry);

            tOffset[0] = tOffsNext;
        }
    }

    private UserSpace createUserspace() {
        String tSeconds = String.valueOf(System.currentTimeMillis() / 1000);
        String usName = USERSPACE_PREFIX + tSeconds.substring(tSeconds.length() - 8);
        UserSpace us = null;

        try {
            us = new UserSpace(getSystem(), QSYSObjectPathName.toPath(USERSPACE_LIBRARY, usName, USERSPACE_OBJ_TYPE));
            us.setMustUseProgramCall(true);
            us.create(USERSPACE_INITIAL_SIZE, true, USERSPACE_EXT_ATTRIBUTE, (byte)0x00, USERSPACE_DESCRIPTION, USERSPACE_AUTHORITY);
        } catch (Exception e) {
            RPGUnitCorePlugin.logError("Error during userspace creation for unit test execution.", e); //$NON-NLS-1$
        }

        return us;
    }

    @Override
    protected void prepareTest(I5ServiceProgram aUnitTestServiceprogram, ArrayList<String> aListOfProcedure) throws UnitTestException {

        if (aUnitTestServiceprogram.getExecutionLibraryList().isTypeOf(I5LibraryList.TYPE_JOBD)) {

            I5ObjectName tJobDescription = getJobDescription(aUnitTestServiceprogram);
            if (!isJobDescriptionAvailable(tJobDescription)) {
                throw new UnitTestException(
                    Messages.bind(Messages.Can_not_execute_unit_test_A_B_due_to_missing_job_description_C,
                        new Object[] { aUnitTestServiceprogram.getLibrary(), aUnitTestServiceprogram.getName(), tJobDescription.toString() }),
                    UnitTestException.Type.unexpectedError);
            }
        }

        userSpace = createUserspace();
    }

    private boolean isJobDescriptionAvailable(I5ObjectName tJobDescription) {
        if (!isLibraryAvailable(tJobDescription.getLibrary())) {
            return false;
        }
        boolean tAvailable = false;
        try {
            ObjectList objects = new ObjectList(getSystem(), tJobDescription.getLibrary(), tJobDescription.getName(), "*JOBD"); //$NON-NLS-1$
            objects.load();
            tAvailable = objects.getObjects().hasMoreElements();
        } catch (Exception e) {
            RPGUnitCorePlugin.logError("Error during check for unit test case runner.", e); //$NON-NLS-1$
        }
        return tAvailable;
    }

    private boolean isLibraryAvailable(String library) {
        boolean tAvailable = false;
        try {
            ObjectList objects = new ObjectList(getSystem(), "QSYS", library, "*LIB"); //$NON-NLS-1$ //$NON-NLS-2$
            objects.load();
            tAvailable = objects.getObjects().hasMoreElements();
        } catch (Exception e) {
            RPGUnitCorePlugin.logError("Error during check for unit test case runner.", e); //$NON-NLS-1$
        }
        return tAvailable;
    }

    private I5ObjectName getJobDescription(I5ServiceProgram aUnitTestServiceprogram) {
        I5ObjectName tJobDescription = Preferences.getInstance().getJobDescription();
        if (Preferences.getInstance().useDefaultJobDescriptionForLibraryList()) {
            tJobDescription = getDefaultJobDescription(aUnitTestServiceprogram);
        }
        return tJobDescription;
    }

    private I5ObjectName getDefaultJobDescription(I5ServiceProgram aUnitTestServiceprogram) {
        return new I5ObjectName("RPGUNIT", aUnitTestServiceprogram.getLibrary().getName()); //$NON-NLS-1$
    }

    @Override
    protected int executeTest(I5ServiceProgram aServiceProgram, ArrayList<String> aListOfProcedure, String[] aLibraryList) throws Exception {

        testResult = null;

        int returnCode = 0;

        ProgramCall program = new ProgramCall(getSystem());
        program.setProgram(getPath());
        program.setParameterList(getParameterList(aServiceProgram, aListOfProcedure, aLibraryList));

        String captureJobLog = Preferences.getInstance().getCaptureJobLog();
        byte[] startingMessageKey = new byte[] { 0x00, 0x00, 0x00, 0x00 };
        if (!Preferences.DEBUG_CAPTURE_JOBLOG_OFF.equals(captureJobLog)) {
            QueuedMessage[] jobLogMessages = getJobLog(program.getServerJob(), MessageQueue.NEWEST, 1);
            if (jobLogMessages.length > 0) {
                startingMessageKey = jobLogMessages[0].getKey();
            }
        }

        if (program.run()) {
            returnCode = getReturnCode(program);
        } else {

            AS400Message[] msgList = program.getMessageList();
            StringBuilder as400ErrorMsg = new StringBuilder();
            for (int j = 0; j < msgList.length; j++) {
                as400ErrorMsg.append(msgList[j].getID() + " - " + msgList[j].getText() + " "); //$NON-NLS-1$ //$NON-NLS-2$
            }
            RPGUnitCorePlugin.logError(as400ErrorMsg.toString());
            throw new UnitTestException(
                Messages.bind(Messages.Unit_test_A_B_ended_unexpected_with_error_message, new Object[] { aServiceProgram.getLibrary(),
                    aServiceProgram.getName(), as400ErrorMsg.toString(), program.getServerJob().toString() }),
                UnitTestException.Type.unexpectedError);
        }

        if (Preferences.DEBUG_CAPTURE_JOBLOG_ALL.equals(captureJobLog)) {
            captureJobLog(program, aServiceProgram, startingMessageKey);
        } else if (Preferences.DEBUG_CAPTURE_JOBLOG_ERRORS_ON_ERROR.equals(captureJobLog)
            || Preferences.DEBUG_CAPTURE_JOBLOG_ALL_ON_ERROR.equals(captureJobLog)) {
            retrieveUnitTestResult(aServiceProgram, aListOfProcedure);
            if (testResult.isError()) {
                captureJobLog(program, aServiceProgram, startingMessageKey);
            }
        }

        return returnCode;
    }

    private void captureJobLog(ProgramCall program, I5ServiceProgram aServiceProgram, byte[] startingMessageKey) throws Exception {

        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd, HH:mm:ss"); //$NON-NLS-1$

        String now = formatter.format(new Date());
        String newJobLogEntry = Messages.bind(Messages.A_Result_of_iRPGUnit_Test_Case_B_served_by_server_job_C,
            new Object[] { now, aServiceProgram, program.getServerJob() });
        logMessage(newJobLogEntry);

        QueuedMessage[] jobLogMessages = getJobLog(program.getServerJob(), startingMessageKey, -1);

        boolean formatted = Preferences.getInstance().isFormattedJobLog();

        for (QueuedMessage jobLogMessage : jobLogMessages) {

            // Skip starting message key, because it was the last message in
            // the queue, before running the unit test
            if (java.util.Arrays.equals(startingMessageKey, jobLogMessage.getKey())) {
                continue;
            }

            if (Preferences.DEBUG_CAPTURE_JOBLOG_ERRORS_ON_ERROR.equals(Preferences.getInstance().getCaptureJobLog())) {
                if (!isError(jobLogMessage)) {
                    continue;
                }
            }

            if (formatted) {
                jobLogMessage.load(MessageFile.SUBSTITUTE_FORMATTING_CHARACTERS);
            } else {
                jobLogMessage.load(MessageFile.NO_FORMATTING);
            }

            newJobLogEntry = jobLogMessage.getID() + " (" + getMessageType(jobLogMessage) + "): " + jobLogMessage.getText(); //$NON-NLS-1$ //$NON-NLS-2$

            String messageHelp = jobLogMessage.getHelp();
            if (!StringHelper.isNullOrEmpty(messageHelp)) {
                newJobLogEntry += NEW_LINE + messageHelp;
            }

            newJobLogEntry += NEW_LINE + createProgramEntry(formatted, Messages.Sending, jobLogMessage.getFromProgram(),
                jobLogMessage.getSendingModuleName(), jobLogMessage.getSendingProcedureName(), jobLogMessage.getSendingStatementNumbers());

            newJobLogEntry += NEW_LINE + createProgramEntry(formatted, Messages.Receiving, jobLogMessage.getReceivingProgramName(),
                jobLogMessage.getReceivingModuleName(), jobLogMessage.getReceivingProcedureName(), jobLogMessage.getReceiverStatementNumbers());

            logMessage(newJobLogEntry);
        }
    }

    private boolean isError(QueuedMessage message) {

        int type = message.getType();

        if (type == QueuedMessage.ESCAPE || type == QueuedMessage.ESCAPE_NOT_HANDLED) {
            return true;
        }

        return false;
    }

    private String getMessageType(QueuedMessage message) {

        int type = message.getType();

        switch (type) {
        case QueuedMessage.COMPLETION:
            return "*COMP"; //$NON-NLS-1$
        case QueuedMessage.DIAGNOSTIC:
            return "*DIAG"; //$NON-NLS-1$
        case QueuedMessage.INFORMATIONAL:
            return "*INFO"; //$NON-NLS-1$
        case QueuedMessage.INQUIRY:
            return "*INQUIRY"; //$NON-NLS-1$
        case QueuedMessage.SENDERS_COPY:
            return "*COPY"; //$NON-NLS-1$
        case QueuedMessage.REQUEST:
        case QueuedMessage.REQUEST_WITH_PROMPTING:
            return "*REQUEST"; //$NON-NLS-1$
        case QueuedMessage.NOTIFY:
        case QueuedMessage.NOTIFY_NOT_HANDLED:
            return "*NOTIFY"; //$NON-NLS-1$
        case QueuedMessage.ESCAPE:
        case QueuedMessage.ESCAPE_NOT_HANDLED:
            return "*ESCAPE"; //$NON-NLS-1$
        case QueuedMessage.REPLY_FROM_SYSTEM_REPLY_LIST:
        case QueuedMessage.REPLY_MESSAGE_DEFAULT_USED:
        case QueuedMessage.REPLY_NOT_VALIDITY_CHECKED:
        case QueuedMessage.REPLY_SYSTEM_DEFAULT_USED:
        case QueuedMessage.REPLY_VALIDITY_CHECKED:
            return "*REPLY"; //$NON-NLS-1$

        default:
            return IBM_NULL; // $NON-NLS-1$
        }
    }

    private QueuedMessage[] getJobLog(Job serverJob, byte[] startingMessageKey, int count) throws Exception {

        AS400 system = serverJob.getSystem();
        String job = serverJob.getName();
        String user = serverJob.getUser();
        String number = serverJob.getNumber();

        JobLog jobLog = null;

        try {

            jobLog = new JobLog(system, job, user, number);
            jobLog.setListDirection(true);
            jobLog.clearAttributesToRetrieve();
            jobLog.addAttributeToRetrieve(JobLog.REPLACEMENT_DATA);
            jobLog.addAttributeToRetrieve(JobLog.MESSAGE_WITH_REPLACEMENT_DATA);
            jobLog.addAttributeToRetrieve(JobLog.MESSAGE_HELP_WITH_REPLACEMENT_DATA);
            jobLog.addAttributeToRetrieve(JobLog.SENDING_PROGRAM_NAME);
            jobLog.addAttributeToRetrieve(JobLog.SENDING_MODULE_NAME);
            jobLog.addAttributeToRetrieve(JobLog.SENDING_PROCEDURE_NAME);
            jobLog.addAttributeToRetrieve(JobLog.SENDING_STATEMENT_NUMBERS);
            jobLog.addAttributeToRetrieve(JobLog.RECEIVING_PROGRAM_NAME);
            jobLog.addAttributeToRetrieve(JobLog.RECEIVING_MODULE_NAME);
            jobLog.addAttributeToRetrieve(JobLog.RECEIVING_PROCEDURE_NAME);
            jobLog.addAttributeToRetrieve(JobLog.RECEIVING_STATEMENT_NUMBERS);
            jobLog.setStartingMessageKey(startingMessageKey);
            jobLog.load();

            QueuedMessage[] messages;

            if (count <= 0) {
                messages = jobLog.getMessages(-1, -1);
            } else {
                messages = jobLog.getMessages(jobLog.getLength() - 1, 1);
            }

            return messages;

        } catch (Throwable e) {
            e.printStackTrace();

        } finally {
            if (jobLog != null) {
                jobLog.close();
            }
        }

        return new QueuedMessage[0];
    }

    private String createProgramEntry(boolean formatted, String label, String programName, String moduleName, String procedureName,
        String[] statementNumbers) {

        // Show first available statement number
        String statement = null;
        for (int i = 0; i < statementNumbers.length; i++) {
            if (!StringHelper.isNullOrEmpty(statementNumbers[i])) {
                statement = statementNumbers[i];
                break;
            }
        }

        String message;
        if (formatted) {
            label = "   " + label;
            message = Messages.bind(Messages.A_program_B_module_C_procedure_D_statement_E_FORMATTED,
                new Object[] { label, getValueOrNull(programName), label, getValueOrNull(moduleName), label, getValueOrNull(procedureName), label,
                    getValueOrNull(statement) });
        } else {
            message = Messages.bind(Messages.A_program_B_module_C_procedure_D_statement_E_UNFORMATTED,
                new Object[] { label, getValueOrNull(programName), label, getValueOrNull(moduleName), label, getValueOrNull(procedureName), label,
                    getValueOrNull(statement) });
        }

        return message.toString();
    }

    private String getValueOrNull(String value) {

        if (StringHelper.isNullOrEmpty(value)) {
            return IBM_NULL; // $NON-NLS-1$
        }

        return value.trim();
    }

    private void logMessage(String message) {

        if (StringHelper.isNullOrEmpty(message)) {
            return;
        }

        QSYSCommandSubSystem commandSubSystem = getConnection().getCommandSubSystem();
        commandSubSystem.logExplanation(message);
    }

    @Override
    protected void cleanUpTest(I5ServiceProgram tServiceProgramName, ArrayList<String> aProcedure) {
        try {
            if (userSpace != null) {
                userSpace.delete();
            }
        } catch (Exception e) {
            // ignore exceptions
        }
    }
}
