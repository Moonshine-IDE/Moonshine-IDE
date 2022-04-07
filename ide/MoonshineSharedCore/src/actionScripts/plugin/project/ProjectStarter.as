package actionScripts.plugin.project
{
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.plugin.project.interfaces.IProjectStarter;
	import actionScripts.plugin.project.interfaces.IProjectStarterDelegate;
	import actionScripts.utils.MethodDescriptor;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ProjectVO;
	import feathers.data.ArrayCollection;

	import flash.system.ApplicationDomain;
	import flash.utils.clearTimeout;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;

	public class ProjectStarter implements IProjectStarterDelegate
	{
		private static var instance:ProjectStarter;
		private static var starters:Vector.<IProjectStarter> = new <IProjectStarter>[];
		private var starter_order:Array;

        private var projects:ArrayCollection = new ArrayCollection();
		private var projectUnderCursor:ProjectEvent;
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var orderIndex:int = -1;
		private var isCycleRunning:Boolean;

		public static function getInstance():ProjectStarter
		{
			if (!instance) instance = new ProjectStarter();
			return instance;
		}

		public function subscribe(starter:IProjectStarter):void
		{
			starters.push(starter);
		}

		public function startProject(event:ProjectEvent):void
		{



			this.projects.add(event);
			start();
		}

		protected function start():void
		{
			if (!isCycleRunning)
			{
				isCycleRunning = true;
				projectUnderCursor = this.projects.removeAt(0) as ProjectEvent;
				initStarterOrder();
				continueDelegation();
			}

		}

		public function continueDelegation():void
		{
			orderIndex++;
			if (orderIndex >= starter_order.length)
			{
				orderIndex = -1;
				isCycleRunning = false;
				if (projects.length > 0) start();
			}
			else
			{
				var interval:uint = setTimeout(function():void
				{
					clearTimeout(interval);
					(starter_order[orderIndex] as MethodDescriptor).callMethod();
				}, 50);

			}
		}

		private function initStarterOrder():void
		{
			starter_order = [];

			var starter:IProjectStarter;
			starters.some(function(element:*, index:int, arr:Vector.<IProjectStarter>):Boolean {
				if (getQualifiedClassName(element) == "actionScripts.plugin.project::ProjectPlugin")
				{
					starter = element as IProjectStarter;
					return true;
				}
				return false;
			})
			starter.projectStarterDelegate = this;

			starter_order.push(new MethodDescriptor(starter, "showProjectPanel"));
			starter_order.push(new MethodDescriptor(starter, "refreshProjectMenu", projectUnderCursor.project));

			starters.some(function(element:*, index:int, arr:Vector.<IProjectStarter>):Boolean {
				if (getQualifiedClassName(element) == "actionScripts.ui.menu::MenuPlugin")
				{
					starter = element as IProjectStarter;
					return true;
				}
				return false;
			})
			starter.projectStarterDelegate = this;

			starter_order.push(new MethodDescriptor(starter, "addProjectHandler"));

			starters.some(function(element:*, index:int, arr:Vector.<IProjectStarter>):Boolean {
				if (getQualifiedClassName(element) == "actionScripts.plugin.workspace::WorkspacePlugin")
				{
					starter = element as IProjectStarter;
					return true;
				}
				return false;
			})
			starter.projectStarterDelegate = this;

			starter_order.push(new MethodDescriptor(starter, "handleAddProject", projectUnderCursor.project));

			starters.some(function(element:*, index:int, arr:Vector.<IProjectStarter>):Boolean {
				if (getQualifiedClassName(element) == "actionScripts.plugin.recentlyOpened::RecentlyOpenedPlugin")
				{
					starter = element as IProjectStarter;
					return true;
				}
				return false;
			})
			starter.projectStarterDelegate = this;

			starter_order.push(new MethodDescriptor(starter, "handleAddProject", projectUnderCursor));

			starters.some(function(element:*, index:int, arr:Vector.<IProjectStarter>):Boolean {
				if (getQualifiedClassName(element) == "actionScripts.plugins.svn::SVNPlugin")
				{
					starter = element as IProjectStarter;
					return true;
				}
				return false;
			})
			starter.projectStarterDelegate = this;

			starter_order.push(new MethodDescriptor(starter, "handleProjectOpen", projectUnderCursor));

			starters.some(function(element:*, index:int, arr:Vector.<IProjectStarter>):Boolean {
				if (getQualifiedClassName(element) == "actionScripts.plugins.fswatcher::FSWatcherPlugin")
				{
					starter = element as IProjectStarter;
					return true;
				}
				return false;
			})
			starter.projectStarterDelegate = this;

			starter_order.push(new MethodDescriptor(starter, "onAddProject", projectUnderCursor));
		}
	}
}
