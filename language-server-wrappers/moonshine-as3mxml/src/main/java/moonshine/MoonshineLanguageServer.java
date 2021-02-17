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

import java.util.concurrent.CompletableFuture;

import com.as3mxml.vscode.ActionScriptLanguageServer;
import com.as3mxml.vscode.project.IProjectConfigStrategyFactory;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import org.eclipse.lsp4j.InitializeParams;
import org.eclipse.lsp4j.InitializeResult;

public class MoonshineLanguageServer extends ActionScriptLanguageServer
{
    public MoonshineLanguageServer(IProjectConfigStrategyFactory factory)
    {
        super(factory);
        actionScriptServices = new MoonshineActionScriptServices(factory);
	}
    @Override
    public CompletableFuture<InitializeResult> initialize(InitializeParams params) {
        CompletableFuture<InitializeResult> result = super.initialize(params);
        try
        {
            JsonObject initOptions = (JsonObject) params.getInitializationOptions();
            if(initOptions != null && initOptions.has("config")) {
                JsonElement jsonConfig = initOptions.get("config");
                MoonshineActionScriptServices moonshineServices = (MoonshineActionScriptServices) actionScriptServices;
                moonshineServices.didChangeProjectConfiguration(jsonConfig);
            }
        }
        catch(Exception e)
        {
            e.printStackTrace(System.err);
        }
        return result;
    }
}