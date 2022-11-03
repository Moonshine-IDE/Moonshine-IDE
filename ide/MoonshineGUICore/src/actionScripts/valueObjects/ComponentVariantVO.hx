/**

Copyright (C) 2016-present Prominic.NET, Inc.
 
This program is free software: you can redistribute it and/or modify
it under the terms of the Server Side Public License, version 1,
as published by MongoDB, Inc.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
Server Side Public License for more details.

You should have received a copy of the Server Side Public License
along with this program. If not, see
http://www.mongodb.com/licensing/server-side-public-license.

As a special exception, the copyright holders give permission to link the
code of portions of this program with the OpenSSL library under certain
conditions as described in each individual source file and distribute
linked combinations including the program with the OpenSSL library. You
must comply with the Server Side Public License in all respects for
all of the code used other than as permitted herein. If you modify file(s)
with this exception, you may extend this exception to your version of the
file(s), but you are not obligated to do so. If you do not wish to do so,
delete this exception statement from your version. If you delete this
exception statement from all source files in the program, then also delete
it in the license file.

*/

package actionScripts.valueObjects;

@:bind
class ComponentVariantVO {
	public static final TYPE_ALPHA:String = "Alpha";
	public static final TYPE_BETA:String = "Beta";
	public static final TYPE_NIGHTLY:String = "Nightly";
	public static final TYPE_PRE_ALPHA:String = "Pre-Alpha";
	public static final TYPE_RELEASE_CANDIDATE:String = "Release Candidate";
	public static final TYPE_STABLE:String = "Stable";

    @:bind
	public var displayVersion:String;
    @:bind
	public var downloadURL:String;
    @:bind
	public var isReDownloadAvailable:Bool = false;
    @:bind
	public var sizeInMb:Int;
    @:bind
	public var title:String;
    @:bind
	public var version:String;

	public function new() {}
}