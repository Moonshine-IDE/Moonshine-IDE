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

import java.io.File;
import java.nio.file.Path;
import java.util.ArrayList;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.nextgenactionscript.vscode.project.CompilerOptions;
import com.nextgenactionscript.vscode.project.IProjectConfigStrategy;
import com.nextgenactionscript.vscode.project.ProjectOptions;
import com.nextgenactionscript.vscode.project.ProjectType;

/**
 * Configures a project for Moonshine IDE.
 */
public class MoonshineProjectConfigStrategy implements IProjectConfigStrategy
{
    private ProjectOptions options;
    private boolean changed = true;

    public MoonshineProjectConfigStrategy()
    {
    }

    public boolean getChanged()
    {
        return changed;
    }

    public void setChanged(boolean value)
    {
        changed = value;
    }

    public void setConfigParams(JsonObject params)
    {
        if (options == null)
        {
            options = new ProjectOptions();
        }
        System.clearProperty("flexlib");
        String flexLibPath = params.get("frameworkSDK").getAsString().concat("/frameworks");
        System.setProperty("flexlib", flexLibPath);
        
        ProjectType type = ProjectType.fromToken(params.get(ProjectOptions.TYPE).getAsString());
        String config = params.get(ProjectOptions.CONFIG).getAsString();

        JsonArray jsonFiles = params.getAsJsonArray(ProjectOptions.FILES);
        int fileCount = jsonFiles.size();
        String[] files = new String[fileCount];
        for (int i = 0; i < fileCount; i++)
        {
            files[i] = jsonFiles.get(i).getAsString();
        }

        JsonObject jsonOptions = params.getAsJsonObject(ProjectOptions.COMPILER_OPTIONS);
        CompilerOptions compilerOptions = new CompilerOptions();
        compilerOptions.warnings = jsonOptions.get(CompilerOptions.WARNINGS).getAsBoolean();

        if(jsonOptions.has(CompilerOptions.SOURCE_PATH))
        {
            JsonArray jsonSourcePath = jsonOptions.getAsJsonArray(CompilerOptions.SOURCE_PATH);
            ArrayList<File> sourcePath = new ArrayList<>();
            for (int i = 0, count = jsonSourcePath.size(); i < count; i++)
            {
                String pathString = jsonSourcePath.get(i).getAsString();
                sourcePath.add(new File(pathString));
            }
            compilerOptions.sourcePath = sourcePath;
        }

        if(jsonOptions.has(CompilerOptions.LIBRARY_PATH))
        {
            JsonArray jsonLibraryPath = jsonOptions.getAsJsonArray(CompilerOptions.LIBRARY_PATH);
            ArrayList<File> libraryPath = new ArrayList<>();
            for (int i = 0, count = jsonLibraryPath.size(); i < count; i++)
            {
                String pathString = jsonLibraryPath.get(i).getAsString();
                libraryPath.add(new File(pathString));
            }
            compilerOptions.libraryPath = libraryPath;
        }

        if(jsonOptions.has(CompilerOptions.EXTERNAL_LIBRARY_PATH))
        {
            JsonArray jsonExternalLibraryPath = jsonOptions.getAsJsonArray(CompilerOptions.EXTERNAL_LIBRARY_PATH);
            ArrayList<File> externalLibraryPath = new ArrayList<>();
            for (int i = 0, count = jsonExternalLibraryPath.size(); i < count; i++)
            {
                String pathString = jsonExternalLibraryPath.get(i).getAsString();
                externalLibraryPath.add(new File(pathString));
            }
            compilerOptions.externalLibraryPath = externalLibraryPath;
        }
        
        String additionalOptions = null;
        if(params.has(ProjectOptions.ADDITIONAL_OPTIONS))
        {
            additionalOptions = params.get(ProjectOptions.ADDITIONAL_OPTIONS).getAsString();
        }
                
        options.type = type;
        options.config = config;
        options.files = files;
        options.compilerOptions = compilerOptions;
        options.additionalOptions = additionalOptions;
    }

    public ProjectOptions getOptions()
    {
        changed = false;
        if (options == null)
        {
            return null;
        }
        return options;
    }
}
