/*******************************************************************************
 * Copyright (c) 2013-2024 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.eclipse.ui.views.properties.IPropertyDescriptor;
import org.eclipse.ui.views.properties.IPropertySheetEntry;
import org.eclipse.ui.views.properties.IPropertySource;
import org.eclipse.ui.views.properties.PropertyDescriptor;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.extensions.testcase.IRPGUnitTestCaseItem;
import de.tools400.rpgunit.core.extensions.view.IRPGUnitSpooledFile;
import de.tools400.rpgunit.core.jobs.ibmi.RPGUnitTestRunner;
import de.tools400.rpgunit.core.model.ibmi.I5ServiceProgram;

public class UnitTestCase implements IRPGUnitTestCaseItem, IUnitTestTreeItem, IUnitTestItemWithSourceMember, IPropertySource {

    private static final String PROPERTY_ID_EXECUTION_TIME = "executionTime"; //$NON-NLS-1$

    private static final String PROPERTY_ID_OUTCOME = "outcome"; //$NON-NLS-1$

    private static final String PROPERTY_ID_ERROR_MESSAGE = "errorMessage"; //$NON-NLS-1$

    private static final String PROPERTY_ID_STATEMENT_NUMBER = "statementNumber"; //$NON-NLS-1$

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
    private String statementNumber;

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
    public boolean isSourceMemberAvailable() {
        if (getEditableSourceMember() != null) {
            return true;
        }
        return false;
    }

    @Override
    public EditableSourceMember getEditableSourceMember() {
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
        return getUnitTestSuite().getEditableSourceMember();
    }

    public IRPGUnitSpooledFile getSpooledFile() {
        return getUnitTestSuite().getSpooledFile();
    }

    @Override
    public int getStatementNumber() {
        try {
            return Integer.parseInt(statementNumber);
        } catch (Exception e) {
            return -1;
        }
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
     * Sets the statement number. Called only by the @link
     * {@link RPGUnitTestRunner}.
     * 
     * @param aStatementNumber - Statement number as returned by RUPGMRMT.
     */
    public void setStatementNumber(String aStatementNumber) {
        statementNumber = aStatementNumber.trim();
    }

    public String getStatementNumberText() {
        return statementNumber;
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
        setStatementNumber(aUnitTestCase.getStatementNumberText());

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
        setStatementNumber(""); //$NON-NLS-1$
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
    public IPropertyDescriptor[] getPropertyDescriptors() {

        List<IPropertyDescriptor> descriptors = new ArrayList<IPropertyDescriptor>();

        descriptors.add(createPropertyDescriptor(PROPERTY_ID_STATEMENT_NUMBER, Messages.Statement_number, false));
        descriptors.add(createPropertyDescriptor(PROPERTY_ID_ERROR_MESSAGE, Messages.Error_message, false));
        descriptors.add(createPropertyDescriptor(PROPERTY_ID_OUTCOME, Messages.Result, false));

        descriptors.add(createPropertyDescriptor(PROPERTY_ID_EXECUTION_TIME, Messages.Execution_time, true));

        return descriptors.toArray(new IPropertyDescriptor[descriptors.size()]);
    }

    private IPropertyDescriptor createPropertyDescriptor(String id, String displayName, boolean advanced) {

        PropertyDescriptor descriptor = new PropertyDescriptor(id, displayName);
        if (advanced) {
            descriptor.setFilterFlags(new String[] { IPropertySheetEntry.FILTER_ID_EXPERT });
        }

        return descriptor;
    }

    @Override
    public Object getPropertyValue(Object id) {

        if (PROPERTY_ID_STATEMENT_NUMBER.equals(id)) {
            return statementNumber;
        } else if (PROPERTY_ID_ERROR_MESSAGE.equals(id)) {
            return errorMessage;
        } else if (PROPERTY_ID_EXECUTION_TIME.equals(id)) {
            return executionTimeFormatter.formatExecutionTime(executionTime) + " s"; //$NON-NLS-1$
        } else if (PROPERTY_ID_OUTCOME.equals(id)) {
            return outcome.getLabel();
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
