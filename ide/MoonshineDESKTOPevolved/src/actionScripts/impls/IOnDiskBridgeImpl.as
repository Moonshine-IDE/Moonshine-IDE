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
package actionScripts.impls
{
    import flash.filesystem.File;
    
    import actionScripts.events.NewProjectEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.interfaces.IOnDiskBridge;
    import actionScripts.plugin.ondiskproj.CreateOnDiskProject;
    import actionScripts.plugin.ondiskproj.OnDiskProjectPlugin;
    import actionScripts.plugin.ondiskproj.importer.OnDiskImporter;
    import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
    import actionScripts.plugins.core.ProjectBridgeImplBase;
    import actionScripts.plugins.ui.editor.dominoFormBuilder.DominoFormBuilderWrapper;
    import actionScripts.ui.IContentWindow;

    public class IOnDiskBridgeImpl extends ProjectBridgeImplBase implements IOnDiskBridge
    {
        public function IOnDiskBridgeImpl()
        {
            super();
        }
		
		public function getTabularInterfaceEditor(file:FileLocation, project:OnDiskProjectVO=null):IContentWindow
		{
			return ((new DominoFormBuilderWrapper(file, project)) as IContentWindow);
		}

        public function getCorePlugins():Array
        {
            return [
            ];
        }

        public function getDefaultPlugins():Array
        {
            return [
                OnDiskProjectPlugin
            ];
        }

        public function getPluginsNotToShowInSettings():Array
        {
            return [
				OnDiskProjectPlugin
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
		
		override public function createProject(event:NewProjectEvent):void
        {
			new CreateOnDiskProject(event);
		}
		
		public function testOnDisk(file:Object):FileLocation
		{
			return OnDiskImporter.test(file as File);
		}

		public function parseOnDisk(file:FileLocation, projectName:String=null, settingsFileLocation:FileLocation = null):OnDiskProjectVO
		{
			return OnDiskImporter.parse(file, projectName, settingsFileLocation);
		}
    }
}
