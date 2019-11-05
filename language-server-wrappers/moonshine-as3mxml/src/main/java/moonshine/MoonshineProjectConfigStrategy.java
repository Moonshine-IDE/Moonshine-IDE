/*
Copyright 2016 Bowler Hat LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package moonshine;

import java.nio.file.Path;
import java.util.ArrayList;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.as3mxml.asconfigc.TopLevelFields;
import com.as3mxml.asconfigc.compiler.CompilerOptions;
import com.as3mxml.asconfigc.compiler.ProjectType;
import com.as3mxml.vscode.project.IProjectConfigStrategy;
import com.as3mxml.vscode.project.ProjectOptions;
import com.as3mxml.vscode.utils.LanguageServerCompilerUtils;

import org.eclipse.lsp4j.WorkspaceFolder;

/**
 * Configures a project for Moonshine IDE.
 */
public class MoonshineProjectConfigStrategy implements IProjectConfigStrategy
{
    private ProjectOptions options;
    private boolean changed = true;
    private WorkspaceFolder workspaceFolder;

    public MoonshineProjectConfigStrategy(WorkspaceFolder workspaceFolder)
    {
    	this.workspaceFolder = workspaceFolder;
        options = new ProjectOptions();
        options.type = ProjectType.APP;
        options.config = "flex";
        options.files = new String[0];
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
        
        String additionalOptions = null;
        if(params.has(TopLevelFields.ADDITIONAL_OPTIONS))
        {
            additionalOptions = params.get(TopLevelFields.ADDITIONAL_OPTIONS).getAsString();
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
