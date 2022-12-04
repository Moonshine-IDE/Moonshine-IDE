////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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
package actionScripts.impls
{
    import actionScripts.interfaces.IVisualEditorBridge;
    import actionScripts.plugin.visualEditor.VisualEditorProjectPlugin;
    import actionScripts.plugins.core.ProjectBridgeImplBase;
    import actionScripts.plugins.ui.editor.VisualEditorViewer;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.ui.IContentWindow;

    public class IVisualEditorProjectBridgeImpl extends ProjectBridgeImplBase implements IVisualEditorBridge
    {
        public function IVisualEditorProjectBridgeImpl()
        {
            super();
        }

        public function getVisualEditor(visualEditorProject:ProjectVO):BasicTextEditor
        {
            return new VisualEditorViewer(visualEditorProject);
        }

        public function renameDominoFormFileSave(visualEditor:IContentWindow,fileName:String):String
        {
            var formXmlString:String=null;
            var editor:VisualEditorViewer = visualEditor as VisualEditorViewer;
            if(editor){
                formXmlString =editor.renameDominoFormFileSave(fileName);
            }
            return formXmlString;
        }

        public function getCorePlugins():Array
        {
            return [
            ];
        }

        public function getDefaultPlugins():Array
        {
            return [
                VisualEditorProjectPlugin
            ];
        }

        public function getPluginsNotToShowInSettings():Array
        {
            return [
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
