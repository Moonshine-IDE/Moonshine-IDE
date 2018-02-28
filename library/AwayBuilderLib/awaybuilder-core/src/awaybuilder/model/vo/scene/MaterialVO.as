package awaybuilder.model.vo.scene
{
    import awaybuilder.model.vo.scene.interfaces.IDefaultable;
    import flash.geom.ColorTransform;
    
    import mx.collections.ArrayCollection;

	[Bindable]
    public class MaterialVO extends MaterialBaseVO implements IDefaultable
    {
		
		public static const SINGLEPASS:String = "singlepass";
		public static const MULTIPASS:String = "multipass";
		
		public var type:String;
		
		public var alpha:Number;
		
		public var alphaBlending:Boolean;
		
		public var colorTransform:ColorTransform;
		
		public var alphaThreshold:Number;
		
		public var ambientLevel:Number;
		public var ambientColor:uint;
		public var ambientTexture:TextureVO;
		public var ambientMethod:ShadingMethodVO;
		
		public var diffuseColor:uint;
		public var diffuseTexture:TextureVO;
		public var diffuseMethod:ShadingMethodVO;
		
		public var normalColor:uint;
		public var normalTexture:TextureVO;
		public var normalMethod:ShadingMethodVO;
		
		public var specularLevel:Number;
		public var specularColor:uint;
		public var specularTexture:TextureVO;
		public var specularGloss:Number;
		public var specularMethod:ShadingMethodVO;
		
		public var shadowMethod:ShadowMethodVO;
		
		public var effectMethods:ArrayCollection = new ArrayCollection(); // SharedEffectMethodVO
		
        public function clone():MaterialVO
        {
            var vo:MaterialVO = new MaterialVO();
			vo.fillFromMaterial( this );
            return vo;
        }
		
		public function fillFromMaterial( asset:MaterialVO ):void
		{
			if( asset.name )
			{
				this.name = asset.name;
			}
			
			this.alpha = asset.alpha;
			this.alphaThreshold = asset.alphaThreshold;
			
			this.alphaPremultiplied = asset.alphaPremultiplied;
			this.type = asset.type;
			this.repeat = asset.repeat;
			this.isDefault = asset.isDefault;
			
			this.bothSides = asset.bothSides;
			this.extra = asset.extra;
			
			this.mipmap = asset.mipmap;
			this.smooth = asset.smooth;
			this.blendMode = asset.blendMode;
			
			this.alphaBlending = asset.alphaBlending;
			this.colorTransform = asset.colorTransform;
			
			this.lightPicker = asset.lightPicker;
			this.light = asset.light;
			this.shadowMethod = asset.shadowMethod;
			
			this.normalTexture = asset.normalTexture;
			this.normalMethod = asset.normalMethod;
			
			this.diffuseTexture = asset.diffuseTexture;
			this.diffuseColor = asset.diffuseColor;
			this.diffuseMethod = asset.diffuseMethod;
			
			this.ambientLevel = asset.ambientLevel;
			this.ambientColor = asset.ambientColor;
			this.ambientTexture = asset.ambientTexture;
			this.ambientMethod = asset.ambientMethod;
			
			this.specularLevel = asset.specularLevel;
			this.specularColor = asset.specularColor;
			this.specularGloss = asset.specularGloss;
			this.specularTexture = asset.specularTexture;
			this.specularMethod = asset.specularMethod;
			
			this.effectMethods = new ArrayCollection( asset.effectMethods.source.concat() );
			
		}
    }
}
