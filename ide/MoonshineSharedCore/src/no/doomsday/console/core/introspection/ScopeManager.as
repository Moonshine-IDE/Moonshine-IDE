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
package no.doomsday.console.core.introspection 
{
	import flash.display.DisplayObject;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import no.doomsday.console.core.DConsole;
	import no.doomsday.console.core.messages.MessageTypes;
	import no.doomsday.console.core.text.autocomplete.AutocompleteManager;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ScopeManager
	{
		public static const SEARCH_METHODS:int = 0;
		public static const SEARCH_ACCESSORS:int = 1;
		public static const SEARCH_CHILDREN:int = 2;
		
		private var _currentScope:IntrospectionScope = createScope( { } );
		private var _previousScope:IntrospectionScope;
		private var console:DConsole;
		private var autoCompleteManager:AutocompleteManager;
		public function ScopeManager(console:DConsole,autoCompleteManager:AutocompleteManager) 
		{
			this.console = console;
			this.autoCompleteManager = autoCompleteManager;
		}
		public function createScope(o:*):IntrospectionScope {
			if (!o) throw new ArgumentError("Invalid scope");
			var c:IntrospectionScope = new IntrospectionScope();
			c.autoCompleteDict = InspectionUtils.getAutoCompleteDictionary(o);
			c.children = TreeUtils.getChildren(o);
			c.accessors = InspectionUtils.getAccessors(o);
			c.methods = InspectionUtils.getMethods(o);
			c.variables = InspectionUtils.getVariables(o);
			c.obj = o;
			_currentScope = c;
			return _currentScope;
		}
		public function setScope(o:*,force:Boolean = false):void {
			if (!force && currentScope.obj === o) {
				printScope();
				return;
			}
			try {
				
				createScope(o);
				autoCompleteManager.scopeDict = currentScope.autoCompleteDict;
			}catch (e:Error) {
				throw e;
			}
			printScope();
			printDownPath();
		}
		
		public function getScopeByName(str:String):*{
			try{
				if (currentScope.obj[str]) return currentScope.obj[str];
				else throw new Error();
			}catch(e:Error){
				try {
					return(currentScope.obj.getChildByName(str));
				}catch (e:Error) {
				}
			}
			throw new Error("No such scope");
		}
		
		public function get currentScope():IntrospectionScope { return _currentScope; }
		
		public function up():void {
			if (!_currentScope) return;
			if (_currentScope.obj is DisplayObject) {
				setScope(_currentScope.obj.parent);
			}
		}		
		public function setScopeByName(str:String):void {
			try {
				setScope(getScopeByName(str));
			}catch (e:Error) {
				throw e;
			}
		}		
		public function printMethods():void {
			var m:Vector.<MethodDesc> = currentScope.methods;
			console.print("	methods:");
			var i:int;
			for (i = 0; i < m.length; i++) 
			{
				var md:MethodDesc = m[i];
				console.print("		" + md.name + " : " + md.returnType);
			}
		}
		public function printVariables():void {
			var a:Vector.<VariableDesc> = currentScope.variables;
			var cv:*;
			console.print("	variables: "+a.length);
			var i:int
			for (i = 0; i < a.length; i++) 
			{
				var vd:VariableDesc = a[i];
				console.print("		" + vd.name + ": " + vd.type);
				try{
					cv = currentScope.obj[vd.name];
					console.print("			value: " + cv.toString());
				}catch (e:Error) {
					
				}
			}
			var b:Vector.<AccessorDesc> = currentScope.accessors;
			console.print("	accessors: "+b.length);
			for (i = 0; i < b.length; i++) 
			{
				var ad:AccessorDesc = b[i];
				console.print("		" + ad.name + ": " + ad.type);
				try{
					cv = currentScope.obj[ad.name];
					console.print("			value: " + cv.toString());
				}catch (e:Error) {
					
				}
			}
		}
		public function printChildren():void {
			var c:Vector.<ChildScopeDesc> = currentScope.children;
			if (c.length < 1) return;
			console.print("	children: "+c.length);
			for (var i:int = 0; i < c.length; i++) 
			{
				var cc:ChildScopeDesc = c[i];
				console.print("		" + cc.name + " : " + cc.type);
			}
		}
		
		public function printDownPath():void {
			printChildren();
			printComplexObjects();
		}
		
		public function printComplexObjects():void
		{
			var a:Vector.<VariableDesc> = currentScope.variables;
			var cv:*;
			if (a.length < 1) return;
			var i:int
			var out:Array = [];
			for (i = 0; i < a.length; i++) 
			{
				var vd:VariableDesc = a[i];
				switch(vd.type) {
					case "Number":
					case "Boolean":
					case "String":
					case "int":
					case "uint":
					case "Array":
					continue;
				}
				out.push("		" + vd.name + ": " + vd.type);
			}
			console.print("	complex types: "+out.length);
			if (out.length > 0) {
				for (i = 0; i < out.length; i++) 
				{
					console.print(out[i]);
				}
			}
		}
		
		public function printScope():void {
			if (currentScope.obj is ByteArray) {
				console.print("scope : [ByteArray]");
			}else{
				console.print("scope : " + currentScope.obj.toString());
			}
		}
		public function setAccessorOnObject(accessorName:String, arg:*):*
		{
			if (arg == "true") {
				arg = true;
			}else if (arg == "false") {
				arg = false;
			}
			currentScope.obj[accessorName] = arg;
			return currentScope.obj[accessorName];
		}
		public function getAccessorOnObject(accessorName:String):String{
			return currentScope.obj[accessorName].toString();
		}
		public function selectBaseScope():void {
			setScope(console.parent);
		}
		public function callMethodOnScope(...args:Array):* {
			var cmd:String = args.shift();
			var func:Function = currentScope.obj[cmd];
			return func.apply(currentScope.obj, args);
		}
		public function updateScope():void
		{
			setScope(currentScope.obj, true);
		}
		
		public function doSearch(search:String,searchMode:int = SEARCH_METHODS):Vector.<String>
		{
			var result:Vector.<String> = new Vector.<String>;
			var s:String = search.toLowerCase();
			var i:int;
			switch(searchMode) {
				case SEARCH_ACCESSORS:
				for (i = currentScope.accessors.length; i--; ) 
				{
					var a:AccessorDesc= currentScope.accessors[i];
					if (a.name.toLowerCase().indexOf(s, 0) > -1) {
						result.push(a.name);
					}
				}
				for (i = currentScope.variables.length; i--; ) 
				{
					var v:VariableDesc = currentScope.variables[i];
					if (v.name.toLowerCase().indexOf(s, 0) > -1) {
						result.push(v.name);
					}
				}
				break;
				case SEARCH_METHODS:
				for (i = currentScope.methods.length; i--; ) 
				{
					var m:MethodDesc = currentScope.methods[i];
					if (m.name.toLowerCase().indexOf(s, 0) > -1) {
						result.push(m.name);
					}
				}
				break;
				case SEARCH_CHILDREN:
				for (i = currentScope.children.length; i--; ) 
				{
					var c:ChildScopeDesc= currentScope.children[i];
					if (c.name.toLowerCase().indexOf(s, 0) > -1) {
						result.push(c.name);
					}
				}
				break;
			}		
			return result;
		}
		
	}

}