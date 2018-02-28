package awaybuilder.model
{
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.model.vo.DocumentVO;
	import awaybuilder.model.vo.GlobalOptionsVO;
	import awaybuilder.model.vo.scene.AnimationNodeVO;
	import awaybuilder.model.vo.scene.AnimationSetVO;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.ContainerVO;
	import awaybuilder.model.vo.scene.CubeTextureVO;
	import awaybuilder.model.vo.scene.EffectVO;
	import awaybuilder.model.vo.scene.GeometryVO;
	import awaybuilder.model.vo.scene.LightPickerVO;
	import awaybuilder.model.vo.scene.LightVO;
	import awaybuilder.model.vo.scene.MaterialVO;
	import awaybuilder.model.vo.scene.ObjectVO;
	import awaybuilder.model.vo.scene.SkeletonVO;
	import awaybuilder.model.vo.scene.TextureVO;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	import org.robotlegs.mvcs.Actor;

	public class DocumentModel extends Actor
	{
		private const _documentVO:DocumentVO = new DocumentVO();
		
		private var _empty:Boolean = true;
		public function get empty():Boolean
		{
			return this._empty;
		}
		public function set empty(value:Boolean):void
		{
			this._empty = value;
		}
		
		private var _name:String;
		public function get name():String
		{
			return this._name;
		}
		public function set name(value:String):void
		{
			if(this._name == value)
			{
				return;
			}
			this._name = value;
			this.dispatch(new DocumentModelEvent(DocumentModelEvent.DOCUMENT_NAME_CHANGED));
		}
		
		private var _edited:Boolean = false;
		public function get edited():Boolean
		{
			return this._edited;
		}
		public function set edited(value:Boolean):void
		{
			if(this._edited == value)
			{
				return;
			}
			this._edited = value;
			this.dispatch(new DocumentModelEvent(DocumentModelEvent.DOCUMENT_EDITED));
		}
		
		private var _savedNativePath:String;
		public function get path():String
		{
			return this._savedNativePath;
		}
		public function set path(value:String):void
		{
			this._savedNativePath = value;
		}
		
		private var _selectedAssets:Vector.<AssetVO> = new Vector.<AssetVO>();
		public function get selectedAssets():Vector.<AssetVO>
		{
			return this._selectedAssets;
		}
		public function set selectedAssets(value:Vector.<AssetVO>):void
		{
			this._selectedAssets = value;
		}
		
		private var _globalOptions:GlobalOptionsVO = new GlobalOptionsVO();
		public function get globalOptions():GlobalOptionsVO
		{
			return this._globalOptions;
		}
		
		public function get animations():ArrayCollection
		{
			return _documentVO.animations;
		}
		public function set animations(value:ArrayCollection):void
		{
			if( animations ) animations.removeEventListener(CollectionEvent.COLLECTION_CHANGE, assets_collectionChangeHandler );
			_documentVO.animations = value;
			if( animations ) animations.addEventListener(CollectionEvent.COLLECTION_CHANGE, assets_collectionChangeHandler );
		}
		
		public function get geometry():ArrayCollection
		{
			return _documentVO.geometry;
		}
		public function set geometry(value:ArrayCollection):void
		{
			if( geometry ) geometry.removeEventListener(CollectionEvent.COLLECTION_CHANGE, assets_collectionChangeHandler );
			_documentVO.geometry = value;
			if( geometry ) geometry.addEventListener(CollectionEvent.COLLECTION_CHANGE, assets_collectionChangeHandler );
		}
		
		public function get materials():ArrayCollection
		{
			return _documentVO.materials;
		}
		public function set materials(value:ArrayCollection):void
		{
			if( materials ) materials.removeEventListener(CollectionEvent.COLLECTION_CHANGE, assets_collectionChangeHandler );
			_documentVO.materials = value;
			if( materials ) materials.addEventListener(CollectionEvent.COLLECTION_CHANGE, assets_collectionChangeHandler );
		}
		
		public function get scene():ArrayCollection
		{
			return _documentVO.scene;
		}
		public function set scene(value:ArrayCollection):void
		{
			if( _documentVO.scene ) _documentVO.scene.removeEventListener(CollectionEvent.COLLECTION_CHANGE, assets_collectionChangeHandler );
			_documentVO.scene = value;
			if( _documentVO.scene ) _documentVO.scene.addEventListener(CollectionEvent.COLLECTION_CHANGE, assets_collectionChangeHandler );
		}
		
		public function get textures():ArrayCollection
		{
			return _documentVO.textures;
		}
		public function set textures(value:ArrayCollection):void
		{
			if( textures ) textures.removeEventListener(CollectionEvent.COLLECTION_CHANGE, assets_collectionChangeHandler );
			_documentVO.textures = value;
			if( textures ) textures.addEventListener(CollectionEvent.COLLECTION_CHANGE, assets_collectionChangeHandler );
		}
		
		public function get lights():ArrayCollection
		{
			return _documentVO.lights;
		}
		public function set lights(value:ArrayCollection):void
		{
			if( lights ) lights.removeEventListener(CollectionEvent.COLLECTION_CHANGE, assets_collectionChangeHandler );
			_documentVO.lights = value;
			if( lights ) lights.addEventListener(CollectionEvent.COLLECTION_CHANGE, assets_collectionChangeHandler );
		}
		
		public function fill( data:DocumentVO ):void
		{
			animations = new ArrayCollection( animations.source.concat( data.animations.source ) );
			geometry = new ArrayCollection( geometry.source.concat( data.geometry.source ) );
			materials = new ArrayCollection( materials.source.concat( data.materials.source ) );
			scene = new ArrayCollection( scene.source.concat( data.scene.source ) );
			textures = new ArrayCollection( textures.source.concat( data.textures.source ) );
			lights = new ArrayCollection( lights.source.concat( data.lights.source ) );
		}
		
		public function getAllAssets():Array
		{
			var assets:Array = scene.source.concat(materials.source.concat(textures.source.concat(animations.source.concat(geometry.source.concat(lights.source)))));
			return assets;
		}
		
		private var _copiedAssets:Vector.<AssetVO>;
		public function get copiedAssets():Vector.<AssetVO>
		{
			return _copiedAssets;
		}
		public function set copiedAssets(value:Vector.<AssetVO>):void
		{
			_copiedAssets = value;
			this.dispatch(new DocumentModelEvent(DocumentModelEvent.CLIPBOARD_UPDATED));
		}
		
		public function clear():void
		{
			scene = new ArrayCollection();
			materials = new ArrayCollection();
			textures = new ArrayCollection();
			geometry = new ArrayCollection();
			animations = new ArrayCollection();
			lights = new ArrayCollection();
			_globalOptions = new GlobalOptionsVO();
			_selectedAssets = new Vector.<AssetVO>();
			
			copiedAssets = null;
			empty = true;
		}
		
		public function removeAssets( source:ArrayCollection, items:ArrayCollection ):void
		{
			for each( var oddItem:AssetVO in items ) 
			{
				removeAsset( source, oddItem );
			}
		}
		public function removeAsset( source:ArrayCollection, oddItem:AssetVO ):void
		{
			for (var i:int = 0; i < source.length; i++) 
			{
				if( source[i].id == oddItem.id )
				{
					source.removeItemAt( i );
					i--;
				}
			}
		}
		public function getAssetHolders( asset:AssetVO ):Vector.<AssetVO>
		{
			var holders:Vector.<AssetVO> = new Vector.<AssetVO>();
			var assets:Array = getAllAssets();
			for each( var holder:AssetVO in assets )
			{
				holders = holders.concat( getAssetHoldersInHierarchy( holder, asset ) );	
			}
			return holders;
		}
		private function getAssetHoldersInHierarchy( holder:AssetVO, asset:AssetVO ):Vector.<AssetVO>
		{
			var holders:Vector.<AssetVO> = new Vector.<AssetVO>();
			var source:ArrayCollection;
			if( holder is ContainerVO )
			{
				source = ContainerVO( holder ).children;
			}
			for each( var vo:AssetVO in source )
			{
				if( vo.equals( asset ) )
				{
					holders.push( holder );
				}
				holders = holders.concat( getAssetHoldersInHierarchy( holder, asset ) );
			}
			return holders;
		}
		public function getLibraryByAsset( asset:AssetVO ):ArrayCollection
		{
			switch( true )
			{
				case( asset is ObjectVO ):
					return scene;
				case( asset is EffectVO ):
				case( asset is MaterialVO ):
					return materials;
				case( asset is TextureVO ):
				case( asset is CubeTextureVO ):
					return textures;
				case( asset is GeometryVO ):
					return geometry;
				case( asset is LightVO ):
				case( asset is LightPickerVO ):
					return lights;
				case( asset is SkeletonVO ):
				case( asset is AnimationSetVO ):
				case( asset is AnimationNodeVO ):
					return animations;
				default:
					return scene;
			}
			
		}
		
		public function getAssetsByType( type:Class, assetsFilterFunction:Function = null, filterItem:AssetVO = null ):Vector.<AssetVO> 
		{
			var allAssets:Array = getAllAssets();
			var objects:Vector.<AssetVO> = new Vector.<AssetVO>();
			for each( var asset:AssetVO in allAssets )
			{
				if( asset is type )
				{
					if( assetsFilterFunction != null )
					{
						if( assetsFilterFunction(asset, filterItem) ) 
						{
							objects.push( asset );
						}
					}
					else 
					{
						objects.push( asset );
					}
				}
			}
			return objects;
		}
		
		private function assets_collectionChangeHandler( event:CollectionEvent ):void
		{
			switch(event.kind)
			{
				case CollectionEventKind.ADD:
				case CollectionEventKind.REMOVE:
				case CollectionEventKind.MOVE:
				case CollectionEventKind.RESET:
				case CollectionEventKind.REPLACE:
					dispatch( new DocumentModelEvent( DocumentModelEvent.OBJECTS_COLLECTION_UPDATED ) );					
					break;
			}
		}
		
	}
}