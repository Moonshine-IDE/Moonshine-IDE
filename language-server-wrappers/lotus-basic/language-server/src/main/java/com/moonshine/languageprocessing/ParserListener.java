package com.moonshine.languageprocessing;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Stack;

import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.tree.ErrorNode;
import org.antlr.v4.runtime.tree.TerminalNode;

import com.moonshine.basicgrammar.TibboBasicParser;
import com.moonshine.basicgrammar.TibboBasicParser.ArgContext;
import com.moonshine.basicgrammar.TibboBasicParser.ArgListContext;
import com.moonshine.basicgrammar.TibboBasicParser.ArrayLiteralContext;
import com.moonshine.basicgrammar.TibboBasicParser.AsTypeClauseContext;
import com.moonshine.basicgrammar.TibboBasicParser.BaseTypeContext;
import com.moonshine.basicgrammar.TibboBasicParser.BlockContext;
import com.moonshine.basicgrammar.TibboBasicParser.BlockIfThenElseContext;
import com.moonshine.basicgrammar.TibboBasicParser.ComplexTypeContext;
import com.moonshine.basicgrammar.TibboBasicParser.ConstStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.ConstSubStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.DeclareFuncStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.DeclareSubStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.DeclareVariableStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.DoLoopStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.EnumerationStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.EnumerationStmt_ConstantContext;
import com.moonshine.basicgrammar.TibboBasicParser.EventDeclarationContext;
import com.moonshine.basicgrammar.TibboBasicParser.ExitStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.ExpressionContext;
import com.moonshine.basicgrammar.TibboBasicParser.FieldLengthContext;
import com.moonshine.basicgrammar.TibboBasicParser.ForNextStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.FunctionStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.GoToStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.IfConditionStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.IncludeStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.IncludeppStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.InlineIfThenElseContext;
import com.moonshine.basicgrammar.TibboBasicParser.JumpStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.LineLabelContext;
import com.moonshine.basicgrammar.TibboBasicParser.LiteralContext;
import com.moonshine.basicgrammar.TibboBasicParser.ObjectDeclarationContext;
import com.moonshine.basicgrammar.TibboBasicParser.ParamContext;
import com.moonshine.basicgrammar.TibboBasicParser.ParamInternalContext;
import com.moonshine.basicgrammar.TibboBasicParser.ParamListContext;
import com.moonshine.basicgrammar.TibboBasicParser.PostfixContext;
import com.moonshine.basicgrammar.TibboBasicParser.PostfixExpressionContext;
import com.moonshine.basicgrammar.TibboBasicParser.PrimaryExpressionContext;
import com.moonshine.basicgrammar.TibboBasicParser.PropertyDefineStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.PropertyDefineStmt_InStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.PropertyGetStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.PropertySetStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.SC_CaseContext;
import com.moonshine.basicgrammar.TibboBasicParser.SC_CondContext;
import com.moonshine.basicgrammar.TibboBasicParser.SC_DefaultContext;
import com.moonshine.basicgrammar.TibboBasicParser.SelectCaseStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.StartRuleContext;
import com.moonshine.basicgrammar.TibboBasicParser.StatementContext;
import com.moonshine.basicgrammar.TibboBasicParser.SubStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.SyscallDeclarationContext;
import com.moonshine.basicgrammar.TibboBasicParser.SyscallDeclarationInnerContext;
import com.moonshine.basicgrammar.TibboBasicParser.SyscallInternalDeclarationInnerContext;
import com.moonshine.basicgrammar.TibboBasicParser.SyscallInternalParamListContext;
import com.moonshine.basicgrammar.TibboBasicParser.TopLevelDeclarationContext;
import com.moonshine.basicgrammar.TibboBasicParser.TypeContext;
import com.moonshine.basicgrammar.TibboBasicParser.TypeStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.TypeStmtElementContext;
import com.moonshine.basicgrammar.TibboBasicParser.UnaryExpressionContext;
import com.moonshine.basicgrammar.TibboBasicParser.UnaryOperatorContext;
import com.moonshine.basicgrammar.TibboBasicParser.VariableListItemContext;
import com.moonshine.basicgrammar.TibboBasicParser.VariableListStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.VariableStmtContext;
import com.moonshine.basicgrammar.TibboBasicParser.VisibilityContext;
import com.moonshine.basicgrammar.TibboBasicParser.WhileWendStmtContext;
import com.moonshine.basicgrammar.TibboBasicParserBaseListener;

