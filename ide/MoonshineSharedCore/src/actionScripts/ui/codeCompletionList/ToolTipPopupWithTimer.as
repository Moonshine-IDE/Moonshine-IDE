////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.ui.codeCompletionList
{
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import mx.controls.ToolTip;
    import mx.managers.PopUpManager;

    [Event(name="close", type="flash.events.Event")]
    public class ToolTipPopupWithTimer extends ToolTip
    {
        public static const HIDE_DELAY:Number = 2500;
        
        private var timer:Timer;
        
        public function ToolTipPopupWithTimer()
        {
            super();

            addEventListener(Event.REMOVED_FROM_STAGE, onToolTipPopupRemovedFromStage);
            timer = new Timer(HIDE_DELAY);
            timer.addEventListener(TimerEvent.TIMER, onToolTipTimer);
            timer.start();
        }

        private function onToolTipTimer(event:TimerEvent):void
        {
            PopUpManager.removePopUp(this);

            cleanUpTimer();
            dispatchEvent(new Event(Event.CLOSE));
        }


        private function onToolTipPopupRemovedFromStage(event:Event):void
        {
            removeEventListener(Event.REMOVED_FROM_STAGE, onToolTipPopupRemovedFromStage);
            cleanUpTimer();
        }

        private function cleanUpTimer():void
        {
            if (!timer) return;

            timer.stop();
            timer.removeEventListener(TimerEvent.TIMER, onToolTipTimer);
            timer = null;
        }
    }
}
