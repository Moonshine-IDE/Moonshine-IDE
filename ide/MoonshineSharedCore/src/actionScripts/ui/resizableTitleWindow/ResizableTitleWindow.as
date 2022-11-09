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
package actionScripts.ui.resizableTitleWindow
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.TitleWindow;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.LayoutEvent;
	
	/**
	 *  ResizableTitleWindow is a TitleWindow with
	 *  a resize handle.
	 */
	public class ResizableTitleWindow extends TitleWindow
	{
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 */
		public function ResizableTitleWindow()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  Properties 
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		// 
		// Event Handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function onAddedToStage(event:Event):void
		{
			addEventListener(CloseEvent.CLOSE, closeByCrossSign);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onResizeKeyDownEvent);
			GlobalEventDispatcher.getInstance().addEventListener(LayoutEvent.WINDOW_MAXIMIZED, onNativeWindowResized, false, 0, true);
			GlobalEventDispatcher.getInstance().addEventListener(LayoutEvent.WINDOW_NORMAL, onNativeWindowResized, false, 0, true);
		}
		
		/**
		 *  @protected
		 */
		protected function closeByCrossSign(event:Event):void
		{
			if (stage) stage.removeEventListener(KeyboardEvent.KEY_DOWN, onResizeKeyDownEvent);
			removeEventListener(CloseEvent.CLOSE, closeByCrossSign);
			GlobalEventDispatcher.getInstance().removeEventListener(LayoutEvent.WINDOW_MAXIMIZED, onNativeWindowResized);
			GlobalEventDispatcher.getInstance().removeEventListener(LayoutEvent.WINDOW_NORMAL, onNativeWindowResized);
			PopUpManager.removePopUp(this);
		}
		
		/**
		 *  @protected
		 */
		protected function onResizeKeyDownEvent(event:KeyboardEvent):void
		{
			if (event.charCode == Keyboard.ESCAPE)
			{
				callLater(closeByCrossSign, [null]);
				dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
			}
		}
		
		/**
		 *  @protected
		 */
		protected function closeThis():void
		{
			callLater(closeByCrossSign, [null]);
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE, true));
		}
		
		protected function onNativeWindowResized(event:Event):void
		{
			PopUpManager.centerPopUp(this);
		}
	}
}