public class ParserListener extends TibboBasicParserBaseListener {
	String currentObject;
	String currentProperty;
	Stack<TBScope> scopeStack;
	Map<String, TBConst> consts;

	TibboBasicProjectParser parser;

	public ParserListener(TibboBasicProjectParser parser) {
		super();
		this.parser = parser;
	}

	@Override
	public void enterStartRule(StartRuleContext ctx) {
		// TODO Auto-generated method stub
		super.enterStartRule(ctx);
	}

	@Override
	public void exitStartRule(StartRuleContext ctx) {
		// TODO Auto-generated method stub
		super.exitStartRule(ctx);
	}

	@Override
	public void enterTopLevelDeclaration(TopLevelDeclarationContext ctx) {
		// TODO Auto-generated method stub
		super.enterTopLevelDeclaration(ctx);
	}

	@Override
	public void exitTopLevelDeclaration(TopLevelDeclarationContext ctx) {
		// TODO Auto-generated method stub
		super.exitTopLevelDeclaration(ctx);
	}

	@Override
	public void enterIncludeStmt(IncludeStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterIncludeStmt(ctx);
	}

	@Override
	public void exitIncludeStmt(IncludeStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitIncludeStmt(ctx);
	}

	@Override
	public void enterIncludeppStmt(IncludeppStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterIncludeppStmt(ctx);
	}

	@Override
	public void exitIncludeppStmt(IncludeppStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitIncludeppStmt(ctx);
	}

	@Override
	public void enterBlock(BlockContext ctx) {
		// TODO Auto-generated method stub
		super.enterBlock(ctx);
	}

	@Override
	public void exitBlock(BlockContext ctx) {
		// TODO Auto-generated method stub
		super.exitBlock(ctx);
	}

	@Override
	public void enterStatement(StatementContext ctx) {
		// TODO Auto-generated method stub
		super.enterStatement(ctx);
	}

	@Override
	public void exitStatement(StatementContext ctx) {
		// TODO Auto-generated method stub
		super.exitStatement(ctx);
	}

	@Override
	public void enterConstStmt(ConstStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterConstStmt(ctx);
	}

	@Override
	public void exitConstStmt(ConstStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitConstStmt(ctx);
	}

	@Override
	public void enterConstSubStmt(ConstSubStmtContext ctx) {

		this.parser.getConsts().put(ctx.name.getText(), new TBConst(ctx.name.getText(), ctx.value.getText(),
				new TBRange(ctx.start, ctx.stop), new ArrayList<>()));

	}

	@Override
	public void exitConstSubStmt(ConstSubStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitConstSubStmt(ctx);
	}

	@Override
	public void enterDeclareVariableStmt(DeclareVariableStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterDeclareVariableStmt(ctx);
	}

	@Override
	public void exitDeclareVariableStmt(DeclareVariableStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitDeclareVariableStmt(ctx);
	}

	@Override
	public void enterDeclareSubStmt(DeclareSubStmtContext ctx) {
		String name = ctx.children.get(2).getText();
		TBFunction function = new TBFunction(name);
		function.setDeclaration(new TBRange(ctx.start, ctx.start));
		this.addFunction(function);
	}

	@Override
	public void exitDeclareSubStmt(DeclareSubStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitDeclareSubStmt(ctx);
	}

