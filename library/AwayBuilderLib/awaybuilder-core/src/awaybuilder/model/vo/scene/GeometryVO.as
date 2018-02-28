package awaybuilder.model.vo.scene
{
	import away3d.core.base.Geometry;
	import away3d.core.base.ISubGeometry;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class GeometryVO extends AssetVO
	{
		
		public var type:String;
		
		public var radius:Number;
		public var bottomRadius:Number;
		public var topRadius:Number;
		public var tubeRadius:Number;
		public var yUp:Boolean;
		public var doubleSided:Boolean;
		public var topClosed:Boolean;
		public var bottomClosed:Boolean;
		public var surfaceClosed:Boolean;
		
		
		
		public var width:Number;
		public var height:Number;
		public var depth:Number;
		public var tile6:Boolean;
		public var segmentsW:uint;
		public var segmentsSW:uint;
		public var segmentsH:uint;
		public var segmentsSH:uint;
		public var segmentsD:Number;
		public var segmentsC:Number;
		public var segmentsR:uint;
		public var segmentsT:Number;
		
		public var scaleU:Number;
		public var scaleV:Number;
		
		public var subGeometries:ArrayCollection;
		
		public function clone():GeometryVO
		{
			var vo:GeometryVO = new GeometryVO();
			vo.fillFromGeometry( this );
			return vo;
		}
		
		public function fillFromGeometry( asset:GeometryVO ):void
		{
			this.name = asset.name;
			
			this.subGeometries = asset.subGeometries;
			this.type = asset.type;
			
			this.width = asset.width;
			this.height = asset.height;
			this.depth = asset.depth;
			this.tile6 = asset.tile6;
			this.segmentsW = asset.segmentsW;
			this.segmentsSW = asset.segmentsSW;
			this.segmentsH = asset.segmentsH;
			this.segmentsSH = asset.segmentsSH;
			this.segmentsD = asset.segmentsD;
			this.segmentsR = asset.segmentsR;
			this.segmentsT = asset.segmentsT;
			this.segmentsC = asset.segmentsC;
			this.radius = asset.radius;
			this.bottomRadius = asset.bottomRadius;
			this.topRadius = asset.topRadius;
			this.tubeRadius = asset.tubeRadius;
			this.yUp = asset.yUp;
			this.doubleSided = asset.doubleSided;
			this.topClosed = asset.topClosed;
			this.bottomClosed = asset.bottomClosed;
			this.surfaceClosed = asset.surfaceClosed;
			this.scaleU = asset.scaleU;
			this.scaleV = asset.scaleV;
			
			this.id = asset.id;
		}
	}
}
