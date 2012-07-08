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
/*
 * {"assignedLabels":[{}],
 * "mode":"NORMAL",
 * "nodeDescription":"the master Jenkins node",
 * "nodeName":"",
 * "numExecutors":2,
 * "description":null,
 * "jobs":[{"name":"Build DE","url":"http://automatix:8080/job/Build%20DE/","color":"blue"},
 *         {"name":"Build de2","url":"http://automatix:8080/job/Build%20de2/","color":"disabled"},
 *         {"name":"Build GA","url":"http://automatix:8080/job/Build%20GA/","color":"blue"},
 *         {"name":"Build GE2","url":"http://automatix:8080/job/Build%20GE2/","color":"blue"},{"name":"ControlDcf77Clock","url":"http://automatix:8080/job/ControlDcf77Clock/","color":"blue"},{"name":"CountdownTimer","url":"http://automatix:8080/job/CountdownTimer/","color":"blue"},{"name":"Damoria Tools","url":"http://automatix:8080/job/Damoria%20Tools/","color":"blue"},{"name":"dcf77","url":"http://automatix:8080/job/dcf77/","color":"blue"},{"name":"Elexs","url":"http://automatix:8080/job/Elexs/","color":"blue"},{"name":"FritzboxMonitor","url":"http://automatix:8080/job/FritzboxMonitor/","color":"blue"},{"name":"Recruit DE","url":"http://automatix:8080/job/Recruit%20DE/","color":"blue"},{"name":"Recruit GA","url":"http://automatix:8080/job/Recruit%20GA/","color":"blue"},{"name":"Recruit GE2","url":"http://automatix:8080/job/Recruit%20GE2/","color":"blue"},{"name":"Test build status monitor","url":"http://automatix:8080/job/Test%20build%20status%20monitor/","color":"disabled"},{"name":"XFD","url":"http://automatix:8080/job/XFD/","color":"blue"}],
 * "overallLoad":{},
 * "primaryView":{"name":"All","url":"http://automatix:8080/"},
 * "quietingDown":false,
 * "slaveAgentPort":0,
 * "useCrumbs":false,
 * "useSecurity":false,
 * "views":[{"name":"All","url":"http://automatix:8080/"},
 *          {"name":"Damoria","url":"http://automatix:8080/view/Damoria/"}]}
 */