	@Override
	public void enterDeclareFuncStmt(DeclareFuncStmtContext ctx) {
		String name = ctx.children.get(2).getText();
		TBFunction function = new TBFunction(name);
		function.setDeclaration(new TBRange(ctx.start, ctx.start));
		this.addFunction(function);
	}

	@Override
	public void exitDeclareFuncStmt(DeclareFuncStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitDeclareFuncStmt(ctx);
	}

	@Override
	public void enterDoLoopStmt(DoLoopStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterDoLoopStmt(ctx);
	}

	@Override
	public void exitDoLoopStmt(DoLoopStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitDoLoopStmt(ctx);
	}

	@Override
	public void enterEnumerationStmt(EnumerationStmtContext ctx) {
		String name = ctx.children.get(1).getText().toLowerCase();
		this.parser.getEnums().put(name,
				new TBEnum(name, new HashMap<>(), new TBRange(ctx.start, ctx.start), new ArrayList<>()));

	}

	@Override
	public void exitEnumerationStmt(EnumerationStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitEnumerationStmt(ctx);
	}

	@Override
	public void enterEnumerationStmt_Constant(EnumerationStmt_ConstantContext ctx) {
		String enumName = ctx.getParent().children.get(1).getText().toLowerCase();
		String name = ctx.children.get(0).getText().toLowerCase();
		String value = ("" + this.parser.getEnums().get(enumName).getMembers().size()).toLowerCase();

		this.parser.getEnums().get(name).getMembers().put(name,
				new TBEnumEntry(name, value, new TBRange(ctx.start, ctx.start), new ArrayList<>()));

	}

	@Override
	public void exitEnumerationStmt_Constant(EnumerationStmt_ConstantContext ctx) {
		// TODO Auto-generated method stub
		super.exitEnumerationStmt_Constant(ctx);
	}

	@Override
	public void enterExitStmt(ExitStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterExitStmt(ctx);
	}

	@Override
	public void exitExitStmt(ExitStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitExitStmt(ctx);
	}

	@Override
	public void enterForNextStmt(ForNextStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterForNextStmt(ctx);
	}

	@Override
	public void exitForNextStmt(ForNextStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitForNextStmt(ctx);
	}

	@Override
	public void enterFunctionStmt(FunctionStmtContext ctx) {
		if (ctx.name != null) {
			String name = ctx.name.getText();
			String length = "";
			TBRange location = new TBRange(ctx.start, ctx.start);
			for (int i = 0; i < ctx.children.size(); i++) {
				if (((ParserRuleContext) ctx.children.get(i)).getRuleIndex() == TibboBasicParser.RULE_asTypeClause) {
					String valueType = ctx.children.get(i).getText();
					if (((ParserRuleContext) ctx.children.get(i)).children.size() >= 4) {
						length = ((ParserRuleContext) ctx.children.get(i)).children.get(2).getText();
					}
					TBRange l1 = new TBRange(ctx.start, ((ParserRuleContext) ctx.children.get(i)).stop);
					TBVariable variable = new TBVariable(name, "", valueType, length, new TBRange(ctx.name, ctx.name),
							null, new ArrayList<>(), null, new ArrayList<>());
					variable.setParentScope(this.scopeStack.get(this.scopeStack.size() - 1));

					this.parser.addVariable(variable);
				}
			}
			TBFunction function = new TBFunction(name);
			function.setName(name);
			function.setDataType(length);
			function.setDataType(ctx.returnType.children.get(1).getText());

			TBScope scope = new TBScope(ctx.start.getTokenSource().getSourceName(), ctx.start, ctx.stop);
			this.parser.getScopes().add(scope);
			this.scopeStack.push(scope);
		}

	}

	@Override
	public void exitFunctionStmt(FunctionStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitFunctionStmt(ctx);
	}

	@Override
	public void enterJumpStmt(JumpStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterJumpStmt(ctx);
	}

	@Override
	public void exitJumpStmt(JumpStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitJumpStmt(ctx);
	}

	@Override
	public void enterGoToStmt(GoToStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterGoToStmt(ctx);
	}

