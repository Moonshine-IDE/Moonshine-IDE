// Generated from /Users/jimmyhu/Projects/TIDEDesktopService/language/TibboBasic/TibboBasicPreprocessorParser.g4 by ANTLR 4.8
// jshint ignore: start
var antlr4 = require('antlr4/index');
var TibboBasicPreprocessorParserListener = require('./TibboBasicPreprocessorParserListener').TibboBasicPreprocessorParserListener;
var TibboBasicPreprocessorParserVisitor = require('./TibboBasicPreprocessorParserVisitor').TibboBasicPreprocessorParserVisitor;

var grammarFileName = "TibboBasicPreprocessorParser.g4";


var serializedATN = ["\u0003\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964",
    "\u0003&}\u0004\u0002\t\u0002\u0004\u0003\t\u0003\u0004\u0004\t\u0004",
    "\u0004\u0005\t\u0005\u0004\u0006\t\u0006\u0004\u0007\t\u0007\u0004\b",
    "\t\b\u0004\t\t\t\u0004\n\t\n\u0003\u0002\u0007\u0002\u0016\n\u0002\f",
    "\u0002\u000e\u0002\u0019\u000b\u0002\u0003\u0002\u0007\u0002\u001c\n",
    "\u0002\f\u0002\u000e\u0002\u001f\u000b\u0002\u0003\u0002\u0005\u0002",
    "\"\n\u0002\u0003\u0003\u0007\u0003%\n\u0003\f\u0003\u000e\u0003(\u000b",
    "\u0003\u0003\u0003\u0003\u0003\u0003\u0004\u0003\u0004\u0003\u0004\u0005",
    "\u0004/\n\u0004\u0003\u0005\u0003\u0005\u0003\u0006\u0003\u0006\u0003",
    "\u0006\u0003\u0006\u0003\u0006\u0003\u0006\u0003\u0006\u0003\u0006\u0003",
    "\u0006\u0003\u0006\u0003\u0006\u0003\u0006\u0003\u0006\u0003\u0006\u0003",
    "\u0006\u0003\u0006\u0003\u0006\u0003\u0006\u0003\u0006\u0003\u0006\u0003",
    "\u0006\u0003\u0006\u0003\u0006\u0003\u0006\u0003\u0006\u0003\u0006\u0003",
    "\u0006\u0003\u0006\u0003\u0006\u0005\u0006P\n\u0006\u0005\u0006R\n\u0006",
    "\u0003\u0007\u0003\u0007\u0003\u0007\u0003\b\u0006\bX\n\b\r\b\u000e",
    "\bY\u0003\t\u0003\t\u0003\t\u0003\t\u0003\t\u0003\t\u0003\t\u0003\t",
    "\u0005\td\n\t\u0003\t\u0003\t\u0003\t\u0003\t\u0003\t\u0003\t\u0003",
    "\t\u0003\t\u0005\tn\n\t\u0003\t\u0003\t\u0003\t\u0003\t\u0003\t\u0003",
    "\t\u0007\tv\n\t\f\t\u000e\ty\u000b\t\u0003\n\u0003\n\u0003\n\u0002\u0003",
    "\u0010\u000b\u0002\u0004\u0006\b\n\f\u000e\u0010\u0012\u0002\u0006\u0003",
    "\u0002\u0004\u0005\u0003\u0002\u0017\u0018\u0003\u0002\u001b\u001e\u0003",
    "\u0002 \"\u0002\u008b\u0002\u0017\u0003\u0002\u0002\u0002\u0004&\u0003",
    "\u0002\u0002\u0002\u0006.\u0003\u0002\u0002\u0002\b0\u0003\u0002\u0002",
    "\u0002\nQ\u0003\u0002\u0002\u0002\fS\u0003\u0002\u0002\u0002\u000eW",
    "\u0003\u0002\u0002\u0002\u0010m\u0003\u0002\u0002\u0002\u0012z\u0003",
    "\u0002\u0002\u0002\u0014\u0016\u0005\u0004\u0003\u0002\u0015\u0014\u0003",
    "\u0002\u0002\u0002\u0016\u0019\u0003\u0002\u0002\u0002\u0017\u0015\u0003",
    "\u0002\u0002\u0002\u0017\u0018\u0003\u0002\u0002\u0002\u0018!\u0003",
    "\u0002\u0002\u0002\u0019\u0017\u0003\u0002\u0002\u0002\u001a\u001c\u0007",
    "\b\u0002\u0002\u001b\u001a\u0003\u0002\u0002\u0002\u001c\u001f\u0003",
    "\u0002\u0002\u0002\u001d\u001b\u0003\u0002\u0002\u0002\u001d\u001e\u0003",
    "\u0002\u0002\u0002\u001e\"\u0003\u0002\u0002\u0002\u001f\u001d\u0003",
    "\u0002\u0002\u0002 \"\u0007\u0002\u0002\u0003!\u001d\u0003\u0002\u0002",
    "\u0002! \u0003\u0002\u0002\u0002\"\u0003\u0003\u0002\u0002\u0002#%\u0007",
    "\b\u0002\u0002$#\u0003\u0002\u0002\u0002%(\u0003\u0002\u0002\u0002&",
    "$\u0003\u0002\u0002\u0002&\'\u0003\u0002\u0002\u0002\')\u0003\u0002",
    "\u0002\u0002(&\u0003\u0002\u0002\u0002)*\u0005\u0006\u0004\u0002*\u0005",
    "\u0003\u0002\u0002\u0002+/\u0005\f\u0007\u0002,/\u0005\n\u0006\u0002",
    "-/\u0005\b\u0005\u0002.+\u0003\u0002\u0002\u0002.,\u0003\u0002\u0002",
    "\u0002.-\u0003\u0002\u0002\u0002/\u0007\u0003\u0002\u0002\u000201\u0007",
    "\u0007\u0002\u00021\t\u0003\u0002\u0002\u000223\u0007\u0006\u0002\u0002",
    "34\u0007\f\u0002\u00024R\u0005\u0010\t\u000256\u0007\u0006\u0002\u0002",
    "67\u0007\r\u0002\u00027R\u0005\u0010\t\u000289\u0007\u0006\u0002\u0002",
    "9R\u0007\u000e\u0002\u0002:;\u0007\u0006\u0002\u0002;R\u0007\u0012\u0002",
    "\u0002<=\u0007\u0006\u0002\u0002=>\u0007\u0010\u0002\u0002>R\u0007!",
    "\u0002\u0002?@\u0007\u0006\u0002\u0002@A\u0007\u0011\u0002\u0002AR\u0007",
    "!\u0002\u0002BC\u0007\u0006\u0002\u0002CD\u0007\u000f\u0002\u0002DR",
    "\u0007!\u0002\u0002EF\u0007\u0006\u0002\u0002FG\u0007\t\u0002\u0002",
    "GR\u0005\u000e\b\u0002HI\u0007\u0006\u0002\u0002IJ\u0007\u0013\u0002",
    "\u0002JR\u0005\u000e\b\u0002KL\u0007\u0006\u0002\u0002LM\u0007\n\u0002",
    "\u0002MO\u0007!\u0002\u0002NP\u0005\u000e\b\u0002ON\u0003\u0002\u0002",
    "\u0002OP\u0003\u0002\u0002\u0002PR\u0003\u0002\u0002\u0002Q2\u0003\u0002",
    "\u0002\u0002Q5\u0003\u0002\u0002\u0002Q8\u0003\u0002\u0002\u0002Q:\u0003",
    "\u0002\u0002\u0002Q<\u0003\u0002\u0002\u0002Q?\u0003\u0002\u0002\u0002",
    "QB\u0003\u0002\u0002\u0002QE\u0003\u0002\u0002\u0002QH\u0003\u0002\u0002",
    "\u0002QK\u0003\u0002\u0002\u0002R\u000b\u0003\u0002\u0002\u0002ST\t",
    "\u0002\u0002\u0002TU\u0007&\u0002\u0002U\r\u0003\u0002\u0002\u0002V",
    "X\u0007$\u0002\u0002WV\u0003\u0002\u0002\u0002XY\u0003\u0002\u0002\u0002",
    "YW\u0003\u0002\u0002\u0002YZ\u0003\u0002\u0002\u0002Z\u000f\u0003\u0002",
    "\u0002\u0002[\\\b\t\u0001\u0002\\n\u0007\"\u0002\u0002]n\u0007 \u0002",
    "\u0002^c\u0007!\u0002\u0002_`\u0007\u0015\u0002\u0002`a\u0005\u0010",
    "\t\u0002ab\u0007\u0016\u0002\u0002bd\u0003\u0002\u0002\u0002c_\u0003",
    "\u0002\u0002\u0002cd\u0003\u0002\u0002\u0002dn\u0003\u0002\u0002\u0002",
    "ef\u0005\u0012\n\u0002fg\t\u0003\u0002\u0002gh\u0005\u0012\n\u0002h",
    "n\u0003\u0002\u0002\u0002ij\u0005\u0012\n\u0002jk\t\u0004\u0002\u0002",
    "kl\u0005\u0012\n\u0002ln\u0003\u0002\u0002\u0002m[\u0003\u0002\u0002",
    "\u0002m]\u0003\u0002\u0002\u0002m^\u0003\u0002\u0002\u0002me\u0003\u0002",
    "\u0002\u0002mi\u0003\u0002\u0002\u0002nw\u0003\u0002\u0002\u0002op\f",
    "\u0005\u0002\u0002pq\u0007\u0019\u0002\u0002qv\u0005\u0010\t\u0006r",
    "s\f\u0004\u0002\u0002st\u0007\u001a\u0002\u0002tv\u0005\u0010\t\u0005",
    "uo\u0003\u0002\u0002\u0002ur\u0003\u0002\u0002\u0002vy\u0003\u0002\u0002",
    "\u0002wu\u0003\u0002\u0002\u0002wx\u0003\u0002\u0002\u0002x\u0011\u0003",
    "\u0002\u0002\u0002yw\u0003\u0002\u0002\u0002z{\t\u0005\u0002\u0002{",
    "\u0013\u0003\u0002\u0002\u0002\u000e\u0017\u001d!&.OQYcmuw"].join("");


