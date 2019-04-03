/*******************************************************************************
 * Copyright (c) 2013-2018 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.action;

import org.eclipse.swt.graphics.Image;

public interface IObjectInError {

    public Image getImage();

    public String getObjectName();

    public String getErrorMessage();

}
