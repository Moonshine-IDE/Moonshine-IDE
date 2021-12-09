/*
	Copyright 2020 Prominic.NET, Inc.

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License

	Author: Prominic.NET, Inc.
	No warranty of merchantability or fitness of any kind.
	Use this software at your own risk.
 */

package moonshine.plugin.search.view;

import moonshine.plugin.search.events.SearchViewEvent;
import feathers.controls.Callout;
import moonshine.components.events.FileTypesCalloutEvent;
import moonshine.components.FileTypesCallout;
import flash.ui.Keyboard;
import feathers.layout.AnchorLayoutData;
import actionScripts.valueObjects.ProjectVO;
import feathers.data.ArrayCollection;
import feathers.controls.Label;
import feathers.layout.HorizontalLayout;
import feathers.controls.LayoutGroup;
import feathers.layout.VerticalLayout;
import feathers.controls.PopUpListView;
import feathers.controls.Radio;
import feathers.core.ToggleGroup;
import feathers.controls.Check;
import feathers.controls.Button;
import feathers.controls.TextInput;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import feathers.events.TriggerEvent;
import feathers.core.InvalidationFlag;
import openfl.text.TextFormat;
import feathers.events.TriggerEvent;

class SearchView extends ResizableTitleWindow {
	public static final EVENT_SEARCH_AND_REPLACE = "replaceOne";
	public static final EVENT_SEARCH_ALL = "searchAll";
	
	public function new() {
		super();
		this.title = "Search";
		this.width = 500.0;
		this.minWidth = 350.0;
		this.minHeight = 250.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
	}

	private var searchTextInput:TextInput;

	private var searchAndReplaceButton:Button;
	private var searchButton:Button;
	
	private var matchCaseCheck:Check;
	private var regExpCheck:Check;
	private var escapeCharsCheck:Check;
	
	private var patternsTextInput:TextInput;
	private var selectPatternButton:Button;
	
	private var selectSearchPlaceGroup:ToggleGroup;
	private var workspaceRadio:Radio;
	private var selectedProjectRadio:Radio;
	private var projectListPopUpListView:PopUpListView;
	
	private var includeExternalPaths:Check;
	
	private var workspaceSearchEnabled:Bool;
	
	private var _searchText:String = "";
	private var _matchCaseEnabled:Bool = false;
	private var _regExpEnabled:Bool = false;
	private var _escapeCharsEnabled:Bool = false;
	private var _includeExternalSourcePath:Bool = false;
	
	private var _projects:ArrayCollection<ProjectVO> = new ArrayCollection();
	
	@:flash.property
	public var projects(get, set):ArrayCollection<ProjectVO>;

	private function get_projects():ArrayCollection<ProjectVO> {
		return this._projects;
	}
	
	private function set_projects(value:ArrayCollection<ProjectVO>):ArrayCollection<ProjectVO> {
		if (this._projects == value) {
			return this._projects;
		}
		
		this._projects = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._projects;
	}
	
	private var _selectedProject:ProjectVO;
	
	@:flash.property
	public var selectedProject(get, set):ProjectVO;

	private function get_selectedProject():ProjectVO {
		return this._selectedProject;
	}
	
	private function set_selectedProject(value:ProjectVO):ProjectVO {
		if (this._selectedProject == value) {
			return this._selectedProject;
		}
		
		this._selectedProject = value;
		this.setInvalid(InvalidationFlag.SELECTION);
		return this._selectedProject;
	}
	
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
		var viewLayout = new VerticalLayout();
		viewLayout.horizontalAlign = JUSTIFY;
		viewLayout.paddingTop = 10.0;
		viewLayout.paddingRight = 10.0;
		viewLayout.paddingBottom = 10.0;
		viewLayout.paddingLeft = 10.0;
		viewLayout.gap = 10.0;
		this.layout = viewLayout;

		this.searchTextInput = new TextInput();
		this.searchTextInput.prompt = "Containing text";
		this.searchTextInput.addEventListener(Event.CHANGE, searchTextInput_changeHandler);
		this.searchTextInput.addEventListener(KeyboardEvent.KEY_DOWN, searchTextInput_keyDownHandler);
		this.addChild(this.searchTextInput);

		var optionsField = new LayoutGroup();
		var optionsFieldLayout = new HorizontalLayout();
		optionsFieldLayout.gap = 10.0;
		optionsField.layout = optionsFieldLayout;
		this.addChild(optionsField);
		
