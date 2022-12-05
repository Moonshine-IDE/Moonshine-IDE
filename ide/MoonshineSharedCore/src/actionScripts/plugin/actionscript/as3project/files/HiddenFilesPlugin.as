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
package actionScripts.plugin.actionscript.as3project.files
{
    import actionScripts.events.HiddenFilesEvent;
    import actionScripts.events.RefreshTreeEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.IPlugin;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.FileWrapper;

    public class HiddenFilesPlugin extends PluginBase implements IPlugin
    {
        override public function get name():String { return "Hidden Files"; }
        override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
        override public function get description():String { return "Handle hide/show operations on folders in Project Tree"; }

        public function HiddenFilesPlugin()
        {
            super();
        }

        override public function activate():void
        {
            super.activate();

            dispatcher.addEventListener(HiddenFilesEvent.MARK_FILES_AS_VISIBLE, showFilesHandler);
            dispatcher.addEventListener(HiddenFilesEvent.MARK_FILES_AS_HIDDEN, hideFilesHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

            dispatcher.removeEventListener(HiddenFilesEvent.MARK_FILES_AS_VISIBLE, showFilesHandler);
            dispatcher.removeEventListener(HiddenFilesEvent.MARK_FILES_AS_HIDDEN, hideFilesHandler);
        }

        private function hideFilesHandler(event:HiddenFilesEvent):void
        {
            var fileWrapper:FileWrapper = event.fileWrapper;
            var project:AS3ProjectVO = UtilsCore.getProjectFromProjectFolder(fileWrapper) as AS3ProjectVO;
            project.hiddenPaths.push(new FileLocation(fileWrapper.nativePath));
            project.saveSettings();

            dispatcher.dispatchEvent(new RefreshTreeEvent(fileWrapper.file));
        }

        private function showFilesHandler(event:HiddenFilesEvent):void
        {
            var fileWrapper:FileWrapper = event.fileWrapper;
            var project:AS3ProjectVO = UtilsCore.getProjectFromProjectFolder(fileWrapper) as AS3ProjectVO;
            var fileIndex:int = -1;
            if (project.hiddenPaths.some(function(item:FileLocation, index:int, arr:Vector.<FileLocation>):Boolean
            {
                if (item.fileBridge.nativePath == fileWrapper.nativePath)
                {
                    fileIndex = index;
                    return true;
                }
                return false;
            }))
            {
                project.hiddenPaths.removeAt(fileIndex);
                project.saveSettings();

                dispatcher.dispatchEvent(new RefreshTreeEvent(fileWrapper.file));
            }
        }
    }
}
