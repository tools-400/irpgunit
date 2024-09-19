package de.tools400.rpgunit.core.helpers;

import com.ibm.as400.access.AS400;

public class OS400Release {

    public static final String V7R3M0 = "V7R3M0";
    public static final String V7R4M0 = "V7R4M0";
    public static final String V7R5M0 = "V7R5M0";

    private static final int PART_LENGTH = 1;

    private int vrs;
    private int rls;
    private int mod;

    public OS400Release(AS400 system) throws Exception {
        this.vrs = ((system.getVRM() & 0xFFFF0000) >> 16);
        this.rls = ((system.getVRM() & 0x0000FF00) >> 8);
        this.mod = ((system.getVRM() & 0x000000FF) >> 8);
    }

    public String getRelease() {
        String release = String.format("V%sR%sM%s", fixLength(vrs), fixLength(rls), fixLength(mod));
        return release;
    }

    public String getReleaseShort() {

        StringBuilder release = new StringBuilder();
        release.append(vrs);
        release.append(".");
        release.append(rls);

        if (mod > 0) {
            release.append(".");
            release.append(mod);
        }

        return release.toString();
    }

    private static String fixLength(int value) {

        int currentLength = Integer.toString(value).length();
        if (currentLength >= PART_LENGTH) {
            return Integer.toString(value);
        }

        StringBuffer fixLength = new StringBuffer();

        int remainingLength = PART_LENGTH - currentLength;
        while (remainingLength > 0) {
            fixLength.append("0");
            remainingLength--;
        }

        fixLength.append(value);

        return fixLength.toString();
    }

    @Override
    public String toString() {
        return getReleaseShort();
    }
}
