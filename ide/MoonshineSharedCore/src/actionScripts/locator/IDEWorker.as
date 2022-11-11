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
package actionScripts.locator
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.interfaces.IWorkerSubscriber;
	
	public class IDEWorker extends EventDispatcher
	{
		public static const WORKER_VALUE_INCOMING:String = "WORKER_VALUE_INCOMING";
		
		[Embed(source="/elements/swf/MoonshineWorker.swf", mimeType="application/octet-stream")]
		private static var WORKER_SWF:Class;
		private static var instance:IDEWorker;
		
		private var mainToWorker:MessageChannel;
		private var workerToMain:MessageChannel;
		private var worker:Worker;
		private var individualSubscriptions:Dictionary = new Dictionary();
		private var incomingData:Object;
		
		public static function getInstance():IDEWorker 
		{	
			if (!instance) 
			{
				instance = new IDEWorker();
				instance.initWorker();
			}
			
			return instance;
		}
		
		public function initWorker():void
		{
			var workerBytes:ByteArray = new WORKER_SWF() as ByteArray;
			worker = WorkerDomain.current.createWorker(workerBytes, true);
			
			// send to worker
			mainToWorker = Worker.current.createMessageChannel(worker);
			worker.setSharedProperty("mainToWorker", mainToWorker);
			
			// receive from worker
			workerToMain = worker.createMessageChannel(Worker.current);
			workerToMain.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMain);
			worker.setSharedProperty("workerToMain", workerToMain);
			worker.start();
		}
		
		public function subscribeAsIndividualComponent(udid:String, anyClass:Object):void
		{
			individualSubscriptions[udid] = anyClass;
		}
		
		public function unSubscribeComponent(udid:String):void
		{
			if (individualSubscriptions[udid] != undefined) 
			{
				delete individualSubscriptions[udid];
			}
		}
		
		public function sendToWorker(type:String, value:Object, subscriberUdid:String=null):void
		{
			mainToWorker.send({event: type, value: value, subscriberUdid: subscriberUdid});
		}
		
		private function onWorkerToMain(event:Event): void
		{
			incomingData = workerToMain.receive();
			if (incomingData.hasOwnProperty("subscriberUdid") && 
				individualSubscriptions[incomingData.subscriberUdid] != undefined)
			{
				try
				{
					(individualSubscriptions[incomingData.subscriberUdid] as IWorkerSubscriber).onWorkerValueIncoming(incomingData);
				}
				catch (e:Error){}
			}
			else
			{
				dispatchEvent(new GeneralEvent(WORKER_VALUE_INCOMING, incomingData));
			}
		}
	}
}