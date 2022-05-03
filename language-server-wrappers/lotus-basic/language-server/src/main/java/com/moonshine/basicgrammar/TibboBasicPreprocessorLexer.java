// Generated from com\moonshine\basicgrammar\TibboBasicPreprocessorLexer.g4 by ANTLR 4.7.1
package com.moonshine.basicgrammar;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.misc.*;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast"})
public class TibboBasicPreprocessorLexer extends Lexer {
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
		COMMENTS_CHANNEL=2;
	public static final int
		DIRECTIVE_MODE=1, DIRECTIVE_DEFINE=2, DIRECTIVE_TEXT=3, DIRECTIVE_INCLUDE_TEXT=4;
	public static String[] channelNames = {
		"DEFAULT_TOKEN_CHANNEL", "HIDDEN", "COMMENTS_CHANNEL"
	};

	public static String[] modeNames = {
		"DEFAULT_MODE", "DIRECTIVE_MODE", "DIRECTIVE_DEFINE", "DIRECTIVE_TEXT", 
		"DIRECTIVE_INCLUDE_TEXT"
	};

	public static final String[] ruleNames = {
		"WS", "INCLUDE", "INCLUDEPP", "SHARP", "COMMENT", "STRING", "CODE", "NEW_LINE", 
		"PRAGMA", "DEFINE", "DEFINED", "ADD", "SUB", "IF", "ELIF", "ELSE", "UNDEF", 
		"IFDEF", "IFNDEF", "ENDIF", "ERROR", "BANG", "LPAREN", "RPAREN", "EQUAL", 
		"NOTEQUAL", "AND", "OR", "LT", "GT", "LE", "GE", "DIRECTIVE_WHITESPACES", 
		"DIRECTIVE_STRING", "CONDITIONAL_SYMBOL", "DECIMAL_LITERAL", "FLOAT", 
		"DIRECTIVE_NEW_LINE", "DIRECTIVE_COMMENT", "DIRECTIVE_DEFINE_CONDITIONAL_SYMBOL", 
		"TEXT_NEW_LINE", "TEXT", "INCLUDE_DIRECITVE_TEXT_NEW_LINE", "INCLUDE_TEXT_NEW_LINE", 
		"INCLUDE_FILE", "EscapeSequence", "OctalEscape", "UnicodeEscape", "HexDigit", 
		"StringFragment", "LETTER", "A", "B", "C", "D", "E", "F", "G", "H", "I", 
		"J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", 
		"X", "Y", "Z"
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


	public TibboBasicPreprocessorLexer(CharStream input) {
		super(input);
		_interp = new LexerATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}

	@Override
	public String getGrammarFileName() { return "TibboBasicPreprocessorLexer.g4"; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public String[] getChannelNames() { return channelNames; }

	@Override
	public String[] getModeNames() { return modeNames; }

	@Override
	public ATN getATN() { return _ATN; }

	public static final String _serializedATN =
		"\3\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964\2(\u023b\b\1\b\1\b"+
		"\1\b\1\b\1\4\2\t\2\4\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4\b\t\b\4\t"+
		"\t\t\4\n\t\n\4\13\t\13\4\f\t\f\4\r\t\r\4\16\t\16\4\17\t\17\4\20\t\20\4"+
		"\21\t\21\4\22\t\22\4\23\t\23\4\24\t\24\4\25\t\25\4\26\t\26\4\27\t\27\4"+
		"\30\t\30\4\31\t\31\4\32\t\32\4\33\t\33\4\34\t\34\4\35\t\35\4\36\t\36\4"+
		"\37\t\37\4 \t \4!\t!\4\"\t\"\4#\t#\4$\t$\4%\t%\4&\t&\4\'\t\'\4(\t(\4)"+
		"\t)\4*\t*\4+\t+\4,\t,\4-\t-\4.\t.\4/\t/\4\60\t\60\4\61\t\61\4\62\t\62"+
		"\4\63\t\63\4\64\t\64\4\65\t\65\4\66\t\66\4\67\t\67\48\t8\49\t9\4:\t:\4"+
		";\t;\4<\t<\4=\t=\4>\t>\4?\t?\4@\t@\4A\tA\4B\tB\4C\tC\4D\tD\4E\tE\4F\t"+
		"F\4G\tG\4H\tH\4I\tI\4J\tJ\4K\tK\4L\tL\4M\tM\4N\tN\3\2\6\2\u00a3\n\2\r"+
		"\2\16\2\u00a4\3\2\3\2\3\3\7\3\u00aa\n\3\f\3\16\3\u00ad\13\3\3\3\3\3\3"+
		"\3\3\3\3\3\3\3\3\3\3\3\6\3\u00b7\n\3\r\3\16\3\u00b8\3\3\3\3\3\4\7\4\u00be"+
		"\n\4\f\4\16\4\u00c1\13\4\3\4\3\4\3\4\3\4\3\4\3\4\3\4\3\4\3\4\3\4\6\4\u00cd"+
		"\n\4\r\4\16\4\u00ce\3\4\3\4\3\5\7\5\u00d4\n\5\f\5\16\5\u00d7\13\5\3\5"+
		"\3\5\3\5\3\5\3\6\3\6\7\6\u00df\n\6\f\6\16\6\u00e2\13\6\3\6\3\6\3\7\3\7"+
		"\3\7\3\7\3\b\6\b\u00eb\n\b\r\b\16\b\u00ec\3\t\5\t\u00f0\n\t\3\t\3\t\3"+
		"\n\3\n\3\n\3\n\3\n\3\n\3\n\3\n\3\n\3\13\3\13\3\13\3\13\3\13\3\13\3\13"+
		"\6\13\u0104\n\13\r\13\16\13\u0105\3\13\3\13\3\f\3\f\3\f\3\f\3\f\3\f\3"+
		"\f\3\f\3\r\3\r\3\16\3\16\3\17\3\17\3\17\3\20\3\20\3\20\3\20\3\20\3\21"+
		"\3\21\3\21\3\21\3\21\3\22\3\22\3\22\3\22\3\22\3\22\3\23\3\23\3\23\3\23"+
		"\3\23\3\23\3\24\3\24\3\24\3\24\3\24\3\24\3\24\3\25\3\25\3\25\3\25\3\25"+
		"\3\25\3\26\3\26\3\26\3\26\3\26\3\26\3\26\3\26\3\27\3\27\3\30\3\30\3\31"+
		"\3\31\3\32\3\32\3\33\3\33\3\33\3\34\3\34\3\34\3\34\3\35\3\35\3\35\3\36"+
		"\3\36\3\37\3\37\3 \3 \3 \3!\3!\3!\3\"\6\"\u0161\n\"\r\"\16\"\u0162\3\""+
		"\3\"\3#\3#\3$\3$\3$\7$\u016c\n$\f$\16$\u016f\13$\3%\6%\u0172\n%\r%\16"+
		"%\u0173\3&\6&\u0177\n&\r&\16&\u0178\3&\3&\7&\u017d\n&\f&\16&\u0180\13"+
		"&\3&\3&\6&\u0184\n&\r&\16&\u0185\5&\u0188\n&\3\'\5\'\u018b\n\'\3\'\3\'"+
		"\3\'\3\'\3\'\3(\3(\7(\u0194\n(\f(\16(\u0197\13(\3(\3(\3(\3)\3)\3)\7)\u019f"+
		"\n)\f)\16)\u01a2\13)\3)\3)\3)\7)\u01a7\n)\f)\16)\u01aa\13)\3)\5)\u01ad"+
		"\n)\3)\3)\3)\3*\5*\u01b3\n*\3*\3*\3*\3*\3*\3+\6+\u01bb\n+\r+\16+\u01bc"+
		"\3,\3,\5,\u01c1\n,\3,\3,\3,\3,\3-\5-\u01c8\n-\3-\3-\3-\3-\3-\3.\3.\3."+
		"\3.\7.\u01d3\n.\f.\16.\u01d6\13.\3.\3.\3.\3.\3/\3/\3/\3/\5/\u01e0\n/\3"+
		"\60\3\60\3\60\3\60\3\60\3\60\3\60\3\60\3\60\5\60\u01eb\n\60\3\61\3\61"+
		"\3\61\3\61\3\61\3\61\3\61\3\62\3\62\3\63\3\63\3\63\3\63\7\63\u01fa\n\63"+
		"\f\63\16\63\u01fd\13\63\3\63\3\63\3\64\3\64\3\64\3\64\3\64\5\64\u0206"+
		"\n\64\3\65\3\65\3\66\3\66\3\67\3\67\38\38\39\39\3:\3:\3;\3;\3<\3<\3=\3"+
		"=\3>\3>\3?\3?\3@\3@\3A\3A\3B\3B\3C\3C\3D\3D\3E\3E\3F\3F\3G\3G\3H\3H\3"+
		"I\3I\3J\3J\3K\3K\3L\3L\3M\3M\3N\3N\2\2O\7\3\t\4\13\5\r\6\17\2\21\2\23"+
		"\7\25\b\27\t\31\n\33\13\35\f\37\r!\16#\17%\20\'\21)\22+\23-\24/\25\61"+
		"\26\63\27\65\30\67\319\32;\33=\34?\35A\36C\37E G!I\"K#M$O%Q\2S\2U\2W\2"+
		"Y&[\']\2_(a\2c\2e\2g\2i\2k\2m\2o\2q\2s\2u\2w\2y\2{\2}\2\177\2\u0081\2"+
		"\u0083\2\u0085\2\u0087\2\u0089\2\u008b\2\u008d\2\u008f\2\u0091\2\u0093"+
		"\2\u0095\2\u0097\2\u0099\2\u009b\2\u009d\2\u009f\2\7\2\3\4\5\6/\4\2\13"+
		"\13\"\"\4\2\f\f\17\17\6\2\f\f\17\17$%))\4\2\62;aa\3\2\62;\7\2\13\13\""+
		"\"..\60\60\62;\5\2\f\f\17\17^^\4\2$$bb\5\2\f\f\17\17$$\n\2$$))^^ddhhp"+
		"pttvv\3\2\62\65\3\2\629\5\2\62;CHch\4\2$$^^\6\2&&C\\aac|\4\2\2\u0101\ud802"+
		"\udc01\3\2\ud802\udc01\3\2\udc02\ue001\3\2\u00eb\u00eb\4\2CCcc\4\2DDd"+
		"d\4\2EEee\4\2FFff\4\2GGgg\4\2HHhh\4\2IIii\4\2JJjj\4\2KKkk\4\2LLll\4\2"+
		"MMmm\4\2NNnn\4\2OOoo\4\2PPpp\4\2QQqq\4\2RRrr\4\2SSss\4\2TTtt\4\2UUuu\4"+
		"\2VVvv\4\2WWww\4\2XXxx\4\2YYyy\4\2ZZzz\4\2[[{{\4\2\\\\||\2\u023e\2\7\3"+
		"\2\2\2\2\t\3\2\2\2\2\13\3\2\2\2\2\r\3\2\2\2\2\17\3\2\2\2\2\21\3\2\2\2"+
		"\2\23\3\2\2\2\2\25\3\2\2\2\3\27\3\2\2\2\3\31\3\2\2\2\3\33\3\2\2\2\3\35"+
		"\3\2\2\2\3\37\3\2\2\2\3!\3\2\2\2\3#\3\2\2\2\3%\3\2\2\2\3\'\3\2\2\2\3)"+
		"\3\2\2\2\3+\3\2\2\2\3-\3\2\2\2\3/\3\2\2\2\3\61\3\2\2\2\3\63\3\2\2\2\3"+
		"\65\3\2\2\2\3\67\3\2\2\2\39\3\2\2\2\3;\3\2\2\2\3=\3\2\2\2\3?\3\2\2\2\3"+
		"A\3\2\2\2\3C\3\2\2\2\3E\3\2\2\2\3G\3\2\2\2\3I\3\2\2\2\3K\3\2\2\2\3M\3"+
		"\2\2\2\3O\3\2\2\2\3Q\3\2\2\2\3S\3\2\2\2\4U\3\2\2\2\5W\3\2\2\2\5Y\3\2\2"+
		"\2\6[\3\2\2\2\6]\3\2\2\2\6_\3\2\2\2\7\u00a2\3\2\2\2\t\u00ab\3\2\2\2\13"+
		"\u00bf\3\2\2\2\r\u00d5\3\2\2\2\17\u00dc\3\2\2\2\21\u00e5\3\2\2\2\23\u00ea"+
		"\3\2\2\2\25\u00ef\3\2\2\2\27\u00f3\3\2\2\2\31\u00fc\3\2\2\2\33\u0109\3"+
		"\2\2\2\35\u0111\3\2\2\2\37\u0113\3\2\2\2!\u0115\3\2\2\2#\u0118\3\2\2\2"+
		"%\u011d\3\2\2\2\'\u0122\3\2\2\2)\u0128\3\2\2\2+\u012e\3\2\2\2-\u0135\3"+
		"\2\2\2/\u013b\3\2\2\2\61\u0143\3\2\2\2\63\u0145\3\2\2\2\65\u0147\3\2\2"+
		"\2\67\u0149\3\2\2\29\u014b\3\2\2\2;\u014e\3\2\2\2=\u0152\3\2\2\2?\u0155"+
		"\3\2\2\2A\u0157\3\2\2\2C\u0159\3\2\2\2E\u015c\3\2\2\2G\u0160\3\2\2\2I"+
		"\u0166\3\2\2\2K\u0168\3\2\2\2M\u0171\3\2\2\2O\u0187\3\2\2\2Q\u018a\3\2"+
		"\2\2S\u0191\3\2\2\2U\u019b\3\2\2\2W\u01b2\3\2\2\2Y\u01ba\3\2\2\2[\u01be"+
		"\3\2\2\2]\u01c7\3\2\2\2_\u01ce\3\2\2\2a\u01df\3\2\2\2c\u01ea\3\2\2\2e"+
		"\u01ec\3\2\2\2g\u01f3\3\2\2\2i\u01f5\3\2\2\2k\u0205\3\2\2\2m\u0207\3\2"+
		"\2\2o\u0209\3\2\2\2q\u020b\3\2\2\2s\u020d\3\2\2\2u\u020f\3\2\2\2w\u0211"+
		"\3\2\2\2y\u0213\3\2\2\2{\u0215\3\2\2\2}\u0217\3\2\2\2\177\u0219\3\2\2"+
		"\2\u0081\u021b\3\2\2\2\u0083\u021d\3\2\2\2\u0085\u021f\3\2\2\2\u0087\u0221"+
		"\3\2\2\2\u0089\u0223\3\2\2\2\u008b\u0225\3\2\2\2\u008d\u0227\3\2\2\2\u008f"+
		"\u0229\3\2\2\2\u0091\u022b\3\2\2\2\u0093\u022d\3\2\2\2\u0095\u022f\3\2"+
		"\2\2\u0097\u0231\3\2\2\2\u0099\u0233\3\2\2\2\u009b\u0235\3\2\2\2\u009d"+
		"\u0237\3\2\2\2\u009f\u0239\3\2\2\2\u00a1\u00a3\t\2\2\2\u00a2\u00a1\3\2"+
		"\2\2\u00a3\u00a4\3\2\2\2\u00a4\u00a2\3\2\2\2\u00a4\u00a5\3\2\2\2\u00a5"+
		"\u00a6\3\2\2\2\u00a6\u00a7\b\2\2\2\u00a7\b\3\2\2\2\u00a8\u00aa\t\2\2\2"+
		"\u00a9\u00a8\3\2\2\2\u00aa\u00ad\3\2\2\2\u00ab\u00a9\3\2\2\2\u00ab\u00ac"+
		"\3\2\2\2\u00ac\u00ae\3\2\2\2\u00ad\u00ab\3\2\2\2\u00ae\u00af\5}=\2\u00af"+
		"\u00b0\5\u0087B\2\u00b0\u00b1\5q\67\2\u00b1\u00b2\5\u0083@\2\u00b2\u00b3"+
		"\5\u0095I\2\u00b3\u00b4\5s8\2\u00b4\u00b6\5u9\2\u00b5\u00b7\t\2\2\2\u00b6"+
		"\u00b5\3\2\2\2\u00b7\u00b8\3\2\2\2\u00b8\u00b6\3\2\2\2\u00b8\u00b9\3\2"+
		"\2\2\u00b9\u00ba\3\2\2\2\u00ba\u00bb\b\3\3\2\u00bb\n\3\2\2\2\u00bc\u00be"+
		"\t\2\2\2\u00bd\u00bc\3\2\2\2\u00be\u00c1\3\2\2\2\u00bf\u00bd\3\2\2\2\u00bf"+
		"\u00c0\3\2\2\2\u00c0\u00c2\3\2\2\2\u00c1\u00bf\3\2\2\2\u00c2\u00c3\5}"+
		"=\2\u00c3\u00c4\5\u0087B\2\u00c4\u00c5\5q\67\2\u00c5\u00c6\5\u0083@\2"+
		"\u00c6\u00c7\5\u0095I\2\u00c7\u00c8\5s8\2\u00c8\u00c9\5u9\2\u00c9\u00ca"+
		"\5\u008bD\2\u00ca\u00cc\5\u008bD\2\u00cb\u00cd\t\2\2\2\u00cc\u00cb\3\2"+
		"\2\2\u00cd\u00ce\3\2\2\2\u00ce\u00cc\3\2\2\2\u00ce\u00cf\3\2\2\2\u00cf"+
		"\u00d0\3\2\2\2\u00d0\u00d1\b\4\3\2\u00d1\f\3\2\2\2\u00d2\u00d4\t\2\2\2"+
		"\u00d3\u00d2\3\2\2\2\u00d4\u00d7\3\2\2\2\u00d5\u00d3\3\2\2\2\u00d5\u00d6"+
		"\3\2\2\2\u00d6\u00d8\3\2\2\2\u00d7\u00d5\3\2\2\2\u00d8\u00d9\7%\2\2\u00d9"+
		"\u00da\3\2\2\2\u00da\u00db\b\5\4\2\u00db\16\3\2\2\2\u00dc\u00e0\7)\2\2"+
		"\u00dd\u00df\n\3\2\2\u00de\u00dd\3\2\2\2\u00df\u00e2\3\2\2\2\u00e0\u00de"+
		"\3\2\2\2\u00e0\u00e1\3\2\2\2\u00e1\u00e3\3\2\2\2\u00e2\u00e0\3\2\2\2\u00e3"+
		"\u00e4\b\6\5\2\u00e4\20\3\2\2\2\u00e5\u00e6\5i\63\2\u00e6\u00e7\3\2\2"+
		"\2\u00e7\u00e8\b\7\5\2\u00e8\22\3\2\2\2\u00e9\u00eb\n\4\2\2\u00ea\u00e9"+
		"\3\2\2\2\u00eb\u00ec\3\2\2\2\u00ec\u00ea\3\2\2\2\u00ec\u00ed\3\2\2\2\u00ed"+
		"\24\3\2\2\2\u00ee\u00f0\7\17\2\2\u00ef\u00ee\3\2\2\2\u00ef\u00f0\3\2\2"+
		"\2\u00f0\u00f1\3\2\2\2\u00f1\u00f2\7\f\2\2\u00f2\26\3\2\2\2\u00f3\u00f4"+
		"\5\u008bD\2\u00f4\u00f5\5\u008fF\2\u00f5\u00f6\5m\65\2\u00f6\u00f7\5y"+
		";\2\u00f7\u00f8\5\u0085A\2\u00f8\u00f9\5m\65\2\u00f9\u00fa\3\2\2\2\u00fa"+
		"\u00fb\b\n\6\2\u00fb\30\3\2\2\2\u00fc\u00fd\5s8\2\u00fd\u00fe\5u9\2\u00fe"+
		"\u00ff\5w:\2\u00ff\u0100\5}=\2\u0100\u0101\5\u0087B\2\u0101\u0103\5u9"+
		"\2\u0102\u0104\t\2\2\2\u0103\u0102\3\2\2\2\u0104\u0105\3\2\2\2\u0105\u0103"+
		"\3\2\2\2\u0105\u0106\3\2\2\2\u0106\u0107\3\2\2\2\u0107\u0108\b\13\7\2"+
		"\u0108\32\3\2\2\2\u0109\u010a\5s8\2\u010a\u010b\5u9\2\u010b\u010c\5w:"+
		"\2\u010c\u010d\5}=\2\u010d\u010e\5\u0087B\2\u010e\u010f\5u9\2\u010f\u0110"+
		"\5s8\2\u0110\34\3\2\2\2\u0111\u0112\7-\2\2\u0112\36\3\2\2\2\u0113\u0114"+
		"\7/\2\2\u0114 \3\2\2\2\u0115\u0116\5}=\2\u0116\u0117\5w:\2\u0117\"\3\2"+
		"\2\2\u0118\u0119\5u9\2\u0119\u011a\5\u0083@\2\u011a\u011b\5}=\2\u011b"+
		"\u011c\5w:\2\u011c$\3\2\2\2\u011d\u011e\5u9\2\u011e\u011f\5\u0083@\2\u011f"+
		"\u0120\5\u0091G\2\u0120\u0121\5u9\2\u0121&\3\2\2\2\u0122\u0123\5\u0095"+
		"I\2\u0123\u0124\5\u0087B\2\u0124\u0125\5s8\2\u0125\u0126\5u9\2\u0126\u0127"+
		"\5w:\2\u0127(\3\2\2\2\u0128\u0129\5}=\2\u0129\u012a\5w:\2\u012a\u012b"+
		"\5s8\2\u012b\u012c\5u9\2\u012c\u012d\5w:\2\u012d*\3\2\2\2\u012e\u012f"+
		"\5}=\2\u012f\u0130\5w:\2\u0130\u0131\5\u0087B\2\u0131\u0132\5s8\2\u0132"+
		"\u0133\5u9\2\u0133\u0134\5w:\2\u0134,\3\2\2\2\u0135\u0136\5u9\2\u0136"+
		"\u0137\5\u0087B\2\u0137\u0138\5s8\2\u0138\u0139\5}=\2\u0139\u013a\5w:"+
		"\2\u013a.\3\2\2\2\u013b\u013c\5u9\2\u013c\u013d\5\u008fF\2\u013d\u013e"+
		"\5\u008fF\2\u013e\u013f\5\u0089C\2\u013f\u0140\5\u008fF\2\u0140\u0141"+
		"\3\2\2\2\u0141\u0142\b\26\6\2\u0142\60\3\2\2\2\u0143\u0144\7#\2\2\u0144"+
		"\62\3\2\2\2\u0145\u0146\7*\2\2\u0146\64\3\2\2\2\u0147\u0148\7+\2\2\u0148"+
		"\66\3\2\2\2\u0149\u014a\7?\2\2\u014a8\3\2\2\2\u014b\u014c\7>\2\2\u014c"+
		"\u014d\7@\2\2\u014d:\3\2\2\2\u014e\u014f\5m\65\2\u014f\u0150\5\u0087B"+
		"\2\u0150\u0151\5s8\2\u0151<\3\2\2\2\u0152\u0153\5\u0089C\2\u0153\u0154"+
		"\5\u008fF\2\u0154>\3\2\2\2\u0155\u0156\7>\2\2\u0156@\3\2\2\2\u0157\u0158"+
		"\7@\2\2\u0158B\3\2\2\2\u0159\u015a\7>\2\2\u015a\u015b\7?\2\2\u015bD\3"+
		"\2\2\2\u015c\u015d\7@\2\2\u015d\u015e\7?\2\2\u015eF\3\2\2\2\u015f\u0161"+
		"\t\2\2\2\u0160\u015f\3\2\2\2\u0161\u0162\3\2\2\2\u0162\u0160\3\2\2\2\u0162"+
		"\u0163\3\2\2\2\u0163\u0164\3\2\2\2\u0164\u0165\b\"\2\2\u0165H\3\2\2\2"+
		"\u0166\u0167\5i\63\2\u0167J\3\2\2\2\u0168\u016d\5k\64\2\u0169\u016c\5"+
		"k\64\2\u016a\u016c\t\5\2\2\u016b\u0169\3\2\2\2\u016b\u016a\3\2\2\2\u016c"+
		"\u016f\3\2\2\2\u016d\u016b\3\2\2\2\u016d\u016e\3\2\2\2\u016eL\3\2\2\2"+
		"\u016f\u016d\3\2\2\2\u0170\u0172\t\6\2\2\u0171\u0170\3\2\2\2\u0172\u0173"+
		"\3\2\2\2\u0173\u0171\3\2\2\2\u0173\u0174\3\2\2\2\u0174N\3\2\2\2\u0175"+
		"\u0177\t\6\2\2\u0176\u0175\3\2\2\2\u0177\u0178\3\2\2\2\u0178\u0176\3\2"+
		"\2\2\u0178\u0179\3\2\2\2\u0179\u017a\3\2\2\2\u017a\u017e\7\60\2\2\u017b"+
		"\u017d\t\6\2\2\u017c\u017b\3\2\2\2\u017d\u0180\3\2\2\2\u017e\u017c\3\2"+
		"\2\2\u017e\u017f\3\2\2\2\u017f\u0188\3\2\2\2\u0180\u017e\3\2\2\2\u0181"+
		"\u0183\7\60\2\2\u0182\u0184\t\6\2\2\u0183\u0182\3\2\2\2\u0184\u0185\3"+
		"\2\2\2\u0185\u0183\3\2\2\2\u0185\u0186\3\2\2\2\u0186\u0188\3\2\2\2\u0187"+
		"\u0176\3\2\2\2\u0187\u0181\3\2\2\2\u0188P\3\2\2\2\u0189\u018b\7\17\2\2"+
		"\u018a\u0189\3\2\2\2\u018a\u018b\3\2\2\2\u018b\u018c\3\2\2\2\u018c\u018d"+
		"\7\f\2\2\u018d\u018e\3\2\2\2\u018e\u018f\b\'\b\2\u018f\u0190\b\'\t\2\u0190"+
		"R\3\2\2\2\u0191\u0195\7)\2\2\u0192\u0194\n\3\2\2\u0193\u0192\3\2\2\2\u0194"+
		"\u0197\3\2\2\2\u0195\u0193\3\2\2\2\u0195\u0196\3\2\2\2\u0196\u0198\3\2"+
		"\2\2\u0197\u0195\3\2\2\2\u0198\u0199\b(\5\2\u0199\u019a\b(\t\2\u019aT"+
		"\3\2\2\2\u019b\u01a0\5k\64\2\u019c\u019f\5k\64\2\u019d\u019f\t\6\2\2\u019e"+
		"\u019c\3\2\2\2\u019e\u019d\3\2\2\2\u019f\u01a2\3\2\2\2\u01a0\u019e\3\2"+
		"\2\2\u01a0\u01a1\3\2\2\2\u01a1\u01ac\3\2\2\2\u01a2\u01a0\3\2\2\2\u01a3"+
		"\u01a8\7*\2\2\u01a4\u01a7\5k\64\2\u01a5\u01a7\t\7\2\2\u01a6\u01a4\3\2"+
		"\2\2\u01a6\u01a5\3\2\2\2\u01a7\u01aa\3\2\2\2\u01a8\u01a6\3\2\2\2\u01a8"+
		"\u01a9\3\2\2\2\u01a9\u01ab\3\2\2\2\u01aa\u01a8\3\2\2\2\u01ab\u01ad\7+"+
		"\2\2\u01ac\u01a3\3\2\2\2\u01ac\u01ad\3\2\2\2\u01ad\u01ae\3\2\2\2\u01ae"+
		"\u01af\b)\n\2\u01af\u01b0\b)\6\2\u01b0V\3\2\2\2\u01b1\u01b3\7\17\2\2\u01b2"+
		"\u01b1\3\2\2\2\u01b2\u01b3\3\2\2\2\u01b3\u01b4\3\2\2\2\u01b4\u01b5\7\f"+
		"\2\2\u01b5\u01b6\3\2\2\2\u01b6\u01b7\b*\b\2\u01b7\u01b8\b*\t\2\u01b8X"+
		"\3\2\2\2\u01b9\u01bb\n\b\2\2\u01ba\u01b9\3\2\2\2\u01bb\u01bc\3\2\2\2\u01bc"+
		"\u01ba\3\2\2\2\u01bc\u01bd\3\2\2\2\u01bdZ\3\2\2\2\u01be\u01c0\7^\2\2\u01bf"+
		"\u01c1\7\17\2\2\u01c0\u01bf\3\2\2\2\u01c0\u01c1\3\2\2\2\u01c1\u01c2\3"+
		"\2\2\2\u01c2\u01c3\7\f\2\2\u01c3\u01c4\3\2\2\2\u01c4\u01c5\b,\2\2\u01c5"+
		"\\\3\2\2\2\u01c6\u01c8\7\17\2\2\u01c7\u01c6\3\2\2\2\u01c7\u01c8\3\2\2"+
		"\2\u01c8\u01c9\3\2\2\2\u01c9\u01ca\7\f\2\2\u01ca\u01cb\3\2\2\2\u01cb\u01cc"+
		"\b-\b\2\u01cc\u01cd\b-\t\2\u01cd^\3\2\2\2\u01ce\u01d4\t\t\2\2\u01cf\u01d3"+
		"\n\n\2\2\u01d0\u01d1\7$\2\2\u01d1\u01d3\7$\2\2\u01d2\u01cf\3\2\2\2\u01d2"+
		"\u01d0\3\2\2\2\u01d3\u01d6\3\2\2\2\u01d4\u01d2\3\2\2\2\u01d4\u01d5\3\2"+
		"\2\2\u01d5\u01d7\3\2\2\2\u01d6\u01d4\3\2\2\2\u01d7\u01d8\t\t\2\2\u01d8"+
		"\u01d9\3\2\2\2\u01d9\u01da\b.\t\2\u01da`\3\2\2\2\u01db\u01dc\7^\2\2\u01dc"+
		"\u01e0\t\13\2\2\u01dd\u01e0\5c\60\2\u01de\u01e0\5e\61\2\u01df\u01db\3"+
		"\2\2\2\u01df\u01dd\3\2\2\2\u01df\u01de\3\2\2\2\u01e0b\3\2\2\2\u01e1\u01e2"+
		"\7^\2\2\u01e2\u01e3\t\f\2\2\u01e3\u01e4\t\r\2\2\u01e4\u01eb\t\r\2\2\u01e5"+
		"\u01e6\7^\2\2\u01e6\u01e7\t\r\2\2\u01e7\u01eb\t\r\2\2\u01e8\u01e9\7^\2"+
		"\2\u01e9\u01eb\t\r\2\2\u01ea\u01e1\3\2\2\2\u01ea\u01e5\3\2\2\2\u01ea\u01e8"+
		"\3\2\2\2\u01ebd\3\2\2\2\u01ec\u01ed\7^\2\2\u01ed\u01ee\7w\2\2\u01ee\u01ef"+
		"\5g\62\2\u01ef\u01f0\5g\62\2\u01f0\u01f1\5g\62\2\u01f1\u01f2\5g\62\2\u01f2"+
		"f\3\2\2\2\u01f3\u01f4\t\16\2\2\u01f4h\3\2\2\2\u01f5\u01fb\7$\2\2\u01f6"+
		"\u01fa\n\17\2\2\u01f7\u01f8\7^\2\2\u01f8\u01fa\13\2\2\2\u01f9\u01f6\3"+
		"\2\2\2\u01f9\u01f7\3\2\2\2\u01fa\u01fd\3\2\2\2\u01fb\u01f9\3\2\2\2\u01fb"+
		"\u01fc\3\2\2\2\u01fc\u01fe\3\2\2\2\u01fd\u01fb\3\2\2\2\u01fe\u01ff\7$"+
		"\2\2\u01ffj\3\2\2\2\u0200\u0206\t\20\2\2\u0201\u0206\n\21\2\2\u0202\u0203"+
		"\t\22\2\2\u0203\u0206\t\23\2\2\u0204\u0206\t\24\2\2\u0205\u0200\3\2\2"+
		"\2\u0205\u0201\3\2\2\2\u0205\u0202\3\2\2\2\u0205\u0204\3\2\2\2\u0206l"+
		"\3\2\2\2\u0207\u0208\t\25\2\2\u0208n\3\2\2\2\u0209\u020a\t\26\2\2\u020a"+
		"p\3\2\2\2\u020b\u020c\t\27\2\2\u020cr\3\2\2\2\u020d\u020e\t\30\2\2\u020e"+
		"t\3\2\2\2\u020f\u0210\t\31\2\2\u0210v\3\2\2\2\u0211\u0212\t\32\2\2\u0212"+
		"x\3\2\2\2\u0213\u0214\t\33\2\2\u0214z\3\2\2\2\u0215\u0216\t\34\2\2\u0216"+
		"|\3\2\2\2\u0217\u0218\t\35\2\2\u0218~\3\2\2\2\u0219\u021a\t\36\2\2\u021a"+
		"\u0080\3\2\2\2\u021b\u021c\t\37\2\2\u021c\u0082\3\2\2\2\u021d\u021e\t"+
		" \2\2\u021e\u0084\3\2\2\2\u021f\u0220\t!\2\2\u0220\u0086\3\2\2\2\u0221"+
		"\u0222\t\"\2\2\u0222\u0088\3\2\2\2\u0223\u0224\t#\2\2\u0224\u008a\3\2"+
		"\2\2\u0225\u0226\t$\2\2\u0226\u008c\3\2\2\2\u0227\u0228\t%\2\2\u0228\u008e"+
		"\3\2\2\2\u0229\u022a\t&\2\2\u022a\u0090\3\2\2\2\u022b\u022c\t\'\2\2\u022c"+
		"\u0092\3\2\2\2\u022d\u022e\t(\2\2\u022e\u0094\3\2\2\2\u022f\u0230\t)\2"+
		"\2\u0230\u0096\3\2\2\2\u0231\u0232\t*\2\2\u0232\u0098\3\2\2\2\u0233\u0234"+
		"\t+\2\2\u0234\u009a\3\2\2\2\u0235\u0236\t,\2\2\u0236\u009c\3\2\2\2\u0237"+
		"\u0238\t-\2\2\u0238\u009e\3\2\2\2\u0239\u023a\t.\2\2\u023a\u00a0\3\2\2"+
		"\2+\2\3\4\5\6\u00a4\u00ab\u00b8\u00bf\u00ce\u00d5\u00e0\u00ec\u00ef\u0105"+
		"\u0162\u016b\u016d\u0173\u0178\u017e\u0185\u0187\u018a\u0195\u019e\u01a0"+
		"\u01a6\u01a8\u01ac\u01b2\u01bc\u01c0\u01c7\u01d2\u01d4\u01df\u01ea\u01f9"+
		"\u01fb\u0205\13\2\3\2\4\6\2\4\3\2\t\7\2\4\5\2\4\4\2\t\b\2\4\2\2\t#\2";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}