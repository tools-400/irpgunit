/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.extensions.testcase;

import de.tools400.rpgunit.core.extensions.view.IRPGUnitSpooledFile;

public interface IRPGUnitUpdateTestResult {
    public void updateTestResult(IRPGUnitSpooledFile[] aSpooledFiles);
}