	@Override
	public void exitGoToStmt(GoToStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitGoToStmt(ctx);
	}

	@Override
	public void enterInlineIfThenElse(InlineIfThenElseContext ctx) {
		TBScope scope = new TBScope(ctx.start.getTokenSource().getSourceName(), ctx.start, ctx.stop);
		scope.setParentScope(this.scopeStack.peek());
		this.parser.getScopes().add(scope);
		this.scopeStack.push(scope);
	}

	@Override
	public void exitInlineIfThenElse(InlineIfThenElseContext ctx) {
		this.scopeStack.peek();
	}

	@Override
	public void enterBlockIfThenElse(BlockIfThenElseContext ctx) {

		TBScope scope = new TBScope(ctx.start.getTokenSource().getSourceName(), ctx.start, ctx.stop);
		this.parser.getScopes().add(scope);
		this.scopeStack.push(scope);
	}

	@Override
	public void exitBlockIfThenElse(BlockIfThenElseContext ctx) {
		this.scopeStack.pop();
	}

	@Override
	public void enterIfConditionStmt(IfConditionStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterIfConditionStmt(ctx);
	}

	@Override
	public void exitIfConditionStmt(IfConditionStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitIfConditionStmt(ctx);
	}

	@Override
	public void enterPropertyDefineStmt(PropertyDefineStmtContext ctx) {
		String objectName = ctx.object.getText();
		String propertyName = ctx.property.getText();
		if (this.parser.getObjects().keySet().contains(objectName)) {
			this.currentObject = objectName;
			this.currentProperty = propertyName;

			this.parser.getObjects().get(objectName).getProperties().add(new TBObjectProperty(objectName, propertyName,
					null, null, new TBRange(ctx.start, ctx.start), new ArrayList<>()));

		}

	}

	@Override
	public void exitPropertyDefineStmt(PropertyDefineStmtContext ctx) {
		this.currentObject = null;
		this.currentProperty = null;
	}

	@Override
	public void enterPropertyDefineStmt_InStmt(PropertyDefineStmt_InStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterPropertyDefineStmt_InStmt(ctx);
	}

	@Override
	public void exitPropertyDefineStmt_InStmt(PropertyDefineStmt_InStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitPropertyDefineStmt_InStmt(ctx);
	}

	@Override
	public void enterPropertyGetStmt(PropertyGetStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterPropertyGetStmt(ctx);
	}

	@Override
	public void exitPropertyGetStmt(PropertyGetStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitPropertyGetStmt(ctx);
	}

	@Override
	public void enterPropertySetStmt(PropertySetStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterPropertySetStmt(ctx);
	}

	@Override
	public void exitPropertySetStmt(PropertySetStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitPropertySetStmt(ctx);
	}

	@Override
	public void enterEventDeclaration(EventDeclarationContext ctx) {
		// TODO Auto-generated method stub
		super.enterEventDeclaration(ctx);
	}

	@Override
	public void exitEventDeclaration(EventDeclarationContext ctx) {
		// TODO Auto-generated method stub
		super.exitEventDeclaration(ctx);
	}

	@Override
	public void enterSyscallDeclaration(SyscallDeclarationContext ctx) {
		// TODO Auto-generated method stub
		super.enterSyscallDeclaration(ctx);
	}

	@Override
	public void exitSyscallDeclaration(SyscallDeclarationContext ctx) {
		// TODO Auto-generated method stub
		super.exitSyscallDeclaration(ctx);
	}

