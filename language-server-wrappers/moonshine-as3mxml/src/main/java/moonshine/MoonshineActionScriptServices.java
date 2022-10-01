////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
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
		List<ActionScriptProjectData> allProjectData = getProjects();
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