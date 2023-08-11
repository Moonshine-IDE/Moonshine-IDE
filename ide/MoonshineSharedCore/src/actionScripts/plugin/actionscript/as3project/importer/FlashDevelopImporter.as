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
package actionScripts.plugin.actionscript.as3project.importer
{
	import actionScripts.plugin.java.javaproject.vo.JavaTypes;
	import actionScripts.plugin.project.ProjectTemplateType;
	import actionScripts.utils.SerializeUtil;

    import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.AS3ProjectPlugin;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.actionscript.as3project.vo.MXMLCConfigVO;
	import actionScripts.plugin.actionscript.as3project.vo.SWFOutputVO;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.MobileDeviceVO;
	import actionScripts.plugin.actionscript.as3project.vo.BuildOptions;

	import surface.SurfaceMockup;

	import utils.EditingSurfaceReader;
	import utils.MainApplicationCodeUtils;
	
	import actionScripts.utils.DominoUtils;
	import mx.utils.Base64Encoder;
	import utils.StringHelper;

	import global.domino.DominoGlobals;
	import actionScripts.utils.XMLUtils;

	import mx.controls.Alert;
	import utils.StringHelperUtils;
	import view.domino.formEditor.object.FormObject;

	public class FlashDevelopImporter extends FlashDevelopImporterBase
	{
		public static function test(file:FileLocation):FileLocation
		{
			if (!file.fileBridge.exists) return null;
			
			var listing:Array = file.fileBridge.getDirectoryListing();
			for each (var i:File in listing)
			{
				if (i.extension == "as3proj" || i.extension == "veditorproj") {
					return (new FileLocation(i.nativePath));
				}
			}
			
			return null;
		}
		
		public static function parse(file:FileLocation, projectName:String=null, descriptorFile:File=null, shallUpdateChildren:Boolean=true, projectTemplateType:String = null):AS3ProjectVO
		{
			var folder:File = (file.fileBridge.getFile as File).parent;
			
			var project:AS3ProjectVO = new AS3ProjectVO(new FileLocation(folder.nativePath), projectName, shallUpdateChildren);
			project.isVisualEditorProject = file.fileBridge.name.indexOf("veditorproj") > -1;
			project.isFlexJSRoyalProject= file.fileBridge.name.indexOf("royaleveditorproj") > -1;
			//royaleveditorpro
			project.projectFile = file;
			
			project.projectName = file.fileBridge.name.substring(0, file.fileBridge.name.lastIndexOf("."));
			project.config = new MXMLCConfigVO(new FileLocation(folder.resolvePath("obj/"+project.projectName+"Config.xml").nativePath));
			project.projectFolder.name = project.projectName;
			
			var stream:FileStream = new FileStream();
			
			stream.open(file.fileBridge.getFile as File, FileMode.READ);
			var data:XML = XML(stream.readUTFBytes(file.fileBridge.getFile.size));
			stream.close();
			
			// Parse XML file
            project.classpaths.length = 0;
            project.resourcePaths.length = 0;
            project.targets.length = 0;

            parsePaths(data.includeLibraries.element, project.includeLibraries, project, "path");
            parsePaths(data.libraryPaths.element, project.libraries, project, "path");
            parsePaths(data.externalLibraryPaths.element, project.externalLibraries, project, "path");
            parsePaths(data.rslPaths.element, project.runtimeSharedLibraries, project, "path");

            project.assetLibrary = data.library;
            parsePathString(data.intrinsics.element, project.intrinsicLibraries, project, "path");
            parsePaths(data.compileTargets.compile, project.targets, project, "path");
            parsePaths(data.hiddenPaths.hidden, project.hiddenPaths, project, "path");
			
			parsePaths(data.classpaths["class"], project.classpaths, project, "path");
			parsePaths(data.moonshineResourcePaths["class"], project.resourcePaths, project, "path");
			parsePaths(data.moonshineNativeExtensionPaths["class"], project.nativeExtensions, project, "path");
			
			project.flashModuleOptions.parse(data.modules);
			
			if (!project.buildOptions.additional) project.buildOptions.additional = "";
			
			if (project.hiddenPaths.length > 0 && project.projectFolder)
			{
				project.projectFolder.updateChildren();
			}

            project.prebuildCommands = SerializeUtil.deserializeString(data.preBuildCommand);
            project.postbuildCommands = SerializeUtil.deserializeString(data.postBuildCommand);
            project.postbuildAlways = SerializeUtil.deserializeBoolean(data.postBuildCommand.@alwaysRun);
			project.isTrustServerCertificateSVN = SerializeUtil.deserializeBoolean(data.trustSVNCertificate);

            project.showHiddenPaths = SerializeUtil.deserializeBoolean(data.options.option.@showHiddenPaths);
            project.isDominoVisualEditorProject = (projectTemplateType == ProjectTemplateType.VISUAL_EDITOR_DOMINO) ||
					SerializeUtil.deserializeBoolean(data.options.option.@isDominoVisualEditor);
			if (project.isDominoVisualEditorProject)
			{
				project.jdkType = JavaTypes.JAVA_8;
			}

			if (data.domino.option.hasOwnProperty('@dominoBaseAgentURL'))
			{
				project.dominoBaseAgentURL = SerializeUtil.deserializeString(data.domino.option.@dominoBaseAgentURL);
			}

			if (data.domino.option.hasOwnProperty('@localDatabase'))
			{
				project.localDatabase = UtilsCore.getAbsolutePathAgainstProject(project.folderLocation, data.domino.option.@localDatabase);
			}

			if (data.domino.option.hasOwnProperty('@targetServer'))
			{
				project.targetServer = SerializeUtil.deserializeString(data.domino.option.@targetServer);
			}

			if (data.domino.option.hasOwnProperty('@targetDatabase'))
			{
				project.targetDatabase = SerializeUtil.deserializeString(data.domino.option.@targetDatabase);
			}

			project.dominoBaseAgentURL = project.dominoBaseAgentURL.replace(/%CleanProjectName%/gi, project.name);
			project.targetDatabase = project.targetDatabase.replace(/%CleanProjectName%/gi, project.name);
			project.localDatabase = project.localDatabase.replace(/%ProjectPath%/gi, project.projectFolder.nativePath);

			project.isPrimeFacesVisualEditorProject = SerializeUtil.deserializeBoolean(data.options.option.@isPrimeFacesVisualEditor);
			project.isExportedToExistingSource = SerializeUtil.deserializeBoolean(data.options.option.@isExportedToExistingSource);
			project.visualEditorExportPath = SerializeUtil.deserializeString(data.options.option.@visualEditorExportPath);
			if (data.options.option.hasOwnProperty('@jdkType'))
				project.jdkType = SerializeUtil.deserializeString(data.options.option.@jdkType);

			if (project.targets.length > 0)
			{
				var target:FileLocation = project.targets[0];
				
				// determine source folder path
				var substrPath:String = target.fileBridge.nativePath.replace(project.folderLocation.fileBridge.nativePath + File.separator, "");
				var pathSplit:Array = substrPath.split(File.separator);
				// remove the last class file name
				pathSplit.pop();
				var finalPath:String = project.folderLocation.fileBridge.nativePath;
				// loop through array if source folder level is
				// deeper more than 1 level
				for (var j:int=0; j < pathSplit.length; j++)
				{
					finalPath += File.separator + pathSplit[j];
				}
				
				// even before deciding, go for some more checks -
				// which needs in case user used 'set as default application'
				// to a file exists in different path
				for each (var i:FileLocation in project.classpaths)
				{
					if ((finalPath + File.separator).indexOf(i.fileBridge.nativePath + File.separator) != -1) project.sourceFolder = i;
				}
				
				// if yet not decided from above approach
				if (!project.sourceFolder) project.sourceFolder = new FileLocation(finalPath);
			}
			else if (project.classpaths.length > 0)
			{
				// its possible that a project do not have any default application (project.targets[0])
				// i.e. library project where no default application maintains
				// we shall try to select the source folder based on its classpaths
				for each (var k:FileLocation in project.classpaths)
				{
					if (k.fileBridge.nativePath.indexOf(project.folderLocation.fileBridge.nativePath + File.separator) != -1) 
					{
						project.sourceFolder = k;
						break;
					}
				}
			}

			if (project.isVisualEditorProject||project.isFlexJSRoyalProject)
			{
				project.visualEditorSourceFolder = new FileLocation(
                        project.folderLocation.fileBridge.nativePath + File.separator + "visualeditor-src/main/webapp"
				);
			}

            project.defaultBuildTargets = data.options.option.@defaultBuildTargets;
            project.testMovie = data.options.option.@testMovie;

            project.buildOptions.parse(data.build);
			project.mavenBuildOptions.parse(data.mavenBuild);

            project.swfOutput.parse(data.output, project);
			if (project.swfOutput.path.fileBridge.extension && project.swfOutput.path.fileBridge.extension.toLowerCase() == "swc")
			{
				project.isLibraryProject = true;
			}

			project.jsOutputPath = SerializeUtil.deserializeString(data.jsOutput.option.@path);

			if (project.targets.length > 0 && project.targets[0].fileBridge.extension == "as" && project.intrinsicLibraries.length == 0) project.isActionScriptOnly = true;
			if (project.targets.length > 0 && project.targets[0].fileBridge.extension == "mxml") project.isActionScriptOnly = false;
			else if (project.intrinsicLibraries.length == 0) project.isActionScriptOnly = true;
			
            project.air = UtilsCore.isAIR(project);
            project.isMobile = UtilsCore.isMobile(project);
			
			if (project.swfOutput.platform == "")
			{
				if (project.isMobile) project.swfOutput.platform = SWFOutputVO.PLATFORM_MOBILE;
				else if (project.air) project.swfOutput.platform = SWFOutputVO.PLATFORM_AIR;
				else project.swfOutput.platform = SWFOutputVO.PLATFORM_DEFAULT;
			}
			
			if (project.air) project.testMovie = AS3ProjectVO.TEST_MOVIE_AIR;
			if (project.testMovie == AS3ProjectVO.TEST_MOVIE_CUSTOM || project.testMovie == AS3ProjectVO.TEST_MOVIE_OPEN_DOCUMENT)
			{
                project.testMovieCommand = data.options.option.@testMovieCommand;
			}
			
			var platform:int = int(data.moonshineRunCustomization.option.@targetPlatform);
			
	
			switch(platform)
			{
				case AS3ProjectPlugin.AS3PROJ_AS_ANDROID:
				{
					//AIR mobile
					project.buildOptions.targetPlatform = "Android";
					break;
				}
				case AS3ProjectPlugin.AS3PROJ_AS_IOS:
				{
					//AIR mobile
					project.buildOptions.targetPlatform = "iOS";
					break;
				}
				case AS3ProjectPlugin.AS3PROJ_JS_WEB:
				{
					//Royale
					project.buildOptions.targetPlatform = "JS";
					break;
				}
				case AS3ProjectPlugin.AS3PROJ_AS_WEB:
				{
					//Royale
					project.buildOptions.targetPlatform = "SWF";
					break;
				}
			}
			
			var html:String = SerializeUtil.deserializeString(data.moonshineRunCustomization.option.@urlToLaunch);
			if (html)
			{
				project.urlToLaunch = html;
			}
			
			var customHtml:String = SerializeUtil.deserializeString(data.moonshineRunCustomization.option.@customUrlToLaunch);
			if (customHtml) project.customHTMLPath = customHtml;

            project.isMobileHasSimulatedDevice = new MobileDeviceVO(SerializeUtil.deserializeString(data.moonshineRunCustomization.option.@deviceSimulator));

			project.runWebBrowser = SerializeUtil.deserializeString(data.moonshineRunCustomization.option.@webBrowser);
			
			var simulator:String = SerializeUtil.deserializeString(data.moonshineRunCustomization.option.@launchMethod);
            project.buildOptions.isMobileRunOnSimulator = (simulator != "Device") ? true : false;

			var deviceConnectType:String = SerializeUtil.deserializeString(data.moonshineRunCustomization.option.@deviceConnectType)
            project.buildOptions.isMobileConnectType = deviceConnectType ? deviceConnectType : BuildOptions.CONNECT_TYPE_USB;
			
			if (!project.air)
			{
				UtilsCore.checkIfRoyaleApplication(project);
				if (!project.isRoyale)
				{
					if (projectTemplateType == ProjectTemplateType.ROYALE_PROJECT)
					{
						project.isRoyale = true;
					}
					else
					{
						project.isRoyale = SerializeUtil.deserializeBoolean(data.options.option.@isRoyale);
					}
				}
			}

            project.buildOptions.isMobileHasSimulatedDevice = new MobileDeviceVO(SerializeUtil.deserializeString(data.moonshineRunCustomization.deviceSimulator));
            project.buildOptions.certAndroid = SerializeUtil.deserializeString(data.moonshineRunCustomization.certAndroid);
            project.buildOptions.certIos = SerializeUtil.deserializeString(data.moonshineRunCustomization.certIos);
            project.buildOptions.certIosProvisioning = SerializeUtil.deserializeString(data.moonshineRunCustomization.certIosProvisioning);
			
			UtilsCore.setProjectMenuType(project);
			
			return project;
		}

		public static function convertDomino(file:FileLocation):void
		{
			var folder:File;
			var projectName:String;
			var settingFile:File = null;
			var projectNameextensionIndex:int = file.fileBridge.name.lastIndexOf("veditorproj");
			if(projectNameextensionIndex>0)
			{
				folder = (file.fileBridge.getFile as File).parent;
				projectName=file.fileBridge.name.substring(0, projectNameextensionIndex - 1);
				settingFile=new File(file.fileBridge.nativePath);
			}
			else
			{
				//get the correct project setting file end with veditorproj.
				folder = file.fileBridge.getFile as File;
				var getFiles:Array = folder.getDirectoryListing();
				for (var i:int = 0; i < getFiles.length; i++)
				{
					var projectFileNameInt:int=getFiles[i].nativePath.lastIndexOf("veditorproj");
					if(projectFileNameInt>0)
					{
						projectName=getFiles[i].nativePath.substring(0, projectFileNameInt - 1);
						settingFile=getFiles[i];
					}
				}
			}

			var projectFolderLocation:FileLocation=new FileLocation(folder.nativePath);
			var requireFileLocation:FileLocation;

			var base64CodeReg:RegExp = new RegExp("^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{4})$","i");

			requireFileLocation = projectFolderLocation.resolvePath(".xml_conversion_required");
			//1. first check the .xml_conversion_required file
			if (requireFileLocation.fileBridge.exists)
			{
				//DominoUtils.getDominoParentContent(projectName,projectName);
				//var visualEditorView:VisualEditorViewer=new VisualEditorViewer();
				//2.start convert domino 
				//2.1 load xml from visualeditor-src and convert it to dxl
				var xmlFileLocation:FileLocation = projectFolderLocation.resolvePath("visualeditor-src"+File.separator+"main"+File.separator+"webapp");
				var subformXmlFileLocation:FileLocation = projectFolderLocation.resolvePath("visualeditor-src"+File.separator+"main"+File.separator+"webapp"+File.separator+"subforms");
				if(!subformXmlFileLocation.fileBridge.exists)
				{
					subformXmlFileLocation.fileBridge.createDirectory();
				}
				if(xmlFileLocation.fileBridge.exists || subformXmlFileLocation.fileBridge.exists)
				{
					var directory:Array = xmlFileLocation.fileBridge.getDirectoryListing();
					var subdirectory:Array = subformXmlFileLocation.fileBridge.getDirectoryListing();
					if(subdirectory){
						for each (var subxml:File in subdirectory)
						{
							directory.push(subxml);
						}
					}
					//add subfrom xml into directory ;

					for each (var xml:File in directory)
					{
						if (xml.extension == "xml" )
						{
							var xmlNameextensionIndex:int = xml.name.lastIndexOf("xml");
							var xmlName:String=xml.name.substring(0, xmlNameextensionIndex - 1);
							var xmlNavePath:String = xml.nativePath;
							var subfromPath:String = "subforms"+File.separator+xml.name;

							var dominoXml:XML;
							
							var _fileStreamMoonshine:FileStream = new FileStream();
							_fileStreamMoonshine.open(xml, FileMode.READ);
							var data:String = _fileStreamMoonshine.readUTFBytes(_fileStreamMoonshine.bytesAvailable);
							var internalxml:XML = new XML(data);

							var windowsTitleName:String= internalxml.MainApplication.@windowsTitle;
							var formObject:FormObject = new FormObject();
							
							if(internalxml.MainApplication.@propagatenoreplace=="true"){
								formObject.propagatenoreplace= true;
							}
							if(internalxml.MainApplication.@noreplace=="true"){
								formObject.noreplace= true;
							}
							
							formObject.hide= internalxml.MainApplication.@hide;
							if(windowsTitleName!=null && windowsTitleName!="" && windowsTitleName.length>0){
								windowsTitleName=StringHelper.base64Decode(windowsTitleName);
							}else{
								windowsTitleName="@Text(\""+xmlName+"\")";
							}
							
							if(xmlNavePath.indexOf(subfromPath)>=0){
								dominoXml =	MainApplicationCodeUtils.getDominoSubformMainContainer(xmlName);
							} else {
								dominoXml = MainApplicationCodeUtils.getDominoParentContent(xmlName,windowsTitleName,formObject);
							}

							//first we insert the action bar if it exist
							var xmlFileLocation:FileLocation= new FileLocation(xml.nativePath);
							var xmlFileString:String=String(xmlFileLocation.fileBridge.read());
							var	sourceXmlCache:XML = new XML(xmlFileString);

							for each(var actionSource:XML in sourceXmlCache..actionbar) //no matter of depth Note here
							{
								var actionNode:XML=new XML("");
								
								dominoXml.appendChild(actionSource);
							}

							
							var surfaceModel:SurfaceMockup=EditingSurfaceReader.fromXMLAutoConvert(internalxml);
							if(surfaceModel!=null)
							{
								var dominoMainContainer:XML;
								if(xmlNavePath.indexOf(subfromPath)>=0)
								{
									dominoMainContainer= MainApplicationCodeUtils.getDominPageMainContainerTag(dominoXml);
								}
								else
								{
									dominoMainContainer = MainApplicationCodeUtils.getDominMainContainerTag(dominoXml);
								}

								//convert to dxl
								var dominoCode:XML=surfaceModel.toDominoCode(dominoMainContainer);
							
								
								//fix the div node from the domino code 
								for each(var div:XML in dominoCode..div) //no matter of depth Note here
								{
									if(div.parent().name() == "tablecell"){
										var divChilren:XMLList = div.children();
										for each (var divChilrenNode:XML in divChilren)
										{
											div.parent().appendChild(divChilrenNode)
										}
										delete div.parent().children()[div.childIndex()];
									}
									
								}
								//fix null pardef
								for each(var pardef:XML in dominoCode..pardef)
								{
									var hideStr:String =pardef.@hide;
									if(pardef && pardef.@id && hideStr==""){
										var id:String = pardef.@id;
										for each(var par:XML in dominoCode..par)
										{
											if(par.@def==id){
												if(par && par.@hide){
													pardef.@hide=par.@hide;
													continue;
												}
											}

										}
									
										
									}
								}

								//fix wrong size on the font
								for each(var font:XML in dominoCode..font)
								{
									if(font && font.@size)
									{
										var sizeStr:String = font.@size;
										if(sizeStr.indexOf("ptpt")>0){
											font.@size=sizeStr.replace(/ptpt/gi, "pt");
										}
									}
								}	

								if(dominoCode!=null ){
									var hasRichText:Boolean=false;	
									if(dominoCode.children().length() != 0){ 
										dominoCode=dominoCode.children()[0]
									}
									
									if(dominoCode.name()=="div" || dominoCode.name()=="_moonshineSelected_div"){
										dominoCode.setName("richtext");
										hasRichText=true;
									
									}
									if(hasRichText==false)
									{
										//add new richtext node
										var richtext:XML = new XML("<richtext style='width:700px;height:700px;' class='flexHorizontalLayout flexHorizontalLayoutLeft flexHorizontalLayoutTop' direction='Horizontal' vdirection='Vertical'/>");
										dominoMainContainer.appendChild(richtext);
										dominoMainContainer=richtext;
									}
								
									if (dominoMainContainer)
									{
										dominoMainContainer.appendChild(dominoCode); 
										if(dominoCode.name()=="richtext"){
											dominoMainContainer=dominoCode;
										}              
									}
									else
									{
										dominoXml.appendChild(dominoCode);
									}

									for each(var body:XML in dominoXml..body) //no matter of depth Note here
									{
										if(body.parent().name() == "richtext"){
											var bodyChilren:XMLList = body.children();
											for each (var bodyChilrenNode:XML in bodyChilren)
											{
												body.parent().appendChild(bodyChilrenNode)
											}
											delete body.parent().children()[body.childIndex()];
										}
										
									}

									//fix the formula base64 code to normal UTF-8 code , when it contain some speacical string
									for each(var formula:XML in dominoXml..formula) //no matter of depth Note here
									{
										if(formula.text()){
											if(formula.text().match(base64CodeReg)){
												var decodeBase64: String =  StringHelper.base64Decode(formula.text());
												var newFormulaNode:XML
												try{
													 newFormulaNode= new XML("<formula>"+decodeBase64+"</formula>");
												}catch(error:Error){
													 newFormulaNode= new XML("<formula>"+StringHelperUtils.fixXmlSpecailCharacter(decodeBase64)+"</formula>");
													
												}
												formula.parent().appendChild(newFormulaNode);
												delete formula.parent().children()[formula.childIndex()];
											}
										
											
										}
									}
									//fix hidewhen
									var richtextNodeList:XMLList=dominoXml..richtext;
									var richtextNode:Object = richtextNodeList[0];
									for each(var par:XML in dominoXml..par) //no matter of depth Note here
									{
										if(par.@hidewhen !=null && par.@hidewhen!="" && par.@def){
											
											var pardefId:String=par.@def;
											if(pardefId!=null){
												for each(var pardef:XML in dominoXml..pardef)
												{
													var id:String = pardef.@id;
													if(pardefId==id){
													
														if(pardef.code!=null){
															if(pardef.code.@event!=null && pardef.code.@event!=""){
																if(pardef.code.@event=="hidewhen"){
																	var formulaXmlList:XMLList=pardef.code.formula;
																	var formulaXml=formulaXmlList[0];
																	if(formulaXml){
																	
																		if(formulaXml.text()!=par.@hidewhen){
																			var parhidewhen:String=par.@hidewhen;
																			if(parhidewhen.match(base64CodeReg)){
																					parhidewhen =  StringHelper.base64Decode(parhidewhen);
																			}
																		
																			var newFormulaNodeFix:XML = new XML("<formula>"+parhidewhen+"</formula>");
																			formulaXml.parent().appendChild(newFormulaNodeFix);
																			delete formulaXml.parent().children()[formulaXml.childIndex()];
																		}
																	}
																}
															}
														}

														//fix the hide in here
														if(pardef.@hide){
																if(par.@hide){
																	if(pardef.@hide!=par.@hide){
																		var parHideString:String=par.@hide;
																		var parHideWhenString:String=par.@hidewhen;
																		if(parHideString!=null){
																			if(parHideWhenString!=null&& parHideWhenString.length>0){
																				//it par have the hidewhen property, so we need merge the hide option on the hidewhen 
																				if(parHideString.length>0){
																					pardef.@hide=parHideString;
																				}
																				
																			}else{
																				DominoGlobals.PardefDivId++;
																				var pardefXml:XML = new XML("<pardef id=\""+DominoGlobals.PardefDivId+"\" "+" dominotype=\"fixedhide\" />" );
																				pardefXml.@hide=par.@hide;

																				par.@def=DominoGlobals.PardefDivId;
																				//var parParentNode:XML = par.parent();
																				//delete par.parent().children()[par.childIndex()];
																				if(richtextNode!=null)
																				richtextNode.insertChildAfter(richtextNode.children()[0],pardefXml);
																			}
																			
																			//parParentNode.appendChild(par);
																			
																		}
																	}
																}
														} 
														continue;
													}
												}
											}
										}
									}

									//fix wrong size uint 

									dominoXml=MainApplicationCodeUtils.fixDominField(dominoXml);
									dominoXml=MainApplicationCodeUtils.fixPardefAlign(dominoXml);

									//fix hide 
									//remove all empty formual node 
									for each(var formula:XML in dominoXml..formula)
									{
										if(formula.parent().name()=="code")
										{
											if(formula.parent().parent().name()=="computedtext")
											{
												if(formula.parent().parent().parent().name()=="par")
												{
													if(formula.children().length()==1&& formula.children()[0]==" ")
													{
														delete formula.parent().children()[formula.childIndex()];
													}
												}
											}
										}

										if(formula.children()==null || formula.children().length()==0)
										{
											delete formula.parent().children()[formula.childIndex()];
										}
									}

									for each(var code:XML in dominoXml..code)
									{
										var codeChilren:XMLList = code.children();
										if(codeChilren.length() == 0)
										{
											delete code.parent().children()[code.childIndex()];
										}
									}

									for each(var computedtext:XML in dominoXml..computedtext)
									{
										var computedtextChilren:XMLList = computedtext.children();
										if(computedtextChilren.length() == 0)
										{
											delete computedtext.parent().children()[computedtext.childIndex()];
										}
									}
									for each(var subformref:XML in dominoXml..subformref){
										if(subformref.@name){
											var subformname:String=subformref.@name;
											if(subformname.length<2){
												
												var subformrefChilren:XMLList = subformref.children();
												if(subformrefChilren.length()== 0){
													delete subformref.parent().children()[subformref.childIndex()];
												}
											}
										}
									
										
									}
									for each(var dominoField:XML in dominoXml..field){
										var choices:String=dominoField.@choicesdialog;
										if(choices!=null && choices==""){
											dominoField.@choicesdialog="none"
										}
									}
									//computedtext
							
								}
								
								//fix the dxl format
								var extensionIndex:int = xml.name.lastIndexOf(xml.extension);
								//write the dxl to traget form file
								var xmlFileName:String=xml.name.substring(0, extensionIndex - 1);
								var targetFileLocation:FileLocation;

								if(xmlNavePath.indexOf(subfromPath)>=0)
								{
									targetFileLocation = projectFolderLocation.resolvePath("nsfs"+File.separator+"nsf-moonshine"+File.separator+"odp"+File.separator+"SharedElements"+File.separator+"Subforms"+File.separator+xmlFileName+".subform");
								}
								else
								{
									targetFileLocation = projectFolderLocation.resolvePath("nsfs"+File.separator+"nsf-moonshine"+File.separator+"odp"+File.separator+"Forms"+File.separator+xmlFileName+".form");
								}
								
								
								var targetFormFile:File=new File(targetFileLocation.fileBridge.nativePath);
								//remove old file
								if(targetFileLocation.fileBridge.exists)
								{
									targetFileLocation.fileBridge.deleteFile();
								}
								dominoXml=DominoUtils.fixNewTab(dominoXml);
								//var dominoCodeXmlStr:String=DominoUtils.fixDominButton(dominoXml);
								//fix </button<
								var dominoCodeXmlStr:String=DominoUtils.fixNotCloseButton(dominoXml.toXMLString());
								try{
									dominoCode=new XML(dominoCodeXmlStr);
								}catch(error:Error){
								
									
								}
								targetFileLocation.fileBridge.save(dominoCodeXmlStr);
								// var _targetfileStreamMoonshine:FileStream = new FileStream();
								// _targetfileStreamMoonshine.open(targetFormFile, FileMode.WRITE);
								// _targetfileStreamMoonshine.writeUTFBytes(DominoUtils.fixDominButton(dominoXml.toXMLString()));
								// _targetfileStreamMoonshine.close();

							}
							_fileStreamMoonshine.close();
						}
					}

					//2.2 we should seting the settingsFilePath into .veditorproj file
					//2.2.1 load the .veditorporj file from local Domino project.
					if(settingFile!=null && settingFile.exists){
						
						//if manven setting.xml file config exist
						// if (OnDiskMavenSettingsExporter.mavenSettingsPath && OnDiskMavenSettingsExporter.mavenSettingsPath.fileBridge.exists) { 
						// 	//load project config file to xml 
						// 	var _settingFileStreamMoonshine:FileStream = new FileStream();
						// 		_settingFileStreamMoonshine.open(settingFile, FileMode.READ);
						// 	var settingData:String = _settingFileStreamMoonshine.readUTFBytes(_settingFileStreamMoonshine.bytesAvailable);
						// 	var settingxml:XML = new XML(settingData);
						// 	if(settingxml..mavenBuild&&settingxml..mavenBuild[0]!=null){
						// 		var opetion:XML=new XML("<option/>");
						// 		opetion.@settingsFilePath=OnDiskMavenSettingsExporter.mavenSettingsPath.fileBridge.nativePath;
						// 		settingxml..mavenBuild[0].appendChild(opetion);
								
						// 		var settingFileLocation:FileLocation=new FileLocation(settingFile.nativePath);
						// 		settingFileLocation.fileBridge.save(settingxml);
						// 	}
						// }
					}
				}

				requireFileLocation.fileBridge.deleteFile();
			}

			//2. remove not need NewVisualEditorProject file
			var newFileVisualTemplate:FileLocation= projectFolderLocation.resolvePath("nsfs"+File.separator+"nsf-moonshine"+File.separator+"odp"+File.separator+"Forms"+File.separator+"NewVisualEditorProject.form");
			if(newFileVisualTemplate.fileBridge.exists)
			{
				newFileVisualTemplate.fileBridge.deleteFile();
			}

			//convertDominoAction(projectFolderLocation);
		}

		public static function convertDominoAction(projectFolderLocation:FileLocation):void
		{
			var separator:String= projectFolderLocation.fileBridge.separator;
			var actionDxlFolderPath:String=projectFolderLocation.fileBridge.nativePath+separator+"nsfs"+separator+"nsf-moonshine"+separator+"odp"+separator+"Code"+separator+"actions";
			var actionDxlFolderFileLocation:FileLocation=new FileLocation(actionDxlFolderPath);
			if(!actionDxlFolderFileLocation.fileBridge.exists){
				actionDxlFolderFileLocation.fileBridge.createDirectory();
			} 
			var actionDxlPath:String = actionDxlFolderFileLocation.fileBridge.nativePath+separator+"Shared Actions";
			var actionDxl:FileLocation=new FileLocation(actionDxlPath); 
			if(!actionDxl.fileBridge.exists){
					//actionDxl.fileBridge.save(DominoUtils.getDominActionDxlTemplate());
			}
			var actionString:String=String(actionDxl.fileBridge.read());
			var	actionDxlCache:XML = new XML(actionString);

			//

			var sourecActionsFileLocation:FileLocation = projectFolderLocation.resolvePath("nsfs"+separator+"nsf-moonshine"+separator+"odp"+separator+"SharedElements"+separator+"Actions");

			if(sourecActionsFileLocation.fileBridge.exists){
				var actionDirectory:Array = sourecActionsFileLocation.fileBridge.getDirectoryListing();
				if(actionDirectory){
					
					for each (var actionxml:File in actionDirectory)
					{
						var actionXmlNavePath:String = actionxml.nativePath;
						var actionFileLocation:FileLocation=new FileLocation(actionXmlNavePath);
						var actionSigleFileString:String=String(actionFileLocation.fileBridge.read());
						var actionSigleXML:XML=new XML(actionSigleFileString);
						actionDxlCache.sharedactions.appendChild(actionSigleXML);
					}

					actionDxl.fileBridge.save(actionDxlCache.toXMLString());
				}
			}		

		}
	}
}