////////////////////////////////////////////////////////////////////////////////
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
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.utils
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.ToolTipEvent;
	import mx.managers.PopUpManager;
	
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.save.SaveFilesPlugin;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.DataHTMLType;
	import actionScripts.valueObjects.FileWrapper;
	import actionScripts.valueObjects.ProjectReferenceVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.Settings;
	
	import components.popup.SDKDefinePopup;
	import components.popup.SDKSelectorPopup;
	import components.popup.UnsaveFileMessagePopup;
	import components.renderers.CustomToolTipGBA;

	public class UtilsCore 
	{
		public static var wrappersFoundThroughFindingAWrapper:Vector.<FileWrapper>;
		private static var sdkPopup:SDKSelectorPopup;
		private static var sdkPathPopup:SDKDefinePopup;
		/**
		 * Get data agent error type
		 */
		public static function getDataType(value:String):DataHTMLType
		{
			var dataType:DataHTMLType = new DataHTMLType();
			var message:String;
			
			// true if it's a login agent call
			if ((value.indexOf("/Grails4NotesBroker/admin/auth") != -1) || (value.indexOf("Please Login") != -1))
			{
				// error is a login error
				var indexToStart:int = value.indexOf("<div class='login_message'>");
				if (indexToStart > 0) message = value.substring(indexToStart+27, value.indexOf("</div>", indexToStart));
				else message = "Please, check your username or password.";
				
				dataType.message = message;
				dataType.type = DataHTMLType.LOGIN_ERROR;
				dataType.isError = true;
			}
			else if ((value.toLowerCase().indexOf("authenticated") != -1) || (value.toLowerCase().indexOf("welcome to grails") != -1))
			{
				dataType.isError = false;
				dataType.type = DataHTMLType.LOGIN_SUCCESS;
			}
			else
			{
				dataType.message = "Your session has expired. Please, re-login.";
				dataType.type = DataHTMLType.SESSION_ERROR;
				dataType.isError = true;
			}
			
			return dataType;
		}
		
		/**
		 * Checks through opened project list against
		 * a given path value
		 * @return
		 * BOOL
		 */
		public static function checkProjectIfAlreadyOpened(value:String):Boolean
		{
			for each (var file:AS3ProjectVO in IDEModel.getInstance().projects)
			{
				if (file.folderLocation.fileBridge.nativePath == value)
				{
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Creates custom tooltip
		 */
		public static function createCustomToolTip(event:ToolTipEvent):void
		{
			var cTT : CustomToolTipGBA = new CustomToolTipGBA();
			event.toolTip = cTT;
		}
		
		/**
		 * Positions the toolTip
		 */
		public static function positionTip(event:ToolTipEvent):void
		{
			var tmpPoint : Point = getContentToGlobalXY( event.currentTarget as UIComponent );
			event.toolTip.y = tmpPoint.y + 20;
			event.toolTip.x = event.toolTip.x - 20;
		}
		
		/**
		 * Getting a component co-ordinate
		 * in respect of global stage
		 */
		public static function getContentToGlobalXY(dObject:UIComponent):Point
		{
			var thisHolderPoint : Point = UIComponent(dObject.owner).contentToGlobal( new Point( dObject.x, dObject.y ) );
			var newP : Point = FlexGlobals.topLevelApplication.globalToContent( thisHolderPoint );
			return newP;
		}
		
		/**
		 * Deserializes True and False strings to true and false Boolean values.
		 */
		public static function deserializeBoolean(o:Object):Boolean {
			var str:String = o.toString();
			return (str.toLowerCase() == "true") ? true:false;
		}
		/**
		 * Serializes a Boolean value into True or False strings.
		 */
		public static function serializeBoolean(b:Boolean):String {
			return b ? "True" : "False";
		}
		
		/**
		 * Deserialize a String value so it's null when empty
		 */
		public static function deserializeString(o:Object):String {
			var str:String = o.toString();
			if (str.length == 0) return null;
			return str;
		}
		
		/**
		 * Serialize a String value so it's empty when null
		 */
		public static function serializeString(str:String):String {
			return str ? str : "";
		}
		
		/**
		 * Serialize key-value pairs to FD-like XML elements using a template element
		 *  Example:
		 *		<option accessible="True" />
		 *		<option allowSourcePathOverlap="True" />
		 *		<option benchmark="True" />
		 *		<option es="True" />
		 *		<option locale="" />
		 */
		public static function serializePairs(pairs:Object, template:XML):XMLList {
			var list:XML = <xml/>;
			for (var key:String in pairs) {
				var node:XML = template.copy();
				node.@[key] = pairs[key];
				list.appendChild(node);
			}
			return list.children();
		}
		
		public static function fixSlashes(path:String):String
		{
			if (!path) return null;
			
			//path = path.replace(/\//g, IDEModel.getInstance().fileCore.separator);
			if (ConstantsCoreVO.IS_MACOS) path = path.replace(/\\/g, IDEModel.getInstance().fileCore.separator);
			return path;
		}
		
		public static function convertString(path:String):String
		{
			if (Settings.os == "win")
			{
				path= path.split(" ").join("^ ");
				path= path.split("(").join("^(");
				path= path.split(")").join("^)");
				path= path.split("&").join("^&");
			}
			else
			{
				path= path.split(" ").join("\\ ");
				path= path.split("(").join("\\(");
				path= path.split(")").join("\\)");
				path= path.split("&").join("\\&");
			}
			return path;
		}
		
		public static function getUserDefinedSDK(searchByValue:String, searchByField:String):ProjectReferenceVO
		{
			for each (var i:ProjectReferenceVO in IDEModel.getInstance().userSavedSDKs)
			{
				if (i[searchByField] == searchByValue)
				{
					return i;
				}
			}
			// if not found
			return null;
		}
		
		/**
		 * Returns projectVO against fileWrapper
		 */
		public static function getProjectFromProjectFolder(projectFolder:FileWrapper):ProjectVO
		{
			for each (var p:ProjectVO in IDEModel.getInstance().projects)
			{
				if (p.folderPath == projectFolder.projectReference.path)
					return p;
			}
			
			return null;
		}
		
		/**
		 * Returns the probable SDK against a project
		 */
		public static function getCurrentSDK(pvo:AS3ProjectVO):Object 
		{
			return pvo.buildOptions.customSDK ? pvo.buildOptions.customSDK.fileBridge.getFile : (IDEModel.getInstance().defaultSDK ? IDEModel.getInstance().defaultSDK.fileBridge.getFile : null);
		}
		
		/**
		 * Stores dotted package references
		 * against a project path to the projectVO
		 */
		public static function storePackageReferenceByProjectPath(project:ProjectVO, filePath:String=null, fileWrapper:FileWrapper=null, fileLocation:FileLocation=null):void
		{
			if (fileWrapper) filePath = fileWrapper.nativePath;
			else if (fileLocation) filePath = fileLocation.fileBridge.nativePath;
			
			var separator:String = IDEModel.getInstance().fileCore.separator;
			var projectPathSplit:Array = project.folderPath.split(separator);
			filePath = filePath.replace(project.folderPath, "");
			project.folderNamesOnly.push(projectPathSplit[projectPathSplit.length-1] + filePath.split(separator).join("."));
		}
		
		/**
		 * Returns dotted package references
		 * against a project path
		 */
		public static function getPackageReferenceByProjectPath(projectPath:String, filePath:String=null, fileWrapper:FileWrapper=null, fileLocation:FileLocation=null, appendProjectNameAsPrefix:Boolean=true):String
		{
			if (fileWrapper) filePath = fileWrapper.nativePath;
			else if (fileLocation) filePath = fileLocation.fileBridge.nativePath;
			
			var separator:String = IDEModel.getInstance().fileCore.separator;
			var projectPathSplit:Array = projectPath.split(separator);
			filePath = filePath.replace(projectPath, "");
			if (appendProjectNameAsPrefix) return projectPathSplit[projectPathSplit.length-1] + filePath.split(separator).join(".");
			return filePath.split(separator).join(".");
		}
		
		/**
		 * Fine a fileWrapper object
		 * by a fileLocation object
		 */
		public static function findFileWrapperAgainstFileLocation(current:FileWrapper, target:FileLocation):FileWrapper
		{
			// Recurse-find filewrapper child
			for each (var child:FileWrapper in current.children)
			{
				if (target.fileBridge.nativePath == child.nativePath || target.fileBridge.nativePath.indexOf(child.nativePath + target.fileBridge.separator) == 0)
				{
					if (wrappersFoundThroughFindingAWrapper) wrappersFoundThroughFindingAWrapper.push(child);
					if (target.fileBridge.nativePath == child.nativePath) 
					{
						return child;
					}
					if (child.children && child.children.length > 0) return findFileWrapperAgainstFileLocation(child, target); 	
				}
			}
			return current;
		}
		
		/**
		 * Find a fileWrapper object
		 * against a project object
		 */
		public static function findFileWrapperAgainstProject(current:FileWrapper, project:ProjectVO, orInFileWrapper:FileWrapper=null):FileWrapper
		{
			var projectChildren:FileWrapper = project ? project.projectFolder : orInFileWrapper;
			
			// Probable termination
			if (!projectChildren) return current;
			
			// Recurse-find filewrapper child
			wrappersFoundThroughFindingAWrapper = new Vector.<FileWrapper>();
			for each (var ownerWrapper:FileWrapper in projectChildren.children)
			{
				if (current.file.fileBridge.nativePath == ownerWrapper.nativePath || current.file.fileBridge.nativePath.indexOf(ownerWrapper.nativePath + current.file.fileBridge.separator) == 0)
				{
					wrappersFoundThroughFindingAWrapper.push(ownerWrapper);
					if (current.file.fileBridge.nativePath == ownerWrapper.nativePath) 
					{
						return ownerWrapper;
					}
					if (ownerWrapper.children && ownerWrapper.children.length > 0) 
					{
						var tmpMultiReturn:FileWrapper = findFileWrapperAgainstFileLocation(ownerWrapper, current.file);
						if (tmpMultiReturn != ownerWrapper) return tmpMultiReturn;
					}
				}
			}
			return current;
		}
		
		/**
		 * Another way of finding fileWrapper
		 * inside the project hierarchy
		 */
		public static function findFileWrapperInDepth(wrapper:FileWrapper, searchPath:String, project:ProjectVO=null):FileWrapper
		{
			var projectChildren:FileWrapper = project ? project.projectFolder : wrapper;
			for each (var child:FileWrapper in projectChildren.children)
			{
				if (searchPath == child.nativePath || searchPath.indexOf(child.nativePath + child.file.fileBridge.separator) == 0)
				{
					wrappersFoundThroughFindingAWrapper.push(child);
					if (searchPath == child.nativePath) 
					{
						return child;
					}
					if (child.children && child.children.length > 0) return findFileWrapperInDepth(child, searchPath);
				}
			}
			
			return wrapper;
		}
		
		/**
		 * Validate a given path compared with a project's
		 * default source path
		 */
		public static function validatePathAgainstSourceFolder(project:ProjectVO, wrapperToCompare:FileWrapper=null, locationToCompare:FileLocation=null, pathToCompare:String=null):Boolean
		{
			if (wrapperToCompare) pathToCompare = wrapperToCompare.nativePath;
			else if (locationToCompare) pathToCompare = locationToCompare.fileBridge.nativePath;
			
			if (pathToCompare.indexOf((project as AS3ProjectVO).sourceFolder.fileBridge.nativePath) == -1)
			{
				return false;
			}
			
			return true;
		}
		
		/**
		 * check for unsaved file before Build
		 */ 
		public static function checkForUnsavedEdior(activeProject:ProjectVO,saveFunction:Function):void
		{
			var unsavedEditorVal:Boolean;
			var unsavedEditor:ArrayCollection = new ArrayCollection();
			var pop:UnsaveFileMessagePopup;
			var sett:SaveFilesPlugin = new SaveFilesPlugin();
			for each (var tab:IContentWindow in IDEModel.getInstance().editors)
			{
				var ed:BasicTextEditor = tab as BasicTextEditor;
				if (ed 
					&& ed.currentFile
					&& ed.currentFile.fileBridge.nativePath.indexOf(activeProject.name) != -1)
				{
					if(ed.isChanged())
					{
						if(!unsavedEditorVal)unsavedEditorVal = true;
						unsavedEditor.addItem(tab);
						//save file before Build n run
						trace("changed"+ed.currentFile.fileBridge.name);
						//ed.saveAs(ed.currentFile);
					}
				}
			}
			if(!IDEModel.getInstance().saveFilesBeforeBuild)// ask to save file before build if the flag value is false
			{
				if(unsavedEditorVal)
				{
					pop = new UnsaveFileMessagePopup();
					PopUpManager.addPopUp(pop, FlexGlobals.topLevelApplication as DisplayObject, false);
					PopUpManager.centerPopUp(pop);
					pop.addEventListener(UnsaveFileMessagePopup.SAVE_SELECTED, saveUnsavedFileHandler);
					pop.addEventListener(UnsaveFileMessagePopup.CANCELLED, CancelHandler);
					pop.addEventListener(UnsaveFileMessagePopup.CONTINUE, ContinueHandler);
				}
				else
					saveFunction(activeProject);
				//Save unsaved file
				function saveUnsavedFileHandler(evt:Event):void{
					for each (var tab:IContentWindow in unsavedEditor)
					{
						var ed:BasicTextEditor = tab as BasicTextEditor;
						ed.saveAs(ed.currentFile);
					}
					ContinueHandler(null);	
				}
				//Build without save file
				function CancelHandler(evt:Event):void{
					pop.removeEventListener(UnsaveFileMessagePopup.SAVE_SELECTED, saveUnsavedFileHandler);
					pop.removeEventListener(UnsaveFileMessagePopup.CONTINUE, ContinueHandler);
					pop.removeEventListener(UnsaveFileMessagePopup.CANCELLED, CancelHandler);
					pop = null;
					return;
				}
				function ContinueHandler(evt:Event):void{
					pop.removeEventListener(UnsaveFileMessagePopup.SAVE_SELECTED, saveUnsavedFileHandler);
					pop.removeEventListener(UnsaveFileMessagePopup.CONTINUE, ContinueHandler);
					pop.removeEventListener(UnsaveFileMessagePopup.CANCELLED, CancelHandler);
					pop = null;
					saveFunction(activeProject);
				}
			}
			else
			{
			    //save automatically before build without asking if the flag value is true
				if(unsavedEditorVal)
				{
					for each (var editorTab:IContentWindow in unsavedEditor)
					{
						var editor:BasicTextEditor = editorTab as BasicTextEditor;
						editor.saveAs(editor.currentFile);
					}
				}
				saveFunction(activeProject);
			}
		}
		
		public static function sdkSelection():void
		{
			if (!sdkPathPopup)
			{
				if(!sdkPopup)
				{
					sdkPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, SDKSelectorPopup, false) as SDKSelectorPopup;
					sdkPopup.addEventListener(ProjectEvent.FLEX_SDK_UDPATED, onFlexSDKUpdated);
					sdkPopup.addEventListener(CloseEvent.CLOSE, onSDKPopupClosed);
					PopUpManager.centerPopUp(sdkPopup);
				}
				else
				{
					PopUpManager.bringToFront(sdkPopup);
				}
			}
			else
			{
				PopUpManager.bringToFront(sdkPathPopup);
			}
			
			function onFlexSDKUpdated(event:ProjectEvent):void
			{
				onSDKPopupClosed(null);
			}
			function onSDKPopupClosed(event:CloseEvent):void
			{
				sdkPopup.removeEventListener(CloseEvent.CLOSE, onSDKPopupClosed);
				sdkPopup.removeEventListener(ProjectEvent.FLEX_SDK_UDPATED, onFlexSDKUpdated);
				sdkPopup = null;
			}
		}
		
		/**
		 * Checks if code-completion requisite FlexJS 
		 * available or not and returns
		 */
		public static function checkCodeCompletionFlexJSSDK():String
		{
			var hasFlex:Boolean = false;
			var model:IDEModel = IDEModel.getInstance();
			var FLEXJS_NAME_PREFIX:String = "Apache Flex (FlexJS) ";
			
			var path:String;
			var bestVersionValue:int = 0;
			for each (var i:ProjectReferenceVO in model.userSavedSDKs)
			{
				var sdkName:String = i.name;
				if (sdkName.indexOf(FLEXJS_NAME_PREFIX) != -1)
				{
					var sdkVersion:String = sdkName.substr(FLEXJS_NAME_PREFIX.length, sdkName.indexOf(" ", FLEXJS_NAME_PREFIX.length) - FLEXJS_NAME_PREFIX.length);
					var versionParts:Array = sdkVersion.split("-")[0].split(".");
					var major:int = 0;
					var minor:int = 0;
					var revision:int = 0;
					if (versionParts.length >= 3)
					{
						major = parseInt(versionParts[0], 10);
						minor = parseInt(versionParts[1], 10);
						revision = parseInt(versionParts[2], 10);
					}
					//FlexJS 0.7.0 is the minimum version supported by the
					//language server. this may change in the future.
					if (major > 0 || minor >= 7)
					{
						//convert the three parts of the version number
						//into a single value to compare to other versions.
						var currentValue:int = major * 1e6 + minor * 1000 + revision;
						if(bestVersionValue < currentValue)
						{
							//pick the newest available version of FlexJS
							//to power the language server.
							hasFlex = true;
							path = i.path;
							bestVersionValue = currentValue;
							model.isCodeCompletionJavaPresent = true;
						}
					}
				}
			}
			
			return path;
		}
		
		/**
		 * Returns BOOL if version is newer than
		 * given version
		 * 
		 * Basically requires for FlexJS version check where
		 * 0.8.0 added new compiler argument which do not works
		 * in older versions
		 */
		public static function isNewerVersionSDKThan(olderVersion:int, sdkName:String):Boolean
		{
			if (!sdkName) return false;
			
			var FLEXJS_NAME_PREFIX:String = "Apache Flex (FlexJS) ";
			
			if (sdkName.indexOf(FLEXJS_NAME_PREFIX) != -1)
			{
				var sdkVersion:String = sdkName.substr(FLEXJS_NAME_PREFIX.length, sdkName.indexOf(" ", FLEXJS_NAME_PREFIX.length) - FLEXJS_NAME_PREFIX.length);
				var versionParts:Array = sdkVersion.split("-")[0].split(".");
				var major:int = 0;
				var minor:int = 0;
				var revision:int = 0;
				if (versionParts.length >= 3)
				{
					major = parseInt(versionParts[0], 10);
					minor = parseInt(versionParts[1], 10);
					revision = parseInt(versionParts[2], 10);
				}
				
				if (major > 0 || minor > olderVersion)
				{
					return true;
				}
			}
			
			return false;
		}
	}
}