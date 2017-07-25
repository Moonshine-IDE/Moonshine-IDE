////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.impls
{
    import actionScripts.interfaces.IProject;
    import actionScripts.interfaces.IVisualEditorBridge;
    import actionScripts.plugin.actionscript.as3project.save.SaveFilesPlugin;
    import actionScripts.plugin.findreplace.FindReplacePlugin;
    import actionScripts.plugin.fullscreen.FullscreenPlugin;
    import actionScripts.plugin.help.HelpPlugin;
    import actionScripts.plugin.project.ProjectPlugin;
    import actionScripts.plugin.recentlyOpened.RecentlyOpenedPlugin;
    import actionScripts.plugin.settings.SettingsPlugin;
    import actionScripts.plugin.splashscreen.SplashScreenPlugin;
    import actionScripts.plugin.startup.StartupHelperPlugin;
    import actionScripts.plugin.syntax.AS3SyntaxPlugin;
    import actionScripts.plugin.syntax.CSSSyntaxPlugin;
    import actionScripts.plugin.syntax.HTMLSyntaxPlugin;
    import actionScripts.plugin.syntax.JSSyntaxPlugin;
    import actionScripts.plugin.syntax.MXMLSyntaxPlugin;
    import actionScripts.plugin.syntax.XMLSyntaxPlugin;
    import actionScripts.plugin.templating.TemplatingPlugin;
    import actionScripts.plugins.ant.AntBuildPlugin;
    import actionScripts.plugins.core.ProjectBridgeImplBase;
    import actionScripts.plugins.problems.ProblemsPlugin;
    import actionScripts.plugins.references.ReferencesPlugin;
    import actionScripts.plugins.rename.RenamePlugin;
    import actionScripts.plugins.svn.SVNPlugin;
    import actionScripts.plugins.symbols.SymbolsPlugin;

    public class IVisualEditorProjectBridgeImpl extends ProjectBridgeImplBase implements IVisualEditorBridge
    {
        public function IVisualEditorProjectBridgeImpl()
        {
            super();
        }

        public function getCorePlugins():Array
        {
            return [
                SettingsPlugin,
                ProjectPlugin,
                TemplatingPlugin,
                HelpPlugin,
                FindReplacePlugin,
                RecentlyOpenedPlugin,
                FullscreenPlugin,
                AntBuildPlugin,
            ];
        }

        public function getDefaultPlugins():Array
        {
            return [
                AS3SyntaxPlugin,
                CSSSyntaxPlugin,
                JSSyntaxPlugin,
                HTMLSyntaxPlugin,
                MXMLSyntaxPlugin,
                XMLSyntaxPlugin,
                SplashScreenPlugin,
                SVNPlugin,
                SaveFilesPlugin,
                ProblemsPlugin,
                SymbolsPlugin,
                ReferencesPlugin,
                RenamePlugin
            ];
        }

        public function getPluginsNotToShowInSettings():Array
        {
            return [
                ProjectPlugin,
                HelpPlugin,
                FindReplacePlugin,
                RecentlyOpenedPlugin,
                ProblemsPlugin,
                SymbolsPlugin,
                ReferencesPlugin,
                StartupHelperPlugin,
                RenamePlugin
            ];
        }

        public function get runtimeVersion():String
        {
            return "";
        }

        public function get version():String
        {
            return "";
        }
    }
}