var atn = new antlr4.atn.ATNDeserializer().deserialize(serializedATN);

var decisionsToDFA = atn.decisionToState.map( function(ds, index) { return new antlr4.dfa.DFA(ds, index); });

var sharedContextCache = new antlr4.PredictionContextCache();

var literalNames = [ null, null, null, null, null, null, null, null, null, 
                     null, null, null, null, null, null, null, null, null, 
                     "'!'", "'('", "')'", "'='", "'<>'", null, null, "'<'", 
                     "'>'", "'<='", "'>='" ];

var symbolicNames = [ null, "WS", "INCLUDE", "INCLUDEPP", "SHARP", "CODE", 
                      "NEW_LINE", "PRAGMA", "DEFINE", "DEFINED", "IF", "ELIF", 
                      "ELSE", "UNDEF", "IFDEF", "IFNDEF", "ENDIF", "ERROR", 
                      "BANG", "LPAREN", "RPAREN", "EQUAL", "NOTEQUAL", "AND", 
                      "OR", "LT", "GT", "LE", "GE", "DIRECTIVE_WHITESPACES", 
                      "DIRECTIVE_STRING", "CONDITIONAL_SYMBOL", "DECIMAL_LITERAL", 
                      "FLOAT", "TEXT", "INCLUDE_DIRECITVE_TEXT_NEW_LINE", 
                      "INCLUDE_FILE" ];

var ruleNames =  [ "preprocessor", "line", "text", "codeLine", "directive", 
                   "include_file", "directive_text", "preprocessor_expression", 
                   "preprocessor_item" ];

function TibboBasicPreprocessorParser (input) {
	antlr4.Parser.call(this, input);
    this._interp = new antlr4.atn.ParserATNSimulator(this, atn, decisionsToDFA, sharedContextCache);
    this.ruleNames = ruleNames;
    this.literalNames = literalNames;
    this.symbolicNames = symbolicNames;
    return this;
}

TibboBasicPreprocessorParser.prototype = Object.create(antlr4.Parser.prototype);
TibboBasicPreprocessorParser.prototype.constructor = TibboBasicPreprocessorParser;

Object.defineProperty(TibboBasicPreprocessorParser.prototype, "atn", {
	get : function() {
		return atn;
	}
});

TibboBasicPreprocessorParser.EOF = antlr4.Token.EOF;
TibboBasicPreprocessorParser.WS = 1;
TibboBasicPreprocessorParser.INCLUDE = 2;
TibboBasicPreprocessorParser.INCLUDEPP = 3;
TibboBasicPreprocessorParser.SHARP = 4;
TibboBasicPreprocessorParser.CODE = 5;
TibboBasicPreprocessorParser.NEW_LINE = 6;
TibboBasicPreprocessorParser.PRAGMA = 7;
TibboBasicPreprocessorParser.DEFINE = 8;
TibboBasicPreprocessorParser.DEFINED = 9;
TibboBasicPreprocessorParser.IF = 10;
TibboBasicPreprocessorParser.ELIF = 11;
TibboBasicPreprocessorParser.ELSE = 12;
TibboBasicPreprocessorParser.UNDEF = 13;
TibboBasicPreprocessorParser.IFDEF = 14;
TibboBasicPreprocessorParser.IFNDEF = 15;
TibboBasicPreprocessorParser.ENDIF = 16;
TibboBasicPreprocessorParser.ERROR = 17;
TibboBasicPreprocessorParser.BANG = 18;
TibboBasicPreprocessorParser.LPAREN = 19;
TibboBasicPreprocessorParser.RPAREN = 20;
TibboBasicPreprocessorParser.EQUAL = 21;
TibboBasicPreprocessorParser.NOTEQUAL = 22;
TibboBasicPreprocessorParser.AND = 23;
TibboBasicPreprocessorParser.OR = 24;
TibboBasicPreprocessorParser.LT = 25;
TibboBasicPreprocessorParser.GT = 26;
TibboBasicPreprocessorParser.LE = 27;
TibboBasicPreprocessorParser.GE = 28;
TibboBasicPreprocessorParser.DIRECTIVE_WHITESPACES = 29;
TibboBasicPreprocessorParser.DIRECTIVE_STRING = 30;
TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL = 31;
TibboBasicPreprocessorParser.DECIMAL_LITERAL = 32;
TibboBasicPreprocessorParser.FLOAT = 33;
TibboBasicPreprocessorParser.TEXT = 34;
TibboBasicPreprocessorParser.INCLUDE_DIRECITVE_TEXT_NEW_LINE = 35;
TibboBasicPreprocessorParser.INCLUDE_FILE = 36;

