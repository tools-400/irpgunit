/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.cmone.ui.preferences;

import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.preference.PreferencePage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Group;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;

import de.tools400.rpgunit.cmone.Messages;
import de.tools400.rpgunit.cmone.preferences.Preferences;

public class CMOnePreferencesPage extends PreferencePage implements IWorkbenchPreferencePage {

    private static final int COLUMN_1_WIDTH = 170;

    private static final int COLUMN_3_WIDTH = 100;

    private static final int INPUT_FIELD_LENGTH = 90;

    private Button chkCMOneIntegrationEnabled;

    /**
     * Create the preference page.
     */
    public CMOnePreferencesPage() {
    }

    /**
     * Create contents of the preference page.
     * 
     * @param parent
     */
    @Override
    public Control createContents(Composite parent) {

        Composite mainPanel = new Composite(parent, SWT.NULL);
        GridLayout gl_mainPanel = new GridLayout(1, true);
        gl_mainPanel.verticalSpacing = 10;
        mainPanel.setLayout(gl_mainPanel);

        createGroupOverrideCommandParameters(mainPanel);

        initializeValues();

        return mainPanel;
    }

    private void createGroupOverrideCommandParameters(Composite mainPanel) {

        Group grpOverrideCommandParameters = new Group(mainPanel, SWT.NONE);
        grpOverrideCommandParameters.setText(Messages.CMOnePreferencesPage_grpIntegrationParameters_text);
        GridLayout gl_grpOverrideCommandParameters = new GridLayout(1, false);
        grpOverrideCommandParameters.setLayoutData(new GridData(SWT.FILL, SWT.BEGINNING, true, false, 1, 1));
        grpOverrideCommandParameters.setLayout(gl_grpOverrideCommandParameters);

        chkCMOneIntegrationEnabled = new Button(grpOverrideCommandParameters, SWT.CHECK);
        chkCMOneIntegrationEnabled.setToolTipText(Messages.CMOnePreferencesPage_chkEnableIntegration_toolTipText);
        chkCMOneIntegrationEnabled.setText(Messages.CMOnePreferencesPage_chkEnableIntegration_text);
    }

    /**
     * Initialize the preference page.
     */
    @Override
    public void init(IWorkbench workbench) {
        // Initialize the preference page
        return;
    }

    private void initializeValues() {
        chkCMOneIntegrationEnabled.setSelection(getPreferences().isCMOneIntegrationEnabled());
    }

    @Override
    protected void performDefaults() {
        super.performDefaults();
        chkCMOneIntegrationEnabled.setSelection(getPreferences().getDefaultCMOneIntegrationEnabledState());
    }

    @Override
    public boolean performOk() {
        if (!super.performOk()) {
            return false;
        }

        Preferences tPreferences = getPreferences();
        tPreferences.setCMOneIntegrationEnabled(chkCMOneIntegrationEnabled.getSelection());

        return true;
    }

    /**
     * Get the preferences store.
     */
    @Override
    protected IPreferenceStore doGetPreferenceStore() {
        return getPreferences().getStore();
    }

    private Preferences getPreferences() {
        return Preferences.getInstance();
    }
}
