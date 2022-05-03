// Generated from com\moonshine\basicgrammar\TibboBasicPreprocessorParser.g4 by ANTLR 4.7.1
package com.moonshine.basicgrammar;
import org.antlr.v4.runtime.tree.ParseTreeListener;

/**
 * This interface defines a complete listener for a parse tree produced by
 * {@link TibboBasicPreprocessorParser}.
 */
public interface TibboBasicPreprocessorParserListener extends ParseTreeListener {
	/**
	 * Enter a parse tree produced by {@link TibboBasicPreprocessorParser#preprocessor}.
	 * @param ctx the parse tree
	 */
	void enterPreprocessor(TibboBasicPreprocessorParser.PreprocessorContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicPreprocessorParser#preprocessor}.
	 * @param ctx the parse tree
	 */
	void exitPreprocessor(TibboBasicPreprocessorParser.PreprocessorContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicPreprocessorParser#line}.
	 * @param ctx the parse tree
	 */
	void enterLine(TibboBasicPreprocessorParser.LineContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicPreprocessorParser#line}.
	 * @param ctx the parse tree
	 */
	void exitLine(TibboBasicPreprocessorParser.LineContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicPreprocessorParser#text}.
	 * @param ctx the parse tree
	 */
	void enterText(TibboBasicPreprocessorParser.TextContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicPreprocessorParser#text}.
	 * @param ctx the parse tree
	 */
	void exitText(TibboBasicPreprocessorParser.TextContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicPreprocessorParser#codeLine}.
	 * @param ctx the parse tree
	 */
	void enterCodeLine(TibboBasicPreprocessorParser.CodeLineContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicPreprocessorParser#codeLine}.
	 * @param ctx the parse tree
	 */
	void exitCodeLine(TibboBasicPreprocessorParser.CodeLineContext ctx);
	/**
	 * Enter a parse tree produced by the {@code preprocessorConditional}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 */
	void enterPreprocessorConditional(TibboBasicPreprocessorParser.PreprocessorConditionalContext ctx);
	/**
	 * Exit a parse tree produced by the {@code preprocessorConditional}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 */
	void exitPreprocessorConditional(TibboBasicPreprocessorParser.PreprocessorConditionalContext ctx);
	/**
	 * Enter a parse tree produced by the {@code preprocessorEndConditional}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 */
	void enterPreprocessorEndConditional(TibboBasicPreprocessorParser.PreprocessorEndConditionalContext ctx);
	/**
	 * Exit a parse tree produced by the {@code preprocessorEndConditional}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 */
	void exitPreprocessorEndConditional(TibboBasicPreprocessorParser.PreprocessorEndConditionalContext ctx);
	/**
	 * Enter a parse tree produced by the {@code preprocessorDef}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 */
	void enterPreprocessorDef(TibboBasicPreprocessorParser.PreprocessorDefContext ctx);
	/**
	 * Exit a parse tree produced by the {@code preprocessorDef}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 */
	void exitPreprocessorDef(TibboBasicPreprocessorParser.PreprocessorDefContext ctx);
	/**
	 * Enter a parse tree produced by the {@code preprocessorUndef}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 */
	void enterPreprocessorUndef(TibboBasicPreprocessorParser.PreprocessorUndefContext ctx);
	/**
	 * Exit a parse tree produced by the {@code preprocessorUndef}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 */
	void exitPreprocessorUndef(TibboBasicPreprocessorParser.PreprocessorUndefContext ctx);
	/**
	 * Enter a parse tree produced by the {@code preprocessorPragma}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 */
	void enterPreprocessorPragma(TibboBasicPreprocessorParser.PreprocessorPragmaContext ctx);
	/**
	 * Exit a parse tree produced by the {@code preprocessorPragma}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 */
	void exitPreprocessorPragma(TibboBasicPreprocessorParser.PreprocessorPragmaContext ctx);
	/**
	 * Enter a parse tree produced by the {@code preprocessorError}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 */
	void enterPreprocessorError(TibboBasicPreprocessorParser.PreprocessorErrorContext ctx);
	/**
	 * Exit a parse tree produced by the {@code preprocessorError}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 */
	void exitPreprocessorError(TibboBasicPreprocessorParser.PreprocessorErrorContext ctx);
	/**
	 * Enter a parse tree produced by the {@code preprocessorDefine}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 */
	void enterPreprocessorDefine(TibboBasicPreprocessorParser.PreprocessorDefineContext ctx);
	/**
	 * Exit a parse tree produced by the {@code preprocessorDefine}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 */
	void exitPreprocessorDefine(TibboBasicPreprocessorParser.PreprocessorDefineContext ctx);
	/**
	 * Enter a parse tree produced by the {@code preprocessorInclude}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#include_file}.
	 * @param ctx the parse tree
	 */
	void enterPreprocessorInclude(TibboBasicPreprocessorParser.PreprocessorIncludeContext ctx);
	/**
	 * Exit a parse tree produced by the {@code preprocessorInclude}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#include_file}.
	 * @param ctx the parse tree
	 */
	void exitPreprocessorInclude(TibboBasicPreprocessorParser.PreprocessorIncludeContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicPreprocessorParser#directive_text}.
	 * @param ctx the parse tree
	 */
	void enterDirective_text(TibboBasicPreprocessorParser.Directive_textContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicPreprocessorParser#directive_text}.
	 * @param ctx the parse tree
	 */
	void exitDirective_text(TibboBasicPreprocessorParser.Directive_textContext ctx);
	/**
	 * Enter a parse tree produced by the {@code preprocessorBinary}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#preprocessor_expression}.
	 * @param ctx the parse tree
	 */
	void enterPreprocessorBinary(TibboBasicPreprocessorParser.PreprocessorBinaryContext ctx);
	/**
	 * Exit a parse tree produced by the {@code preprocessorBinary}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#preprocessor_expression}.
	 * @param ctx the parse tree
	 */
	void exitPreprocessorBinary(TibboBasicPreprocessorParser.PreprocessorBinaryContext ctx);
	/**
	 * Enter a parse tree produced by the {@code preprocessorConstant}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#preprocessor_expression}.
	 * @param ctx the parse tree
	 */
	void enterPreprocessorConstant(TibboBasicPreprocessorParser.PreprocessorConstantContext ctx);
	/**
	 * Exit a parse tree produced by the {@code preprocessorConstant}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#preprocessor_expression}.
	 * @param ctx the parse tree
	 */
	void exitPreprocessorConstant(TibboBasicPreprocessorParser.PreprocessorConstantContext ctx);
	/**
	 * Enter a parse tree produced by the {@code preprocessorConditionalSymbol}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#preprocessor_expression}.
	 * @param ctx the parse tree
	 */
	void enterPreprocessorConditionalSymbol(TibboBasicPreprocessorParser.PreprocessorConditionalSymbolContext ctx);
	/**
	 * Exit a parse tree produced by the {@code preprocessorConditionalSymbol}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#preprocessor_expression}.
	 * @param ctx the parse tree
	 */
	void exitPreprocessorConditionalSymbol(TibboBasicPreprocessorParser.PreprocessorConditionalSymbolContext ctx);
	/**
	 * Enter a parse tree produced by {@link TibboBasicPreprocessorParser#preprocessor_item}.
	 * @param ctx the parse tree
	 */
	void enterPreprocessor_item(TibboBasicPreprocessorParser.Preprocessor_itemContext ctx);
	/**
	 * Exit a parse tree produced by {@link TibboBasicPreprocessorParser#preprocessor_item}.
	 * @param ctx the parse tree
	 */
	void exitPreprocessor_item(TibboBasicPreprocessorParser.Preprocessor_itemContext ctx);
}