TibboBasicPreprocessorParser.RULE_preprocessor = 0;
TibboBasicPreprocessorParser.RULE_line = 1;
TibboBasicPreprocessorParser.RULE_text = 2;
TibboBasicPreprocessorParser.RULE_codeLine = 3;
TibboBasicPreprocessorParser.RULE_directive = 4;
TibboBasicPreprocessorParser.RULE_include_file = 5;
TibboBasicPreprocessorParser.RULE_directive_text = 6;
TibboBasicPreprocessorParser.RULE_preprocessor_expression = 7;
TibboBasicPreprocessorParser.RULE_preprocessor_item = 8;


function PreprocessorContext(parser, parent, invokingState) {
	if(parent===undefined) {
	    parent = null;
	}
	if(invokingState===undefined || invokingState===null) {
		invokingState = -1;
	}
	antlr4.ParserRuleContext.call(this, parent, invokingState);
    this.parser = parser;
    this.ruleIndex = TibboBasicPreprocessorParser.RULE_preprocessor;
    return this;
}

PreprocessorContext.prototype = Object.create(antlr4.ParserRuleContext.prototype);
PreprocessorContext.prototype.constructor = PreprocessorContext;

PreprocessorContext.prototype.EOF = function() {
    return this.getToken(TibboBasicPreprocessorParser.EOF, 0);
};

PreprocessorContext.prototype.line = function(i) {
    if(i===undefined) {
        i = null;
    }
    if(i===null) {
        return this.getTypedRuleContexts(LineContext);
    } else {
        return this.getTypedRuleContext(LineContext,i);
    }
};

PreprocessorContext.prototype.NEW_LINE = function(i) {
	if(i===undefined) {
		i = null;
	}
    if(i===null) {
        return this.getTokens(TibboBasicPreprocessorParser.NEW_LINE);
    } else {
        return this.getToken(TibboBasicPreprocessorParser.NEW_LINE, i);
    }
};


PreprocessorContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterPreprocessor(this);
	}
};

PreprocessorContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitPreprocessor(this);
	}
};

PreprocessorContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitPreprocessor(this);
    } else {
        return visitor.visitChildren(this);
    }
};




TibboBasicPreprocessorParser.PreprocessorContext = PreprocessorContext;

TibboBasicPreprocessorParser.prototype.preprocessor = function() {

    var localctx = new PreprocessorContext(this, this._ctx, this.state);
    this.enterRule(localctx, 0, TibboBasicPreprocessorParser.RULE_preprocessor);
    var _la = 0; // Token type
    try {
        this.enterOuterAlt(localctx, 1);
        this.state = 21;
        this._errHandler.sync(this);
        var _alt = this._interp.adaptivePredict(this._input,0,this._ctx)
        while(_alt!=2 && _alt!=antlr4.atn.ATN.INVALID_ALT_NUMBER) {
            if(_alt===1) {
                this.state = 18;
                this.line(); 
            }
            this.state = 23;
            this._errHandler.sync(this);
            _alt = this._interp.adaptivePredict(this._input,0,this._ctx);
        }

        this.state = 31;
        this._errHandler.sync(this);
        var la_ = this._interp.adaptivePredict(this._input,2,this._ctx);
        switch(la_) {
        case 1:
            this.state = 27;
            this._errHandler.sync(this);
            _la = this._input.LA(1);
            while(_la===TibboBasicPreprocessorParser.NEW_LINE) {
                this.state = 24;
                this.match(TibboBasicPreprocessorParser.NEW_LINE);
                this.state = 29;
                this._errHandler.sync(this);
                _la = this._input.LA(1);
            }
            break;

        case 2:
            this.state = 30;
            this.match(TibboBasicPreprocessorParser.EOF);
            break;

        }
    } catch (re) {
    	if(re instanceof antlr4.error.RecognitionException) {
	        localctx.exception = re;
	        this._errHandler.reportError(this, re);
	        this._errHandler.recover(this, re);
	    } else {
	    	throw re;
	    }
    } finally {
        this.exitRule();
    }
    return localctx;
};


function LineContext(parser, parent, invokingState) {
	if(parent===undefined) {
	    parent = null;
	}
	if(invokingState===undefined || invokingState===null) {
		invokingState = -1;
	}
	antlr4.ParserRuleContext.call(this, parent, invokingState);
    this.parser = parser;
    this.ruleIndex = TibboBasicPreprocessorParser.RULE_line;
    return this;
}

LineContext.prototype = Object.create(antlr4.ParserRuleContext.prototype);
LineContext.prototype.constructor = LineContext;

LineContext.prototype.text = function() {
    return this.getTypedRuleContext(TextContext,0);
};

LineContext.prototype.NEW_LINE = function(i) {
	if(i===undefined) {
		i = null;
	}
    if(i===null) {
        return this.getTokens(TibboBasicPreprocessorParser.NEW_LINE);
    } else {
        return this.getToken(TibboBasicPreprocessorParser.NEW_LINE, i);
    }
};


LineContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterLine(this);
	}
};

LineContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitLine(this);
	}
};

LineContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitLine(this);
    } else {
        return visitor.visitChildren(this);
    }
};




TibboBasicPreprocessorParser.LineContext = LineContext;

TibboBasicPreprocessorParser.prototype.line = function() {

    var localctx = new LineContext(this, this._ctx, this.state);
    this.enterRule(localctx, 2, TibboBasicPreprocessorParser.RULE_line);
    var _la = 0; // Token type
    try {
        this.enterOuterAlt(localctx, 1);
        this.state = 36;
        this._errHandler.sync(this);
        _la = this._input.LA(1);
        while(_la===TibboBasicPreprocessorParser.NEW_LINE) {
            this.state = 33;
            this.match(TibboBasicPreprocessorParser.NEW_LINE);
            this.state = 38;
            this._errHandler.sync(this);
            _la = this._input.LA(1);
        }
        this.state = 39;
        this.text();
    } catch (re) {
    	if(re instanceof antlr4.error.RecognitionException) {
	        localctx.exception = re;
	        this._errHandler.reportError(this, re);
	        this._errHandler.recover(this, re);
	    } else {
	    	throw re;
	    }
    } finally {
        this.exitRule();
    }
    return localctx;
};


function TextContext(parser, parent, invokingState) {
	if(parent===undefined) {
	    parent = null;
	}
	if(invokingState===undefined || invokingState===null) {
		invokingState = -1;
	}
	antlr4.ParserRuleContext.call(this, parent, invokingState);
    this.parser = parser;
    this.ruleIndex = TibboBasicPreprocessorParser.RULE_text;
    return this;
}

TextContext.prototype = Object.create(antlr4.ParserRuleContext.prototype);
TextContext.prototype.constructor = TextContext;

TextContext.prototype.include_file = function() {
    return this.getTypedRuleContext(Include_fileContext,0);
};

TextContext.prototype.directive = function() {
    return this.getTypedRuleContext(DirectiveContext,0);
};

TextContext.prototype.codeLine = function() {
    return this.getTypedRuleContext(CodeLineContext,0);
};

TextContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterText(this);
	}
};

TextContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitText(this);
	}
};

TextContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitText(this);
    } else {
        return visitor.visitChildren(this);
    }
};




TibboBasicPreprocessorParser.TextContext = TextContext;

