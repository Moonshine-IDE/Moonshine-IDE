package awaybuilder.model.vo.scene
{
	[Bindable]
	public class SkyBoxVO extends AssetVO
	{
		
		public var cubeMap:CubeTextureVO;
		
		public function clone():SkyBoxVO
		{
			var clone:SkyBoxVO = new SkyBoxVO();
			clone.fillFromSkyBox( this );
			return clone;
		}
		
		public function fillFromSkyBox( asset:SkyBoxVO ):void
		{
			this.id = asset.id;
			this.name = asset.name;
			this.cubeMap = asset.cubeMap;
		}
		
	}
}
