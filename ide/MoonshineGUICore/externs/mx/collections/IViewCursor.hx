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

extern interface IViewCursor extends IEventDispatcher {
	public var afterLast(default, never):Bool;
	public var beforeFirst(default, never):Bool;
	public var bookmark(default, never):CursorBookmark;
	public var current(default, never):Dynamic;
	public var view(default, never):ICollectionView;

	public function findAny(values:Dynamic):Bool;

	public function findFirst(values:Dynamic):Bool;
	public function findLast(values:Dynamic):Bool;

	public function insert(item:Dynamic):Void;

	public function moveNext():Bool;
	public function movePrevious():Bool;

	public function remove():Dynamic;

	public function seek(bookmark:CursorBookmark, offset:Int = 0, prefetch:Int = 0):Void;
}
