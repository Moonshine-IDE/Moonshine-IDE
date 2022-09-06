package actionScripts.plugins.vagrant.utils
{
	import actionScripts.controllers.DataAgent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.utils.FileDownloader;
	import actionScripts.utils.UnzipUsingAS3CommonZip;

	import flash.events.ErrorEvent;

	import flash.events.Event;

	import flash.filesystem.File;

	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	public class DeployDatabaseJob extends ConvertDatabaseJob
	{
		protected var databaseName:String;

		public function DeployDatabaseJob(nsfUploadCompletionData:Object, server:String, dbName:String)
		{
			databaseName = dbName;

			super(nsfUploadCompletionData, server, null);
		}

		override protected function runConversionCommandOnServer(withId:String = null):void
		{
			clearTimeout(conversioTestTimeout);
			loader = new DataAgent(
					serverURL + "/task" + (withId ? "/" + withId : ""),
					onConversionRunResponseLoaded,
					onConversionRunFault,
					withId ? null : {command: "/bin/bash /opt/domino/scripts/deploy_database.sh '" + uploadedNSFFilePath + "' '"+ databaseName +"'"},
					withId ? DataAgent.GETEVENT : DataAgent.POSTEVENT
			);
		}

		override protected function onTaskStatusCompleted(withJSONObject:Object):void
		{
			success(withJSONObject.output);
			dispatchEvent(new Event(EVENT_CONVERSION_COMPLETE));
		}
	}
}
