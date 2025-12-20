/*******************************************************************************
 * Copyright (c) 2013-2025 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local;

import java.util.LinkedList;
import java.util.Map;
import java.util.TreeMap;

import org.eclipse.ui.views.properties.IPropertySource;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.extensions.testcase.IRPGUnitTestCaseItem;
import de.tools400.rpgunit.core.extensions.view.IRPGUnitSpooledFile;
import de.tools400.rpgunit.core.helpers.StringHelper;
import de.tools400.rpgunit.core.model.ibmi.I5ServiceProgram;

public class UnitTestSuite extends AbstractUnitTestObject
    implements IRPGUnitTestCaseItem, IUnitTestTreeItem, IUnitTestItemWithSourceMember, Comparable<UnitTestSuite>, IPropertySource {

    private static final String PROPERTY_ID_EXECUTION_TIME = "executionTime"; //$NON-NLS-1$

    private static final String PROPERTY_ID_OUTCOME = "outcome"; //$NON-NLS-1$

    private static final String PROPERTY_ID_RUNS = "runs"; //$NON-NLS-1$

    private static final String PROPERTY_ID_NUMBER_FAILURES = "numberFailures"; //$NON-NLS-1$

    private static final String PROPERTY_ID_NUMBER_ERRORS = "numberErrors"; //$NON-NLS-1$

    private static final String PROPERTY_ID_NUMBER_ASSERTIONS = "numberAssertions"; //$NON-NLS-1$

    private static final String PROPERTY_ID_SERVICE_PROGRAM = "serviceProgram"; //$NON-NLS-1$

    private static final String PROPERTY_ID_SIZE_TEST_RESULT = "sizeTestResult"; //$NON-NLS-1$

    private I5ServiceProgram serviceprogram;
    private boolean isIncompleteProcedureList = false;
    private UnitTestExecutionTimeFormatter executionTimeFormatter;
    private Map<String, UnitTestCase> unitTestCases;

    private boolean isExpanded = false;

    private Outcome outcome;
    private int numberAssertions;
    private int numberFailures;
    private int numberErrors;
    private int runs;
    private UnitTestReportFile spooledFile;

    private int numberTestCases;
    private int numberSelectedTestCases;

    private IEditableSource editableSource;
    private int userSpaceSize;

    public UnitTestSuite(I5ServiceProgram input) {
        setServiceProgram(input);
        setIncompleteProcedureList(false);

        this.executionTimeFormatter = new UnitTestExecutionTimeFormatter();
        this.unitTestCases = new TreeMap<String, UnitTestCase>();

        this.isExpanded = false;
    }

    public void setIncompleteProcedureList(boolean anIsIncomplete) {
        isIncompleteProcedureList = anIsIncomplete;
    }

    public boolean isPartiallySelected() {

        if (unitTestCases == null || unitTestCases.size() == 0) {
            return false;
        }

        int c = 0;
        for (UnitTestCase tUnitTestCase : unitTestCases.values()) {
            if (tUnitTestCase.isSelected()) {
                c++;
            }
        }

        if (c != numberSelectedTestCases) {
            throw new RuntimeException("Number of selected test cases 'c' must match calculated number of test cases."); //$NON-NLS-1$
        }

        if (numberSelectedTestCases > 0) {
            return true;
        }

        return false;
    }

    /**
     * @return the numberFailures
     */
    public int getNumberFailures() {
        return numberFailures;
    }

    /**
     * @return the numberErrors
     */
    public int getNumberErrors() {
        return numberErrors;
    }

    /**
     * @return the input
     */
    public I5ServiceProgram getServiceProgram() {
        return serviceprogram;
    }

    private boolean isSourceStreamFile() {
        if (StringHelper.isNullOrEmpty(serviceprogram.getSourceStreamFile())) {
            return false;
        } else {
            return true;
        }
    }

    @Override
    public boolean isSourceAvailable() {
        if (getEditableSource() != null) {
            return true;
        }
        return false;
    }

    public IEditableSource getEditableSource() {
        if (editableSource == null) {
            if (isSourceStreamFile()) {
                editableSource = EditableSourceStreamFile.getSourceStreamFile(serviceprogram.getLibrary().getConnection(),
                    serviceprogram.getSourceStreamFile());
            } else {
                editableSource = EditableSourceMember.getSourceMember(serviceprogram.getLibrary().getConnection(), serviceprogram.getSourceFile(),
                    serviceprogram.getSourceLibrary(), serviceprogram.getSourceMember());
            }
        }
        return editableSource;
    }

    @Override
    public int getStatementNumber() {
        return -1;
    }

    public UnitTestCase[] getUnitTestCases() {
        UnitTestCase[] tTestCases = new UnitTestCase[unitTestCases.size()];
        return unitTestCases.values().toArray(tTestCases);
    }

    public String[] getSelectedUnitTestProcedureNames() {

        LinkedList<String> tSelectedUnitTestProcedureNames = new LinkedList<String>();
        for (UnitTestCase tUnitTestCase : getUnitTestCases()) {
            if (tUnitTestCase.isSelected()) {
                tSelectedUnitTestProcedureNames.add(tUnitTestCase.getProcedure());
                tUnitTestCase.setSelected(false);
            }
        }

        return tSelectedUnitTestProcedureNames.toArray(new String[tSelectedUnitTestProcedureNames.size()]);
    }

    public void setServiceProgram(I5ServiceProgram input) {
        this.serviceprogram = input;
    }

    public IRPGUnitSpooledFile getSpooledFile() {
        return spooledFile;
    }

    public void setSpooledFile(IRPGUnitSpooledFile spooledFile) {
        this.spooledFile = (UnitTestReportFile)spooledFile;
    }

    @Override
    public int compareTo(UnitTestSuite aUnitTestResult) {
        if (aUnitTestResult == null) {
            return 1;
        }

        if (getServiceProgram() == null) {
            if (aUnitTestResult.getServiceProgram() == null) {
                return 0;
            } else {
                return -1;
            }
        }

        return getServiceProgram().compareTo(aUnitTestResult.getServiceProgram());
    }

    public void updateUnitTestResult(UnitTestSuite aUnitTestSuite) {

        setRuns(aUnitTestSuite.getRuns());
        setNumberTestCases(aUnitTestSuite.getNumberTestCases());
        setUserSpaceSize(aUnitTestSuite.getUserSpaceSize());
        setSpooledFile(aUnitTestSuite.getSpooledFile());
        UnitTestCase[] tNewCases = aUnitTestSuite.getUnitTestCases();

        for (int i = 0; i < tNewCases.length; i++) {
            updateOrAddUnitTestCase(tNewCases[i]);
        }
    }

    public int getRuns() {
        return runs;
    }

    public void setRuns(int runs) {
        this.runs = runs;
    }

    public int getNumberTestCases() {
        if (isIncompleteProcedureList) {
            return unitTestCases.size();
        }
        return numberTestCases;
    }

    public int getNumberAssertions() {
        return numberAssertions;
    }

    public void setNumberTestCases(int numberTestCases) {
        this.numberTestCases = numberTestCases;
    }

    public int getUserSpaceSize() {
        return userSpaceSize;
    }

    public void setUserSpaceSize(int size) {
        userSpaceSize = size;
    }

    public long getTotalExecutionTime() {
        long executionTime = 0;
        for (UnitTestCase tUnitTestCase : unitTestCases.values()) {
            if (tUnitTestCase.hasStatistics()) {
                long tExecutionTime = tUnitTestCase.getExecutionTime();
                if (tExecutionTime > 0) {
                    executionTime += tExecutionTime;
                }
            }
        }
        return executionTime;
    }

    @Override
    public boolean hasStatistics() {
        for (UnitTestCase tUnitTestCase : unitTestCases.values()) {
            if (tUnitTestCase.hasStatistics()) {
                return true;
            }
        }
        return false;
    }

    @Override
    public boolean isExpanded() {
        return isExpanded;
    }

    @Override
    public void setExpanded(boolean isExpanded) {
        this.isExpanded = isExpanded;
    }

    @Override
    public boolean isError() {
        if (getNumberErrors() == 0) {
            return false;
        }
        return true;
    }

    @Override
    public boolean isFailure() {
        if (getNumberFailures() == 0) {
            return false;
        }
        return true;
    }

    @Override
    public boolean isSuccessful() {
        if (isError() || isFailure()) {
            return false;
        }
        return true;
    }

    public void cancel() {

        clearOutcome();

        for (UnitTestCase tUnitTestCase : getUnitTestCases()) {
            removeUnitTestStatistics(tUnitTestCase);
            tUnitTestCase.cancel();
            addUnitTestStatistics(tUnitTestCase);
            clearOutcome();
        }

        outcome = Outcome.max(Outcome.CANCELED, this.outcome);
    }

    private boolean existTestCase(UnitTestCase unitTestCase) {
        return unitTestCases.containsKey(unitTestCase.getKey());
    }

    public void addUnitTestCase(UnitTestCase aUnitTestCase) {

        unitTestCases.put(aUnitTestCase.getKey(), aUnitTestCase);
        addUnitTestStatistics(aUnitTestCase);

        aUnitTestCase.setUnitTestSuite(this);

        clearOutcome();
    }

    private void updateUnitTestCase(UnitTestCase aUnitTestCase) {

        UnitTestCase tUnitTestCase = unitTestCases.get(aUnitTestCase.getKey());
        removeUnitTestStatistics(tUnitTestCase);
        tUnitTestCase.updateUnitTestResult(aUnitTestCase);
        addUnitTestStatistics(aUnitTestCase);
        clearOutcome();
    }

    private void updateOrAddUnitTestCase(UnitTestCase aUnitTestCase) {

        // TODO: System.out.println("... Updating result: " +
        // aUnitTestCase.getProcedure());
        if (existTestCase(aUnitTestCase)) {
            updateUnitTestCase(aUnitTestCase);
        } else {
            addUnitTestCase(aUnitTestCase);
        }
    }

    private void addUnitTestStatistics(UnitTestCase aUnitTestCase) {
        if (aUnitTestCase.isError()) {
            numberErrors++;
        } else if (aUnitTestCase.isFailure()) {
            numberFailures++;
        }
        numberAssertions += aUnitTestCase.getAssertions();
    }

    private void removeUnitTestStatistics(UnitTestCase aUnitTestCase) {
        if (aUnitTestCase.isError()) {
            numberErrors--;
        } else if (aUnitTestCase.isFailure()) {
            numberFailures--;
        }
        numberAssertions -= aUnitTestCase.getAssertions();
    }

    /* Intentionally restricted access to 'package-private' */
    void updateCountSelected(boolean anIsSelected) {
        if (anIsSelected) {
            numberSelectedTestCases++;
        } else {
            numberSelectedTestCases--;
        }
    }

    private void clearOutcome() {
        this.outcome = null;
    }

    public Outcome getOutcome() {
        if (outcome == null) {
            for (UnitTestCase tUnitTestCase : getUnitTestCases()) {
                outcome = Outcome.max(outcome, tUnitTestCase.getOutcome());
            }
        }
        return outcome;
    }

    @Override
    public Object getEditableValue() {
        return this;
    }

    @Override
    public void createPropertyDescriptors() {

        createPropertyDescriptor(PROPERTY_ID_SERVICE_PROGRAM, Messages.Test_suite, false);
        createPropertyDescriptor(PROPERTY_ID_NUMBER_ASSERTIONS, Messages.Assertions, false);
        createPropertyDescriptor(PROPERTY_ID_NUMBER_ERRORS, Messages.Errors, false);
        createPropertyDescriptor(PROPERTY_ID_NUMBER_FAILURES, Messages.Failures, false);
        createPropertyDescriptor(PROPERTY_ID_RUNS, Messages.Runs, false);
        createPropertyDescriptor(PROPERTY_ID_OUTCOME, Messages.Result, false);

        createPropertyDescriptor(PROPERTY_ID_EXECUTION_TIME, Messages.Execution_time, true);
        createPropertyDescriptor(PROPERTY_ID_SIZE_TEST_RESULT, Messages.Size_test_result, true);
    }

    // private IPropertyDescriptor createPropertyDescriptor(String id, String
    // displayName, boolean advanced) {
    //
    // PropertyDescriptor descriptor = new PropertyDescriptor(id, displayName);
    // if (advanced) {
    // descriptor.setFilterFlags(new String[] {
    // IPropertySheetEntry.FILTER_ID_EXPERT });
    // }
    //
    // return descriptor;
    // }

    @Override
    public Object getPropertyValue(Object id) {

        if (PROPERTY_ID_SERVICE_PROGRAM.equals(id)) {
            return serviceprogram.getLibrary() + "/" + serviceprogram.getName(); //$NON-NLS-1$
        } else if (PROPERTY_ID_SIZE_TEST_RESULT.equals(id)) {
            return getUserSpaceSize();
        } else if (PROPERTY_ID_EXECUTION_TIME.equals(id)) {
            return executionTimeFormatter.formatExecutionTime(getTotalExecutionTime()) + " s"; //$NON-NLS-1$
        } else if (PROPERTY_ID_NUMBER_ASSERTIONS.equals(id)) {
            return Integer.toString(getNumberAssertions());
        } else if (PROPERTY_ID_NUMBER_ERRORS.equals(id)) {
            return Integer.toString(getNumberErrors());
        } else if (PROPERTY_ID_NUMBER_FAILURES.equals(id)) {
            return Integer.toString(getNumberFailures());
        } else if (PROPERTY_ID_RUNS.equals(id)) {
            return Integer.toString(getRuns()) + "/" + Integer.toString(getNumberTestCases()); //$NON-NLS-1$
        } else if (PROPERTY_ID_OUTCOME.equals(id)) {
            Outcome tOutcome = getOutcome();
            if (tOutcome == null) {
                return "[null]"; //$NON-NLS-1$
            } else {
                return tOutcome.getLabel();
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

    @Override
    public int category() {
        return 0;
    }
}
