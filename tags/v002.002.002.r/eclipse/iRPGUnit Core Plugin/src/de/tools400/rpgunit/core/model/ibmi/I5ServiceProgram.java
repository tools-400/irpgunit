/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.ibmi;

import java.util.HashSet;
import java.util.Set;

public class I5ServiceProgram extends I5Object {

    Set<String> procedures;

    public I5ServiceProgram(String name, I5Library lib) {
        super(name, "*SRVPGM", lib); //$NON-NLS-1$

        this.procedures = new HashSet<String>();
    }

    public void addProcedure(String name) {

        procedures.add(name);
    }

    public String[] getProcedures() {

        return procedures.toArray(new String[procedures.size()]);
    }

}
