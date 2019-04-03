/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.extensions.view;

public interface IRPGUnitSpooledFile extends Comparable<IRPGUnitSpooledFile> {

    public String getTestSuite();

    public String getConnectionName();

    public String getName();

    public int getNumber();

    public String getJobName();

    public String getJobUser();

    public String getJobNumber();

    @Override
    public boolean equals(Object o);

    @Override
    public int hashCode();
}
