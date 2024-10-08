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

package actionScripts.plugin.core.compiler;

import openfl.events.Event;

class ProjectActionEvent extends Event {
	public static final BUILD_DEBUG:String = "projectBuildDebug";
	public static final BUILD_AND_DEBUG:String = "projectBuildAndDebug";
	public static final BUILD_RELEASE:String = "projectBuildRelease";
	public static final BUILD_AND_RUN:String = "projectBuildAndRun";
	public static final RUN_AFTER_DEBUG:String = "projectCompilerRunAfterDebug";
	public static final BUILD:String = "projectCompilerBuild";
	public static final CLEAN_PROJECT:String = "cleanProject";
	public static final SET_DEFAULT_APPLICATION:String = "setDefaultApplication";

	public var value:Dynamic;

	public function new(type:String, value:Dynamic = null, bubbles:Bool = false, cancelable:Bool = false) {
		this.value = value;
		super(type, bubbles, cancelable);
	}
}