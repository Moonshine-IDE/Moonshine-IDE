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
package actionScripts.utils
{
	public class MethodDescriptor
	{
		public var origin:*;
		public var method:String;
		public var parameters:Array;
		
		public function MethodDescriptor(origin:*, method:String, ...param)
		{
			super();
			
			this.origin = origin;
			this.method = method;
			this.parameters = param;
		}
		
		public function callMethod():void
		{
			origin[method].apply(null, parameters);
		}
		
		public function callConstructorWithParameters():Object
		{
			try
			{
				var paramLength:int = parameters ? parameters.length : 0;
				switch (paramLength) {
					case 0:return new origin();
					case 1:return new origin(parameters[0]);
					case 2:return new origin(parameters[0], parameters[1]);
					case 3:return new origin(parameters[0], parameters[1], parameters[2]);
					case 4:return new origin(parameters[0], parameters[1], parameters[2], parameters[3]);
					case 5:return new origin(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4]);
					case 6:return new origin(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5]);
					case 7:return new origin(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6]);
					case 8:return new origin(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7]);
					case 9:return new origin(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7], parameters[8]);
					case 10:return new origin(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], parameters[6], parameters[7], parameters[8], parameters[9]);
					default: throw new Error("Too many parameters to generate new class.");
				}
			}
			catch (e:Error)
			{
				throw new Error("Throws error while creating class with unknown Constructors.");
			}
			
			return null;
		}
	}
}