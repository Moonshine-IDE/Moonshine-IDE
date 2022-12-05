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
package actionScripts.ui.menu.vo
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	public class ProjectMenuTypes
	{
		public static const FLEX_AS:String = "flexASproject";
		public static const PURE_AS:String = "pureASProject";
		public static const JS_ROYALE:String = "flexJSroyale";
		public static const JS_ROYALE_VISUAL:String = "flexJSVisualroyale";
		public static const VISUAL_EDITOR_FLEX:String = "visualEditorFlex";
		public static const VISUAL_EDITOR_PRIMEFACES:String = "visualEditorPrimefaces";
		public static const VISUAL_EDITOR_DOMINO:String = "visualEditorDomino";
		public static const VISUAL_EDITOR_DOMINO_PAGE:String = "visualEditorDominoPage";
		public static const LIBRARY_FLEX_AS:String = "libraryFlexAS";
		public static const GIT_PROJECT:String = "gitProject";
		public static const SVN_PROJECT:String = "svnProject";
		public static const JAVA:String = "java";
		public static const GRAILS:String = "grails";
		public static const HAXE:String = "haxe";
		public static const ON_DISK:String = "onDisk";
		public static const GENERIC:String = "generic";
		public static const TEMPLATE:String = "template";
		
		public static var VISUAL_EDITOR_FILE_TEMPLATE_ITEMS:Array;
		public static var VISUAL_EDITOR_FILE_TEMPLATE_ITEMS_TYPE:Array;
		
		private static var resourceManager:IResourceManager = ResourceManager.getInstance();
		
		{
			VISUAL_EDITOR_FILE_TEMPLATE_ITEMS = [resourceManager.getString('resources', 'VISUALEDITOR_FLEX_FILE'), resourceManager.getString('resources', 'VISUALEDITOR_PRIMEFACES_FILE')];
			VISUAL_EDITOR_FILE_TEMPLATE_ITEMS_TYPE = [VISUAL_EDITOR_FLEX, VISUAL_EDITOR_PRIMEFACES];
		}
	}
}