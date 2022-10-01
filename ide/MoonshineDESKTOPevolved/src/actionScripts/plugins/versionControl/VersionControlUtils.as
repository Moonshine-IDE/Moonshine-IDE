////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.plugins.versionControl
{
	import flash.filesystem.File;
	import flash.net.registerClassAlias;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.utils.FileUtils;
	import actionScripts.utils.SharedObjectUtil;
	import actionScripts.valueObjects.RepositoryItemVO;
	import actionScripts.valueObjects.VersionControlTypes;

	public class VersionControlUtils
	{
		public static var IS_CHECKOUT_BROWSED_ONCE:Boolean;
		public static var LAST_CHECKOUT_BROWSED_LOCATION:String;
		
		private static var _REPOSITORIES:ArrayCollection;
		public static function get REPOSITORIES():ArrayCollection
		{
			if (!_REPOSITORIES) _REPOSITORIES = SharedObjectUtil.getRepositoriesFromSO(VersionControlUtils.getDefaultRepositories());
			return _REPOSITORIES;
		}
		
		public static function getRepositoryItemByUdid(value:String):RepositoryItemVO
		{
			for each (var item:RepositoryItemVO in REPOSITORIES)
			{
				if (item.udid == value) return item;
			}
			
			return null;
		}
		
		public static function getRepositoryItemByURL(value:String, ofType:String=null):RepositoryItemVO
		{
			for each (var item:RepositoryItemVO in REPOSITORIES)
			{
				if (item.url == value) 
				{
					if (ofType && item.type == ofType) return item;
					else if (!ofType) return item;
				}
			}
			
			return null;
		}

		public static function getRepositoryItemByLocalPath(path:String, ofType:String=null):RepositoryItemVO
		{
			for each (var item:RepositoryItemVO in REPOSITORIES)
			{
				if (item.pathToDownloaded &&
						item.pathToDownloaded == path)
				{
					if (ofType && item.type == ofType) return item;
					else if (!ofType) return item;
				}
			}

			return null;
		}
		
		public static function hasAuthenticationFailError(value:String):Boolean
		{
			var match:Array = value.toLowerCase().match(/authentication failed/);
			if (!match) match = value.toLowerCase().match(/authorization failed/);
			
			return (match != null);
		}
		
		public static function parseRepositoryDependencies(ofRepository:RepositoryItemVO, fromPath:File, duplicateOfRepository:Boolean=true):Boolean
		{
			ofRepository.pathToDownloaded = fromPath.nativePath;
			fromPath = fromPath.resolvePath("moonshine-dependencies.xml")
			if (fromPath.exists)
			{
				var dependencies:XML;
				var readObject:Object = FileUtils.readFromFile(fromPath);
				
				try
				{
					dependencies = new XML(readObject);
				}
				catch (e:Error)
				{
					GlobalEventDispatcher.getInstance().dispatchEvent(
						new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, 
							"Error #"+ e.errorID +": While reading moonshine-dependencies.xml:\n"+ e.message, 
							false, false, 
							ConsoleOutputEvent.TYPE_ERROR)
					);
					return false;
				}
				
				var tmpRepo:RepositoryItemVO;
				var gitMetaRepository:RepositoryItemVO;
				
				if (duplicateOfRepository)
				{
					// check if the same URL entry already added
					// we don't want same entry item twice in the list
					gitMetaRepository = getRepositoryItemByURL(ofRepository.url, VersionControlTypes.XML);
					if (gitMetaRepository && (gitMetaRepository.type == VersionControlTypes.XML))
					{
						gitMetaRepository.children = [];
					}
					else
					{
						// duplicate the original git-meta entry
						// to add as a separate/new-one to the manage repositories list
						registerClassAlias("actionScripts.valueObjects.RepositoryItemVO", RepositoryItemVO);
						gitMetaRepository = ObjectUtil.copy(ofRepository) as RepositoryItemVO;
						gitMetaRepository.label = String(dependencies.label);
						gitMetaRepository.notes = String(dependencies.description);
						gitMetaRepository.type = VersionControlTypes.XML;
						gitMetaRepository.children = [];
						
						VersionControlUtils.REPOSITORIES.addItem(gitMetaRepository);
					}
				}
				else
				{
					gitMetaRepository = ofRepository;
					gitMetaRepository.children = [];
				}
				
				// put this inside so we initialize only
				// if the correct xml format found
				for each (var repo:XML in dependencies..dependency)
				{
					tmpRepo = new RepositoryItemVO();
					tmpRepo.url = String(repo.url);
					tmpRepo.label = String(repo.label);
					tmpRepo.notes = String(repo.description);
					tmpRepo.type = String(repo["repo-type"]);
					tmpRepo.isRequireAuthentication = ofRepository.isRequireAuthentication;
					tmpRepo.isTrustCertificate = ofRepository.isTrustCertificate;
					tmpRepo.isDownloadable = true;
					tmpRepo.udid = UIDUtil.createUID();
					gitMetaRepository.children.push(tmpRepo);
				}
				
				// add sort
				/*if (gitMetaRepository.children.length > 0)
				{
					gitMetaRepository.children.sortOn("url", Array.CASEINSENSITIVE);
				}*/
				
				SharedObjectUtil.saveRepositoriesToSO(REPOSITORIES);
				return true;
			}
			else
			{
				setStateOfRepositoryIfNotExists(ofRepository);
			}
			
			SharedObjectUtil.saveRepositoriesToSO(REPOSITORIES);
			return false;
		}
		
		public static function updateDependentRepositories(selectedRepository:RepositoryItemVO=null):void
		{
			var tmpRepo:Object = REPOSITORIES;
			var repositories:Array = selectedRepository ? [selectedRepository] : REPOSITORIES.source;
			var nonExistingRepositories:Array = [];
			var repo:RepositoryItemVO;
			for each (repo in repositories)
			{
				if (repo.type == VersionControlTypes.XML)
				{
					if (selectedRepository && selectedRepository.pathToDownloaded)
					{
						// test the path existence
						if (!FileUtils.isPathExists(selectedRepository.pathToDownloaded)) 
						{
							nonExistingRepositories.push(repo);
						}
						else
						{
							parseRepositoryDependencies(repo, new File(selectedRepository.pathToDownloaded), false);
						}
					}
				}
			}
			
			// alert if some owner-repositories does not exists
			if (nonExistingRepositories.length > 0)
			{
				var tmpMessage:String = "Following projects not found. You can remove the entries if the project has been deleted:\n";
				for each (repo in nonExistingRepositories)
				{
					setStateOfRepositoryIfNotExists(repo);
					if (repo.pathToDownloaded)
					{
						tmpMessage += "\n1. "+ repo.pathToDownloaded;
					}
				}
				
				Alert.show(tmpMessage, "Note!");
			}
		}
		
		public static function getDefaultRepositories():ArrayList
		{
			var tmpCollection:ArrayList = new ArrayList();
			
			var tmpRepository:RepositoryItemVO = new RepositoryItemVO();
			tmpRepository.url = "https://github.com/Moonshine-IDE/Moonshine-IDE";
			tmpRepository.notes = "Moonshine-IDE Source Code";
			tmpRepository.type = VersionControlTypes.GIT;
			tmpRepository.udid = UIDUtil.createUID();
			tmpRepository.isDefault = true;
			tmpCollection.addItem(tmpRepository);

			tmpRepository = new RepositoryItemVO();
			tmpRepository.url = "https://github.com/Moonshine-IDE/Moonshine-IDE-Examples-Directory-Assistance";
			tmpRepository.notes = "Moonshine-IDE example projects";
			tmpRepository.type = VersionControlTypes.GIT;
			tmpRepository.udid = UIDUtil.createUID();
			tmpRepository.isDefault = true;
			tmpCollection.addItem(tmpRepository);
			
			tmpRepository = new RepositoryItemVO();
			tmpRepository.url = "https://github.com/apache/royale-asjs";
			tmpRepository.notes = "Apache Royale Source and Examples";
			tmpRepository.type = VersionControlTypes.GIT;
			tmpRepository.udid = UIDUtil.createUID();
			tmpRepository.isDefault = true;
			tmpCollection.addItem(tmpRepository);
			
			tmpRepository = new RepositoryItemVO();
			tmpRepository.url = "https://github.com/Moonshine-IDE/Royale-Examples";
			tmpRepository.notes = "Additional Apache Royale Examples";
			tmpRepository.type = VersionControlTypes.GIT;
			tmpRepository.udid = UIDUtil.createUID();
			tmpRepository.isDefault = true;
			tmpCollection.addItem(tmpRepository);
			
			return tmpCollection;
		}
		
		private static function setStateOfRepositoryIfNotExists(repo:RepositoryItemVO):void
		{
			if (repo.type == VersionControlTypes.GIT || repo.type == VersionControlTypes.XML)
			{
				repo.children = null;
			}
			else if (repo.type == VersionControlTypes.SVN)
			{
				repo.children = [];
			}
		}
	}
}
