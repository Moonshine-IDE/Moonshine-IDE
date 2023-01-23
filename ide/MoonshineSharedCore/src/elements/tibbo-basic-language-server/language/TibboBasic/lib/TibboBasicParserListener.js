// Generated from /Users/jimmyhu/Projects/tibbo-basic/server/language/TibboBasic/TibboBasicParser.g4 by ANTLR 4.8
// jshint ignore: start
var antlr4 = require('antlr4/index');

// This class defines a complete listener for a parse tree produced by TibboBasicParser.
function TibboBasicParserListener() {
	antlr4.tree.ParseTreeListener.call(this);
	return this;
}

TibboBasicParserListener.prototype = Object.create(antlr4.tree.ParseTreeListener.prototype);
TibboBasicParserListener.prototype.constructor = TibboBasicParserListener;

// Enter a parse tree produced by TibboBasicParser#startRule.
TibboBasicParserListener.prototype.enterStartRule = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#startRule.
TibboBasicParserListener.prototype.exitStartRule = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#topLevelDeclaration.
TibboBasicParserListener.prototype.enterTopLevelDeclaration = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#topLevelDeclaration.
TibboBasicParserListener.prototype.exitTopLevelDeclaration = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#includeStmt.
TibboBasicParserListener.prototype.enterIncludeStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#includeStmt.
TibboBasicParserListener.prototype.exitIncludeStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#includeppStmt.
TibboBasicParserListener.prototype.enterIncludeppStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#includeppStmt.
TibboBasicParserListener.prototype.exitIncludeppStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#block.
TibboBasicParserListener.prototype.enterBlock = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#block.
TibboBasicParserListener.prototype.exitBlock = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#statement.
TibboBasicParserListener.prototype.enterStatement = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#statement.
TibboBasicParserListener.prototype.exitStatement = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#constStmt.
TibboBasicParserListener.prototype.enterConstStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#constStmt.
TibboBasicParserListener.prototype.exitConstStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#constSubStmt.
TibboBasicParserListener.prototype.enterConstSubStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#constSubStmt.
TibboBasicParserListener.prototype.exitConstSubStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#declareVariableStmt.
TibboBasicParserListener.prototype.enterDeclareVariableStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#declareVariableStmt.
TibboBasicParserListener.prototype.exitDeclareVariableStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#declareSubStmt.
TibboBasicParserListener.prototype.enterDeclareSubStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#declareSubStmt.
TibboBasicParserListener.prototype.exitDeclareSubStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#declareFuncStmt.
TibboBasicParserListener.prototype.enterDeclareFuncStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#declareFuncStmt.
TibboBasicParserListener.prototype.exitDeclareFuncStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#doLoopStmt.
TibboBasicParserListener.prototype.enterDoLoopStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#doLoopStmt.
TibboBasicParserListener.prototype.exitDoLoopStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#enumerationStmt.
TibboBasicParserListener.prototype.enterEnumerationStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#enumerationStmt.
TibboBasicParserListener.prototype.exitEnumerationStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#enumerationStmt_Constant.
TibboBasicParserListener.prototype.enterEnumerationStmt_Constant = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#enumerationStmt_Constant.
TibboBasicParserListener.prototype.exitEnumerationStmt_Constant = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#exitStmt.
TibboBasicParserListener.prototype.enterExitStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#exitStmt.
TibboBasicParserListener.prototype.exitExitStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#forNextStmt.
TibboBasicParserListener.prototype.enterForNextStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#forNextStmt.
TibboBasicParserListener.prototype.exitForNextStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#functionStmt.
TibboBasicParserListener.prototype.enterFunctionStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#functionStmt.
TibboBasicParserListener.prototype.exitFunctionStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#jumpStmt.
TibboBasicParserListener.prototype.enterJumpStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#jumpStmt.
TibboBasicParserListener.prototype.exitJumpStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#goToStmt.
TibboBasicParserListener.prototype.enterGoToStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#goToStmt.
TibboBasicParserListener.prototype.exitGoToStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#inlineIfThenElse.
TibboBasicParserListener.prototype.enterInlineIfThenElse = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#inlineIfThenElse.
TibboBasicParserListener.prototype.exitInlineIfThenElse = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#blockIfThenElse.
TibboBasicParserListener.prototype.enterBlockIfThenElse = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#blockIfThenElse.
TibboBasicParserListener.prototype.exitBlockIfThenElse = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#ifConditionStmt.
TibboBasicParserListener.prototype.enterIfConditionStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#ifConditionStmt.
TibboBasicParserListener.prototype.exitIfConditionStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#propertyDefineStmt.
TibboBasicParserListener.prototype.enterPropertyDefineStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#propertyDefineStmt.
TibboBasicParserListener.prototype.exitPropertyDefineStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#propertyDefineStmt_InStmt.
TibboBasicParserListener.prototype.enterPropertyDefineStmt_InStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#propertyDefineStmt_InStmt.
TibboBasicParserListener.prototype.exitPropertyDefineStmt_InStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#propertyGetStmt.
TibboBasicParserListener.prototype.enterPropertyGetStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#propertyGetStmt.
TibboBasicParserListener.prototype.exitPropertyGetStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#propertySetStmt.
TibboBasicParserListener.prototype.enterPropertySetStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#propertySetStmt.
TibboBasicParserListener.prototype.exitPropertySetStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#eventDeclaration.
TibboBasicParserListener.prototype.enterEventDeclaration = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#eventDeclaration.
TibboBasicParserListener.prototype.exitEventDeclaration = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#syscallDeclaration.
TibboBasicParserListener.prototype.enterSyscallDeclaration = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#syscallDeclaration.
TibboBasicParserListener.prototype.exitSyscallDeclaration = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#syscallDeclarationInner.
TibboBasicParserListener.prototype.enterSyscallDeclarationInner = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#syscallDeclarationInner.
TibboBasicParserListener.prototype.exitSyscallDeclarationInner = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#syscallInternalDeclarationInner.
TibboBasicParserListener.prototype.enterSyscallInternalDeclarationInner = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#syscallInternalDeclarationInner.
TibboBasicParserListener.prototype.exitSyscallInternalDeclarationInner = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#syscallInternalParamList.
TibboBasicParserListener.prototype.enterSyscallInternalParamList = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#syscallInternalParamList.
TibboBasicParserListener.prototype.exitSyscallInternalParamList = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#paramInternal.
TibboBasicParserListener.prototype.enterParamInternal = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#paramInternal.
TibboBasicParserListener.prototype.exitParamInternal = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#selectCaseStmt.
TibboBasicParserListener.prototype.enterSelectCaseStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#selectCaseStmt.
TibboBasicParserListener.prototype.exitSelectCaseStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#sC_Case.
TibboBasicParserListener.prototype.enterSC_Case = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#sC_Case.
TibboBasicParserListener.prototype.exitSC_Case = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#sC_Default.
TibboBasicParserListener.prototype.enterSC_Default = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#sC_Default.
TibboBasicParserListener.prototype.exitSC_Default = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#sC_Cond.
TibboBasicParserListener.prototype.enterSC_Cond = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#sC_Cond.
TibboBasicParserListener.prototype.exitSC_Cond = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#subStmt.
TibboBasicParserListener.prototype.enterSubStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#subStmt.
TibboBasicParserListener.prototype.exitSubStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#typeStmt.
TibboBasicParserListener.prototype.enterTypeStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#typeStmt.
TibboBasicParserListener.prototype.exitTypeStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#typeStmtElement.
TibboBasicParserListener.prototype.enterTypeStmtElement = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#typeStmtElement.
TibboBasicParserListener.prototype.exitTypeStmtElement = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#expression.
TibboBasicParserListener.prototype.enterExpression = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#expression.
TibboBasicParserListener.prototype.exitExpression = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#unaryExpression.
TibboBasicParserListener.prototype.enterUnaryExpression = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#unaryExpression.
TibboBasicParserListener.prototype.exitUnaryExpression = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#unaryOperator.
TibboBasicParserListener.prototype.enterUnaryOperator = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#unaryOperator.
TibboBasicParserListener.prototype.exitUnaryOperator = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#postfixExpression.
TibboBasicParserListener.prototype.enterPostfixExpression = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#postfixExpression.
TibboBasicParserListener.prototype.exitPostfixExpression = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#postfix.
TibboBasicParserListener.prototype.enterPostfix = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#postfix.
TibboBasicParserListener.prototype.exitPostfix = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#primaryExpression.
TibboBasicParserListener.prototype.enterPrimaryExpression = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#primaryExpression.
TibboBasicParserListener.prototype.exitPrimaryExpression = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#variableStmt.
TibboBasicParserListener.prototype.enterVariableStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#variableStmt.
TibboBasicParserListener.prototype.exitVariableStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#variableListStmt.
TibboBasicParserListener.prototype.enterVariableListStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#variableListStmt.
TibboBasicParserListener.prototype.exitVariableListStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#variableListItem.
TibboBasicParserListener.prototype.enterVariableListItem = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#variableListItem.
TibboBasicParserListener.prototype.exitVariableListItem = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#whileWendStmt.
TibboBasicParserListener.prototype.enterWhileWendStmt = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#whileWendStmt.
TibboBasicParserListener.prototype.exitWhileWendStmt = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#objectDeclaration.
TibboBasicParserListener.prototype.enterObjectDeclaration = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#objectDeclaration.
TibboBasicParserListener.prototype.exitObjectDeclaration = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#argList.
TibboBasicParserListener.prototype.enterArgList = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#argList.
TibboBasicParserListener.prototype.exitArgList = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#arg.
TibboBasicParserListener.prototype.enterArg = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#arg.
TibboBasicParserListener.prototype.exitArg = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#paramList.
TibboBasicParserListener.prototype.enterParamList = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#paramList.
TibboBasicParserListener.prototype.exitParamList = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#param.
TibboBasicParserListener.prototype.enterParam = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#param.
TibboBasicParserListener.prototype.exitParam = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#asTypeClause.
TibboBasicParserListener.prototype.enterAsTypeClause = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#asTypeClause.
TibboBasicParserListener.prototype.exitAsTypeClause = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#baseType.
TibboBasicParserListener.prototype.enterBaseType = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#baseType.
TibboBasicParserListener.prototype.exitBaseType = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#complexType.
TibboBasicParserListener.prototype.enterComplexType = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#complexType.
TibboBasicParserListener.prototype.exitComplexType = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#fieldLength.
TibboBasicParserListener.prototype.enterFieldLength = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#fieldLength.
TibboBasicParserListener.prototype.exitFieldLength = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#lineLabel.
TibboBasicParserListener.prototype.enterLineLabel = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#lineLabel.
TibboBasicParserListener.prototype.exitLineLabel = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#literal.
TibboBasicParserListener.prototype.enterLiteral = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#literal.
TibboBasicParserListener.prototype.exitLiteral = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#arrayLiteral.
TibboBasicParserListener.prototype.enterArrayLiteral = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#arrayLiteral.
TibboBasicParserListener.prototype.exitArrayLiteral = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#type.
TibboBasicParserListener.prototype.enterType = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#type.
TibboBasicParserListener.prototype.exitType = function(ctx) {
};


// Enter a parse tree produced by TibboBasicParser#visibility.
TibboBasicParserListener.prototype.enterVisibility = function(ctx) {
};

// Exit a parse tree produced by TibboBasicParser#visibility.
TibboBasicParserListener.prototype.exitVisibility = function(ctx) {
};



exports.TibboBasicParserListener = TibboBasicParserListener;