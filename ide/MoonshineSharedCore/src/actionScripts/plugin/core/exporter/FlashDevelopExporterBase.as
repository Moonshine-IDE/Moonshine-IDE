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
package actionScripts.plugin.core.exporter
{
	import actionScripts.factory.FileLocation;
	import actionScripts.valueObjects.ProjectVO;
	
	public class FlashDevelopExporterBase
	{
		protected static function exportPaths(v:Vector.<FileLocation>, container:XML, element:XML, p:ProjectVO, absolutePath:Boolean=false, appendAsValue:Boolean=false, nullValue:String=null):XML
		{
			for each (var f:FileLocation in v) 
			{
				var e:XML = element.copy();
				var relative:String = p.folderLocation.fileBridge.getRelativePath(f, true);
				if (absolutePath) relative = null;
				if (appendAsValue) e.appendChild(relative ? relative : f.fileBridge.nativePath);
				else e.@path = relative ? relative : f.fileBridge.nativePath;
				container.appendChild( e );
			}
			
			if (v.length == 0 && nullValue)
			{
				element.appendChild(nullValue);
				container.appendChild(nullValue);
			}
			else if (v.length == 0)
			{
				container.appendChild(<!-- <empty/> -->);
			}
			
			return container;
		}
		
		protected static function exportPathString(v:Vector.<String>, container:XML, element:XML, p:ProjectVO, absolutePath:Boolean=false, appendAsValue:Boolean=false, nullValue:String=null):XML
		{
			for each (var f:String in v) 
			{
				var e:XML = element.copy();
				if (appendAsValue) e.appendChild(f);
				else e.@path = f;
				container.appendChild( e );
			}
			
			if (v.length == 0 && nullValue)
			{
				element.appendChild(nullValue);
				container.appendChild(nullValue);
			}
			else if (v.length == 0)
			{
				var tmpXML:XML = <!-- <empty/> -->
				container.appendChild(tmpXML);
			}
			
			return container;
		}
	}
}