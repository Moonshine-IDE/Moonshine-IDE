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

import java.util.List;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.as3mxml.vscode.ActionScriptServices;
import com.as3mxml.vscode.project.WorkspaceFolderData;

import org.eclipse.lsp4j.WorkspaceFolder;
import org.eclipse.lsp4j.jsonrpc.services.JsonNotification;

public class MoonshineActionScriptServices extends ActionScriptServices
{
	@JsonNotification(value="moonshine/didChangeProjectConfiguration")
	public void didChangeProjectConfiguration(Object rawData) throws Exception
	{
        Gson gson = new Gson();
		JsonObject config = gson.toJsonTree(rawData).getAsJsonObject();
		List<WorkspaceFolder> folders = getWorkspaceFolders();
		if (folders == null || folders.size() == 0)
		{
			throw new Exception("No workspace folders available to change project configuration.");
		}
		WorkspaceFolder folder = getWorkspaceFolders().get(0);
		WorkspaceFolderData folderData = getWorkspaceFolderData(folder);
		if (folderData == null)
		{
			throw new Exception("No folder data for workspace: " + folder.getUri());
		}
        MoonshineProjectConfigStrategy projectConfigStrategy = (MoonshineProjectConfigStrategy) folderData.config;
        projectConfigStrategy.setConfigParams(config);
        checkForProblemsNow(true);
	}
}