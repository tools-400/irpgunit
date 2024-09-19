/*******************************************************************************
 * Copyright (c) 2012-2024 iSphere Project Owners
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.host;

import com.ibm.as400.access.AS400;
import com.ibm.as400.access.CommandCall;
import com.ibm.as400.data.PcmlException;

import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.helpers.StringHelper;
import de.tools400.rpgunit.core.host.api.APIProgramCall;
import de.tools400.rpgunit.core.host.api.PcmlProgramCallDocument;

public class GetPTFStatus extends APIProgramCall {

    private static final long serialVersionUID = 8278417042542914025L;

    private static final String PROGRAM_NAME = "RUGETPTFS"; //$NON-NLS-1$
    private static final String PCML_NAME = "de.tools400.rpgunit.core.host.GetPTFStatus"; //$NON-NLS-1$

    public static final String PTF_STATUS_NOT_LOADED = "NEVER_LOADED";
    public static final String PTF_STATUS_LOADED = "LOADED";
    public static final String PTF_STATUS_APPLIED = "APPLIED";
    public static final String PTF_STATUS_PERMANENTLY_APPLIED = "PERMANENTLY_APPLIED";
    public static final String PTF_STATUS_PERMANENTLY_REMOVED = "PERMANENTLY_REMOVED";
    public static final String PTF_STATUS_DAMAGED = "DAMAGED";
    public static final String PTF_STATUS_SUPERSEDED = "SUPERSEDED";

    // Input parameters
    private static final String I_PTF = "i_ptf";
    private String ptf;

    // Output parameters
    private static final String O_STATUS = "o_status";
    private String ptfStatus;

    public GetPTFStatus() {
        super(PROGRAM_NAME, PCML_NAME);
    }

    public void setPTF(String ptf) {
        this.ptf = ptf;
    }

    public String getPTFStatus() {
        return ptfStatus;
    }

    protected void setInputParameters(PcmlProgramCallDocument pcml) throws PcmlException {
        pcml.setStringValue(I_PTF, ptf);
    }

    public boolean run(AS400 system, String ptf) {
        setPTF(ptf);
        return super.run(system);
    }

    protected void getOutputParameters(PcmlProgramCallDocument pcml) throws PcmlException {
        ptfStatus = pcml.getStringValue(O_STATUS); // $NON-NLS-1$
    }

    public static void main(String[] args) {

        AS400 system = new AS400("wwsent.de.obi.net", "RADDATZ", "just4you0b");
        GetPTFStatus program = new GetPTFStatus();
        program.setLibraryList(system, "RPGUNITDVP");
        if (!program.run(system, "SI85386")) {
            System.out.println(program.getErrorMessages()[0]);
        } else {
            System.out.println("PTF Status: " + program.getPTFStatus());
        }
    }

    private boolean setLibraryList(AS400 system, String... currentLibraryList) {

        String command = "CHGLIBL LIBL(" + StringHelper.concatTokens(currentLibraryList, " ") + ")"; //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        CommandCall commandCall = new CommandCall(system);

        try {

            if (commandCall.run(command)) {
                return true;
            }

        } catch (Exception e) {
            RPGUnitCorePlugin.logError("Failed to set library list.", e);
        }

        return false;
    }
}
