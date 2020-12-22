package actionScripts.plugins.git.utils
{
	public class GitUtils
	{
		public static function getCalculatedRemotePathWithAuth(initialPath:String, username:String, password:String=null):String
		{
			var calculatedURL:String = initialPath;
			if (calculatedURL.indexOf("@") != -1)
			{
				calculatedURL = calculatedURL.replace(
						calculatedURL.substring(0, calculatedURL.indexOf("@") + 1),
						""
				);
			}

			return (calculatedURL = "https://"+ username + (password ? ":"+ password : "") +"@"+ calculatedURL);
		}
	}
}
