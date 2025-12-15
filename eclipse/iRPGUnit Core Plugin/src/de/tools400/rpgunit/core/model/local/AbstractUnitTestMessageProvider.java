/*******************************************************************************
 * Copyright (c) 2012-2025 iSphere Project Owners
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local;

import org.eclipse.ui.views.properties.IPropertySource;

import de.tools400.rpgunit.core.Messages;

public abstract class AbstractUnitTestMessageProvider extends AbstractUnitTestObject implements IPropertySource {

    private static final String PROPERTY_ID_TYPE = "type"; //$NON-NLS-1$
    private static final String PROPERTY_ID_PROGRAM_NAME = "programName"; //$NON-NLS-1$
    private static final String PROPERTY_ID_PROGRAM_LIBRARY_NAME = "programLibraryName"; //$NON-NLS-1$
    private static final String PROPERTY_ID_MODULE_NAME = "moduleName"; //$NON-NLS-1$
    private static final String PROPERTY_ID_MODULE_LIBRARY_NAME = "moduleLibraryName"; //$NON-NLS-1$
    private static final String PROPERTY_ID_PROCEDURE_NAME = "procedureName"; //$NON-NLS-1$
    private static final String PROPERTY_ID_STATEMENT_NUMBER = "statementNumber"; //$NON-NLS-1$

    // private UnitTestCase unitTestCase;

    private String program;
    private String programLibrary;
    private String module;
    private String moduleLibrary;
    private String procedure;
    private String statementNumber;

    public AbstractUnitTestMessageProvider(String aPgmNm, String aPgmLibNm, String aModNm, String aModLibNm, String aProcNm, String aStmtNb) {
        this.program = aPgmNm.trim();
        this.programLibrary = aPgmLibNm.trim();
        this.module = aModNm.trim();
        this.moduleLibrary = aModLibNm.trim();
        this.procedure = aProcNm.trim();
        this.statementNumber = aStmtNb.trim();
    }

    // public void setUnitTestCase(UnitTestCase aUnitTestCase) {
    // unitTestCase = aUnitTestCase;
    // }
    //
    // public UnitTestCase getUnitTestCase() {
    // return unitTestCase;
    // }

    public String getProgram() {
        return program;
    }

    public String getProgramLibrary() {
        return programLibrary;
    }

    public String getModule() {
        return module;
    }

    public String getModuleLibrary() {
        return moduleLibrary;
    }

    public String getProcedure() {
        return procedure;
    }

    public String getStatementNumberText() {
        return statementNumber;
    }

    public abstract String getType();

    @Override
    public Object getEditableValue() {
        return this;
    }

    @Override
    public void createPropertyDescriptors() {

        createPropertyDescriptor(PROPERTY_ID_TYPE, Messages.Type, false, Messages.Other);
        createPropertyDescriptor(PROPERTY_ID_PROGRAM_NAME, Messages.Program, false, Messages.Program);
        createPropertyDescriptor(PROPERTY_ID_PROGRAM_LIBRARY_NAME, Messages.Library, false, Messages.Program);
        createPropertyDescriptor(PROPERTY_ID_MODULE_NAME, Messages.Module, false, Messages.Module);
        createPropertyDescriptor(PROPERTY_ID_MODULE_LIBRARY_NAME, Messages.Library, false, Messages.Module);
        createPropertyDescriptor(PROPERTY_ID_PROCEDURE_NAME, Messages.Procedure, false, Messages.Statement_number);
        createPropertyDescriptor(PROPERTY_ID_STATEMENT_NUMBER, Messages.Statement_number, false, Messages.Statement_number);
    }

    @Override
    public Object getPropertyValue(Object id) {

        if (PROPERTY_ID_TYPE.equals(id)) {
            return getType();
        } else if (PROPERTY_ID_PROGRAM_NAME.equals(id)) {
            return getProgram();
        } else if (PROPERTY_ID_PROGRAM_LIBRARY_NAME.equals(id)) {
            return getProgramLibrary();
        } else if (PROPERTY_ID_MODULE_NAME.equals(id)) {
            return getModule();
        } else if (PROPERTY_ID_MODULE_LIBRARY_NAME.equals(id)) {
            return getModuleLibrary();
        } else if (PROPERTY_ID_PROCEDURE_NAME.equals(id)) {
            return getProcedure();
        } else if (PROPERTY_ID_STATEMENT_NUMBER.equals(id)) {
            return getStatementNumberText();
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
