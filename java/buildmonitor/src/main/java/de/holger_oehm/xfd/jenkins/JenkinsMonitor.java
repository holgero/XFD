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

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import com.google.gson.Gson;

public class JenkinsMonitor {
    private final Gson gson = new Gson();
    private final HttpClient client = new DefaultHttpClient();
    private final HttpGet getJsonApi;
    private final String url;

    public JenkinsMonitor(final String url) {
        this.url = url;
        getJsonApi = new HttpGet(url + "/api/json");
    }

    public BuildState state() throws ClientProtocolException, IOException {
        final HttpResponse response = client.execute(getJsonApi);
        final HttpEntity entity = response.getEntity();
        if (null == entity) {
            throw new IllegalStateException("no response from " + url);
        }
        final InputStream instream = entity.getContent();
        try {
            final JenkinsView jenkinsView = gson.fromJson(new InputStreamReader(instream), JenkinsView.class);
            return jenkinsView.getState();
        } finally {
            instream.close();
        }
    }

}
