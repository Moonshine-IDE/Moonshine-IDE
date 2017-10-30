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
package actionScripts.plugin.settings.providers
{
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.settings.ISettingsProvider;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.startup.StartupHelperPlugin;
    import actionScripts.ui.tabview.CloseTabEvent;

    import flash.display.DisplayObject;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.net.SharedObject;

    import mx.controls.Alert;
    import mx.core.FlexGlobals;
    import mx.events.CloseEvent;

    public class JavaSettingsProvider implements ISettingsProvider
    {
        public var resetLabel:String = "Reset Java path";

        public function JavaSettingsProvider()
        {
        }

        public function getSettingsList():Vector.<ISetting>
        {
            return null;
        }
        
        public function resetJavaPath():void
        {
            Alert.yesLabel = "Reset";
            Alert.buttonWidth = 120;
            Alert.show("Are you sure you want to reset the Java Development Kit path?", "Warning!",
                    Alert.YES|Alert.CANCEL, FlexGlobals.topLevelApplication as Sprite,
                    onResetHandler, null, Alert.CANCEL);
        }

        private function onResetHandler(event:CloseEvent):void
        {
            var model:IDEModel = IDEModel.getInstance();
            if (!model.javaPathForTypeAhead) return;
            
            var cookie:SharedObject = SharedObject.getLocal("moonshine-ide-local");
            var dispatcher:EventDispatcher = GlobalEventDispatcher.getInstance();

            Alert.yesLabel = "Yes";
            Alert.buttonWidth = 65;
            if (event.detail == Alert.YES)
            {
                if (model.activeEditor)
                {
                    delete cookie.data["javaPathForTypeahead"];
                    model.javaPathForTypeAhead = null;
                    
                    dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, model.activeEditor as DisplayObject));
                    dispatcher.dispatchEvent(new Event(StartupHelperPlugin.EVENT_RESTART_HELPING));
                }
            }
        }
    }
}
