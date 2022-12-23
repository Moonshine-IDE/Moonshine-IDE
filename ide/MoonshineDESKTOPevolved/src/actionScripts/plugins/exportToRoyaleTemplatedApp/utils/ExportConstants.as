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

package actionScripts.plugins.exportToRoyaleTemplatedApp.utils
{
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

	public class ExportConstants  
	{
		public static const ROYALE_JEWEL_APPLICATION:String = "<j:Application";
		
		// General
		public static const NAME_START:String = "GENERATED_";
		public static const NAME_END:String = ":";
		public static const TOKEN_START:String = "<!--";
		public static const TOKEN_END:String = "-->";
		
		// Menu
		public static const GENERATED_MENU_CURSOR:String = "GENERATED_MENU_CURSOR";
		public static const START_GENERATED_MENU:String = "START_GENERATED_MENU";
		public static const END_GENERATED_MENU:String = "END_GENERATED_MENU";
		
		// Views
		public static const GENERATED_VIEWS_CURSOR:String = "GENERATED_VIEWS_CURSOR";
		public static const START_GENERATED_SCROLLABLE_SECTION:String = "START_GENERATED_SCROLLABLE_SECTION";
		public static const END_GENERATED_SCROLLABLE_SECTION:String = "END_GENERATED_SCROLLABLE_SECTION";
		
		// CSS
		public static const CSS_CURSOR:String = "APPLICATION_CSS_CURSOR";		
		public static const START_GENERATED_SCRIPT_CSSSTYLES:String = "START_GENERATED_SCRIPT_CSSSTYLES";
		public static const END_GENERATED_SCRIPT_CSSSTYLES:String = "END_GENERATED_SCRIPT_CSSSTYLES";
		
		public static function getCssSection(projectName:String):GeneratedSection
		{
			return new GeneratedSection([
				"<!--" + START_GENERATED_SCRIPT_CSSSTYLES + "_" + projectName + ":  **DO NOT MODIFY ANYTHING BELOW THIS LINE MANUALLY**-->",
				"<fx:Style source=\"../../generated/" + projectName + "/resources/export-app-styles.css\"/>",
				"<!--" + END_GENERATED_SCRIPT_CSSSTYLES + "_" + projectName + ": **DO NOT MODIFY ANYTHING ABOVE THIS LINE MANUALLY**-->"
			])
		}
	}
}