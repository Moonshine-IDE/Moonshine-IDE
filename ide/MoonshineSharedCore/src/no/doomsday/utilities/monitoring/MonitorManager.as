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
package no.doomsday.utilities.monitoring 
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import no.doomsday.console.core.DConsole;
	import no.doomsday.console.core.introspection.ScopeManager;
	import no.doomsday.console.core.messages.MessageTypes;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class MonitorManager
	{
		
		private var monitors:Vector.<Monitor> = new Vector.<Monitor>();
		private var monitorTimer:Timer = new Timer(300);
		private var console:DConsole;
		private var scopeManager:ScopeManager;
		public function MonitorManager(console:DConsole,scopeMgr:ScopeManager)
		{
			this.console = console;
			this.scopeManager = scopeMgr;
			monitorTimer.addEventListener(TimerEvent.TIMER, update);
		}
		public function set interval(n:int):void {
			if (n < 1000/console.stage.frameRate) {
				n = 1000/console.stage.frameRate;
			}
			monitorTimer.delay = n;
		}
		public function get interval():int {
			return monitorTimer.delay;
		}
		public function start():void {
			monitorTimer.start();
		}
		public function stop():void {
			monitorTimer.stop();
		}
		public function addMonitor(scope:Object, ...properties:Array):Monitor {
			var m:Monitor;
			for (var i:int = 0; i < monitors.length; i++) 
			{
				if (monitors[i].scope == scope) {
					m = monitors[i];
					inner: for (var j:int = 0; j < properties.length; j++) 
					{
						for (var k:int = 0; k < monitors[i].properties.length; k++) 
						{
							if (properties[j] == monitors[i].properties[k]) continue inner;
						}
						monitors[i].properties.push(properties[j]);
					}
					console.print("Existing monitor found, appending properties", MessageTypes.SYSTEM);
				}
			}
			if (!m) {
				m = new Monitor(scope, properties);
				monitors.push(m);
				console.print("New monitor created", MessageTypes.SYSTEM);
			}
			return m;
			
		}
		public function removeMonitor(scope:Object):Boolean {
			for (var i:int = 0; i < monitors.length; i++) 
			{
				if (monitors[i].scope == scope) {
					monitors.splice(i, 1);
					return true;
				}
			}
			return false;
		}
		private function update(e:TimerEvent = null):void {
			for (var i:int = 0; i < monitors.length; i++) 
			{
				monitors[i].update();
			}
		}
		
		public function destroyMonitors():void
		{
			monitors = new Vector.<Monitor>;
			console.print("All monitors destroyed",MessageTypes.SYSTEM);
		}
		
		public function destroyMonitor():void
		{
			if (removeMonitor(scopeManager.currentScope.obj)) {
				console.print("Removed", MessageTypes.SYSTEM);
			}else {
				console.print("No such monitor", MessageTypes.ERROR);
			}
		}
		
		public function createMonitor(...properties:Array):void
		{
			properties.unshift(scopeManager.currentScope.obj);
			addMonitor.apply(this, properties);
		}
		public function setMonitorInterval(i:int = 300):int {
			if (i < 0) i = 0;
			monitorTimer.delay = i;
			return monitorTimer.delay;
		}
		
	}

}