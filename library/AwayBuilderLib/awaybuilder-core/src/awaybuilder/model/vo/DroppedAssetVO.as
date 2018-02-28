package awaybuilder.model.vo
{
	import awaybuilder.model.vo.scene.AssetVO;

	public class DroppedAssetVO
	{
		public var value:AssetVO;
		
		public var oldPosition:int;
		public var newPosition:int;
		
		public var oldParent:AssetVO;
		public var newParent:AssetVO;
	}
}