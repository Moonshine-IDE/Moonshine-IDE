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
		public var showAlert					: Boolean;

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
		
		public function DataAgent(_postURL:String, _successFn:Function, _errorFn:Function, _anObject:Object = null, _eventType:String=POSTEVENT, _timeout:Number=0, _showAlert:Boolean=true)
		{
			successFunctionCallback = _successFn;
			errorFunctionCallback = _errorFn;
			postUrl = _postURL;
			anObject = _anObject;
			eventType = _eventType;
			timeOut = _timeout;
			showAlert = _showAlert;
			
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
						GlobalEventDispatcher.getInstance().dispatchEvent(
								new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, htmlType.message));
						
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
				if (showAlert)
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
				if (showAlert)
					Alert.show(event.text, "Error!");
				errorFunctionCallback( event.text );
			}
			
			// finally clear the event
			dispose();
		}
	}
}