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
package actionScripts.ui.notifier
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;
	import mx.events.EffectEvent;
	
	import components.views.notifier.ActionNotifyItem;
	
	public class ActionNotifier extends Canvas
	{
		private static var instance:ActionNotifier;
		
		public static function getInstance():ActionNotifier {
			
			if (!instance)
				instance = new ActionNotifier();
			
			return instance;	
		}
		
		protected var showTimer:Timer;
		
		protected var notifyQueue:Array = [];
		
		protected var isShowing:ActionNotifyItem;
		
		public function notify(about:String):void {
			notifyQueue.push(about);
			checkQueue();
		}
		
		protected function checkQueue(e:Object=null):void {
			if (isShowing) return;
			
			if (notifyQueue.length > 0)
				showNew();
		}
		
		protected function showNew():void {
			var item:ActionNotifyItem = new ActionNotifyItem();
			item.notifyText = notifyQueue.pop();
			addChild(item);
			
			isShowing = item;
			
			showTimer = new Timer(500, 1);
			showTimer.addEventListener(TimerEvent.TIMER_COMPLETE, showDone);
			showTimer.start();
		}
		
		protected function showDone(e:Object=null):void {
			if (isShowing.alpha == 1) {
				isShowing.removeEffect.addEventListener(EffectEvent.EFFECT_END, showDone);
				isShowing.removeEffect.play([isShowing]);
			} else {
				removeChild(isShowing);
				isShowing = null;
				checkQueue();	
			}
		}

	}
}