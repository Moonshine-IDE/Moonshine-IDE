lexer grammar TibboBasicPreprocessorLexer;

channels { COMMENTS_CHANNEL }
WS
    : [ \t]+ -> channel(HIDDEN)
    ;

INCLUDE:                  [ \t]* I N C L U D E [ \t]+                           -> mode(DIRECTIVE_INCLUDE_TEXT);
INCLUDEPP:                [ \t]* I N C L U D E P P [ \t]+                     -> mode(DIRECTIVE_INCLUDE_TEXT);
SHARP:                    [ \t]* '#'                                        -> mode(DIRECTIVE_MODE);
COMMENT:                  '\'' ~[\r\n]*                              -> type(CODE);
STRING:                   StringFragment                             -> type(CODE);
CODE:                     ~[\r\n#'"]+;
NEW_LINE:                   '\r'? '\n'                               ;

mode DIRECTIVE_MODE;
PRAGMA:  P R A G M A -> mode(DIRECTIVE_TEXT);
DEFINE:  D E F I N E [ \t]+ -> mode(DIRECTIVE_DEFINE);
DEFINED: D E F I N E D;
IF:      I F;
ELIF:    E L I F;
ELSE:    E L S E;
UNDEF:   U N D E F;
IFDEF:   I F D E F;
IFNDEF:  I F N D E F;
ENDIF:   E N D I F;
ERROR:   E R R O R -> mode(DIRECTIVE_TEXT);
BANG:             '!' ;
LPAREN:           '(' ;
RPAREN:           ')' ;
EQUAL:            '=';
NOTEQUAL:         '<>';
AND:              A N D;
OR:               O R;
LT:               '<' ;
GT:               '>' ;
LE:               '<=';
GE:               '>=';
DIRECTIVE_WHITESPACES:      [ \t]+                           -> channel(HIDDEN);
DIRECTIVE_STRING:           StringFragment;
CONDITIONAL_SYMBOL:         LETTER (LETTER | [0-9_])*;
DECIMAL_LITERAL:            [0-9]+;
FLOAT:                      ([0-9]+ '.' [0-9]* | '.' [0-9]+);
DIRECTIVE_NEW_LINE:              '\r'? '\n'                       -> type(NEW_LINE), mode(DEFAULT_MODE);
DIRECTIVE_COMMENT:                  '\'' ~[\r\n]*                              -> type(CODE), mode(DEFAULT_MODE);

mode DIRECTIVE_DEFINE;

DIRECTIVE_DEFINE_CONDITIONAL_SYMBOL: LETTER (LETTER | [0-9])* ('(' (LETTER | [0-9,. \t])* ')')? -> type(CONDITIONAL_SYMBOL), mode(DIRECTIVE_TEXT);

mode DIRECTIVE_TEXT;

TEXT_NEW_LINE:                   '\r'? '\n'       -> type(NEW_LINE), mode(DEFAULT_MODE);
TEXT:                            ~[\r\n\\]+;

mode DIRECTIVE_INCLUDE_TEXT;
INCLUDE_DIRECITVE_TEXT_NEW_LINE:         '\\' '\r'? '\n'  -> channel(HIDDEN);
INCLUDE_TEXT_NEW_LINE:                   '\r'? '\n'       -> type(NEW_LINE), mode(DEFAULT_MODE);
INCLUDE_FILE:                            ["`] (~["\r\n] | '""')* ["`] ->  mode(DEFAULT_MODE);


fragment
EscapeSequence
    : '\\' ('b'|'t'|'n'|'f'|'r'|'"'|'\''|'\\')
    | OctalEscape
    | UnicodeEscape
    ;

fragment
OctalEscape
    :   '\\' [0-3] [0-7] [0-7]
    |   '\\' [0-7] [0-7]
    |   '\\' [0-7]
    ;

fragment
UnicodeEscape
    :   '\\' 'u' HexDigit HexDigit HexDigit HexDigit
    ;

fragment HexDigit:          [0-9a-fA-F];

fragment
StringFragment: '"' (~('\\' | '"') | '\\' .)* '"';

fragment LETTER
    : [$A-Za-z_]
    | ~[\u0000-\u00FF\uD800-\uDBFF]
    | [\uD800-\uDBFF] [\uDC00-\uDFFF]
    | [\u00E9]
    ;

fragment A: [aA];
fragment B: [bB];
fragment C: [cC];
fragment D: [dD];
fragment E: [eE];
fragment F: [fF];
fragment G: [gG];
fragment H: [hH];
fragment I: [iI];
fragment J: [jJ];
fragment K: [kK];
fragment L: [lL];
fragment M: [mM];
fragment N: [nN];
fragment O: [oO];
fragment P: [pP];
fragment Q: [qQ];
fragment R: [rR];
fragment S: [sS];
fragment T: [tT];
fragment U: [uU];
fragment V: [vV];
fragment W: [wW];
fragment X: [xX];
fragment Y: [yY];
fragment Z: [zZ];
