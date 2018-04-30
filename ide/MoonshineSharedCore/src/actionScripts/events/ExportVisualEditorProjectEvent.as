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
package actionScripts.events
{
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

    import flash.events.Event;

    public class ExportVisualEditorProjectEvent extends Event
    {
        public static const EVENT_INIT_EXPORT_VISUALEDITOR_PROJECT_TO_FLEX:String = "initExportVisualEditorToFlex";
        public static const EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_FLEX:String = "exportVisualEditorProjectToFlex";
        public static const EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES:String = "exportVisualEditorProjectToPrimeFaces";

        private var _exportedProject:AS3ProjectVO;

        public function ExportVisualEditorProjectEvent(type:String, exportedProject:AS3ProjectVO = null):void
        {
            super(type, false, false);

            _exportedProject = exportedProject;
        }

        public function get exportedProject():AS3ProjectVO
        {
            return _exportedProject;
        }
    }
}
