package awaybuilder.controller.clipboard
{
	import away3d.core.base.Object3D;
	import away3d.entities.Mesh;
	
	import awaybuilder.controller.clipboard.events.ClipboardEvent;
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.MeshVO;
	import awaybuilder.model.vo.scene.ObjectVO;
	
	import mx.collections.ArrayCollection;
	
	import org.robotlegs.mvcs.Command;

	public class CopyCommand extends Command
	{
		
		[Inject]
		public var document:DocumentModel;
		
		[Inject]
		public var assets:AssetsModel;
		
		[Inject]
		public var event:ClipboardEvent;
		
		override public function execute():void
		{
			if( !document.selectedAssets || (document.selectedAssets.length == 0))
			{
				return;
			}
			
			var copiedAssets:Vector.<AssetVO> = new Vector.<AssetVO>();
			for each( var vo:AssetVO in document.selectedAssets )
			{
				var objectVO:ObjectVO = vo as ObjectVO;
				if( objectVO )
				{
					copiedAssets.push( objectVO );
				}
				
			}
			document.copiedAssets = copiedAssets;
			if(event.type == ClipboardEvent.CLIPBOARD_CUT)
			{
				this.dispatch(new SceneEvent(SceneEvent.PERFORM_DELETION ));
			}
		}
	}
}