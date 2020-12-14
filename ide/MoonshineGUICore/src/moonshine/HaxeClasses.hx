package moonshine;

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
import feathers.core.DefaultToolTipManager;
import feathers.core.FocusManager;
import moonshine.components.FileSavePopupView;
import moonshine.components.QuitView;
import moonshine.components.SDKDefineView;
import moonshine.components.SDKSelectorView;
import moonshine.components.SelectOpenedProjectView;
import moonshine.components.StandardPopupView;
import moonshine.plugin.findreplace.view.FindReplaceView;
import moonshine.plugin.findreplace.view.GoToLineView;
import moonshine.plugin.help.view.AS3DocsView;
import moonshine.plugin.help.view.TourDeFlexContentsView;
import moonshine.plugin.locations.view.LocationsView;
import moonshine.plugin.outline.view.OutlineView;
import moonshine.plugin.problems.view.ProblemsView;
import moonshine.plugin.references.view.ReferencesView;
import moonshine.plugin.rename.view.RenameFileView;
import moonshine.plugin.rename.view.RenameSymbolView;
import moonshine.plugin.symbols.view.SymbolsView;

class HaxeClasses {
	public var FocusManager:FocusManager;
	public var DefaultToolTipManager:DefaultToolTipManager;
	public var SDKDefineView:SDKDefineView;
	public var SDKSelectorView:SDKSelectorView;
	public var AS3DocsView:AS3DocsView;
	public var FileSavePopupView:FileSavePopupView;
	public var FindReplaceView:FindReplaceView;
	public var GoToLineView:GoToLineView;
	public var LocationsView:LocationsView;
	public var OutlineView:OutlineView;
	public var ProblemsView:ProblemsView;
	public var ReferencesView:ReferencesView;
	public var RenameFileView:RenameFileView;
	public var RenameSymbolView:RenameSymbolView;
	public var SelectOpenedProjectView:SelectOpenedProjectView;
	public var StandardPopupView:StandardPopupView;
	public var SymbolsView:SymbolsView;
	public var TourDeFlexContentsView:TourDeFlexContentsView;
	public var QuitView:QuitView;
}
