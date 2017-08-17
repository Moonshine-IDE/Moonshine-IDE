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

 /** Tool for displaying a trace window in a released/uploaded SWF
  *
  * Created by Ã˜yvind Nordhagen, www.oyvindnordhagen.com.
  * Released for use, change and distribution free of charge as
  * long as this author credit is left as is.
  * 
  * For documentation, suggestions and bug reporting, see www.oyvindnordhagen.com/blog/ailogger/
  */

package no.doomsday.console.core
{
	import no.doomsday.console.core.messages.Message;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import flash.xml.XMLNode;
	import no.doomsday.console.core.commands.ConsoleCommand;
	import no.doomsday.console.core.interfaces.IConsole;
	import no.doomsday.console.core.interfaces.IDisplayable;
	import no.doomsday.console.core.interfaces.ILogger;
	import no.doomsday.console.core.events.DLoggerEvent;
	import no.doomsday.console.core.messages.MessageTypes;
	import no.doomsday.console.core.text.TextFormats;
	import no.doomsday.console.core.text.TextUtils;
	
	public final class DLogger extends AbstractConsole
	{
		private static const WELCOME_MESSAGE:String		= "Welcome to DLogger by Øyvind Nordhagen - www.oyvindnordhagen.com";
		private static const VERSION:String 			= "1.0";
		private static const OPEN_LOGGER_LABEL:String 	= "Show DLogger";
		private static const CLOSE_LOGGER_LABEL:String 	= "Close DLogger";
		private static const CODE_HEX:uint				= 99
		
		public var detailedLogging			:Boolean;
		public var disablePassword			:Boolean;
		public var disableSenderLabels		:Boolean;
		public var alwaysOnTop				:Boolean = true;
		public var scrollOnNewLine			:Boolean = true;
		
		private var _password				:String;	
		private var _passwordEntered		:String 	= "";
		private var _scrollSpeed			:int 		= 2;
		private var _enableContextMenu		:Boolean 	= true;
		private var _logColoring			:Boolean 	= true;
		private var _inverseColor			:Boolean	= false;
		private var _isVisible				:Boolean;
		private var _fmt					:Dictionary = new Dictionary();
		private var _senderFmt				:TextFormat;
		private var _describeFmt			:TextFormat;
		private var _passwordField			:TextField;
		private var _txt					:TextField;
		private var _bg						:Shape 		= new Shape();
		private var _passwordTimer			:Timer;
		private var _lastMessage			:String;
		private var _lastMessageRepeat		:uint;
		private var _maxHeight				:uint;
		private var _width					:uint;
		private var _height					:uint;
		private var _txtBounds				:Rectangle;
		private var _fadeTarget:Number = 1;
		
		/**
		 * Constructor function
		 *
		 * @param	$password		Password for opening trace window. Empty string = no password
		 * @param	$width			Width of the log window, default: fills stage.
		 * @param	$password		Height of the log window, default: fills stage
		 */
		public function DLogger($password:String = "", $width:uint = 0, $height:uint = 0)
		{
			_password = $password;
			_width = $width;
			_height = $height;
			
			_setColorScheme();
			
			//_senderFmt = _getFmt(0xFFFFFF);
			_describeFmt = TextFormats.debugTformatSystem;
			
			_createTraceWindow();
			
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
		}
		
		override public function setPassword(pass:String):void {
			_password = pass;
		}
		
		public function set inverseColorScheme($val:Boolean):void
		{
			_inverseColor = $val;
			_setColorScheme();
			
			if (_bg != null)
			{
				_redrawBg();
			}
		}
		
		protected function _setColorScheme():void
		{
			if (_inverseColor)
				_setInverseColor();
			else
				_setRegularColor();
		}
		
		protected function _setInverseColor():void
		{
			_fmt[MessageTypes.OUTPUT] 	= TextFormats.getInverse(TextFormats.debugTformatNew);
			_fmt[MessageTypes.WARNING] 	= TextFormats.getInverse(TextFormats.debugTformatWarning);
			_fmt[MessageTypes.ERROR] 	= TextFormats.getInverse(TextFormats.debugTformatError);
			_fmt[MessageTypes.SYSTEM] 	= TextFormats.getInverse(TextFormats.debugTformatSystem);
			_fmt[MessageTypes.EVENT] 	= TextFormats.getInverse(TextFormats.debugTformatEvent);
			_fmt[MessageTypes.TRACE] 	= TextFormats.getInverse(TextFormats.debugTformatTrace);
			
			//_fmt[MessageTypes.OUTPUT] 	= _getFmt(0xFFFFFF);
			//_fmt[MessageTypes.WARNING] 	= _getFmt(0xFF6600);
			//_fmt[MessageTypes.ERROR] 	= _getFmt(0xFF0000);
			//_fmt[MessageTypes.SYSTEM] 	= _getFmt(0x00FF00);
			//_fmt[MessageTypes.EVENT] 	= _getFmt(0x0099FF);
			//_fmt[MessageTypes.TRACE] 	= _getFmt(0x999999);
		}
		
		protected function _setRegularColor():void
		{
			_fmt[MessageTypes.OUTPUT] 	= TextFormats.debugTformatNew;
			_fmt[MessageTypes.WARNING] 	= TextFormats.debugTformatWarning;
			_fmt[MessageTypes.ERROR] 	= TextFormats.debugTformatError;
			_fmt[MessageTypes.SYSTEM] 	= TextFormats.debugTformatSystem;
			_fmt[MessageTypes.EVENT] 	= TextFormats.debugTformatEvent;
			_fmt[MessageTypes.TRACE] 	= TextFormats.debugTformatTrace;
			
			//_fmt[MessageTypes.OUTPUT] = _getFmt(0x000000);
			//_fmt[MessageTypes.WARNING] = _getFmt(0x996600);
			//_fmt[MessageTypes.ERROR] = _getFmt(0xCC0000);
			//_fmt[MessageTypes.SYSTEM] = _getFmt(0x009900);
			//_fmt[MessageTypes.EVENT] = _getFmt(0x000099);
			//_fmt[MessageTypes.TRACE] = _getFmt(0x666666);
		}
		
		public function get inverseColorScheme():Boolean
		{
			return _inverseColor;
		}
		
		public function get coloring():Boolean
		{
			return _logColoring;
		}
		
		public function set coloring($val:Boolean):void
		{
			_logColoring = $val;
			
			if (!$val)
			{
				_resetLogColoring();
			}
		}
		
		public function get enableContextMenu():Boolean
		{
			return _enableContextMenu;
		}
		
		public function set enableContextMenu($val:Boolean):void
		{
			if (parent != null)
			{
				if ($val && parent.contextMenu == null)
				{
					_createContextMenuItems();
				}
				else if (!$val && parent.contextMenu != null)
				{
					_removeContextMenuItems();
				}
			}
			
			_enableContextMenu = $val;
		}
		
		public function getLogText():String
		{
			return _txt.text;
		}
		
		public function get isVisible():Boolean
		{
			return _isVisible;
		}
		
		public function toggle():void
		{
			_toggleVisible();
		}
		
		public function describe($obj:Object, $objectName:String = ""):void
		{
			if ($objectName == "")
			{
				if ($obj.toString() != "[object Object]")
				{
					_log(_getClassName($obj) + ":\n", "", true, false);
				}
				else
				{
					_log("Describe:\n", "", true, false);
				}
			}
			else
			{
				_log($objectName + ":\n", "", true, false);
			}
				
			_applySeverityColor(MessageTypes.OUTPUT);
			
			var variables:XMLList = describeType($obj).variable;
			var numVariables:uint = variables.length();
			
			if (numVariables > 0)
			{
				for (var i:uint = 0; i < numVariables; i++)
				{
					var v:XML = variables[i];
					var value:String = ($obj[v.@name] == "") ? "\"\"" : $obj[v.@name];
					_log(v.@name + ":" + v.@type + " = " + value, "", false, false);
					_applySeverityColor(MessageTypes.TRACE, 0, false, true);
				}
			}
			else
			{
				for (var prop:String in $obj)
				{
					_log(prop + ": " + $obj[prop], "", false, false);
					_applySeverityColor(MessageTypes.TRACE, 0, false, true);
					numVariables++;
				}
			}
			
			_log("<" + numVariables + " properties found>\n", "", false, false);
			_applySeverityColor(MessageTypes.TRACE, 0, false, true);
		}
		
		public function cr($numLines:uint = 1):void
		{
			var cr:String = ""
			for (var i:uint = 0; i < $numLines; i++) cr += "\n";
			_write(cr);
		}
		
		public function header($text:String, $severity:int = MessageTypes.OUTPUT):void
		{
			_write("\n\n\t");
			_write($text.toUpperCase());
			_applySeverityColor($severity);
			_write("\n");
		}
		
		override public function log(...args:Array):void {
			for (var i:int = 0; i < args.length; i++) 
			{
				addMessage(args[i]);
			}
		}
		public function addMessage($msg:Object, $severity:int = MessageTypes.OUTPUT, $appendLast:Boolean = false):void
		{
			if (!_fmt[$severity])
			{
				$severity = MessageTypes.OUTPUT;
			}
			
			var str:String;
			var append:Boolean = $appendLast;
			var sender:String = "";
			var customColor:uint = 0;
			
			if ($msg is DLoggerEvent)
			{
				var aie:DLoggerEvent = ($msg as DLoggerEvent);
				$msg = aie.message;
				
				switch (aie.type)
				{
					case DLoggerEvent.LOG:
					$severity = aie.severity;
					append = aie.appendLast;
					sender = (aie.origin is String) ? aie.origin as String : _getEventTargetName(aie);
					break;
				
					case DLoggerEvent.DESCRIBE:
					describe($msg);
					return;
					break;
				
					default:
					throw new Error("Invalid DLoggerEvent type: " + aie.type);
				}
			}
			
			if ($msg == null)
			{
				$msg = "null";
				$severity = MessageTypes.ERROR;
			}
			
			if ($msg is String)
			{
				str = String($msg);
			}
			else if ($msg is Number || $msg is int)
			{
				var hex:String = $msg.toString(16).toUpperCase();
				str = String($msg);
				
				if (hex.length == 6)
				{
					str += ", HEX: " + hex;
					$severity = CODE_HEX;
					customColor = $msg as uint;
				}
			}
			else if ($msg is Array)
			{
				str = (detailedLogging) ? ($msg as Array).join() + "(" + ($msg as Array).length + " elements)" : ($msg as Array).join();
			}
			else if ($msg is XML || $msg is XMLNode || $msg is XMLList)
			{
				str = $msg.toXMLString();
			}
			else if ($msg is Error)
			{
				str = (detailedLogging) ? ($msg as Error).getStackTrace() : ($msg as Error).message;
				$severity = MessageTypes.ERROR;
			}
			else if ($msg is ErrorEvent)
			{
				sender = _getEventTargetName($msg as ErrorEvent);
				str = _getClassName($msg) + ": " + ($msg as ErrorEvent).text;
				$severity = MessageTypes.ERROR;
			}
			else if ($msg is Event)
			{
				var e:Event = $msg as Event;
				sender = _getEventTargetName(e);
				str = "EVENT: " + e.toString();
				$severity = MessageTypes.EVENT;
			}
			else
			{
				str = getQualifiedClassName($msg);
				if ($msg.name != undefined) str += "." + $msg.name;
				
				if (detailedLogging)
				{
					str += "\n" + describeType($msg).toXMLString();
				}
			}
			
			if (!append)
			{
				_log(str, sender);
			}
			else
			{
				_appendLast(str);
			}
			
			_applySeverityColor($severity, customColor, append);
		}
		
		private function _getFmt($color:uint):TextFormat
		{
			return new TextFormat("_sans", 11, $color);
		}
		
		private function _resetLogColoring():void
		{
			_txt.setTextFormat(_fmt[MessageTypes.OUTPUT]);
		}
		
		private function _appendLast($str:String):void
		{
			_write(" â€º " + $str);
		}
		
		private function _appendRepeat($repeatCount:uint):void
		{
			if ($repeatCount > 2)
			{
				_txt.replaceText(_txt.text.lastIndexOf("(") + 1, _txt.text.lastIndexOf(")"), $repeatCount.toString())
			}
			else
			{
				_write(" (" + $repeatCount + ")");
			}
		}
		
		private function _write($text:String):void
		{
			_txt.appendText($text);
			if (scrollOnNewLine) _txt.scrollV = _txt.maxScrollV;
			if (alwaysOnTop) _moveToTop();
		}
		
		private function _applySeverityColor($severity:uint, $customColor:uint = 0, $append:Boolean = false, $describe:Boolean = false):void
		{
			var fmt:TextFormat;
			
			if (_logColoring)
			{
				if (!$describe)
				{
					fmt = ($severity != CODE_HEX) ? _fmt[$severity] : _getFmt($customColor);
				}
				else
				{
					fmt = _describeFmt;
				}
					
				var firstChar:uint = (!$append) ? _txt.getFirstCharInParagraph(_txt.text.length - 1) : _txt.text.lastIndexOf("â€º");
				_txt.setTextFormat(fmt, firstChar, _txt.text.length);
			}
		}
		
		/**
		 * Sets the logger dimensions
		 * @param	rectangle
		 */
		public function setDims(rectangle:Rectangle):void {
			_width = rectangle.width;
			_height = rectangle.height;
			_createBg();
			
			_txt.width 			= _bg.width - 10;
			_txt.height 		= _bg.height - 10;
			_txtBounds.width 	= _bg.width - 40;
			_txtBounds.height 	= _bg.height - 20;
			_txt.scrollRect 	= _txtBounds;
		}
		/**
		 * Gets the currently set logger dimensions
		 * @return
		 */
		public function getDims():Rectangle {
			return _txtBounds.clone();
		}
		
		private function _createBg():void
		{
			if (!stage) return;
			_bg.graphics.clear();
			
			var fillColor:uint = _inverseColor ? 0xFFFFFF : 0x000000;
			_bg.graphics.beginFill(fillColor, 0.8);
			
			var w:uint = (_width == 0) ? stage.stageWidth - 10 : _width;
			var h:uint = (_height == 0) ? stage.stageHeight - 10 : _height;
			
			_bg.graphics.drawRect(0, 0, w, h);
			_bg.graphics.endFill();
		}
		
		private function _createContextMenuItems():void
		{
			if (_enableContextMenu && parent != null)
			{
				var openItem:ContextMenuItem = new ContextMenuItem(OPEN_LOGGER_LABEL);
					openItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, _validateOpen);
									
				parent.contextMenu = new ContextMenu();
				//parent.contextMenu.customItems = [openItem];
			}
		}
		
		private function _createPasswordField():void
		{
			if (parent == null) return;
			
			_passwordField 						= new TextField();
			_passwordField.width 				= 120;
			_passwordField.height 				= 20;
			_passwordField.background 			= true;
			_passwordField.border 				= true;
			_passwordField.selectable 			= true;
			_passwordField.type 				= TextFieldType.INPUT;
			_passwordField.defaultTextFormat 	= new TextFormat("_sans", 11, 0x000000, false, null, null,
															  null, null, TextFormatAlign.CENTER);
			_passwordField.borderColor 			= 0xFFFFFF;
			_passwordField.backgroundColor 		= 0x000000;
			_passwordField.x 					= stage.stageWidth * 0.5 - _passwordField.width * 0.5;
			_passwordField.y 					= stage.stageHeight * 0.5 - _passwordField.height * 0.5;
			_passwordField.text 				= "Enter password";
			
			_passwordField.setSelection(0, _passwordField.text.length);
			_passwordField.addEventListener(Event.CHANGE, _onPasswordKeyDown);
			
			addChild(_passwordField);
			stage.focus = _passwordField;
			_moveToTop()
		}
		
		private function _createTraceWindow():void
		{
			_createBg();
			
			_txt 			= new TextField();
			_txt.width 		= _bg.width - 10;
			_txt.height 	= _bg.height - 10;
			_txt.multiline 	= true;
			_txt.wordWrap 	= true;
			_txt.x 			= 5;
			_txt.y 			= 5;
			
			_txtBounds = new Rectangle();
			_txtBounds.x 		= 0;
			_txtBounds.y 		= 5;
			
			_txtBounds.width 	= _bg.width - 40;
			_txtBounds.height 	= _bg.height - 20;
			
			_txt.scrollRect = _txtBounds;
			_txt.defaultTextFormat = _fmt[MessageTypes.OUTPUT];
			_txt.text = "";
			
			if (x == 0)
			{
				x = 5;
			}
			
			if (y == 0)
			{
				y = 5;
			}
			
			_bg.visible = false;
			_txt.visible = false;
			
			addChild(_bg);
			addChild(_txt);
			
			log("Welcome to DLogger v" + VERSION + " |  Booted at " + new Date().toString() + "\n");
			log("Player version is " + Capabilities.version + "\n");
		}
		
		private function _getClassName(o:Object):String
		{
			var fullName:String = getQualifiedClassName(o);
			var ret:String;
			
			try
			{
				ret = fullName.substr(fullName.lastIndexOf(":") + 1);
			}
			catch (e:Error)
			{
				ret = o.toString();
			}
			
			return ret;
		}
		
		private function _getEventTargetName(e:Object):String
		{
			var tgt:String = "";
			
			if (e is Event && e.target != null || e.currentTarget != null)
			{
				var tg:Object;
				
				if (e is DLoggerEvent && (e as DLoggerEvent).origin != null)
				{
					tg = (e as DLoggerEvent).origin;
				}
				else if (e is Event)
				{
					tg = (e.currentTarget == null) ? e.target : e.currentTarget;
				}
				else
				{
					tg = e;
				}
				
				var tgs:String = tg.toString();
				tgt = tgs.substring(tgs.lastIndexOf(" ") + 1, tgs.length - 1);
				
				try
				{
					if (String(tg.name).substr(0, 8) != "instance")
					{
						tgt += " (" + e.target.name + ")";
					}
				}
				catch (e:ReferenceError) { /* Why bother...*/ }
			}
			
			return tgt;
		}
		
		private function _log($msg:String, $sender:String = null, $useTimeStamp:Boolean = true, $useSenderLabel:Boolean = true):void
		{
			if ($msg != _lastMessage)
			{
				if ($msg != "\n\n" && $msg != "\n")
				{
					var now:String = new Date().toTimeString().substr(0, 8);
					var lastChar:uint = $msg.length;
					var returns:Array = new Array();
					
					while ($msg.charAt(lastChar - 1) == "\n")
					{
						lastChar--;
						returns.push("\n");
					}
					
					if (!disableSenderLabels && $useSenderLabel)
					{
						if ($sender != "")
						{
							$sender = " ~ " + $sender;
						}
						else if (parent != null)
						{
							var tgs:String = parent.toString();
							$sender = " ~ " + tgs.substring(tgs.lastIndexOf(" ") + 1, tgs.length - 1);
						}
						else
						{
							$sender = " ~ [unknown origin]"
						}
					}
					
					if ($useTimeStamp)
					{
						_write("\n" + now + "   " + $msg.substr(0, lastChar) + $sender + returns.join(""));
					}
					else
					{
						_write("\n\t" + $msg.substr(0, lastChar) + $sender + returns.join(""));
					}
					
					_lastMessage = $msg;
					_lastMessageRepeat = 1;
				}
				else
				{
					_write($msg);
				}
			}
			else
			{
				_lastMessageRepeat++;
				_appendRepeat(_lastMessageRepeat);
			}
		}
		
		private function _moveToTop():void
		{
			if (parent != null)
				parent.setChildIndex(this, parent.numChildren - 1);
		}
		
		private function _onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			
			_createContextMenuItems();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
		}
		
		// Making the trace window accessible by pressing SHIFT + ENTER
		private function _onKeyDown(e:KeyboardEvent):void
		{
			if (e.shiftKey && e.keyCode == Keyboard.ENTER)
			{
				_validateOpen();
			}
			else if (e.charCode == Keyboard.ENTER && _passwordField != null)
			{
				_validatePassword();
			}
			else if (e.charCode == Keyboard.ESCAPE && _passwordField != null)
			{
				_removePasswordField();
			}
		}
		
		private function _onPasswordKeyDown(e:Event):void
		{
			_passwordEntered = _passwordField.text;
			
			if (_passwordEntered == _password)
			{
				_passwordField.textColor = 0x00FF00;
			}
			else
			{
				_passwordField.textColor = 0xFF0000;
			}
		}
		
		private function _redrawBg():void
		{
			_createBg();
		}
		
		private function _removeContextMenuItems():void
		{
			if (parent != null && parent.contextMenu != null)
			{
			//	parent.contextMenu.customItems[1].removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, _validateOpen);
			//	parent.contextMenu.customItems = null;
				parent.contextMenu = null;
			}
		}
		
		private function _removePasswordField():void
		{
			removeChild(_passwordField);
			_passwordField.removeEventListener(Event.CHANGE, _onPasswordKeyDown);
			_passwordField = null;
			
			if (stage != null)
				stage.focus = null;
		}
		
		private function _scroll(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.DOWN && _txt.scrollV < _txt.maxScrollV)
			{
				_txt.scrollV += _scrollSpeed;
			}
			else if (e.keyCode == Keyboard.UP && _txt.scrollV > 0)
			{
				_txt.scrollV += _scrollSpeed * -1;
			}
			else if (e.keyCode == Keyboard.HOME)
			{
				_txt.scrollV = 0;
			}
			else if (e.keyCode == Keyboard.END)
			{
				_txt.scrollV = _txt.maxScrollV;
			}
		}
		
		private function _handleVisibility():void {
			if (_isVisible)
			{
				setDims(new Rectangle(x, y, _width, _height));
				_moveToTop(); // Asking parent DisplayObjectContainer to move logger to the top of the Display List
				enableScrolling();
				fadeIn();
			}
			else
			{
				disableScrolling();
				fadeOut();
			}
			
			if (_enableContextMenu)
			{
				/*if (parent != null && parent.contextMenu.customItems.length > 0) {
					//trace(parent.contextMenu.customItems);
					for (var i:int = 0; i < parent.contextMenu.customItems.length; i++) 
					{
						if (parent.contextMenu.customItems[i].caption == CLOSE_LOGGER_LABEL || parent.contextMenu.customItems[i].caption == OPEN_LOGGER_LABEL) {
							parent.contextMenu.customItems[i].caption = _isVisible ? CLOSE_LOGGER_LABEL : OPEN_LOGGER_LABEL;
							break;
						}
					}
				}*/
			}
		}
		
		private function fadeOut():void
		{
			alpha = 1;
			_fadeTarget = 0;
			addEventListener(Event.ENTER_FRAME, fade, false, 0, true);
		}
		
		private function fadeIn():void
		{	_txt.visible = _bg.visible = _isVisible;
			alpha = 0;
			_fadeTarget = 1;
			addEventListener(Event.ENTER_FRAME, fade, false, 0, true);
		}
		
		private function fade(e:Event):void 
		{
			alpha += (_fadeTarget - alpha) * .4;
			if (Math.abs(_fadeTarget - alpha) < 0.1) {
				removeEventListener(Event.ENTER_FRAME, fade);
				alpha = _fadeTarget;
				if(!_isVisible)	_txt.visible = _bg.visible = false;
			}
		}
		
		private function _setVisible(visibility:Boolean):Boolean {
			_isVisible = visibility;
			_handleVisibility();
			return visibility;
		}
		
		private function _toggleVisible():void
		{
			_isVisible = !_isVisible;
			//_bg.visible = !_bg.visible;
			//_txt.visible = !_txt.visible;
			_handleVisibility();
		}
		
		private function _validateOpen(e:ContextMenuEvent = null):void
		{
			if (_passwordEntered != _password && !disablePassword)
			{
				if (_passwordField == null)
				{
					_createPasswordField();
				}
				else
				{
					_removePasswordField();
				}
			}
			else
			{
				_toggleVisible();
			}
		}
		
		private function _validatePassword():void
		{
			if (_passwordEntered == _password)
			{
				disablePassword = true;
				_removePasswordField();
				_toggleVisible();
			}
		}
		
		public function disableScrolling():void
		{
			if (stage != null)
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, _scroll);
		}
		
		public function enableScrolling():void
		{
			if (stage != null)
				stage.addEventListener(KeyboardEvent.KEY_DOWN, _scroll);
		}
		
		/* INTERFACE no.doomsday.console.core.interfaces.ILogger */
		
		override public function show():void
		{
			_setVisible(true);
		}
		
		override public function hide():void
		{
			_setVisible(false);
		}
		
		override public function trace(...args:Array):void 
		{
			log.apply(this, args);
		}
	}
}