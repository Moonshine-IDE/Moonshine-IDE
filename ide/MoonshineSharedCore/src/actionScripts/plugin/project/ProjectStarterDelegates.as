package actionScripts.plugin.project
{
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.project.interfaces.IProjectStarter;
	import actionScripts.plugin.project.interfaces.IProjectStarterDelegate;
	import actionScripts.plugin.project.vo.ProjectStarterSubscribing;
	import actionScripts.plugin.recentlyOpened.RecentlyOpenedPlugin;
	import actionScripts.plugin.workspace.WorkspacePlugin;
	import actionScripts.ui.LayoutModifier;
	import actionScripts.utils.MethodDescriptor;
	import actionScripts.utils.SharedObjectConst;
	import actionScripts.utils.SharedObjectUtil;
	import actionScripts.valueObjects.ProjectVO;
	import flash.net.SharedObject;

	import components.views.project.TreeView;

	import feathers.data.ArrayCollection;

	import flash.events.Event;

	import flash.utils.Dictionary;

	import flash.utils.clearTimeout;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	public class ProjectStarterDelegates extends ConsoleOutputter implements IProjectStarterDelegate
	{
		private static var instance:ProjectStarterDelegates;
		private static var starters:Vector.<ProjectStarterSubscribing> = new <ProjectStarterSubscribing>[];
		private var starter_order_beginning:Array;
		private var starter_order_after_addition:Array;
		private var starter_order_after_selection:Array;

        private var projects:ArrayCollection = new ArrayCollection();
		private var projectsWaitingForSubProcessesToStart:ArrayCollection = new ArrayCollection();
		private var projectUnderCursor:ProjectEvent;
		private var model:IDEModel = IDEModel.getInstance();
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var projectCookie:SharedObject;
		private var orderIndex:int = 0;
		private var isCycleRunning:Boolean;
		private var totalQueueCount:int;
		private var workingQueueCount:int;
		private var startTime:int;

		public static function getInstance():ProjectStarterDelegates
		{
			if (!instance) instance = new ProjectStarterDelegates();
			return instance;
		}

		public function ProjectStarterDelegates()
		{
			super();
			dispatcher.addEventListener(ProjectEvent.ACTIVE_PROJECT_CHANGED, onProjectSelectionChangedInSidebar, false, 0, true);
			dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, onProjectRemove, false, 0, true);
			dispatcher.addEventListener(WorkspacePlugin.EVENT_WORKSPACE_CHANGED, onWorkspaceChanged, false, 0, true);

			projectCookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
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
				isCycleRunning = true;
				showProjectPanel();
				if (!starter_order_beginning)
				{
					initStarterOrder();
				}

				start2();
			}
		}

		private var starterOrderIndex:int = 0;
		private var startersByOrder:Array;
		protected function start2():void
		{
			switch (starterOrderIndex)
			{
				case 0:
					continueDelegation();
					break;
				case 1:
					startersByOrder = starter_order_beginning;
					workingQueueCount = 0;
					continueDelegation();
					break;
				case 2:
					startersByOrder = starter_order_after_addition;
					workingQueueCount = 0;
					continueDelegation();
					break;
				default:
					totalQueueCount = 0;
					workingQueueCount = 0;
					starterOrderIndex = 0;
					projectUnderCursor = null;

					projectsWaitingForSubProcessesToStart = new ArrayCollection();
					dispatcher.dispatchEvent(new Event(RecentlyOpenedPlugin.RECENT_PROJECT_LIST_UPDATED));
					dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
					success("Project(s) addition completed.");
					startLSPagainstProjectWithOpenedEditors();
					break;
			}
		}

		protected function startLSPagainstProjectWithOpenedEditors():void
		{
			var tmpExecuteCheck:String;
			for each (var projectEvent:ProjectEvent in projects.array)
			{
				tmpExecuteCheck = "actionScripts.impls::ILanguageServerBridgeImp-"+projectEvent.project.projectFolder.nativePath;
				if ((executeDictionary[tmpExecuteCheck] == undefined) &&
						(projectCookie.data["projectFiles" + projectEvent.project.name] != undefined) &&
						((projectCookie.data["projectFiles" + projectEvent.project.name] as Array).length != 0))
				{
					dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.LANGUAGE_SERVER_OPEN_REQUEST, projectEvent.project));
					executeDictionary[tmpExecuteCheck] = true;
				}
			}

			projects = new ArrayCollection();
			isCycleRunning = false;
		}

		public function continueDelegation():void
		{
			switch (starterOrderIndex)
			{
				case 0:
					if (projects.length != 0)
					{
						workingQueueCount ++;
						projectUnderCursor = this.projects.removeAt(0) as ProjectEvent;
						projectsWaitingForSubProcessesToStart.add(projectUnderCursor);
						var interval:uint = setTimeout(function():void
						{
							clearTimeout(interval);
							dispatcher.dispatchEvent(
									new ProjectEvent(ProjectEvent.OPEN_PROJECT_LAST_OPENED_FILES, projectUnderCursor.project)
							);
						}, 100);
					}
					else
					{
						projects = projectsWaitingForSubProcessesToStart;
						projectsWaitingForSubProcessesToStart = new ArrayCollection();
						starterOrderIndex ++;
						start2();
					}
					break;
				case 1:
					if (projects.length != 0)
					{
						workingQueueCount ++;
						projectUnderCursor = this.projects.removeAt(0) as ProjectEvent;
						projectsWaitingForSubProcessesToStart.add(projectUnderCursor);
						dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED,
								projectUnderCursor.project.name,
								"Opening ("+ workingQueueCount +"/"+ totalQueueCount +"): ", false));

						success("Opening ("+ workingQueueCount +"/"+ totalQueueCount +"): " + projectUnderCursor.project.name);
						runAddProjectMethodInStarterSubscriber(0);
					}
					else
					{
						projects = projectsWaitingForSubProcessesToStart;
						projectsWaitingForSubProcessesToStart = new ArrayCollection();
						starterOrderIndex ++;
						start2();
					}
					break;
				case 2:
					if ((projects.length != 0) &&
							((orderIndex == 0) || (orderIndex >= startersByOrder.length)))
					{
						orderIndex = 0;
						workingQueueCount ++;
						projectUnderCursor = this.projects.removeAt(0) as ProjectEvent;
						projectsWaitingForSubProcessesToStart.add(projectUnderCursor);
						dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED,
								projectUnderCursor.project.name,
								"Initializing ("+ workingQueueCount +"/"+ totalQueueCount +"): ", false));

						success("Initializing ("+ workingQueueCount +"/"+ totalQueueCount +"): " + projectUnderCursor.project.name);
						runAddProjectMethodInStarterSubscriber(orderIndex);
						orderIndex ++;
					}
					else if ((projects.length == 0) &&
							((orderIndex == 0) || (orderIndex >= startersByOrder.length)))
					{
						orderIndex = 0;
						projects = projectsWaitingForSubProcessesToStart;
						projectsWaitingForSubProcessesToStart = new ArrayCollection();
						starterOrderIndex ++;
						start2();
					}
					else if (orderIndex < startersByOrder.length)
					{
						runAddProjectMethodInStarterSubscriber(orderIndex);
						orderIndex ++;
					}
					break;
				default:
					starterOrderIndex ++;
					start2();
					break;
			}
		}

		protected function runStarterMethodssAfterProjectsAdded():void
		{
			if (orderIndex < startersByOrder.length)
			{
				runAddProjectMethodInStarterSubscriber(orderIndex);
				orderIndex ++;
			}
		}

		protected function runAddProjectMethodInStarterSubscriber(localOrderIndex:int):void
		{
			// it's impossible to ensure all granular processes
			// to have completed from IProjectStarter component
			// before executing next steps, because there is no
			// Async operation available in AS3. Haxe does, though.
			// to execute next step in safe intervals with possibility
			// to complete IProjectStarter processes, we executes
			// with a short setTimeout(50)
			var interval:uint = setTimeout(function(localOrderIndex:int):void
			{
				clearTimeout(interval);
				(startersByOrder[localOrderIndex] as ProjectStarterSubscribing).subscriber.onProjectAdded(projectUnderCursor);
				//(starter_order[orderIndex] as MethodDescriptor).callMethod();
			}, 100, localOrderIndex);
		}

		public function continueDelegationOld():void
		{
			orderIndex++;
			if (orderIndex >= startersByOrder.length)
			{
				orderIndex = -1;
				isCycleRunning = false;
				dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
				if (projects.length > 0) start();
				else
				{
					trace("+++++++++++++++++++++++++++++");
					totalQueueCount = 0;
					workingQueueCount = 0;
					if (starterOrderIndex == 1)
					{
						model.mainView.getTreeViewPanel().selectProject(
								model.mainView.getTreeViewPanel().projects.getItemAt(
										model.mainView.getTreeViewPanel().projects.length - 1
								) as ProjectVO
						);
					}

					starterOrderIndex++;
					start2();
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
				var interval:uint = setTimeout(function(localOrderIndex:int):void
				{
					clearTimeout(interval);
					(startersByOrder[localOrderIndex] as ProjectStarterSubscribing).subscriber.onProjectAdded(projectUnderCursor);
					//(starter_order[orderIndex] as MethodDescriptor).callMethod();
				}, 100, orderIndex);
			}
		}

		public function showProjectPanel():void
		{
			dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.SHOW_PROJECT_VIEW));
		}

		private function initStarterOrder():void
		{
			starter_order_beginning = [];
			starter_order_after_selection = [];
			starter_order_after_addition = [];

			for each (var starter:ProjectStarterSubscribing in starters)
			{
				starter.subscriber.projectStarterDelegate = this;

				// we need to have sidebar to be displayed first
				if (getQualifiedClassName(starter.subscriber) == "actionScripts.plugin.project::ProjectPlugin")
				{
					starter_order_beginning.push(starter);
				}
				else if (starter.isRunsOnlyWithProjectSelection)
				{
					starter_order_after_selection.push(starter);
				}
				else
				{
					starter_order_after_addition.push(starter);
				}
			}
		}

		private var executeDictionary:Dictionary = new Dictionary();

		private function onProjectSelectionChangedInSidebar(event:ProjectEvent):void
		{
			for each (var starter:ProjectStarterSubscribing in starter_order_after_selection)
			{
				if (starter.isRunsOnlyWithProjectSelection)
				{
					if (starter.occurrenceType == ProjectStarterSubscribing.OCCURRENCE_EVERYTIME_ON_PROJECT_SELECTION)
					{
						starter.subscriber.onProjectAdded(event);
					}
					else
					{
						var tmpExecuteCheck:String = getQualifiedClassName(starter.subscriber) +"-"+ event.project.projectFolder.nativePath;
						if (executeDictionary[tmpExecuteCheck] == undefined)
						{
							starter.subscriber.onProjectAdded(event);
							executeDictionary[tmpExecuteCheck] = true;
						}
					}
				}
			}
		}

		private function onProjectRemove(event:ProjectEvent):void
		{
			for each (var starter:ProjectStarterSubscribing in starters)
			{
				if (starter.isRunsOnlyWithProjectSelection &&
					(starter.occurrenceType == ProjectStarterSubscribing.OCCURRENCE_ONCE_ON_PROJECT_SELECTION))
				{
					var tmpExecuteCheck:String = getQualifiedClassName(starter.subscriber) +"-"+ event.project.projectFolder.nativePath;
					delete executeDictionary[tmpExecuteCheck];
				}
			}
		}

		private function onWorkspaceChanged(event:Event):void
		{
			executeDictionary = new Dictionary();
		}
	}
}