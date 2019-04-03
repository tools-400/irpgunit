/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local;

import java.text.DecimalFormat;

import de.tools400.rpgunit.core.extensions.view.IRPGUnitSpooledFile;

public class UnitTestReportFile implements IRPGUnitSpooledFile {

    private String testSuite;

    private String connectionName;

    private String name;

    private int number;

    private String jobName;

    private String jobUser;

    private String jobNumber;

    private DecimalFormat numberFormatter;

    public UnitTestReportFile(String aTestSuite) {
        this.testSuite = aTestSuite;
        this.numberFormatter = new DecimalFormat("######"); //$NON-NLS-1$
    }

    @Override
    public String getTestSuite() {
        return testSuite;
    }

    @Override
    public String getConnectionName() {
        return connectionName;
    }

    public void setSystem(String system) {
        this.connectionName = system;
    }

    @Override
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public int getNumber() {
        return number;
    }

    public void setNumber(int number) {
        this.number = number;
    }

    @Override
    public String getJobName() {
        return jobName;
    }

    public void setJobName(String jobName) {
        this.jobName = jobName;
    }

    @Override
    public String getJobUser() {
        return jobUser;
    }

    public void setJobUser(String jobUser) {
        this.jobUser = jobUser;
    }

    @Override
    public String getJobNumber() {
        return jobNumber;
    }

    public void setJobNumber(String jobNumber) {
        this.jobNumber = jobNumber;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }

        if (o.getClass() != this.getClass()) {
            return false;
        }

        UnitTestReportFile tReportFile = (UnitTestReportFile)o;
        return jobName == tReportFile.getJobName() && jobNumber == tReportFile.getJobNumber() && jobUser == tReportFile.getJobUser()
            && name == tReportFile.getName() && number == tReportFile.getNumber() && connectionName == tReportFile.getConnectionName()
            && connectionName == tReportFile.getTestSuite();
    }

    @Override
    public int hashCode() {
        int tHash = 7;
        tHash = 31 * tHash + (null == jobName ? 0 : jobName.hashCode());
        tHash = 31 * tHash + (null == jobNumber ? 0 : jobNumber.hashCode());
        tHash = 31 * tHash + (null == jobUser ? 0 : jobUser.hashCode());
        tHash = 31 * tHash + (null == name ? 0 : name.hashCode());
        tHash = 31 * tHash + number;
        tHash = 31 * tHash + (null == connectionName ? 0 : connectionName.hashCode());
        tHash = 31 * tHash + (null == testSuite ? 0 : testSuite.hashCode());
        return tHash;
    }

    @Override
    public int compareTo(IRPGUnitSpooledFile o) {
        if (o == null) {
            return -1;
        }
        return getTestSuite().compareTo(o.getTestSuite());
    }

    @Override
    public String toString() {

        StringBuilder buffer = new StringBuilder();

        buffer.append(name);
        buffer.append(" #"); //$NON-NLS-1$
        buffer.append(numberFormatter.format(number));
        buffer.append(" Job:"); //$NON-NLS-1$
        buffer.append(jobNumber);
        buffer.append("/"); //$NON-NLS-1$
        buffer.append(jobUser);
        buffer.append("/"); //$NON-NLS-1$
        buffer.append(jobName);

        return buffer.toString();
    }
}
