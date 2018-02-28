package awaybuilder.model.vo.scene
{
	[Bindable]
	public class MaterialBaseVO extends AssetVO
	{
		
		public var blendMode:String;
		
		public var repeat:Boolean;
		public var bothSides:Boolean;
		public var extra:Object;
		public var lightPicker:LightPickerVO;
		public var light:LightVO;
		public var mipmap:Boolean;
		public var smooth:Boolean;
		
		public var alphaPremultiplied:Boolean;
		
	}
}
