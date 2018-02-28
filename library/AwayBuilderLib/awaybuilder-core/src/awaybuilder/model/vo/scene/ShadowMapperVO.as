package awaybuilder.model.vo.scene
{
	[Bindable]
	public class ShadowMapperVO extends AssetVO
	{
		
		public var numCascades:Number = 5;
		public var coverage:Number = 1;
		
		public var depthMapSize:Number;
		public var depthMapSizeCube:Number;
		
		public var type:String;
		
		public function clone():ShadowMapperVO
		{
			var clone:ShadowMapperVO = new ShadowMapperVO();
			clone.fillFromShadowMapper( this );
			return clone;
		}
		
		public function fillFromShadowMapper( asset:ShadowMapperVO ):void
		{
			this.id = asset.id;
			this.numCascades = asset.numCascades;
			this.coverage = asset.coverage;
			this.type = asset.type;
			this.depthMapSize = asset.depthMapSize;
			this.depthMapSizeCube = asset.depthMapSizeCube;
		}
		
	}
}
