/*******************************************************************************
 * Copyright (c) 2013-2024 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.ui.views.properties.IPropertyDescriptor;
import org.eclipse.ui.views.properties.IPropertySheetEntry;
import org.eclipse.ui.views.properties.IPropertySource;
import org.eclipse.ui.views.properties.PropertyDescriptor;

import de.tools400.rpgunit.core.Messages;

public class UnitTestCallStackEntry implements IUnitTestItemWithSourceMember, IPropertySource {

    private static final String PROPERTY_ID_STATEMENT_NUMBER = "statementNumber"; //$NON-NLS-1$

    private static final String PROPERTY_ID_SOURCE_MEMBER = "sourceMember"; //$NON-NLS-1$

    private static final String PROPERTY_ID_SOURCE_LIBRARY = "sourceLibrary"; //$NON-NLS-1$

    private static final String PROPERTY_ID_SOURCE_FILE = "sourceFile"; //$NON-NLS-1$

    private static final String PROPERTY_ID_PROCEDURE = "procedure"; //$NON-NLS-1$

    private static final String PROPERTY_ID_MODULE = "module"; //$NON-NLS-1$

    private static final String PROPERTY_ID_PROGRAM = "program"; //$NON-NLS-1$

    private UnitTestCase unitTestCase;

    private String program;

    private String module;

    private String procedure;

    private String statementNumber;

    private String sourceFile;

    private String sourceLibrary;

    private String sourceMember;

    private EditableSourceMember editableSourceMember;

    public UnitTestCallStackEntry(String aProgram, String aModule, String aProcedure, String aStatementNumber, String aSourceFile,
        String aSourceLibrary, String aSourceMember) {
        unitTestCase = null;
        program = aProgram.trim();
        module = aModule.trim();
        procedure = aProcedure.trim();
        statementNumber = aStatementNumber.trim();
        sourceFile = aSourceFile.trim();
        sourceLibrary = aSourceLibrary.trim();
        sourceMember = aSourceMember.trim();
        editableSourceMember = null;
    }

    public void setUnitTestCase(UnitTestCase aUnitTestCase) {
        unitTestCase = aUnitTestCase;
    }

    public UnitTestCase getUnitTestCase() {
        return unitTestCase;
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
        if (editableSourceMember == null) {
            editableSourceMember = EditableSourceMember.getSourceMember(unitTestCase.getServiceprogram().getLibrary().getConnection(), sourceFile,
                sourceLibrary, sourceMember);
        }
        return editableSourceMember;
    }

    @Override
    public int getStatementNumber() {
        try {
            return Integer.parseInt(statementNumber);
        } catch (Exception e) {
            return -1;
        }
    }

    public String getProgram() {
        return this.program;
    }

    public String getModule() {
        return this.module;
    }

    public String getProcedure() {
        return this.procedure;
    }

    public String getStatementNumberText() {
        return this.statementNumber;
    }

    public String getSourceFile() {
        return sourceFile;
    }

    public String getSourceLibrary() {
        return sourceLibrary;
    }

    public String getSourceMember() {
        return sourceMember;
    }

    @Override
    public Object getEditableValue() {
        return this;
    }

    @Override
    public IPropertyDescriptor[] getPropertyDescriptors() {

        List<IPropertyDescriptor> descriptors = new ArrayList<IPropertyDescriptor>();

        descriptors.add(createPropertyDescriptor(PROPERTY_ID_PROGRAM, Messages.Program, false));
        descriptors.add(createPropertyDescriptor(PROPERTY_ID_MODULE, Messages.Module, false));
        descriptors.add(createPropertyDescriptor(PROPERTY_ID_PROCEDURE, Messages.Procedure, false));
        descriptors.add(createPropertyDescriptor(PROPERTY_ID_SOURCE_FILE, Messages.Source_file, false));
        descriptors.add(createPropertyDescriptor(PROPERTY_ID_SOURCE_LIBRARY, Messages.Source_library, false));
        descriptors.add(createPropertyDescriptor(PROPERTY_ID_SOURCE_MEMBER, Messages.Source_member, false));
        descriptors.add(createPropertyDescriptor(PROPERTY_ID_STATEMENT_NUMBER, Messages.Statement_number, false));

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

        if (PROPERTY_ID_PROGRAM.equals(id)) {
            return getProgram();
        } else if (PROPERTY_ID_MODULE.equals(id)) {
            return getModule();
        } else if (PROPERTY_ID_PROCEDURE.equals(id)) {
            return getProcedure();
        } else if (PROPERTY_ID_SOURCE_FILE.equals(id)) {
            return getSourceFile();
        } else if (PROPERTY_ID_SOURCE_LIBRARY.equals(id)) {
            return getSourceLibrary();
        } else if (PROPERTY_ID_SOURCE_MEMBER.equals(id)) {
            return getSourceMember();
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
