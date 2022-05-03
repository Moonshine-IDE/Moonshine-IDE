// Generated from com\moonshine\basicgrammar\TibboBasicParser.g4 by ANTLR 4.7.1
package com.moonshine.basicgrammar;
import org.antlr.v4.runtime.tree.ParseTreeListener;

/**
 * This interface defines a complete listener for a parse tree produced by
 * {@link TibboBasicParser}.
 */
public interface TibboBasicParserListener extends ParseTreeListener {
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#startRule}.
	 * @param ctx the parse tree
	 */
	void enterStartRule(TibboBasicParser.StartRuleContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#startRule}.
	 * @param ctx the parse tree
	 */
	void exitStartRule(TibboBasicParser.StartRuleContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#topLevelDeclaration}.
	 * @param ctx the parse tree
	 */
	void enterTopLevelDeclaration(TibboBasicParser.TopLevelDeclarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#topLevelDeclaration}.
	 * @param ctx the parse tree
	 */
	void exitTopLevelDeclaration(TibboBasicParser.TopLevelDeclarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#includeStmt}.
	 * @param ctx the parse tree
	 */
	void enterIncludeStmt(TibboBasicParser.IncludeStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#includeStmt}.
	 * @param ctx the parse tree
	 */
	void exitIncludeStmt(TibboBasicParser.IncludeStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#includeppStmt}.
	 * @param ctx the parse tree
	 */
	void enterIncludeppStmt(TibboBasicParser.IncludeppStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#includeppStmt}.
	 * @param ctx the parse tree
	 */
	void exitIncludeppStmt(TibboBasicParser.IncludeppStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#block}.
	 * @param ctx the parse tree
	 */
	void enterBlock(TibboBasicParser.BlockContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#block}.
	 * @param ctx the parse tree
	 */
	void exitBlock(TibboBasicParser.BlockContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#statement}.
	 * @param ctx the parse tree
	 */
	void enterStatement(TibboBasicParser.StatementContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#statement}.
	 * @param ctx the parse tree
	 */
	void exitStatement(TibboBasicParser.StatementContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#constStmt}.
	 * @param ctx the parse tree
	 */
	void enterConstStmt(TibboBasicParser.ConstStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#constStmt}.
	 * @param ctx the parse tree
	 */
	void exitConstStmt(TibboBasicParser.ConstStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#constSubStmt}.
	 * @param ctx the parse tree
	 */
	void enterConstSubStmt(TibboBasicParser.ConstSubStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#constSubStmt}.
	 * @param ctx the parse tree
	 */
	void exitConstSubStmt(TibboBasicParser.ConstSubStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#declareVariableStmt}.
	 * @param ctx the parse tree
	 */
	void enterDeclareVariableStmt(TibboBasicParser.DeclareVariableStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#declareVariableStmt}.
	 * @param ctx the parse tree
	 */
	void exitDeclareVariableStmt(TibboBasicParser.DeclareVariableStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#declareSubStmt}.
	 * @param ctx the parse tree
	 */
	void enterDeclareSubStmt(TibboBasicParser.DeclareSubStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#declareSubStmt}.
	 * @param ctx the parse tree
	 */
	void exitDeclareSubStmt(TibboBasicParser.DeclareSubStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#declareFuncStmt}.
	 * @param ctx the parse tree
	 */
	void enterDeclareFuncStmt(TibboBasicParser.DeclareFuncStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#declareFuncStmt}.
	 * @param ctx the parse tree
	 */
	void exitDeclareFuncStmt(TibboBasicParser.DeclareFuncStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#doLoopStmt}.
	 * @param ctx the parse tree
	 */
	void enterDoLoopStmt(TibboBasicParser.DoLoopStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#doLoopStmt}.
	 * @param ctx the parse tree
	 */
	void exitDoLoopStmt(TibboBasicParser.DoLoopStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#enumerationStmt}.
	 * @param ctx the parse tree
	 */
	void enterEnumerationStmt(TibboBasicParser.EnumerationStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#enumerationStmt}.
	 * @param ctx the parse tree
	 */
	void exitEnumerationStmt(TibboBasicParser.EnumerationStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#enumerationStmt_Constant}.
	 * @param ctx the parse tree
	 */
	void enterEnumerationStmt_Constant(TibboBasicParser.EnumerationStmt_ConstantContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#enumerationStmt_Constant}.
	 * @param ctx the parse tree
	 */
	void exitEnumerationStmt_Constant(TibboBasicParser.EnumerationStmt_ConstantContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#exitStmt}.
	 * @param ctx the parse tree
	 */
	void enterExitStmt(TibboBasicParser.ExitStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#exitStmt}.
	 * @param ctx the parse tree
	 */
	void exitExitStmt(TibboBasicParser.ExitStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#forNextStmt}.
	 * @param ctx the parse tree
	 */
	void enterForNextStmt(TibboBasicParser.ForNextStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#forNextStmt}.
	 * @param ctx the parse tree
	 */
	void exitForNextStmt(TibboBasicParser.ForNextStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#functionStmt}.
	 * @param ctx the parse tree
	 */
	void enterFunctionStmt(TibboBasicParser.FunctionStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#functionStmt}.
	 * @param ctx the parse tree
	 */
	void exitFunctionStmt(TibboBasicParser.FunctionStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#jumpStmt}.
	 * @param ctx the parse tree
	 */
	void enterJumpStmt(TibboBasicParser.JumpStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#jumpStmt}.
	 * @param ctx the parse tree
	 */
	void exitJumpStmt(TibboBasicParser.JumpStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#goToStmt}.
	 * @param ctx the parse tree
	 */
	void enterGoToStmt(TibboBasicParser.GoToStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#goToStmt}.
	 * @param ctx the parse tree
	 */
	void exitGoToStmt(TibboBasicParser.GoToStmtContext ctx);
	/**
	 * Enter a parse tree produced by the {@code inlineIfThenElse}
	 * labeled alternative in {@link TibboBasicParser#ifThenElseStmt}.
	 * @param ctx the parse tree
	 */
	void enterInlineIfThenElse(TibboBasicParser.InlineIfThenElseContext ctx);
	/**
	 * Exit a parse tree produced by the {@code inlineIfThenElse}
	 * labeled alternative in {@link TibboBasicParser#ifThenElseStmt}.
	 * @param ctx the parse tree
	 */
	void exitInlineIfThenElse(TibboBasicParser.InlineIfThenElseContext ctx);
	/**
	 * Enter a parse tree produced by the {@code blockIfThenElse}
	 * labeled alternative in {@link TibboBasicParser#ifThenElseStmt}.
	 * @param ctx the parse tree
	 */
	void enterBlockIfThenElse(TibboBasicParser.BlockIfThenElseContext ctx);
	/**
	 * Exit a parse tree produced by the {@code blockIfThenElse}
	 * labeled alternative in {@link TibboBasicParser#ifThenElseStmt}.
	 * @param ctx the parse tree
	 */
	void exitBlockIfThenElse(TibboBasicParser.BlockIfThenElseContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#ifConditionStmt}.
	 * @param ctx the parse tree
	 */
	void enterIfConditionStmt(TibboBasicParser.IfConditionStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#ifConditionStmt}.
	 * @param ctx the parse tree
	 */
	void exitIfConditionStmt(TibboBasicParser.IfConditionStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#propertyDefineStmt}.
	 * @param ctx the parse tree
	 */
	void enterPropertyDefineStmt(TibboBasicParser.PropertyDefineStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#propertyDefineStmt}.
	 * @param ctx the parse tree
	 */
	void exitPropertyDefineStmt(TibboBasicParser.PropertyDefineStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#propertyDefineStmt_InStmt}.
	 * @param ctx the parse tree
	 */
	void enterPropertyDefineStmt_InStmt(TibboBasicParser.PropertyDefineStmt_InStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#propertyDefineStmt_InStmt}.
	 * @param ctx the parse tree
	 */
	void exitPropertyDefineStmt_InStmt(TibboBasicParser.PropertyDefineStmt_InStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#propertyGetStmt}.
	 * @param ctx the parse tree
	 */
	void enterPropertyGetStmt(TibboBasicParser.PropertyGetStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#propertyGetStmt}.
	 * @param ctx the parse tree
	 */
	void exitPropertyGetStmt(TibboBasicParser.PropertyGetStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#propertySetStmt}.
	 * @param ctx the parse tree
	 */
	void enterPropertySetStmt(TibboBasicParser.PropertySetStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#propertySetStmt}.
	 * @param ctx the parse tree
	 */
	void exitPropertySetStmt(TibboBasicParser.PropertySetStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#eventDeclaration}.
	 * @param ctx the parse tree
	 */
	void enterEventDeclaration(TibboBasicParser.EventDeclarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#eventDeclaration}.
	 * @param ctx the parse tree
	 */
	void exitEventDeclaration(TibboBasicParser.EventDeclarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#syscallDeclaration}.
	 * @param ctx the parse tree
	 */
	void enterSyscallDeclaration(TibboBasicParser.SyscallDeclarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#syscallDeclaration}.
	 * @param ctx the parse tree
	 */
	void exitSyscallDeclaration(TibboBasicParser.SyscallDeclarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#syscallDeclarationInner}.
	 * @param ctx the parse tree
	 */
	void enterSyscallDeclarationInner(TibboBasicParser.SyscallDeclarationInnerContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#syscallDeclarationInner}.
	 * @param ctx the parse tree
	 */
	void exitSyscallDeclarationInner(TibboBasicParser.SyscallDeclarationInnerContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#syscallInternalDeclarationInner}.
	 * @param ctx the parse tree
	 */
	void enterSyscallInternalDeclarationInner(TibboBasicParser.SyscallInternalDeclarationInnerContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#syscallInternalDeclarationInner}.
	 * @param ctx the parse tree
	 */
	void exitSyscallInternalDeclarationInner(TibboBasicParser.SyscallInternalDeclarationInnerContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#syscallInternalParamList}.
	 * @param ctx the parse tree
	 */
	void enterSyscallInternalParamList(TibboBasicParser.SyscallInternalParamListContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#syscallInternalParamList}.
	 * @param ctx the parse tree
	 */
	void exitSyscallInternalParamList(TibboBasicParser.SyscallInternalParamListContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#paramInternal}.
	 * @param ctx the parse tree
	 */
	void enterParamInternal(TibboBasicParser.ParamInternalContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#paramInternal}.
	 * @param ctx the parse tree
	 */
	void exitParamInternal(TibboBasicParser.ParamInternalContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#selectCaseStmt}.
	 * @param ctx the parse tree
	 */
	void enterSelectCaseStmt(TibboBasicParser.SelectCaseStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#selectCaseStmt}.
	 * @param ctx the parse tree
	 */
	void exitSelectCaseStmt(TibboBasicParser.SelectCaseStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#sC_Case}.
	 * @param ctx the parse tree
	 */
	void enterSC_Case(TibboBasicParser.SC_CaseContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#sC_Case}.
	 * @param ctx the parse tree
	 */
	void exitSC_Case(TibboBasicParser.SC_CaseContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#sC_Default}.
	 * @param ctx the parse tree
	 */
	void enterSC_Default(TibboBasicParser.SC_DefaultContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#sC_Default}.
	 * @param ctx the parse tree
	 */
	void exitSC_Default(TibboBasicParser.SC_DefaultContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#sC_Cond}.
	 * @param ctx the parse tree
	 */
	void enterSC_Cond(TibboBasicParser.SC_CondContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#sC_Cond}.
	 * @param ctx the parse tree
	 */
	void exitSC_Cond(TibboBasicParser.SC_CondContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#subStmt}.
	 * @param ctx the parse tree
	 */
	void enterSubStmt(TibboBasicParser.SubStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#subStmt}.
	 * @param ctx the parse tree
	 */
	void exitSubStmt(TibboBasicParser.SubStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#typeStmt}.
	 * @param ctx the parse tree
	 */
	void enterTypeStmt(TibboBasicParser.TypeStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#typeStmt}.
	 * @param ctx the parse tree
	 */
	void exitTypeStmt(TibboBasicParser.TypeStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#typeStmtElement}.
	 * @param ctx the parse tree
	 */
	void enterTypeStmtElement(TibboBasicParser.TypeStmtElementContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#typeStmtElement}.
	 * @param ctx the parse tree
	 */
	void exitTypeStmtElement(TibboBasicParser.TypeStmtElementContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#expression}.
	 * @param ctx the parse tree
	 */
	void enterExpression(TibboBasicParser.ExpressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#expression}.
	 * @param ctx the parse tree
	 */
	void exitExpression(TibboBasicParser.ExpressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#unaryExpression}.
	 * @param ctx the parse tree
	 */
	void enterUnaryExpression(TibboBasicParser.UnaryExpressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#unaryExpression}.
	 * @param ctx the parse tree
	 */
	void exitUnaryExpression(TibboBasicParser.UnaryExpressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#unaryOperator}.
	 * @param ctx the parse tree
	 */
	void enterUnaryOperator(TibboBasicParser.UnaryOperatorContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#unaryOperator}.
	 * @param ctx the parse tree
	 */
	void exitUnaryOperator(TibboBasicParser.UnaryOperatorContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#postfixExpression}.
	 * @param ctx the parse tree
	 */
	void enterPostfixExpression(TibboBasicParser.PostfixExpressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#postfixExpression}.
	 * @param ctx the parse tree
	 */
	void exitPostfixExpression(TibboBasicParser.PostfixExpressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#postfix}.
	 * @param ctx the parse tree
	 */
	void enterPostfix(TibboBasicParser.PostfixContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#postfix}.
	 * @param ctx the parse tree
	 */
	void exitPostfix(TibboBasicParser.PostfixContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#primaryExpression}.
	 * @param ctx the parse tree
	 */
	void enterPrimaryExpression(TibboBasicParser.PrimaryExpressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#primaryExpression}.
	 * @param ctx the parse tree
	 */
	void exitPrimaryExpression(TibboBasicParser.PrimaryExpressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#variableStmt}.
	 * @param ctx the parse tree
	 */
	void enterVariableStmt(TibboBasicParser.VariableStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#variableStmt}.
	 * @param ctx the parse tree
	 */
	void exitVariableStmt(TibboBasicParser.VariableStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#variableListStmt}.
	 * @param ctx the parse tree
	 */
	void enterVariableListStmt(TibboBasicParser.VariableListStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#variableListStmt}.
	 * @param ctx the parse tree
	 */
	void exitVariableListStmt(TibboBasicParser.VariableListStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#variableListItem}.
	 * @param ctx the parse tree
	 */
	void enterVariableListItem(TibboBasicParser.VariableListItemContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#variableListItem}.
	 * @param ctx the parse tree
	 */
	void exitVariableListItem(TibboBasicParser.VariableListItemContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#whileWendStmt}.
	 * @param ctx the parse tree
	 */
	void enterWhileWendStmt(TibboBasicParser.WhileWendStmtContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#whileWendStmt}.
	 * @param ctx the parse tree
	 */
	void exitWhileWendStmt(TibboBasicParser.WhileWendStmtContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#objectDeclaration}.
	 * @param ctx the parse tree
	 */
	void enterObjectDeclaration(TibboBasicParser.ObjectDeclarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#objectDeclaration}.
	 * @param ctx the parse tree
	 */
	void exitObjectDeclaration(TibboBasicParser.ObjectDeclarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#argList}.
	 * @param ctx the parse tree
	 */
	void enterArgList(TibboBasicParser.ArgListContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#argList}.
	 * @param ctx the parse tree
	 */
	void exitArgList(TibboBasicParser.ArgListContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#arg}.
	 * @param ctx the parse tree
	 */
	void enterArg(TibboBasicParser.ArgContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#arg}.
	 * @param ctx the parse tree
	 */
	void exitArg(TibboBasicParser.ArgContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#paramList}.
	 * @param ctx the parse tree
	 */
	void enterParamList(TibboBasicParser.ParamListContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#paramList}.
	 * @param ctx the parse tree
	 */
	void exitParamList(TibboBasicParser.ParamListContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#param}.
	 * @param ctx the parse tree
	 */
	void enterParam(TibboBasicParser.ParamContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#param}.
	 * @param ctx the parse tree
	 */
	void exitParam(TibboBasicParser.ParamContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#asTypeClause}.
	 * @param ctx the parse tree
	 */
	void enterAsTypeClause(TibboBasicParser.AsTypeClauseContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#asTypeClause}.
	 * @param ctx the parse tree
	 */
	void exitAsTypeClause(TibboBasicParser.AsTypeClauseContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#baseType}.
	 * @param ctx the parse tree
	 */
	void enterBaseType(TibboBasicParser.BaseTypeContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#baseType}.
	 * @param ctx the parse tree
	 */
	void exitBaseType(TibboBasicParser.BaseTypeContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#complexType}.
	 * @param ctx the parse tree
	 */
	void enterComplexType(TibboBasicParser.ComplexTypeContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#complexType}.
	 * @param ctx the parse tree
	 */
	void exitComplexType(TibboBasicParser.ComplexTypeContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#fieldLength}.
	 * @param ctx the parse tree
	 */
	void enterFieldLength(TibboBasicParser.FieldLengthContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#fieldLength}.
	 * @param ctx the parse tree
	 */
	void exitFieldLength(TibboBasicParser.FieldLengthContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#lineLabel}.
	 * @param ctx the parse tree
	 */
	void enterLineLabel(TibboBasicParser.LineLabelContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#lineLabel}.
	 * @param ctx the parse tree
	 */
	void exitLineLabel(TibboBasicParser.LineLabelContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#literal}.
	 * @param ctx the parse tree
	 */
	void enterLiteral(TibboBasicParser.LiteralContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#literal}.
	 * @param ctx the parse tree
	 */
	void exitLiteral(TibboBasicParser.LiteralContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#arrayLiteral}.
	 * @param ctx the parse tree
	 */
	void enterArrayLiteral(TibboBasicParser.ArrayLiteralContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#arrayLiteral}.
	 * @param ctx the parse tree
	 */
	void exitArrayLiteral(TibboBasicParser.ArrayLiteralContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#type}.
	 * @param ctx the parse tree
	 */
	void enterType(TibboBasicParser.TypeContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#type}.
	 * @param ctx the parse tree
	 */
	void exitType(TibboBasicParser.TypeContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicParser#visibility}.
	 * @param ctx the parse tree
	 */
	void enterVisibility(TibboBasicParser.VisibilityContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicParser#visibility}.
	 * @param ctx the parse tree
	 */
	void exitVisibility(TibboBasicParser.VisibilityContext ctx);
}