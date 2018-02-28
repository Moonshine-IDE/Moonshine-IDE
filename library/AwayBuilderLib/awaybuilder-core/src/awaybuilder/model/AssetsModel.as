package awaybuilder.model
{
	import away3d.animators.AnimationSetBase;
	import away3d.animators.AnimatorBase;
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.VertexAnimationSet;
	import away3d.animators.VertexAnimator;
	import away3d.animators.data.Skeleton;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.LensBase;
	import away3d.cameras.lenses.OrthographicLens;
	import away3d.cameras.lenses.OrthographicOffCenterLens;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.entities.TextureProjector;
	import away3d.library.assets.IAsset;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.lights.shadowmaps.CascadeShadowMapper;
	import away3d.lights.shadowmaps.CubeMapShadowMapper;
	import away3d.lights.shadowmaps.DirectionalShadowMapper;
	import away3d.lights.shadowmaps.NearDirectionalShadowMapper;
	import away3d.lights.shadowmaps.ShadowMapperBase;
	import away3d.materials.SinglePassMaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.AlphaMaskMethod;
	import away3d.materials.methods.AnisotropicSpecularMethod;
	import away3d.materials.methods.BasicAmbientMethod;
	import away3d.materials.methods.BasicDiffuseMethod;
	import away3d.materials.methods.BasicNormalMethod;
	import away3d.materials.methods.BasicSpecularMethod;
	import away3d.materials.methods.CascadeShadowMapMethod;
	import away3d.materials.methods.CelDiffuseMethod;
	import away3d.materials.methods.CelSpecularMethod;
	import away3d.materials.methods.ColorMatrixMethod;
	import away3d.materials.methods.ColorTransformMethod;
	import away3d.materials.methods.DitheredShadowMapMethod;
	import away3d.materials.methods.EffectMethodBase;
	import away3d.materials.methods.EnvMapAmbientMethod;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.FogMethod;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.GradientDiffuseMethod;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.materials.methods.HeightMapNormalMethod;
	import away3d.materials.methods.LightMapDiffuseMethod;
	import away3d.materials.methods.LightMapMethod;
	import away3d.materials.methods.NearShadowMapMethod;
	import away3d.materials.methods.OutlineMethod;
	import away3d.materials.methods.PhongSpecularMethod;
	import away3d.materials.methods.ProjectiveTextureMethod;
	import away3d.materials.methods.RefractionEnvMapMethod;
	import away3d.materials.methods.RimLightMethod;
	import away3d.materials.methods.ShadingMethodBase;
	import away3d.materials.methods.SimpleWaterNormalMethod;
	import away3d.materials.methods.SoftShadowMapMethod;
	import away3d.materials.methods.SubsurfaceScatteringDiffuseMethod;
	import away3d.materials.methods.WrapDiffuseMethod;
	import away3d.primitives.CapsuleGeometry;
	import away3d.primitives.ConeGeometry;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.PrimitiveBase;
	import away3d.primitives.SkyBox;
	import away3d.primitives.SphereGeometry;
	import away3d.primitives.TorusGeometry;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.CubeTextureBase;
	import away3d.textures.Texture2DBase;
	
	import awaybuilder.model.vo.scene.AnimationSetVO;
	import awaybuilder.model.vo.scene.AnimatorVO;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.CameraVO;
	import awaybuilder.model.vo.scene.ContainerVO;
	import awaybuilder.model.vo.scene.CubeTextureVO;
	import awaybuilder.model.vo.scene.EffectVO;
	import awaybuilder.model.vo.scene.GeometryVO;
	import awaybuilder.model.vo.scene.LensVO;
	import awaybuilder.model.vo.scene.LightPickerVO;
	import awaybuilder.model.vo.scene.LightVO;
	import awaybuilder.model.vo.scene.MaterialVO;
	import awaybuilder.model.vo.scene.MeshVO;
	import awaybuilder.model.vo.scene.ShadingMethodVO;
	import awaybuilder.model.vo.scene.ShadowMapperVO;
	import awaybuilder.model.vo.scene.ShadowMethodVO;
	import awaybuilder.model.vo.scene.SkeletonVO;
	import awaybuilder.model.vo.scene.SkyBoxVO;
	import awaybuilder.model.vo.scene.TextureProjectorVO;
	import awaybuilder.utils.AssetUtil;
	
	import flash.geom.ColorTransform;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.UIDUtil;

	public class AssetsModel extends SmartFactoryModelBase
	{
		public function GetObjectsByType( type:Class, property:String=null, value:Object=null ):Vector.<Object> 
		{
			var objects:Vector.<Object> = new Vector.<Object>();
			for (var object:Object in _assets)
			{
				if( object is type )
				{
					if( property )
					{
						if( (object[property] == value) ) 
						{
							objects.push( object );
						}
					}
					else 
					{
						objects.push( object );
					}
				}
			}
			return objects;
		}
		public function RemoveObject( obj:Object ):void 
		{
			var asset:AssetVO = _assets[obj] as AssetVO;
			delete _objectsByAsset[asset];
			delete _assets[obj];
		}
		public function ReplaceObject( oldObject:Object, newObject:Object ):void 
		{
			var asset:AssetVO = _assets[oldObject];
			
			_objectsByAsset[asset] = newObject;
			_assets[newObject] = asset;
			
			delete _assets[oldObject];
		}
		public function GetObject( asset:AssetVO ):Object 
		{
			if( !asset ) return null;
			return _objectsByAsset[asset];
		}
		override public function GetAsset( obj:Object ):AssetVO
		{
			if( !obj ) return null;
			
			if( _assets[obj] ) return _assets[obj];
			
			var asset:AssetVO = createAsset( obj );
			if ((obj is IAsset) && (obj.id))
			{
				asset.id = obj.id;
			}
			else
			{
				asset.id = UIDUtil.createUID();
				if (obj is IAsset)
				{
					obj.id = asset.id;
				}
			}
			
			_assets[obj] = asset;
			_objectsByAsset[asset] = obj;
			return asset;
		}
		public function CreateAnimationSet( type:String ):AnimationSetVO
		{
			var animation:AnimationSetBase;
			switch( type )
			{
				case "VertexAnimationSet":
					animation = new VertexAnimationSet();
					animation.name =  "VertexAnimationSet" + AssetUtil.GetNextId("VertexAnimationSet");
					break;
				case "SkeletonAnimationSet":
					animation = new SkeletonAnimationSet();
					animation.name =  "SkeletonAnimationSet" + AssetUtil.GetNextId("SkeletonAnimationSet");
					break;
			}
			return GetAsset( animation ) as AnimationSetVO;
		}
		public function CreateAnimator( type:String, animationSet:AnimationSetVO, skeleton:SkeletonVO=null ):AnimatorVO
		{
			var animator:AnimatorBase;
			switch( type )
			{
				case "UVAnimator":
					break;
				case "ParticleAnimator":
					break;
				case "SkeletonAnimator":
					animator = new SkeletonAnimator(GetObject(animationSet) as SkeletonAnimationSet,GetObject(skeleton) as Skeleton );
					animator.name =  "SkeletonAnimator" + AssetUtil.GetNextId("SkeletonAnimator");
					break;
				case "VertexAnimator":
					animator = new VertexAnimator(GetObject(animationSet) as VertexAnimationSet);
					animator.name =  "VertexAnimator" + AssetUtil.GetNextId("VertexAnimator");
					break;
			}
			animator.updatePosition = false;
			return GetAsset( animator ) as AnimatorVO;
		}
		
		public function CreateMaterial( clone:MaterialVO = null ):MaterialVO
		{
			if( !clone )
			{
				clone = defaultMaterial;
			}
			var newMaterial:SinglePassMaterialBase;
			var textureMaterial:TextureMaterial = GetObject(clone) as TextureMaterial;
			newMaterial = new TextureMaterial( textureMaterial.texture, textureMaterial.smooth, textureMaterial.repeat, textureMaterial.mipmap );
			newMaterial.name = "Material" + AssetUtil.GetNextId("Material");
			newMaterial.gloss = 50;
			return GetAsset(newMaterial) as MaterialVO;
		}
		
		public function CreateLens( type:String ):LensVO
		{
			var lens:LensBase = new LensBase();
			switch( type )
			{
				case "PerspectiveLens":
					lens = new PerspectiveLens();
					break;
				case "OrthographicLens":
					lens = new OrthographicLens( 600 );
					break;
				case "OrthographicOffCenterLens":
					lens = new OrthographicOffCenterLens( -400, 400, -300, 300 );
					break;
			}
			return GetAsset(lens) as LensVO;
		}
		
		public function CreateCamera():CameraVO
		{
			var camera:Camera3D = new Camera3D();
			camera.name = "Camera" + AssetUtil.GetNextId("Camera");
			camera.x = camera.y = camera.z = 0;
			return GetAsset(camera) as CameraVO;
		}
		public function CreateProjectiveTextureMethod( textureProjector:TextureProjectorVO ):EffectVO
		{
			var method:EffectMethodBase = new ProjectiveTextureMethod( GetObject(textureProjector) as TextureProjector );
			method.name =  "ProjectiveTexture " + AssetUtil.GetNextId("ProjectiveTexture");
			
			return GetAsset( method ) as EffectVO;
		}
		public function CreateEffectMethod( type:String ):EffectVO
		{
			var method:EffectMethodBase;
			switch( type )
			{
				case "LightMapMethod":
					method = new LightMapMethod(GetObject(defaultTexture) as Texture2DBase);
					method.name =  "LightMap" + AssetUtil.GetNextId("LightMapMethod");
					break;
				case "RimLightMethod":
					method = new RimLightMethod();
					method.name =  "RimLight" + AssetUtil.GetNextId("RimLightMethod");
					break;
				case "ColorTransformMethod":
					method = new ColorTransformMethod();
					ColorTransformMethod(method).colorTransform = new ColorTransform();
					method.name =  "ColorTransform" + AssetUtil.GetNextId("ColorTransformMethod");
					break;
				case "AlphaMaskMethod":
					method = new AlphaMaskMethod(GetObject(defaultTexture) as Texture2DBase, false);
					method.name =  "AlphaMask" + AssetUtil.GetNextId("AlphaMaskMethod");
					break;
				case "ColorMatrixMethod":
					method = new ColorMatrixMethod([ 0.2225, 0.7169, 0.0606, 0, 0, 0.2225, 0.7169, 0.0606, 0, 0, 0.2225, 0.7169, 0.0606, 0, 0, 0, 0, 0, 1, 1]);
					method.name =  "ColorMatrix" + AssetUtil.GetNextId("ColorMatrixMethod");
					break;
				case "RefractionEnvMapMethod":
					method = new RefractionEnvMapMethod( GetObject(defaultCubeTexture) as CubeTextureBase );
					method.name =  "RefractionEnvMap" + AssetUtil.GetNextId("RefractionEnvMapMethod");
					break;
				case "OutlineMethod":
					method = new OutlineMethod();
					method.name =  "Outline" + AssetUtil.GetNextId("OutlineMethod");
					break;
				case "FresnelEnvMapMethod":
					method = new FresnelEnvMapMethod( GetObject(defaultCubeTexture) as CubeTextureBase );
					method.name =  "FresnelEnvMap" + AssetUtil.GetNextId("FresnelEnvMapMethod");
					break;
				case "FogMethod":
					method = new FogMethod(0,1000);
					method.name =  "Fog" + AssetUtil.GetNextId("FogMethod");
					break;
				case "EnvMapMethod":
					method = new EnvMapMethod( GetObject(defaultCubeTexture) as CubeTextureBase );
					method.name =  "EnvMap" + AssetUtil.GetNextId("EnvMapMethod");
					EnvMapMethod(method).mask = GetObject(defaultTexture) as Texture2DBase;
					break;
			}
			return GetAsset( method ) as EffectVO;
		}
		public function CreateSkyBox():SkyBoxVO
		{
			var mesh:SkyBox = new SkyBox( GetObject(defaultCubeTexture) as CubeTextureBase );
			mesh.name = "SkyBox" + AssetUtil.GetNextId("SkyBox");
			return GetAsset( mesh ) as SkyBoxVO;
		}
		public function CreateTextureProjector():TextureProjectorVO
		{
			var projector:TextureProjector = new TextureProjector( GetObject(defaultTexture) as Texture2DBase );
			projector.name = "TextureProjector" + AssetUtil.GetNextId("TextureProjector");
			return GetAsset( projector ) as TextureProjectorVO;
		}
		public function CreateContainer():ContainerVO
		{
			var obj:ObjectContainer3D = new ObjectContainer3D();
			obj.name = "Container" + AssetUtil.GetNextId("ObjectContainer3D");
			return GetAsset( obj ) as ContainerVO;
		}
		public function CreateMesh( geometry:GeometryVO ):MeshVO
		{
			var mesh:Mesh = new Mesh( GetObject(geometry) as Geometry );
			mesh.name = "Mesh" + AssetUtil.GetNextId("Mesh");
			return GetAsset( mesh ) as MeshVO;
		}
		public function CreateGeometry( type:String ):GeometryVO
		{
			var georM:TorusGeometry
			var geometry:PrimitiveBase;
			switch( type )
			{
				case "PlaneGeometry":
					geometry = new PlaneGeometry();
					geometry.name = "PlaneGeometry" + AssetUtil.GetNextId("PlaneGeometry");
					break;
				case "CubeGeometry":
					geometry = new CubeGeometry();
					geometry.name = "CubeGeometry" + AssetUtil.GetNextId("CubeGeometry");
					break;
				case "SphereGeometry":
					geometry = new SphereGeometry();
					geometry.name = "SphereGeometry" + AssetUtil.GetNextId("SphereGeometry");
					break;
				case "CylinderGeometry":
					geometry = new CylinderGeometry();
					geometry.name = "CylinderGeometry" + AssetUtil.GetNextId("CylinderGeometry");
					break;
				case "ConeGeometry":
					geometry = new ConeGeometry();
					geometry.name = "ConeGeometry" + AssetUtil.GetNextId("ConeGeometry");
					break;
				case "CapsuleGeometry":
					geometry = new CapsuleGeometry();
					geometry.name = "CapsuleGeometry" + AssetUtil.GetNextId("CapsuleGeometry");
					break;
				case "TorusGeometry":
					geometry = new TorusGeometry();
					geometry.name = "TorusGeometry" + AssetUtil.GetNextId("TorusGeometry");
					break;
			}
			return GetAsset( geometry ) as GeometryVO;
		}
		public function CreateCubeTexture():CubeTextureVO
		{
			var light:BitmapCubeTexture = new BitmapCubeTexture( getChekerboard(0xFFFFFF), getChekerboard(0xAAAAAA), getChekerboard(0xEEEEEE), getChekerboard(0xDDDDDD), getChekerboard(0xCCCCCC), getChekerboard(0xBBBBBB) );
			light.name = "Cube " + AssetUtil.GetNextId("Cube");
			return GetAsset( light ) as CubeTextureVO;
		}
		public function CreateDirectionalLight():LightVO
		{
			var light:DirectionalLight = new DirectionalLight();
			light.name = "DirectionalLight " + AssetUtil.GetNextId("directionalLight");
			light.castsShadows = false;
			return GetAsset( light ) as LightVO;
		}
		public function CreatePointLight():LightVO
		{
			var light:PointLight = new PointLight();
			light.name = "PointLight " + AssetUtil.GetNextId("pointLight");
			light.radius = 1000;
			light.fallOff = 3000;
			light.castsShadows = false;
			return GetAsset( light ) as LightVO;
		}
		public function CreateLightPicker():LightPickerVO
		{
			var lightPicker:StaticLightPicker = new StaticLightPicker([]);
			lightPicker.name = "Light Picker " + AssetUtil.GetNextId("lightPicker");
			return GetAsset( lightPicker ) as LightPickerVO;
		}
		
		public function CreateFilteredShadowMapMethod( light:LightVO ):ShadowMethodVO
		{
			var method:FilteredShadowMapMethod = new FilteredShadowMapMethod( GetObject(light) as DirectionalLight );
			method.name = "FilteredShadow" + AssetUtil.GetNextId("FilteredShadowMapMethod");
			return GetAsset( method ) as ShadowMethodVO;
		}
		public function CreateDitheredShadowMapMethod( light:LightVO ):ShadowMethodVO
		{
			var method:DitheredShadowMapMethod = new DitheredShadowMapMethod( GetObject(light) as DirectionalLight );
			method.name = "DitheredShadow" + AssetUtil.GetNextId("DitheredShadowMapMethod");
			return GetAsset( method ) as ShadowMethodVO;
		}
		public function CreateSoftShadowMapMethod( light:LightVO ):ShadowMethodVO
		{
			var method:SoftShadowMapMethod = new SoftShadowMapMethod( GetObject(light) as DirectionalLight );
			method.name = "SoftShadow" + AssetUtil.GetNextId("SoftShadowMapMethod");
			return GetAsset( method ) as ShadowMethodVO;
		}
		public function CreateHardShadowMapMethod( light:LightVO ):ShadowMethodVO
		{
			var method:HardShadowMapMethod = new HardShadowMapMethod( GetObject(light) as LightBase );
			method.name = "HardShadow" + AssetUtil.GetNextId("HardShadowMapMethod");
			return GetAsset( method ) as ShadowMethodVO;
		}
		public function CreateNearShadowMapMethod( light:LightVO ):ShadowMethodVO
		{
			var simple:SoftShadowMapMethod = new SoftShadowMapMethod( GetObject(light) as DirectionalLight );
			var method:NearShadowMapMethod = new NearShadowMapMethod( simple );
			method.name = "NearShadow" + AssetUtil.GetNextId("NearShadowMapMethod");
			var asset:ShadowMethodVO = GetAsset( method ) as ShadowMethodVO;;
			asset.baseMethod = GetAsset( simple ) as ShadowMethodVO;
			return asset;
		}
		public function CreateCascadeShadowMapMethod( light:LightVO ):ShadowMethodVO
		{
			var simple:SoftShadowMapMethod = new SoftShadowMapMethod( GetObject(light) as DirectionalLight );
			var method:CascadeShadowMapMethod = new CascadeShadowMapMethod( simple );
			method.name = "CascadeShadow" + AssetUtil.GetNextId("CascadeShadowMapMethod");
			return GetAsset( method ) as ShadowMethodVO;
		}
		public function CreateShadingMethod( type:String ):ShadingMethodVO
		{
			var baseMethod:ShadingMethodBase;
			var method:ShadingMethodBase;
			switch( type )
			{
				case "BasicAmbientMethod":
					method = new BasicAmbientMethod();
					break;
				case "EnvMapAmbientMethod":
					method = new EnvMapAmbientMethod(GetObject(defaultCubeTexture) as CubeTextureBase);
					break;
				case "BasicDiffuseMethod":
					method = new BasicDiffuseMethod();
					break;
				case "GradientDiffuseMethod":
					method = new GradientDiffuseMethod(GetObject(defaultTexture) as Texture2DBase);
					break;
				case "WrapDiffuseMethod":
					method = new WrapDiffuseMethod();
					break;
				case "LightMapDiffuseMethod":
					baseMethod = new BasicDiffuseMethod();
					method = new LightMapDiffuseMethod(GetObject(defaultTexture) as Texture2DBase,"multiply",false, baseMethod as BasicDiffuseMethod);
					break;
				case "CelDiffuseMethod":
					baseMethod = new BasicDiffuseMethod();
					method = new CelDiffuseMethod(3,baseMethod as BasicDiffuseMethod);
					break;
				case "SubsurfaceScatteringDiffuseMethod":
					baseMethod = new BasicDiffuseMethod();
					method = new SubsurfaceScatteringDiffuseMethod();
//					SubsurfaceScatteringDiffuseMethod(method).baseMethod = baseMethod as BasicDiffuseMethod;
					break;
				case "BasicSpecularMethod":
					method = new BasicSpecularMethod();
					break;
				case "AnisotropicSpecularMethod":
					method = new AnisotropicSpecularMethod();
					break;
				case "PhongSpecularMethod":
					method = new PhongSpecularMethod();
					break;
				case "CelSpecularMethod":
					method = new CelSpecularMethod();
					break;
				case "FresnelSpecularMethod":
					baseMethod = new BasicSpecularMethod();
					method = new FresnelSpecularMethod( true, baseMethod as BasicSpecularMethod );
					break;
				case "BasicNormalMethod":
					method = new BasicNormalMethod();
					break;
				case "HeightMapNormalMethod":
					method = new HeightMapNormalMethod(GetObject(defaultTexture) as Texture2DBase,5,5,5);
					break;
				case "SimpleWaterNormalMethod":
					method = new SimpleWaterNormalMethod(GetObject(defaultTexture) as Texture2DBase,GetObject(defaultTexture) as Texture2DBase);
					break;
				
			}
			return GetAsset( method ) as ShadingMethodVO;
		}
		public function CreateShadowMapper( type:String ):ShadowMapperVO
		{
			var mapper:ShadowMapperBase;
			switch( type )
			{
				case "DirectionalShadowMapper":
					mapper = new DirectionalShadowMapper();
					break;
				case "CascadeShadowMapper":
					mapper = new CascadeShadowMapper();
					break;
				case "NearDirectionalShadowMapper":
					mapper = new NearDirectionalShadowMapper();
					break;
				case "CubeMapShadowMapper":
					mapper = new CubeMapShadowMapper();
					break;
			}
			
			return GetAsset( mapper ) as ShadowMapperVO;
		}
		public function checkEffectMethodForDefaulttexture( method:EffectMethodBase ):void
		{
			if (method is EnvMapMethod ){
				if(EnvMapMethod (method).envMap.name=="defaultTexture"){
					EnvMapMethod (method).envMap=GetObject(defaultCubeTexture) as BitmapCubeTexture;
				}
				if(EnvMapMethod (method).mask){
					if(EnvMapMethod (method).mask.name=="defaultTexture"){
						EnvMapMethod (method).mask=GetObject(defaultTexture) as Texture2DBase;
					}
				}
			}
			if (method is LightMapMethod){
				if(LightMapMethod (method).texture.name=="defaultTexture"){
					LightMapMethod (method).texture=GetObject(defaultTexture) as Texture2DBase;
				}
			}
			if (method is AlphaMaskMethod){
				if(AlphaMaskMethod (method).texture.name=="defaultTexture"){
					AlphaMaskMethod (method).texture=GetObject(defaultTexture) as Texture2DBase;
				}
			}
			if (method is RefractionEnvMapMethod){
				if(RefractionEnvMapMethod (method).envMap.name=="defaultTexture"){
					RefractionEnvMapMethod (method).envMap=GetObject(defaultCubeTexture) as BitmapCubeTexture;
				}
			}
			if (method is FresnelEnvMapMethod){
				if(FresnelEnvMapMethod(method).envMap.name=="defaultTexture"){
					FresnelEnvMapMethod (method).envMap=GetObject(defaultCubeTexture) as BitmapCubeTexture;
				}
			}
			
		}
			
		public function checkIfMaterialIsDefault( mat:TextureMaterial ):Boolean
		{
			var defaultMat:TextureMaterial=GetObject(defaultMaterial) as TextureMaterial;
			//first check the textures (before returning false);
			if (mat.normalMap)
				if (mat.normalMap.name=="defaultTexture") mat.normalMap=GetObject(defaultTexture) as Texture2DBase;
			if (mat.specularMap)
				if (mat.specularMap.name=="defaultTexture") mat.texture=GetObject(defaultTexture) as Texture2DBase;
			if (mat.ambientTexture)
				if (mat.ambientTexture.name=="defaultTexture") mat.texture=GetObject(defaultTexture) as Texture2DBase;		
			if (mat.texture)	
				if (mat.texture.name=="defaultTexture") mat.texture=GetObject(defaultTexture) as Texture2DBase;
			
			var i:int;
			for (i=0;i<mat.numMethods;i++){
				checkEffectMethodForDefaulttexture(mat.getMethodAt(i));
			}
			// now all texutures are checked and replaced with defaults
			// check each material-property, and return false, if it is not default
			if ((mat.name!="Default")&& (mat.name!="defaultMaterial"))return false;
			if (getQualifiedClassName( mat.ambientMethod ).split("::")[1]!="BasicAmbientMethod")return false;
			if (getQualifiedClassName( mat.diffuseMethod ).split("::")[1]!="BasicDiffuseMethod")return false;
			if (getQualifiedClassName( mat.specularMethod ).split("::")[1]!="BasicSpecularMethod")return false;
			if (getQualifiedClassName( mat.normalMethod ).split("::")[1]!="BasicNormalMethod")return false;
			if (mat.numMethods!=defaultMat.numMethods)return false;
			if (mat.alpha!=defaultMat.alpha)return false;
			if (mat.alphaBlending!=defaultMat.alphaBlending)return false;
			if (mat.alphaPremultiplied!=defaultMat.alphaPremultiplied)return false;
			if (mat.alphaThreshold!=defaultMat.alphaThreshold)return false;
			if (mat.ambient!=defaultMat.ambient)return false;
			if (mat.ambientColor!=defaultMat.ambientColor)return false;
			if (mat.blendMode!=defaultMat.blendMode)return false;
			if (mat.bothSides!=defaultMat.bothSides)return false;
			if (mat.gloss!=defaultMat.gloss)return false;
			//if (mat.mipmap!=defaultMat.mipmap)return false;
			//if (mat.smooth!=defaultMat.smooth)return false;
			if (mat.specular!=defaultMat.specular)return false;
			if (mat.specularColor!=defaultMat.specularColor)return false;
			
			if (mat.normalMap!=defaultMat.normalMap)return false;
			if (mat.texture!=defaultMat.texture)return false;
			if (mat.specularMap!=defaultMat.specularMap)return false;
			if (mat.specularMap!=defaultMat.specularMap)return false;
			
			return true;
			
		}
			
		
	}
}