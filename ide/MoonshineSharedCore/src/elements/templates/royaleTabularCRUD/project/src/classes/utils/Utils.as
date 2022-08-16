package classes.utils
{
	import org.apache.royale.html.beads.DisableBead;
	import org.apache.royale.html.beads.DisabledAlphaBead;
	import org.apache.royale.html.LoadIndicator;
	
	public class Utils
	{
		public static var mainContentView:Object; 
		
		private static var loader:LoadIndicator;
		
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

		public static function convertEpochToDate(epoch:Number):Date
		{
			var tmpDate:Date = new Date();
			tmpDate.setTime(epoch);

			return tmpDate;
		}
		
		public static function setBusy():void
		{
			var result:DisableBead = getDisableBead();
			result.disabled = true;
			addRemoveBusyIndicator();
		}
		
		public static function removeBusy():void
		{
			var result:DisableBead = getDisableBead();
			result.disabled = false;
			addRemoveBusyIndicator();
		}
		
		private static function getDisableBead():DisableBead
		{
			var result:DisableBead = mainContentView.getBeadByType(DisableBead) as DisableBead;
            if (!result)
            {
                result = new DisableBead();
                mainContentView.addBead(result);
                return result;
            }
            return result;
		}
		
		private static function addRemoveBusyIndicator():void
		{
			if (loader)
			{
				mainContentView.removeElement(loader);
				loader = null;
			}
			else
			{
				loader = new LoadIndicator();
				loader.width = loader.height = 50;
				loader.x = mainContentView.width / 2 - loader.width / 2;
				loader.y = mainContentView.height / 2 - loader.height / 2;
				COMPILE::JS
				{
					loader.element.style.position = "absolute";
				}
				mainContentView.addElement(loader);
			}
		}
	}
}