	@Override
	public void enterSyscallDeclarationInner(SyscallDeclarationInnerContext ctx) {

		if (ctx.object != null) {
			String objectName = ctx.object.getText();
			String functionName = ctx.property.getText();
			if (this.parser.getObjects().get(objectName) != null) {

				this.parser.getObjects().get(objectName).getFunctions().add(new TBObjectFunction(functionName, null,
						new ArrayList<>(), "", new TBRange(ctx.start, ctx.start), new ArrayList<>()));
			} else {
				// non object syscall
				String name = ctx.property.getText();
				String valueType = "";
				for (int i = 0; i < ctx.children.size(); i++) {
					if (((ParserRuleContext) ctx.children.get(i))
							.getRuleIndex() == TibboBasicParser.RULE_asTypeClause) {
						valueType = ((AsTypeClauseContext) ctx.children.get(i)).valueType.getText();
					}
				}
				this.parser.getSyscalls().put(name, new TBSyscall(name, 0, name, new ArrayList<>(), valueType,
						new TBRange(ctx.start, ctx.start), new ArrayList<>()));
			}
		}

	}

	@Override
	public void exitSyscallDeclarationInner(SyscallDeclarationInnerContext ctx) {
		// TODO Auto-generated method stub
		super.exitSyscallDeclarationInner(ctx);
	}

	@Override
	public void enterSyscallInternalDeclarationInner(SyscallInternalDeclarationInnerContext ctx) {
		// TODO Auto-generated method stub
		super.enterSyscallInternalDeclarationInner(ctx);
	}

	@Override
	public void exitSyscallInternalDeclarationInner(SyscallInternalDeclarationInnerContext ctx) {
		// TODO Auto-generated method stub
		super.exitSyscallInternalDeclarationInner(ctx);
	}

	@Override
	public void enterSyscallInternalParamList(SyscallInternalParamListContext ctx) {
		// TODO Auto-generated method stub
		super.enterSyscallInternalParamList(ctx);
	}

	@Override
	public void exitSyscallInternalParamList(SyscallInternalParamListContext ctx) {
		// TODO Auto-generated method stub
		super.exitSyscallInternalParamList(ctx);
	}

	@Override
	public void enterParamInternal(ParamInternalContext ctx) {
		// TODO Auto-generated method stub
		super.enterParamInternal(ctx);
	}

	@Override
	public void exitParamInternal(ParamInternalContext ctx) {
		// TODO Auto-generated method stub
		super.exitParamInternal(ctx);
	}

	@Override
	public void enterSelectCaseStmt(SelectCaseStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterSelectCaseStmt(ctx);
	}

	@Override
	public void exitSelectCaseStmt(SelectCaseStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitSelectCaseStmt(ctx);
	}

	@Override
	public void enterSC_Case(SC_CaseContext ctx) {
		// TODO Auto-generated method stub
		super.enterSC_Case(ctx);
	}

	@Override
	public void exitSC_Case(SC_CaseContext ctx) {
		// TODO Auto-generated method stub
		super.exitSC_Case(ctx);
	}

	@Override
	public void enterSC_Default(SC_DefaultContext ctx) {
		// TODO Auto-generated method stub
		super.enterSC_Default(ctx);
	}

	@Override
	public void exitSC_Default(SC_DefaultContext ctx) {
		// TODO Auto-generated method stub
		super.exitSC_Default(ctx);
	}

	@Override
	public void enterSC_Cond(SC_CondContext ctx) {
		// TODO Auto-generated method stub
		super.enterSC_Cond(ctx);
	}

	@Override
	public void exitSC_Cond(SC_CondContext ctx) {
		// TODO Auto-generated method stub
		super.exitSC_Cond(ctx);
	}

	@Override
	public void enterSubStmt(SubStmtContext ctx) {
		if (ctx.name != null) {
			String name = ctx.name.getText();
			this.addFunction(name);
//                location: {
//                    startToken: ctx.start,
//                    stopToken: ctx.name
//                },
			// });

			TBScope scope = new TBScope(ctx.start.getTokenSource().getSourceName(), ctx.start, ctx.stop);
			this.parser.getScopes().add(scope);
			this.scopeStack.push(scope);
		}

	}

	private void addFunction(String name) {
		if (name != null) {
			if (this.parser.getFunctions().keySet().contains(name)) {
				this.parser.getFunctions().put(name, new TBFunction(name));

			}
		}
		/*
		 * for (const key in func) { this.parser.functions[name][key] = func[key]; }
		 */
	}

