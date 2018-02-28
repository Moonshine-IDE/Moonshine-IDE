package awaybuilder.model.vo.scene 
{
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	
	import mx.collections.ArrayCollection;
	
	import away3d.core.base.SubMesh;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	
	import awaybuilder.utils.AssetUtil;
	
	[Bindable]
	public class SubMeshVO extends AssetVO
	{
	
	    public var material:MaterialVO;
		
		public var subGeometry:SubGeometryVO;
		
		public var uvTransform:Matrix;
		
		public var parentMesh:MeshVO;
		
		public function clone():SubMeshVO
		{
			var m:SubMeshVO = new SubMeshVO();
			m.id = this.id;
			m.material = this.material;
			m.subGeometry = this.subGeometry;
			m.parentMesh = this.parentMesh;
			m.uvTransform = this.uvTransform;
			return m;
		}
		
	}
}
