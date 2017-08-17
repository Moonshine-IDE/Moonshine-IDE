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
package actionScripts.controllers
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import spark.components.Alert;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.DataHTMLType;
	
	import components.popup.LoginPopUp;
	
	/**
	 * DataAgent
	 * 
	 * The agent designed in the way as
	 * one at a time usage - do not
	 * use for parallel use, if you needs to
	 * do that then create different instances of
	 * the class.
	 */
	public class DataAgent
	{
		//--------------------------------------------------------------------------
		//
		//  PUBLIC STATIC CONST
		//
		//--------------------------------------------------------------------------
		
		public static const GENERICPOSTEVENT		: String = "GENERICPOSTEVENT";
		public static const POSTEVENT				: String = "POST";
		public static const GETEVENT				: String = "GET";
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC VARIABLES
		//
		//--------------------------------------------------------------------------
		
		public var successFunctionCallback		: Function; // Holds the author component's success handler (param: errorMessage, successMessage ..args)
		public var errorFunctionCallback		: Function; // Holds the author component's fault handler (param: errorMessage)
		public var anObject						: Object;
		public var eventType					: String;
		public var postUrl						: String;
		public var timeOut						: Number;
		//--------------------------------------------------------------------------
		//
		//  PRIVATE VARIABLES
		//
		//--------------------------------------------------------------------------
		
		private var httpService					: URLLoader;
		private var pop							: LoginPopUp;
		
		/**
		 * CONSTRUCTOR
		 * 
		 * Initiates HTTP request event for any
		 * GET or POST data transaction
		 * 
		 * @required
		 * type, successFunction, errorFunction
		 * @optional
		 * postURL, postObject, timeoutSeconds
		 */
		
		public function DataAgent(_postURL:String, _successFn:Function, _errorFn:Function, _anObject:Object = null, _eventType:String=POSTEVENT, _timeout:Number=0)
		{
			successFunctionCallback = _successFn;
			errorFunctionCallback = _errorFn;
			postUrl = _postURL;
			anObject = _anObject;
			eventType = _eventType;
			timeOut = _timeout;
			
			// starting the call
			var urlVariables : URLVariables = new URLVariables();
			var urlVariablesFieldCount : int; 
			for ( var i:String in _anObject ) {
				urlVariables[ i ] = _anObject[ i ];
				urlVariablesFieldCount ++;
			}
			
			var request : URLRequest = new URLRequest();
			request.data = urlVariables;
			request.url = _postURL;
			request.method = _eventType;
			
			httpService = new URLLoader();
			httpService.addEventListener( Event.COMPLETE, onSuccess );
			httpService.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			httpService.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			httpService.load( request );
		}
		
		//--------------------------------------------------------------------------
		//
		//  PROTECTED API
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Dispose everything 
		 */
		protected function dispose() : void
		{
			// probable termination
			if ( !httpService ) return;
			if(pop) pop=null;
			httpService.close();
			httpService.removeEventListener( Event.COMPLETE, onSuccess );
			httpService.removeEventListener( IOErrorEvent.IO_ERROR, onIOError );
			httpService.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
			successFunctionCallback = errorFunctionCallback = null;
			httpService = null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  LISTENERS API
		//
		//--------------------------------------------------------------------------
		
		/**
		 * On success callback
		 */
		private function onSuccess( event:Event ) : void
		{
			//if user is redirected to login page then his authentication has been expired.
			if(event.target.data.toString().indexOf("<html") >= 0)
			{
				var htmlType:DataHTMLType = UtilsCore.getDataType(event.target.data.toString());
				if (htmlType)
				{
					if (htmlType.type == DataHTMLType.SESSION_ERROR)
					{
						GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(htmlType.message));
						
						//Show login popup again and save current dataagent params
						pop = new LoginPopUp();
						PopUpManager.addPopUp(pop, FlexGlobals.topLevelApplication as DisplayObject, false);
						pop.isLastDataCallingAgent = true;
						pop.anObject = anObject;
						pop.successFunctionCallback = successFunctionCallback;
						pop.errorFunctionCallback = errorFunctionCallback;
						pop.postUrl = postUrl;
						pop.timeOut = timeOut;
						pop.eventType = eventType;
						PopUpManager.centerPopUp(pop);
					}
					else if (htmlType.type == DataHTMLType.LOGIN_ERROR)
					{
						if ( successFunctionCallback != null ) successFunctionCallback(htmlType.message, false); // login handler, only has double parameters
					}
					else if (htmlType.type == DataHTMLType.LOGIN_SUCCESS)
					{
						if ( successFunctionCallback != null ) successFunctionCallback(htmlType.message, true); // login handler, only has double parameters
					}
				}
			}
			else
			{	
				if ( successFunctionCallback != null ) successFunctionCallback(event.target.data);
			}
			
			// finally clear the event
			dispose();
		}
		
		/**
		 * On error callback
		 */
		private function onIOError( event:IOErrorEvent ) : void
		{
			// Fault definition of having a 'onErrorPostHandler()'
			// in the Post event initiator component.
			if (errorFunctionCallback != null)
			{
				Alert.show(event.text, "Error!");
				errorFunctionCallback( event.text );
			}
			
			// finally clear the event
			dispose();
		}
		
		/**
		 * On security error
		 */
		private function onSecurityError(event:SecurityErrorEvent):void
		{
			// Fault definition of having a 'onErrorPostHandler()'
			// in the Post event initiator component.
			if (errorFunctionCallback != null)
			{
				Alert.show(event.text, "Error!");
				errorFunctionCallback( event.text );
			}
			
			// finally clear the event
			dispose();
		}
	}
}