import haxe.DynamicAccess;

typedef Arguments = {
	cwd:String,
	classPaths:Array<String>,
	?hl:String,
	?env:DynamicAccess<String>,
	?program:String,
	?args:Array<String>,
	?argsFile:String,
	?port:Int,
	?hotReload:Bool,
	?profileSamples:Int
}
