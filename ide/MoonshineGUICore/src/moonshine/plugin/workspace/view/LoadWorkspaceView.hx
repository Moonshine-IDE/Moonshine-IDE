package moonshine.plugin.workspace.view;

import feathers.controls.PopUpListView;
import feathers.layout.VerticalLayout;
import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import feathers.data.ArrayCollection;
import feathers.core.InvalidationFlag;
import openfl.events.Event;
import feathers.events.TriggerEvent;
import moonshine.plugin.workspace.events.WorkspaceEvent;

class LoadWorkspaceView extends ResizableTitleWindow {
	public function new() {
		MoonshineTheme.initializeTheme();

		super();
			
		this.title = "Load Workspace";
		this.width = 350.0;
		this.minWidth = 300.0;
		this.minHeight = 300.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
		
	}
	
	private var loadWorkspaceButton:Button;
	private var workspacePopUpListView:PopUpListView;
	
	private var _selectedWorkspace:String;
	
	@:flash.property
	public var selectedWorkspace(get, set):String;
	
	private function get_selectedWorkspace():String {
		return this._selectedWorkspace;
	}

	private function set_selectedWorkspace(value:String):String {
		if (this._selectedWorkspace == value) {
			return this._selectedWorkspace;
		}
		
		this._selectedWorkspace = value;
		this.setInvalid(InvalidationFlag.SELECTION);
		return this._selectedWorkspace;
	}
	
	private var _workspaces:ArrayCollection<String> = new ArrayCollection();
	
	@:flash.property
	public var workspaces(get, set):ArrayCollection<String>;

	private function get_workspaces():ArrayCollection<String> {
		return this._workspaces;
	}

	private function set_workspaces(value:ArrayCollection<String>):ArrayCollection<String> {
		if (this._workspaces == value) {
			return this._workspaces;
		}
		
		this._workspaces = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._workspaces;
	}
	
	override private function initialize():Void {
		var viewLayout = new VerticalLayout();
		viewLayout.horizontalAlign = JUSTIFY;
		viewLayout.paddingTop = 10.0;
		viewLayout.paddingRight = 10.0;
		viewLayout.paddingBottom = 10.0;
		viewLayout.paddingLeft = 10.0;
		viewLayout.gap = 10.0;
		this.layout = viewLayout;
		
		this.workspacePopUpListView = new PopUpListView();
		this.workspacePopUpListView.addEventListener(Event.CHANGE, workspacePopUpListView_changeHandler);
		this.addChild(this.workspacePopUpListView);
		
		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.loadWorkspaceButton = new Button();
		this.loadWorkspaceButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.loadWorkspaceButton.text = "Load Workspace";
		this.loadWorkspaceButton.addEventListener(TriggerEvent.TRIGGER, loadWorkspaceButton_triggerHandler);
		footer.addChild(this.loadWorkspaceButton);
		this.footer = footer;
		
		super.initialize();
	}
	
	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.workspacePopUpListView.dataProvider = this._workspaces;
		}		
		
		super.update();
	}
	
	private function workspacePopUpListView_changeHandler(event:Event):Void {
		this.set_selectedWorkspace(this.workspacePopUpListView.selectedItem);	
	}	
	
	private function loadWorkspaceButton_triggerHandler(event:Event):Void {
		var workspaceEvent = new WorkspaceEvent(WorkspaceEvent.NEW_WORKSPACE_WITH_LABEL);
		
		dispatchEvent(workspaceEvent);
	}
}