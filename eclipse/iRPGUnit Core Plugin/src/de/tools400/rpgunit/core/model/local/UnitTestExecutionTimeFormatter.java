/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local;

import java.text.DecimalFormat;

public class UnitTestExecutionTimeFormatter {

    private DecimalFormat df = new DecimalFormat("#,###,###,##0.000"); //$NON-NLS-1$

    public String formatExecutionTime(long executionTime) {
        double tSeconds = 0;
        if (executionTime > 0) {
            double tMicroSeconds = (1000 * 1000);
            tSeconds = executionTime / tMicroSeconds;
        }
        return df.format(tSeconds);
    }

}
