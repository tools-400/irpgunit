/*******************************************************************************
 * Copyright (c) 2013-2025 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.eclipse.ui.views.properties.IPropertySource;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.extensions.testcase.IRPGUnitTestCaseItem;
import de.tools400.rpgunit.core.extensions.view.IRPGUnitSpooledFile;
import de.tools400.rpgunit.core.helpers.IntHelper;
import de.tools400.rpgunit.core.jobs.ibmi.RPGUnitTestRunner;
import de.tools400.rpgunit.core.model.ibmi.I5ServiceProgram;

public class UnitTestCase extends AbstractUnitTestObject
    implements IRPGUnitTestCaseItem, IUnitTestTreeItem, IUnitTestItemWithSourceMember, IPropertySource {

    private static final String PROPERTY_ID_ACTUAL_VALUE = "actualValue"; //$NON-NLS-1$
    private static final String PROPERTY_ID_ACTUAL_LENGTH = "actualLength"; //$NON-NLS-1$
    private static final String PROPERTY_ID_ACTUAL_ORIGINAL_LENGTH = "actualOriginalLength"; //$NON-NLS-1$
    private static final String PROPERTY_ID_ACTUAL_DATA_TYPE = "actualDataType"; //$NON-NLS-1$
    private static final String PROPERTY_ID_ACTUAL_ASSERTION_PROCEDURE = "actualAssertionProcedure"; //$NON-NLS-1$

    private static final String PROPERTY_ID_EXPECTED_VALUE = "expectedValue"; //$NON-NLS-1$
    private static final String PROPERTY_ID_EXPECTED_LENGTH = "expectedLength"; //$NON-NLS-1$
    private static final String PROPERTY_ID_EXPECTED_ORIGINAL_LENGTH = "expectedOriginalLength"; //$NON-NLS-1$
    private static final String PROPERTY_ID_EXPECTED_DATA_TYPE = "expectedDataType"; //$NON-NLS-1$
    private static final String PROPERTY_ID_EXPECTED_ASSERTION_PROCEDURE = "expectedAssertionProcedure"; //$NON-NLS-1$

    private static final String PROPERTY_ID_OUTCOME = "outcome"; //$NON-NLS-1$
    private static final String PROPERTY_ID_ERROR_MESSAGE = "errorMessage"; //$NON-NLS-1$
    private static final String PROPERTY_ID_EXECUTION_TIME = "executionTime"; //$NON-NLS-1$

    private static final String PROPERTY_ID_PROCEDURE_NAME = "procedureName"; //$NON-NLS-1$
    private static final String PROPERTY_ID_STATEMENT_NUMBER = "statementNumber"; //$NON-NLS-1$

    private static final String NOT_APPLICABLE = "n/a";
    private static final String RPG_NULL_VALUE = "*N";

    private UnitTestSuite unitTestSuite;
    private String procedure;
    private boolean isSelected = false;
    private boolean isExpanded = false;
    private UnitTestExecutionTimeFormatter executionTimeFormatter;

    /* Run Statistics */
    private int assertions;
    private List<UnitTestCallStackEntry> callStackEntries;
    private String errorMessage;
    private long executionTime;
    private Date lastRunDate;
    private Outcome outcome;
    private UnitTestMessageSender messageSender;
    private UnitTestMessageReceiver messageReceiver;
    private UnitTestLogValue expected;
    private UnitTestLogValue actual;

    public UnitTestCase(String aProcedure) {
        this.unitTestSuite = null;
        this.procedure = aProcedure.trim();
        this.isSelected = false;
        this.isExpanded = false;
        this.executionTimeFormatter = new UnitTestExecutionTimeFormatter();

        this.callStackEntries = new ArrayList<UnitTestCallStackEntry>();
    }

    public boolean isExecutable() {

        if (getProcedure().toUpperCase().startsWith("TEST")) {
            return true;
        }

        throw new IllegalAccessError("There should never be a procedure not starting with 'test'.");
    }

    public void setSelected(boolean anIsSelected) {
        if (isSelected == anIsSelected) {
            return;
        }

        isSelected = anIsSelected;
        unitTestSuite.updateCountSelected(anIsSelected);
    }

    public boolean isSelected() {
        return isSelected;
    }

    /**
     * @return the serviceprogram
     */
    public I5ServiceProgram getServiceprogram() {
        return unitTestSuite.getServiceProgram();
    }

    /**
     * @return the name
     */
    public String getProcedure() {
        return procedure;
    }

    @Override
    public boolean isSuccessful() {
        return Outcome.SUCCESS.equals(outcome);
    }

    @Override
    public boolean isFailure() {
        return Outcome.FAILURE.equals(outcome);
    }

    @Override
    public boolean isError() {
        return Outcome.ERROR.equals(outcome);
    }

    @Override
    public boolean isExpanded() {
        return isExpanded;
    }

    @Override
    public void setExpanded(boolean isExpanded) {
        this.isExpanded = isExpanded;
    }

    /**
     * Sets the outcome. Called only by the @link {@link RPGUnitTestRunner}.
     * 
     * @param anOutcomeId - Id of the outcome as returned by RUPGMRMT.
     */
    public void setOutcome(String anOutcomeId) {
        Outcome tOutcome = Outcome.find(anOutcomeId);
        if (tOutcome != null) {
            setOutcome(tOutcome);
        } else {
            throw new IllegalArgumentException("Illegal argument 'anOutcomeId': " + anOutcomeId); //$NON-NLS-1$
        }
    }

    public Outcome getOutcome() {
        return outcome;
    }

    private void setOutcome(Outcome anOutcome) {
        this.outcome = anOutcome;
    }

    public Date getLastRunDate() {
        return lastRunDate;
    }

    public long getExecutionTime() {
        return executionTime;
    }

    public void setExpected(UnitTestLogValue expected) {
        this.expected = expected;
    }

    public UnitTestLogValue getExpected() {
        return expected;
    }

    public void setActual(UnitTestLogValue actual) {
        this.actual = actual;
    }

    public UnitTestLogValue getActual() {
        return actual;
    }

    /**
     * Sets the number of assertions. Called only by the @link
     * {@link RPGUnitTestRunner}.
     * 
     * @param anAssertions - NUmber of assertions as returned by RUPGMRMT.
     */
    public void setAssertions(int anAssertions) {
        this.assertions = anAssertions;
    }

    public int getAssertions() {
        return assertions;
    }

    /* Intentionally set restricted to 'package-private' */
    void setUnitTestSuite(UnitTestSuite aUnitTestSuite) {
        this.unitTestSuite = aUnitTestSuite;
    }

    public UnitTestSuite getUnitTestSuite() {
        return unitTestSuite;
    }

    @Override
    public boolean isSourceAvailable() {
        if (getEditableSource() != null) {
            return true;
        }
        return false;
    }

    @Override
    public IEditableSource getEditableSource() {

        if (isError()) {
            /*
             * In case of an unexpected runtime error, e.g. division by zero,
             * the QMHRCVPM API is used for receiving the escape message. The
             * source is not available, because the sender information of format
             * RCVM0300 of the QMHRCVPM API does not contain the program library
             * name and hence we cannot get its source member.
             */
            return null;
        }

        IEditableSource editableSource;
        if (callStackEntries.isEmpty()) {
            editableSource = null;
        } else {
            editableSource = callStackEntries.get(0).getEditableSource();
        }

        return editableSource;
    }

    public IRPGUnitSpooledFile getSpooledFile() {
        return getUnitTestSuite().getSpooledFile();
    }

    @Override
    public int getStatementNumber() {

        int statementNumber = -1;

        if (getOutcome() == Outcome.ERROR) {
            UnitTestMessageReceiver messageReceiver = getMessageReceiver();
            String statementNumberString = messageReceiver.getStatementNumberText();
            statementNumber = IntHelper.tryParseInt(statementNumberString, -1);
        } else if (getOutcome() == Outcome.FAILURE) {
            if (!callStackEntries.isEmpty()) {
                statementNumber = callStackEntries.get(0).getStatementNumber();
            }
        }

        return statementNumber;
    }

    /**
     * Sets the message. Called only by the @link {@link RPGUnitTestRunner}.
     * 
     * @param aMessage - Message as returned by RUPGMRMT.
     */
    public void setMessage(String aMessage) {
        errorMessage = aMessage.trim();
    }

    public String getMessage() {
        return errorMessage;
    }

    public String getStatementNumberText() {

        String statementNumber = NOT_APPLICABLE;

        if (getOutcome() == Outcome.ERROR) {
            UnitTestMessageReceiver messageReceiver = getMessageReceiver();
            statementNumber = messageReceiver.getStatementNumberText();
        } else if (getOutcome() == Outcome.FAILURE) {
            if (!callStackEntries.isEmpty()) {
                statementNumber = callStackEntries.get(0).getStatementNumberText();
            }
        }

        return statementNumber;
    }

    public void setMessageSender(UnitTestMessageSender messageSender) {
        if (messageSender != null) {
            messageSender.setUnitTestCase(this);
        }
        this.messageSender = messageSender;
    }

    public UnitTestMessageSender getMessageSender() {
        return messageSender;
    }

    public void setMessageReceiver(UnitTestMessageReceiver messageReceiver) {
        if (messageReceiver != null) {
            messageReceiver.setUnitTestCase(this);
        }
        this.messageReceiver = messageReceiver;
    }

    public UnitTestMessageReceiver getMessageReceiver() {
        return messageReceiver;
    }

    public String getKey() {
        return procedure;
    }

    @Override
    public boolean hasStatistics() {
        return lastRunDate != null;
    }

    /**
     * Sets the date and duration of the last run. Called only by the @link
     * {@link RPGUnitTestRunner}.
     * 
     * @param lastRunDate - Date last run as returned by RUPGMRMT
     * @param executionTime - Execution time in milliseconds as returned by
     *        RUPGMRMT.
     */
    public void setStatistics(Date lastRunDate, long executionTime) {
        this.lastRunDate = lastRunDate;
        this.executionTime = executionTime;
    }

    public void resetStatistics() {
        this.lastRunDate = null;
        this.executionTime = -1;
    }

    /**
     * Adds a call stack entry. Called only by the @link
     * {@link RPGUnitTestRunner}.
     * 
     * @param aCallStackEntry - Call stack entry as returned by RUPGMRMT.
     */
    public void addCallStackEntry(UnitTestCallStackEntry aCallStackEntry) {
        aCallStackEntry.setUnitTestCase(this);
        callStackEntries.add(aCallStackEntry);
    }

    public List<UnitTestCallStackEntry> getCallStack() {
        return callStackEntries;
    }

    /* Intentionally set restricted to 'package-private' */
    void updateUnitTestResult(UnitTestCase aUnitTestCase) {

        setAssertions(aUnitTestCase.assertions);
        setMessage(aUnitTestCase.errorMessage);
        setStatistics(aUnitTestCase.getLastRunDate(), aUnitTestCase.getExecutionTime());
        setOutcome(aUnitTestCase.getOutcome());
        setMessageSender(aUnitTestCase.getMessageSender());
        setMessageReceiver(aUnitTestCase.getMessageReceiver());
        setExpected(aUnitTestCase.getExpected());
        setActual(aUnitTestCase.getActual());

        callStackEntries.clear();
        for (UnitTestCallStackEntry tUnitTestCallStackEntry : aUnitTestCase.getCallStack()) {
            addCallStackEntry(tUnitTestCallStackEntry);
        }
    }

    public void cancel() {

        setAssertions(0);
        setMessage(""); //$NON-NLS-1$ ;
        resetStatistics();
        setOutcome(Outcome.CANCELED);
        callStackEntries.clear();
    }

    /*
     * (non-Javadoc)
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        return "UnitTestCase [selected=" + isSelected + " assertions=" + assertions + ", name=" + procedure + ", serviceprogram=" //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$ //$NON-NLS-4$
            + unitTestSuite.getServiceProgram() + ", status=" + outcome + "]"; //$NON-NLS-1$ //$NON-NLS-2$
    }

    @Override
    public Object getEditableValue() {
        return this;
    }

    @Override
    public void createPropertyDescriptors() {

        createCategoryResult();
        createCategoryStatement();

        // expected == null, if:
        // - outcome = success
        // -

        if (getExpected() != null) {
            createCategoryExpectedValue();
        }
        if (getActual() != null) {
            createCategoryActualValue();
        }
    }

    private void createCategoryStatement() {

        // Category: Statement
        createPropertyDescriptor(PROPERTY_ID_PROCEDURE_NAME, Messages.Procedure, false, Messages.Category_Statement);

        if (getOutcome() != Outcome.SUCCESS) {
            if (!isPropertyEmpty((String)getPropertyValue(PROPERTY_ID_STATEMENT_NUMBER))) {
                createPropertyDescriptor(PROPERTY_ID_STATEMENT_NUMBER, Messages.Statement_number, false, Messages.Category_Statement);
            }
        }
    }

    private void createCategoryResult() {

        // Category: Result
        createPropertyDescriptor(PROPERTY_ID_OUTCOME, Messages.Result, false, Messages.Category_Result);

        if (!isPropertyEmpty((String)getPropertyValue(PROPERTY_ID_ERROR_MESSAGE))) {
            createPropertyDescriptor(PROPERTY_ID_ERROR_MESSAGE, Messages.Error_message, false, Messages.Category_Result);
        }

        // ... advanced properties
        createPropertyDescriptor(PROPERTY_ID_EXECUTION_TIME, Messages.Execution_time, true, Messages.Category_Result);
    }

    private void createCategoryExpectedValue() {

        Short length = (Short)getPropertyValue(PROPERTY_ID_EXPECTED_LENGTH);

        // Category: Expected Test Values
        if (length > 0) {
            createPropertyDescriptor(PROPERTY_ID_EXPECTED_VALUE, Messages.Expected_value, false, Messages.Category_Expected_Test_Value);
            createPropertyDescriptor(PROPERTY_ID_EXPECTED_LENGTH, Messages.Expected_length, false, Messages.Category_Expected_Test_Value);
        } else if (getOutcome() == Outcome.FAILURE) {
            createPropertyDescriptor(PROPERTY_ID_EXPECTED_VALUE, Messages.Expected_value, false, Messages.Category_Expected_Test_Value);
        }

        if (!isPropertyEmpty((Short)getPropertyValue(PROPERTY_ID_EXPECTED_ORIGINAL_LENGTH))) {
            Short originalLength = (Short)getPropertyValue(PROPERTY_ID_EXPECTED_ORIGINAL_LENGTH);
            if (originalLength != length) {
                createPropertyDescriptor(PROPERTY_ID_EXPECTED_ORIGINAL_LENGTH, Messages.Expected_original_length, false,
                    Messages.Category_Expected_Test_Value);
            }
        }

        // ... advanced properties
        String dataType = (String)getPropertyValue(PROPERTY_ID_EXPECTED_DATA_TYPE);
        if (!RPG_NULL_VALUE.equals(dataType)) {
            createPropertyDescriptor(PROPERTY_ID_EXPECTED_DATA_TYPE, Messages.Expected_data_type, true, Messages.Category_Expected_Test_Value);
        }

        createPropertyDescriptor(PROPERTY_ID_EXPECTED_ASSERTION_PROCEDURE, Messages.Expected_assertion_procedure, true,
            Messages.Category_Expected_Test_Value);
    }

    private void createCategoryActualValue() {

        Short length = (Short)getPropertyValue(PROPERTY_ID_ACTUAL_LENGTH);

        // Category: Actual Test Values
        if (length > 0) {
            createPropertyDescriptor(PROPERTY_ID_ACTUAL_VALUE, Messages.Actual_value, false, Messages.Category_Actual_Test_Value);
            createPropertyDescriptor(PROPERTY_ID_ACTUAL_LENGTH, Messages.Actual_length, false, Messages.Category_Actual_Test_Value);
        } else if (getOutcome() == Outcome.FAILURE) {
            createPropertyDescriptor(PROPERTY_ID_ACTUAL_VALUE, Messages.Actual_value, false, Messages.Category_Actual_Test_Value);
        }

        if (!isPropertyEmpty((Short)getPropertyValue(PROPERTY_ID_ACTUAL_ORIGINAL_LENGTH))) {
            Short originalLength = (Short)getPropertyValue(PROPERTY_ID_ACTUAL_ORIGINAL_LENGTH);
            if (originalLength != length) {
                createPropertyDescriptor(PROPERTY_ID_ACTUAL_ORIGINAL_LENGTH, Messages.Actual_original_length, false,
                    Messages.Category_Actual_Test_Value);
            }
        }

        // ... advanced properties
        String dataType = (String)getPropertyValue(PROPERTY_ID_ACTUAL_DATA_TYPE);
        if (!RPG_NULL_VALUE.equals(dataType)) {
            createPropertyDescriptor(PROPERTY_ID_ACTUAL_DATA_TYPE, Messages.Actual_data_type, true, Messages.Category_Actual_Test_Value);
        }
        createPropertyDescriptor(PROPERTY_ID_ACTUAL_ASSERTION_PROCEDURE, Messages.Actual_assertion_procedure, true,
            Messages.Category_Actual_Test_Value);
    }

    @Override
    public Object getPropertyValue(Object id) {

        UnitTestLogValue expected = getExpected();
        UnitTestLogValue actual = getActual();

        if (PROPERTY_ID_PROCEDURE_NAME.equals(id)) {
            return getProcedure();
        } else if (PROPERTY_ID_STATEMENT_NUMBER.equals(id)) {
            return getStatementNumberText();
        } else if (PROPERTY_ID_ERROR_MESSAGE.equals(id)) {
            return getMessage();
        } else if (PROPERTY_ID_EXECUTION_TIME.equals(id)) {
            return executionTimeFormatter.formatExecutionTime(getExecutionTime()) + " s"; //$NON-NLS-1$
        } else if (PROPERTY_ID_OUTCOME.equals(id)) {
            return getOutcome().getLabel();
        } else if (PROPERTY_ID_EXPECTED_VALUE.equals(id)) {
            return getValue(expected);
        } else if (PROPERTY_ID_EXPECTED_LENGTH.equals(id)) {
            return getLength(expected);
        } else if (PROPERTY_ID_EXPECTED_ORIGINAL_LENGTH.equals(id)) {
            return getOriginalLength(expected);
        } else if (PROPERTY_ID_EXPECTED_DATA_TYPE.equals(id)) {
            return getDataType(expected);
        } else if (PROPERTY_ID_EXPECTED_ASSERTION_PROCEDURE.equals(id)) {
            return getAssertionProcedure(expected);
        } else if (PROPERTY_ID_ACTUAL_VALUE.equals(id)) {
            return getValue(actual);
        } else if (PROPERTY_ID_ACTUAL_LENGTH.equals(id)) {
            return getLength(actual);
        } else if (PROPERTY_ID_ACTUAL_ORIGINAL_LENGTH.equals(id)) {
            return getOriginalLength(actual);
        } else if (PROPERTY_ID_ACTUAL_DATA_TYPE.equals(id)) {
            return getDataType(actual);
        } else if (PROPERTY_ID_ACTUAL_ASSERTION_PROCEDURE.equals(id)) {
            return getAssertionProcedure(actual);
        }

        return null;
    }

    private Object getOriginalLength(UnitTestLogValue logValue) {
        // if (logValue != null) {
        return logValue.getOriginalLength();
        // } else {
        // return NOT_APPLICABLE;
        // }
    }

    private Object getLength(UnitTestLogValue logValue) {
        // if (logValue != null) {
        return logValue.getLength();
        // } else {
        // return NOT_APPLICABLE;
        // }
    }

    private String getValue(UnitTestLogValue logValue) {
        // if (logValue != null && !RPG_NULL_VALUE.equals(logValue.getValue()))
        // {
        if (RPG_NULL_VALUE.equals(logValue.getDataType())) {
            return Messages.Not_available_due_to_assertion_procedure;
        } else {
            return logValue.getValue();
        }
    }

    private String getDataType(UnitTestLogValue logValue) {
        // if (logValue != null &&
        // !RPG_NULL_VALUE.equals(logValue.getDataType())) {
        return logValue.getDataType();
    }

    private String getAssertionProcedure(UnitTestLogValue logValue) {
        // if (logValue != null &&
        // !RPG_NULL_VALUE.equals(logValue.getAssertProcedure())) {
        // if (RPG_NULL_VALUE.equals(logValue.getAssertProcedure())) {
        // return NOT_APPLICABLE;
        // } else {
        return logValue.getAssertProcedure() + "()";
        // }
    }

    @Override
    public boolean isPropertySet(Object arg0) {
        return false;
    }

    @Override
    public void resetPropertyValue(Object arg0) {
    }

    @Override
    public void setPropertyValue(Object arg0, Object arg1) {
    }
}
