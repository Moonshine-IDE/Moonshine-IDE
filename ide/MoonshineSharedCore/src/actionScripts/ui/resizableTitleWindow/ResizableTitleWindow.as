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
package actionScripts.ui.resizableTitleWindow
{
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.geom.Point;
    import flash.ui.Keyboard;
    
    import mx.events.CloseEvent;
    import mx.managers.PopUpManager;
    
    import spark.components.TitleWindow;
    
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
        
        private var clickOffset:Point;
        
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
		}
		
		/**
		 *  @protected
		 */
		protected function closeByCrossSign(event:Event):void
		{
			if (stage) stage.removeEventListener(KeyboardEvent.KEY_DOWN, onResizeKeyDownEvent);
			removeEventListener(CloseEvent.CLOSE, closeByCrossSign);
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
	}
}