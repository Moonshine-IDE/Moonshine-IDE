// Generated from com\moonshine\basicgrammar\TibboBasicPreprocessorParser.g4 by ANTLR 4.7.1
package com.moonshine.basicgrammar;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.*;
import org.antlr.v4.runtime.tree.*;
import java.util.List;
import java.util.Iterator;
import java.util.ArrayList;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast"})
public class TibboBasicPreprocessorParser extends Parser {
	static { RuntimeMetaData.checkVersion("4.7.1", RuntimeMetaData.VERSION); }

	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		WS=1, INCLUDE=2, INCLUDEPP=3, SHARP=4, CODE=5, NEW_LINE=6, PRAGMA=7, DEFINE=8, 
		DEFINED=9, ADD=10, SUB=11, IF=12, ELIF=13, ELSE=14, UNDEF=15, IFDEF=16, 
		IFNDEF=17, ENDIF=18, ERROR=19, BANG=20, LPAREN=21, RPAREN=22, EQUAL=23, 
		NOTEQUAL=24, AND=25, OR=26, LT=27, GT=28, LE=29, GE=30, DIRECTIVE_WHITESPACES=31, 
		DIRECTIVE_STRING=32, CONDITIONAL_SYMBOL=33, DECIMAL_LITERAL=34, FLOAT=35, 
		TEXT=36, INCLUDE_DIRECITVE_TEXT_NEW_LINE=37, INCLUDE_FILE=38;
	public static final int
		RULE_preprocessor = 0, RULE_line = 1, RULE_text = 2, RULE_codeLine = 3, 
		RULE_directive = 4, RULE_include_file = 5, RULE_directive_text = 6, RULE_preprocessor_expression = 7, 
		RULE_preprocessor_item = 8;
	public static final String[] ruleNames = {
		"preprocessor", "line", "text", "codeLine", "directive", "include_file", 
		"directive_text", "preprocessor_expression", "preprocessor_item"
	};

	private static final String[] _LITERAL_NAMES = {
		null, null, null, null, null, null, null, null, null, null, "'+'", "'-'", 
		null, null, null, null, null, null, null, null, "'!'", "'('", "')'", "'='", 
		"'<>'", null, null, "'<'", "'>'", "'<='", "'>='"
	};
	private static final String[] _SYMBOLIC_NAMES = {
		null, "WS", "INCLUDE", "INCLUDEPP", "SHARP", "CODE", "NEW_LINE", "PRAGMA", 
		"DEFINE", "DEFINED", "ADD", "SUB", "IF", "ELIF", "ELSE", "UNDEF", "IFDEF", 
		"IFNDEF", "ENDIF", "ERROR", "BANG", "LPAREN", "RPAREN", "EQUAL", "NOTEQUAL", 
		"AND", "OR", "LT", "GT", "LE", "GE", "DIRECTIVE_WHITESPACES", "DIRECTIVE_STRING", 
		"CONDITIONAL_SYMBOL", "DECIMAL_LITERAL", "FLOAT", "TEXT", "INCLUDE_DIRECITVE_TEXT_NEW_LINE", 
		"INCLUDE_FILE"
	};
	public static final Vocabulary VOCABULARY = new VocabularyImpl(_LITERAL_NAMES, _SYMBOLIC_NAMES);

	/**
	 * @deprecated Use {@link #VOCABULARY} instead.
	 */
	@Deprecated
	public static final String[] tokenNames;
	static {
		tokenNames = new String[_SYMBOLIC_NAMES.length];
		for (int i = 0; i < tokenNames.length; i++) {
			tokenNames[i] = VOCABULARY.getLiteralName(i);
			if (tokenNames[i] == null) {
				tokenNames[i] = VOCABULARY.getSymbolicName(i);
			}

			if (tokenNames[i] == null) {
				tokenNames[i] = "<INVALID>";
			}
		}
	}

	@Override
	@Deprecated
	public String[] getTokenNames() {
		return tokenNames;
	}

	@Override

	public Vocabulary getVocabulary() {
		return VOCABULARY;
	}

