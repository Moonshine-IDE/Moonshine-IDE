////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.valueObjects
{
	/**
	 * Implementation of CodeAction interface from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new properties or methods to this class
	 * that are specific to Moonshine IDE or to a particular language. Create a
	 * subclass for new properties or create a utility function for methods.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_codeAction
	 */
	public class CodeAction
	{
		public static const KIND_QUICK_FIX:String = "quickfix";
		public static const KIND_REFACTOR:String = "refactor";
		public static const KIND_REFACTOR_EXTRACT:String = "refactor.extract";
		public static const KIND_REFACTOR_INLINE:String = "refactor.inline";
		public static const KIND_REFACTOR_REWRITE:String = "refactor.rewrite";
		public static const KIND_SOURCE:String = "source";
		public static const KIND_SOURCE_ORGANIZE_IMPORTS:String = "source.organizeImports";
		
		private static const FIELD_DIAGNOSTICS:String = "diagnostics";
		private static const FIELD_EDIT:String = "edit";
		private static const FIELD_COMMAND:String = "command";

		/**
		 * A short, human-readable, title for this code action.
		 */
		public var title:String;

		/**
		 * The kind of the code action. Used to filter code actions.
		 */
		public var kind:String;

		/**
		 * The diagnostics that this code action resolves.
		 */
		public var diagnostics:Vector.<Diagnostic>;

		/**
		 * The workspace edit this code action performs.
		 */
		public var edit:WorkspaceEdit;

		/**
		 * A command this code action executes. If a code action provides an
		 * edit and a command, first the edit is executed and then the command.
		 */
		public var command:Command;

		public function CodeAction()
		{
			
		}

		public static function parse(original:Object):CodeAction
		{
			var vo:CodeAction = new CodeAction();
			vo.title = original.title;
			vo.kind = original.kind;
			if(FIELD_DIAGNOSTICS in original)
			{
				var diagnostics:Vector.<Diagnostic> = new <Diagnostic>[];
				var jsonDiagnostics:Array = original.diagnostics;
				var diagnosticCount:int = jsonDiagnostics.length;
				for(var i:int = 0; i < diagnosticCount; i++)
				{
					diagnostics[i] = Diagnostic.parse(jsonDiagnostics[i]);
				}
				vo.diagnostics = diagnostics;
			}
			if(FIELD_EDIT in original)
			{
				vo.edit = WorkspaceEdit.parse(original.edit);
			}
			if(FIELD_COMMAND in original)
			{
				vo.command = Command.parse(original.command);
			}
			return vo;
		}
	}
}