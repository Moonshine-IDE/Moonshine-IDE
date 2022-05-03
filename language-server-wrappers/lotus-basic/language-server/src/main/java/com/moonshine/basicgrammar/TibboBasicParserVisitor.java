// Generated from com\moonshine\basicgrammar\TibboBasicParser.g4 by ANTLR 4.7.1
package com.moonshine.basicgrammar;
import org.antlr.v4.runtime.tree.ParseTreeVisitor;

/**
 * This interface defines a complete generic visitor for a parse tree produced
 * by {@link TibboBasicParser}.
 *
 * @param <T> The return type of the visit operation. Use {@link Void} for
 * operations with no return type.
 */
public interface TibboBasicParserVisitor<T> extends ParseTreeVisitor<T> {
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#startRule}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitStartRule(TibboBasicParser.StartRuleContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#topLevelDeclaration}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitTopLevelDeclaration(TibboBasicParser.TopLevelDeclarationContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#includeStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitIncludeStmt(TibboBasicParser.IncludeStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#includeppStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitIncludeppStmt(TibboBasicParser.IncludeppStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#block}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitBlock(TibboBasicParser.BlockContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#statement}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitStatement(TibboBasicParser.StatementContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#constStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitConstStmt(TibboBasicParser.ConstStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#constSubStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitConstSubStmt(TibboBasicParser.ConstSubStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#declareVariableStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitDeclareVariableStmt(TibboBasicParser.DeclareVariableStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#declareSubStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitDeclareSubStmt(TibboBasicParser.DeclareSubStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#declareFuncStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitDeclareFuncStmt(TibboBasicParser.DeclareFuncStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#doLoopStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitDoLoopStmt(TibboBasicParser.DoLoopStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#enumerationStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitEnumerationStmt(TibboBasicParser.EnumerationStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#enumerationStmt_Constant}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitEnumerationStmt_Constant(TibboBasicParser.EnumerationStmt_ConstantContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#exitStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitExitStmt(TibboBasicParser.ExitStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#forNextStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitForNextStmt(TibboBasicParser.ForNextStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#functionStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitFunctionStmt(TibboBasicParser.FunctionStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#jumpStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitJumpStmt(TibboBasicParser.JumpStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#goToStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitGoToStmt(TibboBasicParser.GoToStmtContext ctx);
	/**
	 * Visit a parse tree produced by the {@code inlineIfThenElse}
	 * labeled alternative in {@link TibboBasicParser#ifThenElseStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitInlineIfThenElse(TibboBasicParser.InlineIfThenElseContext ctx);
	/**
	 * Visit a parse tree produced by the {@code blockIfThenElse}
	 * labeled alternative in {@link TibboBasicParser#ifThenElseStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitBlockIfThenElse(TibboBasicParser.BlockIfThenElseContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#ifConditionStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitIfConditionStmt(TibboBasicParser.IfConditionStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#propertyDefineStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPropertyDefineStmt(TibboBasicParser.PropertyDefineStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#propertyDefineStmt_InStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPropertyDefineStmt_InStmt(TibboBasicParser.PropertyDefineStmt_InStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#propertyGetStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPropertyGetStmt(TibboBasicParser.PropertyGetStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#propertySetStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPropertySetStmt(TibboBasicParser.PropertySetStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#eventDeclaration}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitEventDeclaration(TibboBasicParser.EventDeclarationContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#syscallDeclaration}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitSyscallDeclaration(TibboBasicParser.SyscallDeclarationContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#syscallDeclarationInner}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitSyscallDeclarationInner(TibboBasicParser.SyscallDeclarationInnerContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#syscallInternalDeclarationInner}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitSyscallInternalDeclarationInner(TibboBasicParser.SyscallInternalDeclarationInnerContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#syscallInternalParamList}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitSyscallInternalParamList(TibboBasicParser.SyscallInternalParamListContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#paramInternal}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitParamInternal(TibboBasicParser.ParamInternalContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#selectCaseStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitSelectCaseStmt(TibboBasicParser.SelectCaseStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#sC_Case}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitSC_Case(TibboBasicParser.SC_CaseContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#sC_Default}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitSC_Default(TibboBasicParser.SC_DefaultContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#sC_Cond}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitSC_Cond(TibboBasicParser.SC_CondContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#subStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitSubStmt(TibboBasicParser.SubStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#typeStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitTypeStmt(TibboBasicParser.TypeStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#typeStmtElement}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitTypeStmtElement(TibboBasicParser.TypeStmtElementContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#expression}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitExpression(TibboBasicParser.ExpressionContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#unaryExpression}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitUnaryExpression(TibboBasicParser.UnaryExpressionContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#unaryOperator}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitUnaryOperator(TibboBasicParser.UnaryOperatorContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#postfixExpression}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPostfixExpression(TibboBasicParser.PostfixExpressionContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#postfix}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPostfix(TibboBasicParser.PostfixContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#primaryExpression}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPrimaryExpression(TibboBasicParser.PrimaryExpressionContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#variableStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitVariableStmt(TibboBasicParser.VariableStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#variableListStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitVariableListStmt(TibboBasicParser.VariableListStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#variableListItem}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitVariableListItem(TibboBasicParser.VariableListItemContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#whileWendStmt}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitWhileWendStmt(TibboBasicParser.WhileWendStmtContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#objectDeclaration}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitObjectDeclaration(TibboBasicParser.ObjectDeclarationContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#argList}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitArgList(TibboBasicParser.ArgListContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#arg}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitArg(TibboBasicParser.ArgContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#paramList}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitParamList(TibboBasicParser.ParamListContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#param}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitParam(TibboBasicParser.ParamContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#asTypeClause}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitAsTypeClause(TibboBasicParser.AsTypeClauseContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#baseType}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitBaseType(TibboBasicParser.BaseTypeContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#complexType}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitComplexType(TibboBasicParser.ComplexTypeContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#fieldLength}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitFieldLength(TibboBasicParser.FieldLengthContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#lineLabel}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitLineLabel(TibboBasicParser.LineLabelContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#literal}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitLiteral(TibboBasicParser.LiteralContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#arrayLiteral}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitArrayLiteral(TibboBasicParser.ArrayLiteralContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#type}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitType(TibboBasicParser.TypeContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicParser#visibility}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitVisibility(TibboBasicParser.VisibilityContext ctx);
}