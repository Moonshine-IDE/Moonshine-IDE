package awaybuilder.model.vo.scene
{
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class LightVO extends ObjectVO
	{
		
		public var type:String;
		
		public var color:uint = 0xffffff;
		
		public var ambientColor:uint = 0xffffff;
		public var ambient:Number = 0;
		
		public var specular:Number = 1;
		public var diffuse:Number = 1;
		
		public var radius:Number = 1;
		public var fallOff:Number = 1;
		
		public var castsShadows:Boolean;
		
		public var shadowMapper:ShadowMapperVO;
		
		public var shadowMethods:ArrayCollection = new ArrayCollection();
		
		public var azimuthAngle:Number = 0;
		public var elevationAngle:Number = 0;
		
		override public function clone():ObjectVO
		{
			var vo:LightVO = new LightVO();
			vo.fillFromLight( this );
			return vo;
		}
		
		public function fillFromLight( asset:LightVO ):void
		{
			this.name = asset.name;
			
			this.fillFromObject( asset );
			this.type = asset.type;
			
			this.color = asset.color;
			this.ambientColor = asset.ambientColor;
			this.ambient = asset.ambient;
			this.diffuse = asset.diffuse;
			
			this.castsShadows = asset.castsShadows;

			this.shadowMapper = asset.shadowMapper;
			
			this.shadowMethods = updateCollection( this.shadowMethods, asset.shadowMethods )
			
			this.azimuthAngle = asset.azimuthAngle;
			this.elevationAngle = asset.elevationAngle;
			this.specular = asset.specular;
			
			this.radius = asset.radius;
			this.fallOff = asset.fallOff;
		}
		
		public static const DIRECTIONAL:String = "directionalType";
		public static const POINT:String = "pointType";
	}
}