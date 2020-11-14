/*******************************************************************************
 * Copyright (c) 2013-2019 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.jobs.ibmi;

import java.beans.PropertyVetoException;
import java.net.SocketException;
import java.util.Arrays;
import java.util.List;

import org.eclipse.rse.services.clientserver.messages.SystemMessageException;

import com.ibm.as400.access.AS400;
import com.ibm.as400.access.AS400Bin2;
import com.ibm.as400.access.AS400Bin4;
import com.ibm.as400.access.AS400Bin8;
import com.ibm.as400.access.CharConverter;
import com.ibm.as400.access.ObjectList;
import com.ibm.as400.access.ProgramParameter;
import com.ibm.etools.iseries.subsystems.qsys.api.IBMiConnection;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.handler.UnitTestException;
import de.tools400.rpgunit.core.model.ibmi.I5Library;
import de.tools400.rpgunit.core.model.ibmi.I5Object;
import de.tools400.rpgunit.core.model.ibmi.I5ObjectName;
import de.tools400.rpgunit.core.model.ibmi.I5ServiceProgram;
import de.tools400.rpgunit.core.model.local.UnitTestSuite;
import de.tools400.rpgunit.core.preferences.Preferences;

public abstract class AbstractUnitTestRunner {

    /**
     * Remote test driver return code: All test successfully finished.
     */
    private static final int SUCCESS = 0;

    /**
     * Remote test driver return code: One or more test cases failed.
     */
    private static final int FAILURE = -1;

    /**
     * Remote test driver: Maximum number of test cases.
     */
    private static final int MAX_NUM_TEST_CASES = 250;

    private AS400 system = null;

    private I5Object runner = null;

    private CharConverter conv = null;

    private AS400Bin2 shortConv = null;

    private AS400Bin4 intConv = null;

    private AS400Bin8 longConv = null;

    private static final short VARLEN_BYTES = 2;

    protected AbstractUnitTestRunner(I5Object aRunner) {
        runner = aRunner;
    }

    public UnitTestSuite runRemoteUnitTestSuite(I5ServiceProgram aServiceProgram) throws Exception {
        UnitTestSuite testResult = runRemoteUnitTests(aServiceProgram, null);
        return testResult;
    }

    public UnitTestSuite runRemoteUnitTestCases(I5ServiceProgram aServiceProgram, List<String> aListOfProcedure) throws Exception {
        UnitTestSuite testResult = runRemoteUnitTests(aServiceProgram, aListOfProcedure);
        return testResult;
    }

    public boolean isAvailable() {
        boolean tAvailable = false;
        String connectionName = null;
        try {
            IBMiConnection tConnection = runner.getLibrary().getConnection();
            connectionName = tConnection.getConnectionName();
            ObjectList objects = new ObjectList(tConnection.getAS400ToolboxObject(), getLibrary().getName(), getName(), getType());
            objects.load();
            tAvailable = objects.getObjects().hasMoreElements();
        } catch (SocketException e) {
            RPGUnitCorePlugin.logError("Socket error in connection '" + connectionName + "' lost.", e); //$NON-NLS-1$ //$NON-NLS-2$
        } catch (Exception e) {
            RPGUnitCorePlugin.logError("Error during check for unit test case runner.", e); //$NON-NLS-1$
        }
        return tAvailable;
    }

    @Override
    public String toString() {
        if (runner == null) {
            return "null"; //$NON-NLS-1$
        }
        return runner.toString();
    }

    protected String getName() {
        return runner.getName();
    }

    protected I5Library getLibrary() {
        return runner.getLibrary();
    }

    protected String getType() {
        return runner.getType();
    }

    protected String getPath() {
        return runner.getPath();
    }

    protected IBMiConnection getConnection() {
        return runner.getLibrary().getConnection();
    }

    protected AS400 getSystem() throws SystemMessageException {
        return system;
    }

    private AS400 initializeSystem(boolean aCreateNew) throws SystemMessageException {
        if (system == null) {
            system = getConnection().getAS400ToolboxObject(Preferences.getInstance().mustCreateNewConnection());
        }
        return system;
    }

    private void disconnectSystem() throws SystemMessageException {
        if (system != null && !system.equals(getConnection().getAS400ToolboxObject())) {
            system.disconnectAllServices();
            system = null;
        }
    }

    protected ProgramParameter produceNullParameter() throws PropertyVetoException {
        ProgramParameter tParameter = new ProgramParameter();
        tParameter.setNullParameter(true);
        tParameter.setParameterType(ProgramParameter.PASS_BY_REFERENCE);
        return tParameter;
    }

    protected ProgramParameter produceStringParameter(String aString, int aLength) throws Exception {

        byte[] tBytes = new byte[aLength];
        Arrays.fill(tBytes, 0, tBytes.length, (byte)0x40);
        getCharConverter().stringToByteArray(aString, tBytes);

        ProgramParameter tParameter = new ProgramParameter(aLength);
        tParameter.setParameterType(ProgramParameter.PASS_BY_REFERENCE);
        tParameter.setInputData(tBytes);

        return tParameter;
    }

    protected ProgramParameter produceVarlenStringParameter(String aString, int aMaxLen) throws Exception {

        int tLength = aString.length() + VARLEN_BYTES;
        byte[] tBytes = new byte[aMaxLen];
        Arrays.fill(tBytes, 0, VARLEN_BYTES, (byte)0x00);
        Arrays.fill(tBytes, VARLEN_BYTES, tBytes.length - VARLEN_BYTES, (byte)0x40);
        getShortConverter().toBytes((short)aString.length(), tBytes);
        getCharConverter().stringToByteArray(aString, tBytes, VARLEN_BYTES);

        ProgramParameter tParameter = new ProgramParameter(tLength);
        tParameter.setParameterType(ProgramParameter.PASS_BY_REFERENCE);
        tParameter.setInputData(tBytes);

        return tParameter;
    }

    protected ProgramParameter produceStringArrayParameter(String[] anArray, int aLength) throws Exception {
        byte[] tBytes = new byte[(aLength * anArray.length) + 2];

        // Number of array items
        Arrays.fill(tBytes, 0, 2, (byte)0x00);

        // Array of Char(10)
        Arrays.fill(tBytes, 2, tBytes.length - 2, (byte)0x40);

        // Set number of array entries to the first 2 bytes
        int tOffset = 0;
        tBytes[tOffset] = (byte)(anArray.length >> 8);
        tBytes[tOffset + 1] = (byte)(anArray.length /* >> 0 */);

        // Set array items, starting after the number of array items.
        tOffset = tOffset + 2;
        byte[] tItemBytes = new byte[aLength];
        for (int i = 0; i < anArray.length; i++) {
            Arrays.fill(tItemBytes, 0, tItemBytes.length, (byte)0x40);
            getCharConverter().stringToByteArray(anArray[i], tItemBytes);
            System.arraycopy(tItemBytes, 0, tBytes, tOffset, tItemBytes.length);
            tOffset = tOffset + tItemBytes.length;
        }

        ProgramParameter tParameter = new ProgramParameter(tOffset);
        tParameter.setParameterType(ProgramParameter.PASS_BY_REFERENCE);
        tParameter.setInputData(tBytes);

        return tParameter;
    }

    protected ProgramParameter produceVarlenStringArrayParameter(List<String> aListOfStrings, int aLength) throws Exception {

        // aLength = length of RPG array item 'procedure name'
        byte[] tBytes = new byte[((aLength + 2) * aListOfStrings.size()) + 2];

        // Number of array items
        Arrays.fill(tBytes, 0, 2, (byte)0x00);

        // Set number of array entries to the first 2 bytes
        int tOffset = 0;
        tBytes[tOffset] = (byte)(aListOfStrings.size() >> 8);
        tBytes[tOffset + 1] = (byte)(aListOfStrings.size());

        // Set array items, starting after the number of array items.
        tOffset = tOffset + 2;
        byte[] tItemBytes = new byte[aLength + 2];
        for (String tStringEntry : aListOfStrings) {
            tItemBytes[0] = (byte)((byte)tStringEntry.length() >> 8);
            tItemBytes[1] = (byte)(tStringEntry.length());
            Arrays.fill(tItemBytes, 2, tItemBytes.length - 2, (byte)0x40);
            getCharConverter().stringToByteArray(tStringEntry, tItemBytes, VARLEN_BYTES);
            System.arraycopy(tItemBytes, 0, tBytes, tOffset, tItemBytes.length);
            tOffset = tOffset + tItemBytes.length;
        }

        ProgramParameter tParameter = new ProgramParameter(tOffset);
        tParameter.setParameterType(ProgramParameter.PASS_BY_REFERENCE);
        tParameter.setInputData(tBytes);

        return tParameter;
    }

    protected ProgramParameter producesQualifiedObjectName(I5ObjectName jobDescription) throws Exception {
        byte[] tBytes = new byte[20];
        Arrays.fill(tBytes, 0, tBytes.length, (byte)0x40);

        int tOffset = 0;
        byte[] tItemBytes = new byte[10];

        // Copy job description name
        Arrays.fill(tItemBytes, 0, tItemBytes.length, (byte)0x40);
        getCharConverter().stringToByteArray(jobDescription.getName(), tItemBytes);
        System.arraycopy(tItemBytes, 0, tBytes, tOffset, tItemBytes.length);
        tOffset = tOffset + tItemBytes.length;

        // Copy job description library name
        Arrays.fill(tItemBytes, 0, tItemBytes.length, (byte)0x40);
        getCharConverter().stringToByteArray(jobDescription.getLibrary(), tItemBytes);
        System.arraycopy(tItemBytes, 0, tBytes, tOffset, tItemBytes.length);
        tOffset = tOffset + tItemBytes.length;

        ProgramParameter tParameter = new ProgramParameter(tOffset);
        tParameter.setParameterType(ProgramParameter.PASS_BY_REFERENCE);
        tParameter.setInputData(tBytes);

        return tParameter;
    }

    protected String extractString(byte[] aBuffer, int[] anOffset, int aLength) throws Exception {
        String tValue = getCharConverter().byteArrayToString(aBuffer, anOffset[0], aLength);
        anOffset[0] = anOffset[0] + aLength;
        return tValue;
    }

    protected long extractLong(byte[] aBuffer, int[] anOffset) {
        long tValue = getLongConverter().toLong(aBuffer, anOffset[0]);
        anOffset[0] = anOffset[0] + getLongConverter().getByteLength();
        return tValue;
    }

    protected int extractInt(byte[] aBuffer, int[] anOffset) {
        int tValue = getIntConverter().toInt(aBuffer, anOffset[0]);
        anOffset[0] = anOffset[0] + getIntConverter().getByteLength();
        return tValue;
    }

    protected short extractShort(byte[] aBuffer, int[] anOffset) {
        short tValue = getShortConverter().toShort(aBuffer, anOffset[0]);
        anOffset[0] = anOffset[0] + getShortConverter().getByteLength();
        return tValue;
    }

    protected CharConverter getCharConverter() throws Exception {
        if (conv == null) {
            conv = new CharConverter(getSystem().getCcsid(), getSystem());
        }
        return conv;
    }

    protected AS400Bin8 getLongConverter() {
        if (longConv == null) {
            longConv = new AS400Bin8();
        }
        return longConv;
    }

    protected AS400Bin4 getIntConverter() {
        if (intConv == null) {
            intConv = new AS400Bin4();
        }
        return intConv;
    }

    protected AS400Bin2 getShortConverter() {
        if (shortConv == null) {
            shortConv = new AS400Bin2();
        }
        return shortConv;
    }

    /**
     * Prepares the unit test suite or the unit test case that is executed next.
     * 
     * @param aServiceProgram Unit test suite that contains one or more unit
     *        test cases.
     * @param aProcedure Unit test case that is executed or <code>null</code>
     *        for all test cases.
     * @throws Exception
     */
    protected abstract void prepareTest(I5ServiceProgram aServiceProgram, List<String> aListOfProcedure) throws Exception;

    /**
     * Executes a prepared unit test suite or unit test case case.
     * 
     * @param aServiceProgram Unit test suite that contains one or more unit
     *        test cases.
     * @param aProcedure Unit test case that is executed or <code>null</code>
     *        for all test cases.
     * @return return code that indicates whether or not the test case has been
     *         successfully finished. Possible return codes are:
     *         <ul>
     *         <li>&nbsp;0&nbsp;&nbsp;Error while loading the test suite.</lie>
     *         <li>-1&nbsp;&nbsp;Error while loading the test suite.</lie>
     *         <li>-2&nbsp;&nbsp;No test case found.</lie>
     *         <li>-3&nbsp;&nbsp;Failed to reclaim the test suite.</lie>
     *         <li>-4&nbsp;&nbsp;Test case ended with errors or failures.</lie>
     *         </ul>
     * @throws Exception
     */
    protected abstract int executeTest(I5ServiceProgram aServiceProgram, List<String> aListOfProcedure, String[] aLibraryList) throws Exception;

    /**
     * Retrieves the result of the unit test case.
     * 
     * @param aServiceProgram Unit test suite that contains one or more unit
     *        test cases.
     * @param aProcedure Unit test case that is executed or <code>null</code>
     *        for all test cases.
     * @return Result of the unit test case.
     * @throws Exception
     */
    protected abstract UnitTestSuite retrieveUnitTestResult(I5ServiceProgram aServiceProgram, List<String> aListOfProcedure) throws Exception;

    /**
     * Frees the unit test case and returns all allocated resources.
     * 
     * @param aServiceProgram Unit test suite that contains one or more unit
     *        test cases.
     * @param aProcedure Unit test case that is executed or <code>null</code>
     *        for all test cases.
     */
    protected abstract void cleanUpTest(I5ServiceProgram aServiceProgram, List<String> aListOfProcedure);

    private UnitTestSuite runRemoteUnitTests(I5ServiceProgram aServiceprogram, List<String> aListOfProcedures) throws Exception {

        UnitTestSuite testResult = null;

        if (aListOfProcedures != null && aListOfProcedures.size() > MAX_NUM_TEST_CASES) {
            throw new Exception(
                Messages.bind(Messages.Number_of_selected_test_cases_exceeds_maximum_of_A_items, Integer.toString(MAX_NUM_TEST_CASES)));
        }

        initializeSystem(true);

        try {
            prepareTest(aServiceprogram, aListOfProcedures);

            int rc = executeTest(aServiceprogram, aListOfProcedures, aServiceprogram.getExecutionLibraryList().getLibraries());
            switch (rc) {
            case SUCCESS: // test ok, return result
            case FAILURE: // test failed, return result
                testResult = retrieveUnitTestResult(aServiceprogram, aListOfProcedures);
                break;

            default:
                throw new UnitTestException("Unit test " + aServiceprogram.getName() + " returned unexpected error code:" + rc, //$NON-NLS-1$ //$NON-NLS-2$
                    UnitTestException.Type.unexpectedError);
            }

        } finally {
            cleanUp(aServiceprogram, aListOfProcedures);
        }

        return testResult;
    }

    private void cleanUp(I5ServiceProgram aServiceProgram, List<String> aListOfProcedures) throws SystemMessageException {
        cleanUpTest(aServiceProgram, aListOfProcedures);
        disconnectSystem();
    }

}
