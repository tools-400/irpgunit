/*******************************************************************************
 * Copyright (c) 2013-2025 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.ui.views.properties.IPropertySource;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.helpers.IntHelper;
import de.tools400.rpgunit.core.jobs.ibmi.RPGUnitTestRunner;

public class UnitTestCaseEvent extends AbstractUnitTestObject implements IUnitTestTreeItem, IUnitTestItemWithSourceMember, IPropertySource {

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
    private static final String PROPERTY_ID_ASSERT_PROC_NAME = "assertProcName"; //$NON-NLS-1$

    private static final String PROPERTY_ID_STATEMENT_NUMBER = "statementNumber"; //$NON-NLS-1$

    private static final String NOT_APPLICABLE = "n/a";
    private static final String RPG_NULL_VALUE = "*N";

    private UnitTestCase unitTestCase;
    private boolean isExpanded = false;

    /* Run Statistics */
    private List<UnitTestCallStackEntry> callStackEntries;
    private String errorMessage;
    private Outcome outcome;
    private String assertProcName;
    private UnitTestMessageSender messageSender;
    private UnitTestMessageReceiver messageReceiver;
    private UnitTestLogValue expected;
    private UnitTestLogValue actual;

    public UnitTestCaseEvent() {
        this.unitTestCase = null;
        this.isExpanded = false;

        this.callStackEntries = new ArrayList<UnitTestCallStackEntry>();
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

    /* Intentionally set restricted to 'package-private' */
    void setUnitTestCase(UnitTestCase aUnitTestCase) {
        this.unitTestCase = aUnitTestCase;
    }

    public UnitTestCase getUnitTestCase() {
        return unitTestCase;
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

    /**
     * Sets the message. Called only by the @link {@link RPGUnitTestRunner}.
     * 
     * @param aMessage - Message as returned by RUPGMRMT.
     */
    public void setAssertProcName(String anAssertProcName) {
        assertProcName = anAssertProcName.trim();
    }

    public String getAssertProcName() {
        return assertProcName;
    }

    public String getStatementNumberText() {

        String statementNumber = NOT_APPLICABLE;

        if (getOutcome() == Outcome.ERROR) {
            UnitTestMessageReceiver messageReceiver = getMessageReceiver();
            if (messageReceiver != null) {
                // for v4 and v5 test cases
                statementNumber = messageReceiver.getStatementNumberText();
            } else {
                // for old v3 test cases
                if (callStackEntries != null && callStackEntries.size() > 0) {
                    statementNumber = Integer.toString(callStackEntries.get(0).getStatementNumber());
                }
            }
        } else if (getOutcome() == Outcome.FAILURE) {
            if (!callStackEntries.isEmpty()) {
                statementNumber = callStackEntries.get(0).getStatementNumberText();
            }
        }

        return statementNumber;
    }

    public void setMessageSender(UnitTestMessageSender messageSender) {
        if (messageSender != null) {
            // TODO: fix setting UnitTestCase
            // messageSender.setUnitTestCase(this);
        }
        this.messageSender = messageSender;
    }

    public UnitTestMessageSender getMessageSender() {
        return messageSender;
    }

    public void setMessageReceiver(UnitTestMessageReceiver messageReceiver) {
        if (messageReceiver != null) {
            // TODO: fix setting UnitTestCase
            // messageReceiver.setUnitTestCase(this);
        }
        this.messageReceiver = messageReceiver;
    }

    public UnitTestMessageReceiver getMessageReceiver() {
        return messageReceiver;
    }

    /**
     * Adds a call stack entry. Called only by the @link
     * {@link RPGUnitTestRunner}.
     * 
     * @param aCallStackEntry - Call stack entry as returned by RUPGMRMT.
     */
    public void addCallStackEntry(UnitTestCallStackEntry aCallStackEntry) {
        aCallStackEntry.setUnitTestCaseEvent(this);
        callStackEntries.add(aCallStackEntry);
    }

    public List<UnitTestCallStackEntry> getCallStack() {
        return callStackEntries;
    }

    /* Intentionally set restricted to 'package-private' */
    void updateUnitTestResult(UnitTestCaseEvent aUnitTestCase) {

        setMessage(aUnitTestCase.errorMessage);
        setOutcome(aUnitTestCase.getOutcome());
        setAssertProcName(aUnitTestCase.getAssertProcName());
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

        setMessage(""); //$NON-NLS-1$ ;
        setOutcome(Outcome.CANCELED);
        callStackEntries.clear();
    }

    /*
     * (non-Javadoc)
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        return "UnitTestCase [status=" + outcome + "]"; //$NON-NLS-1$
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

        if (getOutcome() != Outcome.SUCCESS) {
            if (!isPropertyEmpty((String)getPropertyValue(PROPERTY_ID_STATEMENT_NUMBER))) {
                createPropertyDescriptor(PROPERTY_ID_STATEMENT_NUMBER, Messages.Statement_number, false, Messages.Category_Statement);
            }
        }
    }

    private void createCategoryResult() {

        // Category: Result
        createPropertyDescriptor(PROPERTY_ID_OUTCOME, Messages.Result, false, Messages.Category_Result);

        if (!isPropertyEmpty((String)getPropertyValue(PROPERTY_ID_ASSERT_PROC_NAME))) {
            createPropertyDescriptor(PROPERTY_ID_ASSERT_PROC_NAME, Messages.AssertProcName, false, Messages.Category_Result);
        }

        if (!isPropertyEmpty((String)getPropertyValue(PROPERTY_ID_ERROR_MESSAGE))) {
            createPropertyDescriptor(PROPERTY_ID_ERROR_MESSAGE, Messages.Error_message, false, Messages.Category_Result);
        }

        // ... advanced properties
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

        if (PROPERTY_ID_STATEMENT_NUMBER.equals(id)) {
            return getStatementNumberText();
        } else if (PROPERTY_ID_ERROR_MESSAGE.equals(id)) {
            return getMessage();
        } else if (PROPERTY_ID_ASSERT_PROC_NAME.equals(id)) {
            return getAssertProcName();
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

    @Override
    public boolean hasStatistics() {
        return false;
    }
}