	private void addFunction(TBFunction function) {

		if (this.parser.getFunctions().keySet().contains(function.getName())) {
			this.parser.getFunctions().put(function.getName(), function);

		}

		/*
		 * for (const key in func) { this.parser.functions[name][key] = func[key]; }
		 */
	}

	@Override
	public void exitSubStmt(SubStmtContext ctx) {
		this.scopeStack.pop();
	}

	@Override
	public void enterTypeStmt(TypeStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterTypeStmt(ctx);
	}

	@Override
	public void exitTypeStmt(TypeStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitTypeStmt(ctx);
	}

	@Override
	public void enterTypeStmtElement(TypeStmtElementContext ctx) {
		// TODO Auto-generated method stub
		super.enterTypeStmtElement(ctx);
	}

	@Override
	public void exitTypeStmtElement(TypeStmtElementContext ctx) {
		// TODO Auto-generated method stub
		super.exitTypeStmtElement(ctx);
	}

	@Override
	public void enterExpression(ExpressionContext ctx) {
		// TODO Auto-generated method stub
		super.enterExpression(ctx);
	}

	@Override
	public void exitExpression(ExpressionContext ctx) {
		// TODO Auto-generated method stub
		super.exitExpression(ctx);
	}

	@Override
	public void enterUnaryExpression(UnaryExpressionContext ctx) {
		// TODO Auto-generated method stub
		super.enterUnaryExpression(ctx);
	}

	@Override
	public void exitUnaryExpression(UnaryExpressionContext ctx) {
		// TODO Auto-generated method stub
		super.exitUnaryExpression(ctx);
	}

	@Override
	public void enterUnaryOperator(UnaryOperatorContext ctx) {
		// TODO Auto-generated method stub
		super.enterUnaryOperator(ctx);
	}

	@Override
	public void exitUnaryOperator(UnaryOperatorContext ctx) {
		// TODO Auto-generated method stub
		super.exitUnaryOperator(ctx);
	}

	@Override
	public void enterPostfixExpression(PostfixExpressionContext ctx) {
		// TODO Auto-generated method stub
		super.enterPostfixExpression(ctx);
	}

	@Override
	public void exitPostfixExpression(PostfixExpressionContext ctx) {
		// TODO Auto-generated method stub
		super.exitPostfixExpression(ctx);
	}

	@Override
	public void enterPostfix(PostfixContext ctx) {
		// TODO Auto-generated method stub
		super.enterPostfix(ctx);
	}

	@Override
	public void exitPostfix(PostfixContext ctx) {
		// TODO Auto-generated method stub
		super.exitPostfix(ctx);
	}

	@Override
	public void enterPrimaryExpression(PrimaryExpressionContext ctx) {
		// TODO Auto-generated method stub
		super.enterPrimaryExpression(ctx);
	}

	@Override
	public void exitPrimaryExpression(PrimaryExpressionContext ctx) {
		// TODO Auto-generated method stub
		super.exitPrimaryExpression(ctx);
	}

	@Override
	public void enterVariableStmt(VariableStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterVariableStmt(ctx);
	}

	@Override
	public void exitVariableStmt(VariableStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitVariableStmt(ctx);
	}

	@Override
	public void enterVariableListStmt(VariableListStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterVariableListStmt(ctx);
	}

	@Override
	public void exitVariableListStmt(VariableListStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitVariableListStmt(ctx);
	}

	@Override
	public void enterVariableListItem(VariableListItemContext ctx) {
		String variableType = ((VariableListStmtContext) ctx.parent).variableType.valueType.getText();
		String length = "";
		if (ctx.children.size() >= 4) {
			length = ctx.children.get(2).getText();
		}
		String name = ctx.name.getText();
		TBVariable variable = new TBVariable(name, "", length, variableType, new TBRange(ctx.start, ctx.start), null,
				new ArrayList<>(), null, new ArrayList<>());
		variable.setParentScope(this.scopeStack.peek());
		this.parser.addVariable(variable);

	}