TibboBasicPreprocessorParser.prototype.text = function() {

    var localctx = new TextContext(this, this._ctx, this.state);
    this.enterRule(localctx, 4, TibboBasicPreprocessorParser.RULE_text);
    try {
        this.state = 44;
        this._errHandler.sync(this);
        switch(this._input.LA(1)) {
        case TibboBasicPreprocessorParser.INCLUDE:
        case TibboBasicPreprocessorParser.INCLUDEPP:
            this.enterOuterAlt(localctx, 1);
            this.state = 41;
            this.include_file();
            break;
        case TibboBasicPreprocessorParser.SHARP:
            this.enterOuterAlt(localctx, 2);
            this.state = 42;
            this.directive();
            break;
        case TibboBasicPreprocessorParser.CODE:
            this.enterOuterAlt(localctx, 3);
            this.state = 43;
            this.codeLine();
            break;
        default:
            throw new antlr4.error.NoViableAltException(this);
        }
    } catch (re) {
    	if(re instanceof antlr4.error.RecognitionException) {
	        localctx.exception = re;
	        this._errHandler.reportError(this, re);
	        this._errHandler.recover(this, re);
	    } else {
	    	throw re;
	    }
    } finally {
        this.exitRule();
    }
    return localctx;
};


function CodeLineContext(parser, parent, invokingState) {
	if(parent===undefined) {
	    parent = null;
	}
	if(invokingState===undefined || invokingState===null) {
		invokingState = -1;
	}
	antlr4.ParserRuleContext.call(this, parent, invokingState);
    this.parser = parser;
    this.ruleIndex = TibboBasicPreprocessorParser.RULE_codeLine;
    return this;
}

CodeLineContext.prototype = Object.create(antlr4.ParserRuleContext.prototype);
CodeLineContext.prototype.constructor = CodeLineContext;

CodeLineContext.prototype.CODE = function() {
    return this.getToken(TibboBasicPreprocessorParser.CODE, 0);
};

CodeLineContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterCodeLine(this);
	}
};

CodeLineContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitCodeLine(this);
	}
};

CodeLineContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitCodeLine(this);
    } else {
        return visitor.visitChildren(this);
    }
};




TibboBasicPreprocessorParser.CodeLineContext = CodeLineContext;

TibboBasicPreprocessorParser.prototype.codeLine = function() {

    var localctx = new CodeLineContext(this, this._ctx, this.state);
    this.enterRule(localctx, 6, TibboBasicPreprocessorParser.RULE_codeLine);
    try {
        this.enterOuterAlt(localctx, 1);
        this.state = 46;
        this.match(TibboBasicPreprocessorParser.CODE);
    } catch (re) {
    	if(re instanceof antlr4.error.RecognitionException) {
	        localctx.exception = re;
	        this._errHandler.reportError(this, re);
	        this._errHandler.recover(this, re);
	    } else {
	    	throw re;
	    }
    } finally {
        this.exitRule();
    }
    return localctx;
};


function DirectiveContext(parser, parent, invokingState) {
	if(parent===undefined) {
	    parent = null;
	}
	if(invokingState===undefined || invokingState===null) {
		invokingState = -1;
	}
	antlr4.ParserRuleContext.call(this, parent, invokingState);
    this.parser = parser;
    this.ruleIndex = TibboBasicPreprocessorParser.RULE_directive;
    return this;
}

DirectiveContext.prototype = Object.create(antlr4.ParserRuleContext.prototype);
DirectiveContext.prototype.constructor = DirectiveContext;


 
DirectiveContext.prototype.copyFrom = function(ctx) {
    antlr4.ParserRuleContext.prototype.copyFrom.call(this, ctx);
};


function PreprocessorDefContext(parser, ctx) {
	DirectiveContext.call(this, parser);
    DirectiveContext.prototype.copyFrom.call(this, ctx);
    return this;
}

PreprocessorDefContext.prototype = Object.create(DirectiveContext.prototype);
PreprocessorDefContext.prototype.constructor = PreprocessorDefContext;

TibboBasicPreprocessorParser.PreprocessorDefContext = PreprocessorDefContext;

PreprocessorDefContext.prototype.SHARP = function() {
    return this.getToken(TibboBasicPreprocessorParser.SHARP, 0);
};

PreprocessorDefContext.prototype.IFDEF = function() {
    return this.getToken(TibboBasicPreprocessorParser.IFDEF, 0);
};

PreprocessorDefContext.prototype.CONDITIONAL_SYMBOL = function() {
    return this.getToken(TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL, 0);
};

PreprocessorDefContext.prototype.IFNDEF = function() {
    return this.getToken(TibboBasicPreprocessorParser.IFNDEF, 0);
};
PreprocessorDefContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterPreprocessorDef(this);
	}
};

PreprocessorDefContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitPreprocessorDef(this);
	}
};

PreprocessorDefContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitPreprocessorDef(this);
    } else {
        return visitor.visitChildren(this);
    }
};


function PreprocessorErrorContext(parser, ctx) {
	DirectiveContext.call(this, parser);
    DirectiveContext.prototype.copyFrom.call(this, ctx);
    return this;
}

PreprocessorErrorContext.prototype = Object.create(DirectiveContext.prototype);
PreprocessorErrorContext.prototype.constructor = PreprocessorErrorContext;

TibboBasicPreprocessorParser.PreprocessorErrorContext = PreprocessorErrorContext;

PreprocessorErrorContext.prototype.SHARP = function() {
    return this.getToken(TibboBasicPreprocessorParser.SHARP, 0);
};

PreprocessorErrorContext.prototype.ERROR = function() {
    return this.getToken(TibboBasicPreprocessorParser.ERROR, 0);
};

PreprocessorErrorContext.prototype.directive_text = function() {
    return this.getTypedRuleContext(Directive_textContext,0);
};
PreprocessorErrorContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterPreprocessorError(this);
	}
};

PreprocessorErrorContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitPreprocessorError(this);
	}
};

PreprocessorErrorContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitPreprocessorError(this);
    } else {
        return visitor.visitChildren(this);
    }
};


function PreprocessorUndefContext(parser, ctx) {
	DirectiveContext.call(this, parser);
    DirectiveContext.prototype.copyFrom.call(this, ctx);
    return this;
}

PreprocessorUndefContext.prototype = Object.create(DirectiveContext.prototype);
PreprocessorUndefContext.prototype.constructor = PreprocessorUndefContext;

TibboBasicPreprocessorParser.PreprocessorUndefContext = PreprocessorUndefContext;

PreprocessorUndefContext.prototype.SHARP = function() {
    return this.getToken(TibboBasicPreprocessorParser.SHARP, 0);
};

PreprocessorUndefContext.prototype.UNDEF = function() {
    return this.getToken(TibboBasicPreprocessorParser.UNDEF, 0);
};

PreprocessorUndefContext.prototype.CONDITIONAL_SYMBOL = function() {
    return this.getToken(TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL, 0);
};
PreprocessorUndefContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterPreprocessorUndef(this);
	}
};

PreprocessorUndefContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitPreprocessorUndef(this);
	}
};

PreprocessorUndefContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitPreprocessorUndef(this);
    } else {
        return visitor.visitChildren(this);
    }
};


function PreprocessorConditionalContext(parser, ctx) {
	DirectiveContext.call(this, parser);
    DirectiveContext.prototype.copyFrom.call(this, ctx);
    return this;
}

PreprocessorConditionalContext.prototype = Object.create(DirectiveContext.prototype);
PreprocessorConditionalContext.prototype.constructor = PreprocessorConditionalContext;

TibboBasicPreprocessorParser.PreprocessorConditionalContext = PreprocessorConditionalContext;

PreprocessorConditionalContext.prototype.SHARP = function() {
    return this.getToken(TibboBasicPreprocessorParser.SHARP, 0);
};

