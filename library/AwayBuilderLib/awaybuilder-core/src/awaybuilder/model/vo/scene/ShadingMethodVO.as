package awaybuilder.model.vo.scene
{
	[Bindable]
	public class ShadingMethodVO extends AssetVO
	{
		
		public var type:String;
		
		public var envMap:CubeTextureVO;
		
		public var value:Number;
		
		public var blendMode:String;
		public var texture:TextureVO;
		public var baseMethod:ShadingMethodVO;
		
		public var smoothness:Number;
		
		public var scattering:Number;
		public var translucency:Number; 
		public var scatterColor:uint;
		
		public var basedOnSurface:Boolean;
		
		public var fresnelPower:Number;
		
		public var width:Number;
		public var height:Number;
		public var depth:Number;
		
		public function clone():ShadingMethodVO
		{
			var clone:ShadingMethodVO = new ShadingMethodVO();
			clone.fillFromShadingMethod( this );
			return clone;
		}
		
		public function fillFromShadingMethod( asset:ShadingMethodVO ):void
		{
			this.id = asset.id;
			this.type = asset.type;
			
			this.envMap = asset.envMap;
			this.texture = asset.texture;
			
			this.value = asset.value;
			
			this.blendMode = asset.blendMode;
			this.baseMethod = asset.baseMethod;
			
			this.smoothness = asset.smoothness;
			
			this.scattering = asset.scattering;
			this.translucency = asset.translucency;
			this.scatterColor = asset.scatterColor;
			
			this.basedOnSurface = asset.basedOnSurface;
			
			this.fresnelPower = asset.fresnelPower;
			
			this.width = asset.width;
			this.height = asset.height;
			this.depth = asset.depth;
			
		}
		
	}
}
