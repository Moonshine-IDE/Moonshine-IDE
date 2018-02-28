package awaybuilder.model.vo.scene
{
	
	[Bindable]
	public class SubGeometryVO extends AssetVO
	{
		
		public var type : String;
		
		public var vertexData : Vector.<Number>;
		public var vertexOffset : int;
		public var vertexStride: uint;
		
		public var autoDerivedNormals: Boolean;
		public var autoDerivedTangents: Boolean;
		public var numVerts:Number;
		public var numTris:Number;
		public var scaleU:Number;
		public var scaleV:Number;
		
		public var hasUVData : Boolean;
		public var UVData : Vector.<Number>;
		public var UVStride : uint;
		public var UVOffset : int;
		
		public var hasSecUVData : Boolean;
		public var SecUVData : Vector.<Number>;
		public var SecUVStride : uint;
		public var SecUVOffset : int;
		
		public var vertexNormalData : Vector.<Number>;
		public var vertexNormalOffset : int;
		public var vertexNormalStride : uint;
		
		public var vertexTangentData : Vector.<Number>;
		public var vertexTangentOffset : int;
		public var vertexTangentStride : uint;
		
		public var jointWeightsData : Vector.<Number>;
		public var jointIndexData : Vector.<Number>;
		
		public var indexData : Vector.<uint>;
		
//		public var parentGeometry:GeometryVO;
		
		public function clone():SubGeometryVO
		{
			var vo:SubGeometryVO = new SubGeometryVO();
			vo.fillFromSubGeometryVO( this );
			return vo;
		}
		
		public function fillFromSubGeometryVO( asset:SubGeometryVO ):void
		{
			this.id = asset.id;
			this.type = asset.type;
			this.name = asset.name;
			this.numVerts = asset.numVerts;
			this.numTris = asset.numTris;
			this.scaleU = asset.scaleU;
			this.scaleV = asset.scaleV;
			this.vertexData = asset.vertexData;
			this.vertexOffset = asset.vertexOffset;
			this.vertexStride = asset.vertexStride;
			this.autoDerivedNormals = asset.autoDerivedNormals;
			this.autoDerivedTangents = asset.autoDerivedTangents;
			this.hasUVData = asset.hasUVData;
			this.UVData = asset.UVData;
			this.UVStride = asset.UVStride;
			this.UVOffset = asset.UVOffset;			
			this.hasSecUVData = asset.hasSecUVData;
			this.SecUVData = asset.SecUVData;
			this.SecUVStride = asset.SecUVStride;
			this.SecUVOffset = asset.SecUVOffset;
			this.vertexNormalData = asset.vertexNormalData;
			this.vertexNormalOffset = asset.vertexNormalOffset;
			this.vertexNormalStride = asset.vertexNormalStride;
			this.vertexTangentData = asset.vertexTangentData;
			this.vertexTangentOffset = asset.vertexTangentOffset;
			this.vertexTangentStride = asset.vertexTangentStride;
			this.indexData = asset.indexData;
			this.jointWeightsData = asset.jointWeightsData;
			this.jointIndexData = this.jointIndexData;
		}
	}
}
