/*******************************************************************************
 * Copyright (c) 2013-2018 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.swt.widgets;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.VerifyEvent;
import org.eclipse.swt.events.VerifyListener;

public class NumericOnlyVerifyListener implements VerifyListener {

    private boolean isDecimalPositions;
    private boolean hasSign;

    public NumericOnlyVerifyListener() {
        this(false);
    }

    public NumericOnlyVerifyListener(boolean anIsDecimalPositions) {
        this(anIsDecimalPositions, false);
    }

    public NumericOnlyVerifyListener(boolean anIsDecimalPositions, boolean anHasSign) {
        isDecimalPositions = anIsDecimalPositions;
        hasSign = anHasSign;
    }

    public void verifyText(VerifyEvent event) {
        switch (event.keyCode) {
        case SWT.BS: // Backspace
        case SWT.DEL: // Delete
        case SWT.HOME: // Home
        case SWT.END: // End
        case SWT.ARROW_LEFT: // Left arrow
        case SWT.ARROW_RIGHT: // Right arrow
            return;
        }

        if (isDecimalPositions) {
            if (event.character == ',' || event.character == '.' || event.keyCode == SWT.KEYPAD_DECIMAL) {
                return;
            }
        }

        if (hasSign) {
            if (event.character == '+' || event.character == '-') {
                return;
            }
        }

        if (event.keyCode != 0) {
            if (!Character.isDigit(event.character)) {
                event.doit = false; // disallow the action
            }
        }
    }
}
