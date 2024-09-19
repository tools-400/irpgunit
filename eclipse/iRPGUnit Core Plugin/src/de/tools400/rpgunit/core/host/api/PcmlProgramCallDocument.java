/*******************************************************************************
 * Copyright (c) 2012-2024 iSphere Project Owners
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.host.api;

import com.ibm.as400.access.AS400;
import com.ibm.as400.data.PcmlException;
import com.ibm.as400.data.ProgramCallDocument;

public class PcmlProgramCallDocument extends ProgramCallDocument {

    private static final long serialVersionUID = -5975118008941088001L;

    private String program;

    public PcmlProgramCallDocument(AS400 system, String program, String pcmlDocument, ClassLoader classLoader) throws PcmlException {
        super(system, pcmlDocument, classLoader);

        this.program = program;
    }

    public void setStringValue(String parameterName, String value) throws PcmlException {
        super.setStringValue(getParameterName(parameterName), value);
    }

    public String getStringValue(String parameterName) throws PcmlException {
        return super.getStringValue(getParameterName(parameterName));
    }

    protected String getParameterName(String parameterName) {
        return String.format("%s.%s", program, parameterName);
    }
}
