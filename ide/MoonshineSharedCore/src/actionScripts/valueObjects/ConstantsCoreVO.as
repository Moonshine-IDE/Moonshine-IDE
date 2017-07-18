////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.valueObjects
{
	import flash.system.Security;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	
	import actionScripts.factory.FileLocation;
	
	/**
	 * ConstantsCoreVO
	 * 
	 * @date 10.28.2015
	 * @version 1.0
	 */
	[Bindable] public class ConstantsCoreVO
	{
		//--------------------------------------------------------------------------
		//
		//  PUBLIC STATIC CONSTS
		//
		//--------------------------------------------------------------------------
		
		public static const IS_AIR: Boolean = Security.sandboxType.toString() == "application" ? true : false;
		public static const FILE_APPLICATIONSTORAGE: String = "applicationStorageDirectory";
		public static const FILE_APPLICATIONDIRECTORY: String = "applicationDirectory";
		public static const MOONSHINE_PROD_ID: String = "com.moonshine-ide";
		public static const REQUIRED_FLEXJS_SDK_VERION_MINIMUM:String = "0.7.0";
		public static const REQUIRED_FLEX_SDK_VERION_MINIMUM:String = null;
		public static const EVENT_PROBLEMS:String = "EVENT_PROBLEMS";
		public static const EVENT_SHOW_DEBUG_VIEW:String = "EVENT_SHOW_DEBUG_VIEW";
		
		[Embed(source='/elements/swf/loading.swf')]
		public static var loaderIcon: Class;
		public static var FLEX_PROJECTS: ArrayList;
		
		public static var TEMPLATE_AS3CLASS: FileLocation;
		public static var TEMPLATE_AS3INTERFACE: FileLocation;
		public static var TEMPLATE_CSS: FileLocation;
		public static var TEMPLATE_TEXT: FileLocation;
		public static var TEMPLATE_XML: FileLocation;
		public static var TEMPLATE_MXML: FileLocation;
		public static var TEMPLATES_FILES: ArrayCollection;
		public static var TEMPLATES_PROJECTS: ArrayCollection;
		public static var TEMPLATES_PROJECTS_SPECIALS:ArrayCollection;
		public static var TEMPLATES_MXML_COMPONENTS:ArrayCollection = new ArrayCollection();
		public static var TEMPLATES_OPEN_PROJECTS: ArrayCollection;
		public static var ACTIONSCRIPT_PROJECT:FileLocation;
		public static var FLEXBROWSER_PROJECT:FileLocation;
		public static var FLEXDESKTOP_PROJECT:FileLocation;
		public static var FLEXMOBILE_PROJECT:FileLocation;
		public static var VISUALEDITOR_FLEX_PROJECT:FileLocation;
		public static var HAXESWF_PROJECT:FileLocation;
		public static var FLEXJS_PROJECT:FileLocation;
		public static var FLEXJSBL_PROJECT:FileLocation;
		public static var MENU_TOOLTIP: ArrayCollection;
		
		public static var AS3PROJ_CONFIG_SOURCE: XML = <project version="2">
		  <!-- Output SWF options -->
		  <output>
			<movie outputType="Application" />
			<movie input="" />
			<movie path="..\swf\Grails4NotesBroker.swf" />
			<movie fps="30" />
			<movie width="800" />
			<movie height="600" />
			<movie version="16" />
			<movie minorVersion="0" />
			<movie platform="Flash Player" />
			<movie background="#FFFFFF" />
		  </output>
		  <!-- Other classes to be compiled into your SWF -->
		  <classpaths>
			<class path="." />
		  </classpaths>
		  <!-- Build options -->
		  <build>
			<option accessible="False" />
			<option advancedTelemetry="False" />
			<option allowSourcePathOverlap="False" />
			<option benchmark="False" />
			<option es="False" />
			<option inline="False" />
			<option locale="" />
			<option loadConfig="" />
			<option optimize="True" />
			<option omitTraces="True" />
			<option showActionScriptWarnings="True" />
			<option showBindingWarnings="True" />
			<option showInvalidCSS="True" />
			<option showDeprecationWarnings="True" />
			<option showUnusedTypeSelectorWarnings="True" />
			<option strict="True" />
			<option useNetwork="True" />
			<option useResourceBundleMetadata="True" />
			<option warnings="True" />
			<option verboseStackTraces="False" />
			<option linkReport="" />
			<option loadExterns="" />
			<option staticLinkRSL="True" />
			<option additional="" />
			<option compilerConstants="" />
			<option minorVersion="" />
		  </build>
		  <!-- SWC Include Libraries -->
		  <includeLibraries>
			<!-- example: <element path="..." /> -->
		  </includeLibraries>
		  <!-- SWC Libraries -->
		  <libraryPaths>
			<element path="lib\granite.swc" />
			<element path="lib\granite-client-flex-3.1.0.RC1.swc" />
			<element path="lib\granite-client-flex45-advanced-3.1.0.RC1.swc" />
			<element path="lib\granite-client-flex-udp-3.1.0.RC1.swc" />
			<element path="lib\granite-essentials.swc" />
		  </libraryPaths>
		  <!-- External Libraries -->
		  <externalLibraryPaths>
			<!-- example: <element path="..." /> -->
		  </externalLibraryPaths>
		  <!-- Runtime Shared Libraries -->
		  <rslPaths>
			<!-- example: <element path="..." /> -->
		  </rslPaths>
		  <!-- Intrinsic Libraries -->
		  <intrinsics>
			<element path="Library\AS3\frameworks\Flex4" />
		  </intrinsics>
		  <!-- Assets to embed into the output SWF -->
		  <library>
			<!-- example: <asset path="..." id="..." update="..." glyphs="..." mode="..." place="..." sharepoint="..." /> -->
		  </library>
		  <!-- Class files to compile (other referenced classes will automatically be included) -->
		  <compileTargets>
			<compile path="Grails4NotesBroker.mxml" />
		  </compileTargets>
		  <!-- Paths to exclude from the Project Explorer tree -->
		  <hiddenPaths>
			<hidden path="obj" />
		  </hiddenPaths>
		  <!-- Executed before build -->
		  <preBuildCommand />
		  <!-- Executed after build -->
		  <postBuildCommand alwaysRun="False" />
		  <!-- Other project options -->
		  <options>
			<option showHiddenPaths="False" />
			<option testMovie="Default" />
			<option testMovieCommand="" />
		  </options>
		  <!-- Plugin storage -->
		  <storage />
		</project>
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC STATIC VAR
		//
		//--------------------------------------------------------------------------
		
		public static var IS_MACOS							: Boolean;
		public static var IS_DEVELOPMENT_MODE				: Boolean;
		public static var IS_AUTH_REQUIRED					: Boolean; // MoonshineServerPluginOpenSource
		public static var IS_BUNDLED_SDK_PRESENT			: Boolean;
		public static var IS_HELPER_DOWNLOADED_SDK_PRESENT	: Boolean;
		public static var IS_HELPER_DOWNLOADED_ANT_PRESENT	: Object;
		public static var IS_BUNDLED_SDK_PROMPT_DNS			: Boolean;
		public static var IS_SDK_HELPER_PROMPT_DNS			: Boolean;
		public static var IS_OSX_CODECOMPLETION_PROMPT		: Boolean;
		public static var IS_OSX_JAVA_SDK_PROMPT			: Boolean;
		public static var IS_CONSOLE_CLEARED_ONCE			: Boolean;
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC STATIC API
		//
		//--------------------------------------------------------------------------
		
		public static function generate():void
		{
			TEMPLATE_AS3CLASS = new FileLocation("TEMPLATE");
			TEMPLATE_AS3CLASS.fileBridge.name = "AS3 Class.as";
			TEMPLATE_AS3CLASS.fileBridge.isDirectory = false;
			TEMPLATE_AS3CLASS.fileBridge.extension = "as";
			TEMPLATE_AS3CLASS.fileBridge.data = <root><![CDATA[package $packageName
{
	public class $fileName
	{
	}
}]]></root>;
			
			TEMPLATE_AS3INTERFACE = new FileLocation("TEMPLATE");
			TEMPLATE_AS3INTERFACE.fileBridge.name = "AS3 Interface.as";
			TEMPLATE_AS3INTERFACE.fileBridge.isDirectory = false;
			TEMPLATE_AS3INTERFACE.fileBridge.extension = "as";
			TEMPLATE_AS3INTERFACE.fileBridge.data = <root><![CDATA[package $packageName
{
	public interface $fileName
	{
	}
}]]></root>;
			
			TEMPLATE_MXML = new FileLocation("TEMPLATE");
			TEMPLATE_MXML.fileBridge.name = "MXML File.mxml";
			TEMPLATE_MXML.fileBridge.isDirectory = false;
			TEMPLATE_MXML.fileBridge.extension = "mxml";
			TEMPLATE_MXML.fileBridge.data = <root><![CDATA[<?xml version="1.0" encoding="utf-8"?>
<s:Group xmlns:fx="http://ns.adobe.com/mxml/2009" 
		xmlns:s="library://ns.adobe.com/flex/spark" 
		xmlns:mx="library://ns.adobe.com/flex/mx">
	<fx:Script>
	</fx:Script>
	<fx:Declarations>
	</fx:Declarations>
</s:Group>]]></root>;
			
			TEMPLATE_CSS = new FileLocation("TEMPLATE");
			TEMPLATE_CSS.fileBridge.name = "CSS File.css";
			TEMPLATE_CSS.fileBridge.isDirectory = false;
			TEMPLATE_CSS.fileBridge.extension = "css";
			TEMPLATE_CSS.fileBridge.data = "";
			
			TEMPLATE_TEXT = new FileLocation("TEMPLATE");
			TEMPLATE_TEXT.fileBridge.name = "Text File.txt";
			TEMPLATE_TEXT.fileBridge.isDirectory = false;
			TEMPLATE_TEXT.fileBridge.extension = "txt";
			TEMPLATE_TEXT.fileBridge.data = "";
			
			TEMPLATE_XML = new FileLocation("TEMPLATE");
			TEMPLATE_XML.fileBridge.name = "XML File.xml";
			TEMPLATE_XML.fileBridge.isDirectory = false;
			TEMPLATE_XML.fileBridge.extension = "xml";
			TEMPLATE_XML.fileBridge.data = <root><![CDATA[<?xml version="1.0" encoding="utf-8"?>]]></root>;
			
			ACTIONSCRIPT_PROJECT = new FileLocation("Actionscript Project (SWF, Desktop)");
			ACTIONSCRIPT_PROJECT.fileBridge.name = "Actionscript Project (SWF, Desktop)";
			ACTIONSCRIPT_PROJECT.fileBridge.isDirectory = true;
			ACTIONSCRIPT_PROJECT.fileBridge.data = "Create a pure ActionScript project.";
			
			FLEXBROWSER_PROJECT = new FileLocation("Flex Browser Project (SWF)");
			FLEXBROWSER_PROJECT.fileBridge.name = "Flex Browser Project (SWF)";
			FLEXBROWSER_PROJECT.fileBridge.isDirectory = true;
			FLEXBROWSER_PROJECT.fileBridge.data = "Create a Flex project that will generate an SWF and HTML files, to run on browser.";
			
			FLEXDESKTOP_PROJECT = new FileLocation("Flex Desktop Project (MacOS, Windows)");
			FLEXDESKTOP_PROJECT.fileBridge.name = "Flex Desktop Project (MacOS, Windows)";
			FLEXDESKTOP_PROJECT.fileBridge.isDirectory = true;
			FLEXDESKTOP_PROJECT.fileBridge.data = "Create a Flex project that will generate a desktop application. This can be used to generate .AIR, .EXE (Windows only) and .DMG (OSX) installers.";
			
			FLEXJS_PROJECT = new FileLocation("Flex Browser Project (FlexJS)");
			FLEXJS_PROJECT.fileBridge.name = "Flex Browser Project (FlexJS)";
			FLEXJS_PROJECT.fileBridge.isDirectory = true;
			FLEXJS_PROJECT.fileBridge.data = "Create a FlexJS project that will generate an SWF and HTML files, to run on browser.";
			
			FLEXMOBILE_PROJECT = new FileLocation("Flex Mobile Project (iOS, Android)");
			FLEXMOBILE_PROJECT.fileBridge.name = "Flex Mobile Project (iOS, Android)";
			FLEXMOBILE_PROJECT.fileBridge.isDirectory = true;
			FLEXMOBILE_PROJECT.fileBridge.data = "Create a project that will create an application designed for mobile devices.";
			
			HAXESWF_PROJECT = new FileLocation("HaXe SWF Project");
			HAXESWF_PROJECT.fileBridge.name = "HaXe SWF Project";
			HAXESWF_PROJECT.fileBridge.isDirectory = true;
			HAXESWF_PROJECT.fileBridge.data = "Create a HaXe-based project that will generate a SWF file only.";

			VISUALEDITOR_FLEX_PROJECT = new FileLocation("Visual Editor Project (Flex)");
			VISUALEDITOR_FLEX_PROJECT.fileBridge.name = "Visual Editor Project (Flex)";
            VISUALEDITOR_FLEX_PROJECT.fileBridge.isDirectory = true;
            VISUALEDITOR_FLEX_PROJECT.fileBridge.data = "Create a Flex project using visual editor.";

			var openTemplateProjectVO:TemplateVO = new TemplateVO();
			var openTemplateProject:FileLocation = new FileLocation("");
			openTemplateProjectVO.title = openTemplateProject.fileBridge.name = "Open Apache® Flex/JS Project..";
			openTemplateProjectVO.logoImagePath = "/elements/images/Open Project.png"
			openTemplateProject.fileBridge.data = openTemplateProjectVO.description = "Import or Open an ActionScript or Apache® Flex Project in Moonshine.";
			openTemplateProjectVO.file = openTemplateProject;
			
			TEMPLATES_OPEN_PROJECTS = new ArrayCollection([IS_AIR ? openTemplateProjectVO : openTemplateProject]);
			TEMPLATES_FILES = new ArrayCollection([TEMPLATE_AS3CLASS, TEMPLATE_AS3INTERFACE, TEMPLATE_MXML, TEMPLATE_CSS, TEMPLATE_TEXT, TEMPLATE_XML]);
			TEMPLATES_PROJECTS = new ArrayCollection([ACTIONSCRIPT_PROJECT,FLEXBROWSER_PROJECT,FLEXDESKTOP_PROJECT,FLEXMOBILE_PROJECT,FLEXJS_PROJECT,VISUALEDITOR_FLEX_PROJECT,FLEXJSBL_PROJECT,HAXESWF_PROJECT]);
			
			MENU_TOOLTIP = new ArrayCollection([{label:"Open",tooltip:"Open File/Project"},{label:"Save",tooltip:"Save File"},{label:"Save As",tooltip:"Save As"},{label:"Close",tooltip:"Close File"},{label:"Find",tooltip:"Find/Replace Text"},
				{label:"Find previous",tooltip:"Find Previous Text"},{label:"Find Resource",tooltip:"Find File Resource"},{label:"Project view",tooltip:"Display Project View"},{label:"Fullscreen",tooltip:"Set Fuulscreen View"},
				{label:"Debug view",tooltip:"Display Debug View"},{label:"Splashscreen",tooltip:"Display Fullscreen"},{label:"Build Project",tooltip:"Build Project"},{label:"Build & Run",tooltip:"Build & Run Project"},
				{label:"Build and Run as Javascript",tooltip:"Create JS/HTML files from AS/MXML files using FlexJS SDK"},{label:"Build Release",tooltip:"Build & Release of Project"},{label:"Clean Project",tooltip:"Clean Project"},
				{label:"Build & Debug",tooltip:"Build & Debug Project"},{label:"Step Over",tooltip:"Step to next line"},{label:"Resume",tooltip:"Continue execution till next breakpoint"},{label:"Stop",tooltip:"Terminate debug execution"},
				{label:"Ant Build",tooltip:"Build Project through Ant script"},{label:"Configure",tooltip:"Select xml file for Ant build"}]);
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE STATIC API
		//
		//--------------------------------------------------------------------------
		
		private static function getNewTemplateType(fileName:String, isDirectory:Boolean, extension:String, data:String=null):Object
		{
			var newTemplate:Object = new Object();
			newTemplate.name = fileName;
			newTemplate.isDirectory = isDirectory;
			newTemplate.extension = extension;
			newTemplate.data = data;
			
			return newTemplate;
		}
	}
}