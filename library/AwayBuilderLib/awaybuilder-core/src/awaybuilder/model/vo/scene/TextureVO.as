package awaybuilder.model.vo.scene 
{
	import awaybuilder.model.vo.scene.interfaces.IDefaultable;
	
	import flash.display.BitmapData;
	
	[Bindable]
	public class TextureVO extends AssetVO implements IDefaultable
	{
	
	    public var bitmapData:BitmapData;
	
	    public function clone():TextureVO
	    {
	        var vo:TextureVO = new TextureVO();
			vo.isDefault = this.isDefault;
			vo.id = this.id;
			vo.name = this.name;
			vo.bitmapData = this.bitmapData;
	        return vo;
	    }
		
	}
}