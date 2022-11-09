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

import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

import com.as3mxml.asconfigc.TopLevelFields;
import com.as3mxml.asconfigc.compiler.CompilerOptions;
import com.as3mxml.asconfigc.compiler.ProjectType;
import com.as3mxml.asconfigc.utils.OptionsUtils;
import com.as3mxml.vscode.project.IProjectConfigStrategy;
import com.as3mxml.vscode.project.ProjectOptions;
import com.as3mxml.vscode.utils.LanguageServerCompilerUtils;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import org.eclipse.lsp4j.WorkspaceFolder;

/**
 * Configures a project for Moonshine IDE.
 */
public class MoonshineProjectConfigStrategy implements IProjectConfigStrategy
{
    private ProjectOptions options;
    private boolean changed = true;
    private Path projectPath;
    private WorkspaceFolder workspaceFolder;

    public MoonshineProjectConfigStrategy(Path projectPath, WorkspaceFolder workspaceFolder)
    {
        this.projectPath = projectPath;
    	this.workspaceFolder = workspaceFolder;
        options = new ProjectOptions();
        options.type = ProjectType.APP;
        options.config = "flex";
        options.files = new String[0];
    }

    public Path getProjectPath() {
        return projectPath;
    }

    public WorkspaceFolder getWorkspaceFolder()
    {
        return workspaceFolder;
    }

    public String getDefaultConfigurationProblemPath()
    {
        String uri = workspaceFolder.getUri();
        Path path = LanguageServerCompilerUtils.getPathFromLanguageServerURI(uri);
        if(path == null)
        {
        	return null;
        }
        return path.toString();
    }

    public Path getConfigFilePath()
    {
        return null;
    }

    public boolean getChanged()
    {
        return changed;
    }

    public void forceChanged()
    {
        changed = true;
    }

    public void setConfigParams(JsonObject params)
    {
        changed = true;

        String projectType = params.get(TopLevelFields.TYPE).getAsString();
        String config = params.get(TopLevelFields.CONFIG).getAsString();

        JsonArray jsonFiles = params.getAsJsonArray(TopLevelFields.FILES);
        int fileCount = jsonFiles.size();
        String[] files = new String[fileCount];
        for (int i = 0; i < fileCount; i++)
        {
            files[i] = jsonFiles.get(i).getAsString();
        }

        ArrayList<String> targets = new ArrayList<>();;
        ArrayList<String> compilerOptions = new ArrayList<>();

        JsonObject jsonOptions = params.getAsJsonObject(TopLevelFields.COMPILER_OPTIONS);

        if(jsonOptions.has(CompilerOptions.TARGETS))
        {
            JsonArray jsonTargets = jsonOptions.getAsJsonArray(CompilerOptions.TARGETS);
            for (int i = 0, count = jsonTargets.size(); i < count; i++)
            {
                String targetString = jsonTargets.get(i).getAsString();
                targets.add(targetString);
            }
        }
        
        List<String> additionalOptions = null;
        if(params.has(TopLevelFields.ADDITIONAL_OPTIONS))
        {
            String additionalOptionsText = params.get(TopLevelFields.ADDITIONAL_OPTIONS).getAsString();
            additionalOptions = OptionsUtils.parseAdditionalOptions(additionalOptionsText);
        }
        
        options.type = projectType;
        options.config = config;
        options.files = files;
        options.targets = targets;
        options.compilerOptions = compilerOptions;
        options.additionalOptions = additionalOptions;
    }

    public ProjectOptions getOptions()
    {
        changed = false;
        return options;
    }
}
