// Generated from com\moonshine\basicgrammar\TibboBasicPreprocessorParser.g4 by ANTLR 4.7.1
package com.moonshine.basicgrammar;
import org.antlr.v4.runtime.tree.ParseTreeVisitor;

/**
 * This interface defines a complete generic visitor for a parse tree produced
 * by {@link TibboBasicPreprocessorParser}.
 *
 * @param <T> The return type of the visit operation. Use {@link Void} for
 * operations with no return type.
 */
public interface TibboBasicPreprocessorParserVisitor<T> extends ParseTreeVisitor<T> {
	/**
	 * Visit a parse tree produced by {@link TibboBasicPreprocessorParser#preprocessor}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPreprocessor(TibboBasicPreprocessorParser.PreprocessorContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicPreprocessorParser#line}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitLine(TibboBasicPreprocessorParser.LineContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicPreprocessorParser#text}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitText(TibboBasicPreprocessorParser.TextContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicPreprocessorParser#codeLine}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitCodeLine(TibboBasicPreprocessorParser.CodeLineContext ctx);
	/**
	 * Visit a parse tree produced by the {@code preprocessorConditional}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPreprocessorConditional(TibboBasicPreprocessorParser.PreprocessorConditionalContext ctx);
	/**
	 * Visit a parse tree produced by the {@code preprocessorEndConditional}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPreprocessorEndConditional(TibboBasicPreprocessorParser.PreprocessorEndConditionalContext ctx);
	/**
	 * Visit a parse tree produced by the {@code preprocessorDef}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPreprocessorDef(TibboBasicPreprocessorParser.PreprocessorDefContext ctx);
	/**
	 * Visit a parse tree produced by the {@code preprocessorUndef}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPreprocessorUndef(TibboBasicPreprocessorParser.PreprocessorUndefContext ctx);
	/**
	 * Visit a parse tree produced by the {@code preprocessorPragma}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPreprocessorPragma(TibboBasicPreprocessorParser.PreprocessorPragmaContext ctx);
	/**
	 * Visit a parse tree produced by the {@code preprocessorError}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPreprocessorError(TibboBasicPreprocessorParser.PreprocessorErrorContext ctx);
	/**
	 * Visit a parse tree produced by the {@code preprocessorDefine}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#directive}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPreprocessorDefine(TibboBasicPreprocessorParser.PreprocessorDefineContext ctx);
	/**
	 * Visit a parse tree produced by the {@code preprocessorInclude}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#include_file}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPreprocessorInclude(TibboBasicPreprocessorParser.PreprocessorIncludeContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicPreprocessorParser#directive_text}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitDirective_text(TibboBasicPreprocessorParser.Directive_textContext ctx);
	/**
	 * Visit a parse tree produced by the {@code preprocessorBinary}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#preprocessor_expression}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPreprocessorBinary(TibboBasicPreprocessorParser.PreprocessorBinaryContext ctx);
	/**
	 * Visit a parse tree produced by the {@code preprocessorConstant}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#preprocessor_expression}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPreprocessorConstant(TibboBasicPreprocessorParser.PreprocessorConstantContext ctx);
	/**
	 * Visit a parse tree produced by the {@code preprocessorConditionalSymbol}
	 * labeled alternative in {@link TibboBasicPreprocessorParser#preprocessor_expression}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPreprocessorConditionalSymbol(TibboBasicPreprocessorParser.PreprocessorConditionalSymbolContext ctx);
	/**
	 * Visit a parse tree produced by {@link TibboBasicPreprocessorParser#preprocessor_item}.
	 * @param ctx the parse tree
	 * @return the visitor result
	 */
	T visitPreprocessor_item(TibboBasicPreprocessorParser.Preprocessor_itemContext ctx);
}