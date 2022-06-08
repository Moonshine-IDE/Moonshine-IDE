package actionScripts.valueObjects;

class AS3ClassAttributes {
	public var modifierA:String;
	public var modifierB:String;
	public var modifierC:String;
	public var extendsClassInterface:String;
	public var implementsInterface:String;
	public var imports:Array<String> = [];

	public function new() {}

	public function getModifiersB():String {
		var tempModifArr:Array<String> = [];
		if (modifierB != null)
			tempModifArr.push(modifierB);
		if (modifierC != null)
			tempModifArr.push(modifierC);

		return tempModifArr.join(" ");
	}

	public function getImports(importKeyword:String = "import"):String {
		var allImports:String = "";

		var countImports:Int = imports.length;
		for (i in 0...countImports) {
			var imp:String = imports[i];
			if (i == 0) {
				allImports += importKeyword + " " + imp + ";\n";
			} else {
				allImports += "    " + importKeyword + " " + imp + ";\n";
			}
		}

		return allImports;
	}
}