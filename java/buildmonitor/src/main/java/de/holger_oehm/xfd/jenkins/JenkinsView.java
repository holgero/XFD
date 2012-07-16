package de.holger_oehm.xfd.jenkins;

import java.util.Arrays;

public class JenkinsView {
    public static class JenkinsJob {
        private String name;
        private String url;
        private String color;

        BuildState getState() {
            if (color.endsWith("_anime")) {
                return BuildState.BUILDING;
            }
            switch (color) {
            case "disabled":
            case "blue":
                return BuildState.OK;
            case "yellow":
                return BuildState.INSTABLE;
            case "red":
                return BuildState.FAILED;
            }
            throw new IllegalStateException(color);
        }

        @Override
        public String toString() {
            return "JenkinsJob [name=" + name + ", url=" + url + ", color=" + color + "]";
        }
    }

    private String description;
    private JenkinsJob jobs[];
    private String name;
    private String url;

    public BuildState getState() {
        BuildState result = BuildState.OK;
        for (final JenkinsJob job : jobs) {
            final BuildState jobResult = job.getState();
            if (jobResult.isWorse(result)) {
                result = jobResult;
            }
        }
        return result;
    }

    @Override
    public String toString() {
        return "JenkinsView [description=" + description + ", jobs=" + Arrays.toString(jobs) + ", name=" + name + ", url="
                + url + "]";
    }
}
