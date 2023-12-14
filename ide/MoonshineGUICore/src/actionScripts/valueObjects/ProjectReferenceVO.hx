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

//TODO
package actionScripts.valueObjects;

import flash.filesystem.File;
import actionScripts.utils.FileUtils;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import haxe.DynamicAccess;
#if flash
import flash.Vector;
#else
import openfl.Vector;
#end

class ProjectReferenceVO {
	public var name:String;
	public var path:String = "";
	public var startIn:String = "";
	public var status:String = "";
	public var loading:Bool;
	public var sdk:String;
	public var isAway3D:Bool;
	public var isTemplate:Bool;
	public var hiddenPaths:Vector<FileLocation> = new Vector<FileLocation>();
	public var showHiddenPaths:Bool;
	public var sourceFolder:FileLocation;

	public function new() {}

	/**
	 * Static method to translate config
	 * SO data in a loosely-coupled manner
	 */
	public static function getNewRemoteProjectReferenceVO(value:Dynamic):ProjectReferenceVO {
		var tmpVO:ProjectReferenceVO = new ProjectReferenceVO();

		// value submission
		if (value.path != null)
			tmpVO.path = value.path;
		if (value.name != null) {
			// since https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1027 problem
			// parse by path to overcome problem during reading from already saved data
			if (tmpVO.path != null) {
				if (!FileUtils.isPathDirectory(tmpVO.path)) 
				{
					var pathSplit = tmpVO.path.split(File.separator);
					if (pathSplit.length > 3)
					{
						do
						{
							pathSplit.shift();
						} while (pathSplit.length > 3);
					}
					
					tmpVO.name = "..."+ File.separator + pathSplit.join(File.separator); //cast( tmpVO.path.split(IDEModel.getInstance().fileCore.separator).pop(), String ) +" ("+ tmpVO.path +")";
				}
				else tmpVO.name = value.name;
			} else {
				tmpVO.name = value.name;
			}
		}
		if (value.startIn != null)
			tmpVO.startIn = value.startIn;
		if (value.status != null)
			tmpVO.status = value.status;
		if (value.loading != null)
			tmpVO.loading = value.loading;
		if (value.sdk != null)
			tmpVO.sdk = value.sdk;
		if (value.isAway3D != null)
			tmpVO.isAway3D = value.isAway3D;
		if (value.isTemplate != null)
			tmpVO.isTemplate = value.isTemplate;

		// finally
		return tmpVO;
	}

	public static function serializeForSharedObject(value:ProjectReferenceVO):Dynamic {
		return {
			name: value.name,
			path: value.path,
			startIn: value.startIn,
			status: value.status,
			loading: value.loading,
			sdk: value.sdk,
			isAway3D: value.isAway3D,
			isTemplate: value.isTemplate
		};
	}
}