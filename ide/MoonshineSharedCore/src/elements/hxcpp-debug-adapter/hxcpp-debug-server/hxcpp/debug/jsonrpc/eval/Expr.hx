package hxcpp.debug.jsonrpc.eval;

enum Const {
	CInt(v:Int);
	CFloat(f:Float);
	CString(s:String);
	#if !haxe3
	CInt32(v:haxe.Int32);
	#end
}

typedef ExprDef = Expr;

enum Expr {
	EConst(c:Const);
	EIdent(v:String);
	EVar(n:String, ?t:CType, ?e:Expr);
	EParent(e:Expr);
	EBlock(e:Array<Expr>);
	EField(e:Expr, f:String);
	EBinop(op:String, e1:Expr, e2:Expr);
	EUnop(op:String, prefix:Bool, e:Expr);
	ECall(e:Expr, params:Array<Expr>);
	EIf(cond:Expr, e1:Expr, ?e2:Expr);
	EWhile(cond:Expr, e:Expr);
	EFor(v:String, it:Expr, e:Expr);
	EBreak;
	EContinue;
	EFunction(args:Array<Argument>, e:Expr, ?name:String, ?ret:CType);
	EReturn(?e:Expr);
	EArray(e:Expr, index:Expr);
	EArrayDecl(e:Array<Expr>);
	ENew(cl:String, params:Array<Expr>);
	EThrow(e:Expr);
	ETry(e:Expr, v:String, t:Null<CType>, ecatch:Expr);
	EObject(fl:Array<{name:String, e:Expr}>);
	ETernary(cond:Expr, e1:Expr, e2:Expr);
	ESwitch(e:Expr, cases:Array<{values:Array<Expr>, expr:Expr}>, ?defaultExpr:Expr);
	EDoWhile(cond:Expr, e:Expr);
	EMeta(name:String, args:Array<Expr>, e:Expr);
	ECheckType(e:Expr, t:CType);
}

typedef Argument = {name:String, ?t:CType, ?opt:Bool, ?value:Expr};
typedef Metadata = Array<{name:String, params:Array<Expr>}>;

enum CType {
	CTPath(path:Array<String>, ?params:Array<CType>);
	CTFun(args:Array<CType>, ret:CType);
	CTAnon(fields:Array<{name:String, t:CType, ?meta:Metadata}>);
	CTParent(t:CType);
	CTOpt(t:CType);
	CTNamed(n:String, t:CType);
}

enum Error {
	EInvalidChar(c:Int);
	EUnexpected(s:String);
	EUnterminatedString;
	EUnterminatedComment;
	EInvalidPreprocessor(msg:String);
	EUnknownVariable(v:String);
	EInvalidIterator(v:String);
	EInvalidOp(op:String);
	EInvalidAccess(f:String);
	ECustom(msg:String);
}

enum ModuleDecl {
	DPackage(path:Array<String>);
	DImport(path:Array<String>, ?everything:Bool);
	DClass(c:ClassDecl);
	DTypedef(c:TypeDecl);
}

typedef ModuleType = {
	var name:String;
	var params:{}; // TODO : not yet parsed
	var meta:Metadata;
	var isPrivate:Bool;
}

typedef ClassDecl = {
	> ModuleType,
	var extend:Null<CType>;
	var implement:Array<CType>;
	var fields:Array<FieldDecl>;
	var isExtern:Bool;
}

typedef TypeDecl = {
	> ModuleType,
	var t:CType;
}

typedef FieldDecl = {
	var name:String;
	var meta:Metadata;
	var kind:FieldKind;
	var access:Array<FieldAccess>;
}

enum FieldAccess {
	APublic;
	APrivate;
	AInline;
	AOverride;
	AStatic;
	AMacro;
}

enum FieldKind {
	KFunction(f:FunctionDecl);
	KVar(v:VarDecl);
}

typedef FunctionDecl = {
	var args:Array<Argument>;
	var expr:Expr;
	var ret:Null<CType>;
}

typedef VarDecl = {
	var get:Null<String>;
	var set:Null<String>;
	var expr:Null<Expr>;
	var type:Null<CType>;
}