PreprocessorConditionalContext.prototype.IF = function() {
    return this.getToken(TibboBasicPreprocessorParser.IF, 0);
};

PreprocessorConditionalContext.prototype.preprocessor_expression = function() {
    return this.getTypedRuleContext(Preprocessor_expressionContext,0);
};

PreprocessorConditionalContext.prototype.ELIF = function() {
    return this.getToken(TibboBasicPreprocessorParser.ELIF, 0);
};

PreprocessorConditionalContext.prototype.ELSE = function() {
    return this.getToken(TibboBasicPreprocessorParser.ELSE, 0);
};
PreprocessorConditionalContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterPreprocessorConditional(this);
	}
};

PreprocessorConditionalContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitPreprocessorConditional(this);
	}
};

PreprocessorConditionalContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitPreprocessorConditional(this);
    } else {
        return visitor.visitChildren(this);
    }
};


function PreprocessorPragmaContext(parser, ctx) {
	DirectiveContext.call(this, parser);
    DirectiveContext.prototype.copyFrom.call(this, ctx);
    return this;
}

PreprocessorPragmaContext.prototype = Object.create(DirectiveContext.prototype);
PreprocessorPragmaContext.prototype.constructor = PreprocessorPragmaContext;

TibboBasicPreprocessorParser.PreprocessorPragmaContext = PreprocessorPragmaContext;

PreprocessorPragmaContext.prototype.SHARP = function() {
    return this.getToken(TibboBasicPreprocessorParser.SHARP, 0);
};

PreprocessorPragmaContext.prototype.PRAGMA = function() {
    return this.getToken(TibboBasicPreprocessorParser.PRAGMA, 0);
};

PreprocessorPragmaContext.prototype.directive_text = function() {
    return this.getTypedRuleContext(Directive_textContext,0);
};
PreprocessorPragmaContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterPreprocessorPragma(this);
	}
};

PreprocessorPragmaContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitPreprocessorPragma(this);
	}
};

PreprocessorPragmaContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitPreprocessorPragma(this);
    } else {
        return visitor.visitChildren(this);
    }
};


function PreprocessorDefineContext(parser, ctx) {
	DirectiveContext.call(this, parser);
    DirectiveContext.prototype.copyFrom.call(this, ctx);
    return this;
}

PreprocessorDefineContext.prototype = Object.create(DirectiveContext.prototype);
PreprocessorDefineContext.prototype.constructor = PreprocessorDefineContext;

TibboBasicPreprocessorParser.PreprocessorDefineContext = PreprocessorDefineContext;

PreprocessorDefineContext.prototype.SHARP = function() {
    return this.getToken(TibboBasicPreprocessorParser.SHARP, 0);
};

PreprocessorDefineContext.prototype.DEFINE = function() {
    return this.getToken(TibboBasicPreprocessorParser.DEFINE, 0);
};

PreprocessorDefineContext.prototype.CONDITIONAL_SYMBOL = function() {
    return this.getToken(TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL, 0);
};

PreprocessorDefineContext.prototype.directive_text = function() {
    return this.getTypedRuleContext(Directive_textContext,0);
};
PreprocessorDefineContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterPreprocessorDefine(this);
	}
};

PreprocessorDefineContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitPreprocessorDefine(this);
	}
};

PreprocessorDefineContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitPreprocessorDefine(this);
    } else {
        return visitor.visitChildren(this);
    }
};


function PreprocessorEndConditionalContext(parser, ctx) {
	DirectiveContext.call(this, parser);
    DirectiveContext.prototype.copyFrom.call(this, ctx);
    return this;
}

PreprocessorEndConditionalContext.prototype = Object.create(DirectiveContext.prototype);
PreprocessorEndConditionalContext.prototype.constructor = PreprocessorEndConditionalContext;

TibboBasicPreprocessorParser.PreprocessorEndConditionalContext = PreprocessorEndConditionalContext;

PreprocessorEndConditionalContext.prototype.SHARP = function() {
    return this.getToken(TibboBasicPreprocessorParser.SHARP, 0);
};

PreprocessorEndConditionalContext.prototype.ENDIF = function() {
    return this.getToken(TibboBasicPreprocessorParser.ENDIF, 0);
};
PreprocessorEndConditionalContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterPreprocessorEndConditional(this);
	}
};

PreprocessorEndConditionalContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitPreprocessorEndConditional(this);
	}
};

PreprocessorEndConditionalContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitPreprocessorEndConditional(this);
    } else {
        return visitor.visitChildren(this);
    }
};



TibboBasicPreprocessorParser.DirectiveContext = DirectiveContext;

TibboBasicPreprocessorParser.prototype.directive = function() {

    var localctx = new DirectiveContext(this, this._ctx, this.state);
    this.enterRule(localctx, 8, TibboBasicPreprocessorParser.RULE_directive);
    var _la = 0; // Token type
    try {
        this.state = 79;
        this._errHandler.sync(this);
        var la_ = this._interp.adaptivePredict(this._input,6,this._ctx);
        switch(la_) {
        case 1:
            localctx = new PreprocessorConditionalContext(this, localctx);
            this.enterOuterAlt(localctx, 1);
            this.state = 48;
            this.match(TibboBasicPreprocessorParser.SHARP);
            this.state = 49;
            this.match(TibboBasicPreprocessorParser.IF);
            this.state = 50;
            this.preprocessor_expression(0);
            break;

        case 2:
            localctx = new PreprocessorConditionalContext(this, localctx);
            this.enterOuterAlt(localctx, 2);
            this.state = 51;
            this.match(TibboBasicPreprocessorParser.SHARP);
            this.state = 52;
            this.match(TibboBasicPreprocessorParser.ELIF);
            this.state = 53;
            this.preprocessor_expression(0);
            break;

        case 3:
            localctx = new PreprocessorConditionalContext(this, localctx);
            this.enterOuterAlt(localctx, 3);
            this.state = 54;
            this.match(TibboBasicPreprocessorParser.SHARP);
            this.state = 55;
            this.match(TibboBasicPreprocessorParser.ELSE);
            break;

        case 4:
            localctx = new PreprocessorEndConditionalContext(this, localctx);
            this.enterOuterAlt(localctx, 4);
            this.state = 56;
            this.match(TibboBasicPreprocessorParser.SHARP);
            this.state = 57;
            this.match(TibboBasicPreprocessorParser.ENDIF);
            break;

        case 5:
            localctx = new PreprocessorDefContext(this, localctx);
            this.enterOuterAlt(localctx, 5);
            this.state = 58;
            this.match(TibboBasicPreprocessorParser.SHARP);
            this.state = 59;
            this.match(TibboBasicPreprocessorParser.IFDEF);
            this.state = 60;
            this.match(TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL);
            break;

        case 6:
            localctx = new PreprocessorDefContext(this, localctx);
            this.enterOuterAlt(localctx, 6);
            this.state = 61;
            this.match(TibboBasicPreprocessorParser.SHARP);
            this.state = 62;
            this.match(TibboBasicPreprocessorParser.IFNDEF);
            this.state = 63;
            this.match(TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL);
            break;

        case 7:
            localctx = new PreprocessorUndefContext(this, localctx);
            this.enterOuterAlt(localctx, 7);
            this.state = 64;
            this.match(TibboBasicPreprocessorParser.SHARP);
            this.state = 65;
            this.match(TibboBasicPreprocessorParser.UNDEF);
            this.state = 66;
            this.match(TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL);
            break;

        case 8:
            localctx = new PreprocessorPragmaContext(this, localctx);
            this.enterOuterAlt(localctx, 8);
            this.state = 67;
            this.match(TibboBasicPreprocessorParser.SHARP);
            this.state = 68;
            this.match(TibboBasicPreprocessorParser.PRAGMA);
            this.state = 69;
            this.directive_text();
            break;

        case 9:
            localctx = new PreprocessorErrorContext(this, localctx);
            this.enterOuterAlt(localctx, 9);
            this.state = 70;
            this.match(TibboBasicPreprocessorParser.SHARP);
            this.state = 71;
            this.match(TibboBasicPreprocessorParser.ERROR);
            this.state = 72;
            this.directive_text();
            break;

        case 10:
            localctx = new PreprocessorDefineContext(this, localctx);
            this.enterOuterAlt(localctx, 10);
            this.state = 73;
            this.match(TibboBasicPreprocessorParser.SHARP);
            this.state = 74;
            this.match(TibboBasicPreprocessorParser.DEFINE);
            this.state = 75;
            this.match(TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL);
            this.state = 77;
            this._errHandler.sync(this);
            _la = this._input.LA(1);
            if(_la===TibboBasicPreprocessorParser.TEXT) {
                this.state = 76;
                this.directive_text();
            }

            break;

        }
    } catch (re) {
    	if(re instanceof antlr4.error.RecognitionException) {
	        localctx.exception = re;
	        this._errHandler.reportError(this, re);
	        this._errHandler.recover(this, re);
	    } else {
	    	throw re;
	    }
    } finally {
        this.exitRule();
    }
    return localctx;
};


