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

            addEventListener(Event.ADDED_TO_STAGE, onToolTipPopupAddedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, onToolTipPopupRemovedFromStage);
        }

        public function close():void
        {
            PopUpManager.removePopUp(this);
        }

        private function onToolTipTimer(event:TimerEvent):void
        {
            PopUpManager.removePopUp(this);

            dispatchEvent(new Event(Event.CLOSE));
        }

        private function onToolTipPopupAddedToStage(event:Event):void
        {
            cleanUpTimer();

            timer = new Timer(HIDE_DELAY);
            timer.addEventListener(TimerEvent.TIMER, onToolTipTimer);
            timer.start();
        }

        private function onToolTipPopupRemovedFromStage(event:Event):void
        {
            cleanUpTimer();
        }

        private function cleanUpTimer():void
        {
            if (!timer) return;

            timer.removeEventListener(TimerEvent.TIMER, onToolTipTimer);
            timer.stop();
            timer = null;
        }
    }
}
