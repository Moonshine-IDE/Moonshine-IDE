package awaybuilder.view.components.controls
{
	import spark.components.SkinnableContainer;
	
	public class PropertiesItemContainer extends SkinnableContainer
	{
		public function PropertiesItemContainer()
		{
			super();
		}
		
		[Bindable]
		public var label:String;
		
		[Bindable]
		public var paddingTop:Number = 0;
		
		[Bindable]
		public var paddingBottom:Number = 0;
		
		[Bindable]
		public var paddingLeft:Number = 0;
		
		[Bindable]
		public var paddingRight:Number = 0;
	}
}