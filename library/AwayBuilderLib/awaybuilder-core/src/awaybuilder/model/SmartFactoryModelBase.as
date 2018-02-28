package awaybuilder.model
{
	import away3d.animators.AnimationSetBase;
	import away3d.animators.AnimatorBase;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.data.JointPose;
	import away3d.animators.data.Skeleton;
	import away3d.animators.data.SkeletonJoint;
	import away3d.animators.data.SkeletonPose;
	import away3d.animators.nodes.AnimationNodeBase;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.animators.nodes.VertexClipNode;
	import away3d.animators.states.AnimationStateBase;
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.LensBase;
	import away3d.cameras.lenses.OrthographicLens;
	import away3d.cameras.lenses.OrthographicOffCenterLens;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.ISubGeometry;
	import away3d.core.base.Object3D;
	import away3d.core.base.SkinnedSubGeometry;
	import away3d.core.base.SubMesh;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.entities.TextureProjector;
	import away3d.library.assets.NamedAssetBase;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.lights.shadowmaps.CascadeShadowMapper;
	import away3d.lights.shadowmaps.NearDirectionalShadowMapper;
	import away3d.lights.shadowmaps.ShadowMapperBase;
	import away3d.materials.ColorMaterial;
	import away3d.materials.ColorMultiPassMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.SinglePassMaterialBase;
	import away3d.materials.SkyBoxMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.TextureMultiPassMaterial;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.AlphaMaskMethod;
	import away3d.materials.methods.CascadeShadowMapMethod;
	import away3d.materials.methods.CelDiffuseMethod;
	import away3d.materials.methods.CelSpecularMethod;
	import away3d.materials.methods.ColorMatrixMethod;
	import away3d.materials.methods.ColorTransformMethod;
	import away3d.materials.methods.DitheredShadowMapMethod;
	import away3d.materials.methods.EffectMethodBase;
	import away3d.materials.methods.EnvMapAmbientMethod;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.FogMethod;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.GradientDiffuseMethod;
	import away3d.materials.methods.HeightMapNormalMethod;
	import away3d.materials.methods.LightMapDiffuseMethod;
	import away3d.materials.methods.LightMapMethod;
	import away3d.materials.methods.NearShadowMapMethod;
	import away3d.materials.methods.OutlineMethod;
	import away3d.materials.methods.ProjectiveTextureMethod;
	import away3d.materials.methods.RefractionEnvMapMethod;
	import away3d.materials.methods.RimLightMethod;
	import away3d.materials.methods.ShadingMethodBase;
	import away3d.materials.methods.ShadowMapMethodBase;
	import away3d.materials.methods.SimpleWaterNormalMethod;
	import away3d.materials.methods.SoftShadowMapMethod;
	import away3d.materials.methods.SubsurfaceScatteringDiffuseMethod;
	import away3d.materials.methods.WrapDiffuseMethod;
	import away3d.materials.utils.DefaultMaterialManager;
	import away3d.primitives.CapsuleGeometry;
	import away3d.primitives.ConeGeometry;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SkyBox;
	import away3d.primitives.SphereGeometry;
	import away3d.primitives.TorusGeometry;
	import away3d.textures.ATFTexture;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;
	
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
	import awaybuilder.model.vo.scene.SharedEffectVO;
	import awaybuilder.model.vo.scene.SharedLightVO;
	import awaybuilder.model.vo.scene.SkeletonPoseVO;
	import awaybuilder.model.vo.scene.SkeletonVO;
	import awaybuilder.model.vo.scene.SkyBoxVO;
	import awaybuilder.model.vo.scene.SubGeometryVO;
	import awaybuilder.model.vo.scene.SubMeshVO;
	import awaybuilder.model.vo.scene.TextureProjectorVO;
	import awaybuilder.model.vo.scene.TextureVO;
	import awaybuilder.utils.AssetUtil;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;

	use namespace arcane;

	public class SmartFactoryModelBase
	{
		
		public function GetAsset( obj:Object ):AssetVO
		{
			return null;
		}
		
		protected function createAsset( item:Object ):AssetVO
		{
			var asset:AssetVO;
			switch(true)
			{
				case(item is Mesh):
					return fillMesh( new MeshVO(), item as Mesh );
					
				case(item is LightBase):
					return fillLight( new LightVO(), item as LightBase  );
					
				case(item is SkyBox):
					return fillSkyBox( new SkyBoxVO(), item as SkyBox  );
					
				case(item is TextureProjector):
					return fillTextureProjector( new TextureProjectorVO(), item as TextureProjector  );
					
				case(item is Camera3D):
					return fillCamera( new CameraVO(),  item as Camera3D );
					
				case(item is Entity):
				case(item is ObjectContainer3D):
					return fillContainer( new ContainerVO(), item as ObjectContainer3D );
					
				case(item is MaterialBase):
					return fillMaterial( new MaterialVO(), item as MaterialBase );
					
				case(item is BitmapTexture):
					return fillBitmapTexture( new TextureVO(), item as BitmapTexture );
					
				case(item is ATFTexture):
					return fillATFTexture( new TextureVO(), item as ATFTexture );
					
				case(item is Geometry):
					return fillGeometry( new GeometryVO(), item as Geometry );
					
				case(item is ISubGeometry):
					return fillSubGeometry( new SubGeometryVO(), item as ISubGeometry );
					
				case(item is AnimationStateBase):
					asset = fillAsset( new AssetVO(), item );
					asset.name = "Animation State (" + item.name +")";
					return asset;
					
				case(item is SkeletonPose):
					return fillSkeletonPose( new SkeletonPoseVO(), item as SkeletonPose );
					
				case(item is Skeleton):
					return fillSkeleton( new SkeletonVO(), item as Skeleton );
					
				case(item is ShadowMapMethodBase):
					return fillShadowMethod( new ShadowMethodVO(), item as ShadowMapMethodBase );
					
				case(item is SubMesh):
					return fillSubMesh( new SubMeshVO(), item as SubMesh );
					
				case(item is EffectMethodBase):
					return fillEffectMethod( new EffectVO(), item as EffectMethodBase );
					
				case(item is LightPickerBase):
					return fillLightPicker( new LightPickerVO(),  item as StaticLightPicker );
					
				case(item is BitmapCubeTexture):
					return fillCubeTexture( new CubeTextureVO(),  item as BitmapCubeTexture );
					
				case(item is ShadowMapperBase):
					return fillShadowMapper( new ShadowMapperVO(),  item as ShadowMapperBase );
					
				case(item is ShadingMethodBase):
					return fillShadingMethod( new ShadingMethodVO(),  item as ShadingMethodBase );
					
				case(item is AnimationNodeBase):
					return fillAnimationNode( new AnimationNodeVO(),  item as AnimationNodeBase );
					
				case(item is AnimationSetBase):
					return fillAnimationSet( new AnimationSetVO(),  item as AnimationSetBase );
					
				case(item is LensBase):
					return fillLens( new LensVO(),  item as LensBase );
					
				case(item is AnimatorBase):
					return fillAnimator( new AnimatorVO,  item as AnimatorBase );
			}
			
			return null;
		}
		private function fillSkeletonPose( asset:SkeletonPoseVO, item:SkeletonPose ):SkeletonPoseVO
		{
			asset = fillAsset( asset, item ) as SkeletonPoseVO;
			asset.name = "Skeleton Pose (" + item.name +")";
			asset.jointTransforms = new ArrayCollection();
			var jointMatrix:Matrix3D;
			for each( var jointTranform:JointPose in item.jointPoses )
			{
				jointMatrix=new Matrix3D();
				jointTranform.toMatrix3D(jointMatrix);
				asset.jointTransforms.addItem(jointMatrix);
			}
			return asset;
		}
		private function fillSkeleton( asset:SkeletonVO, item:Skeleton ):SkeletonVO
		{
			asset = fillAsset( asset, item ) as SkeletonVO;
			asset.name = item.name;
			asset.joints = new Vector.<SkeletonJoint>;
			for each( var joint:SkeletonJoint in item.joints )
			{
				asset.joints.push( joint );
			}
			return asset;
		}
		private function fillLightPicker( asset:LightPickerVO, item:StaticLightPicker ):LightPickerVO
		{
			asset = fillAsset( asset, item ) as LightPickerVO;
			asset.name = item.name;
			asset.lights = new ArrayCollection();
			for each( var light:LightBase in item.lights )
			{
				asset.lights.addItem( new SharedLightVO(GetAsset( light ) as LightVO ) );
			}
			return asset;
		}
		private function fillEffectMethod( asset:EffectVO, item:EffectMethodBase ):EffectVO
		{
			asset.type = getQualifiedClassName( item ).split("::")[1];
			asset.name = item.name;
			switch( true ) 
			{
				case(item is AlphaMaskMethod):
					var alphaMaskMethod:AlphaMaskMethod = item as AlphaMaskMethod;
					asset.texture = GetAsset(alphaMaskMethod.texture) as TextureVO;
					asset.useSecondaryUV = alphaMaskMethod.useSecondaryUV;
					break;
				case(item is ColorTransformMethod):
					var colorTransformMethod:ColorTransformMethod = item as ColorTransformMethod;
						asset.r = colorTransformMethod.colorTransform.redMultiplier;
						asset.g = colorTransformMethod.colorTransform.greenMultiplier;
						asset.b = colorTransformMethod.colorTransform.blueMultiplier;
						asset.a = colorTransformMethod.colorTransform.alphaMultiplier;
						asset.rO = colorTransformMethod.colorTransform.redOffset;
						asset.gO = colorTransformMethod.colorTransform.greenOffset;
						asset.bO = colorTransformMethod.colorTransform.blueOffset;
						asset.aO = colorTransformMethod.colorTransform.alphaOffset;
					break;
				case(item is ColorMatrixMethod):
				var colorMatrixMethod:ColorMatrixMethod = item as ColorMatrixMethod;
						asset.r = colorMatrixMethod.colorMatrix[0];
						asset.g = colorMatrixMethod.colorMatrix[1];
						asset.b = colorMatrixMethod.colorMatrix[2];
						asset.a = colorMatrixMethod.colorMatrix[3];
						asset.rG = colorMatrixMethod.colorMatrix[5];
						asset.gG = colorMatrixMethod.colorMatrix[6];
						asset.bG = colorMatrixMethod.colorMatrix[7];
						asset.aG = colorMatrixMethod.colorMatrix[8];
						asset.rB = colorMatrixMethod.colorMatrix[10];
						asset.gB = colorMatrixMethod.colorMatrix[11];
						asset.bB = colorMatrixMethod.colorMatrix[12];
						asset.aB = colorMatrixMethod.colorMatrix[13];
						asset.rA = colorMatrixMethod.colorMatrix[15];
						asset.gA = colorMatrixMethod.colorMatrix[16];
						asset.bA = colorMatrixMethod.colorMatrix[17];
						asset.aA = colorMatrixMethod.colorMatrix[18];
						asset.rO = colorMatrixMethod.colorMatrix[4];
						asset.gO = colorMatrixMethod.colorMatrix[9];
						asset.bO = colorMatrixMethod.colorMatrix[14];
						asset.aO = colorMatrixMethod.colorMatrix[19];
					break;
				case(item is EnvMapMethod):
					var envMapMethod:EnvMapMethod = item as EnvMapMethod;
					asset.cubeTexture = GetAsset(envMapMethod.envMap) as CubeTextureVO;
					asset.alpha = envMapMethod.alpha;
					asset.texture = GetAsset(envMapMethod.mask) as TextureVO;
					break;
				case(item is FogMethod):
				var fogMethod:FogMethod = item as FogMethod; 
					asset.color = fogMethod.fogColor;
					asset.minDistance = fogMethod.minDistance;
					asset.maxDistance = fogMethod.maxDistance;
					break;
				case(item is FresnelEnvMapMethod):
					var fresnelEnvMapMethod:FresnelEnvMapMethod = item as FresnelEnvMapMethod;
					asset.cubeTexture = GetAsset(fresnelEnvMapMethod.envMap) as CubeTextureVO;
					asset.power = fresnelEnvMapMethod.fresnelPower;
					asset.normalReflectance = fresnelEnvMapMethod.normalReflectance;
					asset.alpha = fresnelEnvMapMethod.alpha;
					asset.texture = GetAsset(fresnelEnvMapMethod.mask) as TextureVO;
					break;
				case(item is LightMapMethod):
					var lightMapMethod:LightMapMethod = item as LightMapMethod; 
					asset.texture = GetAsset(lightMapMethod.texture) as TextureVO;
					asset.mode = lightMapMethod.blendMode;
					asset.useSecondaryUV = lightMapMethod.useSecondaryUV;
					break;
				case(item is OutlineMethod):
					var outlineMethod:OutlineMethod = item as OutlineMethod;
					asset.size = outlineMethod.outlineSize;
					asset.color = outlineMethod.outlineColor;
					asset.showInnerLines = outlineMethod.showInnerLines;
//					asset.dedicatedMesh = outlineMethod.dedicatedMesh;
					break;
				case(item is ProjectiveTextureMethod):
					var projectiveTextureMethod:ProjectiveTextureMethod = item as ProjectiveTextureMethod;
					asset.textureProjector = GetAsset( projectiveTextureMethod.projector ) as TextureProjectorVO;
					asset.mode = projectiveTextureMethod.mode;
					break;
				case(item is RefractionEnvMapMethod):
					var refractionEnvMapMethod:RefractionEnvMapMethod = item as RefractionEnvMapMethod; 
					asset.cubeTexture = GetAsset(refractionEnvMapMethod.envMap) as CubeTextureVO;
					asset.r = refractionEnvMapMethod.dispersionR;
					asset.g = refractionEnvMapMethod.dispersionG;
					asset.b = refractionEnvMapMethod.dispersionB;
					asset.alpha = refractionEnvMapMethod.alpha;
					asset.refraction = refractionEnvMapMethod.refractionIndex;
					break;
				case(item is RimLightMethod):
					var rimLightMethod:RimLightMethod = item as RimLightMethod;
					asset.color = RimLightMethod(item).color;
					asset.strength = RimLightMethod(item).strength;
					asset.power = RimLightMethod(item).power;
					break;
			}
			
			return asset;
		}
		private function fillSubMesh( asset:SubMeshVO, item:SubMesh ):SubMeshVO
		{
			asset.name = "SubMesh";
			asset.material = GetAsset( item.material ) as MaterialVO;
			asset.subGeometry = GetAsset( item.subGeometry ) as SubGeometryVO;
			asset.uvTransform = item.uvTransform;
			return asset;
		}
		private function fillShadowMethod( asset:ShadowMethodVO, item:ShadowMapMethodBase ):ShadowMethodVO
		{
			asset = fillAsset( asset, item ) as ShadowMethodVO;
			asset.castingLight = GetAsset( item.castingLight ) as LightVO;
			asset.epsilon = item.epsilon;
			asset.alpha = item.alpha;
			asset.type = getQualifiedClassName( item ).split("::")[1];
			
				
			var alreadyAdded:Boolean = false;
			for each( var method:ShadowMethodVO in asset.castingLight.shadowMethods )
			{
				if( method.equals( asset ) ) alreadyAdded = true;	
			}
			if( !alreadyAdded )	asset.castingLight.shadowMethods.addItem( asset );
				
				
			if( item is SoftShadowMapMethod )
			{
				var softShadowMapMethod:SoftShadowMapMethod = item as SoftShadowMapMethod;
				asset.samples = softShadowMapMethod.numSamples;
				asset.range = softShadowMapMethod.range;
			}
			else if( item is DitheredShadowMapMethod )
			{
				var ditheredShadowMapMethod:DitheredShadowMapMethod = item as DitheredShadowMapMethod;
				asset.samples = ditheredShadowMapMethod.numSamples;
				asset.range = ditheredShadowMapMethod.range;
			}
			else if( item is CascadeShadowMapMethod )
			{
				var cascadeShadowMapMethod:CascadeShadowMapMethod = item as CascadeShadowMapMethod;
				asset.baseMethod = GetAsset( cascadeShadowMapMethod.baseMethod ) as ShadowMethodVO;
			}
			else if( item is NearShadowMapMethod )
			{
				var nearShadowMapMethod:NearShadowMapMethod = item as NearShadowMapMethod;
				asset.baseMethod = GetAsset( nearShadowMapMethod.baseMethod ) as ShadowMethodVO;
			}
			return asset;
		}
		
		private function fillTextureProjector( asset:TextureProjectorVO, obj:TextureProjector ):TextureProjectorVO
		{
			asset = fillObject( asset, obj ) as TextureProjectorVO;
			asset.aspectRatio = obj.aspectRatio;
			asset.fov = obj.fieldOfView;
			asset.texture = GetAsset( obj.texture ) as TextureVO;
			return asset;
		}
		private function fillSkyBox( asset:SkyBoxVO, obj:SkyBox ):SkyBoxVO
		{
			asset = fillAsset( asset, obj ) as SkyBoxVO;
			asset.cubeMap = GetAsset( SkyBoxMaterial(obj.material).cubeMap ) as CubeTextureVO;
			return asset;
		}
		private function fillLight( asset:LightVO, item:LightBase ):LightVO
		{
			asset = fillObject( asset, item ) as LightVO;
			asset.color = item.color;
			asset.ambientColor = item.ambientColor;
			asset.ambient = item.ambient;
			asset.diffuse = item.diffuse;
			
			asset.specular = item.specular;
			
			asset.castsShadows = item.castsShadows;
			asset.shadowMapper = GetAsset( item.shadowMapper ) as ShadowMapperVO;
			
			if( item is DirectionalLight ) 
			{
				var dl:DirectionalLight = DirectionalLight( item );
				dl.direction.normalize();
				asset.type = LightVO.DIRECTIONAL;
				
				asset.elevationAngle = Math.round(-Math.asin( dl.direction.y )*180/Math.PI);
				var a:Number = Math.atan2(dl.direction.x, dl.direction.z )*180/Math.PI;
				asset.azimuthAngle = Math.round(a<0?a+360:a);
			}
			else if( item is PointLight ) 
			{
				var pl:PointLight = PointLight( item );
				asset.type = LightVO.POINT;
				asset.radius = pl.radius;
				asset.fallOff = pl.fallOff;
			}
			return asset;
		}
		
		private function fillSubGeometry( asset:SubGeometryVO, obj:ISubGeometry ):SubGeometryVO
		{
			asset = fillAsset( asset, obj ) as SubGeometryVO;
			asset.type = getQualifiedClassName( obj ).split("::")[1];
			asset.numVerts = obj.numVertices
			asset.numTris = obj.numTriangles;
			asset.scaleU = obj.scaleU
			asset.scaleV = obj.scaleV;
			asset.vertexData = obj.vertexData;
			asset.vertexOffset = obj.vertexOffset;
			asset.vertexStride = obj.vertexStride;
			asset.autoDerivedNormals = obj.autoDeriveVertexNormals;
			asset.autoDerivedTangents = obj.autoDeriveVertexTangents;
			asset.hasUVData = !obj.autoGenerateDummyUVs
			asset.UVData = obj.UVData;
			asset.UVStride = obj.UVStride;
			asset.UVOffset = obj.UVOffset;
			asset.hasSecUVData = obj.hasSecondaryUVs;
			asset.SecUVData = obj.SecondaryUVData;
			asset.SecUVStride = obj.secondaryUVStride;
			asset.SecUVOffset = obj.secondaryUVOffset;
			asset.vertexNormalData = obj.vertexNormalData;
			asset.vertexNormalOffset = obj.vertexNormalOffset;
			asset.vertexNormalStride = obj.vertexNormalStride;
			asset.vertexTangentData = obj.vertexTangentData;
			asset.vertexTangentOffset = obj.vertexTangentOffset;
			asset.vertexTangentStride = obj.vertexTangentStride;
			asset.indexData = obj.indexData;
			if (obj is SkinnedSubGeometry){
				asset.jointIndexData = SkinnedSubGeometry(obj).jointIndexData;
				asset.jointWeightsData = SkinnedSubGeometry(obj).jointWeightsData;
			}
			return asset;
		}
		private function fillGeometry( asset:GeometryVO, obj:Geometry ):GeometryVO
		{
			asset = fillAsset( asset, obj ) as GeometryVO;
			asset.type = getQualifiedClassName( obj ).split("::")[1];
			asset.subGeometries = new ArrayCollection();
			asset.scaleU=1;
			asset.scaleV=1;
			switch (true){
				case (obj is PlaneGeometry):
					var planeGeometry:PlaneGeometry = obj as PlaneGeometry;
					asset.width = planeGeometry.width;
					asset.height = planeGeometry.height;
					asset.segmentsW = planeGeometry.segmentsW;
					asset.segmentsH = planeGeometry.segmentsH;
					asset.yUp = planeGeometry.yUp;
					asset.doubleSided = planeGeometry.doubleSided;
					break;
				case (obj is CubeGeometry):
					var cubeGeometry:CubeGeometry = obj as CubeGeometry;
					asset.width = cubeGeometry.width;
					asset.height = cubeGeometry.height;
					asset.depth = cubeGeometry.depth;
					asset.tile6 = cubeGeometry.tile6;
					asset.segmentsW = cubeGeometry.segmentsW;
					asset.segmentsH = cubeGeometry.segmentsH;
					asset.segmentsD = cubeGeometry.segmentsD;
					break;
				case (obj is SphereGeometry):
					var sphereGeometry:SphereGeometry = obj as SphereGeometry;
					asset.radius = sphereGeometry.radius;
					asset.yUp = sphereGeometry.yUp;
					asset.segmentsSW = sphereGeometry.segmentsW;
					asset.segmentsSH = sphereGeometry.segmentsH;
					break;
				case (obj is ConeGeometry):
					var coneGeometry:ConeGeometry = obj as ConeGeometry;
					asset.radius = coneGeometry.bottomRadius;
					asset.height = coneGeometry.height;
					asset.segmentsR = coneGeometry.segmentsW;
					asset.segmentsH = coneGeometry.segmentsH;
					asset.bottomClosed = coneGeometry.bottomClosed;
					asset.yUp = coneGeometry.yUp;
					break;
				case (obj is CylinderGeometry):
					var cylinderGeometry:CylinderGeometry = obj as CylinderGeometry;
					asset.bottomRadius = cylinderGeometry.bottomRadius;
					asset.topRadius = cylinderGeometry.topRadius;
					asset.height = cylinderGeometry.height;
					asset.segmentsR = cylinderGeometry.segmentsW;
					asset.segmentsH = cylinderGeometry.segmentsH;
					asset.topClosed = cylinderGeometry.topClosed;
					asset.bottomClosed = cylinderGeometry.bottomClosed;
					asset.yUp = cylinderGeometry.yUp;
					break;
				case (obj is CapsuleGeometry):
					var capsuleGeometry:CapsuleGeometry = obj as CapsuleGeometry;
					asset.radius = capsuleGeometry.radius;
					asset.height = capsuleGeometry.height;
					asset.segmentsR = capsuleGeometry.segmentsW;
					asset.segmentsC = capsuleGeometry.segmentsH;
					asset.yUp = capsuleGeometry.yUp;
					break;
				case (obj is TorusGeometry):
					var torusGeometry:TorusGeometry = obj as TorusGeometry;
					asset.radius = torusGeometry.radius;
					asset.tubeRadius = torusGeometry.tubeRadius;
					asset.segmentsR = torusGeometry.segmentsR;
					asset.segmentsT = torusGeometry.segmentsT;
					asset.yUp = torusGeometry.yUp;
					break;
			}
			if( obj.subGeometries.length>0)
			{
				asset.scaleU=obj.subGeometries[0].scaleU;
				asset.scaleV=obj.subGeometries[0].scaleV;			
			}
			var subGeoCounter:uint=0;
			for each( var sub:ISubGeometry in obj.subGeometries )
			{
				subGeoCounter++;
				var subGeometryVO:SubGeometryVO = GetAsset(sub) as SubGeometryVO;
				subGeometryVO.name="SubGeometry #"+subGeoCounter;
				asset.subGeometries.addItem( subGeometryVO );
			}
			return asset;
		}
		
		private function fillAnimator( asset:AnimatorVO, obj:AnimatorBase ):AnimatorVO
		{
			asset = fillAsset( asset, obj ) as AnimatorVO;
			asset.type = getQualifiedClassName( obj ).split("::")[1];
			asset.animationSet = GetAsset(obj.animationSet) as AnimationSetVO;
			
			var alreadyAdded:Boolean = false;
			for each( var animator:AnimatorVO in asset.animationSet.animators )
			{
				if( animator.equals( asset ) ) alreadyAdded = true;	
			}
			if( !alreadyAdded )	asset.animationSet.animators.addItem( asset ); // AnimationSet is container for Animators, but not store it directly
			
			asset.playbackSpeed = obj.playbackSpeed;
			var skeletonAnimator:SkeletonAnimator = obj as SkeletonAnimator;
			if( skeletonAnimator )
			{
				asset.skeleton = GetAsset(skeletonAnimator.skeleton) as SkeletonVO;
			}
			return asset;
		}
		private function fillCamera( asset:CameraVO, obj:Camera3D ):CameraVO
		{
			asset = fillObject( asset, obj ) as CameraVO;
			asset.lens = GetAsset(obj.lens) as LensVO;
			return asset;
		}
		private function fillLens( asset:LensVO, obj:LensBase ):LensVO
		{
			asset = fillAsset( asset, obj ) as LensVO;
			asset.type = getQualifiedClassName( obj ).split("::")[1];
			var perspectiveLens:PerspectiveLens = obj as PerspectiveLens;
			if( perspectiveLens )
			{
				asset.value = perspectiveLens.fieldOfView;
				asset.near = perspectiveLens.near;
				asset.far = perspectiveLens.far;
			}
			var orthographicLens:OrthographicLens = obj as OrthographicLens;
			if( orthographicLens )
			{
				asset.value = orthographicLens.projectionHeight;
				asset.near = orthographicLens.near;
				asset.far = orthographicLens.far;
			}
			var orthographicOffCenterLens:OrthographicOffCenterLens = obj as OrthographicOffCenterLens;
			if( orthographicOffCenterLens )
			{
				asset.minX = orthographicOffCenterLens.minX;
				asset.minY = orthographicOffCenterLens.minY;
				asset.maxX = orthographicOffCenterLens.maxX;
				asset.maxY = orthographicOffCenterLens.maxY;
				asset.near = orthographicOffCenterLens.near;
				asset.far = orthographicOffCenterLens.far;
			}
			return asset;
		}
		private function fillAnimationSet( asset:AnimationSetVO, obj:AnimationSetBase ):AnimationSetVO
		{
			asset = fillAsset( asset, obj ) as AnimationSetVO;
			asset.type = getQualifiedClassName( obj ).split("::")[1];
			for each( var animationNodeBase:AnimationNodeBase in obj.animations )
			{
				var animationNodeVO:AnimationNodeVO = GetAsset( animationNodeBase ) as AnimationNodeVO;
				asset.animations.addItem( new SharedAnimationNodeVO(animationNodeVO) );
			}
			return asset;
		}
		private function fillAnimationNode( asset:AnimationNodeVO, obj:AnimationNodeBase ):AnimationNodeVO
		{
			asset = fillAsset( asset, obj ) as AnimationNodeVO;
			asset.name = obj.name;
			asset.type = getQualifiedClassName( obj ).split("::")[1];
			var poseCnt:uint=0;
			var skeletonClipNode:SkeletonClipNode = obj as SkeletonClipNode;
			if( skeletonClipNode )
			{
				for each (var skeletonPose:SkeletonPose in skeletonClipNode.frames)
				{					
					asset.animationPoses.addItem( GetAsset( skeletonPose ) as SkeletonPoseVO );
					asset.frameDurations.addItem(skeletonClipNode.durations[poseCnt] );
					poseCnt++;
				}
				asset.totalDuration = skeletonClipNode.totalDuration;
				return asset;
			}
			var vertexClipNode:VertexClipNode = obj as VertexClipNode;
			if( vertexClipNode )
			{
			 	for each (var vertexPose:Geometry in vertexClipNode.frames)
				{						
						asset.animationPoses.addItem( vertexPose );
						asset.frameDurations.addItem(vertexClipNode.durations[poseCnt] );
						poseCnt++;
					}
				asset.totalDuration = vertexClipNode.frames.length;
			}
			return asset;
		}
		private function fillShadingMethod( asset:ShadingMethodVO, obj:ShadingMethodBase ):ShadingMethodVO
		{
			asset.type = getQualifiedClassName( obj ).split("::")[1];
			asset.name = asset.type;
			switch( true ) 
			{	
				case(obj is EnvMapAmbientMethod):
				{
					var envMapAmbientMethod:EnvMapAmbientMethod = obj as EnvMapAmbientMethod;
					asset.envMap = GetAsset( envMapAmbientMethod.envMap ) as CubeTextureVO;
					break;
				}
				case(obj is GradientDiffuseMethod):
				{
					var gradientDiffuseMethod:GradientDiffuseMethod = obj as GradientDiffuseMethod;
					asset.texture = GetAsset( gradientDiffuseMethod.gradient ) as TextureVO;
					break;
				}
				case(obj is WrapDiffuseMethod):
				{
					var wrapDiffuseMethod:WrapDiffuseMethod = obj as WrapDiffuseMethod;
					asset.value = wrapDiffuseMethod.wrapFactor;
					break;
				}
				case(obj is LightMapDiffuseMethod):
				{
					var lightMapDiffuseMethod:LightMapDiffuseMethod = obj as LightMapDiffuseMethod;
					asset.blendMode = lightMapDiffuseMethod.blendMode;
					asset.texture = GetAsset( lightMapDiffuseMethod.lightMapTexture ) as TextureVO;
					asset.baseMethod = GetAsset( lightMapDiffuseMethod.baseMethod ) as ShadingMethodVO;
					break;
				}
				case(obj is CelDiffuseMethod):
				{
					var celDiffuseMethod:CelDiffuseMethod = obj as CelDiffuseMethod;
					asset.value = celDiffuseMethod.levels;
					asset.smoothness = celDiffuseMethod.smoothness;
					asset.baseMethod = GetAsset( celDiffuseMethod.baseMethod ) as ShadingMethodVO;
					break;
				}
				case(obj is SubsurfaceScatteringDiffuseMethod):
				{
					var subsurfaceScatterDiffuseMethod:SubsurfaceScatteringDiffuseMethod = obj as SubsurfaceScatteringDiffuseMethod;
					asset.scattering = subsurfaceScatterDiffuseMethod.scattering;
					asset.translucency = subsurfaceScatterDiffuseMethod.translucency;
					asset.baseMethod = GetAsset( subsurfaceScatterDiffuseMethod.baseMethod ) as ShadingMethodVO;
					break;
				}
				case(obj is CelSpecularMethod):
				{
					var celSpecularMethod:CelSpecularMethod = obj as CelSpecularMethod;
					asset.value = celSpecularMethod.specularCutOff;
					asset.smoothness = celSpecularMethod.smoothness;
					asset.baseMethod = GetAsset( celSpecularMethod.baseMethod ) as ShadingMethodVO;
					break;
				}
				case(obj is FresnelSpecularMethod):
				{
					var fresnelSpecularMethod:FresnelSpecularMethod = obj as FresnelSpecularMethod;
					asset.basedOnSurface = fresnelSpecularMethod.basedOnSurface;
					asset.fresnelPower = fresnelSpecularMethod.fresnelPower;
					asset.value = fresnelSpecularMethod.normalReflectance;
					asset.baseMethod = GetAsset( fresnelSpecularMethod.baseMethod ) as ShadingMethodVO;
					break;
				}
				case(obj is HeightMapNormalMethod):
				{
					var heightMapNormalMethod:HeightMapNormalMethod = obj as HeightMapNormalMethod;
					break;
				}
				case(obj is SimpleWaterNormalMethod):
				{
					var simpleWaterNormalMethod:SimpleWaterNormalMethod = obj as SimpleWaterNormalMethod;
					asset.texture = GetAsset( simpleWaterNormalMethod.secondaryNormalMap ) as TextureVO;
					break;
				}
			}
					
			return asset;
		}
		private function fillShadowMapper( asset:ShadowMapperVO, obj:ShadowMapperBase ):ShadowMapperVO
		{
			asset.depthMapSize = obj.depthMapSize;
			asset.depthMapSizeCube = obj.depthMapSize;
			asset.type = getQualifiedClassName( obj ).split("::")[1];
			if( obj is NearDirectionalShadowMapper )
			{
				var nearDirectionalShadowMapper:NearDirectionalShadowMapper = obj as NearDirectionalShadowMapper;
				asset.coverage = nearDirectionalShadowMapper.coverageRatio;
			}
			else if( obj is CascadeShadowMapper )
			{
				var cascadeShadowMapper:CascadeShadowMapper = obj as CascadeShadowMapper;
				asset.numCascades = cascadeShadowMapper.numCascades;
			}
			return asset;
		}
		private function fillCubeTexture( asset:CubeTextureVO, item:BitmapCubeTexture ):CubeTextureVO
		{
			asset = fillAsset( asset, item ) as CubeTextureVO;
			asset.positiveX = item.positiveX;
			asset.negativeX = item.negativeX;
			asset.positiveY = item.positiveY;
			asset.negativeY = item.negativeY;
			asset.positiveZ = item.positiveZ;
			asset.negativeZ = item.negativeZ;
			return asset;
		}
		private function fillATFTexture( asset:TextureVO, item:ATFTexture ):TextureVO
		{
			asset = fillAsset( asset, item ) as TextureVO;
			
			//asset.bitmapData = item.atfData.;
			return asset;
		}
		private function fillBitmapTexture( asset:TextureVO, item:BitmapTexture ):TextureVO
		{
			asset = fillAsset( asset, item ) as TextureVO;
			
			asset.bitmapData = item.bitmapData;
			return asset;
		}
		private function fillMaterial( asset:MaterialVO, item:MaterialBase ):MaterialVO
		{
			asset = fillAsset( asset, item ) as MaterialVO;
			
			asset.alphaPremultiplied = item.alphaPremultiplied;
			
			asset.repeat = item.repeat;
			asset.bothSides = item.bothSides;
			asset.extra = item.extra;
			asset.lightPicker = GetAsset(item.lightPicker) as LightPickerVO;
			asset.mipmap = item.mipmap;
			asset.smooth = item.smooth;
			asset.blendMode = item.blendMode;
			
			if( item is TextureMaterial )
			{
				asset.type = MaterialVO.SINGLEPASS;
				var textureMaterial:TextureMaterial = item as TextureMaterial;
				asset.alphaThreshold = textureMaterial.alphaThreshold;
				asset.alpha = textureMaterial.alpha;
				
				asset.alphaBlending = textureMaterial.alphaBlending;
				asset.colorTransform = textureMaterial.colorTransform;
				
				asset.ambientLevel = textureMaterial.ambient; 
				asset.ambientColor = textureMaterial.ambientColor;
				asset.ambientTexture = GetAsset( textureMaterial.ambientTexture ) as TextureVO;
				asset.ambientMethod = GetAsset( textureMaterial.ambientMethod ) as ShadingMethodVO;
				
				asset.diffuseColor= textureMaterial.diffuseMethod.diffuseColor;
				asset.diffuseTexture = GetAsset( textureMaterial.texture ) as TextureVO;
				asset.diffuseMethod = GetAsset( textureMaterial.diffuseMethod ) as ShadingMethodVO;
				
				asset.specularLevel = textureMaterial.specular;
				asset.specularColor = textureMaterial.specularColor;
				asset.specularGloss = textureMaterial.gloss;
				asset.specularTexture = GetAsset( textureMaterial.specularMap ) as TextureVO;
				asset.specularMethod = GetAsset( textureMaterial.specularMethod ) as ShadingMethodVO;
				
				asset.normalTexture = GetAsset( textureMaterial.normalMap ) as TextureVO;
				asset.normalMethod = GetAsset( textureMaterial.normalMethod ) as ShadingMethodVO;
				
				asset.shadowMethod = GetAsset( textureMaterial.shadowMethod ) as ShadowMethodVO;
			}
			else if( item is ColorMaterial )
			{
				asset.type = MaterialVO.SINGLEPASS;
				var colorMaterial:ColorMaterial = item as ColorMaterial;
				asset.alpha = colorMaterial.alpha;
				asset.alphaThreshold = colorMaterial.alphaThreshold;
				
				asset.alphaBlending = colorMaterial.alphaBlending;
				
				asset.ambientLevel = colorMaterial.ambient; 
				asset.ambientColor = colorMaterial.ambientColor;
				asset.ambientTexture = null;
				asset.ambientMethod = GetAsset( colorMaterial.ambientMethod ) as ShadingMethodVO;
				
				asset.diffuseColor= colorMaterial.diffuseMethod.diffuseColor;
				asset.diffuseTexture = null;
				asset.diffuseMethod = GetAsset( colorMaterial.diffuseMethod ) as ShadingMethodVO;
				
				asset.specularLevel = colorMaterial.specular;
				asset.specularColor = colorMaterial.specularColor;
				asset.specularGloss = colorMaterial.gloss;
				asset.specularTexture = GetAsset( colorMaterial.specularMap ) as TextureVO;
				asset.specularMethod = GetAsset( colorMaterial.specularMethod ) as ShadingMethodVO;
				
				asset.normalTexture = GetAsset( colorMaterial.normalMap ) as TextureVO;
				asset.normalMethod = GetAsset( colorMaterial.normalMethod ) as ShadingMethodVO;
				
				asset.shadowMethod = GetAsset( colorMaterial.shadowMethod ) as ShadowMethodVO;
			}
			else if( item is TextureMultiPassMaterial )
			{
				asset.type = MaterialVO.MULTIPASS;
				var textureMultiPassMaterial:TextureMultiPassMaterial = item as TextureMultiPassMaterial;
				asset.alphaThreshold = textureMultiPassMaterial.alphaThreshold;
				//asset.alphaBlending = textureMultiPassMaterial.alphaBlending;
				//asset.colorTransform = textureMultiPassMaterial.colorTransform;
				
				asset.ambientLevel = textureMultiPassMaterial.ambient; 
				asset.ambientColor = textureMultiPassMaterial.ambientColor;
				asset.ambientTexture = GetAsset( textureMultiPassMaterial.ambientTexture ) as TextureVO;
				asset.ambientMethod = GetAsset( textureMultiPassMaterial.ambientMethod ) as ShadingMethodVO;
				
				asset.diffuseColor= textureMultiPassMaterial.diffuseMethod.diffuseColor;
				asset.diffuseTexture = GetAsset( textureMultiPassMaterial.texture ) as TextureVO;
				asset.diffuseMethod = GetAsset( textureMultiPassMaterial.diffuseMethod ) as ShadingMethodVO;
				
				asset.specularLevel = textureMultiPassMaterial.specular;
				asset.specularColor = textureMultiPassMaterial.specularColor;
				asset.specularGloss = textureMultiPassMaterial.gloss;
				asset.specularTexture = GetAsset( textureMultiPassMaterial.specularMap ) as TextureVO;
				asset.specularMethod = GetAsset( textureMultiPassMaterial.specularMethod ) as ShadingMethodVO;
				
				asset.normalTexture = GetAsset( textureMultiPassMaterial.normalMap ) as TextureVO;
				asset.normalMethod = GetAsset( textureMultiPassMaterial.normalMethod ) as ShadingMethodVO;
				
				asset.shadowMethod = GetAsset( textureMultiPassMaterial.shadowMethod ) as ShadowMethodVO;
			}
			else if( item is ColorMultiPassMaterial )
			{
				asset.type = MaterialVO.MULTIPASS;
				var colorMultiPassMaterial:ColorMultiPassMaterial = item as ColorMultiPassMaterial;
				asset.alphaThreshold = colorMultiPassMaterial.alphaThreshold;
				
				
				asset.ambientLevel = colorMultiPassMaterial.ambient; 
				asset.ambientColor = colorMultiPassMaterial.ambientColor;
				asset.ambientTexture = null;
				asset.ambientMethod = GetAsset( colorMultiPassMaterial.ambientMethod ) as ShadingMethodVO;
				
				asset.diffuseColor= colorMultiPassMaterial.diffuseMethod.diffuseColor;
				asset.diffuseTexture = null;
				asset.diffuseMethod = GetAsset( colorMultiPassMaterial.diffuseMethod ) as ShadingMethodVO;
				
				asset.specularLevel = colorMultiPassMaterial.specular;
				asset.specularColor = colorMultiPassMaterial.specularColor;
				asset.specularGloss = colorMultiPassMaterial.gloss;
				asset.specularTexture = GetAsset( colorMultiPassMaterial.specularMap ) as TextureVO;
				asset.specularMethod = GetAsset( colorMultiPassMaterial.specularMethod ) as ShadingMethodVO;
				
				asset.normalTexture = GetAsset( colorMultiPassMaterial.normalMap ) as TextureVO;
				asset.normalMethod = GetAsset( colorMultiPassMaterial.normalMethod ) as ShadingMethodVO;
				
				asset.shadowMethod = GetAsset( colorMultiPassMaterial.shadowMethod ) as ShadowMethodVO;
			}
			
			asset.effectMethods = new ArrayCollection();
			if( item is SinglePassMaterialBase )
			{
				var singlePassMaterialBase:SinglePassMaterialBase = item as SinglePassMaterialBase;
				asset.alphaThreshold = singlePassMaterialBase.alphaThreshold;
				for (var i:int = 0; i < singlePassMaterialBase.numMethods; i++) 
				{
					asset.effectMethods.addItem( new SharedEffectVO( GetAsset(singlePassMaterialBase.getMethodAt( i )) as EffectVO ) );
				}
			}
			
			// shadowMethods loaded not from lights, so lights know nothing about them directly
			if( asset.shadowMethod )
			{
				asset.light = asset.shadowMethod.castingLight;
				
				var alreadyAdded:Boolean = false;
				for each( var method:ShadowMethodVO in asset.light.shadowMethods )
				{
					if( method.equals( asset.shadowMethod ) ) alreadyAdded = true;	
				}
				if( !alreadyAdded )	asset.light.shadowMethods.addItem( asset.shadowMethod );
			}
			
			return asset;
		}
		private function fillMesh( asset:MeshVO, item:Mesh ):MeshVO
		{
			asset = fillContainer( asset, item ) as MeshVO;
			asset.castsShadows = item.castsShadows;
			asset.subMeshes = new ArrayCollection();
			asset.geometry = GetAsset(item.geometry) as GeometryVO;
			asset.animator = GetAsset(item.animator) as AnimatorVO;
			for each( var subMesh:SubMesh in item.subMeshes )
			{
				var sm:SubMeshVO = GetAsset(subMesh) as SubMeshVO;
				sm.parentMesh = asset;
				if( sm.subGeometry.type == "SkinnedSubGeometry" )
				{
					asset.jointsPerVertex = SkinnedSubGeometry(subMesh.subGeometry).arcane::jointWeightsData.length / SkinnedSubGeometry(subMesh.subGeometry).numVertices;
				}
				asset.subMeshes.addItem( sm );
			}
			
			// animators loaded not from animationSet, so animationSets know nothing about them directly
			if( asset.animator )
			{
				var alreadyAdded:Boolean = false;
				for each( var animator:AnimatorVO in asset.animator.animationSet.animators )
				{
					if( animator.equals( asset.animator ) ) alreadyAdded = true;	
				}
				if( !alreadyAdded )	asset.animator.animationSet.animators.addItem( asset.animator );
			}
			
			return asset;
		}
		private function fillContainer( asset:ContainerVO, item:ObjectContainer3D ):ContainerVO
		{
			asset = fillObject( asset, item ) as ContainerVO;
			asset.children = new ArrayCollection();
			for (var i:int = 0; i < item.numChildren; i++) 
			{
				asset.children.addItem(GetAsset( item.getChildAt(i) ) );
			}
			return asset;
		}
		private function fillObject( asset:ObjectVO, item:Object3D ):ObjectVO
		{
			asset = fillAsset( asset, item ) as ObjectVO;
			asset.x = item.x;
			asset.y = item.y;
			asset.z = item.z;
			asset.pivotX = item.pivotPoint.x;
			asset.pivotY = item.pivotPoint.y;
			asset.pivotZ = item.pivotPoint.z;
			asset.scaleX = item.scaleX;
			asset.scaleY = item.scaleY;
			asset.scaleZ = item.scaleZ;
			asset.rotationX = item.rotationX;
			asset.rotationY = item.rotationY;
			asset.rotationZ = item.rotationZ;
			
			asset.extras = new ArrayCollection();
			
			for( var name:String in item.extra )
			{
				var extra:ExtraItemVO = new ExtraItemVO();
				extra.name = name;
				extra.value = item.extra[name];
				asset.extras.addItem( extra );
			}
				
			return asset;
		}
		private function fillAsset( asset:AssetVO, item:Object ):AssetVO
		{
			if( item is NamedAssetBase )
			{
				asset.name = NamedAssetBase(item).name;
			}
			if( asset.name == null )
			{
				asset.name = getQualifiedClassName( item ).split("::")[1] + AssetUtil.GetNextId(getQualifiedClassName( item ).split("::")[1]);
			}
			return asset;
		}
		
		protected function createDefaults():void 
		{
			if( !_defaultTexture )
			{
				var texture:BitmapTexture = DefaultMaterialManager.getDefaultTexture();
				texture.name = "Default";
				_defaultTexture = GetAsset( texture ) as TextureVO;
				_defaultTexture.isDefault = true;
			}
			if( !_defaultMaterial )
			{
				var material:TextureMaterial = DefaultMaterialManager.getDefaultMaterial();
				material.name = "Default";
				material.texture = DefaultMaterialManager.getDefaultTexture();
				material.repeat=true;
				_defaultMaterial = GetAsset( material ) as MaterialVO;
				_defaultMaterial.isDefault = true;
			}
			if( !_defaultCubeTexture )
			{
				var bitmap:BitmapData = getChekerboard();
				var cubeTexture:BitmapCubeTexture = new BitmapCubeTexture( bitmap, bitmap, bitmap, bitmap, bitmap, bitmap );
				cubeTexture.name = "CubeDefault";
				_defaultCubeTexture = GetAsset( cubeTexture ) as CubeTextureVO;
				_defaultCubeTexture.isDefault = true;
			}
		}
		protected function getChekerboard( color:uint = 0xFFFFFF ):BitmapData
		{
			var bitmap:BitmapData = new BitmapData(8, 8, false, 0x0);
			for( var i:uint=0; i<8*8; i+=2 ) //create chekerboard
			{
				bitmap.setPixel(i%8 + Math.floor(i/8)%2, Math.floor(i/8), color);
			}
			return bitmap;
		}
		
		protected var _assets:Dictionary = new Dictionary();
		protected var _objectsByAsset:Dictionary = new Dictionary();
		
		private var _defaultMaterial:MaterialVO;
		public function get defaultMaterial():MaterialVO
		{
			if( !_defaultMaterial )
			{
				createDefaults();
			}
			return _defaultMaterial;
		}
		
		private var _defaultTexture:TextureVO;
		public function get defaultTexture():TextureVO
		{
			if( !_defaultTexture )
			{
				createDefaults();
			}
			return _defaultTexture;
		}
		
		private var _defaultCubeTexture:CubeTextureVO;
		public function get defaultCubeTexture():CubeTextureVO
		{
			if( !_defaultCubeTexture )
			{
				createDefaults();
			}
			return _defaultCubeTexture;
		}
		
		public function Clear():void
		{
			_defaultMaterial = null;
			_defaultCubeTexture = null;
			_defaultTexture = null;
			_assets = new Dictionary();
			_objectsByAsset = new Dictionary();
			AssetUtil.Clear();
		}
	}
}