function Include_fileContext(parser, parent, invokingState) {
	if(parent===undefined) {
	    parent = null;
	}
	if(invokingState===undefined || invokingState===null) {
		invokingState = -1;
	}
	antlr4.ParserRuleContext.call(this, parent, invokingState);
    this.parser = parser;
    this.ruleIndex = TibboBasicPreprocessorParser.RULE_include_file;
    return this;
}

Include_fileContext.prototype = Object.create(antlr4.ParserRuleContext.prototype);
Include_fileContext.prototype.constructor = Include_fileContext;


 
Include_fileContext.prototype.copyFrom = function(ctx) {
    antlr4.ParserRuleContext.prototype.copyFrom.call(this, ctx);
};


function PreprocessorIncludeContext(parser, ctx) {
	Include_fileContext.call(this, parser);
    Include_fileContext.prototype.copyFrom.call(this, ctx);
    return this;
}

PreprocessorIncludeContext.prototype = Object.create(Include_fileContext.prototype);
PreprocessorIncludeContext.prototype.constructor = PreprocessorIncludeContext;

TibboBasicPreprocessorParser.PreprocessorIncludeContext = PreprocessorIncludeContext;

PreprocessorIncludeContext.prototype.INCLUDE_FILE = function() {
    return this.getToken(TibboBasicPreprocessorParser.INCLUDE_FILE, 0);
};

PreprocessorIncludeContext.prototype.INCLUDE = function() {
    return this.getToken(TibboBasicPreprocessorParser.INCLUDE, 0);
};

PreprocessorIncludeContext.prototype.INCLUDEPP = function() {
    return this.getToken(TibboBasicPreprocessorParser.INCLUDEPP, 0);
};
PreprocessorIncludeContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterPreprocessorInclude(this);
	}
};

PreprocessorIncludeContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitPreprocessorInclude(this);
	}
};

PreprocessorIncludeContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitPreprocessorInclude(this);
    } else {
        return visitor.visitChildren(this);
    }
};



TibboBasicPreprocessorParser.Include_fileContext = Include_fileContext;

TibboBasicPreprocessorParser.prototype.include_file = function() {

    var localctx = new Include_fileContext(this, this._ctx, this.state);
    this.enterRule(localctx, 10, TibboBasicPreprocessorParser.RULE_include_file);
    var _la = 0; // Token type
    try {
        localctx = new PreprocessorIncludeContext(this, localctx);
        this.enterOuterAlt(localctx, 1);
        this.state = 81;
        _la = this._input.LA(1);
        if(!(_la===TibboBasicPreprocessorParser.INCLUDE || _la===TibboBasicPreprocessorParser.INCLUDEPP)) {
        this._errHandler.recoverInline(this);
        }
        else {
        	this._errHandler.reportMatch(this);
            this.consume();
        }
        this.state = 82;
        this.match(TibboBasicPreprocessorParser.INCLUDE_FILE);
    } catch (re) {
    	if(re instanceof antlr4.error.RecognitionException) {
	        localctx.exception = re;
	        this._errHandler.reportError(this, re);
	        this._errHandler.recover(this, re);
	    } else {
	    	throw re;
	    }
    } finally {
        this.exitRule();
    }
    return localctx;
};


function Directive_textContext(parser, parent, invokingState) {
	if(parent===undefined) {
	    parent = null;
	}
	if(invokingState===undefined || invokingState===null) {
		invokingState = -1;
	}
	antlr4.ParserRuleContext.call(this, parent, invokingState);
    this.parser = parser;
    this.ruleIndex = TibboBasicPreprocessorParser.RULE_directive_text;
    return this;
}

Directive_textContext.prototype = Object.create(antlr4.ParserRuleContext.prototype);
Directive_textContext.prototype.constructor = Directive_textContext;

Directive_textContext.prototype.TEXT = function(i) {
	if(i===undefined) {
		i = null;
	}
    if(i===null) {
        return this.getTokens(TibboBasicPreprocessorParser.TEXT);
    } else {
        return this.getToken(TibboBasicPreprocessorParser.TEXT, i);
    }
};


Directive_textContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterDirective_text(this);
	}
};

Directive_textContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitDirective_text(this);
	}
};

Directive_textContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitDirective_text(this);
    } else {
        return visitor.visitChildren(this);
    }
};




TibboBasicPreprocessorParser.Directive_textContext = Directive_textContext;

TibboBasicPreprocessorParser.prototype.directive_text = function() {

    var localctx = new Directive_textContext(this, this._ctx, this.state);
    this.enterRule(localctx, 12, TibboBasicPreprocessorParser.RULE_directive_text);
    var _la = 0; // Token type
    try {
        this.enterOuterAlt(localctx, 1);
        this.state = 85; 
        this._errHandler.sync(this);
        _la = this._input.LA(1);
        do {
            this.state = 84;
            this.match(TibboBasicPreprocessorParser.TEXT);
            this.state = 87; 
            this._errHandler.sync(this);
            _la = this._input.LA(1);
        } while(_la===TibboBasicPreprocessorParser.TEXT);
    } catch (re) {
    	if(re instanceof antlr4.error.RecognitionException) {
	        localctx.exception = re;
	        this._errHandler.reportError(this, re);
	        this._errHandler.recover(this, re);
	    } else {
	    	throw re;
	    }
    } finally {
        this.exitRule();
    }
    return localctx;
};


function Preprocessor_expressionContext(parser, parent, invokingState) {
	if(parent===undefined) {
	    parent = null;
	}
	if(invokingState===undefined || invokingState===null) {
		invokingState = -1;
	}
	antlr4.ParserRuleContext.call(this, parent, invokingState);
    this.parser = parser;
    this.ruleIndex = TibboBasicPreprocessorParser.RULE_preprocessor_expression;
    return this;
}

