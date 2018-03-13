/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class UnitTestViewerRoot {
    private List<UnitTestSuite> testResults = new ArrayList<UnitTestSuite>();

    public UnitTestViewerRoot() {

    }

    public UnitTestViewerRoot(UnitTestSuite testResult) {
        super();
        this.testResults.add(testResult);
    }

    public UnitTestViewerRoot(UnitTestSuite[] testResults) {
        this.testResults.addAll(Arrays.asList(testResults));
    }

    public void addTestResult(UnitTestSuite testResult) {
        this.testResults.add(testResult);
    }

    public UnitTestSuite[] getTestResults() {
        return testResults.toArray(new UnitTestSuite[testResults.size()]);
    }
}
