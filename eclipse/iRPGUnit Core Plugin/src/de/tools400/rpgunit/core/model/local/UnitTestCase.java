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

    private static final String PROPERTY_ID_OUTCOME = "outcome"; //$NON-NLS-1$
    private static final String PROPERTY_ID_EXECUTION_TIME = "executionTime"; //$NON-NLS-1$
    private static final String PROPERTY_ID_NUM_TEST_EVENTS = "numTestEvents"; //$NON-NLS-1$

    private static final String PROPERTY_ID_PROCEDURE_NAME = "procedureName"; //$NON-NLS-1$

    private static final String NOT_APPLICABLE = "n/a";
    private static final String RPG_NULL_VALUE = "*N";

    private UnitTestSuite unitTestSuite;
    private String procedure;
    private boolean isSelected = false;
    private boolean isExpanded = false;
    private UnitTestExecutionTimeFormatter executionTimeFormatter;

    /* Run Statistics */
    private int assertions;
    private long executionTime;
    private Date lastRunDate;
    private Outcome outcome;
    private List<UnitTestCaseEvent> testCaseEvents;

    public UnitTestCase(String aProcedure) {
        this.unitTestSuite = null;
        this.procedure = aProcedure.trim();
        this.isSelected = false;
        this.isExpanded = false;
        this.executionTimeFormatter = new UnitTestExecutionTimeFormatter();

        this.testCaseEvents = new ArrayList<UnitTestCaseEvent>();
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
        if (testCaseEvents.isEmpty()) {
            editableSource = null;
        } else {
            editableSource = testCaseEvents.get(0).getEditableSource();
        }

        return editableSource;
    }

    @Override
    public int getStatementNumber() {

        int statementNumber = -1;

        if (getOutcome() == Outcome.ERROR) {
            UnitTestCaseEvent unitTestCaseEvent = testCaseEvents.get(0);
            UnitTestMessageReceiver messageReceiver = unitTestCaseEvent.getMessageReceiver();
            String statementNumberString = messageReceiver.getStatementNumberText();
            statementNumber = IntHelper.tryParseInt(statementNumberString, -1);
        } else if (getOutcome() == Outcome.FAILURE) {
            if (!testCaseEvents.isEmpty()) {
                statementNumber = testCaseEvents.get(0).getStatementNumber();
            }
        }

        return statementNumber;
    }

    public IRPGUnitSpooledFile getSpooledFile() {
        return getUnitTestSuite().getSpooledFile();
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

    public void addUnitTestCaseEvent(UnitTestCaseEvent aUnitTestCaseEvent) {
        aUnitTestCaseEvent.setUnitTestCase(this);
        testCaseEvents.add(aUnitTestCaseEvent);
    }

    public UnitTestCaseEvent[] getUnitTestCaseEvents() {
        UnitTestCaseEvent[] tUnitTestCaseEvents = new UnitTestCaseEvent[testCaseEvents.size()];
        return testCaseEvents.toArray(tUnitTestCaseEvents);
    }

    /* Intentionally set restricted to 'package-private' */
    void updateUnitTestResult(UnitTestCase aUnitTestCase) {

        setAssertions(aUnitTestCase.getAssertions());
        setStatistics(aUnitTestCase.getLastRunDate(), aUnitTestCase.getExecutionTime());
        setOutcome(aUnitTestCase.getOutcome());
        testCaseEvents.clear();
        for (UnitTestCaseEvent tUnitTestCaseEvent : aUnitTestCase.getUnitTestCaseEvents()) {
            addUnitTestCaseEvent(tUnitTestCaseEvent);
        }
    }

    public void cancel() {

        setAssertions(0);
        resetStatistics();
        setOutcome(Outcome.CANCELED);
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
    }

    private void createCategoryStatement() {

        // Category: Statement
        createPropertyDescriptor(PROPERTY_ID_PROCEDURE_NAME, Messages.Procedure, false, Messages.Category_Statement);
    }

    private void createCategoryResult() {

        // Category: Result
        createPropertyDescriptor(PROPERTY_ID_OUTCOME, Messages.Result, false, Messages.Category_Result);

        // ... advanced properties
        createPropertyDescriptor(PROPERTY_ID_EXECUTION_TIME, Messages.Execution_time, true, Messages.Category_Result);
        createPropertyDescriptor(PROPERTY_ID_NUM_TEST_EVENTS, Messages.Number_of_assertions, true, Messages.Category_Result);
    }

    @Override
    public Object getPropertyValue(Object id) {

        if (PROPERTY_ID_PROCEDURE_NAME.equals(id)) {
            return getProcedure();
        } else if (PROPERTY_ID_EXECUTION_TIME.equals(id)) {
            return executionTimeFormatter.formatExecutionTime(getExecutionTime()) + " s"; //$NON-NLS-1$
        } else if (PROPERTY_ID_NUM_TEST_EVENTS.equals(id)) {
            return Integer.toString(testCaseEvents.size());
        } else if (PROPERTY_ID_OUTCOME.equals(id)) {
            return getOutcome().getLabel();
        }

        return null;
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
