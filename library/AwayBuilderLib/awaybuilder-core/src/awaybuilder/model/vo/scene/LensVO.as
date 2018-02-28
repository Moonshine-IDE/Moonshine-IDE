package awaybuilder.model.vo.scene
{
	[Bindable]
	public class LensVO extends AssetVO
	{
		
		public var type:String;
		
		public var value:Number;
		
		public var minX:Number;
		public var maxX:Number;
		public var minY:Number;
		public var maxY:Number;
		
		public var near:Number;
		public var far:Number;
		
		public function clone():LensVO
		{
			var vo:LensVO = new LensVO();
			vo.fillFromLens( this );
			return vo;
		}
		
		public function fillFromLens( asset:LensVO ):void
		{
			this.name = asset.name;
			
			this.type = asset.type;
			this.value = asset.value;
			this.minX = asset.minX;
			this.maxX = asset.maxX;
			this.minY = asset.minY;
			this.maxY = asset.maxY;
			this.near = asset.near;
			this.far = asset.far;
			
			this.id = asset.id;
		}
	}
}