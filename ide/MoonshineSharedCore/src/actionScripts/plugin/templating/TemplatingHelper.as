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
package actionScripts.plugin.templating
{
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.TreeMenuItemEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.utils.TextUtil;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.FileWrapper;

	public class TemplatingHelper
	{
		// Replace values for templates {$ProjectName:"My New Project"}
		public var templatingData:Object = {};
		public var isProjectFromExistingSource:Boolean;
		
		public function fileTemplate(fromTemplate:FileLocation, toFile:FileLocation):void
		{
			if (ConstantsCoreVO.IS_AIR) 
			{
				toFile.fileBridge.createFile();
				fromTemplate.fileBridge.copyFileTemplate(toFile, templatingData);
			}
		}
		
		public function projectTemplate(fromDir:FileLocation, toDir:FileLocation, excludeFiles:Array = null):void
		{
			if (!fromDir.fileBridge.exists)
			{
				return;
			}

			copyFiles(fromDir, toDir, excludeFiles);
		}
		
		protected function copyFiles(fromDir:FileLocation, toDir:FileLocation, excludedFiles:Array = null):void
		{
			var files:Array = fromDir.fileBridge.getDirectoryListing();
			var newFile:FileLocation;
			var template:Boolean;
			
			for each (var file:Object in files)
			{
				file = new FileLocation(file.nativePath);
				if (FileLocation(file).fileBridge.isDirectory)
				{
					var directorySourceName:String = FileLocation(file).fileBridge.name;
					// do not copy stocked 'src' and 'visualeditor-src' folder if user choose to create a project with his/her existing source
					if (!isProjectFromExistingSource || (directorySourceName != "src" && directorySourceName != "visualeditor-src"))
					{
						if (ConstantsCoreVO.IS_AIR)
						{
							newFile = toDir.resolvePath(templatedFileName(file as FileLocation));
							newFile.fileBridge.createDirectory();
						}
						
						copyFiles(file as FileLocation, newFile);
					}
				}
				else
				{
					template = (FileLocation(file).fileBridge.name.indexOf(".template") > -1);
					
					if (ConstantsCoreVO.IS_AIR)
					{
						newFile = toDir.resolvePath(templatedFileName(file as FileLocation));
                    }

					if (!excludedFiles || !excludedFiles.some(function(item:String, index:int, arr:Array):Boolean{
						return item == newFile.name;
					}))
					{
						try
						{
							if(template)
							{
								file.fileBridge.copyFileTemplate(newFile, templatingData);
							} else
							{
								copyFileContents(file as FileLocation, newFile);
							}
						} catch (e:Error)
						{
						}
					}
				}
			}
		}
		
		private function templatedFileName(src:FileLocation):String
		{
			var name:String = src.fileBridge.name;
			if (name.indexOf("$") > -1)
			{
				var m:int;
				for (var key:String in templatingData)
				{
					m = name.indexOf(key);	
					if (m > -1)
					{
						name = name.substr(0, m) + templatingData[key] + name.substr(m+key.length); 
					}
				}
			}
			
			if (name.indexOf(".template") > -1)
			{
				name = name.substr(0, name.indexOf(".template"));
			}
			
			return name;
		}
		
		private function copyFileContents(src:FileLocation, dst:FileLocation):void
		{
			if (!src.fileBridge.exists) return;
			src.fileBridge.copyTo(dst);
		}
		
		public static function replace(content:String, data:Object):String
		{
			for (var key:String in data)
			{
				var re:RegExp = new RegExp(TextUtil.escapeRegex(key), "g");
				content = content.replace(re, data[key]);
			}
			
			return content;
		}
		
		public static function getTemplateLabel(template:FileLocation):String
		{
			var name:String = template.fileBridge.name;
			
			name = stripTemplate(name);
			
			if (name.indexOf(".") > -1)
			{
				name = name.substr(0, name.indexOf("."));
			}
			
			return name;
		}
		
		public static function getCustomFileFor(template:FileLocation):FileLocation
		{
			var appDirPath:String = template.fileBridge.resolveApplicationDirectoryPath(null).fileBridge.nativePath;
			var appStorageDirPath:String = template.fileBridge.resolveApplicationStorageDirectoryPath(null).fileBridge.nativePath;
			
			var customTemplatePath:String = template.fileBridge.nativePath.substr(appDirPath.length+1);
			var customTemplate:FileLocation = template.fileBridge.resolveApplicationStorageDirectoryPath(customTemplatePath);
			
			return customTemplate;
		}
		
		public static function getOriginalFileForCustom(template:FileLocation):FileLocation
		{
			var appDirPath:String = template.fileBridge.resolveApplicationDirectoryPath(null).fileBridge.nativePath;
			var appStorageDirPath:String = template.fileBridge.resolveApplicationStorageDirectoryPath(null).fileBridge.nativePath;
			
			var originalTemplatePath:String = template.fileBridge.nativePath.substr(appStorageDirPath.length+1);
			var originalTemplate:FileLocation = template.fileBridge.resolveApplicationDirectoryPath(originalTemplatePath);
			
			return originalTemplate;
		}
		
		public static function getTemplateMenuType(file:String):Array
		{
			switch (file)
			{
				case "MXML File":
					return [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.TEMPLATE];
				case "AS3 Class":
				case "AS3 Interface":
					return [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.TEMPLATE];
				case "CSS File":
					return [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, 
						ProjectMenuTypes.TEMPLATE];
				case "XML File":
					return [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, 
						ProjectMenuTypes.TEMPLATE, ProjectMenuTypes.GRAILS, ProjectMenuTypes.HAXE];
				case "File":
					return [ProjectMenuTypes.JAVA, ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, 
						ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.VISUAL_EDITOR_FLEX, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, 
						ProjectMenuTypes.TEMPLATE, ProjectMenuTypes.GRAILS, ProjectMenuTypes.HAXE];
				case "Visual Editor Flex File":
					return [ProjectMenuTypes.VISUAL_EDITOR_FLEX];
				case "Visual Editor PrimeFaces File":
					return [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES];
				case "Java Class":
					return [ProjectMenuTypes.GRAILS, ProjectMenuTypes.JAVA, ProjectMenuTypes.TEMPLATE];
				case "Groovy Class":
					return [ProjectMenuTypes.GRAILS, ProjectMenuTypes.TEMPLATE];
				case "Haxe Class":
				case "Haxe Interface":
					return [ProjectMenuTypes.HAXE, ProjectMenuTypes.TEMPLATE];
			}
			
			return [];
		}
		
		public static function stripTemplate(from:String):String
		{
			if (from.indexOf(".template") > -1)
			{
				from = from.substr(0, from.indexOf(".template"));
			}
			
			return from;
		}
		
		public static function getExtension(template:FileLocation):String
		{
			var name:String = stripTemplate(template.fileBridge.name);
			
			if (name.lastIndexOf(".") > -1)
			{
				return name.substr( name.lastIndexOf(".")+1 );	
			}
			
			return null;
		}
		
		public static function setFileAsDefaultApplication(fw:FileWrapper, parent:FileWrapper):void
		{
			if (!fw.file.fileBridge.checkFileExistenceAndReport()) return;
			
			var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
			var project:AS3ProjectVO = UtilsCore.getProjectFromProjectFolder(fw) as AS3ProjectVO;
			
			var nameOnlyPreviousSourceFileArray:Array = project.targets[0].fileBridge.name.split(".");
			nameOnlyPreviousSourceFileArray.pop();
			var nameOnlyPreviousSourceFile:String = nameOnlyPreviousSourceFileArray.join(".");

			var nameOnlyRequestedSourceFileArray:Array = fw.file.name.split(".");
			nameOnlyRequestedSourceFileArray.pop();
			var nameOnlyRequestedSourceFile:String = nameOnlyRequestedSourceFileArray.join(".");
			
			if (project.air)
			{
				var tmpAppDescData:String = project.targets[0].fileBridge.parent.resolvePath(nameOnlyPreviousSourceFile +"-app.xml").fileBridge.read() as String;
				tmpAppDescData = tmpAppDescData.replace(/<id>(.*?)<\/id>/, "<id>"+ nameOnlyRequestedSourceFile +"<\/id>");
				tmpAppDescData = tmpAppDescData.replace(/<filename>(.*?)<\/filename>/, "<filename>"+ nameOnlyRequestedSourceFile +"<\/filename>");
				tmpAppDescData = tmpAppDescData.replace(/<name>(.*?)<\/name>/, "<name>"+ nameOnlyRequestedSourceFile +"<\/name>");
				
				var newDescriptorFile:FileLocation = fw.file.fileBridge.parent.resolvePath(nameOnlyRequestedSourceFileArray.join(".") +"-app.xml");
				if (!newDescriptorFile.fileBridge.exists)
				{
					newDescriptorFile.fileBridge.save(tmpAppDescData);
					
					// refresh to project tree UI
					var tmpTreeEvent:TreeMenuItemEvent = new TreeMenuItemEvent(TreeMenuItemEvent.NEW_FILE_CREATED, newDescriptorFile.fileBridge.nativePath, parent);
					tmpTreeEvent.extra = newDescriptorFile;
					dispatcher.dispatchEvent(tmpTreeEvent);
				}
				else
				{
					dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.PROJECT_FILES_UPDATES, parent));
				}
			}
			else
			{
				var htmlFile:FileLocation = project.folderLocation.resolvePath("bin-debug");
				if (htmlFile.fileBridge.exists)
				{
					htmlFile = htmlFile.resolvePath(nameOnlyPreviousSourceFile +".html");
					if (htmlFile.fileBridge.exists)
					{
						var htmlData:String = htmlFile.fileBridge.read() as String;
						var searchExp:RegExp = new RegExp(TextUtil.escapeRegex(nameOnlyPreviousSourceFile), "g");
						htmlData = htmlData.replace(searchExp, nameOnlyRequestedSourceFile);
						
						htmlFile.fileBridge.parent.resolvePath(nameOnlyRequestedSourceFile +".html").fileBridge.save(htmlData);
						
						// refresh bin-debug folder
						var binDebugWrapper:FileWrapper = UtilsCore.findFileWrapperAgainstFileLocation(project.projectFolder, htmlFile.fileBridge.parent);
						dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.PROJECT_FILES_UPDATES, binDebugWrapper));
					}
				}
			}
			
			project.targets[0] = fw.file;
			project.swfOutput.path = project.swfOutput.path.fileBridge.parent.resolvePath(nameOnlyRequestedSourceFile +".swf");
			project.saveSettings();
		}
	}
}