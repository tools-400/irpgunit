/*******************************************************************************
 * Copyright (c) 2013-2019 iRPGUnit Project Team
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Common Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/cpl-v10.html
 *******************************************************************************/

package de.tools400.rpgunit.core.model.local;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.swt.graphics.Image;

import de.tools400.rpgunit.core.Messages;
import de.tools400.rpgunit.core.RPGUnitCorePlugin;
import de.tools400.rpgunit.core.jobs.ibmi.RPGUnitTestRunner;

public enum Outcome {
    NOT_YET_RUN (Messages.NOT_YET_RUN, RPGUnitTestRunner.RUNNER_OUTCOME_NOT_YET_RUN, 5, RPGUnitCorePlugin.IMAGE_TEST_NOT_YET_RUN),
    CANCELED (Messages.CANCELED, RPGUnitTestRunner.RUNNER_OUTCOME_CANCELED, 4, RPGUnitCorePlugin.IMAGE_TEST_CANCELED),
    ERROR (Messages.ERROR, RPGUnitTestRunner.RUNNER_OUTCOME_ERROR, 3, RPGUnitCorePlugin.IMAGE_TEST_ERROR),
    FAILURE (Messages.FAILED, RPGUnitTestRunner.RUNNER_OUTCOME_FAILED, 2, RPGUnitCorePlugin.IMAGE_TEST_FAILED),
    SUCCESS (Messages.SUCCESS, RPGUnitTestRunner.RUNNER_OUTCOME_SUCCESS, 1, RPGUnitCorePlugin.IMAGE_TEST_SUCCESS);

    private String label;
    private String id;
    private int weight;
    private String imageId;

    private static Map<String, Outcome> outcomes;

    static {
        outcomes = new HashMap<String, Outcome>();
        for (Outcome outcome : Outcome.values()) {
            outcomes.put(outcome.id, outcome);
        }
    }

    private Outcome(String label, String id, int weight, String imageId) {
        this.label = label;
        this.id = id;
        this.weight = weight;
        this.imageId = imageId;
    }

    public String getLabel() {
        return label;
    }

    public String getId() {
        return id;
    }

    public Image getImage() {
        return RPGUnitCorePlugin.getDefault().getImageRegistry().get(imageId);
    }

    public static Outcome find(String id) {
        return outcomes.get(id);
    }

    public static Outcome max(Outcome outcome1, Outcome outcome2) {

        if (outcome1 == null) {
            return outcome2;
        } else if (outcome2 == null) {
            return outcome1;
        } else {
            if (outcome1.weight > outcome2.weight) {
                return outcome1;
            } else {
                return outcome2;
            }
        }
    }

}
