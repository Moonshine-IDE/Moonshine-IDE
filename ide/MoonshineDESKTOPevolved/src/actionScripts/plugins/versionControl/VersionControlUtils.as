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
package actionScripts.plugins.versionControl
{
	import flash.filesystem.File;
	import flash.net.registerClassAlias;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;
	
	import actionScripts.utils.FileUtils;
	import actionScripts.utils.SharedObjectUtil;
	import actionScripts.valueObjects.RepositoryItemVO;
	import actionScripts.valueObjects.VersionControlTypes;

	public class VersionControlUtils
	{
		private static var _REPOSITORIES:ArrayCollection;
		public static function get REPOSITORIES():ArrayCollection
		{
			if (!_REPOSITORIES) _REPOSITORIES = SharedObjectUtil.getRepositoriesFromSO();
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
				var readObject:Object = FileUtils.readFromFile(fromPath);
				var dependencies:XML = new XML(readObject);
				var tmpRepo:RepositoryItemVO;
				var gitMetaRepository:RepositoryItemVO;
				
				if (duplicateOfRepository)
				{
					// duplicate the original git-meta entry
					// to add as a separate/new-one to the manage repositories list
					registerClassAlias("actionScripts.valueObjects.RepositoryItemVO", RepositoryItemVO);
					gitMetaRepository = ObjectUtil.copy(ofRepository) as RepositoryItemVO;
					gitMetaRepository.label = String(dependencies.label); 
					gitMetaRepository.type = VersionControlTypes.XML;
					gitMetaRepository.children = [];
					
					VersionControlUtils.REPOSITORIES.addItem(gitMetaRepository);
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
					tmpRepo.udid = UIDUtil.createUID();
					gitMetaRepository.children.push(tmpRepo);
				}
				
				SharedObjectUtil.saveRepositoriesToSO(REPOSITORIES);
				return true;
			}
			
			return false;
		}
		
		public static function updateDependentRepositories(selectedRepository:RepositoryItemVO=null):void
		{
			var repositories:Array = selectedRepository ? [selectedRepository] : REPOSITORIES.source;
			var nonExistingRepositories:Array = [];
			var ownerRepository:RepositoryItemVO;
			var repo:RepositoryItemVO;
			for each (repo in repositories)
			{
				if (repo.type == VersionControlTypes.XML)
				{
					ownerRepository = getRepositoryItemByUdid(repo.udid);
					if (ownerRepository && ownerRepository.pathToDownloaded)
					{
						// test the path existence
						if (!FileUtils.isPathExists(ownerRepository.pathToDownloaded)) 
						{
							nonExistingRepositories.push(repo);
						}
						else
						{
							parseRepositoryDependencies(repo, new File(ownerRepository.pathToDownloaded), false);
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
					if (repo.pathToDownloaded)
					{
						tmpMessage += "\n1. "+ repo.pathToDownloaded;
					}
				}
				
				Alert.show(tmpMessage, "Note!");
			}
		}
	}
}