Preprocessor_expressionContext.prototype = Object.create(antlr4.ParserRuleContext.prototype);
Preprocessor_expressionContext.prototype.constructor = Preprocessor_expressionContext;


 
Preprocessor_expressionContext.prototype.copyFrom = function(ctx) {
    antlr4.ParserRuleContext.prototype.copyFrom.call(this, ctx);
};

function PreprocessorBinaryContext(parser, ctx) {
	Preprocessor_expressionContext.call(this, parser);
    this.op = null; // Token;
    Preprocessor_expressionContext.prototype.copyFrom.call(this, ctx);
    return this;
}

PreprocessorBinaryContext.prototype = Object.create(Preprocessor_expressionContext.prototype);
PreprocessorBinaryContext.prototype.constructor = PreprocessorBinaryContext;

TibboBasicPreprocessorParser.PreprocessorBinaryContext = PreprocessorBinaryContext;

PreprocessorBinaryContext.prototype.preprocessor_item = function(i) {
    if(i===undefined) {
        i = null;
    }
    if(i===null) {
        return this.getTypedRuleContexts(Preprocessor_itemContext);
    } else {
        return this.getTypedRuleContext(Preprocessor_itemContext,i);
    }
};

PreprocessorBinaryContext.prototype.EQUAL = function() {
    return this.getToken(TibboBasicPreprocessorParser.EQUAL, 0);
};

PreprocessorBinaryContext.prototype.NOTEQUAL = function() {
    return this.getToken(TibboBasicPreprocessorParser.NOTEQUAL, 0);
};

PreprocessorBinaryContext.prototype.LT = function() {
    return this.getToken(TibboBasicPreprocessorParser.LT, 0);
};

PreprocessorBinaryContext.prototype.GT = function() {
    return this.getToken(TibboBasicPreprocessorParser.GT, 0);
};

PreprocessorBinaryContext.prototype.LE = function() {
    return this.getToken(TibboBasicPreprocessorParser.LE, 0);
};

PreprocessorBinaryContext.prototype.GE = function() {
    return this.getToken(TibboBasicPreprocessorParser.GE, 0);
};

PreprocessorBinaryContext.prototype.preprocessor_expression = function(i) {
    if(i===undefined) {
        i = null;
    }
    if(i===null) {
        return this.getTypedRuleContexts(Preprocessor_expressionContext);
    } else {
        return this.getTypedRuleContext(Preprocessor_expressionContext,i);
    }
};

PreprocessorBinaryContext.prototype.AND = function() {
    return this.getToken(TibboBasicPreprocessorParser.AND, 0);
};

PreprocessorBinaryContext.prototype.OR = function() {
    return this.getToken(TibboBasicPreprocessorParser.OR, 0);
};
PreprocessorBinaryContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterPreprocessorBinary(this);
	}
};

PreprocessorBinaryContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitPreprocessorBinary(this);
	}
};

PreprocessorBinaryContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitPreprocessorBinary(this);
    } else {
        return visitor.visitChildren(this);
    }
};


function PreprocessorConstantContext(parser, ctx) {
	Preprocessor_expressionContext.call(this, parser);
    Preprocessor_expressionContext.prototype.copyFrom.call(this, ctx);
    return this;
}

PreprocessorConstantContext.prototype = Object.create(Preprocessor_expressionContext.prototype);
PreprocessorConstantContext.prototype.constructor = PreprocessorConstantContext;

TibboBasicPreprocessorParser.PreprocessorConstantContext = PreprocessorConstantContext;

PreprocessorConstantContext.prototype.DECIMAL_LITERAL = function() {
    return this.getToken(TibboBasicPreprocessorParser.DECIMAL_LITERAL, 0);
};

PreprocessorConstantContext.prototype.DIRECTIVE_STRING = function() {
    return this.getToken(TibboBasicPreprocessorParser.DIRECTIVE_STRING, 0);
};
PreprocessorConstantContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterPreprocessorConstant(this);
	}
};

PreprocessorConstantContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitPreprocessorConstant(this);
	}
};

PreprocessorConstantContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitPreprocessorConstant(this);
    } else {
        return visitor.visitChildren(this);
    }
};


function PreprocessorConditionalSymbolContext(parser, ctx) {
	Preprocessor_expressionContext.call(this, parser);
    Preprocessor_expressionContext.prototype.copyFrom.call(this, ctx);
    return this;
}

PreprocessorConditionalSymbolContext.prototype = Object.create(Preprocessor_expressionContext.prototype);
PreprocessorConditionalSymbolContext.prototype.constructor = PreprocessorConditionalSymbolContext;

TibboBasicPreprocessorParser.PreprocessorConditionalSymbolContext = PreprocessorConditionalSymbolContext;

PreprocessorConditionalSymbolContext.prototype.CONDITIONAL_SYMBOL = function() {
    return this.getToken(TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL, 0);
};

PreprocessorConditionalSymbolContext.prototype.LPAREN = function() {
    return this.getToken(TibboBasicPreprocessorParser.LPAREN, 0);
};

PreprocessorConditionalSymbolContext.prototype.preprocessor_expression = function() {
    return this.getTypedRuleContext(Preprocessor_expressionContext,0);
};

PreprocessorConditionalSymbolContext.prototype.RPAREN = function() {
    return this.getToken(TibboBasicPreprocessorParser.RPAREN, 0);
};
PreprocessorConditionalSymbolContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterPreprocessorConditionalSymbol(this);
	}
};

PreprocessorConditionalSymbolContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitPreprocessorConditionalSymbol(this);
	}
};

PreprocessorConditionalSymbolContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitPreprocessorConditionalSymbol(this);
    } else {
        return visitor.visitChildren(this);
    }
};



