/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.spooledfileviewer.model;

import java.util.Arrays;
import java.util.HashSet;

import de.tools400.rpgunit.core.extensions.view.IRPGUnitSpooledFile;

public class SpooledFilesStore {
    private HashSet<IRPGUnitSpooledFile> spooledFiles = null;

    public SpooledFilesStore() {
        spooledFiles = null;
    }

    public IRPGUnitSpooledFile[] getSpooledFiles() {
        HashSet<IRPGUnitSpooledFile> tSpooledFiles = getOrCreateStore();
        IRPGUnitSpooledFile[] tArray = new IRPGUnitSpooledFile[tSpooledFiles.size()];
        tSpooledFiles.toArray(tArray);
        Arrays.sort(tArray);
        return tArray;
    }

    public int getLength() {
        return getOrCreateStore().size();
    }

    public void setSpooledFiles(IRPGUnitSpooledFile[] aListOfSpooledFiles) {
        HashSet<IRPGUnitSpooledFile> tSpooledFiles = getOrCreateStore();
        tSpooledFiles.clear();
        for (IRPGUnitSpooledFile tSpooledFile : aListOfSpooledFiles) {
            if (!tSpooledFiles.contains(tSpooledFile)) {
                tSpooledFiles.add(tSpooledFile);
            }
        }
    }

    private HashSet<IRPGUnitSpooledFile> getOrCreateStore() {
        if (spooledFiles == null) {
            spooledFiles = new HashSet<IRPGUnitSpooledFile>();
        }
        return spooledFiles;
    }
}
