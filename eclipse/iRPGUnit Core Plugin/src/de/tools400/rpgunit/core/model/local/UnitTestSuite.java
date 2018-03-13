/*******************************************************************************
 * Copyright (c) 2013-2017 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import org.eclipse.ui.views.properties.IPropertyDescriptor;
import org.eclipse.ui.views.properties.IPropertySheetEntry;
import org.eclipse.ui.views.properties.IPropertySource;
import org.eclipse.ui.views.properties.PropertyDescriptor;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.extensions.testcase.IRPGUnitTestCaseItem;
import de.tools400.rpgunit.core.extensions.view.IRPGUnitSpooledFile;
import de.tools400.rpgunit.core.model.ibmi.I5ServiceProgram;

public class UnitTestSuite implements IRPGUnitTestCaseItem, IUnitTestTreeItem, IUnitTestItemWithSourceMember, Comparable<UnitTestSuite>,
    IPropertySource {

    private static final String PROPERTY_ID_EXECUTION_TIME = "executionTime"; //$NON-NLS-1$

    private static final String PROPERTY_ID_OUTCOME = "outcome"; //$NON-NLS-1$

    private static final String PROPERTY_ID_RUNS = "runs"; //$NON-NLS-1$

    private static final String PROPERTY_ID_NUMBER_FAILURES = "numberFailures"; //$NON-NLS-1$

    private static final String PROPERTY_ID_NUMBER_ERRORS = "numberErrors"; //$NON-NLS-1$

    private static final String PROPERTY_ID_NUMBER_ASSERTIONS = "numberAssertions"; //$NON-NLS-1$

    private static final String PROPERTY_ID_SERVICE_PROGRAM = "serviceProgram"; //$NON-NLS-1$

    private I5ServiceProgram serviceprogram;

    private int numberAssertions;

    private int numberFailures;

    private int numberErrors;

    private int numberSelectedTestCases = 0;

    private int runs = 0;

    private int numberTestCases = 0;

    private boolean isSelected = false;

    private boolean isExpanded = false;

    private boolean isIncompleteProcedureList = false;

    private UnitTestReportFile spooledFile;

    private EditableSourceMember editableSourceMember;

    private Map<String, UnitTestCase> unitTestCases = new TreeMap<String, UnitTestCase>();

    private UnitTestExecutionTimeFormatter executionTimeFormatter;

    public UnitTestSuite(I5ServiceProgram input) {
        setServiceProgram(input);
        setIsSelected(false);
        setIncompleteProcedureList(false);

        this.executionTimeFormatter = new UnitTestExecutionTimeFormatter();
    }

    public void setIsSelected(boolean anIsSelected) {

        if (isSelected == anIsSelected) {
            return;
        }

        isSelected = anIsSelected;

        if (isSelected) {
            for (UnitTestCase tUnitTestCase : unitTestCases.values()) {
                if (isIncompleteProcedureList) {
                    tUnitTestCase.setIsSelected(true);
                } else {
                    tUnitTestCase.setIsSelected(false);
                }
            }
        }
    }

    public void removeNonExecutableTestCases() {
        
        Set<String> toBeRemoved=new HashSet<String>();
        
        for (String key : unitTestCases.keySet()) {
           UnitTestCase unitTestCase= unitTestCases.get(key);
           if (!unitTestCase.isExecutable()) {
               toBeRemoved.add(key);
           }
        }
        
        for (String key : toBeRemoved) {
            unitTestCases.remove(key);
        }
    }
    
    public void setIncompleteProcedureList(boolean anIsIncomplete) {
        isIncompleteProcedureList = anIsIncomplete;
    }

    protected void countSelected(boolean anIsSelected) {
        if (anIsSelected) {
            numberSelectedTestCases++;
        } else {
            numberSelectedTestCases--;
        }

        if (numberSelectedTestCases > 0) {
            setIsSelected(false);
        }
    }

    public boolean isSelected() {
        return isSelected;
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

    @Override
    public EditableSourceMember getEditableSourceMember() {
        if (editableSourceMember == null) {
            editableSourceMember = EditableSourceMember.getSourceMember(serviceprogram.getLibrary().getConnection(), serviceprogram.getSourceFile(),
                serviceprogram.getSourceLibrary(), serviceprogram.getSourceMember());
        }
        return editableSourceMember;
    }

    @Override
    public int getStatementNumber() {
        return -1;
    }

    public void addUnitTestCase(UnitTestCase aUnitTestCase) {
        aUnitTestCase.setUnitTestSuite(this);
        unitTestCases.put(aUnitTestCase.getKey(), aUnitTestCase);
        if (aUnitTestCase.isFailure()) {
            numberFailures++;
        } else if (aUnitTestCase.isError()) {
            numberErrors++;
        }

        numberAssertions = numberAssertions + aUnitTestCase.getAssertions();
        isSelected = false;
    }

    public UnitTestCase[] getUnitsTestCases() {
        UnitTestCase[] tTestCases = new UnitTestCase[unitTestCases.size()];
        return unitTestCases.values().toArray(tTestCases);
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
        setSpooledFile(aUnitTestSuite.getSpooledFile());
        UnitTestCase[] tNewCases = aUnitTestSuite.getUnitsTestCases();
        for (int i = 0; i < tNewCases.length; i++) {
            updateTestCase(tNewCases[i]);
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

    public long getTotalExecutionTime() {
        long executionTime = 0;
        for (UnitTestCase tUnitTestCase : unitTestCases.values()) {
            if (tUnitTestCase.hasStatistics() && tUnitTestCase.isSuccessful()) {
                executionTime += tUnitTestCase.getExecutionTime();
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

    private void updateTestCase(UnitTestCase unitTestCase) {
        removeTestCaseIfExists(unitTestCase);
        addUnitTestCase(unitTestCase);
    }

    private boolean existTestCase(UnitTestCase unitTestCase) {
        return unitTestCases.containsKey(unitTestCase.getKey());
    }

    private void removeTestCaseIfExists(UnitTestCase aUnitTestCase) {
        if (existTestCase(aUnitTestCase)) {
            removeTestCase(aUnitTestCase);
        }
    }

    private void removeTestCase(UnitTestCase aUnitTestCase) {
        UnitTestCase tTestCase = unitTestCases.get(aUnitTestCase.getKey());

        if (tTestCase.isSelected()) {
            numberSelectedTestCases--;
        }

        if (tTestCase.isFailure()) {
            numberFailures--;
        } else if (tTestCase.isError()) {
            numberErrors--;
        }

        numberAssertions = numberAssertions - tTestCase.getAssertions();
        unitTestCases.remove(tTestCase.getKey());
    }

    @Override
    public Object getEditableValue() {
        return this;
    }

    @Override
    public IPropertyDescriptor[] getPropertyDescriptors() {

        List<IPropertyDescriptor> descriptors = new ArrayList<IPropertyDescriptor>();

        descriptors.add(createPropertyDescriptor(PROPERTY_ID_SERVICE_PROGRAM, Messages.Test_suite, false));
        descriptors.add(createPropertyDescriptor(PROPERTY_ID_NUMBER_ASSERTIONS, Messages.Assertions, false));
        descriptors.add(createPropertyDescriptor(PROPERTY_ID_NUMBER_ERRORS, Messages.Errors, false));
        descriptors.add(createPropertyDescriptor(PROPERTY_ID_NUMBER_FAILURES, Messages.Failures, false));
        descriptors.add(createPropertyDescriptor(PROPERTY_ID_RUNS, Messages.Runs, false));
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

        if (PROPERTY_ID_SERVICE_PROGRAM.equals(id)) {
            return serviceprogram.getLibrary() + "/" + serviceprogram.getName(); //$NON-NLS-1$
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
            if (isSuccessful()) {
                return Messages.SUCCESS;
            } else if (isFailure()) {
                return Messages.FAILED;
            } else {
                return Messages.ERROR;
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
