package actionScripts.plugins.versionControl.utils
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.plugins.svn.SVNPlugin;
	import actionScripts.plugins.versionControl.event.VersionControlEvent;
	import actionScripts.ui.menu.vo.MenuItem;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;

	public class VersionControlMenuUtils
	{
		private static var resourceManager:IResourceManager = ResourceManager.getInstance();
		
		public static function getSourceControlMenuItems(project:ProjectVO):Vector.<MenuItem>
		{
			var baseMenu:Vector.<MenuItem> = getBaseMenuItems();
			
			if (project && (project.menuType.indexOf(ProjectMenuTypes.GIT_PROJECT) != -1))
			{
				return getGitMenuItems(baseMenu);
			}
			else if (project && (project.menuType.indexOf(ProjectMenuTypes.SVN_PROJECT) != -1))
			{
				return getSVNMenuItems(baseMenu);
			}
			
			return baseMenu;
		}
		
		private static function getBaseMenuItems():Vector.<MenuItem>
		{
			var tmpMenuItems:Vector.<MenuItem> = Vector.<MenuItem>([
				new MenuItem((ConstantsCoreVO.IS_MACOS &&
					ConstantsCoreVO.IS_APP_STORE_VERSION && 
					!VersionControlUtils.isSandboxPermissionAcquired()) ? "Grant Permission" : resourceManager.getString('resources','MANAGE_REPOSITORIES'), null, null, VersionControlEvent.OPEN_MANAGE_REPOSITORIES_GIT)
			]);
			
			return tmpMenuItems;
		}
		
		private static function getGitMenuItems(baseMenu:Vector.<MenuItem>):Vector.<MenuItem>
		{
			var isGitAvailable:Boolean = UtilsCore.isGitPresent();
			baseMenu = baseMenu.concat(Vector.<MenuItem>([
				new MenuItem(null),
				new MenuItem(resourceManager.getString('resources','COMMIT'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.COMMIT_REQUEST, null, null, null, null, null, null, null, false, isGitAvailable),
				new MenuItem(resourceManager.getString('resources','PUSH'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.PUSH_REQUEST, null, null, null, null, null, null, null, false, isGitAvailable),
				new MenuItem(resourceManager.getString('resources','PULL'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.PULL_REQUEST, null, null, null, null, null, null, null, false, isGitAvailable),
				new MenuItem(resourceManager.getString('resources','REVERT'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.REVERT_REQUEST, null, null, null, null, null, null, null, false, isGitAvailable),
				new MenuItem(null),
				new MenuItem(resourceManager.getString('resources','NEW_BRANCH'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.NEW_BRANCH_REQUEST, null, null, null, null, null, null, null, false, isGitAvailable),
				new MenuItem(resourceManager.getString('resources','SWITCH_BRANCH'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.CHANGE_BRANCH_REQUEST, null, null, null, null, null, null, null, false, isGitAvailable)
			]));
			
			return baseMenu;
		}
		
		private static function getSVNMenuItems(baseMenu:Vector.<MenuItem>):Vector.<MenuItem>
		{
			var isSVNAvailable:Boolean = UtilsCore.isSVNPresent();
			
			baseMenu = baseMenu.concat(Vector.<MenuItem>([
				new MenuItem(null),
				new MenuItem(resourceManager.getString('resources','COMMIT'), null, [ProjectMenuTypes.SVN_PROJECT], SVNPlugin.COMMIT_REQUEST, null, null, null, null, null, null, null, false, isSVNAvailable),
				new MenuItem(resourceManager.getString('resources','UPDATE'), null, [ProjectMenuTypes.SVN_PROJECT], SVNPlugin.UPDATE_REQUEST, null, null, null, null, null, null, null, false, isSVNAvailable)
			]));
			
			return baseMenu;
		}
	}
}