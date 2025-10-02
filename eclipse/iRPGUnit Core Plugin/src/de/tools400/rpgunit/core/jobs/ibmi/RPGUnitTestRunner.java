/*******************************************************************************
 * Copyright (c) 2013-2025 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.jobs.ibmi;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

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
import de.tools400.rpgunit.core.helpers.QueuedMessageHelper;
import de.tools400.rpgunit.core.helpers.StringHelper;
import de.tools400.rpgunit.core.model.ibmi.I5Library;
import de.tools400.rpgunit.core.model.ibmi.I5LibraryList;
import de.tools400.rpgunit.core.model.ibmi.I5Object;
import de.tools400.rpgunit.core.model.ibmi.I5ObjectName;
import de.tools400.rpgunit.core.model.ibmi.I5ServiceProgram;
import de.tools400.rpgunit.core.model.local.UnitTestCallStackEntry;
import de.tools400.rpgunit.core.model.local.UnitTestCase;
import de.tools400.rpgunit.core.model.local.UnitTestMessageReceiver;
import de.tools400.rpgunit.core.model.local.UnitTestMessageSender;
import de.tools400.rpgunit.core.model.local.UnitTestReportFile;
import de.tools400.rpgunit.core.model.local.UnitTestSuite;
import de.tools400.rpgunit.core.preferences.Preferences;

@SuppressWarnings("unused")
public class RPGUnitTestRunner extends AbstractUnitTestRunner {

    private static final String NEW_LINE = "\n"; //$NON-NLS-1$

    public static final String RUNNER_OUTCOME_NOT_YET_RUN = "*";
    public static final String RUNNER_OUTCOME_CANCELED = "C";
    public static final String RUNNER_OUTCOME_SUCCESS = "S";
    public static final String RUNNER_OUTCOME_FAILED = "F";
    public static final String RUNNER_OUTCOME_ERROR = "E";

    private static final String TYPE_STMF = "*STMF";
    private static final String TYPE_MEMBER = "*MBR";

    UnitTestSuite testResult = null;

    /*
     * Remote test driver: Object properties.
     */

    /**
     * User space version number 3. Introduced 23.04.2017.<br>
     * Added 'tmpl_testSuite.numTestCasesRtn'.
     */
    private static int VERSION_3 = 3;

    /**
     * User space version number 4. Introduced 01.04.2024.<br>
     * Added message 'receiver' and program library name.
     */
    private static int VERSION_4 = 4;

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
     * Reclaim resources, 10. parameter of the test suite.
     */
    private static final int PARM_RECLAIM_RESOURCES = 9;

    /**
     * Path of the XML stream file that contains the result, 11. parameter of
     * the test suite.
     */
    private static final int PARM_XML_STMF = 10;

    /**
     * Format of the XML output, 12. parameter of the test suite.
     */
    private static final int PARM_XML_TYPE = 11;

    /**
     * Number of parameters of the remote test driver program.
     */
    private static final int PARM_NUM_ENTRIES = 12;

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
     * String type of source: *MBR | *STMF.<br>
     * Added: 15.5.2025
     */
    private static final int HEADER_TYPE_OF_SOURCE = 10;

    /**
     * Integer. Offset to the source stream file name.<br>
     * Added: 15.5.2025
     */
    private static final int HEADER_OFFSET_SOURCE_STREAM_FILE = 4;

    /**
     * Integer. Length of the source stream file name.<br>
     * Added: 15.5.2025
     */
    private static final int HEADER_LENGTH_SOURCE_STREAM_FILE = 4;

    /**
     * String. Reserved.
     */
    private static final int HEADER_RESERVED = 102;

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
     * String type of source: *MBR | *STMF.<br>
     * Added: 15.5.2025
     */
    private static final int CALL_STACK_TYPE_OF_SOURCE = 10;

    /**
     * Integer. Offset to the source stream file name.<br>
     * Added: 15.5.2025
     */
    private static final int CALL_STACK_OFFSET_SOURCE_STREAM_FILE = 4;

    /**
     * Integer. Length of the source stream file name.<br>
     * Added: 15.5.2025
     */
    private static final int CALL_STACK_LENGTH_SOURCE_STREAM_FILE = 4;

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
    private ProgramParameter[] getParameterList(I5ServiceProgram aServiceProgram, List<String> aListOfProcedure, String[] aLibraryList)
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

        // Parameter 11: XML stream file
        if (Preferences.getInstance().isXmlStmfDisabled()) {
            parameter[PARM_XML_STMF] = produceStringParameter(Preferences.XML_STMF_NONE, 1024);
        } else {
            parameter[PARM_XML_STMF] = produceStringParameter(Preferences.getInstance().getXmlStmf(), 1024);
        }

        // Parameter 12: XML type
        if (Preferences.getInstance().isXmlStmfDisabled()) {
            parameter[PARM_XML_TYPE] = produceStringParameter(Preferences.XML_TYPE, 10);
        } else {
            parameter[PARM_XML_TYPE] = produceStringParameter(Preferences.getInstance().getXmlType(), 10);
        }

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
    protected UnitTestSuite retrieveUnitTestResult(I5ServiceProgram aServiceprogram, List<String> aListOfProcedure) throws Exception {

        if (testResult != null) {
            return testResult;
        }

        testResult = new UnitTestSuite(aServiceprogram);

        // @formatter:off
        /*
         * Structure of user space:
         *  
         *   tmpl_testSuite
         *     tmpl_testCase_v4         Array(n)
         *       tmpl_callStkEnt_V4     Array(0..64)
         *       or
         *       tmpl_sender_V4
         *       tmpl_receiver_V4
         *
         * Structure of test suite header: 
         * 
         * D tmpl_testSuite  DS           256    qualified template
         * D  length                       10I 0
         * D  version                      10I 0
         * D  testSuite                          likeds(Object_t)
         * D  numRuns                      10I 0
         * D  numAsserts                   10I 0
         * D  numFailures                  10I 0
         * D  numErrors                    10I 0
         * D  offsTestCases                10I 0
         * D  numTestCases                 10I 0
         * D  system                       10A
         * D  splF_name                    10A
         * D  splF_nbr                     10I 0
         * D  job_name                     10A
         * D  job_user                     10A
         * D  job_nbr                       6A
         * D  qSrcMbr                            likeds(SrcMbr_t)
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
        int headerLength = extractInt(bytes, offset);
        int tVersion = extractInt(bytes, offset);
        if (tVersion != VERSION_3 && tVersion != VERSION_4) {
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

        // Varying length portion of header (extension of V4 header, 15.5.2025)
        boolean isV4Extended = false;
        String tSourceStreamFile = "";
        if ((offset[0] + HEADER_TYPE_OF_SOURCE) < headerLength) {
            String tTypeOfSource = extractString(bytes, offset, HEADER_TYPE_OF_SOURCE).trim();
            if (TYPE_STMF.equals(tTypeOfSource)) {
                int tOffsetSourceStreamFile = extractInt(bytes, offset);
                int tLengthSourceStreamFile = extractInt(bytes, offset);
                offset[0] = tOffsetSourceStreamFile;
                tSourceStreamFile = extractString(bytes, offset, tLengthSourceStreamFile).trim();
                isV4Extended = true;
            } else if (TYPE_MEMBER.equals(tTypeOfSource)) {
                isV4Extended = true;
            } else {
                isV4Extended = false;
            }
        }

        testResult.setRuns(tNumberRuns);
        testResult.setNumberTestCases(tNumberTestCases);
        testResult.setUserSpaceSize(headerLength);

        testResult.getServiceProgram().setSourceFile(tSrcFile);
        testResult.getServiceProgram().setSourceLibrary(tSrcLibrary);
        testResult.getServiceProgram().setSourceMember(tSrcMember);
        testResult.getServiceProgram().setSourceStreamFIle(tSourceStreamFile);

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

        if (tVersion == VERSION_4) {
            retrieveTestCasesV4(bytes, tTotalSizeUserSpace, tOffsetTestCases, numTestCasesRtn, testResult, tVersion, isV4Extended);
        } else if (tVersion == VERSION_3) {
            retrieveTestCasesV3(bytes, tTotalSizeUserSpace, tOffsetTestCases, numTestCasesRtn, testResult, tVersion);
        } else {
            throw new InvalidVersionException(tVersion);
        }

        assert tNumberAssertions == testResult.getNumberAssertions() : "Number of assertions does not match"; //$NON-NLS-1$

        return testResult;
    }

    private void retrieveTestCasesV3(byte[] aUserSpaceBytes, int aTotalLength, int anOffsetTestCases, int numTestCasesRtn, UnitTestSuite aTestSuite,
        int aVersion) throws Exception {

        // @formatter:off
        /* 
         * Structure of test case entry: 
         *   
         * D tmpl_testCase_v4...
         * D                 DS            50    qualified template
         * D  offsNextEntry                10i 0
         * D  lenEntry                      5i 0
         * D  result                        1a
         * D  reserved_1                    1a
         * D  numAsserts                   10i 0
         * D  execTime                     20i 0
         * D  offsTestCaseText...
         * D                               10i 0
         * D  lenTestCaseText...
         * D                                5i 0
         * D  offsExcpMsg                  10i 0
         * D  lenExcpMsg                    5i 0
         * D  offsSndInf                   10i 0
         * D  lenSndInf                     5i 0
         * D  offsRcvInf                   10i 0
         * D  lenRcvInf                     5i 0
         * D  offsCallStkE                 10i 0
         * D  numCallStkE                   5i 0
         *   
         *   Length over all: 50
         */
        // @formatter:on

        String tOutcome = null;
        String tReserved_1 = null;
        String tNoLongerUsed = null;
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
            tNoLongerUsed = extractString(aUserSpaceBytes, tOffset, ENTRY_STATEMENT_NUMBER);
            tAssertions = extractInt(aUserSpaceBytes, tOffset);
            tNumCallStkEnt = extractInt(aUserSpaceBytes, tOffset);
            tOffsCallStkEnt = extractInt(aUserSpaceBytes, tOffset);
            tOffsetNext = extractInt(aUserSpaceBytes, tOffset);
            tLenProcName = extractShort(aUserSpaceBytes, tOffset);
            tLenExcpMessage = extractShort(aUserSpaceBytes, tOffset);
            tProcedure = extractString(aUserSpaceBytes, tOffset, ENTRY_PROCEDURE).trim();

            tExcpMessage = extractString(aUserSpaceBytes, tOffset, tLenExcpMessage).trim();
            tExecutionTime = extractLong(aUserSpaceBytes, tOffset);

            UnitTestCase testCase = new UnitTestCase(tProcedure);
            testCase.setOutcome(tOutcome);
            testCase.setStatistics(tLastRunDate, tExecutionTime);
            testCase.setAssertions(tAssertions);
            testCase.setMessage(tExcpMessage);
            aTestSuite.addUnitTestCase(testCase);

            retrieveTestCaseCallStackV3(aUserSpaceBytes, tEntryLength, tOffsCallStkEnt, tNumCallStkEnt, testCase, aVersion);

            tOffset[0] = tOffsetNext;
        }
    }

    private void retrieveTestCaseCallStackV3(byte[] aUserSpaceBytes, int aTotalLength, int anOffsetCallStackEntries, int aNumCallStackEntries,
        UnitTestCase aTestCase, int aVersion) throws Exception {

        // @formatter:off
        /* 
         * Structure of test case entry: 
         *   
         * D tmpl_callStkEnt_V4...
         * D                 DS            92    qualified template
         * D  offsNextEntry                10i 0
         * D  lenEntry                      5i 0
         * D  qPgm                               likeds(Object_t)
         * D  qMod                               likeds(Object_t)
         * D  specNb                       10a
         * D  offsProcNm                   10i 0
         * D  lenProcNm                     5i 0
         * D  qSrcMbr                            likeds(SrcMbr_t)
         *
         *   Length over all: 92
         */
        // @formatter:on

        int[] tOffset = { anOffsetCallStackEntries };

        for (int s = 0; s < aNumCallStackEntries; s++) {
            String tPgmNm = extractString(aUserSpaceBytes, tOffset, CALL_STACK_PROGRAM);
            String tPgmLibNm = extractString(aUserSpaceBytes, tOffset, CALL_STACK_PROGRAM_LIB);
            String tModNm = extractString(aUserSpaceBytes, tOffset, CALL_STACK_MODULE);
            String tModLibNm = extractString(aUserSpaceBytes, tOffset, CALL_STACK_MODULE_LIB);
            String tSpecNb = extractString(aUserSpaceBytes, tOffset, CALL_STACK_STATEMENT_NUMBER);
            int tLength = extractInt(aUserSpaceBytes, tOffset);
            int tOffsNext = extractInt(aUserSpaceBytes, tOffset);
            String tReserved_1 = extractString(aUserSpaceBytes, tOffset, CALL_STACK_RESERVED_1);
            short tLenProcNm = extractShort(aUserSpaceBytes, tOffset);
            String tProcNm = extractString(aUserSpaceBytes, tOffset, CALL_STACK_PROCEDURE);

            String tSrcFile = extractString(aUserSpaceBytes, tOffset, CALL_STACK_SOURCE_FILE);
            String tSrcLibrary = extractString(aUserSpaceBytes, tOffset, CALL_STACK_SOURCE_LIBRARY);
            String tSrcMember = extractString(aUserSpaceBytes, tOffset, CALL_STACK_SOURCE_MEMBER);

            UnitTestCallStackEntry tStackEntry = new UnitTestCallStackEntry(tPgmNm, tPgmLibNm, tModNm, tModLibNm, tProcNm, tSpecNb, tSrcFile,
                tSrcLibrary, tSrcMember);

            aTestCase.addCallStackEntry(tStackEntry);

            tOffset[0] = tOffsNext;
        }
    }

    private void retrieveTestCasesV4(byte[] aUserSpaceBytes, int aTotalLength, int anOffsetTestCases, int numTestCasesRtn, UnitTestSuite aTestSuite,
        int aVersion, boolean isV4Extended) throws Exception {

        // @formatter:off
        /* 
         * Structure of test case entry: 
         *   
         * D tmpl_testCase_v4...
         * D                 DS            50    qualified template
         * D  offsNextEntry                10i 0
         * D  lenEntry                      5i 0
         * D  result                        1a
         * D  reserved_1                    1a
         * D  numAsserts                   10i 0
         * D  execTime                     20i 0
         * D  offsTestCaseText...
         * D                               10i 0
         * D  lenTestCaseText...
         * D                                5i 0
         * D  offsExcpMsg                  10i 0
         * D  lenExcpMsg                    5i 0
         * D  offsSndInf                   10i 0
         * D  lenSndInf                     5i 0
         * D  offsRcvInf                   10i 0
         * D  lenRcvInf                     5i 0
         * D  offsCallStkE                 10i 0
         * D  numCallStkE                   5i 0
         *   
         *   Length over all: 50
         */
        // @formatter:on

        int[] tOffset = { anOffsetTestCases };

        Date tLastRunDate = new Date();

        for (int i = 0; i < numTestCasesRtn; i++) {

            int tOffsNextEntry = extractInt(aUserSpaceBytes, tOffset);
            short tlenEntry = extractShort(aUserSpaceBytes, tOffset);

            String tOutcome = extractString(aUserSpaceBytes, tOffset, 1);
            String reserved_1 = extractString(aUserSpaceBytes, tOffset, 1);

            int tNumAsserts = extractInt(aUserSpaceBytes, tOffset);
            long tExecutionTime = extractLong(aUserSpaceBytes, tOffset);

            int tOffsTestCaseText = extractInt(aUserSpaceBytes, tOffset);
            short tLenTestCaseText = extractShort(aUserSpaceBytes, tOffset);

            int tOffsExcpMsg = extractInt(aUserSpaceBytes, tOffset);
            short tLenExcpMsg = extractShort(aUserSpaceBytes, tOffset);

            int tOffsSndInf = extractInt(aUserSpaceBytes, tOffset);
            short tLenSndInf = extractShort(aUserSpaceBytes, tOffset);

            int tOffsRcvInf = extractInt(aUserSpaceBytes, tOffset);
            short tLenRcvInf = extractShort(aUserSpaceBytes, tOffset);

            int tOffsCallStkE = extractInt(aUserSpaceBytes, tOffset);
            short tNumCallStkE = extractShort(aUserSpaceBytes, tOffset);

            String tTestCaseText;
            if (tOffsTestCaseText > 0 && tLenTestCaseText > 0) {
                tOffset[0] = tOffsTestCaseText;
                tTestCaseText = extractString(aUserSpaceBytes, tOffset, tLenTestCaseText).trim();
            } else {
                tTestCaseText = EMPTY_STRING;
            }

            String tExcpMsg;
            if (tOffsExcpMsg > 0 && tLenExcpMsg > 0) {
                tOffset[0] = tOffsExcpMsg;
                tExcpMsg = extractString(aUserSpaceBytes, tOffset, tLenExcpMsg).trim();
            } else {
                tExcpMsg = EMPTY_STRING;
            }

            UnitTestMessageSender tSender;
            if (tOffsSndInf > 0) {
                tOffset[0] = tOffsSndInf;
                short tlenSender = extractShort(aUserSpaceBytes, tOffset);
                String tPgmNm = extractString(aUserSpaceBytes, tOffset, 10);
                String tPgmLibNm = extractString(aUserSpaceBytes, tOffset, 10);
                String tModNm = extractString(aUserSpaceBytes, tOffset, 10);
                String tModLibNm = extractString(aUserSpaceBytes, tOffset, 10);
                String tSpecNb = extractString(aUserSpaceBytes, tOffset, 10);
                int tOffsProcNm = extractInt(aUserSpaceBytes, tOffset);
                short tLenProcNm = extractShort(aUserSpaceBytes, tOffset);
                tOffset[0] = tOffsProcNm;
                String tProcNm = extractString(aUserSpaceBytes, tOffset, tLenProcNm);

                tSender = new UnitTestMessageSender(tPgmNm, tPgmLibNm, tModNm, tModLibNm, tProcNm, tSpecNb);
            } else {
                tSender = null;
            }

            UnitTestMessageReceiver tReceiver;
            if (tOffsRcvInf > 0) {
                tOffset[0] = tOffsRcvInf;
                short tlenReceiver = extractShort(aUserSpaceBytes, tOffset);
                String tPgmNm = extractString(aUserSpaceBytes, tOffset, 10);
                String tPgmLibNm = extractString(aUserSpaceBytes, tOffset, 10);
                String tModNm = extractString(aUserSpaceBytes, tOffset, 10);
                String tModLibNm = extractString(aUserSpaceBytes, tOffset, 10);
                String tSpecNb = extractString(aUserSpaceBytes, tOffset, 10);
                int tOffsProcNm = extractInt(aUserSpaceBytes, tOffset);
                short tLenProcNm = extractShort(aUserSpaceBytes, tOffset);
                tOffset[0] = tOffsProcNm;
                String tProcNm = extractString(aUserSpaceBytes, tOffset, tLenProcNm);

                tReceiver = new UnitTestMessageReceiver(tPgmNm, tPgmLibNm, tModNm, tModLibNm, tProcNm, tSpecNb);
            } else {
                tReceiver = null;
            }

            UnitTestCase testCase = new UnitTestCase(tTestCaseText);
            testCase.setOutcome(tOutcome);
            testCase.setStatistics(tLastRunDate, tExecutionTime);
            testCase.setAssertions(tNumAsserts);
            testCase.setMessage(tExcpMsg);
            testCase.setMessageSender(tSender);
            testCase.setMessageReceiver(tReceiver);
            aTestSuite.addUnitTestCase(testCase);

            if (tOffsCallStkE > 0 && tNumCallStkE > 0) {
                retrieveTestCaseCallStackV4(aUserSpaceBytes, tOffsCallStkE, tNumCallStkE, testCase, aVersion, isV4Extended);
            }

            tOffset[0] = tOffsNextEntry;
        }
    }

    private void retrieveTestCaseCallStackV4(byte[] aUserSpaceBytes, int anOffsetCallStackEntries, int aNumCallStackEntries, UnitTestCase aTestCase,
        int aVersion, boolean isV4Extended) throws Exception {

        int[] tOffset = { anOffsetCallStackEntries };

        for (int s = 0; s < aNumCallStackEntries; s++) {

            int tOffsNextEntry = extractInt(aUserSpaceBytes, tOffset);
            short tLenEntry = extractShort(aUserSpaceBytes, tOffset);
            String tPgmNm = extractString(aUserSpaceBytes, tOffset, 10);
            String tPgmLibNm = extractString(aUserSpaceBytes, tOffset, 10);
            String tModNm = extractString(aUserSpaceBytes, tOffset, 10);
            String tModLibNm = extractString(aUserSpaceBytes, tOffset, 10);
            String tSpecNb = extractString(aUserSpaceBytes, tOffset, 10);

            int tOffsProcNm = extractInt(aUserSpaceBytes, tOffset);
            short tLenProcNm = extractShort(aUserSpaceBytes, tOffset);

            String tSrcFile = extractString(aUserSpaceBytes, tOffset, CALL_STACK_SOURCE_FILE);
            String tSrcLibrary = extractString(aUserSpaceBytes, tOffset, CALL_STACK_SOURCE_LIBRARY);
            String tSrcMember = extractString(aUserSpaceBytes, tOffset, CALL_STACK_SOURCE_MEMBER);

            // Varying length portion of call stack entry (extension of V4
            // entry, 15.5.2025)
            String tSourceStreamFile = "";
            if (isV4Extended) {
                String tTypeOfSource = extractString(aUserSpaceBytes, tOffset, CALL_STACK_TYPE_OF_SOURCE).trim();
                if (TYPE_STMF.equals(tTypeOfSource)) {
                    int tOffsetSourceStreamFile = extractInt(aUserSpaceBytes, tOffset);
                    int tLengthSourceStreamFile = extractInt(aUserSpaceBytes, tOffset);
                    tOffset[0] = tOffsetSourceStreamFile;
                    tSourceStreamFile = extractString(aUserSpaceBytes, tOffset, tLengthSourceStreamFile).trim();
                }
            }

            tOffset[0] = tOffsProcNm;
            String tProcNm = extractString(aUserSpaceBytes, tOffset, tLenProcNm);

            UnitTestCallStackEntry tStackEntry;
            if (StringHelper.isNullOrEmpty(tSourceStreamFile)) {
                tStackEntry = new UnitTestCallStackEntry(tPgmNm, tPgmLibNm, tModNm, tModLibNm, tProcNm, tSpecNb, tSrcFile, tSrcLibrary, tSrcMember);
            } else {
                tStackEntry = new UnitTestCallStackEntry(tPgmNm, tPgmLibNm, tModNm, tModLibNm, tProcNm, tSpecNb, tSourceStreamFile);
            }

            aTestCase.addCallStackEntry(tStackEntry);

            tOffset[0] = tOffsNextEntry;
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
    protected void prepareTest(I5ServiceProgram aUnitTestServiceprogram, List<String> aListOfProcedure) throws UnitTestException {

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
    protected int executeTest(I5ServiceProgram aServiceProgram, List<String> aListOfProcedure, String[] aLibraryList) throws Exception {

        testResult = null;

        int returnCode = 0;

        ProgramCall program = new ProgramCall(getSystem());
        program.setProgram(getPath());
        program.setParameterList(getParameterList(aServiceProgram, aListOfProcedure, aLibraryList));

        String captureJobLog = Preferences.getInstance().getCaptureJobLog();
        byte[] startingMessageKey = new byte[] { 0x00, 0x00, 0x00, 0x00 };
        if (!Preferences.DEBUG_CAPTURE_JOBLOG_OFF.equals(captureJobLog)) {
            QueuedMessage[] jobLogMessages = getNewestJobLogEntry(program.getServerJob());
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
                as400ErrorMsg.append(msgList[j].getID() + " - " + msgList[j].getText()); //$NON-NLS-1$
                String messageHelp = msgList[j].getHelp();
                if (!StringHelper.isNullOrEmpty(messageHelp)) {
                    as400ErrorMsg.append(" "); //$NON-NLS-1$
                    as400ErrorMsg.append(messageHelp);
                }
            }
            RPGUnitCorePlugin.logError(as400ErrorMsg.toString());
            captureJobLog(program, aServiceProgram, startingMessageKey);
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

            String messageHelp = jobLogMessage.getMessageHelpReplacement();
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
        return QueuedMessageHelper.getMessageType(message);
    }

    private QueuedMessage[] getNewestJobLogEntry(Job serverJob) throws Exception {
        return getJobLog(serverJob, MessageQueue.NEWEST, 1);
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
                if (count > jobLog.getLength()) {
                    count = jobLog.getLength();
                }
                messages = jobLog.getMessages(jobLog.getLength() - count, count);
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
            return QueuedMessageHelper.IBM_NULL;
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
    protected void cleanUpTest(I5ServiceProgram tServiceProgramName, List<String> aProcedure) {
        try {
            if (userSpace != null) {
                userSpace.delete();
            }
        } catch (Exception e) {
            // ignore exceptions
        }
    }
}
