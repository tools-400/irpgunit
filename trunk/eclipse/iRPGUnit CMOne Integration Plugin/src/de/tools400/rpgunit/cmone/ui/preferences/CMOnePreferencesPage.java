/*******************************************************************************
 * Copyright (c) 2013-2018 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.cmone.ui.preferences;

import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.preference.PreferencePage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;

import de.tools400.rpgunit.cmone.Messages;
import de.tools400.rpgunit.cmone.preferences.Preferences;

public class CMOnePreferencesPage extends PreferencePage implements IWorkbenchPreferencePage {

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
        createGroupLibraryListInfo(mainPanel);

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

    private void createGroupLibraryListInfo(Composite mainPanel) {

        Group grpLibraryListInfo = new Group(mainPanel, SWT.NONE);
        grpLibraryListInfo.setText(Messages.CMOnePreferencesPage_grpLibraryListInfo_text);
        GridLayout gl_grpLibraryListInfo = new GridLayout(1, false);
        grpLibraryListInfo.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
        grpLibraryListInfo.setLayout(gl_grpLibraryListInfo);

        Text lblLibraryListInfo = new Text(grpLibraryListInfo, SWT.NONE | SWT.MULTI | SWT.WRAP);
        lblLibraryListInfo.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
        lblLibraryListInfo.setEditable(false);
        lblLibraryListInfo.setText(Messages.CMOnePreferencesPage_lblLibraryListInfo);
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

    private class AutoScrollbarsListener implements Listener {

        public void handleEvent(Event event) {

            if (!(event.widget instanceof Text)) {
                return;
            }

            Text text = (Text)event.widget;
            if (text.getHorizontalBar() == null && text.getVerticalBar() == null) {
                return;
            }

            if (event.type != SWT.Modify && event.type != SWT.Resize) {
                return;
            }

            Rectangle r1 = text.getClientArea();
            Rectangle r2 = text.computeTrim(r1.x, r1.y, r1.width, r1.height);

            Point p;
            if ((text.getStyle() & SWT.WRAP) == SWT.WRAP) {
                p = text.computeSize(r1.x, SWT.DEFAULT, true);
            } else {
                p = text.computeSize(SWT.DEFAULT, SWT.DEFAULT, true);
            }

            if (text.getHorizontalBar() != null) {
                text.getHorizontalBar().setVisible(r2.width <= p.x);
            }

            if (text.getVerticalBar() != null) {
                text.getVerticalBar().setVisible(r2.height <= p.y);
            }

            text.getParent().layout(true);
            text.showSelection();
        }
    }
}
