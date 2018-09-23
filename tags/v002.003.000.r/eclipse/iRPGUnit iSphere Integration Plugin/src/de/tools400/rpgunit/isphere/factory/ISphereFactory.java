/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.isphere.factory;

import java.sql.Time;
import java.util.Date;

import biz.isphere.base.internal.IBMiHelper;
import biz.isphere.core.ibmi.contributions.extension.handler.IBMiHostContributionsHandler;
import biz.isphere.core.spooledfiles.SpooledFile;

import com.ibm.as400.access.AS400;
import com.ibm.as400.access.PrintObject;
import com.ibm.as400.access.QSYSObjectPathName;

import de.tools400.rpgunit.core.extensions.view.IRPGUnitSpooledFile;

public final class ISphereFactory {

    public static SpooledFile createSpooledFile(IRPGUnitSpooledFile reportFile) {

        SpooledFile _spooledFile = null;

        try {

            String connectionName = reportFile.getConnectionName();

            String jobName = reportFile.getJobName();
            String jobNumber = reportFile.getJobNumber();
            String jobUser = reportFile.getJobUser();

            String splfName = reportFile.getName();
            int splfNumber = reportFile.getNumber();

            AS400 system = IBMiHostContributionsHandler.getSystem(connectionName);
            com.ibm.as400.access.SpooledFile toolboxSpooledFile = new com.ibm.as400.access.SpooledFile(system, splfName, splfNumber, jobName,
                jobUser, jobNumber);

            _spooledFile = new SpooledFile();
            _spooledFile.setAS400(toolboxSpooledFile.getSystem());
            _spooledFile.setFile(toolboxSpooledFile.getName());
            _spooledFile.setFileNumber(toolboxSpooledFile.getNumber());
            _spooledFile.setJobName(toolboxSpooledFile.getJobName());
            _spooledFile.setJobUser(toolboxSpooledFile.getJobUser());
            _spooledFile.setJobNumber(toolboxSpooledFile.getJobNumber());
            _spooledFile.setJobSystem(toolboxSpooledFile.getJobSysName());
            _spooledFile.setCreationTimestamp(getCreationDate(toolboxSpooledFile), getCreationTime(toolboxSpooledFile));
            _spooledFile.setStatus(toolboxSpooledFile.getStringAttribute(PrintObject.ATTR_SPLFSTATUS));
            _spooledFile.setOutputQueue(toolboxSpooledFile.getStringAttribute(PrintObject.ATTR_OUTPUT_QUEUE));

            QSYSObjectPathName outQPathName = getOutputQueue(toolboxSpooledFile);
            if (outQPathName != null) {
                _spooledFile.setOutputQueue(outQPathName.getObjectName());
                _spooledFile.setOutputQueueLibrary(outQPathName.getLibraryName());
            }
            _spooledFile.setOutputPriority(toolboxSpooledFile.getStringAttribute(PrintObject.ATTR_OUTPTY));
            _spooledFile.setUserData(toolboxSpooledFile.getStringAttribute(PrintObject.ATTR_USERDATA));
            _spooledFile.setFormType(toolboxSpooledFile.getStringAttribute(PrintObject.ATTR_FORMTYPE));
            _spooledFile.setCopies(toolboxSpooledFile.getIntegerAttribute(PrintObject.ATTR_COPIES));
            _spooledFile.setPages(toolboxSpooledFile.getIntegerAttribute(PrintObject.ATTR_PAGES));
            _spooledFile.setCurrentPage(0);
            _spooledFile.setConnectionName(connectionName);

        } catch (Throwable e) {
            e.printStackTrace();
        }

        return _spooledFile;
    }

    private static Date getCreationDate(com.ibm.as400.access.SpooledFile spooledFile) {

        String splfDate = spooledFile.getCreateDate();

        return IBMiHelper.cyymmddToDate(splfDate);
    }

    private static Time getCreationTime(com.ibm.as400.access.SpooledFile spooledFile) {

        String splfTime = spooledFile.getCreateTime();

        return new Time(IBMiHelper.hhmmssToTime(splfTime).getTime());
    }

    private static QSYSObjectPathName getOutputQueue(com.ibm.as400.access.SpooledFile spooledFile) {

        try {
            QSYSObjectPathName outQPathName = new QSYSObjectPathName(spooledFile.getStringAttribute(PrintObject.ATTR_OUTPUT_QUEUE));
            return outQPathName;
        } catch (Throwable e) {
            return null;
        }
    }

}
