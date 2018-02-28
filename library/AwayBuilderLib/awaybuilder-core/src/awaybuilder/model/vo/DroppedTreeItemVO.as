package awaybuilder.model.vo
{
	public class DroppedTreeItemVO
	{
		public function DroppedTreeItemVO( value:Object ):void
		{
			this.value = value;
		}
		public var value:Object;
		
		public var oldPosition:int;
		public var newPosition:int;
		
		public var oldParent:Object;
		public var newParent:Object;
		
	}
}