	@Override
	public void exitVariableListItem(VariableListItemContext ctx) {
		// TODO Auto-generated method stub
		super.exitVariableListItem(ctx);
	}

	@Override
	public void enterWhileWendStmt(WhileWendStmtContext ctx) {
		// TODO Auto-generated method stub
		super.enterWhileWendStmt(ctx);
	}

	@Override
	public void exitWhileWendStmt(WhileWendStmtContext ctx) {
		// TODO Auto-generated method stub
		super.exitWhileWendStmt(ctx);
	}

	@Override
	public void enterObjectDeclaration(ObjectDeclarationContext ctx) {
		String name = ctx.children.get(1).getText(); // children[1].symbol.text;
		this.parser.getObjects().put(name, new TBObject(

				name, new TBRange(ctx.start, ctx.start), new ArrayList<>(), new ArrayList<>(), new ArrayList<>()));
	}

	@Override
	public void exitObjectDeclaration(ObjectDeclarationContext ctx) {
		// TODO Auto-generated method stub
		super.exitObjectDeclaration(ctx);
	}

	@Override
	public void enterArgList(ArgListContext ctx) {
		// TODO Auto-generated method stub
		super.enterArgList(ctx);
	}

	@Override
	public void exitArgList(ArgListContext ctx) {
		// TODO Auto-generated method stub
		super.exitArgList(ctx);
	}

	@Override
	public void enterArg(ArgContext ctx) {
		// TODO Auto-generated method stub
		super.enterArg(ctx);
	}

	@Override
	public void exitArg(ArgContext ctx) {
		// TODO Auto-generated method stub
		super.exitArg(ctx);
	}

	@Override
	public void enterParam(ParamContext ctx) {
		if (ctx.getParent().getParent().getRuleIndex() == TibboBasicParser.RULE_declareSubStmt
				|| ctx.getParent().getParent().getRuleIndex() == TibboBasicParser.RULE_declareFuncStmt) {
			return;
		}
		String valueType = ctx.valueType != null ? ctx.valueType.getText() : "void";

		String length = "";

		TBVariable variable = new TBVariable(ctx.name.getText(), "", length, valueType, new TBRange(ctx.name, ctx.name),
				null, new ArrayList<>(), null, new ArrayList<>());

		TBParameter param = new TBParameter(

				ctx.name.getText(), ctx.byref != null, valueType);

		this.parser.addVariable(variable);

		if (ctx.getParent().getParent().getRuleIndex() == TibboBasicParser.RULE_subStmt) {
			this.parser.getFunctions().get(((SubStmtContext) ctx.getParent().getParent()).name.getText())
					.getParameters().add(param);
		}

		if (ctx.getParent().getParent().getRuleIndex() == TibboBasicParser.RULE_functionStmt) {
			this.parser.getFunctions().get(((FunctionStmtContext) ctx.getParent().getParent()).name.getText())
					.getParameters().add(param);
		}
		if (ctx.getParent().getParent().getRuleIndex() == TibboBasicParser.RULE_syscallDeclarationInner) {
			SyscallDeclarationInnerContext context = (SyscallDeclarationInnerContext) ctx.getParent().getParent();
			Token objName = context.object;
			if (objName != null) {
				TBObject obj = this.parser.getObjects().get(context.children.get(0).getText());
				String prop = context.property.getText();
				for (int i = 0; i < obj.functions.size(); i++) {
					if (obj.getFunctions().get(i).getName().equals(prop)) {
						obj.getFunctions().get(i).getParameters().add(param);
						break;
					}
				}
			} else {
				this.parser.getSyscalls().get(context.children.get(0).getText()).getParameters().add(param);
			}
		}

	}

	@Override
	public void exitParamList(ParamListContext ctx) {
		// TODO Auto-generated method stub
		super.exitParamList(ctx);
	}

	@Override
	public void exitParam(ParamContext ctx) {
		// TODO Auto-generated method stub
		super.exitParam(ctx);
	}

