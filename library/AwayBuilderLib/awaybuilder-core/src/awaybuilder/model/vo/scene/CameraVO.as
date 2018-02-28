package awaybuilder.model.vo.scene
{
	[Bindable]
	public class CameraVO extends ObjectVO
	{
		
		public var lens:LensVO;
		
		override public function clone():ObjectVO
		{
			var asset:CameraVO = new CameraVO();
			asset.fillFromCamera( this );
			return asset;
		}
		
		public function fillFromCamera( asset:CameraVO ):void
		{
			this.fillFromObject( asset );
			this.lens = asset.lens;
		}
		
		
	}
}
