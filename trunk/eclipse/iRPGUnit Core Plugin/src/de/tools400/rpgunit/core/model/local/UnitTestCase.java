/*******************************************************************************
 * Copyright (c) 2013-2017 iRPGUnit Project Team
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
import de.tools400.rpgunit.core.model.ibmi.I5ServiceProgram;

public class UnitTestCase implements IRPGUnitTestCaseItem, IUnitTestTreeItem, IUnitTestItemWithSourceMember, IPropertySource {

    private static final String PROPERTY_ID_EXECUTION_TIME = "executionTime"; //$NON-NLS-1$

    private static final String PROPERTY_ID_OUTCOME = "outcome"; //$NON-NLS-1$

    private static final String PROPERTY_ID_ERROR_MESSAGE = "errorMessage"; //$NON-NLS-1$

    private static final String PROPERTY_ID_STATEMENT_NUMBER = "statementNumber"; //$NON-NLS-1$

    private static final String OUTCOME_ERROR = "E"; //$NON-NLS-1$

    private static final String OUTCOME_FAILURE = "F"; //$NON-NLS-1$

    private static final String OUTCOME_SUCCESS = "S"; //$NON-NLS-1$

    private String procedure;

    private String outcome;

    private long executionTime = 0;

    private String statementNumber;

    private int assertions;

    private String errorMessage;

    private List<UnitTestCallStackEntry> callStackEntries;

    private boolean isSelected = false;

    private Date lastRunDate = null;

    private UnitTestSuite unitTestSuite;

    private boolean isExpanded = false;

    private UnitTestExecutionTimeFormatter executionTimeFormatter;

    public boolean isExecutable() {

        if (getProcedure().toUpperCase().startsWith("TEST")) {
            return true;
        }

        return false;
    }

    public UnitTestCase(String aProcedure) {
        this.unitTestSuite = null;
        this.procedure = aProcedure.trim();
        this.callStackEntries = new ArrayList<UnitTestCallStackEntry>();
        this.executionTimeFormatter = new UnitTestExecutionTimeFormatter();
    }

    public void setIsSelected(boolean anIsSelected) {
        if (isSelected == anIsSelected) {
            return;
        }

        isSelected = anIsSelected;
        unitTestSuite.countSelected(anIsSelected);
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
        return OUTCOME_SUCCESS.equals(outcome);
    }

    @Override
    public boolean isFailure() {
        return OUTCOME_FAILURE.equals(outcome);
    }

    @Override
    public boolean isError() {
        return OUTCOME_ERROR.equals(outcome);
    }

    public void setOutcome(String anOutcome) {
        String tOutcome = anOutcome.trim();
        if (OUTCOME_SUCCESS.equals(tOutcome) || OUTCOME_FAILURE.equals(tOutcome) || OUTCOME_ERROR.equals(tOutcome)) {
            this.outcome = tOutcome;
        } else {
            throw new IllegalArgumentException("Illegal argument: " + tOutcome //$NON-NLS-1$
                + " 'Outcome' must match 'S' (success) or 'F' (failure) or 'E' (error)."); //$NON-NLS-1$
        }
    }

    public long getExecutionTime() {
        return executionTime;
    }

    public void setAssertions(int anAssertions) {
        this.assertions = anAssertions;
    }

    public int getAssertions() {
        return assertions;
    }

    protected void setUnitTestSuite(UnitTestSuite aUnitTestSuite) {
        this.unitTestSuite = aUnitTestSuite;
    }

    public UnitTestSuite getUnitTestSuite() {
        return unitTestSuite;
    }

    @Override
    public EditableSourceMember getEditableSourceMember() {
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

    public void setMessage(String aMessage) {
        errorMessage = aMessage.trim();
    }

    public String getMessage() {
        return errorMessage;
    }

    public void setStatementNumber(String aStatement) {
        statementNumber = aStatement.trim();
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

    public void setStatistics(Date lastRunDate, long executionTime) {
        this.lastRunDate = lastRunDate;
        this.executionTime = executionTime;
    }

    public void resetStatistics() {
        this.lastRunDate = null;
        this.executionTime = -1;
    }

    @Override
    public boolean isExpanded() {
        return isExpanded;
    }

    @Override
    public void setExpanded(boolean isExpanded) {
        this.isExpanded = isExpanded;
    }

    public void addCallStackEntry(UnitTestCallStackEntry aCallStackEntry) {
        aCallStackEntry.setUnitTestCase(this);
        callStackEntries.add(aCallStackEntry);
    }

    public List<UnitTestCallStackEntry> getCallStack() {
        return callStackEntries;
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
            if (isSuccessful()) {
                return "SUCCESS"; //$NON-NLS-1$
            } else if (isFailure()) {
                return "FAILED"; //$NON-NLS-1$
            } else {
                return "ERROR"; //$NON-NLS-1$
            }
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
