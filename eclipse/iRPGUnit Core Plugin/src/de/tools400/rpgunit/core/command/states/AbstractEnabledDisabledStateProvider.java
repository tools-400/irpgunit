/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.command.states;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.ui.AbstractSourceProvider;
import org.eclipse.ui.ISources;

@SuppressWarnings("all")
public abstract class AbstractEnabledDisabledStateProvider extends AbstractSourceProvider {

    public final static String ENABLED = "ENABLED"; //$NON-NLS-1$

    public final static String DISABLED = "DISABLED"; //$NON-NLS-1$

    enum State {
        NOT_LOADED,
        ENABLED,
        DISABLED
    };

    private State curState = State.NOT_LOADED;

    @Override
    public void dispose() {
    }

    @Override
    public String[] getProvidedSourceNames() {
        return new String[] { getState() };
    }

    // You cannot return NULL
    @Override
    public Map getCurrentState() {

        Map map = new HashMap(1);
        if (curState == State.ENABLED)
            map.put(getState(), ENABLED);
        else if (curState == State.DISABLED)
            map.put(getState(), DISABLED);
        else {
            map.put(getState(), DISABLED);
        }

        return map;
    }

    public void setEnabled(boolean anEnabled) {
        if (anEnabled) {
            curState = State.ENABLED;
            fireSourceChanged(ISources.WORKBENCH, getState(), ENABLED);
        } else {
            curState = State.DISABLED;
            fireSourceChanged(ISources.WORKBENCH, getState(), DISABLED);
        }
    }

    protected abstract String getState();
}