		this.matchCaseCheck = new Check();
		this.matchCaseCheck.text = "Match case";
		this.matchCaseCheck.addEventListener(Event.CHANGE, matchCaseCheck_changeHandler);
		optionsField.addChild(this.matchCaseCheck);
		this.regExpCheck = new Check();
		this.regExpCheck.text = "RegExp";
		this.regExpCheck.addEventListener(Event.CHANGE, regExpCheck_changeHandler);
		optionsField.addChild(this.regExpCheck);
		this.escapeCharsCheck = new Check();
		this.escapeCharsCheck.text = "Escape chars";
		this.escapeCharsCheck.addEventListener(Event.CHANGE, escapeCharsCheck_changeHandler);
		optionsField.addChild(this.escapeCharsCheck);

		var fileNamePatternLabel = new Label();
			fileNamePatternLabel.textFormat = new TextFormat("DejaVuSansTF", 13, 0x292929);
			fileNamePatternLabel.text = "File name patterns:";
		this.addChild(fileNamePatternLabel);
		
		var patternsInfoField = new LayoutGroup();
		var patternsInfoFieldLayout = new VerticalLayout();
			patternsInfoFieldLayout.gap = 1.0;
			patternsInfoField.layout = patternsInfoFieldLayout;
			
		var patternsField = new LayoutGroup();
		var patternsFieldLayout = new HorizontalLayout();
			patternsFieldLayout.gap = 2.0;
			patternsField.layout = optionsFieldLayout;
		patternsInfoField.addChild(patternsField);
		
		this.patternsTextInput = new TextInput();
		this.patternsTextInput.width = 400;
		this.patternsTextInput.text = "*";
		patternsField.addChild(this.patternsTextInput);
		this.selectPatternButton = new Button();
		this.selectPatternButton.text = "Select";
		this.selectPatternButton.addEventListener(TriggerEvent.TRIGGER, selectPatternButton_changeHandler);
		patternsField.addChild(this.selectPatternButton);
				
		var separatePatternsLabel:Label = new Label();
			separatePatternsLabel.textFormat = new TextFormat ("DejaVuSansTF", 10, 0x292929);
			separatePatternsLabel.text = "(Separate patterns with coma (,) sign)";
		patternsInfoField.addChild(separatePatternsLabel);
		
		this.addChild(patternsInfoField);
		
		var scopeLabel = new Label();
			scopeLabel.textFormat = new TextFormat("DejaVuSansTF", 13, 0x292929);
			scopeLabel.text = "Scope:";
		this.addChild(scopeLabel);
		
		this.selectSearchPlaceGroup = new ToggleGroup();
		this.selectSearchPlaceGroup.addEventListener(Event.CHANGE, selectSearchPlaceGroup_changeHandler);
		var directionField = new LayoutGroup();
		var directionFieldLayout = new HorizontalLayout();
			directionFieldLayout.gap = 10.0;
			
		directionField.layout = directionFieldLayout;
		this.addChild(directionField);
		
		this.workspaceRadio = new Radio();
		this.workspaceRadio.text = "Workspace";
		this.workspaceRadio.toggleGroup = this.selectSearchPlaceGroup;
		directionField.addChild(this.workspaceRadio);
		this.selectedProjectRadio = new Radio();
		this.selectedProjectRadio.text = "Selected project";
		this.selectedProjectRadio.toggleGroup = this.selectSearchPlaceGroup;
		directionField.addChild(this.selectedProjectRadio);
		
		this.selectSearchPlaceGroup.selectedIndex = 1;
		
		this.projectListPopUpListView = new PopUpListView();
		this.projectListPopUpListView.width = 300;
		this.projectListPopUpListView.layoutData = AnchorLayoutData.center();
		this.projectListPopUpListView.itemToText = function(item:ProjectVO):String {
													 return item.name;
  												  };
  												  
		this.addChild(this.projectListPopUpListView);		
		
