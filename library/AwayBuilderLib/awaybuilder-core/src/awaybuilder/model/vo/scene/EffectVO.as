package awaybuilder.model.vo.scene
{
	[Bindable]
	public class EffectVO extends AssetVO
	{
		
		public var type:String;
		
		public var mode:String = "Multiply";
		
		public var texture:TextureVO;
		public var cubeTexture:CubeTextureVO;
		public var textureProjector:TextureProjectorVO;
		
		public var refraction:Number;
		public var alpha:Number;
		
		public var r:Number;
		public var g:Number;
		public var b:Number;
		public var a:Number;
		public var rG:Number;
		public var gG:Number;
		public var bG:Number;
		public var aG:Number;
		public var rB:Number;
		public var gB:Number;
		public var bB:Number;
		public var aB:Number;
		public var rA:Number;
		public var gA:Number;
		public var bA:Number;
		public var aA:Number;
		public var rO:Number;
		public var gO:Number;
		public var bO:Number;
		public var aO:Number;
		
		public var color:uint;
		public var strength:Number;
		public var power:Number;
		public var useSecondaryUV:Boolean;
		
		public var normalReflectance:Number;
		
		public var showInnerLines:Boolean;
		public var dedicatedMesh:Boolean;
		
		public var size:Number;
		public var minDistance:Number;
		public var maxDistance:Number;
		
		public function clone():EffectVO
		{
			var vo:EffectVO = new EffectVO();
			vo.fillFromEffectMethod( this );
			return vo;
		}
		
		public function fillFromEffectMethod( asset:EffectVO ):void
		{
			this.name = asset.name;
			this.alpha = asset.alpha;
			this.type = asset.type;
			this.isDefault = asset.isDefault;
			this.id = asset.id;
			
			this.mode = asset.mode;
			
			this.texture = asset.texture;
			this.cubeTexture = asset.cubeTexture;
			this.textureProjector = asset.textureProjector;
			
			this.normalReflectance = asset.normalReflectance;
			
			this.refraction = asset.refraction;
			this.alpha = asset.alpha;
			
			this.r = asset.r;
			this.g = asset.g;
			this.b = asset.b;
			this.a = asset.a;
			this.rG = asset.rG;
			this.gG = asset.gG;
			this.bG = asset.bG;
			this.aG = asset.aG;
			this.rB = asset.rB;
			this.gB = asset.gB;
			this.bB = asset.bB;
			this.aB = asset.aB;
			this.rA = asset.rA;
			this.gA = asset.gA;
			this.bA = asset.bA;
			this.aA = asset.aA;
			this.rO = asset.rO;
			this.gO = asset.gO;
			this.bO = asset.bO;
			this.aO = asset.aO;
			
			this.color = asset.color;
			this.strength = asset.strength;
			this.power = asset.power;
			this.useSecondaryUV = asset.useSecondaryUV;
			
			this.showInnerLines = asset.showInnerLines;
			this.dedicatedMesh = asset.dedicatedMesh;
			
			this.size = asset.size;
			this.minDistance = asset.minDistance;
			this.maxDistance = asset.maxDistance;
			
		}
		
		public static const ALPHA_MASK:String = "AlphaMask";
		public static const COLOR_MATRIX:String = "ColorMatrix";
		public static const COLOR_TRANSFORM:String = "ColorTransform";
		public static const ENV_MAP:String = "EnvMap";
		public static const FOG:String = "Fog";
		public static const FRESNEL_ENV_MAP:String = "FresnelEnvMap";
		public static const FRESNEL_PLANAR_REFLECTION:String = "FresnelPlanarReflection";
		public static const LIGHT_MAP:String = "LightMap";
		public static const OUTLINE:String = "Outline";
		public static const PLANAR_REFLECTION:String = "PlanarReflection";
		public static const PROJECTIVE_TEXTURE:String = "ProjectiveTexture";
		public static const REFRACTION_ENV_MAP:String = "RefractionEnvMap";
		public static const RIM_LIGHT:String = "RimLight";
		
	}
}
