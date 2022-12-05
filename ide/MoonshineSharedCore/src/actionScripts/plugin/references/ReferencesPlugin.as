////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugin.references
{
	import actionScripts.events.OpenLocationEvent;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
	import actionScripts.ui.FeathersUIWrapper;
	import actionScripts.ui.editor.LanguageServerTextEditor;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import feathers.data.ArrayCollection;

	import flash.events.Event;

	import moonshine.lsp.Location;
	import moonshine.lsp.Position;
	import moonshine.plugin.references.view.ReferencesView;

	import mx.controls.Alert;

	public class ReferencesPlugin extends PluginBase
	{
		public static const EVENT_OPEN_GO_TO_REFERENCES_VIEW:String = "openGoToReferencesView";
		
		public function ReferencesPlugin()
		{
			referencesView = new ReferencesView();
			referencesViewWrapper = new ReferencesViewWrapper(this.referencesView);
			referencesViewWrapper.percentWidth = 100;
			referencesViewWrapper.percentHeight = 100;
			referencesViewWrapper.minWidth = 0;
			referencesViewWrapper.minHeight = 0;
		}

		override public function get name():String { return "References Plugin"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Displays all references for a symbol in the entire workspace."; }

		private var referencesViewWrapper:ReferencesViewWrapper;
		private var referencesView:ReferencesView;
		private var isReferencesViewVisible:Boolean;

		override public function activate():void
		{
			super.activate();
			referencesView.addEventListener(ReferencesView.EVENT_OPEN_SELECTED_REFERENCE, handleOpenSelectedReference);
			dispatcher.addEventListener(EVENT_OPEN_GO_TO_REFERENCES_VIEW, handleOpenFindReferencesView);
		}

		override public function deactivate():void
		{
			super.deactivate();
			referencesView.removeEventListener(ReferencesView.EVENT_OPEN_SELECTED_REFERENCE, handleOpenSelectedReference);
			dispatcher.removeEventListener(EVENT_OPEN_GO_TO_REFERENCES_VIEW, handleOpenFindReferencesView);
		}

		private function handleOpenFindReferencesView(event:Event):void
		{
			var lspEditor:LanguageServerTextEditor = model.activeEditor as LanguageServerTextEditor;
			if(!lspEditor || !lspEditor.languageClient)
			{
				Alert.show("No references found", ConstantsCoreVO.MOONSHINE_IDE_LABEL);
				return;
			}

			var startLine:int = lspEditor.editor.caretLineIndex;
			var startChar:int = lspEditor.editor.caretCharIndex;
			lspEditor.languageClient.references({
				textDocument: {
					uri: lspEditor.currentFile.fileBridge.url
				},
				position: new Position(startLine, startChar),
				context: {
					includeDeclaration: true
				}
			}, handleShowReferences);
		}

		private function handleShowReferences(references:Array /* Array<Location> */):void
		{
			var collection:ArrayCollection = referencesView.references;
			collection.removeAll();
			var itemCount:int = references.length;
			for(var i:int = 0; i < itemCount; i++)
			{
				var symbol:Location = references[i];
				collection.add(symbol);
			}
			collection.filterFunction = null;
			collection.refresh();

			if (!isReferencesViewVisible)
			{
				dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, referencesViewWrapper));
				isReferencesViewVisible = true;

				referencesView.addEventListener(Event.REMOVED_FROM_STAGE, onReferenceViewRemovedFromStage);
			}
		}

		private function handleOpenSelectedReference(event:Event):void {
			var selectedReference:Location = this.referencesView.selectedReference;
			if(!selectedReference)
			{
				Alert.show("Please select an item to open.");
				return;
			}

			dispatcher.dispatchEvent(
				new OpenLocationEvent(OpenLocationEvent.OPEN_LOCATION, selectedReference));
		}

		private function onReferenceViewRemovedFromStage(event:Event):void
		{
			referencesView.references.removeAll();
			isReferencesViewVisible = false;
			referencesView.removeEventListener(Event.REMOVED_FROM_STAGE, onReferenceViewRemovedFromStage);
		}
	}
}

import actionScripts.interfaces.IViewWithTitle;
import actionScripts.ui.FeathersUIWrapper;

import moonshine.plugin.references.view.ReferencesView;

class ReferencesViewWrapper extends FeathersUIWrapper implements IViewWithTitle {
	public function ReferencesViewWrapper(feathersUIControl:ReferencesView)
	{
		super(feathersUIControl);
	}

	public function get title():String {
		return ReferencesView(feathersUIControl).title;
	}

	override public function get className():String
	{
		//className may be used by LayoutModifier
		return "ReferencesView";
	}
}