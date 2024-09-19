/*******************************************************************************
 * Copyright (c) 2012-2024 iSphere Project Owners
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.host.api;

import java.util.LinkedList;
import java.util.List;

import com.ibm.as400.access.AS400;
import com.ibm.as400.access.AS400Message;
import com.ibm.as400.access.ProgramCall;
import com.ibm.as400.data.PcmlException;

import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.preferences.Preferences;

/**
 * Class for executing program calls with a PCML description.
 */
public abstract class APIProgramCall extends ProgramCall {

    private static final long serialVersionUID = -2642963108490762188L;

    private String programName;
    private String libraryName;
    private String pcmlName;

    private List<String> errorMessages;

    public APIProgramCall(String programName, String pcmlName) {
        this.programName = programName;
        this.libraryName = Preferences.getInstance().getProductLibrary();
        this.pcmlName = pcmlName;
    }

    /**
     * Calls the program on the host.
     * 
     * @param system - AS400 on which the call is executed.
     * @return <code>true</code> on success otherwise <code>false</code>.
     */
    public boolean run(AS400 system) {

        errorMessages = new LinkedList<String>();

        try {

            PcmlProgramCallDocument pcml = new PcmlProgramCallDocument(system, programName, pcmlName, this.getClass().getClassLoader()); // $NON-NLS-1$
            pcml.setPath(programName, getPath(programName, libraryName, "*PGM"));
            setInputParameters(pcml);

            boolean rc = pcml.callProgram(programName);

            if (rc == false) {

                AS400Message[] msgs = pcml.getMessageList(programName); // $NON-NLS-1$
                for (int idx = 0; idx < msgs.length; idx++) {
                    String msg = msgs[idx].getID() + " - " + msgs[idx].getText(); //$NON-NLS-1$
                    RPGUnitCorePlugin.logError(msg, null);
                    errorMessages.add(msg);
                }
                RPGUnitCorePlugin.logError(String.format("*** Call to %s failed. See previous messages ***", programName), null); //$NON-NLS-1$
                return false;

            } else {
                getOutputParameters(pcml);
            }

        } catch (PcmlException e) {
            errorMessages.add(e.getLocalizedMessage());
            RPGUnitCorePlugin.logError(String.format("Failed calling the %s API.", programName), e);
            return false;
        }

        return true;
    }

    /**
     * Returns the name of the program.
     * 
     * @return program name
     */
    public String getProgramName() {
        return programName;
    }

    /**
     * Returns the name of the library where the program is stored.
     * 
     * @return library name
     */
    public String getProgramLibraryName() {
        return libraryName;
    }

    /**
     * Returns the error messages of the last program call.
     * 
     * @return error messages
     */
    public String[] getErrorMessages() {
        return errorMessages.toArray(new String[errorMessages.size()]);
    }

    /**
     * Sets the input parameters before the program call.
     * 
     * @param pcml - PCML document for calling the program.
     * @throws PcmlException
     */
    protected abstract void setInputParameters(PcmlProgramCallDocument pcml) throws PcmlException;

    /**
     * Gets the output parameters before the program call.
     * 
     * @param pcml - PCML document for calling the program.
     * @throws PcmlException
     */
    protected abstract void getOutputParameters(PcmlProgramCallDocument pcml) throws PcmlException;

    /**
     * Produces the path to an IBM i object.
     * 
     * @param object - name of the object
     * @param library - library that contains the object
     * @param type - type of the object
     * @return object path
     */
    protected String getPath(String object, String library, String type) {
        if (type.startsWith("*")) { //$NON-NLS-1$
            type = type.substring(1);
        }
        if (library.equals("QSYS")) { //$NON-NLS-1$
            return String.format("/QSYS.LIB/%s.%s", object, type); //$NON-NLS-1$
        } else {
            return String.format("/QSYS.LIB/%s.LIB/%s.%s", library, object, type); //$NON-NLS-1$
        }
    }
}
