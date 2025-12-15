/*******************************************************************************
 * Copyright (c) 2013-2025 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.ui.view;

import java.util.LinkedList;
import java.util.List;

import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.resource.ColorRegistry;
import org.eclipse.jface.resource.JFaceResources;
import org.eclipse.jface.util.IPropertyChangeListener;
import org.eclipse.jface.util.PropertyChangeEvent;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.CaretEvent;
import org.eclipse.swt.custom.StyleRange;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.events.MouseAdapter;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseTrackAdapter;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Label;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.internal.WorkbenchPlugin;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.helpers.ClipboardHelper;
import de.tools400.rpgunit.core.helpers.StringHelper;
import de.tools400.rpgunit.core.model.local.UnitTestCaseEvent;
import de.tools400.rpgunit.core.model.local.UnitTestLogValue;

public class CompareViewerPanel implements ISelectionChangedListener, IPropertyChangeListener {

    private static final String WORKBENCH_PLUGIN_CONFLICTING_COLOR_ID = "CONFLICTING_COLOR";
    private static final String END_OF_TEXT_MARKER = "«";
    private static final String RGB_VALUE_DELIMITER = ",";

    private static final int SCROLLING_MULTIPLIER_0 = 1;
    private static final int SCROLLING_MULTIPLIER_1 = 10;
    private static final int SCROLLING_MULTIPLIER_2 = 50;

    private final String COMPARE_CONFLICT_COLOR_ID = "de.tools400.rpgunit.core.ui.colors.compare.conflict";
    private final int[] DEFAULT_COMPARE_CONFLICT_COLOR_RGB_VALUES = new int[] { 255, 0, 0 };

    private Composite parent;
    private Font courier;
    private WorkbenchPlugin workbenchPLugin;

    private UnitTestCaseEvent testCaseEvent;

    private Composite mainPanel;
    private StyledText txtExpected;
    private StyledText txtActual;

    public CompareViewerPanel(Composite parent) {
        this.parent = parent;
        this.courier = JFaceResources.getFont(JFaceResources.TEXT_FONT);
        this.workbenchPLugin = WorkbenchPlugin.getDefault();

        getWorkbenchPluginPreferenceStore().addPropertyChangeListener(this);
    }

    public void dispose() {
        getWorkbenchPluginPreferenceStore().removePropertyChangeListener(this);
    }

    public Composite createPanel() {

        mainPanel = new Composite(parent, SWT.NONE);
        GridLayout mainPanelLayout = new GridLayout(3, false);
        mainPanelLayout.verticalSpacing = 0;
        mainPanel.setLayout(mainPanelLayout);
        GridData gridData = new GridData(GridData.FILL_HORIZONTAL);
        gridData.horizontalIndent = 0;
        gridData.verticalIndent = 0;
        mainPanel.setLayoutData(gridData);

        txtExpected = createLogValueText(mainPanel, Messages.Label_Expected);
        txtActual = createLogValueText(mainPanel, Messages.Label_Actual);

        setInput(null);

        return mainPanel;
    }

    private StyledText createLogValueText(Composite panel, String label) {

        Label lblValue = new Label(panel, SWT.NONE);
        lblValue.setText(label);

        Label btnCopy = new Label(panel, SWT.NONE);
        btnCopy.setImage(RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_COPY));
        btnCopy.setToolTipText(Messages.Tooltip_copy_button);

        StyledText txtValue = new StyledText(panel, SWT.BORDER);
        txtValue.setToolTipText(Messages.bind(Messages.Tooltip_test_value, SCROLLING_MULTIPLIER_1, SCROLLING_MULTIPLIER_2));
        txtValue.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
        txtValue.setEditable(false);
        txtValue.setFont(courier);
        txtValue.addMouseWheelListener(new MouseWheelListener());

        btnCopy.addMouseListener(new CopyToClipboardListener(txtValue));
        btnCopy.addMouseTrackListener(new ChangeImageListener(btnCopy));

        // synchronize scrolling of expected and actual values
        txtValue.addCaretListener(new CaretListener());

        return txtValue;
    }

    private IPreferenceStore getWorkbenchPluginPreferenceStore() {
        return workbenchPLugin.getPreferenceStore();
    }

    private class ChangeImageListener extends MouseTrackAdapter {

        private Label btnCopy;

        public ChangeImageListener(Label btnCopy) {
            this.btnCopy = btnCopy;
        }

        @Override
        public void mouseEnter(MouseEvent e) {
            btnCopy.setImage(RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_COPY_HOOVERED));
        }

        @Override
        public void mouseExit(MouseEvent e) {
            btnCopy.setImage(RPGUnitCorePlugin.getDefault().getImageRegistry().get(RPGUnitCorePlugin.IMAGE_COPY));
        }
    }

    private class CopyToClipboardListener extends MouseAdapter {
        private StyledText textWidget;

        public CopyToClipboardListener(StyledText textWidget) {
            this.textWidget = textWidget;
        }

        @Override
        public void mouseUp(MouseEvent event) {
            StringBuilder buffer = new StringBuilder();

            if (event.stateMask == (SWT.CTRL | SWT.NO_FOCUS)) {
                buffer.append(getText(txtExpected));
                buffer.append("\n");
                buffer.append(getText(txtActual));
            }
            if (event.stateMask == (SWT.SHIFT | SWT.NO_FOCUS)) {
                buffer.append(Messages.Label_Expected);
                buffer.append(": ");
                buffer.append(getText(txtExpected));
                buffer.append("\n");
                buffer.append(Messages.Label_Actual);
                buffer.append(": ");
                buffer.append(getText(txtActual));
            } else {
                buffer.append(getText(textWidget));
            }

            ClipboardHelper.setText(buffer.toString());
        }

        private String getText(StyledText widget) {
            String text = StringHelper.trimR(widget.getText());
            if (text.endsWith(END_OF_TEXT_MARKER)) {
                text = text.substring(0, text.length() - 1);
            }
            return text;
        }
    }

    private class CaretListener implements org.eclipse.swt.custom.CaretListener {

        @Override
        public void caretMoved(CaretEvent event) {
            Object widget = event.getSource();
            int newTopIndex = -1;
            StyledText newObject = null;
            if (widget == txtExpected) {
                newTopIndex = txtExpected.getCaretOffset();
                newObject = txtActual;
            } else if (widget == txtActual) {
                newTopIndex = txtActual.getCaretOffset();
                newObject = txtExpected;
            }
            if (newTopIndex <= Math.min(txtExpected.getText().length(), txtActual.getText().length())) {
                newObject.setCaretOffset(newTopIndex);
                newObject.setHorizontalIndex(newTopIndex);
            }
        }
    }

    private class MouseWheelListener implements org.eclipse.swt.events.MouseWheelListener {

        @Override
        public void mouseScrolled(MouseEvent event) {
            StyledText textWidget = (StyledText)event.widget;
            int length = textWidget.getText().length();
            int offset = textWidget.getCaretOffset();
            int stepWidth;
            if (event.stateMask == SWT.SHIFT) {
                stepWidth = SCROLLING_MULTIPLIER_2;
            } else if (event.stateMask == SWT.CTRL) {
                stepWidth = SCROLLING_MULTIPLIER_1;
            } else {
                stepWidth = SCROLLING_MULTIPLIER_0;
            }
            if (event.count > 0) {
                textWidget.setCaretOffset(Math.min(offset - stepWidth, length));
            } else if (event.count < 0) {
                textWidget.setCaretOffset(Math.max(offset + stepWidth, 0));
            }
        }
    }

    public boolean isVisible() {
        if (mainPanel != null) {
            return true;
        } else {
            return false;
        }
    }

    public void setVisible(boolean visible) {

        if (visible) {
            createPanel();
            doDisplayValue();
        } else {
            mainPanel.dispose();
            mainPanel = null;
        }
    }

    public void setInput(UnitTestCaseEvent testCaseEvent) {

        this.testCaseEvent = testCaseEvent;

        doDisplayValue();
    }

    private void doDisplayValue() {

        if (!isVisible()) {
            return;
        }

        clearCompareResult();

        if (this.testCaseEvent == null) {
            setWidgetEnablements();
            return;
        }

        UnitTestLogValue expectedValue = this.testCaseEvent.getExpected();
        UnitTestLogValue actualValue = this.testCaseEvent.getActual();

        if (expectedValue == null || actualValue == null) {
            return;
        }

        String expectedText = getTestValue(expectedValue);
        String actualText = getTestValue(actualValue);

        if (expectedText.length() < actualText.length()) {
            expectedText = StringHelper.getFixLength(expectedText, actualText.length());
        } else {
            actualText = StringHelper.getFixLength(actualText, expectedText.length());
        }

        txtExpected.setText(expectedText);
        txtActual.setText(actualText);

        compareValue(expectedText, actualText);

        setWidgetEnablements();
    }

    private void setWidgetEnablements() {

        boolean isEnabled = false;

        if (testCaseEvent != null) {
            if (hasTestValue(testCaseEvent.getExpected()) || hasTestValue(testCaseEvent.getActual())) {
                isEnabled = true;
            }
        }

        mainPanel.setEnabled(isEnabled);

        setLogValueEnabledment(txtExpected, isEnabled);
        setLogValueEnabledment(txtActual, isEnabled);
    }

    private void setLogValueEnabledment(StyledText widget, boolean isEnabled) {

        widget.setEnabled(isEnabled);

        if (isEnabled) {
            widget.setBackground(Display.getDefault().getSystemColor(SWT.COLOR_LIST_BACKGROUND));
        } else {
            widget.setBackground(Display.getDefault().getSystemColor(SWT.COLOR_WIDGET_BACKGROUND));
        }
    }

    private boolean hasTestValue(UnitTestLogValue value) {

        if (value != null && value.getLength() > 0) {
            return true;
        }

        return false;
    }

    private String getTestValue(UnitTestLogValue logValue) {

        String text = "";
        if (hasTestValue(logValue)) {
            text = logValue.getValue() + END_OF_TEXT_MARKER;
        }

        return text;
    }

    @Override
    public void selectionChanged(SelectionChangedEvent event) {

        ISelection selection = event.getSelection();
        if (selection instanceof IStructuredSelection) {
            IStructuredSelection structuredSelection = (IStructuredSelection)selection;
            Object item = structuredSelection.getFirstElement();
            if (!(item instanceof UnitTestCaseEvent)) {
                // clearCompareResult();
                setInput(null);
                return;
            }

            UnitTestCaseEvent testCaseEvent = (UnitTestCaseEvent)item;
            setInput(testCaseEvent);
        } else {
            setInput(null);
        }
    }

    private void compareValue(String expected, String actual) {

        Color compareConflictColor = getCompareConflictColor();

        List<StyleRange> ranges = new LinkedList<StyleRange>();

        StyleRange range = null;
        int offset = 0;

        while (offset < Math.min(expected.length(), actual.length())) {
            String e1 = getCurrentCharacter(expected, offset);
            String a1 = getCurrentCharacter(actual, offset);

            boolean isEqual = false;
            if (e1.equals(a1)) {
                isEqual = true;
            }

            if (!isEqual) {
                if (range == null) {
                    range = new StyleRange();
                    range.foreground = compareConflictColor;
                    range.start = offset;
                    range.length = 0;
                }
                range.length++;
            } else {
                if (range != null) {
                    ranges.add(range);
                    range = null;
                }
            }
            offset++;
        }

        if (range != null) {
            ranges.add(range);
            range = null;
        }

        txtActual.setStyleRanges(ranges.toArray(new StyleRange[ranges.size()]));

        if (expected.length() > actual.length()) {
            range = new StyleRange();
            range.foreground = compareConflictColor;
            range.start = actual.length();
            range.length = expected.length() - actual.length();
            txtExpected.setStyleRange(range);
        }
    }

    private String getCurrentCharacter(String value, int offset) {
        String c1;
        if (offset < value.length()) {
            c1 = value.substring(offset, offset + 1);
        } else {
            c1 = null;
        }
        return c1;
    }

    private void clearCompareResult() {

        if (!isVisible()) {
            return;
        }

        txtExpected.setText("");
        txtExpected.setStyleRanges(new StyleRange[0]);
        txtActual.setText("");
        txtActual.setStyleRanges(new StyleRange[0]);
    }

    private Color getCompareConflictColor() {

        ColorRegistry registry = getColorRegistry();
        if (registry.get(COMPARE_CONFLICT_COLOR_ID) == null) {

            // Get conflict color from preferences of WorkbenchPlugin
            String conflictingColor = getWorkbenchPluginPreferenceStore().getString(WORKBENCH_PLUGIN_CONFLICTING_COLOR_ID);
            if (StringHelper.isNullOrEmpty(conflictingColor)) {
                conflictingColor = getWorkbenchPluginPreferenceStore().getDefaultString(WORKBENCH_PLUGIN_CONFLICTING_COLOR_ID);
            }

            if (StringHelper.isNullOrEmpty(conflictingColor)) {
                // Fallback to default color: RED
                int r = DEFAULT_COMPARE_CONFLICT_COLOR_RGB_VALUES[0];
                int g = DEFAULT_COMPARE_CONFLICT_COLOR_RGB_VALUES[1];
                int b = DEFAULT_COMPARE_CONFLICT_COLOR_RGB_VALUES[2];
                storeCompareConflicColor(registry, r, g, b);
            } else {
                String[] rgbValues = conflictingColor.split(RGB_VALUE_DELIMITER);
                storeCompareConflicColor(registry, rgbValues);
            }

        }

        return registry.get(COMPARE_CONFLICT_COLOR_ID);
    }

    private void storeCompareConflicColor(ColorRegistry registry, String[] rgbValues) {

        int r;
        int g;
        int b;

        try {
            r = Integer.parseInt(rgbValues[0]);
            g = Integer.parseInt(rgbValues[1]);
            b = Integer.parseInt(rgbValues[2]);
        } catch (Exception e) {
            r = DEFAULT_COMPARE_CONFLICT_COLOR_RGB_VALUES[0];
            g = DEFAULT_COMPARE_CONFLICT_COLOR_RGB_VALUES[1];
            b = DEFAULT_COMPARE_CONFLICT_COLOR_RGB_VALUES[2];
        }

        storeCompareConflicColor(registry, r, g, b);
    }

    private void storeCompareConflicColor(ColorRegistry registry, int r, int g, int b) {

        RGB rgb = new RGB(r, g, b);
        registry.put(COMPARE_CONFLICT_COLOR_ID, rgb);
    }

    private ColorRegistry getColorRegistry() {
        return PlatformUI.getWorkbench().getThemeManager().getCurrentTheme().getColorRegistry();
    }

    @Override
    public void propertyChange(PropertyChangeEvent event) {

        ColorRegistry registry = getColorRegistry();

        Color compareConflicColorOld = (Color)registry.get(COMPARE_CONFLICT_COLOR_ID);
        if (compareConflicColorOld != null) {
            compareConflicColorOld.dispose();
        }

        String[] colorParts = ((String)event.getNewValue()).split(RGB_VALUE_DELIMITER);
        storeCompareConflicColor(registry, colorParts);

        doDisplayValue();
    }
}
