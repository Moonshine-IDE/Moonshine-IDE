package awaybuilder.utils
{
	import flash.utils.Dictionary;

	public class AssetUtil
	{
		public static function GetNextId( type:String ):String
		{
			if( !ids[type] )
			{
				ids[type] = 0;
			}
			ids[type] = ids[type] + 1;
			return ids[type];
		}
		public static function Clear():void
		{
			ids = new Dictionary();
		}
		private static var ids:Dictionary = new Dictionary();
	}
}