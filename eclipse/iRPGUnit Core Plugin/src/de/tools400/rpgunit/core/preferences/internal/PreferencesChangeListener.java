/*******************************************************************************
 * Copyright (c) 2013-2016 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.preferences.internal;

import org.eclipse.jface.util.IPropertyChangeListener;
import org.eclipse.jface.util.PropertyChangeEvent;

import de.tools400.rpgunit.core.extensions.preferences.RPGUnitProductLibraryEvaluateContributionsHandler;
import de.tools400.rpgunit.core.preferences.Preferences;

public class PreferencesChangeListener implements IPropertyChangeListener {

    @Override
    public void propertyChange(PropertyChangeEvent anEvent) {
        if (anEvent.getProperty() == Preferences.PRODUCT_LIBRARY) {
            RPGUnitProductLibraryEvaluateContributionsHandler tHandler = new RPGUnitProductLibraryEvaluateContributionsHandler();
            if (anEvent.getNewValue() != null && (anEvent.getNewValue() instanceof String)) {
                String tLibrary = (String)anEvent.getNewValue();
                tHandler.execute(tLibrary);
            }
        }
    }
}