	@Override
	public void enterAsTypeClause(AsTypeClauseContext ctx) {
		if (ctx.getParent().getRuleIndex() == TibboBasicParser.RULE_propertyGetStmt && this.currentObject != null) {
			String valueType = ctx.valueType.getText();
			for (int i = 0; i < this.parser.getObjects().get(this.currentObject).properties.size(); i++) {
				if (this.parser.getObjects().get(this.currentObject).properties.get(i)
						.getName() == this.currentProperty) {
					this.parser.getObjects().get(this.currentObject).properties.get(i).setDataType(valueType);
					break;
				}
			}
		}
	}

	@Override
	public void exitAsTypeClause(AsTypeClauseContext ctx) {
		// TODO Auto-generated method stub
		super.exitAsTypeClause(ctx);
	}

	@Override
	public void enterBaseType(BaseTypeContext ctx) {
		// TODO Auto-generated method stub
		super.enterBaseType(ctx);
	}

	@Override
	public void exitBaseType(BaseTypeContext ctx) {
		// TODO Auto-generated method stub
		super.exitBaseType(ctx);
	}

	@Override
	public void enterComplexType(ComplexTypeContext ctx) {
		// TODO Auto-generated method stub
		super.enterComplexType(ctx);
	}

	@Override
	public void exitComplexType(ComplexTypeContext ctx) {
		// TODO Auto-generated method stub
		super.exitComplexType(ctx);
	}

	@Override
	public void enterFieldLength(FieldLengthContext ctx) {
		// TODO Auto-generated method stub
		super.enterFieldLength(ctx);
	}

	@Override
	public void exitFieldLength(FieldLengthContext ctx) {
		// TODO Auto-generated method stub
		super.exitFieldLength(ctx);
	}

	@Override
	public void enterLineLabel(LineLabelContext ctx) {
		// TODO Auto-generated method stub
		super.enterLineLabel(ctx);
	}

	@Override
	public void exitLineLabel(LineLabelContext ctx) {
		// TODO Auto-generated method stub
		super.exitLineLabel(ctx);
	}

	@Override
	public void enterLiteral(LiteralContext ctx) {
		// TODO Auto-generated method stub
		super.enterLiteral(ctx);
	}

	@Override
	public void exitLiteral(LiteralContext ctx) {
		// TODO Auto-generated method stub
		super.exitLiteral(ctx);
	}

	@Override
	public void enterArrayLiteral(ArrayLiteralContext ctx) {
		// TODO Auto-generated method stub
		super.enterArrayLiteral(ctx);
	}

	@Override
	public void exitArrayLiteral(ArrayLiteralContext ctx) {
		// TODO Auto-generated method stub
		super.exitArrayLiteral(ctx);
	}

	@Override
	public void enterType(TypeContext ctx) {
		// TODO Auto-generated method stub
		super.enterType(ctx);
	}

	@Override
	public void exitType(TypeContext ctx) {
		// TODO Auto-generated method stub
		super.exitType(ctx);
	}

	@Override
	public void enterVisibility(VisibilityContext ctx) {
		// TODO Auto-generated method stub
		super.enterVisibility(ctx);
	}

	@Override
	public void exitVisibility(VisibilityContext ctx) {
		// TODO Auto-generated method stub
		super.exitVisibility(ctx);
	}

	@Override
	public void enterEveryRule(ParserRuleContext ctx) {
		// TODO Auto-generated method stub
		super.enterEveryRule(ctx);
	}

	@Override
	public void exitEveryRule(ParserRuleContext ctx) {
		// TODO Auto-generated method stub
		super.exitEveryRule(ctx);
	}

	@Override
	public void visitTerminal(TerminalNode node) {
		// TODO Auto-generated method stub
		super.visitTerminal(node);
	}

	@Override
	public void visitErrorNode(ErrorNode node) {
		// TODO Auto-generated method stub
		super.visitErrorNode(node);
	}

}