TibboBasicPreprocessorParser.prototype.preprocessor_expression = function(_p) {
	if(_p===undefined) {
	    _p = 0;
	}
    var _parentctx = this._ctx;
    var _parentState = this.state;
    var localctx = new Preprocessor_expressionContext(this, this._ctx, _parentState);
    var _prevctx = localctx;
    var _startState = 14;
    this.enterRecursionRule(localctx, 14, TibboBasicPreprocessorParser.RULE_preprocessor_expression, _p);
    var _la = 0; // Token type
    try {
        this.enterOuterAlt(localctx, 1);
        this.state = 107;
        this._errHandler.sync(this);
        var la_ = this._interp.adaptivePredict(this._input,9,this._ctx);
        switch(la_) {
        case 1:
            localctx = new PreprocessorConstantContext(this, localctx);
            this._ctx = localctx;
            _prevctx = localctx;

            this.state = 90;
            this.match(TibboBasicPreprocessorParser.DECIMAL_LITERAL);
            break;

        case 2:
            localctx = new PreprocessorConstantContext(this, localctx);
            this._ctx = localctx;
            _prevctx = localctx;
            this.state = 91;
            this.match(TibboBasicPreprocessorParser.DIRECTIVE_STRING);
            break;

        case 3:
            localctx = new PreprocessorConditionalSymbolContext(this, localctx);
            this._ctx = localctx;
            _prevctx = localctx;
            this.state = 92;
            this.match(TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL);
            this.state = 97;
            this._errHandler.sync(this);
            var la_ = this._interp.adaptivePredict(this._input,8,this._ctx);
            if(la_===1) {
                this.state = 93;
                this.match(TibboBasicPreprocessorParser.LPAREN);
                this.state = 94;
                this.preprocessor_expression(0);
                this.state = 95;
                this.match(TibboBasicPreprocessorParser.RPAREN);

            }
            break;

        case 4:
            localctx = new PreprocessorBinaryContext(this, localctx);
            this._ctx = localctx;
            _prevctx = localctx;
            this.state = 99;
            this.preprocessor_item();
            this.state = 100;
            localctx.op = this._input.LT(1);
            _la = this._input.LA(1);
            if(!(_la===TibboBasicPreprocessorParser.EQUAL || _la===TibboBasicPreprocessorParser.NOTEQUAL)) {
                localctx.op = this._errHandler.recoverInline(this);
            }
            else {
            	this._errHandler.reportMatch(this);
                this.consume();
            }
            this.state = 101;
            this.preprocessor_item();
            break;

        case 5:
            localctx = new PreprocessorBinaryContext(this, localctx);
            this._ctx = localctx;
            _prevctx = localctx;
            this.state = 103;
            this.preprocessor_item();
            this.state = 104;
            localctx.op = this._input.LT(1);
            _la = this._input.LA(1);
            if(!((((_la) & ~0x1f) == 0 && ((1 << _la) & ((1 << TibboBasicPreprocessorParser.LT) | (1 << TibboBasicPreprocessorParser.GT) | (1 << TibboBasicPreprocessorParser.LE) | (1 << TibboBasicPreprocessorParser.GE))) !== 0))) {
                localctx.op = this._errHandler.recoverInline(this);
            }
            else {
            	this._errHandler.reportMatch(this);
                this.consume();
            }
            this.state = 105;
            this.preprocessor_item();
            break;

        }
        this._ctx.stop = this._input.LT(-1);
        this.state = 117;
        this._errHandler.sync(this);
        var _alt = this._interp.adaptivePredict(this._input,11,this._ctx)
        while(_alt!=2 && _alt!=antlr4.atn.ATN.INVALID_ALT_NUMBER) {
            if(_alt===1) {
                if(this._parseListeners!==null) {
                    this.triggerExitRuleEvent();
                }
                _prevctx = localctx;
                this.state = 115;
                this._errHandler.sync(this);
                var la_ = this._interp.adaptivePredict(this._input,10,this._ctx);
                switch(la_) {
                case 1:
                    localctx = new PreprocessorBinaryContext(this, new Preprocessor_expressionContext(this, _parentctx, _parentState));
                    this.pushNewRecursionContext(localctx, _startState, TibboBasicPreprocessorParser.RULE_preprocessor_expression);
                    this.state = 109;
                    if (!( this.precpred(this._ctx, 3))) {
                        throw new antlr4.error.FailedPredicateException(this, "this.precpred(this._ctx, 3)");
                    }
                    this.state = 110;
                    localctx.op = this.match(TibboBasicPreprocessorParser.AND);
                    this.state = 111;
                    this.preprocessor_expression(4);
                    break;

                case 2:
                    localctx = new PreprocessorBinaryContext(this, new Preprocessor_expressionContext(this, _parentctx, _parentState));
                    this.pushNewRecursionContext(localctx, _startState, TibboBasicPreprocessorParser.RULE_preprocessor_expression);
                    this.state = 112;
                    if (!( this.precpred(this._ctx, 2))) {
                        throw new antlr4.error.FailedPredicateException(this, "this.precpred(this._ctx, 2)");
                    }
                    this.state = 113;
                    localctx.op = this.match(TibboBasicPreprocessorParser.OR);
                    this.state = 114;
                    this.preprocessor_expression(3);
                    break;

                } 
            }
            this.state = 119;
            this._errHandler.sync(this);
            _alt = this._interp.adaptivePredict(this._input,11,this._ctx);
        }

    } catch( error) {
        if(error instanceof antlr4.error.RecognitionException) {
	        localctx.exception = error;
	        this._errHandler.reportError(this, error);
	        this._errHandler.recover(this, error);
	    } else {
	    	throw error;
	    }
    } finally {
        this.unrollRecursionContexts(_parentctx)
    }
    return localctx;
};


function Preprocessor_itemContext(parser, parent, invokingState) {
	if(parent===undefined) {
	    parent = null;
	}
	if(invokingState===undefined || invokingState===null) {
		invokingState = -1;
	}
	antlr4.ParserRuleContext.call(this, parent, invokingState);
    this.parser = parser;
    this.ruleIndex = TibboBasicPreprocessorParser.RULE_preprocessor_item;
    return this;
}

Preprocessor_itemContext.prototype = Object.create(antlr4.ParserRuleContext.prototype);
Preprocessor_itemContext.prototype.constructor = Preprocessor_itemContext;

Preprocessor_itemContext.prototype.CONDITIONAL_SYMBOL = function() {
    return this.getToken(TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL, 0);
};

Preprocessor_itemContext.prototype.DECIMAL_LITERAL = function() {
    return this.getToken(TibboBasicPreprocessorParser.DECIMAL_LITERAL, 0);
};

Preprocessor_itemContext.prototype.DIRECTIVE_STRING = function() {
    return this.getToken(TibboBasicPreprocessorParser.DIRECTIVE_STRING, 0);
};

Preprocessor_itemContext.prototype.enterRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.enterPreprocessor_item(this);
	}
};

Preprocessor_itemContext.prototype.exitRule = function(listener) {
    if(listener instanceof TibboBasicPreprocessorParserListener ) {
        listener.exitPreprocessor_item(this);
	}
};

Preprocessor_itemContext.prototype.accept = function(visitor) {
    if ( visitor instanceof TibboBasicPreprocessorParserVisitor ) {
        return visitor.visitPreprocessor_item(this);
    } else {
        return visitor.visitChildren(this);
    }
};




TibboBasicPreprocessorParser.Preprocessor_itemContext = Preprocessor_itemContext;

TibboBasicPreprocessorParser.prototype.preprocessor_item = function() {

    var localctx = new Preprocessor_itemContext(this, this._ctx, this.state);
    this.enterRule(localctx, 16, TibboBasicPreprocessorParser.RULE_preprocessor_item);
    var _la = 0; // Token type
    try {
        this.enterOuterAlt(localctx, 1);
        this.state = 120;
        _la = this._input.LA(1);
        if(!(((((_la - 30)) & ~0x1f) == 0 && ((1 << (_la - 30)) & ((1 << (TibboBasicPreprocessorParser.DIRECTIVE_STRING - 30)) | (1 << (TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL - 30)) | (1 << (TibboBasicPreprocessorParser.DECIMAL_LITERAL - 30)))) !== 0))) {
        this._errHandler.recoverInline(this);
        }
        else {
        	this._errHandler.reportMatch(this);
            this.consume();
        }
    } catch (re) {
    	if(re instanceof antlr4.error.RecognitionException) {
	        localctx.exception = re;
	        this._errHandler.reportError(this, re);
	        this._errHandler.recover(this, re);
	    } else {
	    	throw re;
	    }
    } finally {
        this.exitRule();
    }
    return localctx;
};


TibboBasicPreprocessorParser.prototype.sempred = function(localctx, ruleIndex, predIndex) {
	switch(ruleIndex) {
	case 7:
			return this.preprocessor_expression_sempred(localctx, predIndex);
    default:
        throw "No predicate with index:" + ruleIndex;
   }
};

TibboBasicPreprocessorParser.prototype.preprocessor_expression_sempred = function(localctx, predIndex) {
	switch(predIndex) {
		case 0:
			return this.precpred(this._ctx, 3);
		case 1:
			return this.precpred(this._ctx, 2);
		default:
			throw "No predicate with index:" + predIndex;
	}
};


exports.TibboBasicPreprocessorParser = TibboBasicPreprocessorParser;
