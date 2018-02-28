package awaybuilder.model.vo
{
	import awaybuilder.model.vo.scene.AssetVO;

	[Bindable]
	public class GlobalOptionsVO
	{
		
		public var matrixStorage:String = "Size"; // [Size, Precision ]
		
		public var geometryStorage:String = "Size"; // [Size, Precision ]
		
		public var propertyStorage:String = "Size"; // [Size, Precision ]
		
		public var attributesStorage:String = "Size"; // [Size, Precision ]
		
		public var compression:String = "DEFLATE"; // [UNCOMPRESSED, DEFLATE, LZMA]
		
		public var namespace:String = "http://example.com/myawdns";
		
		public var embedTextures:Boolean = true;
		
		public var includeNormal:Boolean = true;
		
		public var includeTangent:Boolean = true;
		
		public var streaming:Boolean = false;
		
		public function clone():GlobalOptionsVO
		{
			var vo:GlobalOptionsVO = new GlobalOptionsVO();
			vo.fill( this );
			return vo;
		}
		
		public function fill( asset:GlobalOptionsVO ):void
		{
			this.matrixStorage = asset.matrixStorage;
			this.geometryStorage = asset.geometryStorage;
			this.propertyStorage = asset.propertyStorage;
			this.attributesStorage = asset.attributesStorage;
			this.compression = asset.compression;
			
			this.namespace = asset.namespace;
			this.embedTextures = asset.embedTextures;
			this.includeNormal = asset.includeNormal;
			this.includeTangent = asset.includeTangent;
			
			this.streaming = asset.streaming;
		}
		
	}
}