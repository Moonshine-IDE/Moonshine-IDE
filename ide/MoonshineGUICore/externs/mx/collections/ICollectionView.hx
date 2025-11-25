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
package mx.collections;

import openfl.events.IEventDispatcher;

extern interface ICollectionView extends IEventDispatcher {
	public var filterFunction:(Dynamic) -> Bool;
	public var length(default, never):Int;
	public var sort:ISort;

	public function contains(item:Dynamic):Bool;
	public function createCursor():IViewCursor;
	public function disableAutoUpdate():Void;
	public function enableAutoUpdate():Void;
	public function itemUpdated(item:Dynamic, property:Dynamic = null, oldValue:Dynamic = null, newValue:Dynamic = null):Void;
	public function refresh():Bool;
}
