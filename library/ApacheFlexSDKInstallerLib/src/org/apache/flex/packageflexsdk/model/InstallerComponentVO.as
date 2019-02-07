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

package org.apache.flex.packageflexsdk.model
{
	[Bindable]
	public class InstallerComponentVO
	{
		public var label:String;
		public var message:String;
		public var required:Boolean;
		public var selected:Boolean;
		public var installed:Boolean=false;
		public var aborted:Boolean=false;
		public var answered:Boolean = false;
		public var licenseName:String;
		public var licenseURL:String;
		public var key:String;
		
		public function InstallerComponentVO(label:String,
											 message:String,
											 licenseName:String,
											 licenseURL:String,
											 key:String,
											 required:Boolean,
											 selected:Boolean=false,
											 installed:Boolean=false,
											 aborted:Boolean=false,
											 answered:Boolean=false
											)
		{
			this.label = label;
			this.message = message;
			this.key = key;
			this.required = required;
			this.selected = selected;
			this.installed = installed;
			this.aborted = aborted;
			this.answered = answered;
			this.licenseName = licenseName;
			this.licenseURL = licenseURL;
		}
	}
}