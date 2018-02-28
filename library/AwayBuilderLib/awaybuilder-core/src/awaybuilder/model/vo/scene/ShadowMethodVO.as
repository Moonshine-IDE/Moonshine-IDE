package awaybuilder.model.vo.scene
{

	[Bindable]
	public class ShadowMethodVO extends AssetVO
	{
		public var castingLight:LightVO;
		
		public var epsilon:Number = .002;
		public var alpha:Number = 1;
		
		public var samples:Number = 5;
		public var range:Number = 1;
		
		public var baseMethod:ShadowMethodVO;
		
		public var isBaseOfShadowMethod:ShadowMethodVO = null;
		
		public var type:String;
		
		public function clone():ShadowMethodVO
		{
			var vo:ShadowMethodVO = new ShadowMethodVO();
			vo.fillFromShadowMethod( this );
			return vo;
		}
		
		public function fillFromShadowMethod( asset:ShadowMethodVO ):void
		{
			this.name = asset.name;
			this.type = asset.type;
			this.epsilon = asset.epsilon;
			this.alpha = asset.alpha;
			this.samples = asset.samples;
			this.range = asset.range;
			this.baseMethod = asset.baseMethod;
			this.isBaseOfShadowMethod = asset.isBaseOfShadowMethod;
		}

		public static const FILTERED_SHADOW_MAP_METHOD:String = "FilteredShadowMapMethod";
		public static const DITHERED_SHADOW_MAP_METHOD:String = "DitheredShadowMapMethod";
		public static const SOFT_SHADOW_MAP_METHOD:String = "SoftShadowMapMethod";
		public static const HARD_SHADOW_MAP_METHOD:String = "HardShadowMapMethod";
		public static const NEAR_SHADOW_MAP_METHOD:String = "NearShadowMapMethod";
		public static const CASCADE_SHADOW_MAP_METHOD:String = "CascadeShadowMapMethod";
	}
}
