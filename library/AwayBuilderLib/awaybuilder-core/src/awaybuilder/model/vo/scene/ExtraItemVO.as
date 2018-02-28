package awaybuilder.model.vo.scene
{
	[Bindable]
	public class ExtraItemVO
	{
		public var name:String;
		public var value:String;
		
		public function clone():ExtraItemVO
		{
			var clone:ExtraItemVO = new ExtraItemVO();
			clone.name = name;
			clone.value = value;
			return clone;
		}
	}
}