function onMainNavChange(event:Event):void
{
	var selectedContent:String = event.currentTarget.selectedItem["content"];
	this[selectedContent + "_ID"].cancelFormEdit();
	this.mainContent.selectedContent = selectedContent;
}