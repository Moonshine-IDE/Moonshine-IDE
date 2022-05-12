package com.moonshine.languagepreprocessing;

import java.util.ArrayList;
import java.util.List;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.misc.Interval;
import org.antlr.v4.runtime.tree.ErrorNode;
import org.antlr.v4.runtime.tree.TerminalNode;

import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.CodeLineContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.Directive_textContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.LineContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.PreprocessorBinaryContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.PreprocessorConditionalContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.PreprocessorConditionalSymbolContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.PreprocessorConstantContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.PreprocessorContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.PreprocessorDefContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.PreprocessorDefineContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.PreprocessorEndConditionalContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.PreprocessorErrorContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.PreprocessorIncludeContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.PreprocessorPragmaContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.PreprocessorUndefContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.Preprocessor_itemContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParser.TextContext;
import com.moonshine.basicgrammar.TibboBasicPreprocessorParserBaseListener;

public class PreprocessorListener extends TibboBasicPreprocessorParserBaseListener {
	TibboBasicPreprocessor preprocessor;
	String filePath;
	List<Integer> expressionStack = new ArrayList<>();
	CharStream charStream;
	int lastLine;
	PreprocessorEvaluationBlock currentBlock;

	public PreprocessorListener(TibboBasicPreprocessor preprocessor, String filePath, List<Integer> expressionStack,
			CharStream charStream) {
		super();
		this.preprocessor = preprocessor;
		this.filePath = filePath;
		this.expressionStack = expressionStack;
		this.charStream = charStream;
		this.lastLine = 0;
		this.currentBlock = null;
	}

	@Override
	public void enterPreprocessor(PreprocessorContext ctx) {
		// TODO Auto-generated method stub
		super.enterPreprocessor(ctx);
	}

	@Override
	public void exitPreprocessor(PreprocessorContext ctx) {
		// TODO Auto-generated method stub
		super.exitPreprocessor(ctx);
	}

	@Override
	public void enterLine(LineContext ctx) {
		// TODO Auto-generated method stub
		super.enterLine(ctx);
	}

	@Override
	public void exitLine(LineContext ctx) {
		// TODO Auto-generated method stub
		super.exitLine(ctx);
	}

	@Override
	public void enterText(TextContext ctx) {
		// TODO Auto-generated method stub
		super.enterText(ctx);
	}

	@Override
	public void exitText(TextContext ctx) {
		// TODO Auto-generated method stub
		super.exitText(ctx);
	}

	@Override
	public void enterCodeLine(CodeLineContext ctx) {
		if (this.currentBlock != null) {
			if (this.currentBlock.isShouldEvaluate()) {
				if (this.getCurrentStack(null)) {
					this.addCode(ctx);
				} else {
					if (ctx.start.getLine() == this.lastLine) {
						this.addCode(ctx);
					}
				}
			}
		} else {
			this.addCode(ctx);
		}

	}

	@Override
	public void exitCodeLine(CodeLineContext ctx) {
		// TODO Auto-generated method stub
		super.exitCodeLine(ctx);
	}

	@Override
	public void enterPreprocessorConditional(PreprocessorConditionalContext ctx) {
		// TODO Auto-generated method stub
		super.enterPreprocessorConditional(ctx);
	}

	@Override
	public void exitPreprocessorConditional(PreprocessorConditionalContext ctx) {
		// TODO Auto-generated method stub
		super.exitPreprocessorConditional(ctx);
	}

	@Override
	public void enterPreprocessorEndConditional(PreprocessorEndConditionalContext ctx) {
		// TODO Auto-generated method stub
		super.enterPreprocessorEndConditional(ctx);
	}

	@Override
	public void exitPreprocessorEndConditional(PreprocessorEndConditionalContext ctx) {
		// TODO Auto-generated method stub
		super.exitPreprocessorEndConditional(ctx);
	}

	@Override
	public void enterPreprocessorDef(PreprocessorDefContext ctx) {
		// TODO Auto-generated method stub
		super.enterPreprocessorDef(ctx);
	}

	@Override
	public void exitPreprocessorDef(PreprocessorDefContext ctx) {
		// TODO Auto-generated method stub
		super.exitPreprocessorDef(ctx);
	}

	@Override
	public void enterPreprocessorUndef(PreprocessorUndefContext ctx) {
		// TODO Auto-generated method stub
		super.enterPreprocessorUndef(ctx);
	}

	@Override
	public void exitPreprocessorUndef(PreprocessorUndefContext ctx) {
		// TODO Auto-generated method stub
		super.exitPreprocessorUndef(ctx);
	}

