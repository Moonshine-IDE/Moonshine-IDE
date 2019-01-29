////////////////////////////////////////////////////////////////////////////////
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
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.ui.editor.text
{
	import actionScripts.valueObjects.Diagnostic;
	import actionScripts.valueObjects.CodeAction;

	public class TextLineModel
	{
		protected var _text:String;
		protected var _meta:Vector.<int>;
		protected var _breakPoint:Boolean;
		protected var _width:Number = -1;
		protected var _traceLine:Boolean;
		protected var _diagnostics:Vector.<Diagnostic> = new <Diagnostic>[];
		protected var _codeActions:Vector.<CodeAction> = new <CodeAction>[];
		protected var _isQuoteTextOpen:Boolean;
		protected var _lastQuoteText:String;
		protected var _debuggerLineSelection:Boolean;
		
		public function set text(value:String):void
		{
			_text = value;
		}
		public function get text():String
		{
			return _text;
		}
		
		public function set meta(value:Vector.<int>):void
		{
			_meta = value;
		}
		public function get meta():Vector.<int>
		{
			return _meta;
		}
		
		public function set breakPoint(value:Boolean):void
		{
			_breakPoint = value;
		}
		public function get breakPoint():Boolean
		{
			return _breakPoint;
		}
		public function set traceLine(value:Boolean):void
		{
			_traceLine = value;
		}
		public function get traceLine():Boolean
		{
			return _traceLine;
		}
		
		public function set debuggerLineSelection(value:Boolean):void
		{
			_debuggerLineSelection = value;
		}
		public function get debuggerLineSelection():Boolean
		{
			return _debuggerLineSelection;
		}

		public function set diagnostics(value:Vector.<Diagnostic>):void
		{
			_diagnostics = value;
		}
		public function get diagnostics():Vector.<Diagnostic>
		{
			return _diagnostics;
		}

		public function set codeActions(value:Vector.<CodeAction>):void
		{
			_codeActions = value;
		}
		public function get codeActions():Vector.<CodeAction>
		{
			return _codeActions;
		}
		
		public function set width(value:Number):void
		{
			_width = value;
		}
		public function get width():Number
		{
			return _width;
		}
		
		public function get startContext():int
		{
			return _meta && _meta.length > 1 ? _meta[1] : 0;
		}
		
		public function get endContext():int
		{
			return _meta && _meta.length > 1 ? _meta[_meta.length-1] : 0;
		}
		
		public function TextLineModel(text:String)
		{
			this.text = text;
		}
		
		public function toString():String
		{
			return text;
		}
		
		public function set isQuoteTextOpen(value:Boolean):void
		{
			_isQuoteTextOpen = value;
		}
		public function get isQuoteTextOpen():Boolean
		{
			return _isQuoteTextOpen;
		}
		
		public function set lastQuoteText(value:String):void
		{
			_lastQuoteText = value;
		}
		public function get lastQuoteText():String
		{
			return _lastQuoteText;
		}
	}
}