/*******************************************************************************
 * Copyright (c) project_year-2020 Tools/400
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.helpers;

import com.ibm.as400.access.QueuedMessage;

public final class QueuedMessageHelper {

    private static final String COMP = "*COMP"; //$NON-NLS-1$
    private static final String DIAG = "*DIAG"; //$NON-NLS-1$
    private static final String INFO = "*INFO"; //$NON-NLS-1$
    private static final String INQUIRY = "*INQUIRY"; //$NON-NLS-1$
    private static final String COPY = "*COPY"; //$NON-NLS-1$
    private static final String REQUEST = "*REQUEST"; //$NON-NLS-1$
    private static final String NOTIFY = "*NOTIFY"; //$NON-NLS-1$
    private static final String ESCAPE = "*ESCAPE"; //$NON-NLS-1$
    private static final String REPLY = "*REPLY"; //$NON-NLS-1$

    public static final String IBM_NULL = "*N"; //$NON-NLS-1$

    private QueuedMessageHelper() {
    }

    public static String getMessageType(QueuedMessage message) {

        int type = message.getType();

        switch (type) {
        case QueuedMessage.COMPLETION:
            return COMP;
        case QueuedMessage.DIAGNOSTIC:
            return DIAG;
        case QueuedMessage.INFORMATIONAL:
            return INFO;
        case QueuedMessage.INQUIRY:
            return INQUIRY;
        case QueuedMessage.SENDERS_COPY:
            return COPY;
        case QueuedMessage.REQUEST:
        case QueuedMessage.REQUEST_WITH_PROMPTING:
            return REQUEST;
        case QueuedMessage.NOTIFY:
        case QueuedMessage.NOTIFY_NOT_HANDLED:
            return NOTIFY;
        case QueuedMessage.ESCAPE:
        case QueuedMessage.ESCAPE_NOT_HANDLED:
            return ESCAPE;
        case QueuedMessage.REPLY_FROM_SYSTEM_REPLY_LIST:
        case QueuedMessage.REPLY_MESSAGE_DEFAULT_USED:
        case QueuedMessage.REPLY_NOT_VALIDITY_CHECKED:
        case QueuedMessage.REPLY_SYSTEM_DEFAULT_USED:
        case QueuedMessage.REPLY_VALIDITY_CHECKED:
            return REPLY;

        default:
            return IBM_NULL; // $NON-NLS-1$
        }
    }

    public static boolean isRequestMessage(QueuedMessage message) {

        int type = message.getType();
        if (type == QueuedMessage.REQUEST || type == QueuedMessage.REQUEST_WITH_PROMPTING) {
            return true;
        }

        return false;
    }

}
