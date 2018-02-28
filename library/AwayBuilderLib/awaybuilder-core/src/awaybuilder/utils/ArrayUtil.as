package awaybuilder.utils
{
	public class ArrayUtil
	{
		public static function vectorEqualToArray(a:Vector.<Object>, b:Array):Boolean {
			if(a.length != b.length) {
				return false;
			}
			var len:int = a.length;
			for(var i:int = 0; i < len; i++) {
				if(a[i] !== b[i]) {
					return false;
				}
			}
			return true;
		}
	}
}