		this.includeExternalPaths = new Check();
		this.includeExternalPaths.text = "Include external source paths";
		this.includeExternalPaths.addEventListener(Event.CHANGE, includeExternalPaths_changeHandler);
		this.addChild(this.includeExternalPaths);
		
		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.searchAndReplaceButton = new Button();
		this.searchAndReplaceButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.searchAndReplaceButton.text = "Replace";
		this.searchAndReplaceButton.addEventListener(TriggerEvent.TRIGGER, searchAndReplaceButton_triggerHandler);
		footer.addChild(this.searchAndReplaceButton);
		this.searchButton = new Button();
		this.searchButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.searchButton.text = "Search";
		this.searchButton.addEventListener(TriggerEvent.TRIGGER, searchButton_triggerHandler);
		footer.addChild(this.searchButton);
		this.footer = footer;

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this._projects.sortCompareFunction = this.sortProjects;
			this._projects.refresh();
			this.projectListPopUpListView.dataProvider = this._projects;
		}
				
		var selection = this.isInvalid(InvalidationFlag.SELECTION);
		
		if (selection) {
			this.projectListPopUpListView.selectedItem = this._selectedProject;	
		}		
		
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		
		if (stateInvalid) {
			includeExternalPaths.enabled = this.workspaceSearchEnabled == false;
			projectListPopUpListView.enabled = this.workspaceSearchEnabled == false;
			_includeExternalSourcePath = this.workspaceSearchEnabled == false ? 
										 this.includeExternalPaths.selected : false;				 
		}				

		super.update();
	}
	
	private function searchAll(eventType:String):Void {
		if (this._searchText == null || this._searchText == "") 
		{
			return;
		}
		
		var searchViewEvent:SearchViewEvent = new SearchViewEvent(eventType, this._searchText);
			searchViewEvent.patternsText = this.patternsTextInput.text;
			searchViewEvent.matchCaseEnabled = this._matchCaseEnabled;
			searchViewEvent.regExpEnabled = this._regExpEnabled;
			searchViewEvent.escapeCharsEnabled = this._escapeCharsEnabled;
			searchViewEvent.includeExternalSourcePath = this._includeExternalSourcePath;
			searchViewEvent.selectedSearchScopeIndex = this.selectSearchPlaceGroup.selectedIndex;
			searchViewEvent.selectedProject = this.selectSearchPlaceGroup.selectedIndex == 1 ?
											  this.projectListPopUpListView.selectedItem : null;
											  
		this.dispatchEvent(searchViewEvent);	
		
		this.dispatchEvent(new Event(Event.CLOSE));
	}	
	
	private function searchTextInput_changeHandler(event:Event):Void {
		this._searchText = this.searchTextInput.text;
	}

	private function searchTextInput_keyDownHandler(event:KeyboardEvent):Void {
		if (event.keyCode == Keyboard.ENTER) {
			this.searchAll(SearchViewEvent.SEARCH_PHRASE);
		}		
	}
	
	private function matchCaseCheck_changeHandler(event:Event):Void {
		this._matchCaseEnabled = this.matchCaseCheck.selected;
	}

	private function regExpCheck_changeHandler(event:Event):Void {
		this._regExpEnabled = this.regExpCheck.selected;
	}

	private function escapeCharsCheck_changeHandler(event:Event):Void {
		this._escapeCharsEnabled = this.escapeCharsCheck.selected;
	}

	private function selectPatternButton_changeHandler(event:Event):Void {
		var fileTypesCallout = new FileTypesCallout(); 
			fileTypesCallout.patterns = this._patterns;
			fileTypesCallout.addEventListener(FileTypesCalloutEvent.SELECT_FILETYPE, extensionsListView_itemTriggerHandler);
		Callout.show(fileTypesCallout, this.selectPatternButton);
	}	
		
	private function includeExternalPaths_changeHandler(event:Event):Void {
		this._includeExternalSourcePath = this.includeExternalPaths.selected;
	}
	
	private function selectSearchPlaceGroup_changeHandler(event:Event):Void {
		this.workspaceSearchEnabled = this.selectSearchPlaceGroup.selectedIndex == 0;
		this.setInvalid(InvalidationFlag.STATE);
	}	
	
	private function searchAndReplaceButton_triggerHandler(event:TriggerEvent):Void {
		this.searchAll(SearchViewEvent.REPLACE_PHRASE);
		
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function searchButton_triggerHandler(event:TriggerEvent):Void {
		this.searchAll(SearchViewEvent.SEARCH_PHRASE);
	}
	
	private function extensionsListView_itemTriggerHandler(event:FileTypesCalloutEvent):Void {
		var index = event.index;
		var pattern = this._patterns.get(index);
			pattern.isSelected = !pattern.isSelected;
			
		this._patterns.updateAt(index);	
		
		var selectedPatterns = this._patterns.array.filter(item -> item.isSelected == true);
		var selectedExt = "";
		for (index => value in selectedPatterns) {
			if (index == 0) {
				selectedExt += value.label;
			} else {
				selectedExt += ", " + value.label;
			}				
		}
		
		if (selectedExt != "") {
			this.patternsTextInput.text = selectedExt;
		} else {
			this.patternsTextInput.text = "*";
		}
	}
	
	private function sortProjects(a:ProjectVO, b:ProjectVO):Int {
		var nameA = a.name.toLowerCase();
		var nameB = b.name.toLowerCase();
	
		if (nameA < nameB) {
			return -1;
		}	 
		else if (nameA > nameB) {
			return 1; 
		}
		else {
			return 0;
		}
	}	
}
