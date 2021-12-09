package moonshine.components;

import feathers.layout.VerticalLayoutData;
import feathers.data.ListViewItemState;
import feathers.controls.Check;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.Label;
import feathers.utils.DisplayObjectRecycler;
import feathers.core.InvalidationFlag;
import feathers.layout.VerticalLayout;
import feathers.data.ArrayCollection;
import feathers.controls.LayoutGroup;
import moonshine.components.events.FileTypesCalloutEvent;
import feathers.controls.ListView;
import feathers.events.ListViewEvent;
import feathers.data.ArrayCollection;
import feathers.data.ListViewItemState;

class FileTypesCallout extends LayoutGroup 
{
	public function new()
	{
		super();
	}
	
	private var extensionListView:ListView;
	
	private var _patterns:ArrayCollection<Dynamic> = new ArrayCollection();
	
	@:flash.property
	public var patterns(get, set):ArrayCollection<Dynamic>;

	private function get_patterns():ArrayCollection<Dynamic> {
		return this._patterns;
	}

	private function set_patterns(value:ArrayCollection<Dynamic>):ArrayCollection<Dynamic> {
		if (this._patterns == value) {
			return this._patterns;
		}
		this._patterns = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._patterns;
	}
	
	override private function initialize():Void { 
		super.initialize();
		
		var contentLayout = new VerticalLayout();
		contentLayout.horizontalAlign = JUSTIFY;
		contentLayout.paddingTop = 10.0;
		contentLayout.paddingRight = 10.0;
		contentLayout.paddingBottom = 10.0;
		contentLayout.paddingLeft = 10.0;
		contentLayout.gap = 10.0;
		this.layout = contentLayout;
		var description = new Label();
		description.text = "Reduce selection to only files of type(s):";
		this.addChild(description);
		extensionListView = new ListView();
		extensionListView.itemToText = (item:Dynamic) -> "*." + item.label;
		extensionListView.itemRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new ItemRenderer();
			var check = new Check();
			check.focusEnabled = false;
			check.mouseEnabled = false;
			itemRenderer.icon = check;
			return itemRenderer;
		}, (itemRenderer, state : ListViewItemState) -> {
				itemRenderer.text = state.text;
				var check = cast(itemRenderer.icon, Check);
				check.selected = state.data.isSelected;
			}, (itemRenderer, state:ListViewItemState) -> {
				itemRenderer.text = null;
				var check = cast(itemRenderer.icon, Check);
				check.selected = false;
			});
		extensionListView.addEventListener(ListViewEvent.ITEM_TRIGGER, extensionsListView_itemTriggerHandler);
		extensionListView.selectable = false;
		extensionListView.layoutData = new VerticalLayoutData(null, 100.0);
		
		this.addChild(extensionListView);
	}
	
	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			extensionListView.dataProvider = this._patterns;
		}

		super.update();
	}
	
	private function extensionsListView_itemTriggerHandler(event:ListViewEvent):Void {
		this.dispatchEvent(new FileTypesCalloutEvent(FileTypesCalloutEvent.SELECT_FILETYPE, event.state.index));
	}
}