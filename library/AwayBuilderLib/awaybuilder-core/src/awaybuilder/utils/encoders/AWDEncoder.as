package awaybuilder.utils.encoders
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	import mx.collections.ArrayCollection;
	
	import away3d.animators.data.SkeletonJoint;
	import away3d.core.base.Geometry;
	import away3d.core.math.MathConsts;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.methods.MethodVO;
	
	import awaybuilder.AwayBuilder;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.AnimationNodeVO;
	import awaybuilder.model.vo.scene.AnimationSetVO;
	import awaybuilder.model.vo.scene.AnimatorVO;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.CameraVO;
	import awaybuilder.model.vo.scene.ContainerVO;
	import awaybuilder.model.vo.scene.CubeTextureVO;
	import awaybuilder.model.vo.scene.EffectVO;
	import awaybuilder.model.vo.scene.ExtraItemVO;
	import awaybuilder.model.vo.scene.GeometryVO;
	import awaybuilder.model.vo.scene.LensVO;
	import awaybuilder.model.vo.scene.LightPickerVO;
	import awaybuilder.model.vo.scene.LightVO;
	import awaybuilder.model.vo.scene.MaterialVO;
	import awaybuilder.model.vo.scene.MeshVO;
	import awaybuilder.model.vo.scene.ObjectVO;
	import awaybuilder.model.vo.scene.ShadingMethodVO;
	import awaybuilder.model.vo.scene.ShadowMapperVO;
	import awaybuilder.model.vo.scene.ShadowMethodVO;
	import awaybuilder.model.vo.scene.SharedAnimationNodeVO;
	import awaybuilder.model.vo.scene.SharedLightVO;
	import awaybuilder.model.vo.scene.SkeletonPoseVO;
	import awaybuilder.model.vo.scene.SkeletonVO;
	import awaybuilder.model.vo.scene.SkyBoxVO;
	import awaybuilder.model.vo.scene.SubGeometryVO;
	import awaybuilder.model.vo.scene.SubMeshVO;
	import awaybuilder.model.vo.scene.TextureProjectorVO;
	import awaybuilder.model.vo.scene.TextureVO;
	
	public class AWDEncoder implements ISceneGraphEncoder
	{
		// set debug to true to get some traces in the console
		private var _debug:Boolean=false;
		private var _body : ByteArray;
		private var _blockBody : ByteArray;
		private var _blockCache : Dictionary;
		private var _blockId : uint;
		
		private var _elemSizeOffsets : Vector.<uint>;
		
		private static const INT8 : uint = 1;
		private static const INT16 : uint = 2;
		private static const INT32 : uint = 3;
		private static const UINT8 : uint = 4;
		private static const UINT16 : uint = 5;
		private static const UINT32 : uint = 6;
		private static const FLOAT32 : uint = 7;
		private static const FLOAT64 : uint = 8;
		private static const BOOL : uint = 21;
		private static const COLOR : uint = 22;
		private static const BADDR : uint = 23;		
		
		public static const AWDSTRING : uint = 31;
		// this constants are not used atm, but might be used at a later released 
		//public static const AWD_FIELD_BYTEARRAY : uint = 32;		
		//public static const AWD_FIELD_VECTOR2x1 : uint = 41;
		//public static const AWD_FIELD_VECTOR3x1 : uint = 42;
		//public static const AWD_FIELD_VECTOR4x1 : uint = 43;
		//public static const AWD_FIELD_MTX3x2 : uint = 44;
		//public static const AWD_FIELD_MTX3x3 : uint = 45;
		//public static const AWD_FIELD_MTX4x3 : uint = 46;
		
		private static const MTX4x4 : uint = 47;
		
		private var blendModeDic:Dictionary;
		
		private var _exportNormals:Boolean=true;
		private var _exportTangents:Boolean=false;
		private var _streaming:Boolean=false;
		private var _compression:uint=0;
		private var _blockCompress:uint=0;
		private var _geomStoragePrecision:uint=0; 
		private var _matrixStoragePrecision:uint=0; 
		private var _propsStoragePrecision:uint=0; 
		private var _attrStoragePrecision:uint=0; 
		private var _embedtextures:Boolean=true; 
		
		private var _matrixNrType : uint;
		private var _propNrType : uint;
		private var _geoNrType : uint;
		private var _attributeNrType : uint;
		
		private var _depthSizeDic:Dictionary=new Dictionary();
		private var _shadowMethodsToLightsDic:Dictionary=new Dictionary();
		private var _translateAnimatiorToMesh:Dictionary=new Dictionary();
		private var _translateAnimationSetToMesh:Dictionary=new Dictionary();
		private var _translateAnimationNodesToMesh:Dictionary=new Dictionary();
		private var _exportedObjects:Dictionary=new Dictionary();
		
		private var _nameSpaceString:String; 
		private var _nameSpaceID:uint; 
		
		public function AWDEncoder()
		{
			super();
			_blockCache = new Dictionary();
			_elemSizeOffsets = new Vector.<uint>();
			_shadowMethodsToLightsDic=new Dictionary();
			_exportedObjects=new Dictionary();
			
			blendModeDic=new Dictionary();
			blendModeDic[BlendMode.NORMAL]=0;
			blendModeDic[BlendMode.ADD]=1;
			blendModeDic[BlendMode.ALPHA]=2;
			blendModeDic[BlendMode.DARKEN]=3;
			blendModeDic[BlendMode.DIFFERENCE]=4;
			blendModeDic[BlendMode.ERASE]=5;
			blendModeDic[BlendMode.HARDLIGHT]=6;
			blendModeDic[BlendMode.INVERT]=7;
			blendModeDic[BlendMode.LAYER]=8;
			blendModeDic[BlendMode.LIGHTEN]=9;
			blendModeDic[BlendMode.MULTIPLY]=10;
			blendModeDic[BlendMode.NORMAL]=11;
			blendModeDic[BlendMode.OVERLAY]=12;
			blendModeDic[BlendMode.SCREEN]=13;
			blendModeDic[BlendMode.SHADER]=14;
			blendModeDic[BlendMode.OVERLAY]=15;
			
			_depthSizeDic[256]=0;
			_depthSizeDic[512]=1;
			_depthSizeDic[2048]=2;
			_depthSizeDic[1024]=3;
		}
		
		// this function is called from the app...
		public function encode(document : DocumentModel, output : ByteArray, useWebRestriction:Boolean = false) : Boolean
		{
			_body = new ByteArray();
			_body.endian = Endian.LITTLE_ENDIAN;
			_blockId = 0;
			
			_nameSpaceID = 1;
			_nameSpaceString = document.globalOptions.namespace;
			_embedtextures = document.globalOptions.embedTextures;
			
			// get the type of compression to use
			switch(document.globalOptions.compression)
			{
				case "DEFLATE":
					_compression = 1;
					break;
				case "LZMA":
					_compression = 2;		
					break;
				default:
					_compression = 0;		
					break;
			}
			// if the streaming option is enabled, the compression is set per block
			if (document.globalOptions.streaming)
			{
				_blockCompress = _compression;
				_compression = 0;
			}
			
			// set the global - storage - precision
			_matrixNrType = FLOAT32;
			if (document.globalOptions.matrixStorage=="Precision"){
				_matrixNrType = FLOAT64;
				_matrixStoragePrecision = 1;				
			}
			_geoNrType=FLOAT32;
			if (document.globalOptions.geometryStorage=="Precision"){
				_geoNrType = FLOAT64;
				_geomStoragePrecision = 1;	
			}
			_propNrType=FLOAT32;
			if (document.globalOptions.propertyStorage=="Precision"){
				_propNrType = FLOAT64;
				_propsStoragePrecision = 1;	
			}
			_attributeNrType=FLOAT32;
			if (document.globalOptions.attributesStorage=="Precision"){
				_attributeNrType = FLOAT64;
				_attrStoragePrecision = 1;	
			}
			
			
			var _embedtexturesInt:int = 1;
			var _exportNormalsInt:int = document.globalOptions.includeNormal?1:0;
			var _exportTangentsInt:int = document.globalOptions.includeTangent?1:0;
			
			if( !useWebRestriction )
			{
				_embedtexturesInt = document.globalOptions.embedTextures?1:0;
			}
			
			if(_debug)trace("start encoding");
			
			//create a AWDBlock class for all supported Assets
			_createAwdBlocks(document.textures);
			_createAwdBlocks(document.lights);
			_createAwdBlocks(document.materials);
			_createAwdBlocks(document.geometry);
			_createAwdBlocks(document.animations);
			_encodeMetaDataBlock();			
			_encodeNameSpaceBlock();
			
			// recursive encode all Scene-graph objects (ObjectContainer3d / Mesh) and their dependencies
			var scene:ArrayCollection = document.scene;
			for each ( var vo:AssetVO in scene )
			{
				// type check is done in :encodeChild funtion...
				_encodeChild(vo);
				
			}
			
			//_encode all supported Assets that are not encodet yet
			_encodeAddionalBlocks(document.textures);
			_encodeAddionalBlocks(document.lights);
			_encodeAddionalBlocks(document.materials);
			_encodeAddionalBlocks(document.geometry);
			_encodeAddionalBlocks(document.animations);
						
			// Header
			output.endian = Endian.LITTLE_ENDIAN;
			output.writeUTFBytes("AWD");//MagicString
			output.writeByte(2);//versionNumber
			output.writeByte(1);//RevisionNumber
			
			var bf:uint = 0;
			bf = 0<<15; //Set bit 16 
			bf |= 0<<14; //Set bit 15 
			bf |= 0<<13; //Set bit 14 
			bf |= 0<<12; //Set bit 13 
			bf |= 0<<11; //Set bit 12 
			bf |= 0<<10; //Set bit 11
			bf |= 0<<9; //Set bit 10
			bf |= 0<<8; //Set bit 9
			bf |= _embedtexturesInt<<7; //Set bit 8 embed textures AwayBuilder settings
			bf |= _exportTangentsInt<<6; //Set bit 7 includeTangents AwayBuilder settings
			bf |= _exportNormalsInt<<5; //Set bit 6 includeNormals AwayBuilder settings
			bf |= _attrStoragePrecision<<4; //Set bit 5 attrStoragePrecision AwayBuilder settings
			bf |= _propsStoragePrecision<<3; //Set bit 4
			bf |= _geomStoragePrecision<<2; //Set bit 3
			bf |= _matrixStoragePrecision<<1; //Set bit 2
			bf |= int(document.globalOptions.streaming);    //Set bit 1
			
			output.writeShort(bf); // flags 
			output.writeByte(_compression); // global compression
			if (_compression==1)
				_body.compress();
			if (_compression==2)
				_body.compress(CompressionAlgorithm.LZMA);
			output.writeUnsignedInt(_body.length);
			output.writeBytes(_body);
			
			_finalize();
			
			if(_debug)trace("SUCCESS");
			return true;
		}
		// encodes all assets in a ArrayCollection, if they have not allready been _encodet
		private function _encodeAddionalBlocks(assetList:ArrayCollection) : void
		{			
			for each ( var asset:AssetVO in assetList )
			{
				if (asset is SharedLightVO) asset=SharedLightVO(asset).linkedAsset as LightVO;
				if (asset.isDefault)return;
				switch(true){
					case (asset is AnimationSetVO):
						for each(var animator:AnimatorVO in AnimationSetVO(asset).animators){
							var newanimId:uint=_getBlockIDorEncodeAsset(animator);				
							if(_debug)trace("addional Block  = "+animator.name+" / "+animator);
						}		
					case (asset is AnimationNodeVO):
					case (asset is SkeletonPoseVO):
					case (asset is SkeletonVO):
					case (asset is AnimatorVO):
					case (asset is TextureVO):
					case (asset is CubeTextureVO):
					case (asset is ShadowMethodVO):
					case (asset is EffectVO):
					case (asset is ShadingMethodVO):
					case (asset is LightVO):
					case (asset is LightPickerVO):
					case (asset is MaterialVO):
					case (asset is GeometryVO):
					case (asset is TextureProjectorVO):
						var newId:uint=_getBlockIDorEncodeAsset(asset);
						if (_debug)trace("addional Block: = "+asset.name+" / asset: "+asset+" / id = "+newId);
						break;
				}	
				
			}
		}
				
		// creates AWDBlocks for a list of Assets
		private function _createAwdBlocks(assetList:ArrayCollection) : void
		{
			for each ( var asset:AssetVO in assetList )
			{
				if (asset is LightVO){
					if (asset is SharedLightVO) asset=SharedLightVO(asset).linkedAsset as LightVO;
					for each (var shadowMeth:ShadowMethodVO in LightVO(asset).shadowMethods){
						_shadowMethodsToLightsDic[shadowMeth]=asset;
					}
				}
				if (asset.isDefault)return;
				switch(true){
					case (asset is AnimationSetVO):
						for each(var animator:AnimatorVO in AnimationSetVO(asset).animators){
							if (!_blockCache[animator]){
								var newAnimatorBlock:AWDBlock=new AWDBlock();
								_blockCache[animator]=newAnimatorBlock;								
								if(_debug)trace("create Block for a Asset = "+animator.name+" / "+animator);
							}						
						}
					case (asset is AnimationNodeVO):
					case (asset is SkeletonPoseVO):
					case (asset is SkeletonVO):
					case (asset is AnimatorVO):
					case (asset is TextureVO):
					case (asset is CubeTextureVO):
					case (asset is ShadowMethodVO):
					case (asset is EffectVO):
					case (asset is ShadingMethodVO):
					case (asset is LightVO):
					case (asset is LightPickerVO):
					case (asset is MaterialVO):
					case (asset is GeometryVO):
					case (asset is TextureProjectorVO):
						var newBlock:AWDBlock=new AWDBlock();
						_blockCache[asset]=newBlock;
						if(_debug)trace("create Block for a Asset = "+asset.name+" / "+asset);
						break;
				}	
				
			}
		}
		
		// gets the AWDBlock-ID for a Asset. Blocks that have not been encoded will get encoded here		
		private function _getBlockIDorEncodeAsset(asset:AssetVO) : uint
		{
			if (asset is SharedLightVO) asset=SharedLightVO(asset).linkedAsset as LightVO;
			if (!asset){
				if(_debug)trace("assetNotFound");
				return 0;
			}
			if (asset.isDefault){
				if(_debug)trace("AssetisDefault");
				return 0;
			}
			var thisBlock:AWDBlock=_blockCache[asset];
			if (!thisBlock){
				thisBlock=new AWDBlock();
				_blockCache[asset]=thisBlock;
			}
			if (thisBlock.id>=0) return thisBlock.id;
			var returnID:uint=0;
			switch(true){
				case (asset is TextureVO):
					returnID=_encodeTexture(TextureVO(asset));
					if(_debug)trace("encoded texture = "+asset.name);
					break;
				case (asset is CubeTextureVO):
					returnID=_encodeCubeTextures(CubeTextureVO(asset));
					if(_debug)trace("encoded cubeTexture = "+asset.name);
					break;
				case (asset is ShadowMethodVO):
					returnID=_encodeShadowMethod(ShadowMethodVO(asset));
					if(_debug)trace("start encoding ShadowMethodVO = "+asset.name);
					break;
				case (asset is EffectVO):
					returnID=_encodeEffectMethod(EffectVO(asset));
					if(_debug)trace("start encoding EffectMethodVO = "+asset.name);
					break;
				case (asset is LightVO):
					returnID=_encodeLight(LightVO(asset));
					if(_debug)trace("start encoding LIGHT = "+asset.name);
					break;
				case (asset is LightPickerVO):
					returnID=_encodeLightPicker(LightPickerVO(asset));
					if(_debug)trace("start encoding LightPicker = "+asset.name);
					break;
				case (asset is MaterialVO):
					returnID=_encodeMaterial(MaterialVO(asset));
					if(_debug)trace("start encoding Material = "+asset.name);
					break;
				case (asset is GeometryVO):
					returnID=_encodeGeometry(GeometryVO(asset));
					if(_debug)trace("start encoding Geometry = "+asset.name);
					break;
				case (asset is AnimationNodeVO):
					returnID=_encodeAnimation(AnimationNodeVO(asset));
					if(_debug)trace("start encoding AnimationNode = "+asset.name);
					break;
				case (asset is AnimationSetVO):
					returnID=_encodeAnimationSet(AnimationSetVO(asset));
					if(_debug)trace("start encoding AnimationSetVO = "+asset.name);
					break;
				case (asset is SkeletonPoseVO):
					returnID=_encodeSkeletonPose(SkeletonPoseVO(asset));
					if(_debug)trace("start encoding SkeletonPoseVO = "+asset.name);
					break;
				case (asset is SkeletonVO):
					returnID=_encodeSkeleton(SkeletonVO(asset));
					if(_debug)trace("start encoding SkeletonVO = "+asset.name);
					break;
				case (asset is AnimatorVO):
					returnID=_encodeAnimator(AnimatorVO(asset));
					if(_debug)trace("start encoding AnimatorVO = "+asset.name);
					break;
				case (asset is TextureProjectorVO):
					returnID=_encodeTextureProjector(TextureProjectorVO(asset));
					if(_debug)trace("start encoding TextureProjectorVO = "+asset.name);
					break;
				default:
					if(_debug)trace("unknown asset");
					break;
			}
			thisBlock.id=returnID;
			return returnID;
		}
		// recursive function to encode all scene-graph objects
		private function _encodeChild(vo : AssetVO, parentID:uint = 0) : void
		{
			var thisBlock:AWDBlock=new AWDBlock();
			var newParentID:uint=0;
			switch (true){
				
				case (vo is LightVO):	
					if (!_exportedObjects[vo.id]){
						if(_debug)trace("LightVO = "+LightVO(vo).name+" parentID = "+parentID);
						_blockCache[vo]=thisBlock;
						newParentID=_encodeLight(LightVO(vo),parentID,true);
						thisBlock.id=newParentID;
						}
					else{
						if(_debug)trace("Create CommandBlock 'PutIntoSceneGraph' for LightVO = "+LightVO(vo).name+" | light ID = "+_exportedObjects[vo.id]+" parentID = "+parentID);
						_blockCache[vo]=thisBlock;
						newParentID=_encodeCommand(ObjectVO(vo),_exportedObjects[vo.id],parentID);
						thisBlock.id=newParentID;						
					}
					for each(var shadowMeth:ShadowMethodVO in LightVO(vo).shadowMethods){
						_getBlockIDorEncodeAsset(shadowMeth)
					}
					break;
				case (vo is TextureProjectorVO):			
					if (!_exportedObjects[vo.id]){
						if(_debug)trace("TextureProjectorVO = "+TextureProjectorVO(vo).name+" parentID = "+parentID);
						_blockCache[vo]=thisBlock;
						newParentID=_encodeTextureProjector(TextureProjectorVO(vo),parentID,true);
						thisBlock.id=newParentID;
					}
					else{
						if(_debug)trace("Create CommandBlock 'PutIntoSceneGraph' for TextureProjectorVO = "+TextureProjectorVO(vo).name+" | TextureProjector ID = "+_exportedObjects[vo.id]+" parentID = "+parentID);
						_blockCache[vo]=thisBlock;
						newParentID=_encodeCommand(ObjectVO(vo),_exportedObjects[vo.id],parentID);
						thisBlock.id=newParentID;						
					}
					break;
				case (vo is CameraVO):					
					if(_debug)trace("CameraVO = "+CameraVO(vo).name+" parentID = "+parentID);
					_blockCache[vo]=thisBlock;
					newParentID=_encodeCamera(CameraVO(vo),parentID);
					thisBlock.id=newParentID;
					break;
				case (vo is SkyBoxVO):					
					if(_debug)trace("SkyBoxVO = "+SkyBoxVO(vo).name+" parentID = "+parentID);
					_blockCache[vo]=thisBlock;
					newParentID=_encodeSkyBox(SkyBoxVO(vo));
					thisBlock.id=newParentID;
					break;
				case (vo is MeshVO):					
					if(_debug)trace("MeshVO = "+MeshVO(vo).name+" parentID = "+parentID+" | animator = "+MeshVO(vo).animator);
					
					if (MeshVO(vo).animator){
						if(!_translateAnimatiorToMesh[MeshVO(vo).animator.id])
							_translateAnimatiorToMesh[MeshVO(vo).animator.id]=new Vector.<MeshVO>;
						_translateAnimatiorToMesh[MeshVO(vo).animator.id].push(MeshVO(vo));						
						_translateAnimationSetToMesh[MeshVO(vo).animator.animationSet.id] = MeshVO(vo);						
						for each (var anim:AnimationNodeVO in MeshVO(vo).animator.animationSet.animations){
							_translateAnimationNodesToMesh[anim.id] = MeshVO(vo);
						}
					}					
					_blockCache[vo]=thisBlock;
					newParentID=_encodeMesh(MeshVO(vo),parentID);
					thisBlock.id=newParentID;
					break;
				case (vo is ContainerVO):
					_blockCache[vo]=thisBlock;
					if(_debug)trace("ContainerVO = "+ContainerVO(vo).name+" parentID = "+parentID);
					newParentID=_encodeContainer3D(ContainerVO(vo),parentID);
					thisBlock.id=newParentID;
					break;
				default:
					if(_debug)trace("try to export unknown type of Asset");
			}
			// if this is a Container, we recursivly encode the childs too:
			if (vo is ContainerVO){
				var child : AssetVO;
				for each (child in ContainerVO(vo).children) {
					_encodeChild(child as AssetVO,newParentID);
				}
			}
			
		}	
		
		
		// encodes the BlockHeader - is called for every block that gets enncoded
		private function _encodeBlockHeader(type : uint) : uint
		{
			_blockId++;
			_body.writeUnsignedInt(_blockId);
			_body.writeByte(0);
			_body.writeByte(type);
			
			var compressBool:int=0;
			var lzmaBool:int=0;
			if (_blockCompress>0){
				compressBool=1;
				if (_blockCompress>1){
					lzmaBool=1;}				
			}
			var bf:uint = 0;
			bf = 0<<7; //Set bit 8
			bf |= 0<<6; //Set bit 7
			bf |= 0<<5; //Set bit 6
			bf |= int(lzmaBool)<<4; //Set bit 5 - if true, LZMA is used for Compression
			bf |= int(compressBool)<<3; //Set bit 4 - if true, the block is compressed
			bf |= _propsStoragePrecision<<2; //Set bit 3 - reserved for propsStoragePrecision
			bf |= _geomStoragePrecision<<1; //Set bit 2 - reserved for geomStoragePrecision
			bf |= _matrixStoragePrecision;    //Set bit 1 - reserved for matrixStoragePrecisicn
			_body.writeByte(bf);
			_blockBody = new ByteArray();
			_blockBody.endian = Endian.LITTLE_ENDIAN;
			return _blockId;
		}
		
		
		// encode Geometry (id=1)
		private function _encodeGeometry(geom : GeometryVO) : uint
		{	
			var returnID:uint;
			if (geom.type!="Geometry"){
				returnID=_encodePrimitiveBlock(geom);
				return returnID;				
			}
			var sub:SubGeometryVO;
			returnID=_encodeBlockHeader(1);
			
			_blockBody.writeUTF(geom.name);
			_blockBody.writeShort(geom.subGeometries.length);
			
			_beginElement(); // Prop list
			if(geom.scaleU!=1) _encodeProperty(1,geom.scaleU, _geoNrType);
			if(geom.scaleV!=1) _encodeProperty(2,geom.scaleV, _geoNrType);
			_endElement(); // Prop list
			
			for each (sub in geom.subGeometries) {
				_beginElement(); // Sub-geom
				_beginElement(); // Prop list
				if(sub.scaleU!=1) _encodeProperty(1,sub.scaleU, _geoNrType);
				if(sub.scaleV!=1) _encodeProperty(2,sub.scaleV, _geoNrType);
				_endElement(); // Prop list
				
				_encodeStream(1, sub.vertexData, sub.vertexOffset, sub.vertexStride);
				_encodeStream(2, sub.indexData);
				var scaleU : Number = 1/sub.scaleU;
				var scaleV : Number = 1/sub.scaleV;
				if(sub.hasUVData)
					_encodeStream(3, sub.UVData, sub.UVOffset, sub.UVStride, scaleU, scaleV);
				if(sub.hasSecUVData)
					_encodeStream(8, sub.SecUVData, sub.SecUVOffset, sub.SecUVStride);
				if ( (_exportNormals) && (!sub.autoDerivedNormals) )	_encodeStream(4, sub.vertexNormalData, sub.vertexNormalOffset, sub.vertexNormalStride);
				if ( (_exportTangents) && (!sub.autoDerivedTangents) )	_encodeStream(5, sub.vertexTangentData, sub.vertexTangentOffset, sub.vertexTangentStride);
				if (sub.jointIndexData){
					_encodeStream(6, sub.jointIndexData, 0, 0);
				}
				if (sub.jointWeightsData){
					_encodeStream(7, sub.jointWeightsData, 0, 0);
				}			
				_endElement(); // Sub-geom
				
				_beginElement(); // User attr
				_endElement(); // User attr
			}
			
			_beginElement(); // User attr
			//_endoceExtraProperties(geom.extras);// no extra properties defined for geom right now
			_endElement(); // User attr
			
			_finalizeBlock();
			
			return returnID;
		}		
		
		// encode Primitve (id = 11)
		private function _encodePrimitiveBlock(geom:GeometryVO) : uint
		{
			var returnID:uint;
			returnID=_encodeBlockHeader(11);
			
			_blockBody.writeUTF(geom.name);
			switch(geom.type){ 
				case "PlaneGeometry":
					_blockBody.writeByte(1);
					_beginElement(); 
					if (geom.width!=100)_encodeProperty(101,geom.width, _geoNrType);
					if (geom.height!=100)_encodeProperty(102,geom.height, _geoNrType);
					if (geom.segmentsW!=1)_encodeProperty(301,geom.segmentsW, UINT16);		
					if (geom.segmentsH!=1)_encodeProperty(302,geom.segmentsH, UINT16);		
					if (!geom.yUp)_encodeProperty(701,geom.yUp, BOOL);		
					if (!geom.doubleSided)_encodeProperty(702,geom.doubleSided, BOOL);	
					if (geom.scaleU!=1) _encodeProperty(110,geom.scaleU, _geoNrType);
					if (geom.scaleV!=1) _encodeProperty(111,geom.scaleV, _geoNrType);
					_endElement(); 
					break;
				case "CubeGeometry":
					_blockBody.writeByte(2);
					_beginElement(); 
					if (geom.width!=100)_encodeProperty(101,geom.width, _geoNrType);
					if (geom.height!=100)_encodeProperty(102,geom.height, _geoNrType);
					if (geom.depth!=100)_encodeProperty(103,geom.depth, _geoNrType);
					if (geom.segmentsW!=1)_encodeProperty(301,geom.segmentsW, UINT16);
					if (geom.segmentsH!=1)_encodeProperty(302,geom.segmentsH, UINT16);
					if (geom.segmentsD!=1)_encodeProperty(303,geom.segmentsD, UINT16);
					if (!geom.tile6)_encodeProperty(701,geom.tile6, BOOL);
					if (geom.scaleU!=1) _encodeProperty(110,geom.scaleU, _geoNrType);
					if (geom.scaleV!=1) _encodeProperty(111,geom.scaleV, _geoNrType);
					_endElement(); 
					break;
				case "SphereGeometry":
					_blockBody.writeByte(3);
					_beginElement(); 
					if (geom.radius!=50)_encodeProperty(101,geom.radius, _geoNrType);
					if (geom.segmentsSW!=16)_encodeProperty(301,geom.segmentsSW, UINT16);
					if (geom.segmentsSH!=12)_encodeProperty(302,geom.segmentsSH, UINT16);		
					if (!geom.yUp)_encodeProperty(701,geom.yUp, BOOL);	
					if (geom.scaleU!=1) _encodeProperty(110,geom.scaleU, _geoNrType);
					if (geom.scaleV!=1) _encodeProperty(111,geom.scaleV, _geoNrType);		
					_endElement(); 
					break;
				case "CylinderGeometry":
					_blockBody.writeByte(4);
					_beginElement(); 
					if (geom.topRadius!=50)_encodeProperty(101,geom.topRadius, _geoNrType);
					if (geom.bottomRadius!=50)_encodeProperty(102,geom.bottomRadius, _geoNrType);
					if (geom.height!=100)_encodeProperty(103,geom.height, _geoNrType);
					if (geom.segmentsR!=16)_encodeProperty(301,geom.segmentsR, UINT16);
					if (geom.segmentsH!=1)_encodeProperty(302,geom.segmentsH, UINT16);		
					if (!geom.topClosed)_encodeProperty(701,Boolean(geom.topClosed), BOOL);		
					if (!geom.bottomClosed)_encodeProperty(702,Boolean(geom.bottomClosed), BOOL);		
					if (!geom.yUp)_encodeProperty(703,Boolean(geom.yUp), BOOL);	
					if (geom.scaleU!=1) _encodeProperty(110,geom.scaleU, _geoNrType);
					if (geom.scaleV!=1) _encodeProperty(111,geom.scaleV, _geoNrType);
					_endElement(); 
					break;
				case "ConeGeometry":
					_blockBody.writeByte(5);
					_beginElement(); 
					if (geom.radius!=50)_encodeProperty(101,geom.radius, _geoNrType);
					if (geom.height!=100)_encodeProperty(102,geom.height, _geoNrType);
					if (geom.segmentsR!=16)_encodeProperty(301,geom.segmentsR, UINT16);
					if (geom.segmentsH!=1)_encodeProperty(302,geom.segmentsH, UINT16);		
					if (!geom.bottomClosed)_encodeProperty(701,Boolean(geom.bottomClosed), BOOL);			
					if (!geom.yUp)_encodeProperty(702,Boolean(geom.yUp), BOOL);	
					if (geom.scaleU!=1) _encodeProperty(110,geom.scaleU, _geoNrType);
					if (geom.scaleV!=1) _encodeProperty(111,geom.scaleV, _geoNrType);
					_endElement(); 
					break;
				case "CapsuleGeometry":
					_blockBody.writeByte(6);
					_beginElement(); 
					if (geom.radius!=50)_encodeProperty(101,geom.radius, _geoNrType);
					if (geom.height!=100)_encodeProperty(102,geom.height, _geoNrType);
					if (geom.segmentsR!=16)_encodeProperty(301,geom.segmentsR, UINT16);
					if (geom.segmentsC!=12)_encodeProperty(302,geom.segmentsC, UINT16);		
					if (!geom.yUp)_encodeProperty(701,geom.yUp, BOOL);	
					if (geom.scaleU!=1) _encodeProperty(110,geom.scaleU, _geoNrType);
					if (geom.scaleV!=1) _encodeProperty(111,geom.scaleV, _geoNrType);
					_endElement(); 
					break;
				case "TorusGeometry":
					_blockBody.writeByte(7);
					_beginElement(); 
					if (geom.radius!=50)_encodeProperty(101,geom.radius, _geoNrType);
					if (geom.tubeRadius!=50)_encodeProperty(102,geom.tubeRadius, _geoNrType);
					if (geom.segmentsR!=16)_encodeProperty(301,geom.segmentsR, UINT16);
					if (geom.segmentsT!=8)_encodeProperty(302,geom.segmentsT, UINT16);		
					if (!geom.yUp)_encodeProperty(701,geom.yUp, BOOL);	
					if (geom.scaleU!=1) _encodeProperty(110,geom.scaleU, _geoNrType);
					if (geom.scaleV!=1) _encodeProperty(111,geom.scaleV, _geoNrType);
					_endElement(); 
					break;
				default:
					break;
			}				
			
			_beginElement(); // Attr list
			//_endoceExtraProperties(geom.extras);// no extra properties defined for geom right now
			_endElement(); // Attr list
			
			_finalizeBlock();
			
			return returnID;
		}
		
		// encode Container (id=22)
		private function _encodeContainer3D(container : ContainerVO, parentId:uint=0) : uint
		{			
			var returnID:uint=_encodeBlockHeader(22);
			
			_blockBody.writeUnsignedInt(parentId);
			_encodeMatrix3D(getTransformMatrix(container));
			_blockBody.writeUTF(container.name);
			// to do: add encoding of pivot.x/.y/.z + visibility + userData
			
			
			_beginElement(); // Prop list
			if(container.pivotX!=0)_encodeProperty(1,container.pivotX,  _matrixNrType);
			if(container.pivotY!=0)_encodeProperty(2,container.pivotY,  _matrixNrType);
			if(container.pivotZ!=0)_encodeProperty(3,container.pivotZ,  _matrixNrType);
			_endElement(); // Prop list
			
			_beginElement(); // Attr list
			_endoceExtraProperties(container.extras);
			_endElement(); // Attr list
			
			_finalizeBlock();
			
			return returnID;
		}
		
		
		// encode Mesh (id=23)
		private function _encodeMesh(mesh : MeshVO, parentId:uint=0) : uint
		{
			var i : uint;
			var geomId : uint;
			var materialIds : Vector.<uint>;
			var returnID:uint;
			
			geomId = _getBlockIDorEncodeAsset(mesh.geometry);
			materialIds=new Vector.<uint>;
			var subMeshVo:SubMeshVO;
			var uvTransform:Matrix=SubMeshVO(mesh.subMeshes[0]).uvTransform;
			var uvArray:Array=new Array();
			var storeUV:Boolean=false;
			var storeSubUV:Boolean=false;
			for each (subMeshVo in mesh.subMeshes){
				if(!storeSubUV){
					var subUvTransform:Matrix=subMeshVo.uvTransform;
					if (subUvTransform!=uvTransform)
						storeSubUV=true;
				}
				materialIds.push( _getBlockIDorEncodeAsset(subMeshVo.material));
			}
			if (storeSubUV){
				storeUV=true;
				for each (subMeshVo in mesh.subMeshes){
					var subUvTransform2:Matrix=subMeshVo.uvTransform;
					if (subUvTransform2==null)
						subUvTransform2=new Matrix();
					uvArray.push(subUvTransform2.a);
					uvArray.push(subUvTransform2.b);
					uvArray.push(subUvTransform2.c);
					uvArray.push(subUvTransform2.d);
					uvArray.push(subUvTransform2.tx);
					uvArray.push(subUvTransform2.ty);
				}				
			}
			else{
				var identityUV:Matrix=new Matrix();
				if (uvTransform){
					if(uvTransform!=identityUV){
						storeUV=true;
						uvArray.push(uvTransform.a);
						uvArray.push(uvTransform.b);
						uvArray.push(uvTransform.c);
						uvArray.push(uvTransform.d);
						uvArray.push(uvTransform.tx);
						uvArray.push(uvTransform.ty);	
					}
				}
			}		
			
			returnID=_encodeBlockHeader(23);
			
			_blockBody.writeUnsignedInt(parentId);
			_encodeMatrix3D(getTransformMatrix(mesh));
			_blockBody.writeUTF(mesh.name);
			_blockBody.writeUnsignedInt(geomId);
			
			_blockBody.writeShort(materialIds.length);
			for (i=0; i<materialIds.length; i++)
				_blockBody.writeUnsignedInt(materialIds[i]);
			
			_beginElement(); // Prop list
			if(mesh.pivotX!=0)_encodeProperty(1,mesh.pivotX,  _matrixNrType);
			if(mesh.pivotY!=0)_encodeProperty(2,mesh.pivotY,  _matrixNrType);
			if(mesh.pivotZ!=0)_encodeProperty(3,mesh.pivotZ,  _matrixNrType);
			if(!mesh.castsShadows)_encodeProperty(5,mesh.castsShadows,  BOOL);
			if (storeUV){
				if(storeSubUV)
					_encodeProperty(902,uvArray,  _propNrType);
				else
					_encodeProperty(901,uvArray,  _propNrType);
			}
			_endElement(); // Prop list			
			
			_beginElement(); // Attr list
			_endoceExtraProperties(mesh.extras);
			_endElement(); // Attr list
			
			_finalizeBlock();
			
			return returnID;
			
		}		
		
		// encode SkyBox (id=31)
		private function _encodeSkyBox(sky : SkyBoxVO) : uint
		{	
			var returnID:uint;
			var skyBoxTex:uint=_getBlockIDorEncodeAsset(sky.cubeMap);
			
			returnID=_encodeBlockHeader(31);
			
			_blockBody.writeUTF(sky.name);
			_blockBody.writeUnsignedInt(skyBoxTex);
			
			_beginElement(); // Prop list
			_endElement(); // Prop list
			
			_beginElement(); // User attr
			_endElement(); // User attr
			
			_finalizeBlock();
			
			return returnID;
		}		
		
		// encode LightBlock (id=41)
		private function _encodeLight(light:LightVO,parentId:uint=0,asSceneObject:Boolean=false) : uint
		{
			var returnID:int;
			var k:int;
			var lightType:uint=1;
			var radius:Number;
			var fallOff:Number;
			var lightMatrix:Matrix3D=getTransformMatrix(light);
			
			var dirVec:Vector3D=new Vector3D();
			if (light.type==LightVO.DIRECTIONAL){				
				
				dirVec.y = -Math.sin( light.elevationAngle*Math.PI/180);
				dirVec.x =  Math.sin(Math.PI/2 - light.elevationAngle*Math.PI/180)*Math.sin( light.azimuthAngle*Math.PI/180);
				dirVec.z =  Math.sin(Math.PI/2 - light.elevationAngle*Math.PI/180)*Math.cos( light.azimuthAngle*Math.PI/180);
			}
			
			returnID=_encodeBlockHeader(41);
			if (!asSceneObject){
				// to Do: store the global-transformation-matrix instead of the local, so the light appears at correct position, altough its not put at the correct scenegraph position
			}
			_exportedObjects[light.id]=returnID;
			_blockBody.writeUnsignedInt(parentId);//parent		
			_encodeMatrix3D(lightMatrix);//matrix
			_blockBody.writeUTF(light.name);//name
			
			if (light.type==LightVO.POINT){
				if(_debug)trace("start encode PointLight = "+light.name);
				if(light.radius!=90000)	radius=light.radius;
				if(light.fallOff!=100000)	fallOff=light.fallOff;
			}
			if (light.type==LightVO.DIRECTIONAL){
				if(_debug)trace("start encode DirectionalLight = "+light.name);	
				lightType=2;
			}					
			
			_blockBody.writeByte(lightType); // lightType	
			
			_beginElement(); // start lights-prop list
			
			if(radius){_encodeProperty(1,radius, _propNrType);}//radius
			if(fallOff){_encodeProperty(2,fallOff, _propNrType);}//fallOff
			if(light.color!=0xffffff){_encodeProperty(3,light.color, COLOR);}//color
			if(light.specular!=1){_encodeProperty(4,light.specular, _propNrType);}//specular
			if(light.diffuse!=1){_encodeProperty(5,light.diffuse, _propNrType);}//diffuse
			if(light.ambientColor!=0xffffff){_encodeProperty(7,light.ambientColor, COLOR);}//ambientColor
			if(light.ambient!=0){_encodeProperty(8,light.ambient, _propNrType);}//ambient-level
			if (light.type==LightVO.DIRECTIONAL){
				_encodeProperty(21,dirVec.x, _matrixNrType);//azimuthAngle
				_encodeProperty(22,dirVec.y, _matrixNrType);//azimuthAngle
				_encodeProperty(23,dirVec.z, _matrixNrType);//azimuthAngle
			}		
			if(light.pivotX!=0)_encodeProperty(24,light.pivotX,  _matrixNrType);
			if(light.pivotY!=0)_encodeProperty(25,light.pivotY,  _matrixNrType);
			if(light.pivotZ!=0)_encodeProperty(26,light.pivotZ,  _matrixNrType);
			// just add the shadowmapper as max 3 light-properties (shadowMapper-Type + shadowmapper-properties)	
			if((light.castsShadows)&&(light.shadowMapper)){		
				var mapperVO:ShadowMapperVO=light.shadowMapper;
				switch(mapperVO.type){ 
					case "NearDirectionalShadowMapper":
						_encodeProperty(9,2, UINT8);
						if(mapperVO.depthMapSize!=2048)_encodeProperty(10,_depthSizeDic[mapperVO.depthMapSize], UINT8);
						if(mapperVO.coverage!=0.5)_encodeProperty(11,mapperVO.coverage, _propNrType);
						break;
					case "DirectionalShadowMapper":
						_encodeProperty(9,1, UINT8);
						if(mapperVO.depthMapSize!=2048)_encodeProperty(10,_depthSizeDic[mapperVO.depthMapSize], UINT8);
						break;
					case "CascadeShadowMapper":
						_encodeProperty(9,3, UINT8);
						if(mapperVO.depthMapSize!=2048)_encodeProperty(10,_depthSizeDic[mapperVO.depthMapSize], UINT8);
						if(mapperVO.numCascades!=3)_encodeProperty(12,mapperVO.numCascades, UINT16);
						break;
					case "CubeMapShadowMapper":
						_encodeProperty(9,4, UINT8);
						if(mapperVO.depthMapSizeCube!=512)_encodeProperty(10,_depthSizeDic[mapperVO.depthMapSizeCube], UINT8);
						break;
				}
			}			
			_endElement(); // prop list			
						
			_beginElement(); // Attr list
			_endoceExtraProperties(light.extras);
			_endElement(); // Attr list
			
			_finalizeBlock();
			
			if(_debug)trace("light = "+light.name + " has been encoded successfully.");	
			return returnID;
		}
		
		// encode Camera (blockID = 42)
		private function _encodeCamera(_cam:CameraVO,parentId:uint) : uint
		{
			var returnID:uint;
			
			returnID=_encodeBlockHeader(42);
			var lens:LensVO=_cam.lens;
			
			_blockBody.writeUnsignedInt(parentId);
			_encodeMatrix3D(getTransformMatrix(_cam));
			_blockBody.writeUTF(_cam.name);
			_blockBody.writeByte(0);	
			_blockBody.writeShort(1);				
			
			switch(lens.type){
				case "PerspectiveLens":
					_blockBody.writeShort(5001);
					_beginElement(); // Lens list
					if(lens.value!=60)_encodeProperty(101,lens.value,  _propNrType);		
					break;
				case "OrthographicLens":
					_blockBody.writeShort(5002);
					_beginElement(); // Lens list
					if(lens.value!=500)_encodeProperty(101,lens.value,  _propNrType);	
					break;
				case "OrthographicOffCenterLens":
					_blockBody.writeShort(5003);
					_beginElement(); // Lens list
					if(lens.minX!=0)_encodeProperty(101,lens.minX,  _propNrType);
					if(lens.maxX!=0)_encodeProperty(102,lens.maxX,  _propNrType);
					if(lens.minY!=0)_encodeProperty(103,lens.minY,  _propNrType);
					if(lens.maxY!=0)_encodeProperty(104,lens.maxY,  _propNrType);
					break;
			}
			_endElement(); // Prop list
			
			_beginElement(); // Prop list
			if(_cam.pivotX!=0)_encodeProperty(1,_cam.pivotX,  _matrixNrType);
			if(_cam.pivotY!=0)_encodeProperty(2,_cam.pivotY,  _matrixNrType);
			if(_cam.pivotZ!=0)_encodeProperty(3,_cam.pivotZ,  _matrixNrType);
			if(lens.near!=20)_encodeProperty(101,lens.near,  _propNrType);
			if(lens.far!=3000)_encodeProperty(102,lens.far,  _propNrType);
			_endElement(); // Prop list
			
			_beginElement(); // Attr list
			_endoceExtraProperties(_cam.extras);
			_endElement(); // Attr list
			
			_finalizeBlock();			
			
			return returnID;
		}
		
		// encode Textureprojector (id=43)
		private function _encodeTextureProjector(texProject :TextureProjectorVO,parentId:uint=0,asSceneObject:Boolean=false) : uint
		{
			var returnID:uint;
			var texID:uint;
			texID=_getBlockIDorEncodeAsset(texProject.texture);
			
			returnID=_encodeBlockHeader(43);
			
			_exportedObjects[texProject.id]=returnID;
			
			_blockBody.writeUnsignedInt(parentId);
			_encodeMatrix3D(getTransformMatrix(texProject));
			_blockBody.writeUTF(texProject.name);
			
			_blockBody.writeUnsignedInt(texID);
			_blockBody.writeFloat(texProject.aspectRatio);
			_blockBody.writeFloat(texProject.fov);
			
			_beginElement(); // Prop list
			if(texProject.pivotX!=0)_encodeProperty(1,texProject.pivotX,  _matrixNrType);
			if(texProject.pivotY!=0)_encodeProperty(2,texProject.pivotY,  _matrixNrType);
			if(texProject.pivotZ!=0)_encodeProperty(3,texProject.pivotZ,  _matrixNrType);
			_endElement(); // Prop list
			
			_beginElement(); // Attr list
			_endoceExtraProperties(texProject.extras);
			_endElement(); // Attr list
			
			_finalizeBlock();
			
			return returnID;
		}
		// encode LightPicker (id=51)
		private function _encodeLightPicker(_lp:LightPickerVO) : uint
		{
			var returnID:uint;
			var lightIDs:Vector.<int>=new Vector.<int>;
			var k:int;
			for each(var lightAssetVO:AssetVO in _lp.lights){
				lightIDs.push(_getBlockIDorEncodeAsset(lightAssetVO));
			}			
			
			returnID=_encodeBlockHeader(51);
			
			_blockBody.writeUTF(_lp.name);
			_blockBody.writeShort(_lp.lights.length);	//num of lights
			for (k=0;k<_lp.lights.length;k++)
				_blockBody.writeUnsignedInt(lightIDs[k]);	//light-ids
			
			_beginElement(); // Attr list
			_endElement(); // Attr list
			
			_finalizeBlock();
			
			return returnID;
		}
		
		// encodes a materialBlock (id=81)
		private function _encodeMaterial(mtl :MaterialVO) : uint
		{
			var returnID:uint;
			// properties:
			var matType:int=1;			
			
			// optional properties:
			var color:uint=0xcccccc;//1
			var texture:int=-1;//2
			var normalTexture:int=0;//3
			var spezialType:uint=0;//4
			var smooth:Boolean=true;//5
			var mipmap:Boolean=true;//6
			var bothSides:Boolean=false;//7
			var alphaPremultiplied:Boolean=false;//8
			var blendMode:uint=0;//9
			var alpha:Number=1.0;//10
			var alphaBlending:Boolean=false;//11
			var alphaThreshold:Number=0;//12
			var repeat:Boolean=true;//13
			//var diffuse-Level:Number;//14
			var ambient:uint=1.0;//15
			var ambientColor:uint=0xffffff;//16
			var ambientTexture:int=-1;//17
			var specular:Number=1.0;//18
			var gloss:Number=50;//19
			var specularColor:uint=0xffffff;//20
			var specularTexture:uint=0;//21
			var lightPicker:int=0;//22	
			
			var allMethods:Vector.<AWDmethod>=_encodeAllShadingMethods(mtl);
			if (mtl.diffuseTexture) texture=_getBlockIDorEncodeAsset(mtl.diffuseTexture);
			if (mtl.ambientTexture) ambientTexture=_getBlockIDorEncodeAsset(mtl.ambientTexture);	
			if ((texture>=0)||(ambientTexture>=0)) matType=2;	
			if (matType==1) color=mtl.diffuseColor;	
			
			if (mtl.type==MaterialVO.SINGLEPASS){
				alpha=mtl.alpha;
				alphaBlending=mtl.alphaBlending;
			}
			else{
				spezialType=1;
			}
			
			alphaThreshold=mtl.alphaThreshold;
			ambient=mtl.ambientLevel;
			ambientColor=mtl.ambientColor;	
			specular=mtl.specularLevel;	
			gloss=mtl.specularGloss;	
			specularColor=mtl.specularColor;	
			
			if (mtl.normalTexture)	normalTexture=_getBlockIDorEncodeAsset(mtl.normalTexture);
			if (mtl.specularTexture)	specularTexture=_getBlockIDorEncodeAsset(mtl.specularTexture);
			
			if (mtl.lightPicker)	lightPicker=_getBlockIDorEncodeAsset(mtl.lightPicker);
			
			smooth=mtl.smooth;
			mipmap=mtl.mipmap;
			bothSides=mtl.bothSides;
			repeat=mtl.repeat;
			alphaPremultiplied=mtl.alphaPremultiplied;		
			blendMode=blendModeDic[mtl.blendMode];
			if ((blendMode!=1)&&(blendMode!=2)&&(blendMode!=8)&&(blendMode!=10))	blendMode=0;
						
			returnID=_encodeBlockHeader(81);
			
			_blockBody.writeUTF(mtl.name);
			_blockBody.writeByte(matType);	//materialType			
			_blockBody.writeByte(allMethods.length); //num of methods
			
			// Property list
			_beginElement(); // Prop list
			if (color!=0xcccccc){	_encodeProperty(1,color, COLOR);}//color
			if (texture>0){_encodeProperty(2,texture, BADDR);}//texture
			if (normalTexture>0){_encodeProperty(3,normalTexture, BADDR);}//normalMap 
			if (spezialType){_encodeProperty(4,spezialType, UINT8);}// multi/singlepass	
			if (!smooth){_encodeProperty(5, smooth, BOOL);} // smooth
			if (!mipmap){_encodeProperty(6, mipmap, BOOL);} // mipmap
			if (bothSides){_encodeProperty(7, bothSides, BOOL);} // bothsides
			if (alphaPremultiplied){_encodeProperty(8, alphaPremultiplied, BOOL);} // pre-multiplied				
			if (blendMode>0){_encodeProperty(9, blendMode, UINT8);} // BlendMode
			if (alpha!=1.0){_encodeProperty(10, alpha, _propNrType);}// alpha
			if (alphaBlending){_encodeProperty(11, alphaBlending, BOOL);}// alphaBlending
			if (alphaThreshold>0){_encodeProperty(12, alphaThreshold, _propNrType);}// alphaThreshold
			if (repeat){_encodeProperty(13, repeat, BOOL);}// repeat
			//if (diffuse){_encodeProperty(14, diffuse, FLOAT32);}// diffuse-level (might come in later version)
			if (ambient!=1){_encodeProperty(15, ambient, _propNrType);}// ambient-level
			if (ambientColor!=0xffffff){_encodeProperty(16, ambientColor, COLOR);}// ambient-color
			if (ambientTexture>0){_encodeProperty(17, ambientTexture, BADDR);}//ambientMap 		
			if (specular!=1){_encodeProperty(18, specular, _propNrType);}// specular-level
			if (gloss!=50){_encodeProperty(19, gloss, _propNrType);}// specular-gloss 
			if (specularColor!=0xffffff){_encodeProperty(20, specularColor, COLOR);}// specular-color
			if (specularTexture>0){_encodeProperty(21, specularTexture, BADDR);}//specularMap 
			if (lightPicker>0){_encodeProperty(22, lightPicker, BADDR);}//lightPicker
			_endElement(); // Prop list			
			
			// _encode all previous stored methods.
			for (var i:int=0;i<allMethods.length;i++){
				if(_debug)trace("allMethods[i]._id "+allMethods[i]._id);
				_encodeMethod(allMethods[i]._id,allMethods[i]._ids,allMethods[i]._values,allMethods[i]._defaultValues , allMethods[i]._types);
			}
			
			_beginElement(); // Attr list
			_endElement(); // Attr list
			
			_finalizeBlock();
			
			return returnID;
		}
		
		
// start of  Material - Methods Helpers		
		//encode all methods of a material. effectmethods and shadowMapmethods are stored in a own block
		private function _encodeAllShadingMethods(mat:MaterialVO) : Vector.<AWDmethod>
		{
			var materialMethods:Vector.<AWDmethod>=new Vector.<AWDmethod>;
			
			_encodeDiffuseMethod(mat.diffuseMethod,materialMethods);
			_encodeSpecularMethod(mat.specularMethod,materialMethods);
			_encodeAmbientMethod(mat.ambientMethod,materialMethods);
			_encodeNormalMethod(mat.normalMethod,materialMethods);
			if(_debug)trace("ShadowMethod= "+mat.shadowMethod);
			if(_debug)trace("ShadowMethod ID= "+_getBlockIDorEncodeAsset(mat.shadowMethod));
			if (mat.shadowMethod)materialMethods.push(new AWDmethod(998, [1], [_getBlockIDorEncodeAsset(mat.shadowMethod)], [0], [BADDR]));
			for each (var effectMethVO:EffectVO in mat.effectMethods){
				materialMethods.push(new AWDmethod(999, [1], [_getBlockIDorEncodeAsset(effectMethVO)], [0], [BADDR]));// to do - check the correct id for a "shared methdod block"-method 
			}
			return materialMethods;
		}
		
		// create the AmbientMethod as a AWDMethod (if its not the BasicDiffuseMethod)
		private function _encodeAmbientMethod(ambientMethVO:ShadingMethodVO,materialMethods:Vector.<AWDmethod>) : void
		{
			if(_debug)trace("ambientMethVO = "+ambientMethVO.type);
			switch(ambientMethVO.type){ 
				case "EnvMapAmbientMethod":
					materialMethods.push(new AWDmethod(1, [1], [_getBlockIDorEncodeAsset(ambientMethVO.envMap)], [0], [BADDR]));
					break;
			}
		}
		
		
		// create the DiffuseMethod as a AWDMethod (if its not the BasicDiffuseMethod)
		private function _encodeDiffuseMethod(diffuseMethVO:ShadingMethodVO, materialMethods:Vector.<AWDmethod>) : void
		{
			if(_debug)trace("diffuseMethVO = "+diffuseMethVO.type);
			var texID:uint;
			switch(diffuseMethVO.type){ 				
				case "LightMapDiffuseMethod":
					_encodeDiffuseMethod(diffuseMethVO.baseMethod,materialMethods);
					var lightMapBlendMode1:uint=blendModeDic[diffuseMethVO.blendMode];
					if ((lightMapBlendMode1!=1)&&(lightMapBlendMode1!=10))lightMapBlendMode1=10;
					texID=_getBlockIDorEncodeAsset(diffuseMethVO.texture);
					materialMethods.push(new AWDmethod(54, [401,1], [ lightMapBlendMode1, texID], [10], [UINT8,BADDR]));
					break;
				case "CelDiffuseMethod":
					_encodeDiffuseMethod(diffuseMethVO.baseMethod,materialMethods);
					materialMethods.push(new AWDmethod(55, [401,101], [diffuseMethVO.value, diffuseMethVO.smoothness], [3,0.1], [UINT8,_propNrType]));
					break;
				case "SubsurfaceScatteringDiffuseMethod":
					_encodeDiffuseMethod(diffuseMethVO.baseMethod,materialMethods);
					materialMethods.push(new AWDmethod(56, [101,102,601], [diffuseMethVO.scattering,diffuseMethVO.translucency,diffuseMethVO.scatterColor], [0.2,1,0xffffff], [_propNrType,_propNrType,COLOR]));
					break;
				case "WrapDiffuseMethod":
					materialMethods.push(new AWDmethod(53, [101], [diffuseMethVO.value], [0.5], [_propNrType]));
					break;
				case "GradientDiffuseMethod":
					texID=_getBlockIDorEncodeAsset(diffuseMethVO.texture);
					materialMethods.push(new AWDmethod(52, [1], [texID], [0], [BADDR]));
					break;
			}			
		}		
		// create the SpecularMethod as a AWDMethod (if its not the BasicDiffuseMethod)
		private function _encodeSpecularMethod(speculareMethVO:ShadingMethodVO, materialMethods:Vector.<AWDmethod>) : void
		{
			if(_debug)trace("speculareMethVO = "+speculareMethVO.type);
			switch(speculareMethVO.type){ 
				case "CelSpecularMethod":	
					_encodeSpecularMethod(speculareMethVO.baseMethod,materialMethods);
					materialMethods.push(new AWDmethod(103, [101,102], [speculareMethVO.value, speculareMethVO.smoothness], [0.5,0.1], [_propNrType,_propNrType]));
					break;
				case "FresnelSpecularMethod":	
					_encodeSpecularMethod(speculareMethVO.baseMethod,materialMethods);
					materialMethods.push(new AWDmethod(104, [701,101,102], [speculareMethVO.basedOnSurface, speculareMethVO.fresnelPower,speculareMethVO.value], [true,0.5,0.1], [BOOL,_propNrType,_propNrType]));
					break;
				case "AnisotropicSpecularMethod":	
					materialMethods.push(new AWDmethod(101, [], [], [], []));
					break;
				case "PhongSpecularMethod":	
					materialMethods.push(new AWDmethod(102, [], [], [], []));
					break;
			}
		}
		// create the NormalMethod as a AWDMethod (if its not the BasicDiffuseMethod)
		private function _encodeNormalMethod(normalMethVO:ShadingMethodVO, materialMethods:Vector.<AWDmethod>) : void
		{
			if(_debug)trace("normalMethVO = "+normalMethVO.type);
			switch(normalMethVO.type){ 
				case "SimpleWaterNormalMethod":
					materialMethods.push(new AWDmethod(152, [1], [_getBlockIDorEncodeAsset(normalMethVO.texture)], [0], [BADDR]));
					break;
				/*case "HeightMapNormalMethod":
				//var worldSize:Vector3D=HeightMapNormalMethod(normalMeth).worldSize;
				//materialMethods.push(new AWDmethod(151, [1108,1109,1110], [worldSize.x, worldSize.y,worldSize.z], [5,5,5], [FLOAT32,FLOAT32,FLOAT32]));
				break;*/
			}
		}
// end of  Material - Methods Helpers
		
	
// start of textures
		// encode TextureBlock (id=82)
		private function _encodeTexture(tex:TextureVO) : uint
		{
			var returnID:uint=_encodeBlockHeader(82);
			
			_blockBody.writeUTF(tex.name);
			
			if (_embedtextures){				
				_blockBody.writeByte(1);//embed
				var ba : ByteArray = _encodeBitmap(tex.bitmapData)[0];	
				_blockBody.writeUnsignedInt(ba.length);
				_blockBody.writeBytes(ba);
			}
			else {
				_blockBody.writeByte(0);//external
				var extension:String=".jpg";
				if(bitMapHasTransparency(tex.bitmapData,tex.bitmapData.rect.width,tex.bitmapData.rect.height))
					extension=".png";
				var texturePath:String="textures/"+getFileName(tex.name, extension);
				_writeString(texturePath);				
				}
			
			_beginElement(); // Properties (empty)
			_endElement(); // Properties
			
			_beginElement(); // Attributes (empty)
			_endElement(); // Attributes
			
			_finalizeBlock();
			
			if(_debug)trace("texture = "+tex.name + " has been encoded successfully!");
			return returnID;
			
		}
		private function getFileName(fullPath: String, extension:String, cubeMapPrefix:String="") : String
		{
			var fSlash: int = fullPath.lastIndexOf("/");
			var bSlash: int = fullPath.lastIndexOf("\\"); // reason for the double slash is just to escape the slash so it doesn't escape the quote!!!
			var slashIndex: int = fSlash > bSlash ? fSlash : bSlash;
			var thisname:String=fullPath.substr(slashIndex + 1);			
			if(thisname.toLowerCase().lastIndexOf(extension) != thisname.length - extension.length)
				thisname+=cubeMapPrefix+extension
			thisname = thisname.replace(" ", "%20");
			return thisname
		}
		// encode TextureBlock (id=83)
		private function _encodeCubeTextures(cubeTexture:CubeTextureVO) : uint
		{
			
			var returnID:uint = _encodeBlockHeader(83);
			
			if (_embedtextures){	
				_blockBody.writeByte(1);// embed;
				_blockBody.writeUTF(cubeTexture.name);
				var id_posX : ByteArray = _encodeBitmap(cubeTexture.positiveX)[0];	
				var id_negX : ByteArray = _encodeBitmap(cubeTexture.negativeX)[0];	
				var id_posY : ByteArray = _encodeBitmap(cubeTexture.positiveY)[0];	
				var id_negY : ByteArray = _encodeBitmap(cubeTexture.negativeY)[0];	
				var id_posZ : ByteArray = _encodeBitmap(cubeTexture.positiveZ)[0];	
				var id_negZ : ByteArray = _encodeBitmap(cubeTexture.negativeZ)[0];				
				// write all encodedBitMaps into the file
				_blockBody.writeUnsignedInt(id_posX.length);
				_blockBody.writeBytes(id_posX);
				_blockBody.writeUnsignedInt(id_negX.length);
				_blockBody.writeBytes(id_negX);
				_blockBody.writeUnsignedInt(id_posY.length);
				_blockBody.writeBytes(id_posY);
				_blockBody.writeUnsignedInt(id_negY.length);
				_blockBody.writeBytes(id_negY);
				_blockBody.writeUnsignedInt(id_posZ.length);
				_blockBody.writeBytes(id_posZ);
				_blockBody.writeUnsignedInt(id_negZ.length);
				_blockBody.writeBytes(id_negZ);	
			}
			else{
				var texturePath:String;
				_blockBody.writeByte(0);//external
				_blockBody.writeUTF(cubeTexture.name);
				var extension:String=".jpg";
				if(bitMapHasTransparency(cubeTexture.positiveX,cubeTexture.positiveX.rect.width,cubeTexture.positiveX.rect.height))
					extension=".png";
				texturePath="textures/"+getFileName(cubeTexture.name,extension,"_posX.");
				_writeString(texturePath);	
				
				extension=".jpg";
				if(bitMapHasTransparency(cubeTexture.negativeX,cubeTexture.negativeX.rect.width,cubeTexture.negativeX.rect.height))
					extension=".png";
				texturePath="textures/"+getFileName(cubeTexture.name,extension,"_negX.");
				_writeString(texturePath);
				
				extension=".jpg";
				if(bitMapHasTransparency(cubeTexture.positiveY,cubeTexture.positiveY.rect.width,cubeTexture.positiveY.rect.height))
					extension=".png";
				_writeString(texturePath);	
				
				extension=".jpg";
				if(bitMapHasTransparency(cubeTexture.negativeY,cubeTexture.negativeY.rect.width,cubeTexture.negativeY.rect.height))
					extension=".png";
				texturePath="textures/"+getFileName(cubeTexture.name,extension,"_negY.");
				_writeString(texturePath);
				
				extension=".jpg";
				if(bitMapHasTransparency(cubeTexture.positiveZ,cubeTexture.positiveZ.rect.width,cubeTexture.positiveZ.rect.height))
					extension=".png";
				texturePath="textures/"+getFileName(cubeTexture.name,extension,"_posZ.");
				_writeString(texturePath);
				
				extension=".jpg";
				if(bitMapHasTransparency(cubeTexture.negativeZ,cubeTexture.negativeZ.rect.width,cubeTexture.negativeZ.rect.height))
					extension=".png";	
				texturePath="textures/"+getFileName(cubeTexture.name,extension,"_negZ.");
				_writeString(texturePath);
				
				
			}
			
			_beginElement(); // Properties (empty)
			_endElement(); // Properties
			
			_beginElement(); // Attributes (empty)
			_endElement(); // Attributes
			
			_finalizeBlock();
			
			
			if(_debug)trace("cubeTexture = "+cubeTexture.name + " has been encoded successfully!");
			return returnID;
		}
// end of textures		
		
		// Creates a EffectMethod-AWDBlock	(id=91) 			
		private function _encodeSharedMethodBlock(name:String, id:int, idsVec : Array, valuesAr : Array, defaultValuesAr : Array, typesVec : Array) : uint
		{
			
			var returnID:uint=_encodeBlockHeader(91);
			
			_blockBody.writeUTF(name);			
			
			_encodeMethod( id, idsVec, valuesAr, defaultValuesAr, typesVec);
			
			_beginElement(); // Attributes (empty)
			_endElement(); // Attributes
			
			_finalizeBlock();
			
			if(_debug)trace("SharedMethod = "+ name + " has been encoded successfully!");
			return returnID
		}		
		private function _encodeEffectMethod(methVO:EffectVO) : uint
		{
			var returnID:uint=0;
			var cubeTexID:uint;
			var texID:uint;
			var texProjectorID:uint;
			if(_debug)trace("methVO.type = "+methVO.type);
			switch(methVO.type)
			{ 
				case "ColorMatrixMethod"://EffectMethodVO.COLOR_MATRIX:
					var colorMatrixAsVector:Array=new Array();
					colorMatrixAsVector.push(methVO.r);//0
					colorMatrixAsVector.push(methVO.g);//1
					colorMatrixAsVector.push(methVO.b);//2
					colorMatrixAsVector.push(methVO.a);//3
					colorMatrixAsVector.push(methVO.rO);//4
					colorMatrixAsVector.push(methVO.rG);//5
					colorMatrixAsVector.push(methVO.gG);//6
					colorMatrixAsVector.push(methVO.bG);//7
					colorMatrixAsVector.push(methVO.aG);//8
					colorMatrixAsVector.push(methVO.gO);//9
					colorMatrixAsVector.push(methVO.rB);//10
					colorMatrixAsVector.push(methVO.gB);//11
					colorMatrixAsVector.push(methVO.bB);//12
					colorMatrixAsVector.push(methVO.aB);//13
					colorMatrixAsVector.push(methVO.bO);//14
					colorMatrixAsVector.push(methVO.rA);//15
					colorMatrixAsVector.push(methVO.gA);//16
					colorMatrixAsVector.push(methVO.bA);//17
					colorMatrixAsVector.push(methVO.aA);//18
					colorMatrixAsVector.push(methVO.aO);//19
					
					var colorMatrixAsVectorDefault:Array= new Array(0,0,0,1, 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1);
					returnID=_encodeSharedMethodBlock(methVO.name,401, [101], [colorMatrixAsVector], [colorMatrixAsVectorDefault], [_propNrType]);
					break;
				case "ColorTransformMethod"://EffectMethodVO.COLOR_TRANSFORM:
					var offSetColor:uint= methVO.aO << 24 | methVO.rO << 16 | methVO.gO << 8 | methVO.bO;
					returnID=_encodeSharedMethodBlock(methVO.name,402, [101,102,103,104,601], [methVO.a,methVO.r,methVO.g,methVO.b,offSetColor], [1,1,1,1,0x00000000], [_propNrType,_propNrType,_propNrType,_propNrType,COLOR]);
					break;
				case "EnvMapMethod"://EffectMethodVO.ENV_MAP:
					cubeTexID=_getBlockIDorEncodeAsset(methVO.cubeTexture);
					texID=_getBlockIDorEncodeAsset(methVO.texture);
					returnID=_encodeSharedMethodBlock(methVO.name,403, [1,101,2], [cubeTexID,methVO.alpha,texID], [0,1,0], [BADDR,_propNrType,BADDR]);
					break;
				case "LightMapMethod"://EffectMethodVO.LIGHT_MAP:
					texID=_getBlockIDorEncodeAsset(methVO.texture);	
					returnID=_encodeSharedMethodBlock(methVO.name,404, [401,1, 701], [blendModeDic[methVO.mode],texID, methVO.useSecondaryUV], [10,0, false], [UINT8,BADDR, BOOL]);
					break;
				case "ProjectiveTextureMethod":
					texID=_getBlockIDorEncodeAsset(methVO.textureProjector);
					returnID=_encodeSharedMethodBlock(methVO.name,405, [1,401], [texID,blendModeDic[methVO.mode]], [0,10], [BADDR,UINT8]);
					break;
				case "RimLightMethod"://EffectMethodVO.RIM_LIGHT:
					returnID=_encodeSharedMethodBlock(methVO.name,406, [601,101,102], [methVO.color,methVO.strength,methVO.power], [0xffffff,0.4,2], [COLOR,_propNrType,_propNrType]);
					break;
				case "AlphaMaskMethod"://EffectMethodVO.ALPHA_MASK:
					texID=_getBlockIDorEncodeAsset(methVO.texture);
					returnID=_encodeSharedMethodBlock(methVO.name,407, [701,1], [methVO.useSecondaryUV,texID], [false,0], [BOOL,BADDR]);
					break;
				case "RefractionEnvMapMethod"://EffectMethodVO.REFRACTION_ENV_MAP:
					cubeTexID=_getBlockIDorEncodeAsset(methVO.cubeTexture);
					texID=_getBlockIDorEncodeAsset(methVO.texture);
					returnID=_encodeSharedMethodBlock(methVO.name,408, [1,101,102,103,104,105], [cubeTexID, methVO.refraction, methVO.r, methVO.g, methVO.b, methVO.alpha], [0,0.1,0.01,0.01,0.01,1], [BADDR,_propNrType,_propNrType,_propNrType,_propNrType,_propNrType]);
					break;
				case "OutlineMethod"://EffectMethodVO.OUTLINE:
					returnID=_encodeSharedMethodBlock(methVO.name,409, [601,101,701,702], [methVO.color, methVO.size, methVO.showInnerLines, methVO.dedicatedMesh], [0x00000000,1,true,false], [COLOR,_propNrType,BOOL,BOOL]);
					break;
				case "FresnelEnvMapMethod"://EffectMethodVO.FRESNEL_ENV_MAP:
					cubeTexID=_getBlockIDorEncodeAsset(methVO.cubeTexture);
					returnID=_encodeSharedMethodBlock(methVO.name, 410, [1,101], [cubeTexID, methVO.alpha], [0, 1], [BADDR, _propNrType]);
					break;
				case "FogMethod"://EffectMethodVO.FOG:
					returnID=_encodeSharedMethodBlock(methVO.name, 411, [101,102,601], [methVO.minDistance, methVO.maxDistance, methVO.color], [0, 1000, 0x808080], [_propNrType, _propNrType, COLOR]);
					break;
				// this methods are available in away3d, but not saved in awd atm:
				//EffectMethodVO.FRESNEL_PLANAR_REFLECTION
				//EffectMethodVO.PLANAR_REFLECTION
			}	
			return returnID;
		}
		
		
		// Creates a ShadowMapMethod-AWDBlock (id=92)	
		private function _encodeShadowMapMethodBlock(methVO:ShadowMethodVO, id:int, idsVec : Array, valuesAr : Array, defaultValuesAr : Array, typesVec : Array) : uint
		{
			var lightID:uint=0;
			if (!_shadowMethodsToLightsDic[methVO])
				trace("unexpected error, could not find light for Shadowmethod");
			else
				lightID=_getBlockIDorEncodeAsset(_shadowMethodsToLightsDic[methVO]);
			
			var returnID:uint=_encodeBlockHeader(92);
			
			_blockBody.writeUTF(methVO.name);				
			_blockBody.writeUnsignedInt(lightID);			
			
			_encodeMethod( id, idsVec, valuesAr, defaultValuesAr, typesVec);
			
			_beginElement(); // Attributes (empty)
			_endElement(); // Attributes
			
			_finalizeBlock();
			
			if(_debug)trace("ShadowMethod = "+ methVO.name + " has been encoded successfully!");
			return returnID
		}
		// creates a new SharedBlock for a ShadowMethod.
		private function _encodeShadowMethod(methVO:ShadowMethodVO) : uint
		{
			var returnID:uint=0;
			var baseID:uint;
			switch(methVO.type)
			{ 				
				case ShadowMethodVO.FILTERED_SHADOW_MAP_METHOD:		
					returnID=_encodeShadowMapMethodBlock(methVO, 1101, [101,102], [methVO.alpha,methVO.epsilon], [1,0.002], [_propNrType,_propNrType]);			
					break;	
				case ShadowMethodVO.DITHERED_SHADOW_MAP_METHOD:	
					returnID=_encodeShadowMapMethodBlock(methVO, 1102, [101,102,201,103], [methVO.alpha,methVO.epsilon,methVO.samples, methVO.range], [1,0.002,5,1], [_propNrType,_propNrType,UINT32,_propNrType]);				
					break;
				case ShadowMethodVO.SOFT_SHADOW_MAP_METHOD:		
					returnID=_encodeShadowMapMethodBlock(methVO,1103, [101,102,201,103], [methVO.alpha,methVO.epsilon,methVO.samples, methVO.range], [1,0.002,5,1], [_propNrType,_propNrType,UINT32,_propNrType]);				
					break;
				case ShadowMethodVO.HARD_SHADOW_MAP_METHOD:		
					returnID=_encodeShadowMapMethodBlock(methVO,1104, [101,102], [methVO.alpha,methVO.epsilon], [1,0.002], [_propNrType,_propNrType]);			
					break;	
				case ShadowMethodVO.CASCADE_SHADOW_MAP_METHOD:		
					baseID=_getBlockIDorEncodeAsset(methVO.baseMethod);// get id for baseMethod (encode BaseMethod if not allready)
					returnID=_encodeShadowMapMethodBlock(methVO,1001, [1], [baseID], [0], [BADDR]);
					break;
				case ShadowMethodVO.NEAR_SHADOW_MAP_METHOD:		
					baseID=_getBlockIDorEncodeAsset(methVO.baseMethod);// get id for baseMethod (encode BaseMethod if not allready)
					returnID=_encodeShadowMapMethodBlock(methVO,1002, [1], [baseID], [0], [BADDR]);
					break;
			}	
			return returnID;
		}

		//////ANIMATION_BLOCKS
		
		// encode Skeleton (id=101)
		private function _encodeSkeleton(skeleton:SkeletonVO) : uint
		{	
			var returnID:uint;
			returnID=_encodeBlockHeader(101);
			
			_blockBody.writeUTF(skeleton.name);
			_blockBody.writeShort(skeleton.joints.length);			
			
			_beginElement(); // Prop list
			_endElement(); // Prop list
			var jointID:int=0;
			var inversMtx:Matrix3D;
			for each (var joint:SkeletonJoint in skeleton.joints){				
				
				_blockBody.writeShort(jointID);//ignored by parser
				_blockBody.writeShort(int(joint.parentIndex +1));//ignored by parser
				_blockBody.writeUTF(joint.name);
				
				_encodeMatrix3D(new Matrix3D(joint.inverseBindPose));
				
				_beginElement(); // User attr
				_endElement(); // User attr				
				_beginElement(); // User attr
				_endElement(); // User attr
				jointID+=1;
			}			
			
			_beginElement(); // User attr
			_endElement(); // User attr			
			_finalizeBlock();
			
			return returnID;
		}
		
		// encode SkeletonPose (id=102)
		private function _encodeSkeletonPose(skeletPose:SkeletonPoseVO) : uint
		{	
			var returnID:uint;
			returnID=_encodeBlockHeader(102);
			
			_blockBody.writeUTF(skeletPose.name);			
			_blockBody.writeShort(skeletPose.jointTransforms.length);
			
			_beginElement(); // Prop list
			_endElement(); // Prop list
			
			var frameCnt:uint=0;
			for each (var skeletonPoseID:Matrix3D in skeletPose.jointTransforms){
				_blockBody.writeByte(1);
				_encodeMatrix3D(skeletonPoseID);				
			}
			
			_beginElement(); // User attr
			_endElement(); // User attr
			
			_finalizeBlock();
			
			return returnID;
		}
		
		// encode AnimationClip (id=112/103)
		private function _encodeAnimation(animClip:AnimationNodeVO) : uint
		{	
			var returnID:uint;
			var typeID:uint;
			switch (animClip.type){
				case "SkeletonClipNode":
					returnID=_encodeSkeletonAnimation(animClip)
					break;
				case "VertexClipNode":
					returnID=_encodeVertexAnimation(animClip)
					break;
			}						
			return returnID;
		}
		
		// encode AnimationClip (id=103)
		private function _encodeSkeletonAnimation(animClip:AnimationNodeVO) : uint
		{				
			var skeletonPoseIDs:Vector.<uint>=new Vector.<uint>;
			for each (var skeletonPose:SkeletonPoseVO in animClip.animationPoses)
				skeletonPoseIDs.push(_getBlockIDorEncodeAsset(skeletonPose));
				
			var returnID:uint =_encodeBlockHeader(103);
			_blockBody.writeUTF(animClip.name);
			_blockBody.writeShort(animClip.animationPoses.length);
			_beginElement(); // Prop list
			_endElement(); // Prop list
			var frameCnt:uint=0;
			for each (var skeletonPoseID:uint in skeletonPoseIDs){
				_blockBody.writeUnsignedInt(skeletonPoseID);
				_blockBody.writeShort(animClip.frameDurations[frameCnt]);				
				frameCnt++;
			}						
			
			_beginElement(); // User attr
			_endElement(); // User attr
			
			_finalizeBlock();
			
			return returnID;
		}		
		
		// encode AnimationClip (id=112) 
		private function _encodeVertexAnimation(animClip:AnimationNodeVO) : uint
		{	
			var geoId:uint=0;
			if (_translateAnimationNodesToMesh[animClip.id]){
				geoId=_getBlockIDorEncodeAsset(MeshVO(_translateAnimationNodesToMesh[animClip.id]).geometry);
			}
			
			var returnID:uint=_encodeBlockHeader(112);			
			_blockBody.writeUTF(animClip.name);		
			_blockBody.writeUnsignedInt(geoId);
			_blockBody.writeShort(animClip.animationPoses.length);	
			_blockBody.writeShort(Geometry(animClip.animationPoses[0]).subGeometries.length);
			_blockBody.writeShort(1);
			_blockBody.writeShort(1);			
			
			_beginElement(); // Prop list
			_endElement(); // Prop list
			
			var frameCnt:uint=0;
			var i:int=0;
			var k:int=0;
			for each (var animGeo:Geometry in animClip.animationPoses){
				_blockBody.writeShort(animClip.frameDurations[frameCnt]);	
				//to do: add optional parsingStyle
				for (i=0;i<animGeo.subGeometries.length;i++){
					
					_beginElement(); // Prop list
					_encodeFloatStream( animGeo.subGeometries[i].vertexData.concat(), 3, 0, 13);
					_endElement(); // Prop list
				}
				frameCnt+=1;
			}			
			_beginElement(); // User attr
			_endElement(); // User attr
			
			_finalizeBlock();
			
			return returnID;
		}
		
		// encode AnimationSet (id=113)
		private function _encodeAnimationSet(animSet:AnimationSetVO) : uint
		{	
			// make shure all frames are exported before the animationSet:
			var animationIDs:Vector.<uint>=new Vector.<uint>;
			for each (var frame:AnimationNodeVO in animSet.animations){
				if (frame is SharedAnimationNodeVO)
					frame=SharedAnimationNodeVO(frame).linkedAsset as AnimationNodeVO;					
				animationIDs.push(_getBlockIDorEncodeAsset(frame));				
			}
			
			var returnID:uint;
			returnID=_encodeBlockHeader(113);			
			
			_blockBody.writeUTF(animSet.name);
			_blockBody.writeShort(animSet.animations.length);
			
			_beginElement(); // Prop list
			switch (animSet.type){
				case "SkeletonAnimationSet"://to do: add jointPerVerticle here
					
					if (_translateAnimationSetToMesh[animSet.id]){
						var jpv:uint=MeshVO(_translateAnimationSetToMesh[animSet.id]).jointsPerVertex;
						_encodeProperty(1,jpv, UINT16);
					}
					break;
				case "VertexAnimationSet":
					break;
			}			
			_endElement(); // Prop list
			
			for each (var animID:uint in animationIDs)
				_blockBody.writeUnsignedInt(animID);
				
			_beginElement(); // User attr
			_endElement(); // User attr
			
			_finalizeBlock();
			
			return returnID;
		}
		
		// encode Animator (id=122)
		private function _encodeAnimator(animator : AnimatorVO) : uint
		{	
			var animSetID:uint=_getBlockIDorEncodeAsset(animator.animationSet);
			
			var meshIDs:Vector.<uint>= new Vector.<uint>;
			if (_translateAnimatiorToMesh[animator.id]){
				for each (var meshvo:MeshVO in _translateAnimatiorToMesh[animator.id])
					meshIDs.push(_getBlockIDorEncodeAsset(meshvo));
			}
			var skeletID:uint;
			var returnID:uint;
			var animType:uint=0;
			switch (animator.type){
				case "SkeletonAnimator":
					animType=1;
					skeletID =_getBlockIDorEncodeAsset(animator.skeleton);
					break;
				case "VertexAnimator":
					animType=2;
					break;
				default:
					trace ("can not export unsupported Animation-Type");
					return 0;
					break;
			}	
			
			returnID=_encodeBlockHeader(122);
			_blockBody.writeUTF(animator.name);
			_blockBody.writeShort(animType);
			
			_beginElement(); // Prop list
			switch (animator.type){
				case "SkeletonAnimator":
					_encodeProperty(1,skeletID,BADDR);
					break;
				case "VertexAnimator":
					animType=2;
					break;
				default:
					trace ("can not export unsupported Animation-Type");
					return 0;
					break;
			}	
			_endElement(); // Prop list
			
			_blockBody.writeUnsignedInt(animSetID);
			_blockBody.writeShort(meshIDs.length);
			for each (var meshid:uint in meshIDs)
				_blockBody.writeUnsignedInt(meshid);
			_blockBody.writeShort(0);
			_blockBody.writeByte(0);
						
			_beginElement(); // Prop list
			_endElement(); // Prop list			
			
			_beginElement(); // User attr
			_endElement(); // User attr
			
			_finalizeBlock();
			
			return returnID;
		}
				
		// encode CommandBlock (id=253) - this is only used for Command: PutIntoSceneGraph
		private function _encodeCommand(targetObj:ObjectVO,targetID:uint,parentId:uint=0) : uint
		{
			var returnID:int;
			
			returnID=_encodeBlockHeader(253);
			_blockBody.writeByte(1);//has sceneHeader
			_blockBody.writeUnsignedInt(parentId);//parent		
			_encodeMatrix3D(getTransformMatrix(targetObj));//matrix
			_blockBody.writeUTF(targetObj.name);//name
			
			_blockBody.writeShort(1);//num Commands (allways 1 for now)
			
			_blockBody.writeShort(1);//"PutIntoSceneGraph"-type =1
			
			_beginElement(); // start list	
			_encodeProperty(1,targetID,  BADDR);
			_endElement(); // end list			
			
			_beginElement(); // start list		
			if(targetObj.pivotX!=0)_encodeProperty(1,targetObj.pivotX,  _matrixNrType);
			if(targetObj.pivotY!=0)_encodeProperty(2,targetObj.pivotY,  _matrixNrType);
			if(targetObj.pivotZ!=0)_encodeProperty(3,targetObj.pivotZ,  _matrixNrType);
			_endElement(); // end list			
			
			_beginElement(); // Attr list
			_endoceExtraProperties(targetObj.extras);
			_endElement(); // Attr list
			
			_finalizeBlock();
			
			if(_debug)trace("CommandBlock = "+targetObj.name + " has been encoded successfully.");	
			return returnID;
		}
		
		// encode NameSpace (id=254)
		private function _encodeNameSpaceBlock() : uint
		{	
			_encodeBlockHeader(254);
			
			_blockBody.writeByte(_nameSpaceID);	
			_blockBody.writeUTF(_nameSpaceString);	
			
			_finalizeBlock();
			return 0
		}
		
		// encode MetaData (id=255)
		private function _encodeMetaDataBlock() : uint
		{	
			_encodeBlockHeader(255);
			_beginElement(); // Prop list
			var date:Date = new Date();			
			var uintVal:uint = date.time;
			var versionNumber:String=AwayBuilder.MAJOR_VERSION+"."+AwayBuilder.MINOR_VERSION+"."+AwayBuilder.REVISION;
			_encodeProperty(1,uintVal, UINT32);
			_encodeProperty(2,"AwayBuilder", AWDSTRING);
			_encodeProperty(3,versionNumber, AWDSTRING);
			_encodeProperty(4,"AwayBuilder", AWDSTRING);
			_encodeProperty(5,versionNumber, AWDSTRING);
			_endElement(); // Prop list
			
			_finalizeBlock();
			return 0
		}
				
		
// helper - functions 
		
		
		private function _finalizeBlock() : void
		{	
			if(_blockCompress==1)
				_blockBody.compress();
			if(_blockCompress==2)
				_blockBody.compress(CompressionAlgorithm.LZMA);
			_body.writeUnsignedInt(_blockBody.length);
			_body.writeBytes(_blockBody);
			_blockBody=null;
		}
		
		private function _encodeMethod(id:int, idsVec : Array, valuesAr : Array, defaultValuesAr : Array, typesVec : Array) : void
		{
			//store ID
			if ((valuesAr.length!=typesVec.length)||(idsVec.length!=typesVec.length)){
				if(_debug) trace("error in Method encoding !!! method id = "+id);
				return 
			}
			
			_blockBody.writeShort(id);//method type 
			_beginElement(); // start prop list
			var i:int=0;
			var s:int=0;
			var encodeProp:Boolean=true;
			for (i=0;i< idsVec.length;i++){
				// we only store the property if it is not the default-value 
				if (defaultValuesAr[i]!=valuesAr[i]){
					if(valuesAr[i] is Array){
						encodeProp=false;
						for(s=0;s<valuesAr[i].length;s++){
							if (defaultValuesAr[i][s]!=valuesAr[i][s]){
								encodeProp=true;
							}							
						}
					}
					if(encodeProp)_encodeProperty(idsVec[i],valuesAr[i], typesVec[i]);
				}
			}
			_endElement(); // end prop list
			
			_beginElement(); // start prop list
			_endElement(); // end prop list
			
		}
		
		// encode a geometry stream 		
		private function _encodeStream(type : uint, data : *, offset : uint = 0, stride : uint = 0, scaleU:Number=1, scaleV:Number=1) : void
		{
			_blockBody.writeByte(type);
			var valueType:uint;
			switch (type) {
				case 1:
				case 4:
				case 5:
					_blockBody.writeByte(_geoNrType);
					_beginElement();
					_encodeFloatStream( Vector.<Number>(data), 3, offset, stride);
					_endElement();
					break;
				
				case 2:
					_blockBody.writeByte(UINT16);
					_beginElement();
					_encodeUnsignedShortStream( Vector.<uint>(data) );
					_endElement();
					break;
				
				case 3:
					_blockBody.writeByte(_geoNrType);
					_beginElement();
					_encodeUVStream( Vector.<Number>(data), 2, offset, stride,scaleU, scaleV);
					_endElement();
					break;
				
				case 6:
					_blockBody.writeByte(_geoNrType);
					_beginElement();
					_encodeJointIndexStream( Vector.<Number>(data));
					_endElement();
					break;
				
				case 7:
					_blockBody.writeByte(_geoNrType);
					_beginElement();
					_encodeJointWeightStream( Vector.<Number>(data));
					_endElement();
					break;
				case 8:
					_blockBody.writeByte(_geoNrType);
					_beginElement();
					_encodeUVStream( Vector.<Number>(data), 2, offset, stride,scaleU, scaleV);
					_endElement();
					break;
			}
		}
		
		private function _encodeJointIndexStream(str : Vector.<Number>) : void
		{
			var i : uint;
			
			i = 0;
			for (i=0; i < str.length; i++) {
				_blockBody.writeShort(int(str[i])/3);
			}
		}
		
		private function _encodeJointWeightStream(str : Vector.<Number>) : void
		{
			var i : uint;
			
			i = 0;
			for (i=0; i < str.length; i++) {
				_writeNumber(_geomStoragePrecision,(str[i]));
			}
		}
		
		private function _encodeFloatStream(str : Vector.<Number>, numPerVertex : uint, offset : uint, stride : uint, scaleU:Number=1, scaleV:Number=1) : void
		{
			var i : uint;			
			i = 0;
			for (i=offset; i < str.length; i += stride) {
				var elem : uint;
				
				for (elem=0; elem<numPerVertex; elem++) {
					_writeNumber(_geomStoragePrecision,(str[i+elem]));
				}
			}
		}
		
		private function _encodeUVStream(str : Vector.<Number>, numPerVertex : uint, offset : uint, stride : uint, scaleU:Number=1, scaleV:Number=1) : void
		{
			var i : uint;			
			i = 0;
			for (i=offset; i < str.length; i += stride) {
				_writeNumber(_geomStoragePrecision,(str[i] * scaleU));
				_writeNumber(_geomStoragePrecision,(str[i+1] * scaleV));
				
			}
		}
		private function _encodeUnsignedShortStream(str : Vector.<uint>) : void
		{
			var i : uint;
			for (i=0; i<str.length; i++) {
				_blockBody.writeShort(str[i]);
			}
		}
		
		
		private function getTransformMatrix(Asset:ObjectVO) : Matrix3D
		{			
			var transformMatrix:Matrix3D=new Matrix3D();
			var vectorComps:Vector.<Vector3D>=new Vector.<Vector3D>();
			vectorComps.push(new Vector3D(Asset.x,Asset.y,Asset.z));
			vectorComps.push(new Vector3D(Asset.rotationX * MathConsts.DEGREES_TO_RADIANS,Asset.rotationY* MathConsts.DEGREES_TO_RADIANS,Asset.rotationZ* MathConsts.DEGREES_TO_RADIANS));
			vectorComps.push(new Vector3D(Asset.scaleX,Asset.scaleY,Asset.scaleZ));
			transformMatrix.recompose(vectorComps);
			return transformMatrix;
		}		
		private function _encodeMatrix3D(mtx : Matrix3D) : void
		{
			var data : Vector.<Number> = mtx.rawData;
			_writeNumber(_matrixStoragePrecision,data[0]);
			_writeNumber(_matrixStoragePrecision,data[1]);
			_writeNumber(_matrixStoragePrecision,data[2]);
			_writeNumber(_matrixStoragePrecision,data[4]);
			_writeNumber(_matrixStoragePrecision,data[5]);
			_writeNumber(_matrixStoragePrecision,data[6]);
			_writeNumber(_matrixStoragePrecision,data[8]);
			_writeNumber(_matrixStoragePrecision,data[9]);
			_writeNumber(_matrixStoragePrecision,data[10]);
			_writeNumber(_matrixStoragePrecision,data[12]);
			_writeNumber(_matrixStoragePrecision,data[13]);
			_writeNumber(_matrixStoragePrecision,data[14]);
		}
		
		
		// writes a Number into the byteArray. This takes the storagePrecision into account.
		private function _writeNumber(precision:uint,value:Number) : void
		{
			if (precision>0){
				_blockBody.writeDouble(value);				
			}
			else{
				_blockBody.writeFloat(value);				
			}
		}
		private function _finalize() : void
		{
			_blockBody = null;
		}
		
		// encodes a Bitmap into a ByteArray - if the Bitmap contains transparent Pixel, its encodet to PNG, otherwise it is encodet to JPG
		public function _encodeBitmap(bitMap:BitmapData):Array
		{			
			var usePNG : Boolean;	
			var ba : ByteArray;	
			usePNG=bitMapHasTransparency(bitMap,bitMap.rect.width,bitMap.rect.height);
			var returnArray:Array=new Array();
			ba = new ByteArray();
			if (usePNG){
				bitMap.encode(bitMap.rect, new PNGEncoderOptions(), ba);
			}
				
			else {
				bitMap.encode(bitMap.rect, new JPEGEncoderOptions(80), ba);
			}	
			returnArray.push(ba);
			returnArray.push(usePNG);
			return returnArray;
		}		
		//check if a transparent pixel was found in a bitmap (use PNG vs JPG)
		private function bitMapHasTransparency(bmd:BitmapData,w:Number,h:Number):Boolean {
			/*
			var i:int;
			var j:int;
			
			for(i=0;i<w;i++) for(j=0;j<h;j++) if(bmd.getPixel32(i, j) < 1) return true;
			*/
			return bmd.transparent;
			
		}
		
		public function dispose() : void
		{
			_blockCache = null;
		}
		
		// encode a propertie (for a proertie list)	
		private function _encodeProperty(id : int, value : *, type : uint) : void
		{
			var i : uint;
			var len  : uint;
			var flen : uint;
			var values : Array;
			
			if (value is Array) {
				len = value.length;
				values = value;
			}
			else {
				values = [ value ];
				len = 1;
			}
			
			switch (type) {
				case BOOL:
				case INT8:
				case UINT8:
					flen = 1;
					break;
				case INT16:
				case UINT16:
					flen = 2;
					break;
				case INT32:
				case UINT32:
				case COLOR:
				case BADDR:
				case FLOAT32:
					flen = 4;
					break;
				case FLOAT64:
					flen = 8;
					break;
				case AWDSTRING:
					_blockBody.writeShort(id);
					_writeString(values[0]);
					return;
			}
			
			_blockBody.writeShort(id);
			_blockBody.writeUnsignedInt(len * flen);
			
			for (i=0; i<len; i++) {
				switch (type) {
					case INT8:
					case UINT8:
						_blockBody.writeByte(values[i]);
						break;
					
					case BOOL:
						_blockBody.writeByte(values[i]? 1 : 0);
						break;
					
					case INT16:
					case UINT16:
						_blockBody.writeShort(values[i]);
						break;
					
					case INT32:
						_blockBody.writeInt(values[i]);
						break;
					
					case UINT32:
					case COLOR:
					case BADDR:
						_blockBody.writeUnsignedInt(values[i]);
						break;
					
					case FLOAT32:
						_blockBody.writeFloat(values[i]);
						break;
					
					case FLOAT64:
						_blockBody.writeDouble(values[i]);
						break;
				}
			}
		}
		
		// encode the user-properties (the extra panel)
		private function _endoceExtraProperties(extraObject:Object) : void
		{
			if(_debug)trace("EncodeProperties");
			for each (var object:ExtraItemVO in extraObject){
				if(_debug)trace("valueName = "+object.name);
				if(_debug)trace("valueValue = "+object.value);
				_encodeAttribute(object.name, object.value)
			}
		}
		// encodes a user-Attribute
		//to do: type-casting maybe can be improved / write the correct NameSpace for each Attributes 
		private function _encodeAttribute(name:String, value : *) : void
		{
			var i : uint;
			var len  : uint;
			var flen : uint;
			var type:uint=AWDSTRING;
			
			if (!value)value="";
			
			var copy:*=value;
			if(int(copy)){
				type=INT32;
				value=int(copy);
			}
			if(Number(copy)){
				type = _attributeNrType;
				value = Number(copy);
			}
			if (type==AWDSTRING){
				if((copy=="false")||(copy=="False")||(copy=="FALSE")){
					type=BOOL;
					value=false;
				}
				if((copy=="true")||(copy=="True")||(copy=="TRUE")){
					type=BOOL;
					value=true;
				}
			}			
			_blockBody.writeByte(_nameSpaceID);//NameSpace			
			_blockBody.writeUTF(name);//Attribute name
			_blockBody.writeByte(type);//Attribute type
			
			switch (type) {
				case INT8:
				case UINT8:	
				case BOOL:
					_blockBody.writeUnsignedInt(1);
					_blockBody.writeByte(value);
					break;
				
				case INT16:
				case UINT16:
					_blockBody.writeUnsignedInt(2);
					_blockBody.writeShort(value);
					break;
				
				case INT32:
					_blockBody.writeUnsignedInt(4);
					_blockBody.writeInt(value);
					break;
					
				case UINT32:
				case COLOR:
				case BADDR:
					_blockBody.writeUnsignedInt(4);
					_blockBody.writeUnsignedInt(value);
					break;
					
				case FLOAT32:
					_blockBody.writeUnsignedInt(4);
					_blockBody.writeFloat(value);
					break;
					
				case FLOAT64:
					_blockBody.writeUnsignedInt(8);
					_blockBody.writeDouble(value);
					break;
				
				case AWDSTRING:
					_writeString(value);
					break;
				}
			
		}		
		
		private function _writeString(thisString:String) : void
		{
			var ba:ByteArray= new ByteArray();
			ba.writeUTFBytes(thisString);					
			_blockBody.writeUnsignedInt(ba.length);
			_blockBody.writeUTFBytes(thisString);
		}	
		private function _beginElement() : void
		{
			_elemSizeOffsets.push(_blockBody.position);
			_blockBody.writeUnsignedInt(0); // Placeholder
		}		
		private function _endElement() : void
		{
			var size : uint;
			var offs : uint;
			
			offs = _elemSizeOffsets.pop();
			
			size = _blockBody.position - (offs);
			if (size) {
				size-=4;
				//trace('size was ', size);
				_blockBody.position = offs;
				_blockBody.writeUnsignedInt(size);
				_blockBody.position = _blockBody.length;
			}
		}				
		
	}
}





