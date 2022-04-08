package actionScripts.plugin.project.vo
{
	import actionScripts.plugin.project.interfaces.IProjectStarter;

	public class ProjectStarterSubscribing
	{
		public var subscriber:IProjectStarter;
		public var subscriberMethods:Vector.<String>; // Function must accept ProjectEvent

		public function ProjectStarterSubscribing(subscriber:IProjectStarter, methods:Vector.<String>)
		{
			this.subscriber = subscriber;
			this.subscriberMethods = methods;
		}
	}
}
