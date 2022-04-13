package actionScripts.plugin.project.vo
{
	import actionScripts.plugin.project.interfaces.IProjectStarter;

	public class ProjectStarterSubscribing
	{
		public static const OCCURRENCE_EVERYTIME_ON_PROJECT_SELECTION:String = "execute-everytime-project-selection";
		public static const OCCURRENCE_ONCE_ON_PROJECT_SELECTION:String = "execute-once-project-selection";

		public var subscriber:IProjectStarter;
		public var subscriberMethods:Vector.<String>; // Function must accept ProjectEvent
		public var isRunsOnlyWithProjectSelection:Boolean;
		public var occurrenceType:String;

		public function ProjectStarterSubscribing(subscriber:IProjectStarter, methods:Vector.<String>, runsOnlyWithProjectSelection:Boolean=true, occurrenceIfRunsOnlyWithProjectSelection:String=OCCURRENCE_ONCE_ON_PROJECT_SELECTION)
		{
			this.subscriber = subscriber;
			this.subscriberMethods = methods;
			this.isRunsOnlyWithProjectSelection = runsOnlyWithProjectSelection;
			this.occurrenceType = occurrenceIfRunsOnlyWithProjectSelection;
		}
	}
}