/*

General Helper Classes 

*/
internal class bitFlags
{
	public static const FLAG1:uint = 1;
	public static const FLAG2:uint = 2;
	public static const FLAG3:uint = 4;
	public static const FLAG4:uint = 8;
	public static const FLAG5:uint = 16;
	public static const FLAG6:uint = 32;
	public static const FLAG7:uint = 64;
	public static const FLAG8:uint = 128;
	public static const FLAG9:uint = 256;
	public static const FLAG10:uint = 512;
	public static const FLAG11:uint = 1024;
	public static const FLAG12:uint = 2048;
	public static const FLAG13:uint = 4096;
	public static const FLAG14:uint = 8192;
	public static const FLAG15:uint = 16384;
	public static const FLAG16:uint = 32768;
	
	public static function test(flags:uint, testFlag:uint):Boolean
	{
		return (flags & testFlag) == testFlag;
	}
}
internal class AWDBlock
{
	public var id : int;
	public function AWDBlock() {
		id=-1;
	} 
	
	
}
internal class AWDmethod
{
	public var _id : uint;
	public var _ids : Array;
	public var _values: Array;
	public var _defaultValues: Array;
	public var _types: Array;
	public function AWDmethod(id : uint,ids : Array,values: Array,defaultValues: Array,types:Array) {
		
		_id=id;
		_ids=ids;
		_values=values;
		_defaultValues=defaultValues;
		_types=types;
	} 
}
