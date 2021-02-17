////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package moonshine;

import java.lang.reflect.Field;
import java.util.List;

import com.as3mxml.vscode.ActionScriptServices;
import com.as3mxml.vscode.project.ActionScriptProjectData;
import com.as3mxml.vscode.project.IProjectConfigStrategyFactory;
import com.as3mxml.vscode.utils.ActionScriptProjectManager;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import org.eclipse.lsp4j.jsonrpc.services.JsonNotification;

public class MoonshineActionScriptServices extends ActionScriptServices
{
    public MoonshineActionScriptServices(IProjectConfigStrategyFactory factory) {
		super(factory);
	}

	@JsonNotification(value="moonshine/didChangeProjectConfiguration")
	public void didChangeProjectConfiguration(Object rawData) throws Exception
	{
        Gson gson = new Gson();
		JsonObject config = gson.toJsonTree(rawData).getAsJsonObject();
		//TODO: change this to a proper API when reflection isn't required
		Field actionScriptProjectManagerField = ActionScriptServices.class.getDeclaredField("actionScriptProjectManager");
		actionScriptProjectManagerField.setAccessible(true);
		ActionScriptProjectManager actionScriptProjectManager = (ActionScriptProjectManager) actionScriptProjectManagerField.get(this);
		List<ActionScriptProjectData> allProjectData = actionScriptProjectManager.getAllProjectData();
		if (allProjectData == null || allProjectData.size() == 0)
		{
			throw new Exception("No projects available to change configuration.");
		}
		ActionScriptProjectData projectData = allProjectData.get(0);
        MoonshineProjectConfigStrategy projectConfigStrategy = (MoonshineProjectConfigStrategy) projectData.config;
        projectConfigStrategy.setConfigParams(config);
        checkForProblemsNow(true);
	}
}