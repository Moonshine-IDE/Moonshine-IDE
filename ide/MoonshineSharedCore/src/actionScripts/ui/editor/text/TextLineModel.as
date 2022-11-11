////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.ui.editor.text
{
	import moonshine.lsp.Diagnostic;
	import moonshine.lsp.CodeAction;

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