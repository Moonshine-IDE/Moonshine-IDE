package actionScripts.plugin.project
{
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.project.interfaces.IProjectStarterDelegate;
	import actionScripts.plugin.project.vo.ProjectStarterSubscribing;
	import actionScripts.ui.LayoutModifier;
	import actionScripts.utils.MethodDescriptor;
	import actionScripts.valueObjects.ProjectVO;

	import components.views.project.TreeView;

	import feathers.data.ArrayCollection;

	import flash.utils.clearTimeout;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	public class ProjectStarterDelegates implements IProjectStarterDelegate
	{
		private static var instance:ProjectStarterDelegates;
		private static var starters:Vector.<ProjectStarterSubscribing> = new <ProjectStarterSubscribing>[];
		private var starter_order:Array;

        private var projects:ArrayCollection = new ArrayCollection();
		private var projectsWaitingForSubProcessesToStart:ArrayCollection = new ArrayCollection();
		private var projectUnderCursor:ProjectEvent;
		private var projectAtZeroIndex:ProjectVO;
		private var model:IDEModel = IDEModel.getInstance();
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var orderIndex:int = -1;
		private var isCycleRunning:Boolean;
		private var totalQueueCount:int;
		private var workingQueueCount:int;
		private var startTime:int;

		public static function getInstance():ProjectStarterDelegates
		{
			if (!instance) instance = new ProjectStarterDelegates();
			return instance;
		}

		public function subscribe(starter:ProjectStarterSubscribing):void
		{
			starters.push(starter);
		}

		public function startProject(event:ProjectEvent):void
		{
			this.projects.add(event);
			totalQueueCount ++;
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED,
					projectUnderCursor ? projectUnderCursor.project.name : "",
					"Opening ("+ workingQueueCount +"/"+ totalQueueCount +"): ", false));
			start();
		}

		protected function start():void
		{
			if (!isCycleRunning)
			{
				showProjectPanel();
				isCycleRunning = true;
				workingQueueCount ++;
				projectUnderCursor = this.projects.removeAt(0) as ProjectEvent;
				projectsWaitingForSubProcessesToStart.add(projectUnderCursor);
				dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED,
						projectUnderCursor.project.name,
						"Opening ("+ workingQueueCount +"/"+ totalQueueCount +"): ", false));
				if (!projectAtZeroIndex)
				{
					projectAtZeroIndex = projectUnderCursor.project;
				}

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
				dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
				if (projects.length > 0) start();
				else
				{
					totalQueueCount = 0;
					workingQueueCount = 0;
					model.mainView.getTreeViewPanel().selectProject(
							model.mainView.getTreeViewPanel().projects.getItemAt(0) as ProjectVO
					);
					projectUnderCursor = null;
					projectAtZeroIndex = null;
				}
			}
			else
			{
				if (startTime == 0)
				{
					trace(">>>>>>>>>>>>>>>>>>>>> 0");
					startTime = getTimer();
				}
				else
				{
					trace(">>>>>>>>>>>>>>>>>>>>>>>>> " + (getTimer() - startTime));
					startTime = getTimer();
				}

				// it's impossible to ensure all granular processes
				// to have completed from IProjectStarter component
				// before executing next steps, because there is no
				// Async operation available in AS3. Haxe does, though.
				// to execute next step in safe intervals with possibility
				// to complete IProjectStarter processes, we executes
				// with a short setTimeout(50)
				var interval:uint = setTimeout(function():void
				{
					clearTimeout(interval);
					(starter_order[orderIndex] as MethodDescriptor).callMethod();
				}, 50);
			}
		}

		public function showProjectPanel():void
		{
			dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.SHOW_PROJECT_VIEW));
		}

		private function initStarterOrder():void
		{
			starter_order = [];
			var tmpProjectPlugin:ProjectStarterSubscribing;

			for each (var starter:ProjectStarterSubscribing in starters)
			{
				starter.subscriber.projectStarterDelegate = this;

				// we need to have sidebar to be displayed first
				if (getQualifiedClassName(starter.subscriber) == "actionScripts.plugin.project::ProjectPlugin")
				{
					tmpProjectPlugin = starter;
				}
				else
				{
					for each (var starterFn:String in starter.subscriberMethods)
					{
						starter_order.push(
								new MethodDescriptor(
										starter.subscriber,
										starterFn,
										projectUnderCursor
								)
						);
					}
				}
			}

			// add projectPluginSubscribing as first items in its
			// process order
			for (var i:int=0; i < tmpProjectPlugin.subscriberMethods.length; i++)
			{
				starter_order.insertAt(
						i,
						new MethodDescriptor(
								tmpProjectPlugin.subscriber,
								tmpProjectPlugin.subscriberMethods[i],
								projectUnderCursor
						)
				);
			}
		}
	}
}