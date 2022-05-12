// Generated from com\moonshine\basicgrammar\TibboBasicParser.g4 by ANTLR 4.7.1
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
public class TibboBasicParser extends Parser {
	static { RuntimeMetaData.checkVersion("4.7.1", RuntimeMetaData.VERSION); }

	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		OBJECT=1, AND=2, AS=3, BOOLEAN=4, REAL=5, BYREF=6, BYTE=7, BYVAL=8, CASE=9, 
		CASE_ELSE=10, CHAR=11, CONST=12, COUNTOF=13, DECLARE=14, DIM=15, DO=16, 
		DWORD=17, ELSE=18, ELIF=19, END=20, ELSEIF=21, ENUM=22, END_ENUM=23, END_FUNCTION=24, 
		END_IF=25, END_PROPERTY=26, END_SELECT=27, END_SUB=28, END_TYPE=29, END_WITH=30, 
		EVENT=31, EXIT_DO=32, EXIT_FOR=33, EXIT_FUNCTION=34, EXIT_PROPERTY=35, 
		EXIT_SUB=36, EXIT_WHILE=37, FALSE=38, FLOAT=39, FOR=40, FUNCTION=41, GET=42, 
		GOTO=43, IF=44, IFDEF=45, IFNDEF=46, INCLUDE=47, INCLUDEPP=48, INTEGER=49, 
		LONG=50, LOOP=51, MOD=52, NEXT=53, NOT=54, OR=55, PROPERTY=56, PUBLIC=57, 
		SELECT=58, SET=59, SHL=60, SHORT=61, SHR=62, SIZEOF=63, STEP=64, STRING=65, 
		SUB=66, THEN=67, TO=68, TRUE=69, TYPE=70, UNDEF=71, UNTIL=72, WEND=73, 
		WHILE=74, WORD=75, XOR=76, SHARP=77, STRINGLITERAL=78, TemplateStringLiteral=79, 
		HEXLITERAL=80, BINLITERAL=81, INTEGERLITERAL=82, DIV=83, EQ=84, GEQ=85, 
		GT=86, LEQ=87, LPAREN=88, LT=89, MINUS=90, MULT=91, NEQ=92, PLUS=93, RPAREN=94, 
		L_SQUARE_BRACKET=95, R_SQUARE_BRACKET=96, L_CURLY_BRACKET=97, R_CURLY_BRACKET=98, 
		NEWLINE=99, COMMENT=100, SINGLEQUOTE=101, COLON=102, SEMICOLON=103, COMMA=104, 
		DOT=105, BANG=106, UNDERSCORE=107, SYSCALL=108, WS=109, IDENTIFIER=110, 
		DIRECTIVE_INCLUDE=111, DIRECTIVE_INCLUDEPP=112, DIRECTIVE_DEFINE=113, 
		DIRECTIVE_IF=114, DIRECTIVE_ELIF=115, DIRECTIVE_ELSE=116, DIRECTIVE_UNDEF=117, 
		DIRECTIVE_IFDEF=118, DIRECTIVE_IFNDEF=119, DIRECTIVE_ENDIF=120, DIRECTIVE_ERROR=121, 
		DIRECTIVE_BANG=122, DIRECTIVE_LP=123, DIRECTIVE_RP=124, DIRECTIVE_EQUAL=125, 
		DIRECTIVE_NOTEQUAL=126, DIRECTIVE_AND=127, DIRECTIVE_OR=128, DIRECTIVE_LT=129, 
		DIRECTIVE_GT=130, DIRECTIVE_LE=131, DIRECTIVE_GE=132, DIRECTIVE_ID=133, 
		DIRECTIVE_DECIMAL_LITERAL=134, DIRECTIVE_FLOAT=135, DIRECTIVE_NEWLINE=136, 
		DIRECTIVE_SINGLE_COMMENT=137, DIRECTIVE_BACKSLASH_NEWLINE=138, DIRECTIVE_TEXT_NEWLINE=139, 
		DIRECTIVE_TEXT_BACKSLASH_NEWLINE=140, DIRECTIVE_TEXT_MULTI_COMMENT=141, 
		DIRECTIVE_TEXT_SINGLE_COMMENT=142, DIRECTIVE_TEXT=143, COMMENT2=144, WS2=145, 
		ANY=146, DOT2=147;
	public static final int
		RULE_startRule = 0, RULE_topLevelDeclaration = 1, RULE_includeStmt = 2, 
		RULE_includeppStmt = 3, RULE_block = 4, RULE_statement = 5, RULE_constStmt = 6, 
		RULE_constSubStmt = 7, RULE_declareVariableStmt = 8, RULE_declareSubStmt = 9, 
		RULE_declareFuncStmt = 10, RULE_doLoopStmt = 11, RULE_enumerationStmt = 12, 
		RULE_enumerationStmt_Constant = 13, RULE_exitStmt = 14, RULE_forNextStmt = 15, 
		RULE_functionStmt = 16, RULE_jumpStmt = 17, RULE_goToStmt = 18, RULE_ifThenElseStmt = 19, 
		RULE_ifConditionStmt = 20, RULE_propertyDefineStmt = 21, RULE_propertyDefineStmt_InStmt = 22, 
		RULE_propertyGetStmt = 23, RULE_propertySetStmt = 24, RULE_eventDeclaration = 25, 
		RULE_syscallDeclaration = 26, RULE_syscallDeclarationInner = 27, RULE_syscallInternalDeclarationInner = 28, 
		RULE_syscallInternalParamList = 29, RULE_paramInternal = 30, RULE_selectCaseStmt = 31, 
		RULE_sC_Case = 32, RULE_sC_Default = 33, RULE_sC_Cond = 34, RULE_subStmt = 35, 
		RULE_typeStmt = 36, RULE_typeStmtElement = 37, RULE_expression = 38, RULE_unaryExpression = 39, 
		RULE_unaryOperator = 40, RULE_postfixExpression = 41, RULE_postfix = 42, 
		RULE_primaryExpression = 43, RULE_variableStmt = 44, RULE_variableListStmt = 45, 
		RULE_variableListItem = 46, RULE_whileWendStmt = 47, RULE_objectDeclaration = 48, 
		RULE_argList = 49, RULE_arg = 50, RULE_paramList = 51, RULE_param = 52, 
		RULE_asTypeClause = 53, RULE_baseType = 54, RULE_complexType = 55, RULE_fieldLength = 56, 
		RULE_lineLabel = 57, RULE_literal = 58, RULE_arrayLiteral = 59, RULE_type = 60, 
		RULE_visibility = 61;
	public static final String[] ruleNames = {
		"startRule", "topLevelDeclaration", "includeStmt", "includeppStmt", "block", 
		"statement", "constStmt", "constSubStmt", "declareVariableStmt", "declareSubStmt", 
		"declareFuncStmt", "doLoopStmt", "enumerationStmt", "enumerationStmt_Constant", 
		"exitStmt", "forNextStmt", "functionStmt", "jumpStmt", "goToStmt", "ifThenElseStmt", 
		"ifConditionStmt", "propertyDefineStmt", "propertyDefineStmt_InStmt", 
		"propertyGetStmt", "propertySetStmt", "eventDeclaration", "syscallDeclaration", 
		"syscallDeclarationInner", "syscallInternalDeclarationInner", "syscallInternalParamList", 
		"paramInternal", "selectCaseStmt", "sC_Case", "sC_Default", "sC_Cond", 
		"subStmt", "typeStmt", "typeStmtElement", "expression", "unaryExpression", 
		"unaryOperator", "postfixExpression", "postfix", "primaryExpression", 
		"variableStmt", "variableListStmt", "variableListItem", "whileWendStmt", 
		"objectDeclaration", "argList", "arg", "paramList", "param", "asTypeClause", 
		"baseType", "complexType", "fieldLength", "lineLabel", "literal", "arrayLiteral", 
		"type", "visibility"
	};

