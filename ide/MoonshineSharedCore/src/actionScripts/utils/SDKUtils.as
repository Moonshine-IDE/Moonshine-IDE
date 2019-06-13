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
package actionScripts.utils
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;
    
    import mx.collections.ArrayCollection;
    
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.NewFileEvent;
    import actionScripts.events.ProjectEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.locator.IDEModel;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.RoyaleOutputTarget;
    import actionScripts.valueObjects.SDKReferenceVO;
	
	public class SDKUtils extends EventDispatcher
	{
		public static const BUNDLED: String = "Bundled";
		public static const EVENT_SDK_EXTRACTED: String = "EVENT_SDK_EXTRACTED";
		public static const EVENT_SDK_EXTRACTION_FAILED: String = "EVENT_SDK_EXTRACTION_FAILED";
		public static const EVENT_SDK_PROMPT_DNS: String = "EVENT_SDK_PROMPT_DNS";
		public static const EXTRACTED_FOLDER_NAME:String = "MoonshineSDKs";
		
		private static const SDKS:Array = ["FlexJS_SDK", "Flex_SDK", "Royale_SDK"];
		
		private static var currentSDKIndex:int;
		private static var isSDKExtractionFailed:Boolean;
		
		public static function checkBundledSDKPresence():void
		{
			CONFIG::OSX
				{
					var tmpLocation:FileLocation = IDEModel.getInstance().fileCore.resolveApplicationDirectoryPath("defaultSDKs/flexSDK.tar.gz");
					if (tmpLocation.fileBridge.exists) ConstantsCoreVO.IS_BUNDLED_SDK_PRESENT = true;
				}
		}
		
		public static function checkHelperDownloadedSDKPresence():void
		{
			CONFIG::OSX
				{
					var downloadsFolder:FileLocation = getUserDownloadsSDKFolder();
					if (!downloadsFolder.fileBridge.exists) return;
					
					var tmpDirListing:Array;
					var tmpFolder:FileLocation;
					var j:Object;
					
					// finding probable Flex/JS SDKs
					for (var i:String in SDKS)
					{
						tmpFolder = downloadsFolder.resolvePath(SDKS[i]);
						if (tmpFolder.fileBridge.exists) 
						{
							tmpDirListing = tmpFolder.fileBridge.getDirectoryListing();
							for each (j in tmpDirListing)
							{
								if (j.isDirectory && ((j.name.toLowerCase().indexOf("flex") != -1) || (j.name.toLowerCase().indexOf("royale") != -1)))
								{
									ConstantsCoreVO.IS_HELPER_DOWNLOADED_SDK_PRESENT = true;
									break;
								}
							}
						}
					}
					
					// finding probable Ant SDK
					tmpFolder = downloadsFolder.resolvePath("Ant");
					if (tmpFolder.fileBridge.exists) 
					{
						tmpDirListing = tmpFolder.fileBridge.getDirectoryListing();
						for each (j in tmpDirListing)
						{
							if (j.isDirectory && j.resolvePath("bin/ant").exists)
							{
								ConstantsCoreVO.IS_HELPER_DOWNLOADED_ANT_PRESENT = j;
								if (!IDEModel.getInstance().antHomePath) GlobalEventDispatcher.getInstance().dispatchEvent(new NewFileEvent(NewFileEvent.EVENT_ANT_BIN_URL_SET, j.nativePath));
								break;
							}
						}
					}
				}
		}
		
		public static function extractBundledSDKs(event:Event):void
		{
			if (isSDKExtractionFailed)
			{
				isSDKExtractionFailed = false;
				currentSDKIndex = 0;
				return;
			}
			
			var downloadsFolder:FileLocation = getUserDownloadsSDKFolder();
			if (!downloadsFolder.fileBridge.exists) downloadsFolder.fileBridge.createDirectory();
			
			if (currentSDKIndex < SDKS.length)
			{
				var model:IDEModel = IDEModel.getInstance();
				var tmpLocation:FileLocation = model.fileCore.resolveApplicationDirectoryPath("defaultSDKs/"+ SDKS[currentSDKIndex] +".tar.gz");
				if (tmpLocation.fileBridge.exists)
				{
					currentSDKIndex++;
					model.flexCore.untar(tmpLocation, downloadsFolder, extractBundledSDKs, onExtractionFailed);
				}
			}
			else
			{
				currentSDKIndex = 0;
				GlobalEventDispatcher.getInstance().dispatchEvent(new Event(EVENT_SDK_EXTRACTED));
				
				// remove com.apple.quarantine from extracted folders
				for (var i:String in SDKS)
				{
					IDEModel.getInstance().flexCore.removeExAttributesTo(downloadsFolder.fileBridge.nativePath +"/"+ SDKS[i]);
				}
			}
		}
		
		public static function initBundledSDKs():Array
		{
			CONFIG::OSX
			{
				// this method should run once on application startup
				var isFound:Boolean;
				var downloadsFolder:FileLocation = getUserDownloadsSDKFolder();
				if (!downloadsFolder.fileBridge.exists) return [];
				
				var totalBundledSDKs:Array = [];
				var model:IDEModel = IDEModel.getInstance();
				if (!model.userSavedSDKs) model.userSavedSDKs = new ArrayCollection();
				for (var i:String in SDKS)
				{
					var targetDir:FileLocation = new FileLocation(downloadsFolder.fileBridge.nativePath +"/"+ SDKS[i]);
					var bundledFlexSDK:SDKReferenceVO = getSDKReference(targetDir);
					if (bundledFlexSDK)
					{
						addSDKDirectory(bundledFlexSDK);
					}
					else if (targetDir.fileBridge.exists)
					{
						// parse through if sdk folders present
						var tmpDirListing:Array = targetDir.fileBridge.getDirectoryListing();
						for each (var j:Object in tmpDirListing)
						{
							if (j.isDirectory && ((j.name.toLowerCase().indexOf("flex") != -1) || (j.name.toLowerCase().indexOf("royale") != -1)))
							{
								bundledFlexSDK = getSDKReference(new FileLocation(j.nativePath));
								if (bundledFlexSDK)
								{
									addSDKDirectory(bundledFlexSDK);
									totalBundledSDKs.push(bundledFlexSDK);
								}
							}
						}
					}
				}
				
				// set one as default sdk if requires
				var timeoutValue:uint = setTimeout(function():void
				{
					if (isFound && model.defaultSDK == null)
					{
						setDefaultSDKByBundledSDK();
						GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.FLEX_SDK_UDPATED_OUTSIDE, model.userSavedSDKs[0]));
					}

					clearTimeout(timeoutValue);
				}, 500);
				
				// send to owner
				return totalBundledSDKs;
				
				/**
				 * @local
				 */
				function addSDKDirectory(value:SDKReferenceVO):void
				{
					var tmpPR:SDKReferenceVO = new SDKReferenceVO();
					tmpPR.name = String(value.name);
					tmpPR.path = value.path;
					tmpPR.status = BUNDLED;
					model.userSavedSDKs.addItemAt(tmpPR, 0);
					isFound = true;
				}
			}
			
			// for non-OSX
			return [];
		}

		public static function setDefaultSDKByBundledSDK():void
		{
			var model:IDEModel = IDEModel.getInstance();
			model.defaultSDK = new FileLocation(model.userSavedSDKs[0].path);
		}
		
		public static function getSDKReference(location:FileLocation):SDKReferenceVO
		{
			if (!location) return null;

			// lets load flex-sdk-description.xml to get it's label
			var description:FileLocation = location.fileBridge.resolvePath("royale-sdk-description.xml");
			if (!description.fileBridge.exists)
			{
				description = location.fileBridge.resolvePath("royale-asjs/royale-sdk-description.xml");
			}
			if (!description.fileBridge.exists)
			{
				description = location.fileBridge.resolvePath("flex-sdk-description.xml");
			}
			if (!description.fileBridge.exists)
			{
				description = location.fileBridge.resolvePath("air-sdk-description.xml");
			}

			if (description.fileBridge.exists)
			{
				// read the xml value to get SDK name
				var tmpXML:XML = XML(description.fileBridge.read());
				var outputTargetsXml:XMLList = tmpXML["output-targets"]["output-target"];
				var outputTargets:Array = [];
				var isPureActionScriptSdk:Boolean;

				for each (var item:XML in outputTargetsXml)
				{
					outputTargets.push(new RoyaleOutputTarget(item.@name, item.@version, item.@AIR, item.@Flash));
				}

				var displayName:String;
				if (description.fileBridge.name.indexOf("air-sdk-description") > -1)
				{
					displayName = "Adobe "+ tmpXML["name"] +" (SDK & Compiler)";
					isPureActionScriptSdk = true;
				}
				else if (description.fileBridge.name.indexOf("royale") > -1)
				{
					displayName = "Apache Royale";
					if (outputTargets.length == 1)
					{
						displayName = displayName.concat(" ", tmpXML.version," (", outputTargets[0].name, " only)");
					}
					else
					{
						displayName += " " + tmpXML.version;
					}
				}
				else
				{
					displayName = tmpXML["name"];
				}
				
				var tmpSDK:SDKReferenceVO = new SDKReferenceVO();
				tmpSDK.path = description.fileBridge.parent.fileBridge.nativePath;
				tmpSDK.name = displayName;
				tmpSDK.isPureActionScriptSdk = isPureActionScriptSdk;
				tmpSDK.version = String(tmpXML.version);
				tmpSDK.build = String(tmpXML.build);
				tmpSDK.outputTargets = outputTargets;
				
				return tmpSDK;
			}
			
			// non-sdk case
			return null;
		}
		
		public static function isSDKAlreadySaved(sdkObject:Object):SDKReferenceVO
		{
			// add sdk
			// don't add if said sdk already added
			var isAlreadyAdded:Boolean;
			var model:IDEModel = IDEModel.getInstance();
			for each (var i:SDKReferenceVO in model.userSavedSDKs)
			{
				if (i.path == sdkObject.path) 
				{
					return i;
				}
			}
			
			if (!(sdkObject is SDKReferenceVO) && !isAlreadyAdded)
			{
				var tmp:SDKReferenceVO = getSDKReference(new FileLocation(sdkObject.path));
				model.userSavedSDKs.addItem(tmp);
				GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.FLEX_SDK_UDPATED, tmp));
				return tmp;
			}
			else if (!isAlreadyAdded)
			{
				model.userSavedSDKs.addItem(sdkObject);
				GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.FLEX_SDK_UDPATED, sdkObject));
				return (sdkObject as SDKReferenceVO);
			}
			
			return null;
		}
		
		public static function getSDKFromSavedList(byPath:String):SDKReferenceVO
		{
			var model:IDEModel = IDEModel.getInstance();
			for each (var i:SDKReferenceVO in model.userSavedSDKs)
			{
				if (i.path == byPath) 
				{
					return i;
				}
			}
			
			return null;
		}
		
		private static function getUserDownloadsSDKFolder(onlyDownloadsFolder:Boolean=false):FileLocation
		{
			var tmpUserFolderSplit: Array = IDEModel.getInstance().fileCore.resolveUserDirectoryPath().fileBridge.nativePath.split(IDEModel.getInstance().fileCore.separator);
			if (tmpUserFolderSplit[1] == "Users")
			{
				tmpUserFolderSplit = tmpUserFolderSplit.slice(1, 3);
			}
			
			var extractionDir:FileLocation = (!onlyDownloadsFolder) ? new FileLocation("/" + tmpUserFolderSplit.join("/") + "/Downloads/"+ EXTRACTED_FOLDER_NAME) : new FileLocation("/" + tmpUserFolderSplit.join("/") + "/Downloads");
			//if (!extractionDir.fileBridge.exists) extractionDir.fileBridge.createDirectory();
			
			return extractionDir;
		}
		
        public static function getSdkSwfMajorVersion(sdkPath:String=null, providerToUpdateAsync:Object=null, fieldToUpdateAsync:String=null):int
        {
            var currentSDKVersion: int = 10;
            var sdk:FileLocation;
            if (sdkPath)
            {
                var isFound:SDKReferenceVO = UtilsCore.getUserDefinedSDK(sdkPath, "path");
                if (isFound) sdk = new FileLocation(isFound.path);
            }
            else
            {
                sdk = IDEModel.getInstance().defaultSDK;
            }

            if (sdk && sdk.fileBridge.exists)
            {
				var configFile:FileLocation = getSDKConfig(sdk);
                if (configFile.fileBridge.exists)
                {
                    // for async type of read and update to specific object's field
                    if (providerToUpdateAsync)
                    {
                        providerToUpdateAsync[fieldToUpdateAsync] = currentSDKVersion;
                        configFile.fileBridge.readAsync(providerToUpdateAsync, XML, int, fieldToUpdateAsync, "target-player");
                    }
                    // non-async direct return only
                    else
                    {
                        var tmpConfigXML: XML = XML(configFile.fileBridge.read());
                        currentSDKVersion = int(tmpConfigXML["target-player"]);
                    }
                }
            }

            return currentSDKVersion;
        }

        public static function getSdkSwfMinorVersion(sdkPath:String=null):int
        {
            var currentSdkMinorVersion: int = 0;
            var sdk:FileLocation;
            if (sdkPath)
            {
                var isFound:SDKReferenceVO = UtilsCore.getUserDefinedSDK(sdkPath, "path");
                if (isFound) sdk = new FileLocation(isFound.path);
            }
            else
            {
                sdk = IDEModel.getInstance().defaultSDK;
            }

            if (sdk && sdk.fileBridge.exists)
            {
                var configFile:FileLocation = getSDKConfig(sdk);
                if (configFile.fileBridge.exists)
                {
					var tmpConfigXML: XML = XML(configFile.fileBridge.read());
					var targetPlayerVersion:String = tmpConfigXML["target-player"].toString();
					var versionParts:Array = targetPlayerVersion.split(".");
					if (versionParts.length > 1)
					{
                        currentSdkMinorVersion = int(versionParts[1]);
					}
                }
            }

            return currentSdkMinorVersion;
        }
		
		public static function checkSDKTypeInSDKList(type:String):SDKReferenceVO
		{
			var model:IDEModel = IDEModel.getInstance();
			for each (var sdk:SDKReferenceVO in model.userSavedSDKs)
			{
				if (sdk.type == type) return sdk;
			}
			
			return null;
		}
		
		private static function onExtractionFailed(event:Event):void
		{
			isSDKExtractionFailed = true;
			GlobalEventDispatcher.getInstance().dispatchEvent(new Event(EVENT_SDK_EXTRACTION_FAILED));
		}

		private static function getSDKConfig(sdkLocation:FileLocation):FileLocation
		{
            var configFile: FileLocation = sdkLocation.resolvePath("frameworks/royale-config.xml");
            if (!configFile.fileBridge.exists)
            {
                configFile = sdkLocation.resolvePath("frameworks/flex-config.xml");
            }

			return configFile;
		}
	}
}