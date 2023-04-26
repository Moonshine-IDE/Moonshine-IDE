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

package actionScripts.plugins.ui.editor
{
	import flash.events.Event;
	import actionScripts.factory.FileLocation;
	
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.events.SaveFileEvent;
	import actionScripts.valueObjects.URLDescriptorVO;

	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.controllers.DataAgent;
	import actionScripts.valueObjects.URLDescriptorVO;

	import actionScripts.utils.TextUtil;

	import actionScripts.ui.FeathersUIWrapper;

	import moonshine.editor.text.events.TextEditorChangeEvent;

	import moonshine.editor.text.TextEditor;
	import actionScripts.ui.editor.BasicTextEditor;
	import moonshine.editor.text.syntax.parser.PlainTextLineParser;
	import moonshine.editor.text.events.TextEditorLineEvent;

	//import actionScripts.plugins.help.view.events.DominoActionPropertyChangeEvent;
	import mx.controls.Alert;
	import actionScripts.utils.DominoUtils;

	import actionScripts.plugins.help.view.DominoJavaAgentEditorView;
	public class DominoJavaAgentEditor extends BasicTextEditor
	{

		private var agentTitle:String = "";
		private var agentEnabled:String = "false";
		private var agentRunAsWebUser:String = "false";

		private var actionXmlCache:XML=null;

		private var dominoJavaAgentEditorView:DominoJavaAgentEditorView;
    
		private var javaMainClass:String = "";
		//<!ENTITY % agent.trigger.types "actionsmenu | agentlist | beforenewmail | afternewmail | docupdate | docpaste | scheduled | serverstart ">
		private var triggerType:String = "actionsmenu";

        public function DominoJavaAgentEditor()
		{
			super();
        }

		

		override protected function initializeChildrens():void
		{

			if(!editor)
			{
				editor = new TextEditor(null, false);
			}
			if(!editor.parser)
			{
				editor.parser = new PlainTextLineParser();
			}
			editor.addEventListener(TextEditorChangeEvent.TEXT_CHANGE, handleTextChange);
			editor.addEventListener(TextEditorLineEvent.TOGGLE_BREAKPOINT, handleToggleBreakpoint);
			editorWrapper = new FeathersUIWrapper(editor);
			editorWrapper.percentHeight = 100;
			editorWrapper.percentWidth = 100;
			dominoJavaAgentEditorView = new DominoJavaAgentEditorView();
			
			dominoJavaAgentEditorView.codeEditor = editorWrapper;
			
		
		}

		 override protected function createChildren():void
		{
			addElement(dominoJavaAgentEditorView);
			
			super.createChildren();
		}


		/**
		 * For domino action ,it only generate from template file 
		 * So we don't need consider the file not existing case
		 */
		override public function save():void 
		{

		
			if (ConstantsCoreVO.IS_AIR)
			{
				file.fileBridge.save(super.text);
				editor.save();
				super.updateChangeStatus();

				
				// Tell the world we've changed
				dispatcher.dispatchEvent(
					new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this)
				);

				//save the java source to target dxl

				var agentXML:XML=DominoUtils.generateDominoAgentDomDocument();
				agentXML.database.agent.@name=agentTitle;
				agentXML.database.agent.@runaswebuser="false";
				agentXML.database.agent.@clientbackgroundthread="false";
				agentXML.database.agent.@allowremotedebugging="false";
				agentXML.database.agent.@storehighlights="false";
				agentXML.database.agent.@publicaccess="false";

				var triggerNode:XML=new XML("<trigger/>");
				triggerNode.@type="actionsmenu";

				var documentsetNode:XML=new XML("<documentset/>");
				documentsetNode.@type="runonce";

				var codeNode:XML=new XML("<code/>");
				codeNode.@event="action";
				var javaprojectNode:XML=new XML("<javaproject/>");
				//javaprojectNode.@class=javaMainClass;
				javaprojectNode.@codepath="";
				

			}
            
            if (!ConstantsCoreVO.IS_AIR)
			{
				dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name +": Saving in process..."));
				super.loader = new DataAgent(URLDescriptorVO.FILE_MODIFY, onSaveSuccess, onSaveFault,
						{path:file.fileBridge.nativePath,saveText:super.text});
			}

		}

		

		

		private function onSaveFault(message:String):void
		{
			//Alert.show("Save Fault"+message);
			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name +": Save error!"));
			loader = null;
		}
		
		private function onSaveSuccess(value:Object, message:String=null):void
		{
			//Alert.show("Save Fault"+message);
			super.loader = null;
			editor.save();
			updateChangeStatus();
			dispatcher.dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name +": Saving successful."));
			dispatcher.dispatchEvent(new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this));
		}

		public function setEdited(value:Boolean):void 
		{
			_isChanged=value;

		}

		public function updateTitle(title:String):void
		{
			if(title!=agentTitle){
				agentTitle=title;
				super._isChanged=true;
				dispatchEvent(new Event('labelChanged'));
			}
		}

		public function updateMainClass(mainClass:String):void
		{
			if(mainClass!=javaMainClass){
				javaMainClass=mainClass;
				super._isChanged=true;
				dispatchEvent(new Event('labelChanged'));
			}

		}

		public function updateEnabled(enabledStr:String):void
		{
			
			if(enabledStr!=agentEnabled){
		
				agentEnabled=enabledStr;
				super._isChanged=true;
				dispatchEvent(new Event('labelChanged'));
			}
		}
		public function updateRunAsWebUser(runAsWebUser:String):void
		{
			if(runAsWebUser!=agentRunAsWebUser){
				agentRunAsWebUser=runAsWebUser;
				super._isChanged=true;
				dispatchEvent(new Event('labelChanged'));
			}
		}

		
	

    }
}