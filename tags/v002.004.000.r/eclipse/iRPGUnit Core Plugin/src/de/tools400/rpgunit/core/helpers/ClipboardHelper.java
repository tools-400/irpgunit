/*******************************************************************************
 * Copyright (c) 2013-2018 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.helpers;

import org.eclipse.swt.dnd.Clipboard;
import org.eclipse.swt.dnd.TextTransfer;
import org.eclipse.swt.dnd.Transfer;
import org.eclipse.swt.dnd.TransferData;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.ui.PlatformUI;

public final class ClipboardHelper {

    private static Clipboard clipboard = new Clipboard(PlatformUI.getWorkbench().getDisplay());

    public static boolean hasTextContents() {
        TransferData[] available = clipboard.getAvailableTypes();
        for (int i = 0; i < available.length; ++i) {
            if (TextTransfer.getInstance().isSupportedType(available[i])) {
                return true;
            }
        }

        return false;
    }

    public static String getText() {

        TextTransfer textTransfer = TextTransfer.getInstance();
        Object data = clipboard.getContents(textTransfer);
        if (data instanceof String) {
            return (String)data;
        }

        return null;
    }

    public static void setText(String text) {

        TextTransfer textTransfer = TextTransfer.getInstance();
        clipboard.setContents(new Object[] { text }, new Transfer[] { textTransfer });
    }

    public static void setTableItemsText(TableItem[] tableItems) {

        StringBuilder buffer = new StringBuilder();
        for (TableItem tableItem : tableItems) {
            if (tableItem.getText() != null) {
                buffer.append(tableItem.getText());
                buffer.append("\n");
            }
        }

        TextTransfer textTransfer = TextTransfer.getInstance();
        clipboard.setContents(new Object[] { buffer.toString() }, new Transfer[] { textTransfer });
    }
}
