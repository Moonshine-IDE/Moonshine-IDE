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
	import flash.geom.Point;
	import flash.system.Capabilities;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.ToolTipEvent;
	import mx.managers.PopUpManager;
	import mx.resources.ResourceManager;
	import mx.utils.UIDUtil;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.actionscript.as3project.vo.SWFOutputVO;
	import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.menu.vo.MenuItem;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.DataHTMLType;
	import actionScripts.valueObjects.FileWrapper;
	import actionScripts.valueObjects.ProjectReferenceVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.ResourceVO;
	import actionScripts.valueObjects.SDKReferenceVO;
	import actionScripts.valueObjects.SDKTypes;
	
	import components.popup.ModifiedFileListPopup;
	import components.popup.SDKDefinePopup;
	import components.popup.SDKSelectorPopup;
	import components.renderers.CustomToolTipGBA;
	import components.views.splashscreen.SplashScreen;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeOutputVO;

	public class UtilsCore 
	{
		public static var wrappersFoundThroughFindingAWrapper:Vector.<FileWrapper>;
		
		private static var sdkPopup:SDKSelectorPopup;
		private static var sdkPathPopup:SDKDefinePopup;
		private static var model:IDEModel = IDEModel.getInstance();
		
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
			for each (var file:ProjectVO in model.projects)
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
		 * Checks content of files to determine between
		 * binary and text
		 */
		public static function isBinary(fileContent:String):Boolean
		{
			return (/[\x00-\x08\x0E-\x1F]/.test(fileContent));
		}
		
		/**
		 * Positions the toolTip
		 */
		public static function positionTip(event:ToolTipEvent):void
		{
			var tmpPoint : Point = getContentToGlobalXY( event.currentTarget as UIComponent );
			event.toolTip.y = tmpPoint.y + 20;
			//event.toolTip.x = event.toolTip.x - 20;
			event.toolTip.x = ( event.currentTarget as UIComponent ).mouseX;
		}
		
		/**
		 * Determines if a project is AIR type
		 */
		public static function isAIR(project:AS3ProjectVO):Boolean
		{
			// giving precedence to the as3proj value
			if (project.swfOutput.platform == SWFOutputVO.PLATFORM_AIR || project.swfOutput.platform == SWFOutputVO.PLATFORM_MOBILE) return true;
			
			if (project.targets.length > 0)
			{
				// considering that application descriptor file should exists in the same
				// root where application source file is exist
				var appFileName:String = project.targets[0].fileBridge.name.split(".")[0];
				if (project.targets[0].fileBridge.parent.fileBridge.resolvePath("application.xml").fileBridge.exists) return true;
				else if (project.targets[0].fileBridge.parent.fileBridge.resolvePath(appFileName +"-app.xml").fileBridge.exists) return true;
			}
			
			if (project.isLibraryProject && project.testMovie == AS3ProjectVO.TEST_MOVIE_AIR) return true;
			
			return false;
		}
		
		/**
		 * Determines if a project is mobile type
		 */
		public static function isMobile(project:AS3ProjectVO):Boolean
		{
			// giving precedence to the as3proj value
			if (project.swfOutput.platform == SWFOutputVO.PLATFORM_MOBILE) return true;
			
			if (project.isLibraryProject)
			{
				if (project.buildOptions.additional && project.buildOptions.additional.indexOf("airmobile") != -1) return true;
			}
			else if (project.sourceFolder && project.sourceFolder.fileBridge.exists)
			{
				var appFileName:String = project.targets[0].fileBridge.name.split(".")[0];
				var descriptor:FileLocation = project.sourceFolder.fileBridge.resolvePath(appFileName +"-app.xml");
				if (descriptor.fileBridge.exists)
				{
					var descriptorData:XML = XML(descriptor.fileBridge.read());
					var tmpNameSearchString:String = "";
					for each (var i:XML in descriptorData.children())
					{
						tmpNameSearchString += i.localName()+" ";
					}
					
					return (tmpNameSearchString.indexOf("android") != -1) || (tmpNameSearchString.indexOf("iPhone") != -1);
				}
			}
			
			return false;
		}
		
		/**
		 * Determines if a project is Lime type
		 */
		public static function isLime(project:HaxeProjectVO):Boolean
		{
			return project.haxeOutput.platform == HaxeOutputVO.PLATFORM_LIME;
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

		public static function fixSlashes(path:String):String
		{
			if (!path) return null;
			
			//path = path.replace(/\//g, IDEModel.getInstance().fileCore.separator);
			if (ConstantsCoreVO.IS_MACOS) path = path.replace(/\\/g, model.fileCore.separator);
			return path;
		}
		
		public static function convertString(path:String):String
		{
			if (!ConstantsCoreVO.IS_MACOS)
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
		
		public static function getUserDefinedSDK(searchByValue:String, searchByField:String):SDKReferenceVO
		{
			for each (var i:SDKReferenceVO in model.userSavedSDKs)
			{
				if (!ConstantsCoreVO.IS_MACOS) searchByValue = searchByValue.replace(/(\/)/g, "\\");
				if (i[searchByField] == searchByValue)
				{
					return i;
				}
			}
			// if not found
			return null;
		}
		
		/**
		 * Returns project based on its path
		 */
		public static function getProjectByPath(value:String):ProjectVO
		{
			for each (var project:ProjectVO in model.projects)
			{
				if (project.folderLocation.fileBridge.nativePath == value)
				{
					return project;
				}
			}
			
			return null;
		}

		/**
		 * Returns project based on its name
		 */
		public static function getProjectByName(projectName:String):ProjectVO
		{
			for each (var project:ProjectVO in model.projects)
			{
				if (project.projectName == projectName)
				{
					return project;
				}
			}

			return null;
		}

		/**
		 * Returns projectVO against fileWrapper
		 */
		public static function getProjectFromProjectFolder(projectFolder:FileWrapper):ProjectVO
		{
			if (!projectFolder) return null;
			
			for each (var p:ProjectVO in model.projects)
			{
				if (p.folderPath == projectFolder.projectReference.path)
					return p;
			}
			
			return null;
		}
		
		/**
		 * Returns the probable SDK against a project
		 */
		public static function getCurrentSDK(pvo:AS3ProjectVO):FileLocation
		{
			return pvo.buildOptions.customSDK ? pvo.buildOptions.customSDK : model.defaultSDK;
		}

		/**
		 * Returns dotted package references
		 * against a project path
		 */
		public static function getPackageReferenceByProjectPath(classPaths:Vector.<FileLocation>, filePath:String=null, fileWrapper:FileWrapper=null, fileLocation:FileLocation=null, appendProjectNameAsPrefix:Boolean=true):String
		{
			if (fileWrapper)
			{
				filePath = fileWrapper.nativePath;
			}
			else if (fileLocation)
			{
				filePath = fileLocation.fileBridge.nativePath;
			}
			
			var separator:String = model.fileCore.separator;
			var classPathCount:int = classPaths.length;
			var projectPathSplit:Array = null;
			for (var i:int = 0; i < classPathCount; i++)
			{
				var location:FileLocation = classPaths[i];
				if (filePath.indexOf(location.fileBridge.nativePath) > -1)
				{
					projectPathSplit = location.fileBridge.nativePath.split(separator);
					filePath = filePath.replace(location.fileBridge.nativePath, "");
					break;
				}
			}
			//var projectPathSplit:Array = projectPath.split(separator);
			//filePath = filePath.replace(projectPath, "");
			if (appendProjectNameAsPrefix && projectPathSplit)
			{
				return projectPathSplit[projectPathSplit.length-1] + filePath.split(separator).join(".");
			}
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
		 * Finding fileWrapper by its UDID
		 */
		public static function findFileWrapperIndexByID(wrapperToSearch:FileWrapper, searchIn:ICollectionView):int
		{
			var uidToSearch:String = UIDUtil.getUID(wrapperToSearch);
			for (var i:String in searchIn)
			{
				if (UIDUtil.getUID(searchIn[i]) == uidToSearch) return int(i);
			}
			
			return -1;
		}
		
		/**
		 * Validate a given path compared with a project's
		 * default source path and class path
		 */
		public static function validatePathAgainstSources(project:ProjectVO, wrapperToCompare:FileWrapper):Boolean
		{
			var pathToCompare:String = wrapperToCompare.nativePath + project.folderLocation.fileBridge.separator;

			// if no sourceFolder exists at all let add file anywhere
			if (!project["sourceFolder"])
			{
				return true;
			}

			if (project.hasOwnProperty("classpaths") && project["classpaths"])
			{
				var classPaths:Vector.<FileLocation> = project["classpaths"];
				var hasPath:Boolean = classPaths.some(function(item:FileLocation, index:int, vector:Vector.<FileLocation>):Boolean{
					return pathToCompare.indexOf(item.fileBridge.nativePath) != -1;
				});

				if (hasPath)
				{
					return true;
				}
			}

			if (pathToCompare.indexOf(project["sourceFolder"].fileBridge.nativePath + project.folderLocation.fileBridge.separator) == -1)
			{
				return false;
			}
			
			return true;
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
			var FLEXJS_NAME_PREFIX:String = "Apache Flex (FlexJS) ";
			
			var path:String;
			var bestVersionValue:int = 0;
			for each (var i:SDKReferenceVO in model.userSavedSDKs)
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
		public static function isNewerVersionSDKThan(olderVersion:int, sdkPath:String):Boolean
		{
			if (!sdkPath) return false;
			
			// we need some extra work to determine if FlexJS version is lower than 0.8.0
			// to ensure addition of new compiler argument '-compiler.targets' 
			// which do not works with SDK < 0.8.0
			var sdkFullName:String;
			for each (var project:SDKReferenceVO in model.userSavedSDKs)
			{
				if (sdkPath == project.path)
				{
					sdkFullName = project.name;
					break;
				}
			}
			
			if (!sdkFullName) return false;
			
            var flexJSPrefixName:String = "Apache Flex (FlexJS) ";
            var royalePrefixName:String = "Apache Royale ";

            var isValidSdk:Boolean = false;
			if (sdkFullName.indexOf(flexJSPrefixName) > -1)
			{
				isValidSdk = true;
			}
			else if (sdkFullName.indexOf(royalePrefixName) > -1)
			{
				return true;
			}

			if (isValidSdk)
            {
                var sdkNamePrefixLength:int = flexJSPrefixName.length;

				var sdkVersion:String = sdkFullName.substr(sdkNamePrefixLength,
						sdkFullName.indexOf(" ", sdkNamePrefixLength) - sdkNamePrefixLength);
				var versionParts:Array = sdkVersion.split("-")[0].split(".");
				var major:int = 0;
				var minor:int = 0;

				if (versionParts.length >= 3)
				{
					major = parseInt(versionParts[0], 10);
					minor = parseInt(versionParts[1], 10);
				}

				if (major > 0 || minor > olderVersion)
				{
					return true;
				}
            }

			return false;
		}
		
		/**
		 * Sets requisite flags based on application file's tag
		 * Required - AS3ProjectVO
		 */
		public static function checkIfRoyaleApplication(project:AS3ProjectVO):void
		{
			if (project.isRoyale) return;

            // probable termination
            if (project.targets.length == 0 || !project.targets[0].fileBridge.exists) return;

            var mainAppContent:String = project.targets[0].fileBridge.read() as String;
			var isBasicApp:Boolean = mainAppContent.indexOf("js:Application") > -1;
			var isMdlApp:Boolean = mainAppContent.indexOf("mdl:Application") > -1;
			var isJewelApp:Boolean = mainAppContent.indexOf("j:Application") > -1;
			var isMXApp:Boolean = mainAppContent.indexOf("mx:Application") > -1;
            var hasExpressNamespace:Boolean = mainAppContent.indexOf("library://ns.apache.org/royale/express") > -1;
		    var hasRoyaleNamespace:Boolean = mainAppContent.indexOf("library://ns.apache.org/royale/basic") > -1 || hasExpressNamespace;
			var hasFlexJSNamespace:Boolean = mainAppContent.indexOf("library://ns.apache.org/flexjs/basic") > -1;
			var hasJewelNamespace:Boolean = mainAppContent.indexOf("library://ns.apache.org/royale/jewel") > -1;
			var hasMXNamespace:Boolean = mainAppContent.indexOf("library://ns.apache.org/royale/mx") > -1;
			var isRoyaleModule:Boolean = mainAppContent.indexOf("s:Module") > -1 || mainAppContent.indexOf("mx:Module")
					|| mainAppContent.indexOf("js:UIModule");

			var isRoyaleNamespace:Boolean = hasRoyaleNamespace || hasJewelNamespace || hasMXNamespace || hasExpressNamespace;

            if ((isBasicApp || isMdlApp || isJewelApp || isMXApp || isRoyaleModule) &&
				(hasFlexJSNamespace || isRoyaleNamespace))
            {
                // FlexJS Application
                project.isFlexJS  = true;
				project.isRoyale = isRoyaleNamespace;
				
                // FlexJS MDL applicaiton
                project.isMDLFlexJS = isMdlApp;
            }
            else
            {
                project.isFlexJS = project.isMDLFlexJS = project.isRoyale = false;
            }
		}
		
		/**
		 * Returns possible Java exeuctable in system
		 */
		public static function getExecutableJavaLocation():FileLocation
		{
			var executableFile:FileLocation;
			var separator:String = model.fileCore.separator;

			if (ConstantsCoreVO.IS_MACOS)
			{
				if (model.javaPathForTypeAhead && model.javaPathForTypeAhead.fileBridge.exists)
				{
					executableFile = new FileLocation(model.javaPathForTypeAhead.fileBridge.nativePath.concat(separator, "bin", separator, "java"));
				}
				else
				{
					executableFile = new FileLocation(separator.concat("usr", separator, "bin", separator, "java"));
				}
            }
			else 
			{
				if (model.javaPathForTypeAhead && model.javaPathForTypeAhead.fileBridge.exists) 
				{
					executableFile = new FileLocation(model.javaPathForTypeAhead.fileBridge.nativePath.concat(separator, "bin", separator, "javaw.exe"));
					if (!executableFile.fileBridge.exists)
					{
						executableFile = new FileLocation(model.javaPathForTypeAhead.fileBridge.nativePath.concat(separator, "javaw.exe"));
                    } // in case of user setup by 'javaPath/bin'
				}
				else
				{
					var javaFolder:String = Capabilities.supports64BitProcesses ? "Program Files (x86)" : "Program Files";
					var tmpJavaLocation:FileLocation = new FileLocation("C:".concat(separator, javaFolder, separator, "Java"));
					if (tmpJavaLocation.fileBridge.exists)
					{
						var javaFiles:Array = tmpJavaLocation.fileBridge.getDirectoryListing();
						for each (var j:Object in javaFiles)
						{
							if (j.nativePath.indexOf("jre") != -1)
							{
								executableFile = new FileLocation(j.nativePath + separator + "bin" + separator + "javaw.exe");
								break;
							}
						}
					}
				}
			}
			
			// finally
			return executableFile;
		}
		
		/**
		 * Closes all the opened editors relative to a certain project path
		 */
		public static function closeAllRelativeEditors(projectOrWrapper:Object, isSkipSaveConfirmation:Boolean=false,
													   completionHandler:Function=null, isCloseWhenDone:Boolean=true):void
		{
			var projectReferencePath:String;
			var editorsCount:int = model.editors.length;
			var hasChangesEditors:ArrayCollection = new ArrayCollection();
			var editorsToClose:Array = [];
			
			// closes all opened file editor instances belongs to the deleted project
			// closing is IMPORTANT
			// if projectOrWrapper==null, it'll close all opened editors irrespective of 
			// any particular project (example usage in 'Close All' option in File menu)
			if (projectOrWrapper)
			{
				if (projectOrWrapper is ProjectVO)
				{
					projectReferencePath = (projectOrWrapper as ProjectVO).folderLocation.fileBridge.nativePath;
                }
				else if (projectOrWrapper is FileWrapper && (projectOrWrapper as FileWrapper).projectReference)
				{
					projectReferencePath = (projectOrWrapper as FileWrapper).projectReference.path;
                }
			}
			
			for (var i:int = 0; i < editorsCount; i++)
			{
				if ((model.editors[i] is BasicTextEditor) && model.editors[i].currentFile &&
					(!projectReferencePath || model.editors[i].projectPath == projectReferencePath))
				{
                    var editor:BasicTextEditor = model.editors[i];
					if (editor)
					{
						editorsToClose.push(editor);
						if (!isSkipSaveConfirmation && editor.isChanged())
						{
							hasChangesEditors.addItem({file:editor, isSelected:true});
                        }
					}
				}
				else if (model.editors[i] is SettingsView && model.editors[i].associatedData &&
						(!projectReferencePath || ProjectVO(model.editors[i].associatedData).folderLocation.fileBridge.nativePath == projectReferencePath))
				{
					editorsToClose.push(model.editors[i]);
					if (!isSkipSaveConfirmation && model.editors[i].isChanged())
					{
						hasChangesEditors.addItem({file:model.editors[i], isSelected:true});
                    }
				}
				else if (model.editors[i].hasOwnProperty("label") && ConstantsCoreVO.NON_CLOSEABLE_TABS.indexOf(model.editors[i].label) == -1)
				{
					if (!isSkipSaveConfirmation && model.editors[i].isChanged())
					{
						hasChangesEditors.addItem({file:model.editors[i], isSelected:true});
					}
					else if (projectOrWrapper == null && completionHandler == null && model.editors[i] != SplashScreen)
					{
						editorsToClose.push(model.editors[i]);
					}
				}
			}
			
			// check if the editors has any changes
			if (!isSkipSaveConfirmation && hasChangesEditors.length > 0)
			{
				var modListPopup:ModifiedFileListPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, ModifiedFileListPopup, true) as ModifiedFileListPopup;
				modListPopup.collection = hasChangesEditors;
				modListPopup.addEventListener(CloseEvent.CLOSE, onModListClosed);
				PopUpManager.centerPopUp(modListPopup);
			}
			else
			{
				onModListClosed(null);
			}
			
			/*
			 * @local
			 */
			function onModListClosed(event:CloseEvent):void
			{
				if (event) event.target.removeEventListener(CloseEvent.CLOSE, onModListClosed);
				
				// in case we just want save process to the unsaved editors
				// but not to close the editors when done 
				// default - true
				if (isCloseWhenDone)
                {
                    // close all the tabs without waiting for anything further
                    for each (var j:IContentWindow in editorsToClose)
                    {
                        GlobalEventDispatcher.getInstance().dispatchEvent(
                                new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, j as DisplayObject, true)
                        );
                    }
                }
				
				// notify the caller
				if (completionHandler != null) completionHandler();
			}
		}
		
		/**
		 * Parse all acceptable files in a given project
		 */
		public static function parseFilesList(collection:IList, project:ProjectVO=null, readableExtensions:Array=null, isSourceFolderOnly:Boolean=false):void
		{
			if (project)
			{
				if (isSourceFolderOnly && (project as AS3ProjectVO).sourceFolder) 
				{
					// lets search for the probable existing fileWrapper object
					// instead of creating a new one - that could be expensive
					var sourceWrapper:FileWrapper = findFileWrapperAgainstFileLocation(project.projectFolder, (project as AS3ProjectVO).sourceFolder);
					if (sourceWrapper) 
					{
						parseChildrens(sourceWrapper, collection, readableExtensions);
						return;
					}
				}
				
				parseChildrens(project.projectFolder, collection, readableExtensions);
			}
			else
			{
				for each (var i:ProjectVO in model.projects)
				{
					parseChildrens(i.projectFolder, collection, readableExtensions);
				}
			}
		}

		/**
		 * Returns menu options on current
		 * recent opened projects
		 */
		public static function getRecentProjectsMenu():MenuItem
		{
			var openRecentLabel:String = ResourceManager.getInstance().getString('resources','OPEN_RECENT_PROJECTS');
			var openProjectMenu:MenuItem = new MenuItem(openRecentLabel);
			openProjectMenu.parents = ["File", openRecentLabel];
			openProjectMenu.items = new Vector.<MenuItem>();
			
			for each (var i:ProjectReferenceVO in model.recentlyOpenedProjects)
			{
				if (i.name)
				{
					var menuItem:MenuItem = new MenuItem(i.name, null, null, "eventOpenRecentProject");
					menuItem.data = i; 
					openProjectMenu.items.push(menuItem);
				}
			}
			
			return openProjectMenu;
		}
		
		/**
		 * Returns menu options on current
		 * recent opened projects
		 */
		public static function getRecentFilesMenu():MenuItem
		{
			var openRecentLabel:String = ResourceManager.getInstance().getString('resources','OPEN_RECENT_FILES');
			var openFileMenu:MenuItem = new MenuItem(openRecentLabel);
			openFileMenu.parents = ["File", openRecentLabel];
			openFileMenu.items = new Vector.<MenuItem>();
			
			for each (var i:ProjectReferenceVO in model.recentlyOpenedFiles)
			{
				if (i.name)
				{
					var menuItem:MenuItem = new MenuItem(i.name, null, null, "eventOpenRecentFile");
					menuItem.data = i; 
					openFileMenu.items.push(menuItem);
				}
			}
			
			return openFileMenu;
		}
		
		/**
		 * Set project menu type based on possible field
		 */
		public static function setProjectMenuType(value:ProjectVO):void
		{
			var currentMenuType:String;
			
			// the type-check ordering are important
			if (value is AS3ProjectVO)
			{
				if ((value as AS3ProjectVO).isFlexJS || (value as AS3ProjectVO).isRoyale || (value as AS3ProjectVO).isMDLFlexJS)
				{
					currentMenuType = ProjectMenuTypes.JS_ROYALE;
				}
				else if ((value as AS3ProjectVO).isLibraryProject)
				{
					currentMenuType = ProjectMenuTypes.LIBRARY_FLEX_AS;
				}
				else if ((value as AS3ProjectVO).isPrimeFacesVisualEditorProject)
				{
					currentMenuType = ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES;
				}
				else if ((value as AS3ProjectVO).isVisualEditorProject)
				{
					currentMenuType = ProjectMenuTypes.VISUAL_EDITOR_FLEX;
				}
				else if ((value as AS3ProjectVO).isActionScriptOnly)
				{
					currentMenuType = ProjectMenuTypes.PURE_AS;
				}
				else
				{
					currentMenuType = ProjectMenuTypes.FLEX_AS;
				}
			}
			else if (value is GrailsProjectVO)
			{
				currentMenuType = ProjectMenuTypes.GRAILS;
			}
			else if (value is JavaProjectVO)
			{
				currentMenuType = ProjectMenuTypes.JAVA;
			}
			else if (value is HaxeProjectVO)
			{
				currentMenuType = ProjectMenuTypes.HAXE;
			}

			if (!value.menuType)
			{
				value.menuType = currentMenuType;
			}
			else if (value.menuType && value.menuType.indexOf(currentMenuType) == -1)
			{
				value.menuType += ","+ currentMenuType;
			}
			
			// version-control check
			if (!value.hasVersionControlType)
			{
				// git check
				GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.CHECK_GIT_PROJECT, value));
				// svn check
				GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.CHECK_SVN_PROJECT, value));
			}
		}
		
		/**
		 * Returns encoded string to run on Windows' shell
		 */
		public static function getEncodedForShell(value:String, forceOSXEncode:Boolean=false, forceWindowsEncode:Boolean=false):String
		{
			var tmpValue:String = "";
			if (ConstantsCoreVO.IS_MACOS || forceOSXEncode)
			{
				// @note
				// in case of /bash one should send the value surrounded by $''
				// i.e. $' +encodedValue+ '
				tmpValue = value.replace(/(\\)/g, '\\\\"');
				tmpValue = value.replace(/(")/g, '\\"');
				tmpValue = value.replace(/(')/g, "\\'");
			}
			else if (!ConstantsCoreVO.IS_MACOS || forceWindowsEncode)
			{
				for (var i:int; i < value.length; i++)
				{
					tmpValue += "^"+ value.charAt(i);
				}
			}
			
			return tmpValue;
		}
		
		/**
		 * Reads through project configuration and
		 * returns the project name
		 */
		public static function getProjectNameFromConfiguration(file:FileLocation=null, path:String=null):String
		{
			if (!file && !path) return null;
			if (!file && path) file = new FileLocation(path);
			
			var configurationXML:XML = new XML(file.fileBridge.read() as String);
			if (file.fileBridge.extension == "project")
			{
				// flash-builder projec
				return String(configurationXML.name);
			}
			else
			{
				// moonshine projects
				return file.fileBridge.nameWithoutExtension;
			}
			
			return null;
		}

		public static function getConsolePath():String
		{
			var separator:String = model.fileCore.separator;
            if (!ConstantsCoreVO.IS_MACOS)
            {
                // in windows
                return "c:".concat(separator, "Windows", separator, "System32", separator, "cmd.exe");
            }
            else
            {
                // in mac
                return separator.concat("bin", separator, "bash");
            }
		}
		
		public static function isMavenAvailable():Boolean
		{
			if (!model.mavenPath || model.mavenPath == "")
			{
				return false;
			}
			
			var component:Object = model.flexCore.getComponentByType(SDKTypes.MAVEN);
			if (component && component.pathValidation)
			{
				return model.fileCore.isPathExists(model.mavenPath + model.fileCore.separator + component.pathValidation);
			}
			
			return true;
		}

		public static function isGradleAvailable():Boolean
		{
			if (!model.gradlePath || model.gradlePath == "")
			{
				return false;
			}
			
			var component:Object = model.flexCore.getComponentByType(SDKTypes.GRADLE);
			if (component && component.pathValidation)
			{
				return model.fileCore.isPathExists(model.gradlePath + model.fileCore.separator + component.pathValidation);
			}
			
			return true;
		}
		
		public static function isGrailsAvailable():Boolean
		{
			if (!model.grailsPath || model.grailsPath == "")
			{
				return false;
			}
			
			var component:Object = model.flexCore.getComponentByType(SDKTypes.GRAILS);
			if (component && component.pathValidation)
			{
				return model.fileCore.isPathExists(model.grailsPath + model.fileCore.separator + component.pathValidation);
			}
			
			return true;
		}

        public static function getMavenBinPath():String
        {
			if (!model.mavenPath || model.mavenPath == "")
			{
				return null;
			}

			var separator:String = model.fileCore.separator;
            var mavenLocation:FileLocation = new FileLocation(model.mavenPath);
            var mavenBin:String = "bin" + separator;
			if (mavenLocation.fileBridge.nativePath.lastIndexOf(model.fileCore.separator +"bin") > -1)
			{
				mavenBin = "";
			}
			
			if (!mavenLocation.fileBridge.exists)
			{
				return null;
			}
			else if (!ConstantsCoreVO.IS_MACOS)
            {
                return mavenLocation.resolvePath(mavenBin + "mvn.cmd").fileBridge.nativePath;
            }
            else
            {
                return UtilsCore.convertString(mavenLocation.resolvePath(mavenBin + "mvn").fileBridge.nativePath);
            }
			
			return null;
        }
		
		public static function getGradleBinPath():String
		{
			if (!model.gradlePath || model.gradlePath == "")
			{
				return null;
			}
			
			var gradleLocation:FileLocation = new FileLocation(model.gradlePath);
			var gradleBin:String = "bin" + model.fileCore.separator;
			if (gradleLocation.fileBridge.nativePath.lastIndexOf(model.fileCore.separator +"bin") > -1)
			{
				gradleBin = "";
			}
			
			if (!gradleLocation.fileBridge.exists)
			{
				return null;
			}
			else if (!ConstantsCoreVO.IS_MACOS)
			{
				return gradleLocation.resolvePath(gradleBin + "gradle.bat").fileBridge.nativePath;
			}
			else
			{
				return UtilsCore.convertString(gradleLocation.resolvePath(gradleBin + "gradle").fileBridge.nativePath);
			}
			
			return null;
		}

        public static function getGrailsBinPath():String
        {
			if (!model.grailsPath || model.grailsPath == "")
			{
				return null;
			}

			var separator:String = model.fileCore.separator;
            var grailsLocation:FileLocation = new FileLocation(model.grailsPath);
            var grailsBin:String = "bin" + separator;
			if (grailsLocation.fileBridge.nativePath.lastIndexOf(model.fileCore.separator +"bin") > -1)
			{
				grailsBin = "";
			}
			
			if (!grailsLocation.fileBridge.exists)
			{
				return null;
			}
			else if (!ConstantsCoreVO.IS_MACOS)
            {
                return grailsLocation.resolvePath(grailsBin + "grails.bat").fileBridge.nativePath;
            }
            else
            {
                return UtilsCore.convertString(grailsLocation.resolvePath(grailsBin + "grails").fileBridge.nativePath);
            }
			
			return null;
        }

        public static function getNodeBinPath():String
        {
			if (!model.nodePath || model.nodePath == "")
			{
				return null;
			}

            var nodeLocation:FileLocation = new FileLocation(model.nodePath);			
			if (!nodeLocation.fileBridge.exists)
			{
				return null;
			}
			else if (!ConstantsCoreVO.IS_MACOS)
            {
                return nodeLocation.resolvePath("node.exe").fileBridge.nativePath;
            }
            else
            {
                return UtilsCore.convertString(nodeLocation.resolvePath("node").fileBridge.nativePath);
            }
			
			return null;
        }

        public static function getNpmBinPath():String
        {
			if (!model.nodePath || model.nodePath == "")
			{
				return null;
			}

            var nodeLocation:FileLocation = new FileLocation(model.nodePath);
			if (!nodeLocation.fileBridge.exists)
			{
				return null;
			}
			else if (!ConstantsCoreVO.IS_MACOS)
            {
                return nodeLocation.resolvePath("npm.cmd").fileBridge.nativePath;
            }
            else
            {
                return UtilsCore.convertString(nodeLocation.resolvePath("npm").fileBridge.nativePath);
            }
			
			return null;
        }

        public static function getNpxBinPath():String
        {
			if (!model.nodePath || model.nodePath == "")
			{
				return null;
			}

            var nodeLocation:FileLocation = new FileLocation(model.nodePath);			
			if (!nodeLocation.fileBridge.exists)
			{
				return null;
			}
			else if (!ConstantsCoreVO.IS_MACOS)
            {
                return nodeLocation.resolvePath("npx.cmd").fileBridge.nativePath;
            }
            else
            {
                return UtilsCore.convertString(nodeLocation.resolvePath("npx").fileBridge.nativePath);
            }
			
			return null;
        }

        public static function getHaxeBinPath():String
        {
			if (!model.haxePath || model.haxePath == "")
			{
				return null;
			}

            var haxeLocation:FileLocation = new FileLocation(model.haxePath);			
			if (!haxeLocation.fileBridge.exists)
			{
				return null;
			}
			else if (!ConstantsCoreVO.IS_MACOS)
            {
                return haxeLocation.resolvePath("haxe.exe").fileBridge.nativePath;
            }
            else
            {
                return UtilsCore.convertString(haxeLocation.resolvePath("haxe").fileBridge.nativePath);
            }
			
			return null;
        }

        public static function getHaxelibBinPath():String
        {
			if (!model.haxePath || model.haxePath == "")
			{
				return null;
			}

            var haxeLocation:FileLocation = new FileLocation(model.haxePath);			
			if (!haxeLocation.fileBridge.exists)
			{
				return null;
			}
			else if (!ConstantsCoreVO.IS_MACOS)
            {
                return haxeLocation.resolvePath("haxelib.exe").fileBridge.nativePath;
            }
            else
            {
                return UtilsCore.convertString(haxeLocation.resolvePath("haxelib").fileBridge.nativePath);
            }
			
			return null;
        }
		
		public static function isDefaultSDKAvailable():Boolean
		{
			if (!model.defaultSDK || !model.defaultSDK.fileBridge.exists)
			{
				return false;
			}
			
			return true;
		}
		
		public static function isJavaForTypeaheadAvailable():Boolean
		{
			if (!model.javaPathForTypeAhead || !model.javaPathForTypeAhead.fileBridge.exists)
			{
				return false;
			}
			
			var component:Object = model.flexCore.getComponentByType(SDKTypes.OPENJAVA);
			if (component && component.pathValidation)
			{
				return model.javaPathForTypeAhead.fileBridge.resolvePath(component.pathValidation).fileBridge.exists;
			}
			
			return true;
		}
		
		public static function isAntAvailable():Boolean
		{
			if (!model.antHomePath || !model.antHomePath.fileBridge.exists)
			{
				return false;
			}
			
			var component:Object = model.flexCore.getComponentByType(SDKTypes.ANT);
			if (component && component.pathValidation)
			{
				return model.antHomePath.fileBridge.resolvePath(component.pathValidation).fileBridge.exists;
			}
			
			return true;
		}
		
		public static function isSVNPresent():Boolean
		{
			if (!model.svnPath || !model.fileCore.isPathExists(model.svnPath))
			{
				return false;
			}
			
			var component:Object = model.flexCore.getComponentByType(SDKTypes.SVN);
			if (component && component.pathValidation)
			{
				return model.flexCore.isValidExecutableBy(SDKTypes.SVN, model.svnPath, component.pathValidation);
			}
			
			return true;
		}
		
		public static function isGitPresent():Boolean
		{
			if (!model.gitPath || !model.fileCore.isPathExists(model.gitPath))
			{
				return false;
			}
			
			var component:Object = model.flexCore.getComponentByType(SDKTypes.GIT);
			if (component && component.pathValidation)
			{
				return model.flexCore.isValidExecutableBy(SDKTypes.GIT, model.gitPath, component.pathValidation);
			}
			
			return true;
		}
		
		public static function getLineBreakEncoding():String
		{
			return (ConstantsCoreVO.IS_MACOS ? "\n" : "\r\n");
		}

        private static function parseChildrens(value:FileWrapper, collection:IList, readableExtensions:Array=null):void
        {
            if (!value) return;

            var extension:String = value.file.fileBridge.extension;
            if (!value.file.fileBridge.isDirectory && (extension != null) && isAcceptableResource(extension))
            {
                collection.addItem(new ResourceVO(value.file.fileBridge.name, value));
                return;
            }

            if ((value.children is Array) && (value.children as Array).length > 0)
            {
                for each (var c:FileWrapper in value.children)
                {
                    extension = c.file.fileBridge.extension;
                    if (!c.file.fileBridge.isDirectory && (extension != null) && isAcceptableResource(extension, readableExtensions))
                    {
                        collection.addItem(new ResourceVO(c.file.fileBridge.name, c));
                    }
                    else if (c.file.fileBridge.isDirectory)
                    {
                        parseChildrens(c, collection, readableExtensions);
                    }
                }
            }
        }

        private static function isAcceptableResource(extension:String, readableExtensions:Array=null):Boolean
        {
            readableExtensions ||= ConstantsCoreVO.READABLE_FILES;
            return readableExtensions.some(
                    function isValidExtension(item:Object, index:int, arr:Array):Boolean {
                        return item == extension;
                    });
        }
    }
}