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
package actionScripts.plugin.core.importer
{
	import actionScripts.events.GlobalEventDispatcher;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;

	import moonshine.plugin.workflows.events.WorkflowEvent;

	public class FlashDevelopImporterBase extends EventDispatcher
	{
		public function FlashDevelopImporterBase(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		protected static function parsePaths(paths:XMLList, v:Vector.<FileLocation>, p:ProjectVO, attrName:String="path"):void
		{
			for each (var pathXML:XML in paths)
			{
				var path:String = pathXML.attribute(attrName);
				
				if (path)
				{
					// file separator fix
					path = UtilsCore.fixSlashes(path);
					var f:FileLocation = p.folderLocation.resolvePath(path);
					
					if (ConstantsCoreVO.IS_AIR) f.fileBridge.canonicalize();
					v.push(f);
				}
			}
		}
		
		protected static function parsePathString(paths:XMLList, v:Vector.<String>, p:ProjectVO, attrName:String="path"):void 
		{
			for each (var pathXML:XML in paths)
			{
				var path:String = pathXML.attribute(attrName);
				if (path)
				{
					v.push(path);
				}
			}
		}

		protected static function parseWorkflowFile(project:ProjectVO):void
		{
			var workflowFile:FileLocation = project.folderLocation.resolvePath("moonshine-workflows.xml");
			if (!workflowFile.fileBridge.exists)
				return;

			GlobalEventDispatcher.getInstance().dispatchEvent(
					new WorkflowEvent(WorkflowEvent.LOAD_WORKFLOW, project)
			);
		}
	}
}