	@Override
	public String getGrammarFileName() { return "TibboBasicPreprocessorParser.g4"; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public ATN getATN() { return _ATN; }

	public TibboBasicPreprocessorParser(TokenStream input) {
		super(input);
		_interp = new ParserATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}
	public static class PreprocessorContext extends ParserRuleContext {
		public TerminalNode EOF() { return getToken(TibboBasicPreprocessorParser.EOF, 0); }
		public List<LineContext> line() {
			return getRuleContexts(LineContext.class);
		}
		public LineContext line(int i) {
			return getRuleContext(LineContext.class,i);
		}
		public List<TerminalNode> NEW_LINE() { return getTokens(TibboBasicPreprocessorParser.NEW_LINE); }
		public TerminalNode NEW_LINE(int i) {
			return getToken(TibboBasicPreprocessorParser.NEW_LINE, i);
		}
		public PreprocessorContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_preprocessor; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterPreprocessor(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitPreprocessor(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitPreprocessor(this);
			else return visitor.visitChildren(this);
		}
	}

	public final PreprocessorContext preprocessor() throws RecognitionException {
		PreprocessorContext _localctx = new PreprocessorContext(_ctx, getState());
		enterRule(_localctx, 0, RULE_preprocessor);
		int _la;
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(21);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,0,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					{
					{
					setState(18);
					line();
					}
					} 
				}
				setState(23);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,0,_ctx);
			}
			setState(31);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,2,_ctx) ) {
			case 1:
				{
				setState(27);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==NEW_LINE) {
					{
					{
					setState(24);
					match(NEW_LINE);
					}
					}
					setState(29);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				}
				break;
			case 2:
				{
				setState(30);
				match(EOF);
				}
				break;
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class LineContext extends ParserRuleContext {
		public TextContext text() {
			return getRuleContext(TextContext.class,0);
		}
		public List<TerminalNode> NEW_LINE() { return getTokens(TibboBasicPreprocessorParser.NEW_LINE); }
		public TerminalNode NEW_LINE(int i) {
			return getToken(TibboBasicPreprocessorParser.NEW_LINE, i);
		}
		public LineContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_line; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterLine(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitLine(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitLine(this);
			else return visitor.visitChildren(this);
		}
	}

	public final LineContext line() throws RecognitionException {
		LineContext _localctx = new LineContext(_ctx, getState());
		enterRule(_localctx, 2, RULE_line);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(36);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==NEW_LINE) {
				{
				{
				setState(33);
				match(NEW_LINE);
				}
				}
				setState(38);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(39);
			text();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class TextContext extends ParserRuleContext {
		public Include_fileContext include_file() {
			return getRuleContext(Include_fileContext.class,0);
		}
		public DirectiveContext directive() {
			return getRuleContext(DirectiveContext.class,0);
		}
		public CodeLineContext codeLine() {
			return getRuleContext(CodeLineContext.class,0);
		}
		public TextContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_text; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterText(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitText(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitText(this);
			else return visitor.visitChildren(this);
		}
	}

	public final TextContext text() throws RecognitionException {
		TextContext _localctx = new TextContext(_ctx, getState());
		enterRule(_localctx, 4, RULE_text);
		try {
			setState(44);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case INCLUDE:
			case INCLUDEPP:
				enterOuterAlt(_localctx, 1);
				{
				setState(41);
				include_file();
				}
				break;
			case SHARP:
				enterOuterAlt(_localctx, 2);
				{
				setState(42);
				directive();
				}
				break;
			case CODE:
				enterOuterAlt(_localctx, 3);
				{
				setState(43);
				codeLine();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class CodeLineContext extends ParserRuleContext {
		public TerminalNode CODE() { return getToken(TibboBasicPreprocessorParser.CODE, 0); }
		public CodeLineContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_codeLine; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterCodeLine(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitCodeLine(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitCodeLine(this);
			else return visitor.visitChildren(this);
		}
	}

	public final CodeLineContext codeLine() throws RecognitionException {
		CodeLineContext _localctx = new CodeLineContext(_ctx, getState());
		enterRule(_localctx, 6, RULE_codeLine);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(46);
			match(CODE);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class DirectiveContext extends ParserRuleContext {
		public DirectiveContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_directive; }
	 
		public DirectiveContext() { }
		public void copyFrom(DirectiveContext ctx) {
			super.copyFrom(ctx);
		}
	}
	public static class PreprocessorDefContext extends DirectiveContext {
		public TerminalNode SHARP() { return getToken(TibboBasicPreprocessorParser.SHARP, 0); }
		public TerminalNode IFDEF() { return getToken(TibboBasicPreprocessorParser.IFDEF, 0); }
		public TerminalNode CONDITIONAL_SYMBOL() { return getToken(TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL, 0); }
		public TerminalNode IFNDEF() { return getToken(TibboBasicPreprocessorParser.IFNDEF, 0); }
		public PreprocessorDefContext(DirectiveContext ctx) { copyFrom(ctx); }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterPreprocessorDef(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitPreprocessorDef(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitPreprocessorDef(this);
			else return visitor.visitChildren(this);
		}
	}
	public static class PreprocessorErrorContext extends DirectiveContext {
		public TerminalNode SHARP() { return getToken(TibboBasicPreprocessorParser.SHARP, 0); }
		public TerminalNode ERROR() { return getToken(TibboBasicPreprocessorParser.ERROR, 0); }
		public Directive_textContext directive_text() {
			return getRuleContext(Directive_textContext.class,0);
		}
		public PreprocessorErrorContext(DirectiveContext ctx) { copyFrom(ctx); }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterPreprocessorError(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitPreprocessorError(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitPreprocessorError(this);
			else return visitor.visitChildren(this);
		}
	}
	public static class PreprocessorUndefContext extends DirectiveContext {
		public TerminalNode SHARP() { return getToken(TibboBasicPreprocessorParser.SHARP, 0); }
		public TerminalNode UNDEF() { return getToken(TibboBasicPreprocessorParser.UNDEF, 0); }
		public TerminalNode CONDITIONAL_SYMBOL() { return getToken(TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL, 0); }
		public PreprocessorUndefContext(DirectiveContext ctx) { copyFrom(ctx); }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterPreprocessorUndef(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitPreprocessorUndef(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitPreprocessorUndef(this);
			else return visitor.visitChildren(this);
		}
	}
	public static class PreprocessorConditionalContext extends DirectiveContext {
		public TerminalNode SHARP() { return getToken(TibboBasicPreprocessorParser.SHARP, 0); }
		public TerminalNode IF() { return getToken(TibboBasicPreprocessorParser.IF, 0); }
		public Preprocessor_expressionContext preprocessor_expression() {
			return getRuleContext(Preprocessor_expressionContext.class,0);
		}
		public TerminalNode ELIF() { return getToken(TibboBasicPreprocessorParser.ELIF, 0); }
		public TerminalNode ELSE() { return getToken(TibboBasicPreprocessorParser.ELSE, 0); }
		public PreprocessorConditionalContext(DirectiveContext ctx) { copyFrom(ctx); }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterPreprocessorConditional(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitPreprocessorConditional(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitPreprocessorConditional(this);
			else return visitor.visitChildren(this);
		}
	}
	public static class PreprocessorPragmaContext extends DirectiveContext {
		public TerminalNode SHARP() { return getToken(TibboBasicPreprocessorParser.SHARP, 0); }
		public TerminalNode PRAGMA() { return getToken(TibboBasicPreprocessorParser.PRAGMA, 0); }
		public Directive_textContext directive_text() {
			return getRuleContext(Directive_textContext.class,0);
		}
		public PreprocessorPragmaContext(DirectiveContext ctx) { copyFrom(ctx); }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterPreprocessorPragma(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitPreprocessorPragma(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitPreprocessorPragma(this);
			else return visitor.visitChildren(this);
		}
	}
	public static class PreprocessorDefineContext extends DirectiveContext {
		public TerminalNode SHARP() { return getToken(TibboBasicPreprocessorParser.SHARP, 0); }
		public TerminalNode DEFINE() { return getToken(TibboBasicPreprocessorParser.DEFINE, 0); }
		public TerminalNode CONDITIONAL_SYMBOL() { return getToken(TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL, 0); }
		public Directive_textContext directive_text() {
			return getRuleContext(Directive_textContext.class,0);
		}
		public PreprocessorDefineContext(DirectiveContext ctx) { copyFrom(ctx); }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterPreprocessorDefine(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitPreprocessorDefine(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitPreprocessorDefine(this);
			else return visitor.visitChildren(this);
		}
	}
	public static class PreprocessorEndConditionalContext extends DirectiveContext {
		public TerminalNode SHARP() { return getToken(TibboBasicPreprocessorParser.SHARP, 0); }
		public TerminalNode ENDIF() { return getToken(TibboBasicPreprocessorParser.ENDIF, 0); }
		public PreprocessorEndConditionalContext(DirectiveContext ctx) { copyFrom(ctx); }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterPreprocessorEndConditional(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitPreprocessorEndConditional(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitPreprocessorEndConditional(this);
			else return visitor.visitChildren(this);
		}
	}

	public final DirectiveContext directive() throws RecognitionException {
		DirectiveContext _localctx = new DirectiveContext(_ctx, getState());
		enterRule(_localctx, 8, RULE_directive);
		int _la;
		try {
			setState(79);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,6,_ctx) ) {
			case 1:
				_localctx = new PreprocessorConditionalContext(_localctx);
				enterOuterAlt(_localctx, 1);
				{
				setState(48);
				match(SHARP);
				setState(49);
				match(IF);
				setState(50);
				preprocessor_expression(0);
				}
				break;
			case 2:
				_localctx = new PreprocessorConditionalContext(_localctx);
				enterOuterAlt(_localctx, 2);
				{
				setState(51);
				match(SHARP);
				setState(52);
				match(ELIF);
				setState(53);
				preprocessor_expression(0);
				}
				break;
			case 3:
				_localctx = new PreprocessorConditionalContext(_localctx);
				enterOuterAlt(_localctx, 3);
				{
				setState(54);
				match(SHARP);
				setState(55);
				match(ELSE);
				}
				break;
			case 4:
				_localctx = new PreprocessorEndConditionalContext(_localctx);
				enterOuterAlt(_localctx, 4);
				{
				setState(56);
				match(SHARP);
				setState(57);
				match(ENDIF);
				}
				break;
			case 5:
				_localctx = new PreprocessorDefContext(_localctx);
				enterOuterAlt(_localctx, 5);
				{
				setState(58);
				match(SHARP);
				setState(59);
				match(IFDEF);
				setState(60);
				match(CONDITIONAL_SYMBOL);
				}
				break;
			case 6:
				_localctx = new PreprocessorDefContext(_localctx);
				enterOuterAlt(_localctx, 6);
				{
				setState(61);
				match(SHARP);
				setState(62);
				match(IFNDEF);
				setState(63);
				match(CONDITIONAL_SYMBOL);
				}
				break;
			case 7:
				_localctx = new PreprocessorUndefContext(_localctx);
				enterOuterAlt(_localctx, 7);
				{
				setState(64);
				match(SHARP);
				setState(65);
				match(UNDEF);
				setState(66);
				match(CONDITIONAL_SYMBOL);
				}
				break;
			case 8:
				_localctx = new PreprocessorPragmaContext(_localctx);
				enterOuterAlt(_localctx, 8);
				{
				setState(67);
				match(SHARP);
				setState(68);
				match(PRAGMA);
				setState(69);
				directive_text();
				}
				break;
			case 9:
				_localctx = new PreprocessorErrorContext(_localctx);
				enterOuterAlt(_localctx, 9);
				{
				setState(70);
				match(SHARP);
				setState(71);
				match(ERROR);
				setState(72);
				directive_text();
				}
				break;
			case 10:
				_localctx = new PreprocessorDefineContext(_localctx);
				enterOuterAlt(_localctx, 10);
				{
				setState(73);
				match(SHARP);
				setState(74);
				match(DEFINE);
				setState(75);
				match(CONDITIONAL_SYMBOL);
				setState(77);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if (_la==TEXT) {
					{
					setState(76);
					directive_text();
					}
				}

				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class Include_fileContext extends ParserRuleContext {
		public Include_fileContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_include_file; }
	 
		public Include_fileContext() { }
		public void copyFrom(Include_fileContext ctx) {
			super.copyFrom(ctx);
		}
	}
	public static class PreprocessorIncludeContext extends Include_fileContext {
		public TerminalNode INCLUDE_FILE() { return getToken(TibboBasicPreprocessorParser.INCLUDE_FILE, 0); }
		public TerminalNode INCLUDE() { return getToken(TibboBasicPreprocessorParser.INCLUDE, 0); }
		public TerminalNode INCLUDEPP() { return getToken(TibboBasicPreprocessorParser.INCLUDEPP, 0); }
		public PreprocessorIncludeContext(Include_fileContext ctx) { copyFrom(ctx); }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterPreprocessorInclude(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitPreprocessorInclude(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitPreprocessorInclude(this);
			else return visitor.visitChildren(this);
		}
	}

	public final Include_fileContext include_file() throws RecognitionException {
		Include_fileContext _localctx = new Include_fileContext(_ctx, getState());
		enterRule(_localctx, 10, RULE_include_file);
		int _la;
		try {
			_localctx = new PreprocessorIncludeContext(_localctx);
			enterOuterAlt(_localctx, 1);
			{
			setState(81);
			_la = _input.LA(1);
			if ( !(_la==INCLUDE || _la==INCLUDEPP) ) {
			_errHandler.recoverInline(this);
			}
			else {
				if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
				_errHandler.reportMatch(this);
				consume();
			}
			setState(82);
			match(INCLUDE_FILE);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class Directive_textContext extends ParserRuleContext {
		public List<TerminalNode> TEXT() { return getTokens(TibboBasicPreprocessorParser.TEXT); }
		public TerminalNode TEXT(int i) {
			return getToken(TibboBasicPreprocessorParser.TEXT, i);
		}
		public Directive_textContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_directive_text; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterDirective_text(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitDirective_text(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitDirective_text(this);
			else return visitor.visitChildren(this);
		}
	}

	public final Directive_textContext directive_text() throws RecognitionException {
		Directive_textContext _localctx = new Directive_textContext(_ctx, getState());
		enterRule(_localctx, 12, RULE_directive_text);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(85); 
			_errHandler.sync(this);
			_la = _input.LA(1);
			do {
				{
				{
				setState(84);
				match(TEXT);
				}
				}
				setState(87); 
				_errHandler.sync(this);
				_la = _input.LA(1);
			} while ( _la==TEXT );
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class Preprocessor_expressionContext extends ParserRuleContext {
		public Preprocessor_expressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_preprocessor_expression; }
	 
		public Preprocessor_expressionContext() { }
		public void copyFrom(Preprocessor_expressionContext ctx) {
			super.copyFrom(ctx);
		}
	}
	public static class PreprocessorBinaryContext extends Preprocessor_expressionContext {
		public Token op;
		public List<Preprocessor_itemContext> preprocessor_item() {
			return getRuleContexts(Preprocessor_itemContext.class);
		}
		public Preprocessor_itemContext preprocessor_item(int i) {
			return getRuleContext(Preprocessor_itemContext.class,i);
		}
		public TerminalNode EQUAL() { return getToken(TibboBasicPreprocessorParser.EQUAL, 0); }
		public TerminalNode NOTEQUAL() { return getToken(TibboBasicPreprocessorParser.NOTEQUAL, 0); }
		public TerminalNode LT() { return getToken(TibboBasicPreprocessorParser.LT, 0); }
		public TerminalNode GT() { return getToken(TibboBasicPreprocessorParser.GT, 0); }
		public TerminalNode LE() { return getToken(TibboBasicPreprocessorParser.LE, 0); }
		public TerminalNode GE() { return getToken(TibboBasicPreprocessorParser.GE, 0); }
		public List<Preprocessor_expressionContext> preprocessor_expression() {
			return getRuleContexts(Preprocessor_expressionContext.class);
		}
		public Preprocessor_expressionContext preprocessor_expression(int i) {
			return getRuleContext(Preprocessor_expressionContext.class,i);
		}
		public TerminalNode AND() { return getToken(TibboBasicPreprocessorParser.AND, 0); }
		public TerminalNode OR() { return getToken(TibboBasicPreprocessorParser.OR, 0); }
		public PreprocessorBinaryContext(Preprocessor_expressionContext ctx) { copyFrom(ctx); }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterPreprocessorBinary(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitPreprocessorBinary(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitPreprocessorBinary(this);
			else return visitor.visitChildren(this);
		}
	}
	public static class PreprocessorConstantContext extends Preprocessor_expressionContext {
		public TerminalNode DECIMAL_LITERAL() { return getToken(TibboBasicPreprocessorParser.DECIMAL_LITERAL, 0); }
		public TerminalNode DIRECTIVE_STRING() { return getToken(TibboBasicPreprocessorParser.DIRECTIVE_STRING, 0); }
		public PreprocessorConstantContext(Preprocessor_expressionContext ctx) { copyFrom(ctx); }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterPreprocessorConstant(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitPreprocessorConstant(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitPreprocessorConstant(this);
			else return visitor.visitChildren(this);
		}
	}
	public static class PreprocessorConditionalSymbolContext extends Preprocessor_expressionContext {
		public TerminalNode CONDITIONAL_SYMBOL() { return getToken(TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL, 0); }
		public TerminalNode LPAREN() { return getToken(TibboBasicPreprocessorParser.LPAREN, 0); }
		public Preprocessor_expressionContext preprocessor_expression() {
			return getRuleContext(Preprocessor_expressionContext.class,0);
		}
		public TerminalNode RPAREN() { return getToken(TibboBasicPreprocessorParser.RPAREN, 0); }
		public PreprocessorConditionalSymbolContext(Preprocessor_expressionContext ctx) { copyFrom(ctx); }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterPreprocessorConditionalSymbol(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitPreprocessorConditionalSymbol(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitPreprocessorConditionalSymbol(this);
			else return visitor.visitChildren(this);
		}
	}

	public final Preprocessor_expressionContext preprocessor_expression() throws RecognitionException {
		return preprocessor_expression(0);
	}

	private Preprocessor_expressionContext preprocessor_expression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		Preprocessor_expressionContext _localctx = new Preprocessor_expressionContext(_ctx, _parentState);
		Preprocessor_expressionContext _prevctx = _localctx;
		int _startState = 14;
		enterRecursionRule(_localctx, 14, RULE_preprocessor_expression, _p);
		int _la;
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(107);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,9,_ctx) ) {
			case 1:
				{
				_localctx = new PreprocessorConstantContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;

				setState(90);
				match(DECIMAL_LITERAL);
				}
				break;
			case 2:
				{
				_localctx = new PreprocessorConstantContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				setState(91);
				match(DIRECTIVE_STRING);
				}
				break;
			case 3:
				{
				_localctx = new PreprocessorConditionalSymbolContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				setState(92);
				match(CONDITIONAL_SYMBOL);
				setState(97);
				_errHandler.sync(this);
				switch ( getInterpreter().adaptivePredict(_input,8,_ctx) ) {
				case 1:
					{
					setState(93);
					match(LPAREN);
					setState(94);
					preprocessor_expression(0);
					setState(95);
					match(RPAREN);
					}
					break;
				}
				}
				break;
			case 4:
				{
				_localctx = new PreprocessorBinaryContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				setState(99);
				preprocessor_item();
				setState(100);
				((PreprocessorBinaryContext)_localctx).op = _input.LT(1);
				_la = _input.LA(1);
				if ( !(_la==EQUAL || _la==NOTEQUAL) ) {
					((PreprocessorBinaryContext)_localctx).op = (Token)_errHandler.recoverInline(this);
				}
				else {
					if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
					_errHandler.reportMatch(this);
					consume();
				}
				setState(101);
				preprocessor_item();
				}
				break;
			case 5:
				{
				_localctx = new PreprocessorBinaryContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				setState(103);
				preprocessor_item();
				setState(104);
				((PreprocessorBinaryContext)_localctx).op = _input.LT(1);
				_la = _input.LA(1);
				if ( !((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << LT) | (1L << GT) | (1L << LE) | (1L << GE))) != 0)) ) {
					((PreprocessorBinaryContext)_localctx).op = (Token)_errHandler.recoverInline(this);
				}
				else {
					if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
					_errHandler.reportMatch(this);
					consume();
				}
				setState(105);
				preprocessor_item();
				}
				break;
			}
			_ctx.stop = _input.LT(-1);
			setState(117);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,11,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) triggerExitRuleEvent();
					_prevctx = _localctx;
					{
					setState(115);
					_errHandler.sync(this);
					switch ( getInterpreter().adaptivePredict(_input,10,_ctx) ) {
					case 1:
						{
						_localctx = new PreprocessorBinaryContext(new Preprocessor_expressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_preprocessor_expression);
						setState(109);
						if (!(precpred(_ctx, 3))) throw new FailedPredicateException(this, "precpred(_ctx, 3)");
						setState(110);
						((PreprocessorBinaryContext)_localctx).op = match(AND);
						setState(111);
						preprocessor_expression(4);
						}
						break;
					case 2:
						{
						_localctx = new PreprocessorBinaryContext(new Preprocessor_expressionContext(_parentctx, _parentState));
						pushNewRecursionContext(_localctx, _startState, RULE_preprocessor_expression);
						setState(112);
						if (!(precpred(_ctx, 2))) throw new FailedPredicateException(this, "precpred(_ctx, 2)");
						setState(113);
						((PreprocessorBinaryContext)_localctx).op = match(OR);
						setState(114);
						preprocessor_expression(3);
						}
						break;
					}
					} 
				}
				setState(119);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,11,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			unrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public static class Preprocessor_itemContext extends ParserRuleContext {
		public TerminalNode CONDITIONAL_SYMBOL() { return getToken(TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL, 0); }
		public TerminalNode DECIMAL_LITERAL() { return getToken(TibboBasicPreprocessorParser.DECIMAL_LITERAL, 0); }
		public TerminalNode DIRECTIVE_STRING() { return getToken(TibboBasicPreprocessorParser.DIRECTIVE_STRING, 0); }
		public Preprocessor_itemContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_preprocessor_item; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).enterPreprocessor_item(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicPreprocessorParserListener ) ((TibboBasicPreprocessorParserListener)listener).exitPreprocessor_item(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) return ((TibboBasicPreprocessorParserVisitor<? extends T>)visitor).visitPreprocessor_item(this);
			else return visitor.visitChildren(this);
		}
	}

	public final Preprocessor_itemContext preprocessor_item() throws RecognitionException {
		Preprocessor_itemContext _localctx = new Preprocessor_itemContext(_ctx, getState());
		enterRule(_localctx, 16, RULE_preprocessor_item);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(120);
			_la = _input.LA(1);
			if ( !((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << DIRECTIVE_STRING) | (1L << CONDITIONAL_SYMBOL) | (1L << DECIMAL_LITERAL))) != 0)) ) {
			_errHandler.recoverInline(this);
			}
			else {
				if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
				_errHandler.reportMatch(this);
				consume();
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public boolean sempred(RuleContext _localctx, int ruleIndex, int predIndex) {
		switch (ruleIndex) {
		case 7:
			return preprocessor_expression_sempred((Preprocessor_expressionContext)_localctx, predIndex);
		}
		return true;
	}
	private boolean preprocessor_expression_sempred(Preprocessor_expressionContext _localctx, int predIndex) {
		switch (predIndex) {
		case 0:
			return precpred(_ctx, 3);
		case 1:
			return precpred(_ctx, 2);
		}
		return true;
	}

	public static final String _serializedATN =
		"\3\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964\3(}\4\2\t\2\4\3\t\3"+
		"\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4\b\t\b\4\t\t\t\4\n\t\n\3\2\7\2\26\n"+
		"\2\f\2\16\2\31\13\2\3\2\7\2\34\n\2\f\2\16\2\37\13\2\3\2\5\2\"\n\2\3\3"+
		"\7\3%\n\3\f\3\16\3(\13\3\3\3\3\3\3\4\3\4\3\4\5\4/\n\4\3\5\3\5\3\6\3\6"+
		"\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3"+
		"\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\5\6P\n\6\5\6R\n\6\3\7\3\7\3\7\3"+
		"\b\6\bX\n\b\r\b\16\bY\3\t\3\t\3\t\3\t\3\t\3\t\3\t\3\t\5\td\n\t\3\t\3\t"+
		"\3\t\3\t\3\t\3\t\3\t\3\t\5\tn\n\t\3\t\3\t\3\t\3\t\3\t\3\t\7\tv\n\t\f\t"+
		"\16\ty\13\t\3\n\3\n\3\n\2\3\20\13\2\4\6\b\n\f\16\20\22\2\6\3\2\4\5\3\2"+
		"\31\32\3\2\35 \3\2\"$\2\u008b\2\27\3\2\2\2\4&\3\2\2\2\6.\3\2\2\2\b\60"+
		"\3\2\2\2\nQ\3\2\2\2\fS\3\2\2\2\16W\3\2\2\2\20m\3\2\2\2\22z\3\2\2\2\24"+
		"\26\5\4\3\2\25\24\3\2\2\2\26\31\3\2\2\2\27\25\3\2\2\2\27\30\3\2\2\2\30"+
		"!\3\2\2\2\31\27\3\2\2\2\32\34\7\b\2\2\33\32\3\2\2\2\34\37\3\2\2\2\35\33"+
		"\3\2\2\2\35\36\3\2\2\2\36\"\3\2\2\2\37\35\3\2\2\2 \"\7\2\2\3!\35\3\2\2"+
		"\2! \3\2\2\2\"\3\3\2\2\2#%\7\b\2\2$#\3\2\2\2%(\3\2\2\2&$\3\2\2\2&\'\3"+
		"\2\2\2\')\3\2\2\2(&\3\2\2\2)*\5\6\4\2*\5\3\2\2\2+/\5\f\7\2,/\5\n\6\2-"+
		"/\5\b\5\2.+\3\2\2\2.,\3\2\2\2.-\3\2\2\2/\7\3\2\2\2\60\61\7\7\2\2\61\t"+
		"\3\2\2\2\62\63\7\6\2\2\63\64\7\16\2\2\64R\5\20\t\2\65\66\7\6\2\2\66\67"+
		"\7\17\2\2\67R\5\20\t\289\7\6\2\29R\7\20\2\2:;\7\6\2\2;R\7\24\2\2<=\7\6"+
		"\2\2=>\7\22\2\2>R\7#\2\2?@\7\6\2\2@A\7\23\2\2AR\7#\2\2BC\7\6\2\2CD\7\21"+
		"\2\2DR\7#\2\2EF\7\6\2\2FG\7\t\2\2GR\5\16\b\2HI\7\6\2\2IJ\7\25\2\2JR\5"+
		"\16\b\2KL\7\6\2\2LM\7\n\2\2MO\7#\2\2NP\5\16\b\2ON\3\2\2\2OP\3\2\2\2PR"+
		"\3\2\2\2Q\62\3\2\2\2Q\65\3\2\2\2Q8\3\2\2\2Q:\3\2\2\2Q<\3\2\2\2Q?\3\2\2"+
		"\2QB\3\2\2\2QE\3\2\2\2QH\3\2\2\2QK\3\2\2\2R\13\3\2\2\2ST\t\2\2\2TU\7("+
		"\2\2U\r\3\2\2\2VX\7&\2\2WV\3\2\2\2XY\3\2\2\2YW\3\2\2\2YZ\3\2\2\2Z\17\3"+
		"\2\2\2[\\\b\t\1\2\\n\7$\2\2]n\7\"\2\2^c\7#\2\2_`\7\27\2\2`a\5\20\t\2a"+
		"b\7\30\2\2bd\3\2\2\2c_\3\2\2\2cd\3\2\2\2dn\3\2\2\2ef\5\22\n\2fg\t\3\2"+
		"\2gh\5\22\n\2hn\3\2\2\2ij\5\22\n\2jk\t\4\2\2kl\5\22\n\2ln\3\2\2\2m[\3"+
		"\2\2\2m]\3\2\2\2m^\3\2\2\2me\3\2\2\2mi\3\2\2\2nw\3\2\2\2op\f\5\2\2pq\7"+
		"\33\2\2qv\5\20\t\6rs\f\4\2\2st\7\34\2\2tv\5\20\t\5uo\3\2\2\2ur\3\2\2\2"+
		"vy\3\2\2\2wu\3\2\2\2wx\3\2\2\2x\21\3\2\2\2yw\3\2\2\2z{\t\5\2\2{\23\3\2"+
		"\2\2\16\27\35!&.OQYcmuw";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}