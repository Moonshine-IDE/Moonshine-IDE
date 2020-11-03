package actionScripts.plugins.versionControl.utils
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.plugins.svn.SVNPlugin;
	import actionScripts.plugins.versionControl.event.VersionControlEvent;
	import actionScripts.ui.menu.vo.MenuItem;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.VersionControlTypes;

	public class VersionControlMenuUtils
	{
		private static var resourceManager:IResourceManager = ResourceManager.getInstance();
		
		public static function getSourceControlMenuItems(project:ProjectVO):Vector.<MenuItem>
		{
			var baseMenu:Vector.<MenuItem> = getBaseMenuItems();
			
			if (project && project.hasVersionControlType && (project.hasVersionControlType == VersionControlTypes.GIT))
			{
				return getGitMenuItems(baseMenu);
			}
			else if (project && project.hasVersionControlType && (project.hasVersionControlType == VersionControlTypes.SVN))
			{
				return getSVNMenuItems(baseMenu);
			}
			
			return baseMenu;
		}
		
		private static function getBaseMenuItems():Vector.<MenuItem>
		{
			var tmpMenuItems:Vector.<MenuItem> = Vector.<MenuItem>([
				new MenuItem((ConstantsCoreVO.IS_MACOS && !VersionControlUtils.isSandboxPermissionAcquired()) ? "Grant Permission" : resourceManager.getString('resources','MANAGE_REPOSITORIES'), null, null, VersionControlEvent.OPEN_MANAGE_REPOSITORIES_GIT)
			]);
			
			return tmpMenuItems;
		}
		
		private static function getGitMenuItems(baseMenu:Vector.<MenuItem>):Vector.<MenuItem>
		{
			baseMenu = baseMenu.concat(Vector.<MenuItem>([
				new MenuItem(null),
				new MenuItem(resourceManager.getString('resources','COMMIT'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.COMMIT_REQUEST),
				new MenuItem(resourceManager.getString('resources','PUSH'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.PUSH_REQUEST),
				new MenuItem(resourceManager.getString('resources','PULL'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.PULL_REQUEST),
				new MenuItem(resourceManager.getString('resources','REVERT'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.REVERT_REQUEST),
				new MenuItem(null),
				new MenuItem(resourceManager.getString('resources','NEW_BRANCH'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.NEW_BRANCH_REQUEST),
				new MenuItem(resourceManager.getString('resources','SWITCH_BRANCH'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.CHANGE_BRANCH_REQUEST)
			]));
			
			return baseMenu;
		}
		
		private static function getSVNMenuItems(baseMenu:Vector.<MenuItem>):Vector.<MenuItem>
		{
			baseMenu = baseMenu.concat(Vector.<MenuItem>([
				new MenuItem(null),
				new MenuItem(resourceManager.getString('resources','COMMIT'), null, [ProjectMenuTypes.SVN_PROJECT], SVNPlugin.COMMIT_REQUEST),
				new MenuItem(resourceManager.getString('resources','UPDATE'), null, [ProjectMenuTypes.SVN_PROJECT], SVNPlugin.UPDATE_REQUEST)
			]));
			
			return baseMenu;
		}
	}
}