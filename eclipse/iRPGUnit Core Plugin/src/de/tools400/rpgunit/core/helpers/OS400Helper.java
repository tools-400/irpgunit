/*******************************************************************************
 * Copyright (c) 2012-2024 iSphere Project Owners
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.helpers;

import com.ibm.as400.access.AS400;
import com.ibm.as400.access.CommandCall;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.host.GetPTFStatus;

public final class OS400Helper {

    public static boolean executeCommand(AS400 system, String command) throws Exception {

        CommandCall commandCall = new CommandCall(system);

        if (commandCall.run(command.toString())) {
            return true;
        } else {
            return false;
        }
    }

    public static String getRelease(AS400 system) throws Exception {
        return new OS400Release(system).getRelease();
    }

    public static String getPTFStatus(AS400 system, String ptf) throws Exception {

        GetPTFStatus program = new GetPTFStatus();
        if (!program.run(system, ptf)) {
            String[] errorMessages = program.getErrorMessages();
            if (errorMessages.length > 0) {
                throw new Exception(Messages.bind(Messages.Could_not_execute_program_A_Reason_B, program.getProgramName(), errorMessages[0]));
            } else {
                throw new Exception(Messages.bind(Messages.Could_not_execute_program_A_Reason_B, program.getProgramName(), "unknown"));
            }
        }

        return program.getPTFStatus();
    }

    public static String getReleaseShort(AS400 system) throws Exception {
        return new OS400Release(system).getReleaseShort();
    }
}
