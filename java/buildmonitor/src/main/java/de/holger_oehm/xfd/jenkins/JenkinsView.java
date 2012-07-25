/*  
 *  Copyright (C) 2012 Holger Oehm
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
