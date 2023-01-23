// Generated from /Users/jimmyhu/Projects/tibbo-basic/server/language/TibboBasic/TibboBasicParser.g4 by ANTLR 4.8
// jshint ignore: start
var antlr4 = require('antlr4/index');

// This class defines a complete generic visitor for a parse tree produced by TibboBasicParser.

function TibboBasicParserVisitor() {
	antlr4.tree.ParseTreeVisitor.call(this);
	return this;
}

TibboBasicParserVisitor.prototype = Object.create(antlr4.tree.ParseTreeVisitor.prototype);
TibboBasicParserVisitor.prototype.constructor = TibboBasicParserVisitor;

// Visit a parse tree produced by TibboBasicParser#startRule.
TibboBasicParserVisitor.prototype.visitStartRule = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#topLevelDeclaration.
TibboBasicParserVisitor.prototype.visitTopLevelDeclaration = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#includeStmt.
TibboBasicParserVisitor.prototype.visitIncludeStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#includeppStmt.
TibboBasicParserVisitor.prototype.visitIncludeppStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#block.
TibboBasicParserVisitor.prototype.visitBlock = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#statement.
TibboBasicParserVisitor.prototype.visitStatement = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#constStmt.
TibboBasicParserVisitor.prototype.visitConstStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#constSubStmt.
TibboBasicParserVisitor.prototype.visitConstSubStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#declareVariableStmt.
TibboBasicParserVisitor.prototype.visitDeclareVariableStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#declareSubStmt.
TibboBasicParserVisitor.prototype.visitDeclareSubStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#declareFuncStmt.
TibboBasicParserVisitor.prototype.visitDeclareFuncStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#doLoopStmt.
TibboBasicParserVisitor.prototype.visitDoLoopStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#enumerationStmt.
TibboBasicParserVisitor.prototype.visitEnumerationStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#enumerationStmt_Constant.
TibboBasicParserVisitor.prototype.visitEnumerationStmt_Constant = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#exitStmt.
TibboBasicParserVisitor.prototype.visitExitStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#forNextStmt.
TibboBasicParserVisitor.prototype.visitForNextStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#functionStmt.
TibboBasicParserVisitor.prototype.visitFunctionStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#jumpStmt.
TibboBasicParserVisitor.prototype.visitJumpStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#goToStmt.
TibboBasicParserVisitor.prototype.visitGoToStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#inlineIfThenElse.
TibboBasicParserVisitor.prototype.visitInlineIfThenElse = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#blockIfThenElse.
TibboBasicParserVisitor.prototype.visitBlockIfThenElse = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#ifConditionStmt.
TibboBasicParserVisitor.prototype.visitIfConditionStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#propertyDefineStmt.
TibboBasicParserVisitor.prototype.visitPropertyDefineStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#propertyDefineStmt_InStmt.
TibboBasicParserVisitor.prototype.visitPropertyDefineStmt_InStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#propertyGetStmt.
TibboBasicParserVisitor.prototype.visitPropertyGetStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#propertySetStmt.
TibboBasicParserVisitor.prototype.visitPropertySetStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#eventDeclaration.
TibboBasicParserVisitor.prototype.visitEventDeclaration = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#syscallDeclaration.
TibboBasicParserVisitor.prototype.visitSyscallDeclaration = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#syscallDeclarationInner.
TibboBasicParserVisitor.prototype.visitSyscallDeclarationInner = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#syscallInternalDeclarationInner.
TibboBasicParserVisitor.prototype.visitSyscallInternalDeclarationInner = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#syscallInternalParamList.
TibboBasicParserVisitor.prototype.visitSyscallInternalParamList = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#paramInternal.
TibboBasicParserVisitor.prototype.visitParamInternal = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#selectCaseStmt.
TibboBasicParserVisitor.prototype.visitSelectCaseStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#sC_Case.
TibboBasicParserVisitor.prototype.visitSC_Case = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#sC_Default.
TibboBasicParserVisitor.prototype.visitSC_Default = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#sC_Cond.
TibboBasicParserVisitor.prototype.visitSC_Cond = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#subStmt.
TibboBasicParserVisitor.prototype.visitSubStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#typeStmt.
TibboBasicParserVisitor.prototype.visitTypeStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#typeStmtElement.
TibboBasicParserVisitor.prototype.visitTypeStmtElement = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#expression.
TibboBasicParserVisitor.prototype.visitExpression = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#unaryExpression.
TibboBasicParserVisitor.prototype.visitUnaryExpression = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#unaryOperator.
TibboBasicParserVisitor.prototype.visitUnaryOperator = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#postfixExpression.
TibboBasicParserVisitor.prototype.visitPostfixExpression = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#postfix.
TibboBasicParserVisitor.prototype.visitPostfix = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#primaryExpression.
TibboBasicParserVisitor.prototype.visitPrimaryExpression = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#variableStmt.
TibboBasicParserVisitor.prototype.visitVariableStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#variableListStmt.
TibboBasicParserVisitor.prototype.visitVariableListStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#variableListItem.
TibboBasicParserVisitor.prototype.visitVariableListItem = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#whileWendStmt.
TibboBasicParserVisitor.prototype.visitWhileWendStmt = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#objectDeclaration.
TibboBasicParserVisitor.prototype.visitObjectDeclaration = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#argList.
TibboBasicParserVisitor.prototype.visitArgList = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#arg.
TibboBasicParserVisitor.prototype.visitArg = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#paramList.
TibboBasicParserVisitor.prototype.visitParamList = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#param.
TibboBasicParserVisitor.prototype.visitParam = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#asTypeClause.
TibboBasicParserVisitor.prototype.visitAsTypeClause = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#baseType.
TibboBasicParserVisitor.prototype.visitBaseType = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#complexType.
TibboBasicParserVisitor.prototype.visitComplexType = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#fieldLength.
TibboBasicParserVisitor.prototype.visitFieldLength = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#lineLabel.
TibboBasicParserVisitor.prototype.visitLineLabel = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#literal.
TibboBasicParserVisitor.prototype.visitLiteral = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#arrayLiteral.
TibboBasicParserVisitor.prototype.visitArrayLiteral = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#type.
TibboBasicParserVisitor.prototype.visitType = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicParser#visibility.
TibboBasicParserVisitor.prototype.visitVisibility = function(ctx) {
  return this.visitChildren(ctx);
};



exports.TibboBasicParserVisitor = TibboBasicParserVisitor;