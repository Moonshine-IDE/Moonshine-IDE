package awaybuilder.model.vo
{
	import awaybuilder.model.vo.scene.AssetVO;

	public class DeleteStateVO
	{
		
		public function DeleteStateVO( asset:AssetVO, owner:AssetVO, index:uint=0 )
		{
			this.asset = asset;
			this.owner = owner;
			this.index = index;
		}
		
		public var asset:AssetVO;
		
		public var owner:AssetVO;
		
		public var index:uint;
		
		public function toString():String
		{
			return "[DeleteStateVO"+asset+"]"
		}
	}
}