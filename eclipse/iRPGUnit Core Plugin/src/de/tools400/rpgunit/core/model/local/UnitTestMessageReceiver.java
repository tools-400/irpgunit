/*******************************************************************************
 * Copyright (c) 2012-2024 iSphere Project Owners
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local;

import de.tools400.rpgunit.core.Messages;

public class UnitTestMessageReceiver extends AbstractUnitTestMessageProvider {

    public UnitTestMessageReceiver(String aPgmNm, String aPgmLibNm, String aModNm, String aModLibNm, String aProcNm, String aStmtNb) {
        super(aPgmNm, aPgmLibNm, aModNm, aModLibNm, aProcNm, aStmtNb);
    }

    @Override
    public String getType() {
        return Messages.Receiver;
    }
}
