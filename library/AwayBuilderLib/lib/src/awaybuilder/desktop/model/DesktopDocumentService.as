package awaybuilder.desktop.model
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.managers.CursorManager;
	
	import awaybuilder.controller.events.ConcatenateDataOperationEvent;
	import awaybuilder.controller.events.DocumentEvent;
	import awaybuilder.controller.events.ReplaceDocumentDataEvent;
	import awaybuilder.controller.events.SaveDocumentEvent;
	import awaybuilder.controller.history.HistoryEvent;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.ApplicationModel;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.IDocumentService;
	import awaybuilder.model.SmartDocumentServiceBase;
	import awaybuilder.model.vo.DocumentVO;
	import awaybuilder.model.vo.GlobalOptionsVO;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.CubeTextureVO;
	import awaybuilder.model.vo.scene.TextureVO;
	import awaybuilder.utils.encoders.AWDEncoder;
	import awaybuilder.utils.encoders.ISceneGraphEncoder;
	
	public class DesktopDocumentService extends SmartDocumentServiceBase implements IDocumentService
	{
		private static const FILE_EXTENSION : String = '.awd';
		
		private var _fileToData:Dictionary = new Dictionary();
		
		private var _nextEvent:Event;
		
		private var _createNew:Boolean;
		
		private var _name:String;
		
		private var _path:String;
		
		private var _items:Array;
		
		private var _property:String;
		
		[Inject]
		public var applicationModel:ApplicationModel;
		
		[Inject]
		public var document:DocumentModel;
		public function load( url:String, name:String, event:Event ):void
		{
			_name = name;
			_nextEvent = event;
			if (document.empty)
				_path = url;
			loadAssets( url );
		}
		
		public function openBitmap( items:Array, property:String ):void
		{
			_items = items;
			_property = property;
			var file:File=File.documentsDirectory;
			if(document.path)
				file = File.documentsDirectory.resolvePath(document.path);
			file.addEventListener(Event.SELECT, bitmapFile_open_selectHandler);
			file.addEventListener(Event.CANCEL, bitmapFile_open_cancelHandler);
			var filters:Array = [];
			var title:String = "Import Bitmap";
			filters.push( new FileFilter("Bitmap (*.png, *.jpg)", "*.png;*.jpg") );
			file.browseForOpen(title, filters);
		}
		
		public function open( type:String, createNew:Boolean, event:Event ):void
		{
			_nextEvent = event;
			_createNew = createNew;
			var file:File=File.documentsDirectory;
			if(document.path)
				file = File.documentsDirectory.resolvePath(document.path);
			file.addEventListener(Event.SELECT, file_open_selectHandler);
			file.addEventListener(Event.CANCEL, file_open_cancelHandler);
			var filters:Array = [];
			var title:String;
			switch( type ) 
			{
				case "open":
					title = "Open File";
					filters.push( new FileFilter("Away3D (*.awd)", "*.awd") );
					break;
				case "import":
					title = "Import File";
					filters.push( new FileFilter("3D and Images", "*.awd;*.3ds;*.obj;*.md2;*.png;*.jpg;*.dae;*.md5mesh;*.md5anim") );
					filters.push( new FileFilter("3D (*.awd, *.3ds, *.obj, *.md2, *.dae, *.md5mesh, *.md5anim)", "*.awd;*.3ds;*.obj;*.md2;*.dae;*.md5mesh;*.md5anim") );
					filters.push( new FileFilter("Images (*.png, *.jpg)", "*.png;*.jpg") );
					break;
				case "images":
					title = "Import Texture";
					filters.push( new FileFilter("Images (*.png, *.jpg)", "*.png;*.jpg") );
					break;
			}
			file.browseForOpen(title, filters);
		}
		
		public function saveAs(data:DocumentModel, defaultName:String):void
		{
			if(defaultName.toLowerCase().lastIndexOf(FILE_EXTENSION) != defaultName.length - FILE_EXTENSION.length)
			{
				defaultName += FILE_EXTENSION;
			}
			var file:File=File.documentsDirectory.resolvePath("./" + defaultName);
			if(document.path)
				file = File.documentsDirectory.resolvePath(document.path).resolvePath("./" + defaultName);;
			file.addEventListener(Event.SELECT, file_save_selectHandler);
			file.addEventListener(Event.CANCEL, file_save_cancelHandler);
			file.browseForSave("Save Document As");
			//this should probably never hold more than one file, but let's just
			//be careful eh?
			this._fileToData[file] = data;
		}
		
		public function saveDocument(data:DocumentModel, path:String):void
		{	
			if (!data.globalOptions.embedTextures){
				saveExternalTextures(data,path)
			}
			
			this.save(data,path);
		}
		
		public function saveExternalTextures(document:DocumentModel, path:String):void
		{	
			
			var folder:File = File.userDirectory.resolvePath(path);
			var textureDirectory:File = folder.parent.resolvePath("textures");
			if(!textureDirectory.exists)
				textureDirectory.createDirectory();
			for each (var tex:AssetVO in document.textures){
				if (tex is TextureVO){
					saveBitmapDataToFile(TextureVO(tex).bitmapData,TextureVO(tex).name,textureDirectory)
				}
				else if (tex is CubeTextureVO){
					saveBitmapDataToFile(CubeTextureVO(tex).positiveX,CubeTextureVO(tex).name+"_posX",textureDirectory)
					saveBitmapDataToFile(CubeTextureVO(tex).negativeX,CubeTextureVO(tex).name+"_negX",textureDirectory)
					saveBitmapDataToFile(CubeTextureVO(tex).positiveY,CubeTextureVO(tex).name+"_posY",textureDirectory)
					saveBitmapDataToFile(CubeTextureVO(tex).negativeY,CubeTextureVO(tex).name+"_negY",textureDirectory)
					saveBitmapDataToFile(CubeTextureVO(tex).positiveZ,CubeTextureVO(tex).name+"_posZ",textureDirectory)
					saveBitmapDataToFile(CubeTextureVO(tex).negativeZ,CubeTextureVO(tex).name+"_negZ",textureDirectory)					
				}
			}
		}
		
		public function saveBitmapDataToFile(_bitmapData:BitmapData, textureName:String, textureDirectory:File):void
		{	
			var extension:String="";
			var encoder : ISceneGraphEncoder = new AWDEncoder();
			var returnArray:Array=AWDEncoder(encoder)._encodeBitmap(_bitmapData);
			var bytes:ByteArray=returnArray[0];
			extension=".jpg";
			if (returnArray[1])
				extension=".png";
			if(textureName.toLowerCase().lastIndexOf(extension) != textureName.length - extension.length)
				textureName+=extension
			
			var textureFile:File = textureDirectory.resolvePath(textureName);
			if (!textureFile.exists){	
				var textureName:String = textureFile.name;
				textureFile=textureDirectory.resolvePath(textureName);
				var saveStream:FileStream = new FileStream();
				saveStream.open(textureFile, FileMode.WRITE);
				saveStream.writeBytes(bytes);
				saveStream.close();						
			}			
		}
		
		public function save(document:DocumentModel, path:String):void
		{	
			var bytes:ByteArray = new ByteArray();
			var encoder:ISceneGraphEncoder = new AWDEncoder();
			var success:Boolean = encoder.encode(document, bytes, applicationModel.webRestrictionsEnabled);
			
			if (!document.globalOptions.embedTextures){
				saveExternalTextures(document,path)
			}
			try
			{
				
				var file:File = new File(path);
				var saveStream:FileStream = new FileStream();
				saveStream.open(file, FileMode.WRITE);
				saveStream.writeBytes(bytes);
				saveStream.close();
				this.dispatch(new SaveDocumentEvent(SaveDocumentEvent.SAVE_DOCUMENT_SUCCESS, file.name, file.nativePath));
			}
			catch (error:Error)
			{
				this.dispatch(new SaveDocumentEvent(SaveDocumentEvent.SAVE_DOCUMENT_FAIL, file.name, file.nativePath));
			}
			
		}
		
		private function file_save_selectHandler(event:Event):void
		{
			var file:File = File(event.currentTarget);
			if(file.nativePath.toLowerCase().lastIndexOf(FILE_EXTENSION) != file.nativePath.length - FILE_EXTENSION.length)
			{
				//this is kind of nasty, but there's no way to force AIR to add
				//a file extension with browseForSave()! WTF?
				file.nativePath += FILE_EXTENSION;
				
				//if we can safely add the extension without overwriting another
				//file, then awesome! otherwise, display the save dialog again
				//and make the file include the extension.
				//not ideal, but I shouldn't be required to make my own
				//overwrite dialog to allow forced extensions
				if(file.exists)
				{
					file.browseForSave("Save Document As");
					return;
				}
			}
			file.removeEventListener(Event.SELECT, file_save_selectHandler);
			file.removeEventListener(Event.CANCEL, file_save_cancelHandler);
			var data:DocumentModel = this._fileToData[file] as DocumentModel;
			delete this._fileToData[file];
			
			this.saveDocument(data, file.nativePath);
		}
		
		
		private function file_save_cancelHandler(event:Event):void
		{
			this.applicationModel.isWaitingForClose = false;
				
			var file:File = File(event.currentTarget);
			file.removeEventListener(Event.SELECT, file_save_selectHandler);
			file.removeEventListener(Event.CANCEL, file_save_cancelHandler);
			delete this._fileToData[file];
		}
		
		private function bitmapFile_open_selectHandler(event:Event):void
		{
			var file:File = File(event.currentTarget);
			file.removeEventListener(Event.SELECT, file_open_selectHandler);
			file.removeEventListener(Event.CANCEL, file_open_cancelHandler);
			loadBitmap( file.url );
		}
		private function bitmapFile_open_cancelHandler(event:Event):void
		{
			var file:File = File(event.currentTarget);
			file.removeEventListener(Event.SELECT, file_open_selectHandler);
			file.removeEventListener(Event.CANCEL, file_open_cancelHandler);
		}
		
		private function file_open_selectHandler(event:Event):void
		{
			if( _createNew )
			{
				this.dispatch(new DocumentEvent(DocumentEvent.NEW_DOCUMENT));
			}
			
			var file:File = File(event.currentTarget);
			file.removeEventListener(Event.SELECT, file_open_selectHandler);
			file.removeEventListener(Event.CANCEL, file_open_cancelHandler);
			_name = file.name;
			_path = file.url;
			loadAssets( file.url );
		}
		
		private function file_open_cancelHandler(event:Event):void
		{
			var file:File = File(event.currentTarget);
			file.removeEventListener(Event.SELECT, file_open_selectHandler);
			file.removeEventListener(Event.CANCEL, file_open_cancelHandler);
		}
		
		override protected function documentReady( document:DocumentVO, globalOptions:GlobalOptionsVO=null ):void 
		{
			if( _nextEvent is ReplaceDocumentDataEvent )
			{
				var replaceDocumentDataEvent:ReplaceDocumentDataEvent = _nextEvent as ReplaceDocumentDataEvent;
				replaceDocumentDataEvent.fileName = _name;
				replaceDocumentDataEvent.path = _path;
				replaceDocumentDataEvent.value = document;
				replaceDocumentDataEvent.globalOptions = globalOptions;
			}
			else if( _nextEvent is HistoryEvent )
			{
				var concatenateDataOperationEvent:HistoryEvent = _nextEvent as HistoryEvent;
				concatenateDataOperationEvent.newValue = document;
			}
			dispatch( _nextEvent );
		}
		
		override protected function bitmapReady( bitmap:Bitmap ):void
		{
			var asset:AssetVO = _items[0] as AssetVO;
			var clone:AssetVO;
			if( asset is CubeTextureVO )
			{
				clone = CubeTextureVO(asset).clone();
				clone[_property] = bitmap.bitmapData;
				dispatch( new SceneEvent( SceneEvent.CHANGE_CUBE_TEXTURE, _items, clone ) );
			}
			else if( asset is TextureVO )
			{
				clone = TextureVO(asset).clone();
				TextureVO(clone).bitmapData = bitmap.bitmapData;
				dispatch( new SceneEvent( SceneEvent.CHANGE_TEXTURE, _items, clone ) );
			}
			
			CursorManager.removeBusyCursor();
		}
	}
}