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
package actionScripts.valueObjects
{
    import flash.system.Capabilities;
    import flash.system.Security;
    
    import mx.collections.ArrayCollection;
    import mx.collections.ArrayList;
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;
    
    import actionScripts.factory.FileLocation;
    import actionScripts.locator.IDEModel;

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
		public static const MOONSHINE_PROD_ID: String = "com.moonshine-ide";
		public static const EVENT_PROBLEMS:String = "EVENT_PROBLEMS";
		public static const EVENT_SHOW_DEBUG_VIEW:String = "EVENT_SHOW_DEBUG_VIEW";
		public static const MOONSHINE_IDE_LABEL:String = "Moonshine IDE™";
		public static const MOONSHINE_IDE_COPYRIGHT_LABEL:String = "Copyright © STARTcloud, Inc. 2015-"+ (new Date().fullYear) +". All rights reserved.";
		public static const MAX_DEPTH_COUNT_IN_PROJECT_SEARCH:int = 3;
		
		[Embed(source='/elements/swf/loading.swf')]
		public static var loaderIcon: Class;
		[Embed(source='/elements/images/icoSource.png')]
		public static var sourceFolderIcon: Class;
		[Embed(source='/elements/images/icoTick.png')]
		public static var menuTickIcon: Class;
		[Embed(source='/elements/images/label_git.png')]
		public static var gitLabelIcon: Class;
		[Embed(source='/elements/images/label_svn.png')]
		public static var svnLabelIcon: Class;
		[Embed(source='/elements/images/label_xml.png')]
		public static var xmlLabelIcon: Class;
		[Embed(source="/elements/images/icoSmallClose.png")]
		public static var SMALL_CROSS_BUTTON: Class;
		public static var FLEX_PROJECTS: ArrayList;
		
		[Embed("/elements/images/upArrow_menuScroll.png")]
		public static var up_icon_menu_scroll:Class;
		[Embed("/elements/images/downArrow_menuScroll.png")]
		public static var down_icon_menu_scroll:Class;
		
		public static var TEMPLATE_AS3CLASS: FileLocation;
		public static var TEMPLATE_AS3INTERFACE: FileLocation;
		public static var TEMPLATE_CSS: FileLocation;
		public static var TEMPLATE_DOMINO_FORM: FileLocation;
		public static var TEMPLATE_DOMINO_PAGE: FileLocation;
		public static var TEMPLATE_DOMINO_SUBFORM: FileLocation;
		public static var TEMPLATE_DOMINO_VIEW: FileLocation;
		public static var TEMPLATE_DOMINO_VIEW_SHARE_COLUMN: FileLocation;
		public static var TEMPLATE_DOMINO_SHAREDFIELD: FileLocation;
		public static var TEMPLATE_DOMINO_ACTION: FileLocation;
		public static var TEMPLATE_TEXT: FileLocation;
		public static var TEMPLATE_XML: FileLocation;
		public static var TEMPLATE_MXML: FileLocation;
		public static var TEMPLATE_MXML_MODULE: FileLocation;
		public static var TEMPLATE_VISUAL_EDITOR_FLEX:FileLocation;
		public static var TEMPLATE_VISUAL_EDITOR_PRIMEFACES:FileLocation;
		public static var TEMPLATE_VISUAL_EDITOR_DOMINO:FileLocation;
		
		public static var TEMPLATES_FILES: ArrayCollection;
		public static var TEMPLATES_PROJECTS: ArrayCollection;
		
		public static var TEMPLATES_PROJECTS_SPECIALS:ArrayCollection;
		public static var TEMPLATES_PROJECTS_ROYALE:ArrayCollection;
		public static var TEMPLATES_PROJECTS_ROYALE_VISUAL:ArrayCollection;
		public static var TEMPLATES_PROJECTS_ROYALE_DOMINO_EXPORT:ArrayCollection;
		public static var TEMPLATES_PROJECTS_JAVA:ArrayCollection;
		public static var TEMPLATES_PROJECTS_GRAILS:ArrayCollection;
		public static var TEMPLATES_PROJECTS_HAXE:ArrayCollection;
		public static var TEMPLATES_PROJECTS_ACTIONSCRIPT:ArrayCollection;
		
		public static var TEMPLATES_MXML_COMPONENTS:ArrayCollection = new ArrayCollection();
        public static var TEMPLATES_MXML_FLEXJS_COMPONENTS:ArrayCollection = new ArrayCollection();
        public static var TEMPLATES_MXML_ROYALE_COMPONENTS:ArrayCollection = new ArrayCollection();
        
		public static var TEMPLATES_VISUALEDITOR_FILES_FLEX:ArrayCollection = new ArrayCollection();
        public static var TEMPLATES_VISUALEDITOR_FILES_PRIMEFACES:ArrayCollection = new ArrayCollection();
		public static var TEMPLATES_VISUALEDITOR_FILES_DOMINO:ArrayCollection = new ArrayCollection();
		public static var TEMPLATES_VISUALEDITOR_FILES_DOMINO_FORM:FileLocation ;

		
		public static var TEMPLATE_ODP_VISUALEDITOR_FILE:FileLocation;
		public static var TEMPLATE_ODP_FORMBUILDER_FILE:FileLocation;
		
		public static var TEMPLATES_OPEN_PROJECTS: ArrayCollection;

		public static var TEMPLATES_NEWS_MOONSHINE:ArrayCollection;

		public static var TEMPLATES_ANDROID_DEVICES:ArrayCollection;
		public static var TEMPLATES_IOS_DEVICES:ArrayCollection;
		
		public static var TEMPLATES_WEB_BROWSERS:ArrayCollection;
		
		public static var VISUALEDITOR_FLEX_PROJECT:FileLocation;
		public static var ONDISK_PROJECT:FileLocation;
		public static var ACTIONSCRIPT_PROJECT:FileLocation;
		public static var LIBRARY_PROJECT_PROJECT:FileLocation;
		public static var FLEXBROWSER_PROJECT:FileLocation;
		public static var FLEXDESKTOP_PROJECT:FileLocation;
		public static var FLEXMOBILE_PROJECT:FileLocation;
		public static var FLEXJS_PROJECT:FileLocation;
        public static var ROYALE_PROJECT:FileLocation;
		public static var MENU_TOOLTIP: ArrayCollection;
		public static var READABLE_FILES:Array;
		public static var KNOWN_BINARY_FILES:Array;
		public static var READABLE_CLASS_FILES:Array;
		public static var READABLE_PROJECT_FILES:Array;
		public static var NON_CLOSEABLE_TABS:Array;
		public static var STARTUP_PROJECT_OPEN_QUEUE_LEFT:int;
		public static var LAST_BROWSED_LOCATION:String;
		public static var CURRENT_WORKSPACE:String;
		
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
		public static var is64BitSupport					: Boolean = Capabilities.supports64BitProcesses;
		public static var IS_DEVELOPMENT_MODE				: Boolean;
		public static var IS_AUTH_REQUIRED					: Boolean; // MoonshineServerPluginOpenSource
		public static var IS_BUNDLED_SDK_PRESENT			: Boolean;
		public static var IS_HELPER_DOWNLOADED_SDK_PRESENT	: Boolean;
		public static var IS_HELPER_DOWNLOADED_ANT_PRESENT	: Object;
		public static var IS_BUNDLED_SDK_PROMPT_DNS			: Boolean;
		public static var IS_SDK_HELPER_PROMPT_DNS			: Boolean;
		public static var IS_GETTING_STARTED_DNS			: Boolean;
		public static var IS_OSX_CODECOMPLETION_PROMPT		: Boolean;
		public static var IS_OSX_JAVA_SDK_PROMPT			: Boolean;
		public static var IS_CONSOLE_CLEARED_ONCE			: Boolean;
		public static var IS_GIT_OSX_AVAILABLE				: Boolean;
		public static var IS_APP_STORE_VERSION				: Boolean;
		public static var IS_DEFAULT_REPOSITORIES_POPULATED	: Boolean;
		public static var IS_APPLICATION_CLOSING			: Boolean;
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC STATIC API
		//
		//--------------------------------------------------------------------------
		
		public static function generate():void
		{
			var resourceManager:IResourceManager = ResourceManager.getInstance();
			
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
			
			READABLE_FILES = ["as", "mxml", "css", "xml", "bat", "txt", "as3proj", "actionScriptProperties", "html", "js", "veditorproj", "xhtml",
								"java", "groovy", "gradle", "yml", "gsp", "properties", "javaproj", "sh", "ini", "jar", "hx", "hxproj", "grailsproj",
								"json", "md", "tbh", "tbs", "tpr", "tph"];
			READABLE_FILES.sort();

			KNOWN_BINARY_FILES = ["nsf", "jpg", "jpeg", "png"]; // store in lower-case

			READABLE_CLASS_FILES = ["as", "mxml", "java", "groovy", "gradle", "hx", "tbs", "tbh"];
			READABLE_CLASS_FILES.sort();

			READABLE_PROJECT_FILES = ["actionScriptProperties", "as3proj", "veditorproj", "javaproj", "grailsproj", "ondiskproj", "genericproj", "hxproj", "tibboproj"];

					TEMPLATE_CSS = new FileLocation("TEMPLATE");
			TEMPLATE_CSS.fileBridge.name = "CSS File.css";
			TEMPLATE_CSS.fileBridge.isDirectory = false;
			TEMPLATE_CSS.fileBridge.extension = "css";
			TEMPLATE_CSS.fileBridge.data = "";

			TEMPLATE_DOMINO_FORM = new FileLocation("TEMPLATE");
			TEMPLATE_DOMINO_FORM.fileBridge.name = "Domino Visual Editor Form.form";
			TEMPLATE_DOMINO_FORM.fileBridge.isDirectory = false;
			TEMPLATE_DOMINO_FORM.fileBridge.extension = "form";
			TEMPLATE_DOMINO_FORM.fileBridge.data = "";


			TEMPLATE_DOMINO_PAGE = new FileLocation("TEMPLATE");
			TEMPLATE_DOMINO_PAGE.fileBridge.name = "Domino Visual Editor Page.page";
			TEMPLATE_DOMINO_PAGE.fileBridge.isDirectory = false;
			TEMPLATE_DOMINO_PAGE.fileBridge.extension = "page";
			TEMPLATE_DOMINO_PAGE.fileBridge.data = "";

			//TEMPLATE_DOMINO_SUBFORM
			TEMPLATE_DOMINO_SUBFORM = new FileLocation("TEMPLATE");
			TEMPLATE_DOMINO_SUBFORM.fileBridge.name = "Domino Visual Editor Subform.subform";
			TEMPLATE_DOMINO_SUBFORM.fileBridge.isDirectory = false;
			TEMPLATE_DOMINO_SUBFORM.fileBridge.extension = "subform";
			TEMPLATE_DOMINO_SUBFORM.fileBridge.data = "";

			TEMPLATE_DOMINO_VIEW = new FileLocation("TEMPLATE");
			TEMPLATE_DOMINO_VIEW.fileBridge.name = "Domino Visual Editor View.view";
			TEMPLATE_DOMINO_VIEW.fileBridge.isDirectory = false;
			TEMPLATE_DOMINO_VIEW.fileBridge.extension = "view";
			TEMPLATE_DOMINO_VIEW.fileBridge.data = "";


			TEMPLATE_DOMINO_VIEW_SHARE_COLUMN= new FileLocation("TEMPLATE");
			TEMPLATE_DOMINO_VIEW_SHARE_COLUMN.fileBridge.name = "Domino Visual Editor View Shared Column.column";
			TEMPLATE_DOMINO_VIEW_SHARE_COLUMN.fileBridge.isDirectory = false;
			TEMPLATE_DOMINO_VIEW_SHARE_COLUMN.fileBridge.extension = "view";
			TEMPLATE_DOMINO_VIEW_SHARE_COLUMN.fileBridge.data = "";

			
			
			//FOR SHAREDFIELD
			TEMPLATE_DOMINO_SHAREDFIELD= new FileLocation("TEMPLATE");
			TEMPLATE_DOMINO_SHAREDFIELD.fileBridge.name = "Domino Visual Share Field.field";
			TEMPLATE_DOMINO_SHAREDFIELD.fileBridge.isDirectory = false;
			TEMPLATE_DOMINO_SHAREDFIELD.fileBridge.extension = "field";
			TEMPLATE_DOMINO_SHAREDFIELD.fileBridge.data = "";

			//TEMPLATE_DOMINO_ACTION
			TEMPLATE_DOMINO_ACTION = new FileLocation("TEMPLATE");
			TEMPLATE_DOMINO_ACTION.fileBridge.name = "Domino Visual Editor ACtion.action";
			TEMPLATE_DOMINO_ACTION.fileBridge.isDirectory = false;
			TEMPLATE_DOMINO_ACTION.fileBridge.extension = "action";
			TEMPLATE_DOMINO_ACTION.fileBridge.data = "";



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

			TEMPLATE_VISUAL_EDITOR_FLEX = new FileLocation("TEMPLATE");
            TEMPLATE_VISUAL_EDITOR_FLEX.fileBridge.name = "Visual Editor Flex File.mxml";
            TEMPLATE_VISUAL_EDITOR_FLEX.fileBridge.isDirectory = false;
            TEMPLATE_VISUAL_EDITOR_FLEX.fileBridge.extension = "mxml";
            TEMPLATE_VISUAL_EDITOR_FLEX.fileBridge.data = <root><![CDATA[<?xml version="1.0" encoding="utf-8"?>
																	<s:Group xmlns:fx="http://ns.adobe.com/mxml/2009"
																			xmlns:s="library://ns.adobe.com/flex/spark"
																			xmlns:mx="library://ns.adobe.com/flex/mx">
																	</s:Group>]]></root>;

            TEMPLATE_VISUAL_EDITOR_PRIMEFACES = new FileLocation("TEMPLATE");
            TEMPLATE_VISUAL_EDITOR_PRIMEFACES.fileBridge.name = "Visual Editor PrimeFaces File.mxml";
            TEMPLATE_VISUAL_EDITOR_PRIMEFACES.fileBridge.isDirectory = false;
            TEMPLATE_VISUAL_EDITOR_PRIMEFACES.fileBridge.extension = "xhml";
            TEMPLATE_VISUAL_EDITOR_PRIMEFACES.fileBridge.data = <root><![CDATA[<?xml version='1.0' encoding='UTF-8' ?>
																				<!DOCTYPE html>
																				<html xmlns="http://www.w3.org/1999/xhtml"
																					  xmlns:h="http://xmlns.jcp.org/jsf/html"
																					  xmlns:p="http://primefaces.org/ui">

			TEMPLATE_VISUAL_EDITOR_DOMINO = new FileLocation("TEMPLATE");
            TEMPLATE_VISUAL_EDITOR_DOMINO.fileBridge.name = "Visual Editor Domino Form.mxml";
            TEMPLATE_VISUAL_EDITOR_DOMINO.fileBridge.isDirectory = false;
            TEMPLATE_VISUAL_EDITOR_DOMINO.fileBridge.extension = "form";
          	TEMPLATE_VISUAL_EDITOR_DOMINO.fileBridge.data = <root><![CDATA[
				<?xml version='1.0' encoding='utf-8'?>
<form name='BGP Network' xmlns='http://www.lotus.com/dxl'  publicaccess='false' designerversion='8.5.3' renderpassthrough='true'>
<code
 event='windowtitle'><formula>Form + ": " + BGPNetwork1122</formula></code>
<actionbar bgcolor='#ece9d8' bordercolor='black'>
<actionbuttonstyle bgcolor='#ece9d8'/><font color='system'/><border style='solid'
 width='0px 0px 1px'/>
<sharedactionref id='224'>
<action title='Save and Close' icon='10' hide='preview read'><code event='click'><formula
>@Command([FileSave]);
@Command([FileCloseWindow])</formula></code></action></sharedactionref>
<sharedactionref id='222'>
<action title='Close' icon='149'><code event='click'><formula>@Command([FileCloseWindow])</formula></code></action></sharedactionref>
<sharedactionref id='223'>
<action title='Edit' icon='5' hide='edit previewedit'><code event='click'><formula
>@Command([EditDocument])</formula></code></action></sharedactionref></actionbar>
<body><richtext>
<pardef id='1' hide='read edit print notes web mobile'/>
<par def='1'/><subformref name='ControlledDelete'/>
<pardef id='2' firstlineleftmargin='1in' hide='read edit print notes web mobile'/>
<par def='2'/>
<table cellbordercolor='#efefef' widthtype='fixedleft' refwidth='5.1660in'><tablecolumn
 width='1.5833in'/><tablecolumn width='3.5826in'/>
<tablerow>
<tablecell columnspan='2' borderwidth='0px' bgcolor='#9f9fff'>
<pardef id='5' keepwithnext='true' keeptogether='true'/>
<par def='5'><run><font style='bold' color='white'/>Network Info</run></par></tablecell></tablerow>
<tablerow>
<tablecell borderwidth='0px'>
<pardef id='4' keepwithnext='true' keeptogether='true'/>
<par def='4'/></tablecell>
<tablecell borderwidth='0px'>
<pardef id='6' keepwithnext='true' keeptogether='true'/>
<par def='6'/></tablecell></tablerow>
<tablerow>
<tablecell borderwidth='0px 0px 1px'>
<par def='4'>Site ID:</par></tablecell>
<tablecell borderwidth='0px 0px 1px'>
<par def='6'><field choicesdialog='view' viewdatabase='' view='Sites' viewcolumn='1'
 lookupeachchar='false' lookupaddressonrefresh='false' type='keyword' kind='editable'
 name='Site_UNID_FK'><keywords recalconchange='true' recalcchoices='true'
 columns='1' ui='dialoglist'/></field></par></tablecell></tablerow>
<tablerow>
<tablecell borderwidth='1px 0px'>
<par def='4'>Network:</par></tablecell>
<tablecell borderwidth='1px 0px'>
<par def='6'><field type='text' kind='editable' name='BGPNetwork'/><compositedata
 type='98' prevtype='65418' nexttype='222' afterparcount='6' containertype='65418'
 aftercontainercount='1' afterbegincount='3'>
Yg4BAIQAAAAAAAAAAAA=
</compositedata></par></tablecell></tablerow>
<tablerow>
<tablecell borderwidth='1px 0px'>
<par def='4'>Mask:</par></tablecell>
<tablecell borderwidth='1px 0px'>
<par def='6'><field type='text' kind='editable' name='BGPMask'/><compositedata
 type='98' prevtype='65418' nexttype='222' afterparcount='6' containertype='65418'
 aftercontainercount='1' afterbegincount='3'>
Yg4BAIQAAAAAAAAAAAA=
</compositedata></par></tablecell></tablerow>
<tablerow>
<tablecell borderwidth='1px 0px'>
<par def='4'>Provider:</par></tablecell>
<tablecell borderwidth='1px 0px'>
<par def='6'><field type='keyword' kind='editable' name='BGPNetblockProvider'><keywords
 ui='dialoglist'><textlist><text>McLeod</text><text>Sprint</text></textlist></keywords></field></par></tablecell></tablerow>
<tablerow>
<tablecell borderwidth='1px 0px'>
<par def='4'>Partition Name Tag:</par></tablecell>
<tablecell borderwidth='1px 0px'>
<par def='6'><field type='text' kind='editable' name='BGPNetwork_PartitionNameTag'/><compositedata
 type='98' prevtype='65418' nexttype='222' afterparcount='6' containertype='65418'
 aftercontainercount='1' afterbegincount='3'>
Yg4BAIQAAAAAAAAAAAA=
</compositedata></par></tablecell></tablerow></table>
<pardef id='7'/>
<par def='7'/></richtext></body>
</form>
			]]></root>;

			ACTIONSCRIPT_PROJECT = new FileLocation("ActionScript Project (SWF, Desktop)");
			ACTIONSCRIPT_PROJECT.fileBridge.name = "ActionScript Project (SWF, Desktop)";
			ACTIONSCRIPT_PROJECT.fileBridge.isDirectory = true;
			ACTIONSCRIPT_PROJECT.fileBridge.data = "Create a pure ActionScript project.";
			
			LIBRARY_PROJECT_PROJECT = new FileLocation("Library Project");
			LIBRARY_PROJECT_PROJECT.fileBridge.name = "Library Project";
			LIBRARY_PROJECT_PROJECT.fileBridge.isDirectory = true;
			LIBRARY_PROJECT_PROJECT.fileBridge.data = "Create a Flex/ActionScript library project.";
			
			FLEXBROWSER_PROJECT = new FileLocation("Flex Browser Project (SWF)");
			FLEXBROWSER_PROJECT.fileBridge.name = "Flex Browser Project (SWF)";
			FLEXBROWSER_PROJECT.fileBridge.isDirectory = true;
			FLEXBROWSER_PROJECT.fileBridge.data = "Create a Flex project that will generate an SWF and HTML files, to run on browser.";
			
			FLEXDESKTOP_PROJECT = new FileLocation("Flex Desktop Project (MacOS, Windows)");
			FLEXDESKTOP_PROJECT.fileBridge.name = "Flex Desktop Project (MacOS, Windows)";
			FLEXDESKTOP_PROJECT.fileBridge.isDirectory = true;
			FLEXDESKTOP_PROJECT.fileBridge.data = "Create a Flex project that will generate a desktop application. This can be used to generate .AIR, .EXE (Windows only) and .DMG (OSX) installers.";
			
			FLEXJS_PROJECT = new FileLocation("Flex Browser Project (Royale)");
			FLEXJS_PROJECT.fileBridge.name = "Flex Browser Project (Royale)";
			FLEXJS_PROJECT.fileBridge.isDirectory = true;
			FLEXJS_PROJECT.fileBridge.data = "Create a Apache Royale project that will generate an SWF and HTML files, to run on browser.";

            ROYALE_PROJECT = new FileLocation("Royale Browser Project");
            ROYALE_PROJECT.fileBridge.name = "Royale Browser Project";
            ROYALE_PROJECT.fileBridge.isDirectory = true;
            ROYALE_PROJECT.fileBridge.data = "Create a Apache Royale project that will generate an SWF and HTML files, to run on browser.";

			FLEXMOBILE_PROJECT = new FileLocation("Flex Mobile Project (iOS, Android)");
			FLEXMOBILE_PROJECT.fileBridge.name = "Flex Mobile Project (iOS, Android)";
			FLEXMOBILE_PROJECT.fileBridge.isDirectory = true;
			FLEXMOBILE_PROJECT.fileBridge.data = "Create a project that will create an application designed for mobile devices.";

			VISUALEDITOR_FLEX_PROJECT = new FileLocation(resourceManager.getString('resources', 'VE_PROJECT'));
			VISUALEDITOR_FLEX_PROJECT.fileBridge.name = resourceManager.getString('resources', 'VE_PROJECT');
            VISUALEDITOR_FLEX_PROJECT.fileBridge.isDirectory = true;
            VISUALEDITOR_FLEX_PROJECT.fileBridge.data = "Create a Flex project using visual editor.";

            var moonshineDevVO:TemplateVO = new TemplateVO();
                moonshineDevVO.logoImagePath = "/elements/images/moonshine-logo-circle.png";
                moonshineDevVO.link = "https://www.moonshine.dev/";
                moonshineDevVO.displayHome = true;
                moonshineDevVO.homeTitle = "New web version features advanced Design View and AI at Moonshine.dev!";
                moonshineDevVO.title = "New web version features advanced Design View and AI at Moonshine.dev!";

            var topicBoxVO:TemplateVO = new TemplateVO();
                topicBoxVO.logoImagePath = "/elements/images/Topicbox_Icon_RGB.png";
                topicBoxVO.link = "https://moonshine-ide.topicbox.com/latest";
                topicBoxVO.displayHome = true;
                topicBoxVO.homeTitle = "View the Moonshine user group discussion forum";
                topicBoxVO.title = "View the Moonshine user group discussion forum";

            TEMPLATES_NEWS_MOONSHINE = new ArrayCollection([moonshineDevVO, topicBoxVO]);

			var openTemplateProjectVO:TemplateVO = new TemplateVO();
			var openTemplateProject:FileLocation = new FileLocation("");
			openTemplateProject.fileBridge.name = "Open/Import Project...";

			openTemplateProjectVO.displayHome = true;
			openTemplateProjectVO.homeTitle = "Open/Import Project...";
			openTemplateProjectVO.title = "Open/Import Project...";
			openTemplateProjectVO.logoImagePath = "/elements/images/Open Project.png";
			openTemplateProject.fileBridge.data = openTemplateProjectVO.description = "Import or Open Project in "+ ConstantsCoreVO.MOONSHINE_IDE_LABEL;
			openTemplateProjectVO.file = openTemplateProject;
			
			TEMPLATES_OPEN_PROJECTS = new ArrayCollection([IS_AIR ? openTemplateProjectVO : openTemplateProject]);

			TEMPLATES_FILES = new ArrayCollection([TEMPLATE_AS3CLASS, TEMPLATE_AS3INTERFACE, TEMPLATE_MXML, TEMPLATE_CSS, TEMPLATE_TEXT, TEMPLATE_XML, TEMPLATE_VISUAL_EDITOR_FLEX, TEMPLATE_VISUAL_EDITOR_PRIMEFACES, TEMPLATE_VISUAL_EDITOR_DOMINO]);
			TEMPLATES_PROJECTS = new ArrayCollection([ACTIONSCRIPT_PROJECT,LIBRARY_PROJECT_PROJECT,FLEXBROWSER_PROJECT,FLEXDESKTOP_PROJECT,FLEXMOBILE_PROJECT,FLEXJS_PROJECT,ROYALE_PROJECT,VISUALEDITOR_FLEX_PROJECT]);
			
			MENU_TOOLTIP = new ArrayCollection([{label:"Open",tooltip:"Open File/Project"},{label:"Save",tooltip:"Save File"},{label:"Save As",tooltip:"Save As"},{label:"Close",tooltip:"Close File"},{label:"Find",tooltip:"Find/Replace Text"},
				{label:"Find previous",tooltip:"Find Previous Text"},{label:"Find Resource",tooltip:"Find File Resource"},{label:"Project view",tooltip:"Display Project View"},{label:"Fullscreen",tooltip:"Set Fuulscreen View"},
				{label:"Debug view",tooltip:"Display Debug View"},{label:"Splashscreen",tooltip:"Display Fullscreen"},{label:"Build Project",tooltip:"Build Project"},{label:"Build & Run",tooltip:"Build & Run Project"},
				{label:"Build and Run as Javascript",tooltip:"Create JS/HTML files from AS/MXML files using FlexJS SDK"},{label:"Build Release",tooltip:"Build & Release of Project"},{label:"Clean Project",tooltip:"Clean Project"},
				{label:"Build & Debug",tooltip:"Build & Debug Project"},{label:"Step Over",tooltip:"Step to next line"},{label:"Resume",tooltip:"Continue execution till next breakpoint"},{label:"Stop",tooltip:"Terminate debug execution"},
				{label:"Ant Build",tooltip:"Build Project through Ant script"},{label:"Configure",tooltip:"Select xml file for Ant build"}]);
			
			NON_CLOSEABLE_TABS = ["*Away Builder", "Away Builder"];
		}
		
		public static function generateDevices():void
		{
			var tmpConfiguration:FileLocation = IDEModel.getInstance().fileCore.resolveApplicationDirectoryPath("elements/Config.xml");
			if (tmpConfiguration.fileBridge.exists)
			{
				TEMPLATES_ANDROID_DEVICES = new ArrayCollection();
				TEMPLATES_IOS_DEVICES = new ArrayCollection();
				
				var tmpXML:XML = new XML(tmpConfiguration.fileBridge.read());
				for each (var i:XML in tmpXML..device)
				{
					if (String(i.@type) == "AND") TEMPLATES_ANDROID_DEVICES.addItem(new MobileDeviceVO(String(i.@name), String(i.@key), String(i.@type), String(i.@screenDPI), true));
					else TEMPLATES_IOS_DEVICES.addItem(new MobileDeviceVO(String(i.@name), String(i.@key), String(i.@type), String(i.@screenDPI), true));
				}
				
				TEMPLATES_WEB_BROWSERS = new ArrayCollection();
				for each (i in tmpXML..browser)
				{
					TEMPLATES_WEB_BROWSERS.addItem(new WebBrowserVO(String(i.@name), String(i.@debugAdapter), true));
				}
			}
		}
	}
}