	@Override
	public void enterPreprocessorPragma(PreprocessorPragmaContext ctx) {
		// TODO Auto-generated method stub
		super.enterPreprocessorPragma(ctx);
	}

	@Override
	public void exitPreprocessorPragma(PreprocessorPragmaContext ctx) {
		// TODO Auto-generated method stub
		super.exitPreprocessorPragma(ctx);
	}

	@Override
	public void enterPreprocessorError(PreprocessorErrorContext ctx) {
		// TODO Auto-generated method stub
		super.enterPreprocessorError(ctx);
	}

	@Override
	public void exitPreprocessorError(PreprocessorErrorContext ctx) {
		// TODO Auto-generated method stub
		super.exitPreprocessorError(ctx);
	}

	@Override
	public void enterPreprocessorDefine(PreprocessorDefineContext ctx) {
		// TODO Auto-generated method stub
		super.enterPreprocessorDefine(ctx);
	}

	@Override
	public void exitPreprocessorDefine(PreprocessorDefineContext ctx) {
		// TODO Auto-generated method stub
		super.exitPreprocessorDefine(ctx);
	}

	@Override
	public void enterPreprocessorInclude(PreprocessorIncludeContext ctx) {
		// TODO Auto-generated method stub
		super.enterPreprocessorInclude(ctx);
	}

	@Override
	public void exitPreprocessorInclude(PreprocessorIncludeContext ctx) {
		// TODO Auto-generated method stub
		super.exitPreprocessorInclude(ctx);
	}

	@Override
	public void enterDirective_text(Directive_textContext ctx) {
		// TODO Auto-generated method stub
		super.enterDirective_text(ctx);
	}

	@Override
	public void exitDirective_text(Directive_textContext ctx) {
		// TODO Auto-generated method stub
		super.exitDirective_text(ctx);
	}

	@Override
	public void enterPreprocessorBinary(PreprocessorBinaryContext ctx) {
		// TODO Auto-generated method stub
		super.enterPreprocessorBinary(ctx);
	}

	@Override
	public void exitPreprocessorBinary(PreprocessorBinaryContext ctx) {
		// TODO Auto-generated method stub
		super.exitPreprocessorBinary(ctx);
	}

	@Override
	public void enterPreprocessorConstant(PreprocessorConstantContext ctx) {
		// TODO Auto-generated method stub
		super.enterPreprocessorConstant(ctx);
	}

	@Override
	public void exitPreprocessorConstant(PreprocessorConstantContext ctx) {
		// TODO Auto-generated method stub
		super.exitPreprocessorConstant(ctx);
	}

	@Override
	public void enterPreprocessorConditionalSymbol(PreprocessorConditionalSymbolContext ctx) {
		// TODO Auto-generated method stub
		super.enterPreprocessorConditionalSymbol(ctx);
	}

	@Override
	public void exitPreprocessorConditionalSymbol(PreprocessorConditionalSymbolContext ctx) {
		// TODO Auto-generated method stub
		super.exitPreprocessorConditionalSymbol(ctx);
	}

	@Override
	public void enterPreprocessor_item(Preprocessor_itemContext ctx) {
		// TODO Auto-generated method stub
		super.enterPreprocessor_item(ctx);
	}

	@Override
	public void exitPreprocessor_item(Preprocessor_itemContext ctx) {
		// TODO Auto-generated method stub
		super.exitPreprocessor_item(ctx);
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

	boolean getCurrentStack(PreprocessorEvaluationBlock block) {
		boolean result = true;
		if (block == null) {
			block = this.currentBlock;
		}
		if (block != null) {
			result = block.evaluationResults.get(block.evaluationResults.size() - 1);
		}
		return result;
	}

	void addCode(ParserRuleContext context) {
		if (this.currentBlock != null) {
			if (!this.currentBlock.isShouldEvaluate()) {
				return;
			}
		}
		String text = this.charStream.getText(new Interval( context.start.getStartIndex(), context.stop.getStopIndex()));
		// this.preprocessor.codes[this.filePath]
		this.preprocessor.getFiles().put(this.filePath, this.replaceRange(this.preprocessor.files.get(this.filePath),
				context.start.getStartIndex(), context.stop.getStopIndex(), text));
		// if (context.children != undefined) {
		// for (let i = 0; i < context.children.length; i++) {
		// this.addCode(context.children[i]);
		// }
		// }
		// else {
		// this.preprocessor.codes[this.filePath].push(context);
		// }
	}

	String replaceRange(String s, int start, int end, String substitute) {
		return s.substring(0, start) + substitute + s.substring(end + 1);
	}
}
