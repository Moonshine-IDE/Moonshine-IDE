package classes.utils
{
	public class Utils
	{
		public static function getDateString(value:Date, allowTime:Boolean=true):String
		{
			var options:Object = { month: 'short', day: '2-digit', year: 'numeric'};
			if (allowTime)
			{
				options.hour = '2-digit';
				options.minute = '2-digit';
				options.second = '2-digit';
				options.timeZoneName = 'short';
			}
			
			return value.toLocaleDateString("en-US", options);
		}
	}
}