/*******************************************************************************
 * Copyright (c) 2013-2019 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.helpers;

import com.ibm.as400.access.AS400;
import com.ibm.as400.access.Job;
import com.ibm.as400.access.JobLog;
import com.ibm.as400.access.MessageQueue;
import com.ibm.as400.access.QueuedMessage;

public final class JobLogHelper {

    public static byte[] getNewestMessageKey(Job serverJob) throws Exception {

        byte[] startingMessageKey = new byte[] { 0x00, 0x00, 0x00, 0x00 };
        QueuedMessage[] jobLogMessages = getJobLog(serverJob, MessageQueue.NEWEST, 1);
        if (jobLogMessages.length > 0) {
            startingMessageKey = jobLogMessages[0].getKey();
        }

        return startingMessageKey;
    }

    public static QueuedMessage[] getJobLog(Job serverJob, byte[] startingMessageKey) throws Exception {
        return getJobLog(serverJob, startingMessageKey, -1);
    }

    public static QueuedMessage[] getJobLog(Job serverJob, byte[] startingMessageKey, int count) throws Exception {

        AS400 system = serverJob.getSystem();
        String job = serverJob.getName();
        String user = serverJob.getUser();
        String number = serverJob.getNumber();

        JobLog jobLog = null;

        try {

            jobLog = new JobLog(system, job, user, number);
            jobLog.setListDirection(true);
            jobLog.clearAttributesToRetrieve();
            jobLog.addAttributeToRetrieve(JobLog.REPLACEMENT_DATA);
            jobLog.addAttributeToRetrieve(JobLog.MESSAGE_WITH_REPLACEMENT_DATA);
            jobLog.addAttributeToRetrieve(JobLog.MESSAGE_HELP_WITH_REPLACEMENT_DATA);
            jobLog.addAttributeToRetrieve(JobLog.SENDING_PROGRAM_NAME);
            jobLog.addAttributeToRetrieve(JobLog.SENDING_MODULE_NAME);
            jobLog.addAttributeToRetrieve(JobLog.SENDING_PROCEDURE_NAME);
            jobLog.addAttributeToRetrieve(JobLog.SENDING_STATEMENT_NUMBERS);
            jobLog.addAttributeToRetrieve(JobLog.RECEIVING_PROGRAM_NAME);
            jobLog.addAttributeToRetrieve(JobLog.RECEIVING_MODULE_NAME);
            jobLog.addAttributeToRetrieve(JobLog.RECEIVING_PROCEDURE_NAME);
            jobLog.addAttributeToRetrieve(JobLog.RECEIVING_STATEMENT_NUMBERS);
            jobLog.setStartingMessageKey(startingMessageKey);
            jobLog.load();

            QueuedMessage[] messages;

            if (count <= 0) {
                messages = jobLog.getMessages(-1, -1);
            } else {
                if (count > jobLog.getLength()) {
                    count = jobLog.getLength();
                }
                messages = jobLog.getMessages(jobLog.getLength() - count, count);
            }

            return messages;

        } catch (Throwable e) {
            e.printStackTrace();

        } finally {
            if (jobLog != null) {
                jobLog.close();
            }
        }

        return new QueuedMessage[0];
    }

}