	private static final String[] _LITERAL_NAMES = {
		null, null, null, null, null, null, null, null, null, null, null, null, 
		null, null, null, null, null, null, null, null, null, null, null, null, 
		null, null, null, null, null, null, null, null, null, null, null, null, 
		null, null, null, null, null, null, null, null, null, null, null, null, 
		null, null, null, null, null, null, null, null, null, null, null, null, 
		null, null, null, null, null, null, null, null, null, null, null, null, 
		null, null, null, null, null, null, null, null, null, null, null, null, 
		null, null, null, null, null, null, null, null, null, null, null, "'['", 
		"']'", "'{'", "'}'", null, null, null, null, "';'"
	};
	private static final String[] _SYMBOLIC_NAMES = {
		null, "OBJECT", "AND", "AS", "BOOLEAN", "REAL", "BYREF", "BYTE", "BYVAL", 
		"CASE", "CASE_ELSE", "CHAR", "CONST", "COUNTOF", "DECLARE", "DIM", "DO", 
		"DWORD", "ELSE", "ELIF", "END", "ELSEIF", "ENUM", "END_ENUM", "END_FUNCTION", 
		"END_IF", "END_PROPERTY", "END_SELECT", "END_SUB", "END_TYPE", "END_WITH", 
		"EVENT", "EXIT_DO", "EXIT_FOR", "EXIT_FUNCTION", "EXIT_PROPERTY", "EXIT_SUB", 
		"EXIT_WHILE", "FALSE", "FLOAT", "FOR", "FUNCTION", "GET", "GOTO", "IF", 
		"IFDEF", "IFNDEF", "INCLUDE", "INCLUDEPP", "INTEGER", "LONG", "LOOP", 
		"MOD", "NEXT", "NOT", "OR", "PROPERTY", "PUBLIC", "SELECT", "SET", "SHL", 
		"SHORT", "SHR", "SIZEOF", "STEP", "STRING", "SUB", "THEN", "TO", "TRUE", 
		"TYPE", "UNDEF", "UNTIL", "WEND", "WHILE", "WORD", "XOR", "SHARP", "STRINGLITERAL", 
		"TemplateStringLiteral", "HEXLITERAL", "BINLITERAL", "INTEGERLITERAL", 
		"DIV", "EQ", "GEQ", "GT", "LEQ", "LPAREN", "LT", "MINUS", "MULT", "NEQ", 
		"PLUS", "RPAREN", "L_SQUARE_BRACKET", "R_SQUARE_BRACKET", "L_CURLY_BRACKET", 
		"R_CURLY_BRACKET", "NEWLINE", "COMMENT", "SINGLEQUOTE", "COLON", "SEMICOLON", 
		"COMMA", "DOT", "BANG", "UNDERSCORE", "SYSCALL", "WS", "IDENTIFIER", "DIRECTIVE_INCLUDE", 
		"DIRECTIVE_INCLUDEPP", "DIRECTIVE_DEFINE", "DIRECTIVE_IF", "DIRECTIVE_ELIF", 
		"DIRECTIVE_ELSE", "DIRECTIVE_UNDEF", "DIRECTIVE_IFDEF", "DIRECTIVE_IFNDEF", 
		"DIRECTIVE_ENDIF", "DIRECTIVE_ERROR", "DIRECTIVE_BANG", "DIRECTIVE_LP", 
		"DIRECTIVE_RP", "DIRECTIVE_EQUAL", "DIRECTIVE_NOTEQUAL", "DIRECTIVE_AND", 
		"DIRECTIVE_OR", "DIRECTIVE_LT", "DIRECTIVE_GT", "DIRECTIVE_LE", "DIRECTIVE_GE", 
		"DIRECTIVE_ID", "DIRECTIVE_DECIMAL_LITERAL", "DIRECTIVE_FLOAT", "DIRECTIVE_NEWLINE", 
		"DIRECTIVE_SINGLE_COMMENT", "DIRECTIVE_BACKSLASH_NEWLINE", "DIRECTIVE_TEXT_NEWLINE", 
		"DIRECTIVE_TEXT_BACKSLASH_NEWLINE", "DIRECTIVE_TEXT_MULTI_COMMENT", "DIRECTIVE_TEXT_SINGLE_COMMENT", 
		"DIRECTIVE_TEXT", "COMMENT2", "WS2", "ANY", "DOT2"
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
	public String getGrammarFileName() { return "TibboBasicParser.g4"; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public ATN getATN() { return _ATN; }

	public TibboBasicParser(TokenStream input) {
		super(input);
		_interp = new ParserATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}
	public static class StartRuleContext extends ParserRuleContext {
		public TerminalNode EOF() { return getToken(TibboBasicParser.EOF, 0); }
		public List<TopLevelDeclarationContext> topLevelDeclaration() {
			return getRuleContexts(TopLevelDeclarationContext.class);
		}
		public TopLevelDeclarationContext topLevelDeclaration(int i) {
			return getRuleContext(TopLevelDeclarationContext.class,i);
		}
		public StartRuleContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_startRule; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterStartRule(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitStartRule(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitStartRule(this);
			else return visitor.visitChildren(this);
		}
	}

	public final StartRuleContext startRule() throws RecognitionException {
		StartRuleContext _localctx = new StartRuleContext(_ctx, getState());
		enterRule(_localctx, 0, RULE_startRule);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(127);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << OBJECT) | (1L << CONST) | (1L << DECLARE) | (1L << DIM) | (1L << ENUM) | (1L << EVENT) | (1L << FUNCTION) | (1L << INCLUDE) | (1L << INCLUDEPP) | (1L << PROPERTY) | (1L << PUBLIC))) != 0) || ((((_la - 66)) & ~0x3f) == 0 && ((1L << (_la - 66)) & ((1L << (SUB - 66)) | (1L << (TYPE - 66)) | (1L << (SYSCALL - 66)))) != 0)) {
				{
				{
				setState(124);
				topLevelDeclaration();
				}
				}
				setState(129);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(130);
			match(EOF);
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

	public static class TopLevelDeclarationContext extends ParserRuleContext {
		public IncludeStmtContext includeStmt() {
			return getRuleContext(IncludeStmtContext.class,0);
		}
		public IncludeppStmtContext includeppStmt() {
			return getRuleContext(IncludeppStmtContext.class,0);
		}
		public EnumerationStmtContext enumerationStmt() {
			return getRuleContext(EnumerationStmtContext.class,0);
		}
		public ConstStmtContext constStmt() {
			return getRuleContext(ConstStmtContext.class,0);
		}
		public DeclareSubStmtContext declareSubStmt() {
			return getRuleContext(DeclareSubStmtContext.class,0);
		}
		public DeclareFuncStmtContext declareFuncStmt() {
			return getRuleContext(DeclareFuncStmtContext.class,0);
		}
		public DeclareVariableStmtContext declareVariableStmt() {
			return getRuleContext(DeclareVariableStmtContext.class,0);
		}
		public VariableStmtContext variableStmt() {
			return getRuleContext(VariableStmtContext.class,0);
		}
		public SubStmtContext subStmt() {
			return getRuleContext(SubStmtContext.class,0);
		}
		public FunctionStmtContext functionStmt() {
			return getRuleContext(FunctionStmtContext.class,0);
		}
		public ObjectDeclarationContext objectDeclaration() {
			return getRuleContext(ObjectDeclarationContext.class,0);
		}
		public PropertyDefineStmtContext propertyDefineStmt() {
			return getRuleContext(PropertyDefineStmtContext.class,0);
		}
		public EventDeclarationContext eventDeclaration() {
			return getRuleContext(EventDeclarationContext.class,0);
		}
		public SyscallDeclarationContext syscallDeclaration() {
			return getRuleContext(SyscallDeclarationContext.class,0);
		}
		public TypeStmtContext typeStmt() {
			return getRuleContext(TypeStmtContext.class,0);
		}
		public TopLevelDeclarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_topLevelDeclaration; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterTopLevelDeclaration(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitTopLevelDeclaration(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitTopLevelDeclaration(this);
			else return visitor.visitChildren(this);
		}
	}

	public final TopLevelDeclarationContext topLevelDeclaration() throws RecognitionException {
		TopLevelDeclarationContext _localctx = new TopLevelDeclarationContext(_ctx, getState());
		enterRule(_localctx, 2, RULE_topLevelDeclaration);
		try {
			setState(147);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,1,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(132);
				includeStmt();
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(133);
				includeppStmt();
				}
				break;
			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(134);
				enumerationStmt();
				}
				break;
			case 4:
				enterOuterAlt(_localctx, 4);
				{
				setState(135);
				constStmt();
				}
				break;
			case 5:
				enterOuterAlt(_localctx, 5);
				{
				setState(136);
				declareSubStmt();
				}
				break;
			case 6:
				enterOuterAlt(_localctx, 6);
				{
				setState(137);
				declareFuncStmt();
				}
				break;
			case 7:
				enterOuterAlt(_localctx, 7);
				{
				setState(138);
				declareVariableStmt();
				}
				break;
			case 8:
				enterOuterAlt(_localctx, 8);
				{
				setState(139);
				variableStmt();
				}
				break;
			case 9:
				enterOuterAlt(_localctx, 9);
				{
				setState(140);
				subStmt();
				}
				break;
			case 10:
				enterOuterAlt(_localctx, 10);
				{
				setState(141);
				functionStmt();
				}
				break;
			case 11:
				enterOuterAlt(_localctx, 11);
				{
				setState(142);
				objectDeclaration();
				}
				break;
			case 12:
				enterOuterAlt(_localctx, 12);
				{
				setState(143);
				propertyDefineStmt();
				}
				break;
			case 13:
				enterOuterAlt(_localctx, 13);
				{
				setState(144);
				eventDeclaration();
				}
				break;
			case 14:
				enterOuterAlt(_localctx, 14);
				{
				setState(145);
				syscallDeclaration();
				}
				break;
			case 15:
				enterOuterAlt(_localctx, 15);
				{
				setState(146);
				typeStmt();
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

	public static class IncludeStmtContext extends ParserRuleContext {
		public TerminalNode INCLUDE() { return getToken(TibboBasicParser.INCLUDE, 0); }
		public TerminalNode STRINGLITERAL() { return getToken(TibboBasicParser.STRINGLITERAL, 0); }
		public IncludeStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_includeStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterIncludeStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitIncludeStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitIncludeStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final IncludeStmtContext includeStmt() throws RecognitionException {
		IncludeStmtContext _localctx = new IncludeStmtContext(_ctx, getState());
		enterRule(_localctx, 4, RULE_includeStmt);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(149);
			match(INCLUDE);
			setState(150);
			match(STRINGLITERAL);
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

	public static class IncludeppStmtContext extends ParserRuleContext {
		public TerminalNode INCLUDEPP() { return getToken(TibboBasicParser.INCLUDEPP, 0); }
		public TerminalNode STRINGLITERAL() { return getToken(TibboBasicParser.STRINGLITERAL, 0); }
		public IncludeppStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_includeppStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterIncludeppStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitIncludeppStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitIncludeppStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final IncludeppStmtContext includeppStmt() throws RecognitionException {
		IncludeppStmtContext _localctx = new IncludeppStmtContext(_ctx, getState());
		enterRule(_localctx, 6, RULE_includeppStmt);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(152);
			match(INCLUDEPP);
			setState(153);
			match(STRINGLITERAL);
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

	public static class BlockContext extends ParserRuleContext {
		public List<StatementContext> statement() {
			return getRuleContexts(StatementContext.class);
		}
		public StatementContext statement(int i) {
			return getRuleContext(StatementContext.class,i);
		}
		public List<LineLabelContext> lineLabel() {
			return getRuleContexts(LineLabelContext.class);
		}
		public LineLabelContext lineLabel(int i) {
			return getRuleContext(LineLabelContext.class,i);
		}
		public BlockContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_block; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterBlock(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitBlock(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitBlock(this);
			else return visitor.visitChildren(this);
		}
	}

	public final BlockContext block() throws RecognitionException {
		BlockContext _localctx = new BlockContext(_ctx, getState());
		enterRule(_localctx, 8, RULE_block);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(161);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << CONST) | (1L << DIM) | (1L << DO) | (1L << EXIT_DO) | (1L << EXIT_FOR) | (1L << EXIT_FUNCTION) | (1L << EXIT_PROPERTY) | (1L << EXIT_SUB) | (1L << EXIT_WHILE) | (1L << FALSE) | (1L << FOR) | (1L << GOTO) | (1L << IF) | (1L << NOT) | (1L << PUBLIC) | (1L << SELECT))) != 0) || ((((_la - 69)) & ~0x3f) == 0 && ((1L << (_la - 69)) & ((1L << (TRUE - 69)) | (1L << (WHILE - 69)) | (1L << (STRINGLITERAL - 69)) | (1L << (TemplateStringLiteral - 69)) | (1L << (HEXLITERAL - 69)) | (1L << (BINLITERAL - 69)) | (1L << (INTEGERLITERAL - 69)) | (1L << (LPAREN - 69)) | (1L << (MINUS - 69)) | (1L << (PLUS - 69)) | (1L << (IDENTIFIER - 69)))) != 0)) {
				{
				{
				setState(156);
				_errHandler.sync(this);
				switch ( getInterpreter().adaptivePredict(_input,2,_ctx) ) {
				case 1:
					{
					setState(155);
					lineLabel();
					}
					break;
				}
				setState(158);
				statement();
				}
				}
				setState(163);
				_errHandler.sync(this);
				_la = _input.LA(1);
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

	public static class StatementContext extends ParserRuleContext {
		public LineLabelContext lineLabel() {
			return getRuleContext(LineLabelContext.class,0);
		}
		public ConstStmtContext constStmt() {
			return getRuleContext(ConstStmtContext.class,0);
		}
		public DoLoopStmtContext doLoopStmt() {
			return getRuleContext(DoLoopStmtContext.class,0);
		}
		public ForNextStmtContext forNextStmt() {
			return getRuleContext(ForNextStmtContext.class,0);
		}
		public JumpStmtContext jumpStmt() {
			return getRuleContext(JumpStmtContext.class,0);
		}
		public IfThenElseStmtContext ifThenElseStmt() {
			return getRuleContext(IfThenElseStmtContext.class,0);
		}
		public SelectCaseStmtContext selectCaseStmt() {
			return getRuleContext(SelectCaseStmtContext.class,0);
		}
		public VariableStmtContext variableStmt() {
			return getRuleContext(VariableStmtContext.class,0);
		}
		public WhileWendStmtContext whileWendStmt() {
			return getRuleContext(WhileWendStmtContext.class,0);
		}
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public StatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_statement; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterStatement(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitStatement(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitStatement(this);
			else return visitor.visitChildren(this);
		}
	}

	public final StatementContext statement() throws RecognitionException {
		StatementContext _localctx = new StatementContext(_ctx, getState());
		enterRule(_localctx, 10, RULE_statement);
		try {
			setState(174);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,4,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(164);
				lineLabel();
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(165);
				constStmt();
				}
				break;
			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(166);
				doLoopStmt();
				}
				break;
			case 4:
				enterOuterAlt(_localctx, 4);
				{
				setState(167);
				forNextStmt();
				}
				break;
			case 5:
				enterOuterAlt(_localctx, 5);
				{
				setState(168);
				jumpStmt();
				}
				break;
			case 6:
				enterOuterAlt(_localctx, 6);
				{
				setState(169);
				ifThenElseStmt();
				}
				break;
			case 7:
				enterOuterAlt(_localctx, 7);
				{
				setState(170);
				selectCaseStmt();
				}
				break;
			case 8:
				enterOuterAlt(_localctx, 8);
				{
				setState(171);
				variableStmt();
				}
				break;
			case 9:
				enterOuterAlt(_localctx, 9);
				{
				setState(172);
				whileWendStmt();
				}
				break;
			case 10:
				enterOuterAlt(_localctx, 10);
				{
				setState(173);
				expression(0);
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

	public static class ConstStmtContext extends ParserRuleContext {
		public TerminalNode CONST() { return getToken(TibboBasicParser.CONST, 0); }
		public List<ConstSubStmtContext> constSubStmt() {
			return getRuleContexts(ConstSubStmtContext.class);
		}
		public ConstSubStmtContext constSubStmt(int i) {
			return getRuleContext(ConstSubStmtContext.class,i);
		}
		public List<TerminalNode> COMMA() { return getTokens(TibboBasicParser.COMMA); }
		public TerminalNode COMMA(int i) {
			return getToken(TibboBasicParser.COMMA, i);
		}
		public ConstStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_constStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterConstStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitConstStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitConstStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ConstStmtContext constStmt() throws RecognitionException {
		ConstStmtContext _localctx = new ConstStmtContext(_ctx, getState());
		enterRule(_localctx, 12, RULE_constStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(176);
			match(CONST);
			setState(177);
			constSubStmt();
			setState(182);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==COMMA) {
				{
				{
				setState(178);
				match(COMMA);
				setState(179);
				constSubStmt();
				}
				}
				setState(184);
				_errHandler.sync(this);
				_la = _input.LA(1);
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

	public static class ConstSubStmtContext extends ParserRuleContext {
		public Token name;
		public ExpressionContext value;
		public TerminalNode EQ() { return getToken(TibboBasicParser.EQ, 0); }
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public AsTypeClauseContext asTypeClause() {
			return getRuleContext(AsTypeClauseContext.class,0);
		}
		public ConstSubStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_constSubStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterConstSubStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitConstSubStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitConstSubStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ConstSubStmtContext constSubStmt() throws RecognitionException {
		ConstSubStmtContext _localctx = new ConstSubStmtContext(_ctx, getState());
		enterRule(_localctx, 14, RULE_constSubStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(185);
			((ConstSubStmtContext)_localctx).name = match(IDENTIFIER);
			setState(187);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==AS) {
				{
				setState(186);
				asTypeClause();
				}
			}

			setState(189);
			match(EQ);
			setState(190);
			((ConstSubStmtContext)_localctx).value = expression(0);
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

	public static class DeclareVariableStmtContext extends ParserRuleContext {
		public TerminalNode DECLARE() { return getToken(TibboBasicParser.DECLARE, 0); }
		public VariableListStmtContext variableListStmt() {
			return getRuleContext(VariableListStmtContext.class,0);
		}
		public VisibilityContext visibility() {
			return getRuleContext(VisibilityContext.class,0);
		}
		public DeclareVariableStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_declareVariableStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterDeclareVariableStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitDeclareVariableStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitDeclareVariableStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final DeclareVariableStmtContext declareVariableStmt() throws RecognitionException {
		DeclareVariableStmtContext _localctx = new DeclareVariableStmtContext(_ctx, getState());
		enterRule(_localctx, 16, RULE_declareVariableStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(193);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==PUBLIC) {
				{
				setState(192);
				visibility();
				}
			}

			setState(195);
			match(DECLARE);
			setState(196);
			variableListStmt();
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

	public static class DeclareSubStmtContext extends ParserRuleContext {
		public Token name;
		public TerminalNode DECLARE() { return getToken(TibboBasicParser.DECLARE, 0); }
		public TerminalNode SUB() { return getToken(TibboBasicParser.SUB, 0); }
		public List<TerminalNode> IDENTIFIER() { return getTokens(TibboBasicParser.IDENTIFIER); }
		public TerminalNode IDENTIFIER(int i) {
			return getToken(TibboBasicParser.IDENTIFIER, i);
		}
		public TerminalNode DOT() { return getToken(TibboBasicParser.DOT, 0); }
		public ParamListContext paramList() {
			return getRuleContext(ParamListContext.class,0);
		}
		public DeclareSubStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_declareSubStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterDeclareSubStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitDeclareSubStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitDeclareSubStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final DeclareSubStmtContext declareSubStmt() throws RecognitionException {
		DeclareSubStmtContext _localctx = new DeclareSubStmtContext(_ctx, getState());
		enterRule(_localctx, 18, RULE_declareSubStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(198);
			match(DECLARE);
			setState(199);
			match(SUB);
			setState(202);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,8,_ctx) ) {
			case 1:
				{
				setState(200);
				match(IDENTIFIER);
				setState(201);
				match(DOT);
				}
				break;
			}
			setState(204);
			((DeclareSubStmtContext)_localctx).name = match(IDENTIFIER);
			setState(206);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==LPAREN) {
				{
				setState(205);
				paramList();
				}
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

	public static class DeclareFuncStmtContext extends ParserRuleContext {
		public Token name;
		public AsTypeClauseContext returnType;
		public TerminalNode DECLARE() { return getToken(TibboBasicParser.DECLARE, 0); }
		public TerminalNode FUNCTION() { return getToken(TibboBasicParser.FUNCTION, 0); }
		public List<TerminalNode> IDENTIFIER() { return getTokens(TibboBasicParser.IDENTIFIER); }
		public TerminalNode IDENTIFIER(int i) {
			return getToken(TibboBasicParser.IDENTIFIER, i);
		}
		public AsTypeClauseContext asTypeClause() {
			return getRuleContext(AsTypeClauseContext.class,0);
		}
		public TerminalNode DOT() { return getToken(TibboBasicParser.DOT, 0); }
		public ParamListContext paramList() {
			return getRuleContext(ParamListContext.class,0);
		}
		public DeclareFuncStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_declareFuncStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterDeclareFuncStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitDeclareFuncStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitDeclareFuncStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final DeclareFuncStmtContext declareFuncStmt() throws RecognitionException {
		DeclareFuncStmtContext _localctx = new DeclareFuncStmtContext(_ctx, getState());
		enterRule(_localctx, 20, RULE_declareFuncStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(208);
			match(DECLARE);
			setState(209);
			match(FUNCTION);
			setState(212);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,10,_ctx) ) {
			case 1:
				{
				setState(210);
				match(IDENTIFIER);
				setState(211);
				match(DOT);
				}
				break;
			}
			setState(214);
			((DeclareFuncStmtContext)_localctx).name = match(IDENTIFIER);
			setState(216);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==LPAREN) {
				{
				setState(215);
				paramList();
				}
			}

			setState(218);
			((DeclareFuncStmtContext)_localctx).returnType = asTypeClause();
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

	public static class DoLoopStmtContext extends ParserRuleContext {
		public ExpressionContext condition;
		public TerminalNode DO() { return getToken(TibboBasicParser.DO, 0); }
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public TerminalNode LOOP() { return getToken(TibboBasicParser.LOOP, 0); }
		public TerminalNode WHILE() { return getToken(TibboBasicParser.WHILE, 0); }
		public TerminalNode UNTIL() { return getToken(TibboBasicParser.UNTIL, 0); }
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public DoLoopStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_doLoopStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterDoLoopStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitDoLoopStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitDoLoopStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final DoLoopStmtContext doLoopStmt() throws RecognitionException {
		DoLoopStmtContext _localctx = new DoLoopStmtContext(_ctx, getState());
		enterRule(_localctx, 22, RULE_doLoopStmt);
		int _la;
		try {
			setState(236);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,12,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(220);
				match(DO);
				setState(221);
				block();
				setState(222);
				match(LOOP);
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(224);
				match(DO);
				setState(225);
				_la = _input.LA(1);
				if ( !(_la==UNTIL || _la==WHILE) ) {
				_errHandler.recoverInline(this);
				}
				else {
					if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
					_errHandler.reportMatch(this);
					consume();
				}
				setState(226);
				((DoLoopStmtContext)_localctx).condition = expression(0);
				setState(227);
				block();
				setState(228);
				match(LOOP);
				}
				break;
			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(230);
				match(DO);
				setState(231);
				block();
				setState(232);
				match(LOOP);
				setState(233);
				_la = _input.LA(1);
				if ( !(_la==UNTIL || _la==WHILE) ) {
				_errHandler.recoverInline(this);
				}
				else {
					if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
					_errHandler.reportMatch(this);
					consume();
				}
				setState(234);
				((DoLoopStmtContext)_localctx).condition = expression(0);
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

	public static class EnumerationStmtContext extends ParserRuleContext {
		public TerminalNode ENUM() { return getToken(TibboBasicParser.ENUM, 0); }
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public TerminalNode END_ENUM() { return getToken(TibboBasicParser.END_ENUM, 0); }
		public List<EnumerationStmt_ConstantContext> enumerationStmt_Constant() {
			return getRuleContexts(EnumerationStmt_ConstantContext.class);
		}
		public EnumerationStmt_ConstantContext enumerationStmt_Constant(int i) {
			return getRuleContext(EnumerationStmt_ConstantContext.class,i);
		}
		public EnumerationStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_enumerationStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterEnumerationStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitEnumerationStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitEnumerationStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final EnumerationStmtContext enumerationStmt() throws RecognitionException {
		EnumerationStmtContext _localctx = new EnumerationStmtContext(_ctx, getState());
		enterRule(_localctx, 24, RULE_enumerationStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(238);
			match(ENUM);
			setState(239);
			match(IDENTIFIER);
			setState(243);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==IDENTIFIER) {
				{
				{
				setState(240);
				enumerationStmt_Constant();
				}
				}
				setState(245);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(246);
			match(END_ENUM);
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

	public static class EnumerationStmt_ConstantContext extends ParserRuleContext {
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public TerminalNode EQ() { return getToken(TibboBasicParser.EQ, 0); }
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public TerminalNode COMMA() { return getToken(TibboBasicParser.COMMA, 0); }
		public EnumerationStmt_ConstantContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_enumerationStmt_Constant; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterEnumerationStmt_Constant(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitEnumerationStmt_Constant(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitEnumerationStmt_Constant(this);
			else return visitor.visitChildren(this);
		}
	}

	public final EnumerationStmt_ConstantContext enumerationStmt_Constant() throws RecognitionException {
		EnumerationStmt_ConstantContext _localctx = new EnumerationStmt_ConstantContext(_ctx, getState());
		enterRule(_localctx, 26, RULE_enumerationStmt_Constant);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(248);
			match(IDENTIFIER);
			setState(251);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==EQ) {
				{
				setState(249);
				match(EQ);
				setState(250);
				expression(0);
				}
			}

			setState(254);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==COMMA) {
				{
				setState(253);
				match(COMMA);
				}
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

	public static class ExitStmtContext extends ParserRuleContext {
		public TerminalNode EXIT_DO() { return getToken(TibboBasicParser.EXIT_DO, 0); }
		public TerminalNode EXIT_FOR() { return getToken(TibboBasicParser.EXIT_FOR, 0); }
		public TerminalNode EXIT_FUNCTION() { return getToken(TibboBasicParser.EXIT_FUNCTION, 0); }
		public TerminalNode EXIT_PROPERTY() { return getToken(TibboBasicParser.EXIT_PROPERTY, 0); }
		public TerminalNode EXIT_SUB() { return getToken(TibboBasicParser.EXIT_SUB, 0); }
		public TerminalNode EXIT_WHILE() { return getToken(TibboBasicParser.EXIT_WHILE, 0); }
		public ExitStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_exitStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterExitStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitExitStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitExitStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ExitStmtContext exitStmt() throws RecognitionException {
		ExitStmtContext _localctx = new ExitStmtContext(_ctx, getState());
		enterRule(_localctx, 28, RULE_exitStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(256);
			_la = _input.LA(1);
			if ( !((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << EXIT_DO) | (1L << EXIT_FOR) | (1L << EXIT_FUNCTION) | (1L << EXIT_PROPERTY) | (1L << EXIT_SUB) | (1L << EXIT_WHILE))) != 0)) ) {
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

	public static class ForNextStmtContext extends ParserRuleContext {
		public ExpressionContext step;
		public TerminalNode FOR() { return getToken(TibboBasicParser.FOR, 0); }
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public TerminalNode TO() { return getToken(TibboBasicParser.TO, 0); }
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public TerminalNode NEXT() { return getToken(TibboBasicParser.NEXT, 0); }
		public TerminalNode STEP() { return getToken(TibboBasicParser.STEP, 0); }
		public ForNextStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_forNextStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterForNextStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitForNextStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitForNextStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ForNextStmtContext forNextStmt() throws RecognitionException {
		ForNextStmtContext _localctx = new ForNextStmtContext(_ctx, getState());
		enterRule(_localctx, 30, RULE_forNextStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(258);
			match(FOR);
			setState(259);
			expression(0);
			setState(260);
			match(TO);
			setState(261);
			expression(0);
			setState(264);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==STEP) {
				{
				setState(262);
				match(STEP);
				setState(263);
				((ForNextStmtContext)_localctx).step = expression(0);
				}
			}

			setState(266);
			block();
			setState(267);
			match(NEXT);
			setState(269);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,17,_ctx) ) {
			case 1:
				{
				setState(268);
				expression(0);
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

	public static class FunctionStmtContext extends ParserRuleContext {
		public Token name;
		public AsTypeClauseContext returnType;
		public TerminalNode FUNCTION() { return getToken(TibboBasicParser.FUNCTION, 0); }
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public TerminalNode END_FUNCTION() { return getToken(TibboBasicParser.END_FUNCTION, 0); }
		public List<TerminalNode> IDENTIFIER() { return getTokens(TibboBasicParser.IDENTIFIER); }
		public TerminalNode IDENTIFIER(int i) {
			return getToken(TibboBasicParser.IDENTIFIER, i);
		}
		public AsTypeClauseContext asTypeClause() {
			return getRuleContext(AsTypeClauseContext.class,0);
		}
		public VisibilityContext visibility() {
			return getRuleContext(VisibilityContext.class,0);
		}
		public TerminalNode DOT() { return getToken(TibboBasicParser.DOT, 0); }
		public ParamListContext paramList() {
			return getRuleContext(ParamListContext.class,0);
		}
		public FunctionStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_functionStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterFunctionStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitFunctionStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitFunctionStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final FunctionStmtContext functionStmt() throws RecognitionException {
		FunctionStmtContext _localctx = new FunctionStmtContext(_ctx, getState());
		enterRule(_localctx, 32, RULE_functionStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(272);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==PUBLIC) {
				{
				setState(271);
				visibility();
				}
			}

			setState(274);
			match(FUNCTION);
			setState(277);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,19,_ctx) ) {
			case 1:
				{
				setState(275);
				match(IDENTIFIER);
				setState(276);
				match(DOT);
				}
				break;
			}
			setState(279);
			((FunctionStmtContext)_localctx).name = match(IDENTIFIER);
			setState(281);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==LPAREN) {
				{
				setState(280);
				paramList();
				}
			}

			setState(283);
			((FunctionStmtContext)_localctx).returnType = asTypeClause();
			setState(284);
			block();
			setState(285);
			match(END_FUNCTION);
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

	public static class JumpStmtContext extends ParserRuleContext {
		public GoToStmtContext goToStmt() {
			return getRuleContext(GoToStmtContext.class,0);
		}
		public ExitStmtContext exitStmt() {
			return getRuleContext(ExitStmtContext.class,0);
		}
		public JumpStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_jumpStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterJumpStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitJumpStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitJumpStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final JumpStmtContext jumpStmt() throws RecognitionException {
		JumpStmtContext _localctx = new JumpStmtContext(_ctx, getState());
		enterRule(_localctx, 34, RULE_jumpStmt);
		try {
			setState(289);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case GOTO:
				enterOuterAlt(_localctx, 1);
				{
				setState(287);
				goToStmt();
				}
				break;
			case EXIT_DO:
			case EXIT_FOR:
			case EXIT_FUNCTION:
			case EXIT_PROPERTY:
			case EXIT_SUB:
			case EXIT_WHILE:
				enterOuterAlt(_localctx, 2);
				{
				setState(288);
				exitStmt();
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

	public static class GoToStmtContext extends ParserRuleContext {
		public TerminalNode GOTO() { return getToken(TibboBasicParser.GOTO, 0); }
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public GoToStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_goToStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterGoToStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitGoToStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitGoToStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final GoToStmtContext goToStmt() throws RecognitionException {
		GoToStmtContext _localctx = new GoToStmtContext(_ctx, getState());
		enterRule(_localctx, 36, RULE_goToStmt);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(291);
			match(GOTO);
			setState(292);
			match(IDENTIFIER);
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

	public static class IfThenElseStmtContext extends ParserRuleContext {
		public IfThenElseStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_ifThenElseStmt; }
	 
		public IfThenElseStmtContext() { }
		public void copyFrom(IfThenElseStmtContext ctx) {
			super.copyFrom(ctx);
		}
	}
	public static class BlockIfThenElseContext extends IfThenElseStmtContext {
		public TerminalNode IF() { return getToken(TibboBasicParser.IF, 0); }
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public List<TerminalNode> THEN() { return getTokens(TibboBasicParser.THEN); }
		public TerminalNode THEN(int i) {
			return getToken(TibboBasicParser.THEN, i);
		}
		public List<BlockContext> block() {
			return getRuleContexts(BlockContext.class);
		}
		public BlockContext block(int i) {
			return getRuleContext(BlockContext.class,i);
		}
		public TerminalNode END_IF() { return getToken(TibboBasicParser.END_IF, 0); }
		public List<TerminalNode> NEWLINE() { return getTokens(TibboBasicParser.NEWLINE); }
		public TerminalNode NEWLINE(int i) {
			return getToken(TibboBasicParser.NEWLINE, i);
		}
		public List<TerminalNode> ELSEIF() { return getTokens(TibboBasicParser.ELSEIF); }
		public TerminalNode ELSEIF(int i) {
			return getToken(TibboBasicParser.ELSEIF, i);
		}
		public List<IfConditionStmtContext> ifConditionStmt() {
			return getRuleContexts(IfConditionStmtContext.class);
		}
		public IfConditionStmtContext ifConditionStmt(int i) {
			return getRuleContext(IfConditionStmtContext.class,i);
		}
		public TerminalNode ELSE() { return getToken(TibboBasicParser.ELSE, 0); }
		public BlockIfThenElseContext(IfThenElseStmtContext ctx) { copyFrom(ctx); }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterBlockIfThenElse(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitBlockIfThenElse(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitBlockIfThenElse(this);
			else return visitor.visitChildren(this);
		}
	}
	public static class InlineIfThenElseContext extends IfThenElseStmtContext {
		public TerminalNode IF() { return getToken(TibboBasicParser.IF, 0); }
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public TerminalNode THEN() { return getToken(TibboBasicParser.THEN, 0); }
		public TerminalNode NEWLINE() { return getToken(TibboBasicParser.NEWLINE, 0); }
		public List<StatementContext> statement() {
			return getRuleContexts(StatementContext.class);
		}
		public StatementContext statement(int i) {
			return getRuleContext(StatementContext.class,i);
		}
		public List<JumpStmtContext> jumpStmt() {
			return getRuleContexts(JumpStmtContext.class);
		}
		public JumpStmtContext jumpStmt(int i) {
			return getRuleContext(JumpStmtContext.class,i);
		}
		public TerminalNode ELSE() { return getToken(TibboBasicParser.ELSE, 0); }
		public InlineIfThenElseContext(IfThenElseStmtContext ctx) { copyFrom(ctx); }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterInlineIfThenElse(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitInlineIfThenElse(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitInlineIfThenElse(this);
			else return visitor.visitChildren(this);
		}
	}

	public final IfThenElseStmtContext ifThenElseStmt() throws RecognitionException {
		IfThenElseStmtContext _localctx = new IfThenElseStmtContext(_ctx, getState());
		enterRule(_localctx, 38, RULE_ifThenElseStmt);
		int _la;
		try {
			setState(335);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,28,_ctx) ) {
			case 1:
				_localctx = new InlineIfThenElseContext(_localctx);
				enterOuterAlt(_localctx, 1);
				{
				setState(294);
				match(IF);
				setState(295);
				expression(0);
				setState(296);
				match(THEN);
				setState(299);
				_errHandler.sync(this);
				switch ( getInterpreter().adaptivePredict(_input,22,_ctx) ) {
				case 1:
					{
					setState(297);
					statement();
					}
					break;
				case 2:
					{
					setState(298);
					jumpStmt();
					}
					break;
				}
				setState(306);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if (_la==ELSE) {
					{
					setState(301);
					match(ELSE);
					setState(304);
					_errHandler.sync(this);
					switch ( getInterpreter().adaptivePredict(_input,23,_ctx) ) {
					case 1:
						{
						setState(302);
						statement();
						}
						break;
					case 2:
						{
						setState(303);
						jumpStmt();
						}
						break;
					}
					}
				}

				setState(308);
				match(NEWLINE);
				}
				break;
			case 2:
				_localctx = new BlockIfThenElseContext(_localctx);
				enterOuterAlt(_localctx, 2);
				{
				setState(310);
				match(IF);
				setState(311);
				expression(0);
				setState(312);
				match(THEN);
				setState(314); 
				_errHandler.sync(this);
				_la = _input.LA(1);
				do {
					{
					{
					setState(313);
					match(NEWLINE);
					}
					}
					setState(316); 
					_errHandler.sync(this);
					_la = _input.LA(1);
				} while ( _la==NEWLINE );
				setState(318);
				block();
				setState(326);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==ELSEIF) {
					{
					{
					setState(319);
					match(ELSEIF);
					setState(320);
					ifConditionStmt();
					setState(321);
					match(THEN);
					setState(322);
					block();
					}
					}
					setState(328);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				setState(331);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if (_la==ELSE) {
					{
					setState(329);
					match(ELSE);
					setState(330);
					block();
					}
				}

				setState(333);
				match(END_IF);
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

	public static class IfConditionStmtContext extends ParserRuleContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public IfConditionStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_ifConditionStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterIfConditionStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitIfConditionStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitIfConditionStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final IfConditionStmtContext ifConditionStmt() throws RecognitionException {
		IfConditionStmtContext _localctx = new IfConditionStmtContext(_ctx, getState());
		enterRule(_localctx, 40, RULE_ifConditionStmt);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(337);
			expression(0);
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

	public static class PropertyDefineStmtContext extends ParserRuleContext {
		public Token object;
		public Token property;
		public TerminalNode PROPERTY() { return getToken(TibboBasicParser.PROPERTY, 0); }
		public TerminalNode DOT() { return getToken(TibboBasicParser.DOT, 0); }
		public TerminalNode END_PROPERTY() { return getToken(TibboBasicParser.END_PROPERTY, 0); }
		public List<TerminalNode> IDENTIFIER() { return getTokens(TibboBasicParser.IDENTIFIER); }
		public TerminalNode IDENTIFIER(int i) {
			return getToken(TibboBasicParser.IDENTIFIER, i);
		}
		public TerminalNode BANG() { return getToken(TibboBasicParser.BANG, 0); }
		public List<PropertyDefineStmt_InStmtContext> propertyDefineStmt_InStmt() {
			return getRuleContexts(PropertyDefineStmt_InStmtContext.class);
		}
		public PropertyDefineStmt_InStmtContext propertyDefineStmt_InStmt(int i) {
			return getRuleContext(PropertyDefineStmt_InStmtContext.class,i);
		}
		public PropertyDefineStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_propertyDefineStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterPropertyDefineStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitPropertyDefineStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitPropertyDefineStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final PropertyDefineStmtContext propertyDefineStmt() throws RecognitionException {
		PropertyDefineStmtContext _localctx = new PropertyDefineStmtContext(_ctx, getState());
		enterRule(_localctx, 42, RULE_propertyDefineStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(339);
			match(PROPERTY);
			setState(341);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==BANG) {
				{
				setState(340);
				match(BANG);
				}
			}

			setState(343);
			((PropertyDefineStmtContext)_localctx).object = match(IDENTIFIER);
			setState(344);
			match(DOT);
			setState(345);
			((PropertyDefineStmtContext)_localctx).property = match(IDENTIFIER);
			setState(349);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==GET || _la==SET) {
				{
				{
				setState(346);
				propertyDefineStmt_InStmt();
				}
				}
				setState(351);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(352);
			match(END_PROPERTY);
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

	public static class PropertyDefineStmt_InStmtContext extends ParserRuleContext {
		public PropertyGetStmtContext propertyGetStmt() {
			return getRuleContext(PropertyGetStmtContext.class,0);
		}
		public PropertySetStmtContext propertySetStmt() {
			return getRuleContext(PropertySetStmtContext.class,0);
		}
		public PropertyDefineStmt_InStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_propertyDefineStmt_InStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterPropertyDefineStmt_InStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitPropertyDefineStmt_InStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitPropertyDefineStmt_InStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final PropertyDefineStmt_InStmtContext propertyDefineStmt_InStmt() throws RecognitionException {
		PropertyDefineStmt_InStmtContext _localctx = new PropertyDefineStmt_InStmtContext(_ctx, getState());
		enterRule(_localctx, 44, RULE_propertyDefineStmt_InStmt);
		try {
			setState(356);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case GET:
				enterOuterAlt(_localctx, 1);
				{
				setState(354);
				propertyGetStmt();
				}
				break;
			case SET:
				enterOuterAlt(_localctx, 2);
				{
				setState(355);
				propertySetStmt();
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

	public static class PropertyGetStmtContext extends ParserRuleContext {
		public TerminalNode GET() { return getToken(TibboBasicParser.GET, 0); }
		public TerminalNode EQ() { return getToken(TibboBasicParser.EQ, 0); }
		public TerminalNode SYSCALL() { return getToken(TibboBasicParser.SYSCALL, 0); }
		public TerminalNode LPAREN() { return getToken(TibboBasicParser.LPAREN, 0); }
		public TerminalNode RPAREN() { return getToken(TibboBasicParser.RPAREN, 0); }
		public AsTypeClauseContext asTypeClause() {
			return getRuleContext(AsTypeClauseContext.class,0);
		}
		public TerminalNode INTEGERLITERAL() { return getToken(TibboBasicParser.INTEGERLITERAL, 0); }
		public TerminalNode COMMA() { return getToken(TibboBasicParser.COMMA, 0); }
		public TerminalNode STRINGLITERAL() { return getToken(TibboBasicParser.STRINGLITERAL, 0); }
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public TerminalNode PLUS() { return getToken(TibboBasicParser.PLUS, 0); }
		public PropertyGetStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_propertyGetStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterPropertyGetStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitPropertyGetStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitPropertyGetStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final PropertyGetStmtContext propertyGetStmt() throws RecognitionException {
		PropertyGetStmtContext _localctx = new PropertyGetStmtContext(_ctx, getState());
		enterRule(_localctx, 46, RULE_propertyGetStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(358);
			match(GET);
			setState(359);
			match(EQ);
			setState(360);
			match(SYSCALL);
			setState(361);
			match(LPAREN);
			setState(370);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==INTEGERLITERAL) {
				{
				setState(362);
				match(INTEGERLITERAL);
				setState(368);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if (_la==COMMA) {
					{
					setState(363);
					match(COMMA);
					setState(364);
					_la = _input.LA(1);
					if ( !(_la==STRINGLITERAL || _la==IDENTIFIER) ) {
					_errHandler.recoverInline(this);
					}
					else {
						if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
						_errHandler.reportMatch(this);
						consume();
					}
					setState(366);
					_errHandler.sync(this);
					_la = _input.LA(1);
					if (_la==PLUS) {
						{
						setState(365);
						match(PLUS);
						}
					}

					}
				}

				}
			}

			setState(372);
			match(RPAREN);
			setState(373);
			asTypeClause();
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

	public static class PropertySetStmtContext extends ParserRuleContext {
		public TerminalNode SET() { return getToken(TibboBasicParser.SET, 0); }
		public TerminalNode EQ() { return getToken(TibboBasicParser.EQ, 0); }
		public TerminalNode SYSCALL() { return getToken(TibboBasicParser.SYSCALL, 0); }
		public TerminalNode LPAREN() { return getToken(TibboBasicParser.LPAREN, 0); }
		public TerminalNode RPAREN() { return getToken(TibboBasicParser.RPAREN, 0); }
		public ParamListContext paramList() {
			return getRuleContext(ParamListContext.class,0);
		}
		public TerminalNode INTEGERLITERAL() { return getToken(TibboBasicParser.INTEGERLITERAL, 0); }
		public TerminalNode COMMA() { return getToken(TibboBasicParser.COMMA, 0); }
		public TerminalNode STRINGLITERAL() { return getToken(TibboBasicParser.STRINGLITERAL, 0); }
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public TerminalNode PLUS() { return getToken(TibboBasicParser.PLUS, 0); }
		public PropertySetStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_propertySetStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterPropertySetStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitPropertySetStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitPropertySetStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final PropertySetStmtContext propertySetStmt() throws RecognitionException {
		PropertySetStmtContext _localctx = new PropertySetStmtContext(_ctx, getState());
		enterRule(_localctx, 48, RULE_propertySetStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(375);
			match(SET);
			setState(376);
			match(EQ);
			setState(377);
			match(SYSCALL);
			setState(378);
			match(LPAREN);
			setState(387);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==INTEGERLITERAL) {
				{
				setState(379);
				match(INTEGERLITERAL);
				setState(385);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if (_la==COMMA) {
					{
					setState(380);
					match(COMMA);
					setState(381);
					_la = _input.LA(1);
					if ( !(_la==STRINGLITERAL || _la==IDENTIFIER) ) {
					_errHandler.recoverInline(this);
					}
					else {
						if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
						_errHandler.reportMatch(this);
						consume();
					}
					setState(383);
					_errHandler.sync(this);
					_la = _input.LA(1);
					if (_la==PLUS) {
						{
						setState(382);
						match(PLUS);
						}
					}

					}
				}

				}
			}

			setState(389);
			match(RPAREN);
			setState(390);
			paramList();
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

	public static class EventDeclarationContext extends ParserRuleContext {
		public Token number;
		public Token name;
		public ParamListContext params;
		public TerminalNode EVENT() { return getToken(TibboBasicParser.EVENT, 0); }
		public TerminalNode LPAREN() { return getToken(TibboBasicParser.LPAREN, 0); }
		public TerminalNode RPAREN() { return getToken(TibboBasicParser.RPAREN, 0); }
		public TerminalNode INTEGERLITERAL() { return getToken(TibboBasicParser.INTEGERLITERAL, 0); }
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public ParamListContext paramList() {
			return getRuleContext(ParamListContext.class,0);
		}
		public EventDeclarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_eventDeclaration; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterEventDeclaration(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitEventDeclaration(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitEventDeclaration(this);
			else return visitor.visitChildren(this);
		}
	}

	public final EventDeclarationContext eventDeclaration() throws RecognitionException {
		EventDeclarationContext _localctx = new EventDeclarationContext(_ctx, getState());
		enterRule(_localctx, 50, RULE_eventDeclaration);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(392);
			match(EVENT);
			setState(393);
			match(LPAREN);
			setState(394);
			((EventDeclarationContext)_localctx).number = match(INTEGERLITERAL);
			setState(395);
			match(RPAREN);
			setState(396);
			((EventDeclarationContext)_localctx).name = match(IDENTIFIER);
			setState(398);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==LPAREN) {
				{
				setState(397);
				((EventDeclarationContext)_localctx).params = paramList();
				}
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

	public static class SyscallDeclarationContext extends ParserRuleContext {
		public TerminalNode SYSCALL() { return getToken(TibboBasicParser.SYSCALL, 0); }
		public TerminalNode LPAREN() { return getToken(TibboBasicParser.LPAREN, 0); }
		public TerminalNode RPAREN() { return getToken(TibboBasicParser.RPAREN, 0); }
		public SyscallDeclarationInnerContext syscallDeclarationInner() {
			return getRuleContext(SyscallDeclarationInnerContext.class,0);
		}
		public SyscallInternalDeclarationInnerContext syscallInternalDeclarationInner() {
			return getRuleContext(SyscallInternalDeclarationInnerContext.class,0);
		}
		public TerminalNode INTEGERLITERAL() { return getToken(TibboBasicParser.INTEGERLITERAL, 0); }
		public TerminalNode COMMA() { return getToken(TibboBasicParser.COMMA, 0); }
		public TerminalNode STRINGLITERAL() { return getToken(TibboBasicParser.STRINGLITERAL, 0); }
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public TerminalNode PLUS() { return getToken(TibboBasicParser.PLUS, 0); }
		public SyscallDeclarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_syscallDeclaration; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterSyscallDeclaration(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitSyscallDeclaration(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitSyscallDeclaration(this);
			else return visitor.visitChildren(this);
		}
	}

	public final SyscallDeclarationContext syscallDeclaration() throws RecognitionException {
		SyscallDeclarationContext _localctx = new SyscallDeclarationContext(_ctx, getState());
		enterRule(_localctx, 52, RULE_syscallDeclaration);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(400);
			match(SYSCALL);
			setState(401);
			match(LPAREN);
			setState(410);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==INTEGERLITERAL) {
				{
				setState(402);
				match(INTEGERLITERAL);
				setState(408);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if (_la==COMMA) {
					{
					setState(403);
					match(COMMA);
					setState(404);
					_la = _input.LA(1);
					if ( !(_la==STRINGLITERAL || _la==IDENTIFIER) ) {
					_errHandler.recoverInline(this);
					}
					else {
						if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
						_errHandler.reportMatch(this);
						consume();
					}
					setState(406);
					_errHandler.sync(this);
					_la = _input.LA(1);
					if (_la==PLUS) {
						{
						setState(405);
						match(PLUS);
						}
					}

					}
				}

				}
			}

			setState(412);
			match(RPAREN);
			setState(415);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case IDENTIFIER:
				{
				setState(413);
				syscallDeclarationInner();
				}
				break;
			case BANG:
				{
				setState(414);
				syscallInternalDeclarationInner();
				}
				break;
			default:
				throw new NoViableAltException(this);
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

	public static class SyscallDeclarationInnerContext extends ParserRuleContext {
		public Token object;
		public Token property;
		public List<TerminalNode> IDENTIFIER() { return getTokens(TibboBasicParser.IDENTIFIER); }
		public TerminalNode IDENTIFIER(int i) {
			return getToken(TibboBasicParser.IDENTIFIER, i);
		}
		public TerminalNode DOT() { return getToken(TibboBasicParser.DOT, 0); }
		public ParamListContext paramList() {
			return getRuleContext(ParamListContext.class,0);
		}
		public AsTypeClauseContext asTypeClause() {
			return getRuleContext(AsTypeClauseContext.class,0);
		}
		public SyscallDeclarationInnerContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_syscallDeclarationInner; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterSyscallDeclarationInner(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitSyscallDeclarationInner(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitSyscallDeclarationInner(this);
			else return visitor.visitChildren(this);
		}
	}

	public final SyscallDeclarationInnerContext syscallDeclarationInner() throws RecognitionException {
		SyscallDeclarationInnerContext _localctx = new SyscallDeclarationInnerContext(_ctx, getState());
		enterRule(_localctx, 54, RULE_syscallDeclarationInner);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(419);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,43,_ctx) ) {
			case 1:
				{
				setState(417);
				((SyscallDeclarationInnerContext)_localctx).object = match(IDENTIFIER);
				setState(418);
				match(DOT);
				}
				break;
			}
			setState(421);
			((SyscallDeclarationInnerContext)_localctx).property = match(IDENTIFIER);
			setState(423);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==LPAREN) {
				{
				setState(422);
				paramList();
				}
			}

			setState(426);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==AS) {
				{
				setState(425);
				asTypeClause();
				}
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

	public static class SyscallInternalDeclarationInnerContext extends ParserRuleContext {
		public Token object;
		public Token property;
		public TerminalNode BANG() { return getToken(TibboBasicParser.BANG, 0); }
		public List<TerminalNode> IDENTIFIER() { return getTokens(TibboBasicParser.IDENTIFIER); }
		public TerminalNode IDENTIFIER(int i) {
			return getToken(TibboBasicParser.IDENTIFIER, i);
		}
		public TerminalNode DOT() { return getToken(TibboBasicParser.DOT, 0); }
		public SyscallInternalParamListContext syscallInternalParamList() {
			return getRuleContext(SyscallInternalParamListContext.class,0);
		}
		public AsTypeClauseContext asTypeClause() {
			return getRuleContext(AsTypeClauseContext.class,0);
		}
		public SyscallInternalDeclarationInnerContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_syscallInternalDeclarationInner; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterSyscallInternalDeclarationInner(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitSyscallInternalDeclarationInner(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitSyscallInternalDeclarationInner(this);
			else return visitor.visitChildren(this);
		}
	}

	public final SyscallInternalDeclarationInnerContext syscallInternalDeclarationInner() throws RecognitionException {
		SyscallInternalDeclarationInnerContext _localctx = new SyscallInternalDeclarationInnerContext(_ctx, getState());
		enterRule(_localctx, 56, RULE_syscallInternalDeclarationInner);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(428);
			match(BANG);
			setState(431);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,46,_ctx) ) {
			case 1:
				{
				setState(429);
				((SyscallInternalDeclarationInnerContext)_localctx).object = match(IDENTIFIER);
				setState(430);
				match(DOT);
				}
				break;
			}
			setState(433);
			((SyscallInternalDeclarationInnerContext)_localctx).property = match(IDENTIFIER);
			setState(435);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==LPAREN) {
				{
				setState(434);
				syscallInternalParamList();
				}
			}

			setState(438);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==AS) {
				{
				setState(437);
				asTypeClause();
				}
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

	public static class SyscallInternalParamListContext extends ParserRuleContext {
		public TerminalNode LPAREN() { return getToken(TibboBasicParser.LPAREN, 0); }
		public TerminalNode RPAREN() { return getToken(TibboBasicParser.RPAREN, 0); }
		public List<ParamInternalContext> paramInternal() {
			return getRuleContexts(ParamInternalContext.class);
		}
		public ParamInternalContext paramInternal(int i) {
			return getRuleContext(ParamInternalContext.class,i);
		}
		public List<TerminalNode> COMMA() { return getTokens(TibboBasicParser.COMMA); }
		public TerminalNode COMMA(int i) {
			return getToken(TibboBasicParser.COMMA, i);
		}
		public SyscallInternalParamListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_syscallInternalParamList; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterSyscallInternalParamList(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitSyscallInternalParamList(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitSyscallInternalParamList(this);
			else return visitor.visitChildren(this);
		}
	}

	public final SyscallInternalParamListContext syscallInternalParamList() throws RecognitionException {
		SyscallInternalParamListContext _localctx = new SyscallInternalParamListContext(_ctx, getState());
		enterRule(_localctx, 58, RULE_syscallInternalParamList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(440);
			match(LPAREN);
			setState(449);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==BYREF || _la==BYVAL || _la==IDENTIFIER) {
				{
				setState(441);
				paramInternal();
				setState(446);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==COMMA) {
					{
					{
					setState(442);
					match(COMMA);
					setState(443);
					paramInternal();
					}
					}
					setState(448);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				}
			}

			setState(451);
			match(RPAREN);
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

	public static class ParamInternalContext extends ParserRuleContext {
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public AsTypeClauseContext asTypeClause() {
			return getRuleContext(AsTypeClauseContext.class,0);
		}
		public TerminalNode BYVAL() { return getToken(TibboBasicParser.BYVAL, 0); }
		public TerminalNode BYREF() { return getToken(TibboBasicParser.BYREF, 0); }
		public ParamInternalContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_paramInternal; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterParamInternal(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitParamInternal(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitParamInternal(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ParamInternalContext paramInternal() throws RecognitionException {
		ParamInternalContext _localctx = new ParamInternalContext(_ctx, getState());
		enterRule(_localctx, 60, RULE_paramInternal);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(454);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==BYREF || _la==BYVAL) {
				{
				setState(453);
				_la = _input.LA(1);
				if ( !(_la==BYREF || _la==BYVAL) ) {
				_errHandler.recoverInline(this);
				}
				else {
					if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
					_errHandler.reportMatch(this);
					consume();
				}
				}
			}

			setState(456);
			match(IDENTIFIER);
			setState(458);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==AS) {
				{
				setState(457);
				asTypeClause();
				}
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

	public static class SelectCaseStmtContext extends ParserRuleContext {
		public TerminalNode SELECT() { return getToken(TibboBasicParser.SELECT, 0); }
		public TerminalNode CASE() { return getToken(TibboBasicParser.CASE, 0); }
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public TerminalNode END_SELECT() { return getToken(TibboBasicParser.END_SELECT, 0); }
		public TerminalNode COLON() { return getToken(TibboBasicParser.COLON, 0); }
		public List<SC_CaseContext> sC_Case() {
			return getRuleContexts(SC_CaseContext.class);
		}
		public SC_CaseContext sC_Case(int i) {
			return getRuleContext(SC_CaseContext.class,i);
		}
		public SC_DefaultContext sC_Default() {
			return getRuleContext(SC_DefaultContext.class,0);
		}
		public SelectCaseStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_selectCaseStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterSelectCaseStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitSelectCaseStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitSelectCaseStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final SelectCaseStmtContext selectCaseStmt() throws RecognitionException {
		SelectCaseStmtContext _localctx = new SelectCaseStmtContext(_ctx, getState());
		enterRule(_localctx, 62, RULE_selectCaseStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(460);
			match(SELECT);
			setState(461);
			match(CASE);
			setState(462);
			expression(0);
			setState(464);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==COLON) {
				{
				setState(463);
				match(COLON);
				}
			}

			setState(469);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==CASE) {
				{
				{
				setState(466);
				sC_Case();
				}
				}
				setState(471);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(473);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==CASE_ELSE) {
				{
				setState(472);
				sC_Default();
				}
			}

			setState(475);
			match(END_SELECT);
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

	public static class SC_CaseContext extends ParserRuleContext {
		public TerminalNode CASE() { return getToken(TibboBasicParser.CASE, 0); }
		public List<SC_CondContext> sC_Cond() {
			return getRuleContexts(SC_CondContext.class);
		}
		public SC_CondContext sC_Cond(int i) {
			return getRuleContext(SC_CondContext.class,i);
		}
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public List<TerminalNode> COMMA() { return getTokens(TibboBasicParser.COMMA); }
		public TerminalNode COMMA(int i) {
			return getToken(TibboBasicParser.COMMA, i);
		}
		public TerminalNode COLON() { return getToken(TibboBasicParser.COLON, 0); }
		public SC_CaseContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_sC_Case; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterSC_Case(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitSC_Case(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitSC_Case(this);
			else return visitor.visitChildren(this);
		}
	}

	public final SC_CaseContext sC_Case() throws RecognitionException {
		SC_CaseContext _localctx = new SC_CaseContext(_ctx, getState());
		enterRule(_localctx, 64, RULE_sC_Case);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(477);
			match(CASE);
			setState(478);
			sC_Cond();
			setState(483);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==COMMA) {
				{
				{
				setState(479);
				match(COMMA);
				setState(480);
				sC_Cond();
				}
				}
				setState(485);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(487);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==COLON) {
				{
				setState(486);
				match(COLON);
				}
			}

			setState(489);
			block();
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

	public static class SC_DefaultContext extends ParserRuleContext {
		public TerminalNode CASE_ELSE() { return getToken(TibboBasicParser.CASE_ELSE, 0); }
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public TerminalNode COLON() { return getToken(TibboBasicParser.COLON, 0); }
		public SC_DefaultContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_sC_Default; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterSC_Default(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitSC_Default(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitSC_Default(this);
			else return visitor.visitChildren(this);
		}
	}

	public final SC_DefaultContext sC_Default() throws RecognitionException {
		SC_DefaultContext _localctx = new SC_DefaultContext(_ctx, getState());
		enterRule(_localctx, 66, RULE_sC_Default);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(491);
			match(CASE_ELSE);
			setState(493);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==COLON) {
				{
				setState(492);
				match(COLON);
				}
			}

			setState(495);
			block();
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

	public static class SC_CondContext extends ParserRuleContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public SC_CondContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_sC_Cond; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterSC_Cond(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitSC_Cond(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitSC_Cond(this);
			else return visitor.visitChildren(this);
		}
	}

	public final SC_CondContext sC_Cond() throws RecognitionException {
		SC_CondContext _localctx = new SC_CondContext(_ctx, getState());
		enterRule(_localctx, 68, RULE_sC_Cond);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(497);
			expression(0);
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

	public static class SubStmtContext extends ParserRuleContext {
		public Token name;
		public TerminalNode SUB() { return getToken(TibboBasicParser.SUB, 0); }
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public TerminalNode END_SUB() { return getToken(TibboBasicParser.END_SUB, 0); }
		public List<TerminalNode> IDENTIFIER() { return getTokens(TibboBasicParser.IDENTIFIER); }
		public TerminalNode IDENTIFIER(int i) {
			return getToken(TibboBasicParser.IDENTIFIER, i);
		}
		public VisibilityContext visibility() {
			return getRuleContext(VisibilityContext.class,0);
		}
		public TerminalNode DOT() { return getToken(TibboBasicParser.DOT, 0); }
		public ParamListContext paramList() {
			return getRuleContext(ParamListContext.class,0);
		}
		public SubStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_subStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterSubStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitSubStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitSubStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final SubStmtContext subStmt() throws RecognitionException {
		SubStmtContext _localctx = new SubStmtContext(_ctx, getState());
		enterRule(_localctx, 70, RULE_subStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(500);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==PUBLIC) {
				{
				setState(499);
				visibility();
				}
			}

			setState(502);
			match(SUB);
			setState(505);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,60,_ctx) ) {
			case 1:
				{
				setState(503);
				match(IDENTIFIER);
				setState(504);
				match(DOT);
				}
				break;
			}
			setState(507);
			((SubStmtContext)_localctx).name = match(IDENTIFIER);
			setState(509);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,61,_ctx) ) {
			case 1:
				{
				setState(508);
				paramList();
				}
				break;
			}
			setState(511);
			block();
			setState(512);
			match(END_SUB);
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

	public static class TypeStmtContext extends ParserRuleContext {
		public Token name;
		public TerminalNode TYPE() { return getToken(TibboBasicParser.TYPE, 0); }
		public TerminalNode END_TYPE() { return getToken(TibboBasicParser.END_TYPE, 0); }
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public VisibilityContext visibility() {
			return getRuleContext(VisibilityContext.class,0);
		}
		public List<TypeStmtElementContext> typeStmtElement() {
			return getRuleContexts(TypeStmtElementContext.class);
		}
		public TypeStmtElementContext typeStmtElement(int i) {
			return getRuleContext(TypeStmtElementContext.class,i);
		}
		public TypeStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_typeStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterTypeStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitTypeStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitTypeStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final TypeStmtContext typeStmt() throws RecognitionException {
		TypeStmtContext _localctx = new TypeStmtContext(_ctx, getState());
		enterRule(_localctx, 72, RULE_typeStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(515);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==PUBLIC) {
				{
				setState(514);
				visibility();
				}
			}

			setState(517);
			match(TYPE);
			setState(518);
			((TypeStmtContext)_localctx).name = match(IDENTIFIER);
			setState(522);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==IDENTIFIER) {
				{
				{
				setState(519);
				typeStmtElement();
				}
				}
				setState(524);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(525);
			match(END_TYPE);
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

	public static class TypeStmtElementContext extends ParserRuleContext {
		public Token name;
		public AsTypeClauseContext valueType;
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public AsTypeClauseContext asTypeClause() {
			return getRuleContext(AsTypeClauseContext.class,0);
		}
		public TerminalNode LPAREN() { return getToken(TibboBasicParser.LPAREN, 0); }
		public LiteralContext literal() {
			return getRuleContext(LiteralContext.class,0);
		}
		public TerminalNode RPAREN() { return getToken(TibboBasicParser.RPAREN, 0); }
		public TypeStmtElementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_typeStmtElement; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterTypeStmtElement(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitTypeStmtElement(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitTypeStmtElement(this);
			else return visitor.visitChildren(this);
		}
	}

	public final TypeStmtElementContext typeStmtElement() throws RecognitionException {
		TypeStmtElementContext _localctx = new TypeStmtElementContext(_ctx, getState());
		enterRule(_localctx, 74, RULE_typeStmtElement);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(527);
			((TypeStmtElementContext)_localctx).name = match(IDENTIFIER);
			setState(532);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==LPAREN) {
				{
				setState(528);
				match(LPAREN);
				setState(529);
				literal();
				setState(530);
				match(RPAREN);
				}
			}

			setState(534);
			((TypeStmtElementContext)_localctx).valueType = asTypeClause();
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

	public static class ExpressionContext extends ParserRuleContext {
		public Token op;
		public UnaryExpressionContext unaryExpression() {
			return getRuleContext(UnaryExpressionContext.class,0);
		}
		public TerminalNode LPAREN() { return getToken(TibboBasicParser.LPAREN, 0); }
		public List<ExpressionContext> expression() {
			return getRuleContexts(ExpressionContext.class);
		}
		public ExpressionContext expression(int i) {
			return getRuleContext(ExpressionContext.class,i);
		}
		public TerminalNode RPAREN() { return getToken(TibboBasicParser.RPAREN, 0); }
		public TerminalNode MULT() { return getToken(TibboBasicParser.MULT, 0); }
		public TerminalNode DIV() { return getToken(TibboBasicParser.DIV, 0); }
		public TerminalNode MOD() { return getToken(TibboBasicParser.MOD, 0); }
		public TerminalNode PLUS() { return getToken(TibboBasicParser.PLUS, 0); }
		public TerminalNode MINUS() { return getToken(TibboBasicParser.MINUS, 0); }
		public TerminalNode LEQ() { return getToken(TibboBasicParser.LEQ, 0); }
		public TerminalNode GEQ() { return getToken(TibboBasicParser.GEQ, 0); }
		public TerminalNode LT() { return getToken(TibboBasicParser.LT, 0); }
		public TerminalNode GT() { return getToken(TibboBasicParser.GT, 0); }
		public TerminalNode NEQ() { return getToken(TibboBasicParser.NEQ, 0); }
		public TerminalNode EQ() { return getToken(TibboBasicParser.EQ, 0); }
		public TerminalNode SHL() { return getToken(TibboBasicParser.SHL, 0); }
		public TerminalNode SHR() { return getToken(TibboBasicParser.SHR, 0); }
		public TerminalNode NOT() { return getToken(TibboBasicParser.NOT, 0); }
		public TerminalNode AND() { return getToken(TibboBasicParser.AND, 0); }
		public TerminalNode XOR() { return getToken(TibboBasicParser.XOR, 0); }
		public TerminalNode OR() { return getToken(TibboBasicParser.OR, 0); }
		public ExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_expression; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterExpression(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitExpression(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitExpression(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ExpressionContext expression() throws RecognitionException {
		return expression(0);
	}

	private ExpressionContext expression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		ExpressionContext _localctx = new ExpressionContext(_ctx, _parentState);
		ExpressionContext _prevctx = _localctx;
		int _startState = 76;
		enterRecursionRule(_localctx, 76, RULE_expression, _p);
		int _la;
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(542);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,65,_ctx) ) {
			case 1:
				{
				setState(537);
				unaryExpression();
				}
				break;
			case 2:
				{
				setState(538);
				match(LPAREN);
				setState(539);
				expression(0);
				setState(540);
				match(RPAREN);
				}
				break;
			}
			_ctx.stop = _input.LT(-1);
			setState(561);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,67,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) triggerExitRuleEvent();
					_prevctx = _localctx;
					{
					setState(559);
					_errHandler.sync(this);
					switch ( getInterpreter().adaptivePredict(_input,66,_ctx) ) {
					case 1:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(544);
						if (!(precpred(_ctx, 6))) throw new FailedPredicateException(this, "precpred(_ctx, 6)");
						setState(545);
						((ExpressionContext)_localctx).op = _input.LT(1);
						_la = _input.LA(1);
						if ( !(((((_la - 52)) & ~0x3f) == 0 && ((1L << (_la - 52)) & ((1L << (MOD - 52)) | (1L << (DIV - 52)) | (1L << (MULT - 52)))) != 0)) ) {
							((ExpressionContext)_localctx).op = (Token)_errHandler.recoverInline(this);
						}
						else {
							if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
							_errHandler.reportMatch(this);
							consume();
						}
						setState(546);
						expression(7);
						}
						break;
					case 2:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(547);
						if (!(precpred(_ctx, 5))) throw new FailedPredicateException(this, "precpred(_ctx, 5)");
						setState(548);
						((ExpressionContext)_localctx).op = _input.LT(1);
						_la = _input.LA(1);
						if ( !(_la==MINUS || _la==PLUS) ) {
							((ExpressionContext)_localctx).op = (Token)_errHandler.recoverInline(this);
						}
						else {
							if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
							_errHandler.reportMatch(this);
							consume();
						}
						setState(549);
						expression(6);
						}
						break;
					case 3:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(550);
						if (!(precpred(_ctx, 4))) throw new FailedPredicateException(this, "precpred(_ctx, 4)");
						setState(551);
						((ExpressionContext)_localctx).op = _input.LT(1);
						_la = _input.LA(1);
						if ( !(((((_la - 85)) & ~0x3f) == 0 && ((1L << (_la - 85)) & ((1L << (GEQ - 85)) | (1L << (GT - 85)) | (1L << (LEQ - 85)) | (1L << (LT - 85)))) != 0)) ) {
							((ExpressionContext)_localctx).op = (Token)_errHandler.recoverInline(this);
						}
						else {
							if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
							_errHandler.reportMatch(this);
							consume();
						}
						setState(552);
						expression(5);
						}
						break;
					case 4:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(553);
						if (!(precpred(_ctx, 3))) throw new FailedPredicateException(this, "precpred(_ctx, 3)");
						setState(554);
						((ExpressionContext)_localctx).op = _input.LT(1);
						_la = _input.LA(1);
						if ( !(_la==EQ || _la==NEQ) ) {
							((ExpressionContext)_localctx).op = (Token)_errHandler.recoverInline(this);
						}
						else {
							if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
							_errHandler.reportMatch(this);
							consume();
						}
						setState(555);
						expression(4);
						}
						break;
					case 5:
						{
						_localctx = new ExpressionContext(_parentctx, _parentState);
						pushNewRecursionContext(_localctx, _startState, RULE_expression);
						setState(556);
						if (!(precpred(_ctx, 2))) throw new FailedPredicateException(this, "precpred(_ctx, 2)");
						setState(557);
						((ExpressionContext)_localctx).op = _input.LT(1);
						_la = _input.LA(1);
						if ( !((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << AND) | (1L << NOT) | (1L << OR) | (1L << SHL) | (1L << SHR))) != 0) || _la==XOR) ) {
							((ExpressionContext)_localctx).op = (Token)_errHandler.recoverInline(this);
						}
						else {
							if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
							_errHandler.reportMatch(this);
							consume();
						}
						setState(558);
						expression(3);
						}
						break;
					}
					} 
				}
				setState(563);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,67,_ctx);
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

	public static class UnaryExpressionContext extends ParserRuleContext {
		public PostfixExpressionContext postfixExpression() {
			return getRuleContext(PostfixExpressionContext.class,0);
		}
		public UnaryOperatorContext unaryOperator() {
			return getRuleContext(UnaryOperatorContext.class,0);
		}
		public PrimaryExpressionContext primaryExpression() {
			return getRuleContext(PrimaryExpressionContext.class,0);
		}
		public UnaryExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_unaryExpression; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterUnaryExpression(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitUnaryExpression(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitUnaryExpression(this);
			else return visitor.visitChildren(this);
		}
	}

	public final UnaryExpressionContext unaryExpression() throws RecognitionException {
		UnaryExpressionContext _localctx = new UnaryExpressionContext(_ctx, getState());
		enterRule(_localctx, 78, RULE_unaryExpression);
		try {
			setState(568);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,68,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(564);
				postfixExpression(0);
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(565);
				unaryOperator();
				setState(566);
				primaryExpression();
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

	public static class UnaryOperatorContext extends ParserRuleContext {
		public TerminalNode MINUS() { return getToken(TibboBasicParser.MINUS, 0); }
		public TerminalNode NOT() { return getToken(TibboBasicParser.NOT, 0); }
		public UnaryOperatorContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_unaryOperator; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterUnaryOperator(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitUnaryOperator(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitUnaryOperator(this);
			else return visitor.visitChildren(this);
		}
	}

	public final UnaryOperatorContext unaryOperator() throws RecognitionException {
		UnaryOperatorContext _localctx = new UnaryOperatorContext(_ctx, getState());
		enterRule(_localctx, 80, RULE_unaryOperator);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(570);
			_la = _input.LA(1);
			if ( !(_la==NOT || _la==MINUS) ) {
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

	public static class PostfixExpressionContext extends ParserRuleContext {
		public Token property;
		public PrimaryExpressionContext primaryExpression() {
			return getRuleContext(PrimaryExpressionContext.class,0);
		}
		public List<PostfixContext> postfix() {
			return getRuleContexts(PostfixContext.class);
		}
		public PostfixContext postfix(int i) {
			return getRuleContext(PostfixContext.class,i);
		}
		public PostfixExpressionContext postfixExpression() {
			return getRuleContext(PostfixExpressionContext.class,0);
		}
		public TerminalNode DOT() { return getToken(TibboBasicParser.DOT, 0); }
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public PostfixExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_postfixExpression; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterPostfixExpression(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitPostfixExpression(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitPostfixExpression(this);
			else return visitor.visitChildren(this);
		}
	}

	public final PostfixExpressionContext postfixExpression() throws RecognitionException {
		return postfixExpression(0);
	}

	private PostfixExpressionContext postfixExpression(int _p) throws RecognitionException {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = getState();
		PostfixExpressionContext _localctx = new PostfixExpressionContext(_ctx, _parentState);
		PostfixExpressionContext _prevctx = _localctx;
		int _startState = 82;
		enterRecursionRule(_localctx, 82, RULE_postfixExpression, _p);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			{
			setState(573);
			primaryExpression();
			setState(577);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,69,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					{
					{
					setState(574);
					postfix();
					}
					} 
				}
				setState(579);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,69,_ctx);
			}
			}
			_ctx.stop = _input.LT(-1);
			setState(591);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,71,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) triggerExitRuleEvent();
					_prevctx = _localctx;
					{
					{
					_localctx = new PostfixExpressionContext(_parentctx, _parentState);
					pushNewRecursionContext(_localctx, _startState, RULE_postfixExpression);
					setState(580);
					if (!(precpred(_ctx, 1))) throw new FailedPredicateException(this, "precpred(_ctx, 1)");
					setState(581);
					match(DOT);
					setState(582);
					((PostfixExpressionContext)_localctx).property = match(IDENTIFIER);
					setState(586);
					_errHandler.sync(this);
					_alt = getInterpreter().adaptivePredict(_input,70,_ctx);
					while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
						if ( _alt==1 ) {
							{
							{
							setState(583);
							postfix();
							}
							} 
						}
						setState(588);
						_errHandler.sync(this);
						_alt = getInterpreter().adaptivePredict(_input,70,_ctx);
					}
					}
					} 
				}
				setState(593);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,71,_ctx);
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

	public static class PostfixContext extends ParserRuleContext {
		public ArgListContext argList() {
			return getRuleContext(ArgListContext.class,0);
		}
		public PostfixContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_postfix; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterPostfix(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitPostfix(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitPostfix(this);
			else return visitor.visitChildren(this);
		}
	}

	public final PostfixContext postfix() throws RecognitionException {
		PostfixContext _localctx = new PostfixContext(_ctx, getState());
		enterRule(_localctx, 84, RULE_postfix);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(594);
			argList();
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

	public static class PrimaryExpressionContext extends ParserRuleContext {
		public LiteralContext literal() {
			return getRuleContext(LiteralContext.class,0);
		}
		public TerminalNode LPAREN() { return getToken(TibboBasicParser.LPAREN, 0); }
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public TerminalNode RPAREN() { return getToken(TibboBasicParser.RPAREN, 0); }
		public PrimaryExpressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_primaryExpression; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterPrimaryExpression(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitPrimaryExpression(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitPrimaryExpression(this);
			else return visitor.visitChildren(this);
		}
	}

	public final PrimaryExpressionContext primaryExpression() throws RecognitionException {
		PrimaryExpressionContext _localctx = new PrimaryExpressionContext(_ctx, getState());
		enterRule(_localctx, 86, RULE_primaryExpression);
		try {
			setState(601);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case FALSE:
			case TRUE:
			case STRINGLITERAL:
			case TemplateStringLiteral:
			case HEXLITERAL:
			case BINLITERAL:
			case INTEGERLITERAL:
			case MINUS:
			case PLUS:
			case IDENTIFIER:
				enterOuterAlt(_localctx, 1);
				{
				setState(596);
				literal();
				}
				break;
			case LPAREN:
				enterOuterAlt(_localctx, 2);
				{
				setState(597);
				match(LPAREN);
				setState(598);
				expression(0);
				setState(599);
				match(RPAREN);
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

	public static class VariableStmtContext extends ParserRuleContext {
		public TerminalNode DIM() { return getToken(TibboBasicParser.DIM, 0); }
		public VariableListStmtContext variableListStmt() {
			return getRuleContext(VariableListStmtContext.class,0);
		}
		public VisibilityContext visibility() {
			return getRuleContext(VisibilityContext.class,0);
		}
		public VariableStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_variableStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterVariableStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitVariableStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitVariableStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final VariableStmtContext variableStmt() throws RecognitionException {
		VariableStmtContext _localctx = new VariableStmtContext(_ctx, getState());
		enterRule(_localctx, 88, RULE_variableStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(604);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==PUBLIC) {
				{
				setState(603);
				visibility();
				}
			}

			setState(606);
			match(DIM);
			setState(607);
			variableListStmt();
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

	public static class VariableListStmtContext extends ParserRuleContext {
		public AsTypeClauseContext variableType;
		public List<VariableListItemContext> variableListItem() {
			return getRuleContexts(VariableListItemContext.class);
		}
		public VariableListItemContext variableListItem(int i) {
			return getRuleContext(VariableListItemContext.class,i);
		}
		public AsTypeClauseContext asTypeClause() {
			return getRuleContext(AsTypeClauseContext.class,0);
		}
		public List<TerminalNode> COMMA() { return getTokens(TibboBasicParser.COMMA); }
		public TerminalNode COMMA(int i) {
			return getToken(TibboBasicParser.COMMA, i);
		}
		public TerminalNode EQ() { return getToken(TibboBasicParser.EQ, 0); }
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public ArrayLiteralContext arrayLiteral() {
			return getRuleContext(ArrayLiteralContext.class,0);
		}
		public VariableListStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_variableListStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterVariableListStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitVariableListStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitVariableListStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final VariableListStmtContext variableListStmt() throws RecognitionException {
		VariableListStmtContext _localctx = new VariableListStmtContext(_ctx, getState());
		enterRule(_localctx, 90, RULE_variableListStmt);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(609);
			variableListItem();
			setState(616);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==COMMA) {
				{
				{
				setState(610);
				match(COMMA);
				setState(612);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if (_la==IDENTIFIER) {
					{
					setState(611);
					variableListItem();
					}
				}

				}
				}
				setState(618);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(619);
			((VariableListStmtContext)_localctx).variableType = asTypeClause();
			setState(625);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==EQ) {
				{
				setState(620);
				match(EQ);
				setState(623);
				_errHandler.sync(this);
				switch (_input.LA(1)) {
				case FALSE:
				case NOT:
				case TRUE:
				case STRINGLITERAL:
				case TemplateStringLiteral:
				case HEXLITERAL:
				case BINLITERAL:
				case INTEGERLITERAL:
				case LPAREN:
				case MINUS:
				case PLUS:
				case IDENTIFIER:
					{
					setState(621);
					expression(0);
					}
					break;
				case L_CURLY_BRACKET:
					{
					setState(622);
					arrayLiteral();
					}
					break;
				default:
					throw new NoViableAltException(this);
				}
				}
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

	public static class VariableListItemContext extends ParserRuleContext {
		public Token name;
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public TerminalNode LPAREN() { return getToken(TibboBasicParser.LPAREN, 0); }
		public LiteralContext literal() {
			return getRuleContext(LiteralContext.class,0);
		}
		public TerminalNode RPAREN() { return getToken(TibboBasicParser.RPAREN, 0); }
		public VariableListItemContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_variableListItem; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterVariableListItem(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitVariableListItem(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitVariableListItem(this);
			else return visitor.visitChildren(this);
		}
	}

	public final VariableListItemContext variableListItem() throws RecognitionException {
		VariableListItemContext _localctx = new VariableListItemContext(_ctx, getState());
		enterRule(_localctx, 92, RULE_variableListItem);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(627);
			((VariableListItemContext)_localctx).name = match(IDENTIFIER);
			setState(632);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==LPAREN) {
				{
				setState(628);
				match(LPAREN);
				setState(629);
				literal();
				setState(630);
				match(RPAREN);
				}
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

	public static class WhileWendStmtContext extends ParserRuleContext {
		public TerminalNode WHILE() { return getToken(TibboBasicParser.WHILE, 0); }
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public BlockContext block() {
			return getRuleContext(BlockContext.class,0);
		}
		public TerminalNode WEND() { return getToken(TibboBasicParser.WEND, 0); }
		public WhileWendStmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_whileWendStmt; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterWhileWendStmt(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitWhileWendStmt(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitWhileWendStmt(this);
			else return visitor.visitChildren(this);
		}
	}

	public final WhileWendStmtContext whileWendStmt() throws RecognitionException {
		WhileWendStmtContext _localctx = new WhileWendStmtContext(_ctx, getState());
		enterRule(_localctx, 94, RULE_whileWendStmt);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(634);
			match(WHILE);
			setState(635);
			expression(0);
			setState(636);
			block();
			setState(637);
			match(WEND);
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

	public static class ObjectDeclarationContext extends ParserRuleContext {
		public TerminalNode OBJECT() { return getToken(TibboBasicParser.OBJECT, 0); }
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public ObjectDeclarationContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_objectDeclaration; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterObjectDeclaration(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitObjectDeclaration(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitObjectDeclaration(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ObjectDeclarationContext objectDeclaration() throws RecognitionException {
		ObjectDeclarationContext _localctx = new ObjectDeclarationContext(_ctx, getState());
		enterRule(_localctx, 96, RULE_objectDeclaration);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(639);
			match(OBJECT);
			setState(640);
			match(IDENTIFIER);
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

	public static class ArgListContext extends ParserRuleContext {
		public TerminalNode LPAREN() { return getToken(TibboBasicParser.LPAREN, 0); }
		public TerminalNode RPAREN() { return getToken(TibboBasicParser.RPAREN, 0); }
		public List<ArgContext> arg() {
			return getRuleContexts(ArgContext.class);
		}
		public ArgContext arg(int i) {
			return getRuleContext(ArgContext.class,i);
		}
		public List<TerminalNode> COMMA() { return getTokens(TibboBasicParser.COMMA); }
		public TerminalNode COMMA(int i) {
			return getToken(TibboBasicParser.COMMA, i);
		}
		public ArgListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_argList; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterArgList(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitArgList(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitArgList(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ArgListContext argList() throws RecognitionException {
		ArgListContext _localctx = new ArgListContext(_ctx, getState());
		enterRule(_localctx, 98, RULE_argList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(642);
			match(LPAREN);
			setState(651);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==FALSE || _la==NOT || ((((_la - 69)) & ~0x3f) == 0 && ((1L << (_la - 69)) & ((1L << (TRUE - 69)) | (1L << (STRINGLITERAL - 69)) | (1L << (TemplateStringLiteral - 69)) | (1L << (HEXLITERAL - 69)) | (1L << (BINLITERAL - 69)) | (1L << (INTEGERLITERAL - 69)) | (1L << (LPAREN - 69)) | (1L << (MINUS - 69)) | (1L << (PLUS - 69)) | (1L << (IDENTIFIER - 69)))) != 0)) {
				{
				setState(643);
				arg();
				setState(648);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==COMMA) {
					{
					{
					setState(644);
					match(COMMA);
					setState(645);
					arg();
					}
					}
					setState(650);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				}
			}

			setState(653);
			match(RPAREN);
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

	public static class ArgContext extends ParserRuleContext {
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public ArgContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_arg; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterArg(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitArg(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitArg(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ArgContext arg() throws RecognitionException {
		ArgContext _localctx = new ArgContext(_ctx, getState());
		enterRule(_localctx, 100, RULE_arg);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(655);
			expression(0);
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

	public static class ParamListContext extends ParserRuleContext {
		public TerminalNode LPAREN() { return getToken(TibboBasicParser.LPAREN, 0); }
		public TerminalNode RPAREN() { return getToken(TibboBasicParser.RPAREN, 0); }
		public List<ParamContext> param() {
			return getRuleContexts(ParamContext.class);
		}
		public ParamContext param(int i) {
			return getRuleContext(ParamContext.class,i);
		}
		public List<TerminalNode> COMMA() { return getTokens(TibboBasicParser.COMMA); }
		public TerminalNode COMMA(int i) {
			return getToken(TibboBasicParser.COMMA, i);
		}
		public ParamListContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_paramList; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterParamList(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitParamList(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitParamList(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ParamListContext paramList() throws RecognitionException {
		ParamListContext _localctx = new ParamListContext(_ctx, getState());
		enterRule(_localctx, 102, RULE_paramList);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(657);
			match(LPAREN);
			setState(666);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==BYREF || _la==BYVAL || _la==IDENTIFIER) {
				{
				setState(658);
				param();
				setState(663);
				_errHandler.sync(this);
				_la = _input.LA(1);
				while (_la==COMMA) {
					{
					{
					setState(659);
					match(COMMA);
					setState(660);
					param();
					}
					}
					setState(665);
					_errHandler.sync(this);
					_la = _input.LA(1);
				}
				}
			}

			setState(668);
			match(RPAREN);
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

	public static class ParamContext extends ParserRuleContext {
		public Token byval;
		public Token byref;
		public Token name;
		public AsTypeClauseContext valueType;
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public TerminalNode LPAREN() { return getToken(TibboBasicParser.LPAREN, 0); }
		public TerminalNode INTEGERLITERAL() { return getToken(TibboBasicParser.INTEGERLITERAL, 0); }
		public TerminalNode RPAREN() { return getToken(TibboBasicParser.RPAREN, 0); }
		public TerminalNode BYVAL() { return getToken(TibboBasicParser.BYVAL, 0); }
		public TerminalNode BYREF() { return getToken(TibboBasicParser.BYREF, 0); }
		public AsTypeClauseContext asTypeClause() {
			return getRuleContext(AsTypeClauseContext.class,0);
		}
		public ParamContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_param; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterParam(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitParam(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitParam(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ParamContext param() throws RecognitionException {
		ParamContext _localctx = new ParamContext(_ctx, getState());
		enterRule(_localctx, 104, RULE_param);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(672);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case BYVAL:
				{
				setState(670);
				((ParamContext)_localctx).byval = match(BYVAL);
				}
				break;
			case BYREF:
				{
				setState(671);
				((ParamContext)_localctx).byref = match(BYREF);
				}
				break;
			case IDENTIFIER:
				break;
			default:
				break;
			}
			setState(674);
			((ParamContext)_localctx).name = match(IDENTIFIER);
			setState(678);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==LPAREN) {
				{
				setState(675);
				match(LPAREN);
				setState(676);
				match(INTEGERLITERAL);
				setState(677);
				match(RPAREN);
				}
			}

			setState(681);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==AS) {
				{
				setState(680);
				((ParamContext)_localctx).valueType = asTypeClause();
				}
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

	public static class AsTypeClauseContext extends ParserRuleContext {
		public TypeContext valueType;
		public TerminalNode AS() { return getToken(TibboBasicParser.AS, 0); }
		public TypeContext type() {
			return getRuleContext(TypeContext.class,0);
		}
		public TerminalNode ENUM() { return getToken(TibboBasicParser.ENUM, 0); }
		public FieldLengthContext fieldLength() {
			return getRuleContext(FieldLengthContext.class,0);
		}
		public AsTypeClauseContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_asTypeClause; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterAsTypeClause(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitAsTypeClause(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitAsTypeClause(this);
			else return visitor.visitChildren(this);
		}
	}

	public final AsTypeClauseContext asTypeClause() throws RecognitionException {
		AsTypeClauseContext _localctx = new AsTypeClauseContext(_ctx, getState());
		enterRule(_localctx, 106, RULE_asTypeClause);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(683);
			match(AS);
			setState(685);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==ENUM) {
				{
				setState(684);
				match(ENUM);
				}
			}

			setState(687);
			((AsTypeClauseContext)_localctx).valueType = type();
			setState(689);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==MULT) {
				{
				setState(688);
				fieldLength();
				}
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

	public static class BaseTypeContext extends ParserRuleContext {
		public TerminalNode CHAR() { return getToken(TibboBasicParser.CHAR, 0); }
		public TerminalNode SHORT() { return getToken(TibboBasicParser.SHORT, 0); }
		public TerminalNode WORD() { return getToken(TibboBasicParser.WORD, 0); }
		public TerminalNode DWORD() { return getToken(TibboBasicParser.DWORD, 0); }
		public TerminalNode FLOAT() { return getToken(TibboBasicParser.FLOAT, 0); }
		public TerminalNode REAL() { return getToken(TibboBasicParser.REAL, 0); }
		public TerminalNode BOOLEAN() { return getToken(TibboBasicParser.BOOLEAN, 0); }
		public TerminalNode BYTE() { return getToken(TibboBasicParser.BYTE, 0); }
		public TerminalNode INTEGER() { return getToken(TibboBasicParser.INTEGER, 0); }
		public TerminalNode LONG() { return getToken(TibboBasicParser.LONG, 0); }
		public TerminalNode STRING() { return getToken(TibboBasicParser.STRING, 0); }
		public TerminalNode MULT() { return getToken(TibboBasicParser.MULT, 0); }
		public ExpressionContext expression() {
			return getRuleContext(ExpressionContext.class,0);
		}
		public List<TerminalNode> WS() { return getTokens(TibboBasicParser.WS); }
		public TerminalNode WS(int i) {
			return getToken(TibboBasicParser.WS, i);
		}
		public BaseTypeContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_baseType; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterBaseType(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitBaseType(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitBaseType(this);
			else return visitor.visitChildren(this);
		}
	}

	public final BaseTypeContext baseType() throws RecognitionException {
		BaseTypeContext _localctx = new BaseTypeContext(_ctx, getState());
		enterRule(_localctx, 108, RULE_baseType);
		int _la;
		try {
			setState(712);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case CHAR:
				enterOuterAlt(_localctx, 1);
				{
				setState(691);
				match(CHAR);
				}
				break;
			case SHORT:
				enterOuterAlt(_localctx, 2);
				{
				setState(692);
				match(SHORT);
				}
				break;
			case WORD:
				enterOuterAlt(_localctx, 3);
				{
				setState(693);
				match(WORD);
				}
				break;
			case DWORD:
				enterOuterAlt(_localctx, 4);
				{
				setState(694);
				match(DWORD);
				}
				break;
			case FLOAT:
				enterOuterAlt(_localctx, 5);
				{
				setState(695);
				match(FLOAT);
				}
				break;
			case REAL:
				enterOuterAlt(_localctx, 6);
				{
				setState(696);
				match(REAL);
				}
				break;
			case BOOLEAN:
				enterOuterAlt(_localctx, 7);
				{
				setState(697);
				match(BOOLEAN);
				}
				break;
			case BYTE:
				enterOuterAlt(_localctx, 8);
				{
				setState(698);
				match(BYTE);
				}
				break;
			case INTEGER:
				enterOuterAlt(_localctx, 9);
				{
				setState(699);
				match(INTEGER);
				}
				break;
			case LONG:
				enterOuterAlt(_localctx, 10);
				{
				setState(700);
				match(LONG);
				}
				break;
			case STRING:
				enterOuterAlt(_localctx, 11);
				{
				setState(701);
				match(STRING);
				setState(710);
				_errHandler.sync(this);
				switch ( getInterpreter().adaptivePredict(_input,90,_ctx) ) {
				case 1:
					{
					setState(703);
					_errHandler.sync(this);
					_la = _input.LA(1);
					if (_la==WS) {
						{
						setState(702);
						match(WS);
						}
					}

					setState(705);
					match(MULT);
					setState(707);
					_errHandler.sync(this);
					_la = _input.LA(1);
					if (_la==WS) {
						{
						setState(706);
						match(WS);
						}
					}

					setState(709);
					expression(0);
					}
					break;
				}
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

	public static class ComplexTypeContext extends ParserRuleContext {
		public List<TerminalNode> IDENTIFIER() { return getTokens(TibboBasicParser.IDENTIFIER); }
		public TerminalNode IDENTIFIER(int i) {
			return getToken(TibboBasicParser.IDENTIFIER, i);
		}
		public List<TerminalNode> DOT() { return getTokens(TibboBasicParser.DOT); }
		public TerminalNode DOT(int i) {
			return getToken(TibboBasicParser.DOT, i);
		}
		public List<TerminalNode> BANG() { return getTokens(TibboBasicParser.BANG); }
		public TerminalNode BANG(int i) {
			return getToken(TibboBasicParser.BANG, i);
		}
		public ComplexTypeContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_complexType; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterComplexType(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitComplexType(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitComplexType(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ComplexTypeContext complexType() throws RecognitionException {
		ComplexTypeContext _localctx = new ComplexTypeContext(_ctx, getState());
		enterRule(_localctx, 110, RULE_complexType);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(714);
			match(IDENTIFIER);
			setState(719);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==DOT || _la==BANG) {
				{
				{
				setState(715);
				_la = _input.LA(1);
				if ( !(_la==DOT || _la==BANG) ) {
				_errHandler.recoverInline(this);
				}
				else {
					if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
					_errHandler.reportMatch(this);
					consume();
				}
				setState(716);
				match(IDENTIFIER);
				}
				}
				setState(721);
				_errHandler.sync(this);
				_la = _input.LA(1);
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

	public static class FieldLengthContext extends ParserRuleContext {
		public TerminalNode MULT() { return getToken(TibboBasicParser.MULT, 0); }
		public TerminalNode INTEGERLITERAL() { return getToken(TibboBasicParser.INTEGERLITERAL, 0); }
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public FieldLengthContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_fieldLength; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterFieldLength(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitFieldLength(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitFieldLength(this);
			else return visitor.visitChildren(this);
		}
	}

	public final FieldLengthContext fieldLength() throws RecognitionException {
		FieldLengthContext _localctx = new FieldLengthContext(_ctx, getState());
		enterRule(_localctx, 112, RULE_fieldLength);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(722);
			match(MULT);
			setState(723);
			_la = _input.LA(1);
			if ( !(_la==INTEGERLITERAL || _la==IDENTIFIER) ) {
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

	public static class LineLabelContext extends ParserRuleContext {
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public TerminalNode COLON() { return getToken(TibboBasicParser.COLON, 0); }
		public LineLabelContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_lineLabel; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterLineLabel(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitLineLabel(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitLineLabel(this);
			else return visitor.visitChildren(this);
		}
	}

	public final LineLabelContext lineLabel() throws RecognitionException {
		LineLabelContext _localctx = new LineLabelContext(_ctx, getState());
		enterRule(_localctx, 114, RULE_lineLabel);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(725);
			match(IDENTIFIER);
			setState(726);
			match(COLON);
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

	public static class LiteralContext extends ParserRuleContext {
		public TerminalNode HEXLITERAL() { return getToken(TibboBasicParser.HEXLITERAL, 0); }
		public TerminalNode BINLITERAL() { return getToken(TibboBasicParser.BINLITERAL, 0); }
		public List<TerminalNode> INTEGERLITERAL() { return getTokens(TibboBasicParser.INTEGERLITERAL); }
		public TerminalNode INTEGERLITERAL(int i) {
			return getToken(TibboBasicParser.INTEGERLITERAL, i);
		}
		public TerminalNode DOT2() { return getToken(TibboBasicParser.DOT2, 0); }
		public TerminalNode PLUS() { return getToken(TibboBasicParser.PLUS, 0); }
		public TerminalNode MINUS() { return getToken(TibboBasicParser.MINUS, 0); }
		public TerminalNode STRINGLITERAL() { return getToken(TibboBasicParser.STRINGLITERAL, 0); }
		public TerminalNode TemplateStringLiteral() { return getToken(TibboBasicParser.TemplateStringLiteral, 0); }
		public TerminalNode TRUE() { return getToken(TibboBasicParser.TRUE, 0); }
		public TerminalNode FALSE() { return getToken(TibboBasicParser.FALSE, 0); }
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public LiteralContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_literal; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterLiteral(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitLiteral(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitLiteral(this);
			else return visitor.visitChildren(this);
		}
	}

	public final LiteralContext literal() throws RecognitionException {
		LiteralContext _localctx = new LiteralContext(_ctx, getState());
		enterRule(_localctx, 116, RULE_literal);
		int _la;
		try {
			setState(747);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case HEXLITERAL:
				enterOuterAlt(_localctx, 1);
				{
				setState(728);
				match(HEXLITERAL);
				}
				break;
			case BINLITERAL:
				enterOuterAlt(_localctx, 2);
				{
				setState(729);
				match(BINLITERAL);
				}
				break;
			case INTEGERLITERAL:
			case MINUS:
			case PLUS:
				enterOuterAlt(_localctx, 3);
				{
				setState(731);
				_errHandler.sync(this);
				_la = _input.LA(1);
				if (_la==MINUS || _la==PLUS) {
					{
					setState(730);
					_la = _input.LA(1);
					if ( !(_la==MINUS || _la==PLUS) ) {
					_errHandler.recoverInline(this);
					}
					else {
						if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
						_errHandler.reportMatch(this);
						consume();
					}
					}
				}

				setState(739);
				_errHandler.sync(this);
				switch ( getInterpreter().adaptivePredict(_input,95,_ctx) ) {
				case 1:
					{
					setState(734); 
					_errHandler.sync(this);
					_la = _input.LA(1);
					do {
						{
						{
						setState(733);
						match(INTEGERLITERAL);
						}
						}
						setState(736); 
						_errHandler.sync(this);
						_la = _input.LA(1);
					} while ( _la==INTEGERLITERAL );
					setState(738);
					match(DOT2);
					}
					break;
				}
				setState(741);
				match(INTEGERLITERAL);
				}
				break;
			case STRINGLITERAL:
				enterOuterAlt(_localctx, 4);
				{
				setState(742);
				match(STRINGLITERAL);
				}
				break;
			case TemplateStringLiteral:
				enterOuterAlt(_localctx, 5);
				{
				setState(743);
				match(TemplateStringLiteral);
				}
				break;
			case TRUE:
				enterOuterAlt(_localctx, 6);
				{
				setState(744);
				match(TRUE);
				}
				break;
			case FALSE:
				enterOuterAlt(_localctx, 7);
				{
				setState(745);
				match(FALSE);
				}
				break;
			case IDENTIFIER:
				enterOuterAlt(_localctx, 8);
				{
				setState(746);
				match(IDENTIFIER);
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

	public static class ArrayLiteralContext extends ParserRuleContext {
		public TerminalNode L_CURLY_BRACKET() { return getToken(TibboBasicParser.L_CURLY_BRACKET, 0); }
		public TerminalNode R_CURLY_BRACKET() { return getToken(TibboBasicParser.R_CURLY_BRACKET, 0); }
		public List<LiteralContext> literal() {
			return getRuleContexts(LiteralContext.class);
		}
		public LiteralContext literal(int i) {
			return getRuleContext(LiteralContext.class,i);
		}
		public List<ArrayLiteralContext> arrayLiteral() {
			return getRuleContexts(ArrayLiteralContext.class);
		}
		public ArrayLiteralContext arrayLiteral(int i) {
			return getRuleContext(ArrayLiteralContext.class,i);
		}
		public List<TerminalNode> COMMA() { return getTokens(TibboBasicParser.COMMA); }
		public TerminalNode COMMA(int i) {
			return getToken(TibboBasicParser.COMMA, i);
		}
		public ArrayLiteralContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_arrayLiteral; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterArrayLiteral(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitArrayLiteral(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitArrayLiteral(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ArrayLiteralContext arrayLiteral() throws RecognitionException {
		ArrayLiteralContext _localctx = new ArrayLiteralContext(_ctx, getState());
		enterRule(_localctx, 118, RULE_arrayLiteral);
		int _la;
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(749);
			match(L_CURLY_BRACKET);
			setState(752);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case FALSE:
			case TRUE:
			case STRINGLITERAL:
			case TemplateStringLiteral:
			case HEXLITERAL:
			case BINLITERAL:
			case INTEGERLITERAL:
			case MINUS:
			case PLUS:
			case IDENTIFIER:
				{
				setState(750);
				literal();
				}
				break;
			case L_CURLY_BRACKET:
				{
				setState(751);
				arrayLiteral();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			setState(761);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,99,_ctx);
			while ( _alt!=2 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1 ) {
					{
					{
					setState(754);
					match(COMMA);
					setState(757);
					_errHandler.sync(this);
					switch (_input.LA(1)) {
					case FALSE:
					case TRUE:
					case STRINGLITERAL:
					case TemplateStringLiteral:
					case HEXLITERAL:
					case BINLITERAL:
					case INTEGERLITERAL:
					case MINUS:
					case PLUS:
					case IDENTIFIER:
						{
						setState(755);
						literal();
						}
						break;
					case L_CURLY_BRACKET:
						{
						setState(756);
						arrayLiteral();
						}
						break;
					default:
						throw new NoViableAltException(this);
					}
					}
					} 
				}
				setState(763);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,99,_ctx);
			}
			setState(765);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==COMMA) {
				{
				setState(764);
				match(COMMA);
				}
			}

			setState(767);
			match(R_CURLY_BRACKET);
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

	public static class TypeContext extends ParserRuleContext {
		public BaseTypeContext baseType() {
			return getRuleContext(BaseTypeContext.class,0);
		}
		public ComplexTypeContext complexType() {
			return getRuleContext(ComplexTypeContext.class,0);
		}
		public TerminalNode LPAREN() { return getToken(TibboBasicParser.LPAREN, 0); }
		public TerminalNode RPAREN() { return getToken(TibboBasicParser.RPAREN, 0); }
		public TerminalNode IDENTIFIER() { return getToken(TibboBasicParser.IDENTIFIER, 0); }
		public TerminalNode INTEGERLITERAL() { return getToken(TibboBasicParser.INTEGERLITERAL, 0); }
		public TypeContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_type; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterType(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitType(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitType(this);
			else return visitor.visitChildren(this);
		}
	}

	public final TypeContext type() throws RecognitionException {
		TypeContext _localctx = new TypeContext(_ctx, getState());
		enterRule(_localctx, 120, RULE_type);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(771);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case BOOLEAN:
			case REAL:
			case BYTE:
			case CHAR:
			case DWORD:
			case FLOAT:
			case INTEGER:
			case LONG:
			case SHORT:
			case STRING:
			case WORD:
				{
				setState(769);
				baseType();
				}
				break;
			case IDENTIFIER:
				{
				setState(770);
				complexType();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			setState(776);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,102,_ctx) ) {
			case 1:
				{
				setState(773);
				match(LPAREN);
				setState(774);
				_la = _input.LA(1);
				if ( !(_la==INTEGERLITERAL || _la==IDENTIFIER) ) {
				_errHandler.recoverInline(this);
				}
				else {
					if ( _input.LA(1)==Token.EOF ) matchedEOF = true;
					_errHandler.reportMatch(this);
					consume();
				}
				setState(775);
				match(RPAREN);
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

	public static class VisibilityContext extends ParserRuleContext {
		public TerminalNode PUBLIC() { return getToken(TibboBasicParser.PUBLIC, 0); }
		public VisibilityContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_visibility; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).enterVisibility(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TibboBasicParserListener ) ((TibboBasicParserListener)listener).exitVisibility(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TibboBasicParserVisitor ) return ((TibboBasicParserVisitor<? extends T>)visitor).visitVisibility(this);
			else return visitor.visitChildren(this);
		}
	}

	public final VisibilityContext visibility() throws RecognitionException {
		VisibilityContext _localctx = new VisibilityContext(_ctx, getState());
		enterRule(_localctx, 122, RULE_visibility);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(778);
			match(PUBLIC);
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
		case 38:
			return expression_sempred((ExpressionContext)_localctx, predIndex);
		case 41:
			return postfixExpression_sempred((PostfixExpressionContext)_localctx, predIndex);
		}
		return true;
	}
	private boolean expression_sempred(ExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
		case 0:
			return precpred(_ctx, 6);
		case 1:
			return precpred(_ctx, 5);
		case 2:
			return precpred(_ctx, 4);
		case 3:
			return precpred(_ctx, 3);
		case 4:
			return precpred(_ctx, 2);
		}
		return true;
	}
	private boolean postfixExpression_sempred(PostfixExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
		case 5:
			return precpred(_ctx, 1);
		}
		return true;
	}

	public static final String _serializedATN =
		"\3\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964\3\u0095\u030f\4\2\t"+
		"\2\4\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4\b\t\b\4\t\t\t\4\n\t\n\4\13"+
		"\t\13\4\f\t\f\4\r\t\r\4\16\t\16\4\17\t\17\4\20\t\20\4\21\t\21\4\22\t\22"+
		"\4\23\t\23\4\24\t\24\4\25\t\25\4\26\t\26\4\27\t\27\4\30\t\30\4\31\t\31"+
		"\4\32\t\32\4\33\t\33\4\34\t\34\4\35\t\35\4\36\t\36\4\37\t\37\4 \t \4!"+
		"\t!\4\"\t\"\4#\t#\4$\t$\4%\t%\4&\t&\4\'\t\'\4(\t(\4)\t)\4*\t*\4+\t+\4"+
		",\t,\4-\t-\4.\t.\4/\t/\4\60\t\60\4\61\t\61\4\62\t\62\4\63\t\63\4\64\t"+
		"\64\4\65\t\65\4\66\t\66\4\67\t\67\48\t8\49\t9\4:\t:\4;\t;\4<\t<\4=\t="+
		"\4>\t>\4?\t?\3\2\7\2\u0080\n\2\f\2\16\2\u0083\13\2\3\2\3\2\3\3\3\3\3\3"+
		"\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\5\3\u0096\n\3\3\4\3\4"+
		"\3\4\3\5\3\5\3\5\3\6\5\6\u009f\n\6\3\6\7\6\u00a2\n\6\f\6\16\6\u00a5\13"+
		"\6\3\7\3\7\3\7\3\7\3\7\3\7\3\7\3\7\3\7\3\7\5\7\u00b1\n\7\3\b\3\b\3\b\3"+
		"\b\7\b\u00b7\n\b\f\b\16\b\u00ba\13\b\3\t\3\t\5\t\u00be\n\t\3\t\3\t\3\t"+
		"\3\n\5\n\u00c4\n\n\3\n\3\n\3\n\3\13\3\13\3\13\3\13\5\13\u00cd\n\13\3\13"+
		"\3\13\5\13\u00d1\n\13\3\f\3\f\3\f\3\f\5\f\u00d7\n\f\3\f\3\f\5\f\u00db"+
		"\n\f\3\f\3\f\3\r\3\r\3\r\3\r\3\r\3\r\3\r\3\r\3\r\3\r\3\r\3\r\3\r\3\r\3"+
		"\r\3\r\5\r\u00ef\n\r\3\16\3\16\3\16\7\16\u00f4\n\16\f\16\16\16\u00f7\13"+
		"\16\3\16\3\16\3\17\3\17\3\17\5\17\u00fe\n\17\3\17\5\17\u0101\n\17\3\20"+
		"\3\20\3\21\3\21\3\21\3\21\3\21\3\21\5\21\u010b\n\21\3\21\3\21\3\21\5\21"+
		"\u0110\n\21\3\22\5\22\u0113\n\22\3\22\3\22\3\22\5\22\u0118\n\22\3\22\3"+
		"\22\5\22\u011c\n\22\3\22\3\22\3\22\3\22\3\23\3\23\5\23\u0124\n\23\3\24"+
		"\3\24\3\24\3\25\3\25\3\25\3\25\3\25\5\25\u012e\n\25\3\25\3\25\3\25\5\25"+
		"\u0133\n\25\5\25\u0135\n\25\3\25\3\25\3\25\3\25\3\25\3\25\6\25\u013d\n"+
		"\25\r\25\16\25\u013e\3\25\3\25\3\25\3\25\3\25\3\25\7\25\u0147\n\25\f\25"+
		"\16\25\u014a\13\25\3\25\3\25\5\25\u014e\n\25\3\25\3\25\5\25\u0152\n\25"+
		"\3\26\3\26\3\27\3\27\5\27\u0158\n\27\3\27\3\27\3\27\3\27\7\27\u015e\n"+
		"\27\f\27\16\27\u0161\13\27\3\27\3\27\3\30\3\30\5\30\u0167\n\30\3\31\3"+
		"\31\3\31\3\31\3\31\3\31\3\31\3\31\5\31\u0171\n\31\5\31\u0173\n\31\5\31"+
		"\u0175\n\31\3\31\3\31\3\31\3\32\3\32\3\32\3\32\3\32\3\32\3\32\3\32\5\32"+
		"\u0182\n\32\5\32\u0184\n\32\5\32\u0186\n\32\3\32\3\32\3\32\3\33\3\33\3"+
		"\33\3\33\3\33\3\33\5\33\u0191\n\33\3\34\3\34\3\34\3\34\3\34\3\34\5\34"+
		"\u0199\n\34\5\34\u019b\n\34\5\34\u019d\n\34\3\34\3\34\3\34\5\34\u01a2"+
		"\n\34\3\35\3\35\5\35\u01a6\n\35\3\35\3\35\5\35\u01aa\n\35\3\35\5\35\u01ad"+
		"\n\35\3\36\3\36\3\36\5\36\u01b2\n\36\3\36\3\36\5\36\u01b6\n\36\3\36\5"+
		"\36\u01b9\n\36\3\37\3\37\3\37\3\37\7\37\u01bf\n\37\f\37\16\37\u01c2\13"+
		"\37\5\37\u01c4\n\37\3\37\3\37\3 \5 \u01c9\n \3 \3 \5 \u01cd\n \3!\3!\3"+
		"!\3!\5!\u01d3\n!\3!\7!\u01d6\n!\f!\16!\u01d9\13!\3!\5!\u01dc\n!\3!\3!"+
		"\3\"\3\"\3\"\3\"\7\"\u01e4\n\"\f\"\16\"\u01e7\13\"\3\"\5\"\u01ea\n\"\3"+
		"\"\3\"\3#\3#\5#\u01f0\n#\3#\3#\3$\3$\3%\5%\u01f7\n%\3%\3%\3%\5%\u01fc"+
		"\n%\3%\3%\5%\u0200\n%\3%\3%\3%\3&\5&\u0206\n&\3&\3&\3&\7&\u020b\n&\f&"+
		"\16&\u020e\13&\3&\3&\3\'\3\'\3\'\3\'\3\'\5\'\u0217\n\'\3\'\3\'\3(\3(\3"+
		"(\3(\3(\3(\5(\u0221\n(\3(\3(\3(\3(\3(\3(\3(\3(\3(\3(\3(\3(\3(\3(\3(\7"+
		"(\u0232\n(\f(\16(\u0235\13(\3)\3)\3)\3)\5)\u023b\n)\3*\3*\3+\3+\3+\7+"+
		"\u0242\n+\f+\16+\u0245\13+\3+\3+\3+\3+\7+\u024b\n+\f+\16+\u024e\13+\7"+
		"+\u0250\n+\f+\16+\u0253\13+\3,\3,\3-\3-\3-\3-\3-\5-\u025c\n-\3.\5.\u025f"+
		"\n.\3.\3.\3.\3/\3/\3/\5/\u0267\n/\7/\u0269\n/\f/\16/\u026c\13/\3/\3/\3"+
		"/\3/\5/\u0272\n/\5/\u0274\n/\3\60\3\60\3\60\3\60\3\60\5\60\u027b\n\60"+
		"\3\61\3\61\3\61\3\61\3\61\3\62\3\62\3\62\3\63\3\63\3\63\3\63\7\63\u0289"+
		"\n\63\f\63\16\63\u028c\13\63\5\63\u028e\n\63\3\63\3\63\3\64\3\64\3\65"+
		"\3\65\3\65\3\65\7\65\u0298\n\65\f\65\16\65\u029b\13\65\5\65\u029d\n\65"+
		"\3\65\3\65\3\66\3\66\5\66\u02a3\n\66\3\66\3\66\3\66\3\66\5\66\u02a9\n"+
		"\66\3\66\5\66\u02ac\n\66\3\67\3\67\5\67\u02b0\n\67\3\67\3\67\5\67\u02b4"+
		"\n\67\38\38\38\38\38\38\38\38\38\38\38\38\58\u02c2\n8\38\38\58\u02c6\n"+
		"8\38\58\u02c9\n8\58\u02cb\n8\39\39\39\79\u02d0\n9\f9\169\u02d3\139\3:"+
		"\3:\3:\3;\3;\3;\3<\3<\3<\5<\u02de\n<\3<\6<\u02e1\n<\r<\16<\u02e2\3<\5"+
		"<\u02e6\n<\3<\3<\3<\3<\3<\3<\5<\u02ee\n<\3=\3=\3=\5=\u02f3\n=\3=\3=\3"+
		"=\5=\u02f8\n=\7=\u02fa\n=\f=\16=\u02fd\13=\3=\5=\u0300\n=\3=\3=\3>\3>"+
		"\5>\u0306\n>\3>\3>\3>\5>\u030b\n>\3?\3?\3?\2\4NT@\2\4\6\b\n\f\16\20\22"+
		"\24\26\30\32\34\36 \"$&(*,.\60\62\64\668:<>@BDFHJLNPRTVXZ\\^`bdfhjlnp"+
		"rtvxz|\2\16\4\2JJLL\3\2\"\'\4\2PPpp\4\2\b\b\n\n\5\2\66\66UU]]\4\2\\\\"+
		"__\4\2WY[[\4\2VV^^\7\2\4\489>>@@NN\4\288\\\\\3\2kl\4\2TTpp\2\u0360\2\u0081"+
		"\3\2\2\2\4\u0095\3\2\2\2\6\u0097\3\2\2\2\b\u009a\3\2\2\2\n\u00a3\3\2\2"+
		"\2\f\u00b0\3\2\2\2\16\u00b2\3\2\2\2\20\u00bb\3\2\2\2\22\u00c3\3\2\2\2"+
		"\24\u00c8\3\2\2\2\26\u00d2\3\2\2\2\30\u00ee\3\2\2\2\32\u00f0\3\2\2\2\34"+
		"\u00fa\3\2\2\2\36\u0102\3\2\2\2 \u0104\3\2\2\2\"\u0112\3\2\2\2$\u0123"+
		"\3\2\2\2&\u0125\3\2\2\2(\u0151\3\2\2\2*\u0153\3\2\2\2,\u0155\3\2\2\2."+
		"\u0166\3\2\2\2\60\u0168\3\2\2\2\62\u0179\3\2\2\2\64\u018a\3\2\2\2\66\u0192"+
		"\3\2\2\28\u01a5\3\2\2\2:\u01ae\3\2\2\2<\u01ba\3\2\2\2>\u01c8\3\2\2\2@"+
		"\u01ce\3\2\2\2B\u01df\3\2\2\2D\u01ed\3\2\2\2F\u01f3\3\2\2\2H\u01f6\3\2"+
		"\2\2J\u0205\3\2\2\2L\u0211\3\2\2\2N\u0220\3\2\2\2P\u023a\3\2\2\2R\u023c"+
		"\3\2\2\2T\u023e\3\2\2\2V\u0254\3\2\2\2X\u025b\3\2\2\2Z\u025e\3\2\2\2\\"+
		"\u0263\3\2\2\2^\u0275\3\2\2\2`\u027c\3\2\2\2b\u0281\3\2\2\2d\u0284\3\2"+
		"\2\2f\u0291\3\2\2\2h\u0293\3\2\2\2j\u02a2\3\2\2\2l\u02ad\3\2\2\2n\u02ca"+
		"\3\2\2\2p\u02cc\3\2\2\2r\u02d4\3\2\2\2t\u02d7\3\2\2\2v\u02ed\3\2\2\2x"+
		"\u02ef\3\2\2\2z\u0305\3\2\2\2|\u030c\3\2\2\2~\u0080\5\4\3\2\177~\3\2\2"+
		"\2\u0080\u0083\3\2\2\2\u0081\177\3\2\2\2\u0081\u0082\3\2\2\2\u0082\u0084"+
		"\3\2\2\2\u0083\u0081\3\2\2\2\u0084\u0085\7\2\2\3\u0085\3\3\2\2\2\u0086"+
		"\u0096\5\6\4\2\u0087\u0096\5\b\5\2\u0088\u0096\5\32\16\2\u0089\u0096\5"+
		"\16\b\2\u008a\u0096\5\24\13\2\u008b\u0096\5\26\f\2\u008c\u0096\5\22\n"+
		"\2\u008d\u0096\5Z.\2\u008e\u0096\5H%\2\u008f\u0096\5\"\22\2\u0090\u0096"+
		"\5b\62\2\u0091\u0096\5,\27\2\u0092\u0096\5\64\33\2\u0093\u0096\5\66\34"+
		"\2\u0094\u0096\5J&\2\u0095\u0086\3\2\2\2\u0095\u0087\3\2\2\2\u0095\u0088"+
		"\3\2\2\2\u0095\u0089\3\2\2\2\u0095\u008a\3\2\2\2\u0095\u008b\3\2\2\2\u0095"+
		"\u008c\3\2\2\2\u0095\u008d\3\2\2\2\u0095\u008e\3\2\2\2\u0095\u008f\3\2"+
		"\2\2\u0095\u0090\3\2\2\2\u0095\u0091\3\2\2\2\u0095\u0092\3\2\2\2\u0095"+
		"\u0093\3\2\2\2\u0095\u0094\3\2\2\2\u0096\5\3\2\2\2\u0097\u0098\7\61\2"+
		"\2\u0098\u0099\7P\2\2\u0099\7\3\2\2\2\u009a\u009b\7\62\2\2\u009b\u009c"+
		"\7P\2\2\u009c\t\3\2\2\2\u009d\u009f\5t;\2\u009e\u009d\3\2\2\2\u009e\u009f"+
		"\3\2\2\2\u009f\u00a0\3\2\2\2\u00a0\u00a2\5\f\7\2\u00a1\u009e\3\2\2\2\u00a2"+
		"\u00a5\3\2\2\2\u00a3\u00a1\3\2\2\2\u00a3\u00a4\3\2\2\2\u00a4\13\3\2\2"+
		"\2\u00a5\u00a3\3\2\2\2\u00a6\u00b1\5t;\2\u00a7\u00b1\5\16\b\2\u00a8\u00b1"+
		"\5\30\r\2\u00a9\u00b1\5 \21\2\u00aa\u00b1\5$\23\2\u00ab\u00b1\5(\25\2"+
		"\u00ac\u00b1\5@!\2\u00ad\u00b1\5Z.\2\u00ae\u00b1\5`\61\2\u00af\u00b1\5"+
		"N(\2\u00b0\u00a6\3\2\2\2\u00b0\u00a7\3\2\2\2\u00b0\u00a8\3\2\2\2\u00b0"+
		"\u00a9\3\2\2\2\u00b0\u00aa\3\2\2\2\u00b0\u00ab\3\2\2\2\u00b0\u00ac\3\2"+
		"\2\2\u00b0\u00ad\3\2\2\2\u00b0\u00ae\3\2\2\2\u00b0\u00af\3\2\2\2\u00b1"+
		"\r\3\2\2\2\u00b2\u00b3\7\16\2\2\u00b3\u00b8\5\20\t\2\u00b4\u00b5\7j\2"+
		"\2\u00b5\u00b7\5\20\t\2\u00b6\u00b4\3\2\2\2\u00b7\u00ba\3\2\2\2\u00b8"+
		"\u00b6\3\2\2\2\u00b8\u00b9\3\2\2\2\u00b9\17\3\2\2\2\u00ba\u00b8\3\2\2"+
		"\2\u00bb\u00bd\7p\2\2\u00bc\u00be\5l\67\2\u00bd\u00bc\3\2\2\2\u00bd\u00be"+
		"\3\2\2\2\u00be\u00bf\3\2\2\2\u00bf\u00c0\7V\2\2\u00c0\u00c1\5N(\2\u00c1"+
		"\21\3\2\2\2\u00c2\u00c4\5|?\2\u00c3\u00c2\3\2\2\2\u00c3\u00c4\3\2\2\2"+
		"\u00c4\u00c5\3\2\2\2\u00c5\u00c6\7\20\2\2\u00c6\u00c7\5\\/\2\u00c7\23"+
		"\3\2\2\2\u00c8\u00c9\7\20\2\2\u00c9\u00cc\7D\2\2\u00ca\u00cb\7p\2\2\u00cb"+
		"\u00cd\7k\2\2\u00cc\u00ca\3\2\2\2\u00cc\u00cd\3\2\2\2\u00cd\u00ce\3\2"+
		"\2\2\u00ce\u00d0\7p\2\2\u00cf\u00d1\5h\65\2\u00d0\u00cf\3\2\2\2\u00d0"+
		"\u00d1\3\2\2\2\u00d1\25\3\2\2\2\u00d2\u00d3\7\20\2\2\u00d3\u00d6\7+\2"+
		"\2\u00d4\u00d5\7p\2\2\u00d5\u00d7\7k\2\2\u00d6\u00d4\3\2\2\2\u00d6\u00d7"+
		"\3\2\2\2\u00d7\u00d8\3\2\2\2\u00d8\u00da\7p\2\2\u00d9\u00db\5h\65\2\u00da"+
		"\u00d9\3\2\2\2\u00da\u00db\3\2\2\2\u00db\u00dc\3\2\2\2\u00dc\u00dd\5l"+
		"\67\2\u00dd\27\3\2\2\2\u00de\u00df\7\22\2\2\u00df\u00e0\5\n\6\2\u00e0"+
		"\u00e1\7\65\2\2\u00e1\u00ef\3\2\2\2\u00e2\u00e3\7\22\2\2\u00e3\u00e4\t"+
		"\2\2\2\u00e4\u00e5\5N(\2\u00e5\u00e6\5\n\6\2\u00e6\u00e7\7\65\2\2\u00e7"+
		"\u00ef\3\2\2\2\u00e8\u00e9\7\22\2\2\u00e9\u00ea\5\n\6\2\u00ea\u00eb\7"+
		"\65\2\2\u00eb\u00ec\t\2\2\2\u00ec\u00ed\5N(\2\u00ed\u00ef\3\2\2\2\u00ee"+
		"\u00de\3\2\2\2\u00ee\u00e2\3\2\2\2\u00ee\u00e8\3\2\2\2\u00ef\31\3\2\2"+
		"\2\u00f0\u00f1\7\30\2\2\u00f1\u00f5\7p\2\2\u00f2\u00f4\5\34\17\2\u00f3"+
		"\u00f2\3\2\2\2\u00f4\u00f7\3\2\2\2\u00f5\u00f3\3\2\2\2\u00f5\u00f6\3\2"+
		"\2\2\u00f6\u00f8\3\2\2\2\u00f7\u00f5\3\2\2\2\u00f8\u00f9\7\31\2\2\u00f9"+
		"\33\3\2\2\2\u00fa\u00fd\7p\2\2\u00fb\u00fc\7V\2\2\u00fc\u00fe\5N(\2\u00fd"+
		"\u00fb\3\2\2\2\u00fd\u00fe\3\2\2\2\u00fe\u0100\3\2\2\2\u00ff\u0101\7j"+
		"\2\2\u0100\u00ff\3\2\2\2\u0100\u0101\3\2\2\2\u0101\35\3\2\2\2\u0102\u0103"+
		"\t\3\2\2\u0103\37\3\2\2\2\u0104\u0105\7*\2\2\u0105\u0106\5N(\2\u0106\u0107"+
		"\7F\2\2\u0107\u010a\5N(\2\u0108\u0109\7B\2\2\u0109\u010b\5N(\2\u010a\u0108"+
		"\3\2\2\2\u010a\u010b\3\2\2\2\u010b\u010c\3\2\2\2\u010c\u010d\5\n\6\2\u010d"+
		"\u010f\7\67\2\2\u010e\u0110\5N(\2\u010f\u010e\3\2\2\2\u010f\u0110\3\2"+
		"\2\2\u0110!\3\2\2\2\u0111\u0113\5|?\2\u0112\u0111\3\2\2\2\u0112\u0113"+
		"\3\2\2\2\u0113\u0114\3\2\2\2\u0114\u0117\7+\2\2\u0115\u0116\7p\2\2\u0116"+
		"\u0118\7k\2\2\u0117\u0115\3\2\2\2\u0117\u0118\3\2\2\2\u0118\u0119\3\2"+
		"\2\2\u0119\u011b\7p\2\2\u011a\u011c\5h\65\2\u011b\u011a\3\2\2\2\u011b"+
		"\u011c\3\2\2\2\u011c\u011d\3\2\2\2\u011d\u011e\5l\67\2\u011e\u011f\5\n"+
		"\6\2\u011f\u0120\7\32\2\2\u0120#\3\2\2\2\u0121\u0124\5&\24\2\u0122\u0124"+
		"\5\36\20\2\u0123\u0121\3\2\2\2\u0123\u0122\3\2\2\2\u0124%\3\2\2\2\u0125"+
		"\u0126\7-\2\2\u0126\u0127\7p\2\2\u0127\'\3\2\2\2\u0128\u0129\7.\2\2\u0129"+
		"\u012a\5N(\2\u012a\u012d\7E\2\2\u012b\u012e\5\f\7\2\u012c\u012e\5$\23"+
		"\2\u012d\u012b\3\2\2\2\u012d\u012c\3\2\2\2\u012e\u0134\3\2\2\2\u012f\u0132"+
		"\7\24\2\2\u0130\u0133\5\f\7\2\u0131\u0133\5$\23\2\u0132\u0130\3\2\2\2"+
		"\u0132\u0131\3\2\2\2\u0133\u0135\3\2\2\2\u0134\u012f\3\2\2\2\u0134\u0135"+
		"\3\2\2\2\u0135\u0136\3\2\2\2\u0136\u0137\7e\2\2\u0137\u0152\3\2\2\2\u0138"+
		"\u0139\7.\2\2\u0139\u013a\5N(\2\u013a\u013c\7E\2\2\u013b\u013d\7e\2\2"+
		"\u013c\u013b\3\2\2\2\u013d\u013e\3\2\2\2\u013e\u013c\3\2\2\2\u013e\u013f"+
		"\3\2\2\2\u013f\u0140\3\2\2\2\u0140\u0148\5\n\6\2\u0141\u0142\7\27\2\2"+
		"\u0142\u0143\5*\26\2\u0143\u0144\7E\2\2\u0144\u0145\5\n\6\2\u0145\u0147"+
		"\3\2\2\2\u0146\u0141\3\2\2\2\u0147\u014a\3\2\2\2\u0148\u0146\3\2\2\2\u0148"+
		"\u0149\3\2\2\2\u0149\u014d\3\2\2\2\u014a\u0148\3\2\2\2\u014b\u014c\7\24"+
		"\2\2\u014c\u014e\5\n\6\2\u014d\u014b\3\2\2\2\u014d\u014e\3\2\2\2\u014e"+
		"\u014f\3\2\2\2\u014f\u0150\7\33\2\2\u0150\u0152\3\2\2\2\u0151\u0128\3"+
		"\2\2\2\u0151\u0138\3\2\2\2\u0152)\3\2\2\2\u0153\u0154\5N(\2\u0154+\3\2"+
		"\2\2\u0155\u0157\7:\2\2\u0156\u0158\7l\2\2\u0157\u0156\3\2\2\2\u0157\u0158"+
		"\3\2\2\2\u0158\u0159\3\2\2\2\u0159\u015a\7p\2\2\u015a\u015b\7k\2\2\u015b"+
		"\u015f\7p\2\2\u015c\u015e\5.\30\2\u015d\u015c\3\2\2\2\u015e\u0161\3\2"+
		"\2\2\u015f\u015d\3\2\2\2\u015f\u0160\3\2\2\2\u0160\u0162\3\2\2\2\u0161"+
		"\u015f\3\2\2\2\u0162\u0163\7\34\2\2\u0163-\3\2\2\2\u0164\u0167\5\60\31"+
		"\2\u0165\u0167\5\62\32\2\u0166\u0164\3\2\2\2\u0166\u0165\3\2\2\2\u0167"+
		"/\3\2\2\2\u0168\u0169\7,\2\2\u0169\u016a\7V\2\2\u016a\u016b\7n\2\2\u016b"+
		"\u0174\7Z\2\2\u016c\u0172\7T\2\2\u016d\u016e\7j\2\2\u016e\u0170\t\4\2"+
		"\2\u016f\u0171\7_\2\2\u0170\u016f\3\2\2\2\u0170\u0171\3\2\2\2\u0171\u0173"+
		"\3\2\2\2\u0172\u016d\3\2\2\2\u0172\u0173\3\2\2\2\u0173\u0175\3\2\2\2\u0174"+
		"\u016c\3\2\2\2\u0174\u0175\3\2\2\2\u0175\u0176\3\2\2\2\u0176\u0177\7`"+
		"\2\2\u0177\u0178\5l\67\2\u0178\61\3\2\2\2\u0179\u017a\7=\2\2\u017a\u017b"+
		"\7V\2\2\u017b\u017c\7n\2\2\u017c\u0185\7Z\2\2\u017d\u0183\7T\2\2\u017e"+
		"\u017f\7j\2\2\u017f\u0181\t\4\2\2\u0180\u0182\7_\2\2\u0181\u0180\3\2\2"+
		"\2\u0181\u0182\3\2\2\2\u0182\u0184\3\2\2\2\u0183\u017e\3\2\2\2\u0183\u0184"+
		"\3\2\2\2\u0184\u0186\3\2\2\2\u0185\u017d\3\2\2\2\u0185\u0186\3\2\2\2\u0186"+
		"\u0187\3\2\2\2\u0187\u0188\7`\2\2\u0188\u0189\5h\65\2\u0189\63\3\2\2\2"+
		"\u018a\u018b\7!\2\2\u018b\u018c\7Z\2\2\u018c\u018d\7T\2\2\u018d\u018e"+
		"\7`\2\2\u018e\u0190\7p\2\2\u018f\u0191\5h\65\2\u0190\u018f\3\2\2\2\u0190"+
		"\u0191\3\2\2\2\u0191\65\3\2\2\2\u0192\u0193\7n\2\2\u0193\u019c\7Z\2\2"+
		"\u0194\u019a\7T\2\2\u0195\u0196\7j\2\2\u0196\u0198\t\4\2\2\u0197\u0199"+
		"\7_\2\2\u0198\u0197\3\2\2\2\u0198\u0199\3\2\2\2\u0199\u019b\3\2\2\2\u019a"+
		"\u0195\3\2\2\2\u019a\u019b\3\2\2\2\u019b\u019d\3\2\2\2\u019c\u0194\3\2"+
		"\2\2\u019c\u019d\3\2\2\2\u019d\u019e\3\2\2\2\u019e\u01a1\7`\2\2\u019f"+
		"\u01a2\58\35\2\u01a0\u01a2\5:\36\2\u01a1\u019f\3\2\2\2\u01a1\u01a0\3\2"+
		"\2\2\u01a2\67\3\2\2\2\u01a3\u01a4\7p\2\2\u01a4\u01a6\7k\2\2\u01a5\u01a3"+
		"\3\2\2\2\u01a5\u01a6\3\2\2\2\u01a6\u01a7\3\2\2\2\u01a7\u01a9\7p\2\2\u01a8"+
		"\u01aa\5h\65\2\u01a9\u01a8\3\2\2\2\u01a9\u01aa\3\2\2\2\u01aa\u01ac\3\2"+
		"\2\2\u01ab\u01ad\5l\67\2\u01ac\u01ab\3\2\2\2\u01ac\u01ad\3\2\2\2\u01ad"+
		"9\3\2\2\2\u01ae\u01b1\7l\2\2\u01af\u01b0\7p\2\2\u01b0\u01b2\7k\2\2\u01b1"+
		"\u01af\3\2\2\2\u01b1\u01b2\3\2\2\2\u01b2\u01b3\3\2\2\2\u01b3\u01b5\7p"+
		"\2\2\u01b4\u01b6\5<\37\2\u01b5\u01b4\3\2\2\2\u01b5\u01b6\3\2\2\2\u01b6"+
		"\u01b8\3\2\2\2\u01b7\u01b9\5l\67\2\u01b8\u01b7\3\2\2\2\u01b8\u01b9\3\2"+
		"\2\2\u01b9;\3\2\2\2\u01ba\u01c3\7Z\2\2\u01bb\u01c0\5> \2\u01bc\u01bd\7"+
		"j\2\2\u01bd\u01bf\5> \2\u01be\u01bc\3\2\2\2\u01bf\u01c2\3\2\2\2\u01c0"+
		"\u01be\3\2\2\2\u01c0\u01c1\3\2\2\2\u01c1\u01c4\3\2\2\2\u01c2\u01c0\3\2"+
		"\2\2\u01c3\u01bb\3\2\2\2\u01c3\u01c4\3\2\2\2\u01c4\u01c5\3\2\2\2\u01c5"+
		"\u01c6\7`\2\2\u01c6=\3\2\2\2\u01c7\u01c9\t\5\2\2\u01c8\u01c7\3\2\2\2\u01c8"+
		"\u01c9\3\2\2\2\u01c9\u01ca\3\2\2\2\u01ca\u01cc\7p\2\2\u01cb\u01cd\5l\67"+
		"\2\u01cc\u01cb\3\2\2\2\u01cc\u01cd\3\2\2\2\u01cd?\3\2\2\2\u01ce\u01cf"+
		"\7<\2\2\u01cf\u01d0\7\13\2\2\u01d0\u01d2\5N(\2\u01d1\u01d3\7h\2\2\u01d2"+
		"\u01d1\3\2\2\2\u01d2\u01d3\3\2\2\2\u01d3\u01d7\3\2\2\2\u01d4\u01d6\5B"+
		"\"\2\u01d5\u01d4\3\2\2\2\u01d6\u01d9\3\2\2\2\u01d7\u01d5\3\2\2\2\u01d7"+
		"\u01d8\3\2\2\2\u01d8\u01db\3\2\2\2\u01d9\u01d7\3\2\2\2\u01da\u01dc\5D"+
		"#\2\u01db\u01da\3\2\2\2\u01db\u01dc\3\2\2\2\u01dc\u01dd\3\2\2\2\u01dd"+
		"\u01de\7\35\2\2\u01deA\3\2\2\2\u01df\u01e0\7\13\2\2\u01e0\u01e5\5F$\2"+
		"\u01e1\u01e2\7j\2\2\u01e2\u01e4\5F$\2\u01e3\u01e1\3\2\2\2\u01e4\u01e7"+
		"\3\2\2\2\u01e5\u01e3\3\2\2\2\u01e5\u01e6\3\2\2\2\u01e6\u01e9\3\2\2\2\u01e7"+
		"\u01e5\3\2\2\2\u01e8\u01ea\7h\2\2\u01e9\u01e8\3\2\2\2\u01e9\u01ea\3\2"+
		"\2\2\u01ea\u01eb\3\2\2\2\u01eb\u01ec\5\n\6\2\u01ecC\3\2\2\2\u01ed\u01ef"+
		"\7\f\2\2\u01ee\u01f0\7h\2\2\u01ef\u01ee\3\2\2\2\u01ef\u01f0\3\2\2\2\u01f0"+
		"\u01f1\3\2\2\2\u01f1\u01f2\5\n\6\2\u01f2E\3\2\2\2\u01f3\u01f4\5N(\2\u01f4"+
		"G\3\2\2\2\u01f5\u01f7\5|?\2\u01f6\u01f5\3\2\2\2\u01f6\u01f7\3\2\2\2\u01f7"+
		"\u01f8\3\2\2\2\u01f8\u01fb\7D\2\2\u01f9\u01fa\7p\2\2\u01fa\u01fc\7k\2"+
		"\2\u01fb\u01f9\3\2\2\2\u01fb\u01fc\3\2\2\2\u01fc\u01fd\3\2\2\2\u01fd\u01ff"+
		"\7p\2\2\u01fe\u0200\5h\65\2\u01ff\u01fe\3\2\2\2\u01ff\u0200\3\2\2\2\u0200"+
		"\u0201\3\2\2\2\u0201\u0202\5\n\6\2\u0202\u0203\7\36\2\2\u0203I\3\2\2\2"+
		"\u0204\u0206\5|?\2\u0205\u0204\3\2\2\2\u0205\u0206\3\2\2\2\u0206\u0207"+
		"\3\2\2\2\u0207\u0208\7H\2\2\u0208\u020c\7p\2\2\u0209\u020b\5L\'\2\u020a"+
		"\u0209\3\2\2\2\u020b\u020e\3\2\2\2\u020c\u020a\3\2\2\2\u020c\u020d\3\2"+
		"\2\2\u020d\u020f\3\2\2\2\u020e\u020c\3\2\2\2\u020f\u0210\7\37\2\2\u0210"+
		"K\3\2\2\2\u0211\u0216\7p\2\2\u0212\u0213\7Z\2\2\u0213\u0214\5v<\2\u0214"+
		"\u0215\7`\2\2\u0215\u0217\3\2\2\2\u0216\u0212\3\2\2\2\u0216\u0217\3\2"+
		"\2\2\u0217\u0218\3\2\2\2\u0218\u0219\5l\67\2\u0219M\3\2\2\2\u021a\u021b"+
		"\b(\1\2\u021b\u0221\5P)\2\u021c\u021d\7Z\2\2\u021d\u021e\5N(\2\u021e\u021f"+
		"\7`\2\2\u021f\u0221\3\2\2\2\u0220\u021a\3\2\2\2\u0220\u021c\3\2\2\2\u0221"+
		"\u0233\3\2\2\2\u0222\u0223\f\b\2\2\u0223\u0224\t\6\2\2\u0224\u0232\5N"+
		"(\t\u0225\u0226\f\7\2\2\u0226\u0227\t\7\2\2\u0227\u0232\5N(\b\u0228\u0229"+
		"\f\6\2\2\u0229\u022a\t\b\2\2\u022a\u0232\5N(\7\u022b\u022c\f\5\2\2\u022c"+
		"\u022d\t\t\2\2\u022d\u0232\5N(\6\u022e\u022f\f\4\2\2\u022f\u0230\t\n\2"+
		"\2\u0230\u0232\5N(\5\u0231\u0222\3\2\2\2\u0231\u0225\3\2\2\2\u0231\u0228"+
		"\3\2\2\2\u0231\u022b\3\2\2\2\u0231\u022e\3\2\2\2\u0232\u0235\3\2\2\2\u0233"+
		"\u0231\3\2\2\2\u0233\u0234\3\2\2\2\u0234O\3\2\2\2\u0235\u0233\3\2\2\2"+
		"\u0236\u023b\5T+\2\u0237\u0238\5R*\2\u0238\u0239\5X-\2\u0239\u023b\3\2"+
		"\2\2\u023a\u0236\3\2\2\2\u023a\u0237\3\2\2\2\u023bQ\3\2\2\2\u023c\u023d"+
		"\t\13\2\2\u023dS\3\2\2\2\u023e\u023f\b+\1\2\u023f\u0243\5X-\2\u0240\u0242"+
		"\5V,\2\u0241\u0240\3\2\2\2\u0242\u0245\3\2\2\2\u0243\u0241\3\2\2\2\u0243"+
		"\u0244\3\2\2\2\u0244\u0251\3\2\2\2\u0245\u0243\3\2\2\2\u0246\u0247\f\3"+
		"\2\2\u0247\u0248\7k\2\2\u0248\u024c\7p\2\2\u0249\u024b\5V,\2\u024a\u0249"+
		"\3\2\2\2\u024b\u024e\3\2\2\2\u024c\u024a\3\2\2\2\u024c\u024d\3\2\2\2\u024d"+
		"\u0250\3\2\2\2\u024e\u024c\3\2\2\2\u024f\u0246\3\2\2\2\u0250\u0253\3\2"+
		"\2\2\u0251\u024f\3\2\2\2\u0251\u0252\3\2\2\2\u0252U\3\2\2\2\u0253\u0251"+
		"\3\2\2\2\u0254\u0255\5d\63\2\u0255W\3\2\2\2\u0256\u025c\5v<\2\u0257\u0258"+
		"\7Z\2\2\u0258\u0259\5N(\2\u0259\u025a\7`\2\2\u025a\u025c\3\2\2\2\u025b"+
		"\u0256\3\2\2\2\u025b\u0257\3\2\2\2\u025cY\3\2\2\2\u025d\u025f\5|?\2\u025e"+
		"\u025d\3\2\2\2\u025e\u025f\3\2\2\2\u025f\u0260\3\2\2\2\u0260\u0261\7\21"+
		"\2\2\u0261\u0262\5\\/\2\u0262[\3\2\2\2\u0263\u026a\5^\60\2\u0264\u0266"+
		"\7j\2\2\u0265\u0267\5^\60\2\u0266\u0265\3\2\2\2\u0266\u0267\3\2\2\2\u0267"+
		"\u0269\3\2\2\2\u0268\u0264\3\2\2\2\u0269\u026c\3\2\2\2\u026a\u0268\3\2"+
		"\2\2\u026a\u026b\3\2\2\2\u026b\u026d\3\2\2\2\u026c\u026a\3\2\2\2\u026d"+
		"\u0273\5l\67\2\u026e\u0271\7V\2\2\u026f\u0272\5N(\2\u0270\u0272\5x=\2"+
		"\u0271\u026f\3\2\2\2\u0271\u0270\3\2\2\2\u0272\u0274\3\2\2\2\u0273\u026e"+
		"\3\2\2\2\u0273\u0274\3\2\2\2\u0274]\3\2\2\2\u0275\u027a\7p\2\2\u0276\u0277"+
		"\7Z\2\2\u0277\u0278\5v<\2\u0278\u0279\7`\2\2\u0279\u027b\3\2\2\2\u027a"+
		"\u0276\3\2\2\2\u027a\u027b\3\2\2\2\u027b_\3\2\2\2\u027c\u027d\7L\2\2\u027d"+
		"\u027e\5N(\2\u027e\u027f\5\n\6\2\u027f\u0280\7K\2\2\u0280a\3\2\2\2\u0281"+
		"\u0282\7\3\2\2\u0282\u0283\7p\2\2\u0283c\3\2\2\2\u0284\u028d\7Z\2\2\u0285"+
		"\u028a\5f\64\2\u0286\u0287\7j\2\2\u0287\u0289\5f\64\2\u0288\u0286\3\2"+
		"\2\2\u0289\u028c\3\2\2\2\u028a\u0288\3\2\2\2\u028a\u028b\3\2\2\2\u028b"+
		"\u028e\3\2\2\2\u028c\u028a\3\2\2\2\u028d\u0285\3\2\2\2\u028d\u028e\3\2"+
		"\2\2\u028e\u028f\3\2\2\2\u028f\u0290\7`\2\2\u0290e\3\2\2\2\u0291\u0292"+
		"\5N(\2\u0292g\3\2\2\2\u0293\u029c\7Z\2\2\u0294\u0299\5j\66\2\u0295\u0296"+
		"\7j\2\2\u0296\u0298\5j\66\2\u0297\u0295\3\2\2\2\u0298\u029b\3\2\2\2\u0299"+
		"\u0297\3\2\2\2\u0299\u029a\3\2\2\2\u029a\u029d\3\2\2\2\u029b\u0299\3\2"+
		"\2\2\u029c\u0294\3\2\2\2\u029c\u029d\3\2\2\2\u029d\u029e\3\2\2\2\u029e"+
		"\u029f\7`\2\2\u029fi\3\2\2\2\u02a0\u02a3\7\n\2\2\u02a1\u02a3\7\b\2\2\u02a2"+
		"\u02a0\3\2\2\2\u02a2\u02a1\3\2\2\2\u02a2\u02a3\3\2\2\2\u02a3\u02a4\3\2"+
		"\2\2\u02a4\u02a8\7p\2\2\u02a5\u02a6\7Z\2\2\u02a6\u02a7\7T\2\2\u02a7\u02a9"+
		"\7`\2\2\u02a8\u02a5\3\2\2\2\u02a8\u02a9\3\2\2\2\u02a9\u02ab\3\2\2\2\u02aa"+
		"\u02ac\5l\67\2\u02ab\u02aa\3\2\2\2\u02ab\u02ac\3\2\2\2\u02ack\3\2\2\2"+
		"\u02ad\u02af\7\5\2\2\u02ae\u02b0\7\30\2\2\u02af\u02ae\3\2\2\2\u02af\u02b0"+
		"\3\2\2\2\u02b0\u02b1\3\2\2\2\u02b1\u02b3\5z>\2\u02b2\u02b4\5r:\2\u02b3"+
		"\u02b2\3\2\2\2\u02b3\u02b4\3\2\2\2\u02b4m\3\2\2\2\u02b5\u02cb\7\r\2\2"+
		"\u02b6\u02cb\7?\2\2\u02b7\u02cb\7M\2\2\u02b8\u02cb\7\23\2\2\u02b9\u02cb"+
		"\7)\2\2\u02ba\u02cb\7\7\2\2\u02bb\u02cb\7\6\2\2\u02bc\u02cb\7\t\2\2\u02bd"+
		"\u02cb\7\63\2\2\u02be\u02cb\7\64\2\2\u02bf\u02c8\7C\2\2\u02c0\u02c2\7"+
		"o\2\2\u02c1\u02c0\3\2\2\2\u02c1\u02c2\3\2\2\2\u02c2\u02c3\3\2\2\2\u02c3"+
		"\u02c5\7]\2\2\u02c4\u02c6\7o\2\2\u02c5\u02c4\3\2\2\2\u02c5\u02c6\3\2\2"+
		"\2\u02c6\u02c7\3\2\2\2\u02c7\u02c9\5N(\2\u02c8\u02c1\3\2\2\2\u02c8\u02c9"+
		"\3\2\2\2\u02c9\u02cb\3\2\2\2\u02ca\u02b5\3\2\2\2\u02ca\u02b6\3\2\2\2\u02ca"+
		"\u02b7\3\2\2\2\u02ca\u02b8\3\2\2\2\u02ca\u02b9\3\2\2\2\u02ca\u02ba\3\2"+
		"\2\2\u02ca\u02bb\3\2\2\2\u02ca\u02bc\3\2\2\2\u02ca\u02bd\3\2\2\2\u02ca"+
		"\u02be\3\2\2\2\u02ca\u02bf\3\2\2\2\u02cbo\3\2\2\2\u02cc\u02d1\7p\2\2\u02cd"+
		"\u02ce\t\f\2\2\u02ce\u02d0\7p\2\2\u02cf\u02cd\3\2\2\2\u02d0\u02d3\3\2"+
		"\2\2\u02d1\u02cf\3\2\2\2\u02d1\u02d2\3\2\2\2\u02d2q\3\2\2\2\u02d3\u02d1"+
		"\3\2\2\2\u02d4\u02d5\7]\2\2\u02d5\u02d6\t\r\2\2\u02d6s\3\2\2\2\u02d7\u02d8"+
		"\7p\2\2\u02d8\u02d9\7h\2\2\u02d9u\3\2\2\2\u02da\u02ee\7R\2\2\u02db\u02ee"+
		"\7S\2\2\u02dc\u02de\t\7\2\2\u02dd\u02dc\3\2\2\2\u02dd\u02de\3\2\2\2\u02de"+
		"\u02e5\3\2\2\2\u02df\u02e1\7T\2\2\u02e0\u02df\3\2\2\2\u02e1\u02e2\3\2"+
		"\2\2\u02e2\u02e0\3\2\2\2\u02e2\u02e3\3\2\2\2\u02e3\u02e4\3\2\2\2\u02e4"+
		"\u02e6\7\u0095\2\2\u02e5\u02e0\3\2\2\2\u02e5\u02e6\3\2\2\2\u02e6\u02e7"+
		"\3\2\2\2\u02e7\u02ee\7T\2\2\u02e8\u02ee\7P\2\2\u02e9\u02ee\7Q\2\2\u02ea"+
		"\u02ee\7G\2\2\u02eb\u02ee\7(\2\2\u02ec\u02ee\7p\2\2\u02ed\u02da\3\2\2"+
		"\2\u02ed\u02db\3\2\2\2\u02ed\u02dd\3\2\2\2\u02ed\u02e8\3\2\2\2\u02ed\u02e9"+
		"\3\2\2\2\u02ed\u02ea\3\2\2\2\u02ed\u02eb\3\2\2\2\u02ed\u02ec\3\2\2\2\u02ee"+
		"w\3\2\2\2\u02ef\u02f2\7c\2\2\u02f0\u02f3\5v<\2\u02f1\u02f3\5x=\2\u02f2"+
		"\u02f0\3\2\2\2\u02f2\u02f1\3\2\2\2\u02f3\u02fb\3\2\2\2\u02f4\u02f7\7j"+
		"\2\2\u02f5\u02f8\5v<\2\u02f6\u02f8\5x=\2\u02f7\u02f5\3\2\2\2\u02f7\u02f6"+
		"\3\2\2\2\u02f8\u02fa\3\2\2\2\u02f9\u02f4\3\2\2\2\u02fa\u02fd\3\2\2\2\u02fb"+
		"\u02f9\3\2\2\2\u02fb\u02fc\3\2\2\2\u02fc\u02ff\3\2\2\2\u02fd\u02fb\3\2"+
		"\2\2\u02fe\u0300\7j\2\2\u02ff\u02fe\3\2\2\2\u02ff\u0300\3\2\2\2\u0300"+
		"\u0301\3\2\2\2\u0301\u0302\7d\2\2\u0302y\3\2\2\2\u0303\u0306\5n8\2\u0304"+
		"\u0306\5p9\2\u0305\u0303\3\2\2\2\u0305\u0304\3\2\2\2\u0306\u030a\3\2\2"+
		"\2\u0307\u0308\7Z\2\2\u0308\u0309\t\r\2\2\u0309\u030b\7`\2\2\u030a\u0307"+
		"\3\2\2\2\u030a\u030b\3\2\2\2\u030b{\3\2\2\2\u030c\u030d\7;\2\2\u030d}"+
		"\3\2\2\2i\u0081\u0095\u009e\u00a3\u00b0\u00b8\u00bd\u00c3\u00cc\u00d0"+
		"\u00d6\u00da\u00ee\u00f5\u00fd\u0100\u010a\u010f\u0112\u0117\u011b\u0123"+
		"\u012d\u0132\u0134\u013e\u0148\u014d\u0151\u0157\u015f\u0166\u0170\u0172"+
		"\u0174\u0181\u0183\u0185\u0190\u0198\u019a\u019c\u01a1\u01a5\u01a9\u01ac"+
		"\u01b1\u01b5\u01b8\u01c0\u01c3\u01c8\u01cc\u01d2\u01d7\u01db\u01e5\u01e9"+
		"\u01ef\u01f6\u01fb\u01ff\u0205\u020c\u0216\u0220\u0231\u0233\u023a\u0243"+
		"\u024c\u0251\u025b\u025e\u0266\u026a\u0271\u0273\u027a\u028a\u028d\u0299"+
		"\u029c\u02a2\u02a8\u02ab\u02af\u02b3\u02c1\u02c5\u02c8\u02ca\u02d1\u02dd"+
		"\u02e2\u02e5\u02ed\u02f2\u02f7\u02fb\u02ff\u0305\u030a";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}