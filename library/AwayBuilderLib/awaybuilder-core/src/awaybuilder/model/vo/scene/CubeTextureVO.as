package awaybuilder.model.vo.scene
{
	import awaybuilder.model.vo.scene.interfaces.IDefaultable;
	
	import flash.display.BitmapData;

	[Bindable]
	public class CubeTextureVO extends AssetVO implements IDefaultable
	{
		
		public var positiveX:BitmapData;
		public var negativeX:BitmapData;
		public var positiveY:BitmapData;
		public var negativeY:BitmapData;
		public var positiveZ:BitmapData;
		public var negativeZ:BitmapData;
		
		public function clone():CubeTextureVO
		{
			var vo:CubeTextureVO = new CubeTextureVO();
			vo.fillFromCubeTexture( this );
			return vo;
		}
		
		public function fillFromCubeTexture( asset:CubeTextureVO ):void
		{
			this.isDefault = asset.isDefault;
			this.id = asset.id;
			this.name = asset.name;
			this.positiveX = asset.positiveX;
			this.negativeX = asset.negativeX;
			this.positiveY = asset.positiveY;
			this.negativeY = asset.negativeY;
			this.positiveZ = asset.positiveZ;
			this.negativeZ = asset.negativeZ;
		}
		
	}
}