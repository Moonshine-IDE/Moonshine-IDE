lexer grammar TibboBasicLexer;

channels { COMMENTS_CHANNEL, DIRECTIVE_CHANNEL }

//objects
OBJECT: O B J E C T;


//keywords
AND: A N D;
AS: A S;
BOOLEAN: B O O L E A N;
REAL: R E A L;
BYREF: B Y R E F;
BYTE: B Y T E;
BYVAL: B Y V A L;
CASE: C A S E;
CASE_ELSE: C A S E WS E L S E;
CHAR: C H A R;
CONST: C O N S T;
COUNTOF: C O U N T O F;
DECLARE: D E C L A R E;
DIM: D I M;
DO: D O;
DWORD: D W O R D;
ELSE: E L S E;
ELIF: E L I F;
END: E N D;
ELSEIF : E L S E WS I F;
ENUM: E N U M;
END_ENUM : E N D WS E N U M;
END_FUNCTION : E N D WS F U N C T I O N;
END_IF : E N D WS I F;
END_PROPERTY : E N D WS P R O P E R T Y;
END_SELECT : E N D WS S E L E C T;
END_SUB : E N D WS S U B;
END_TYPE: E N D WS T Y P E;
END_WITH : E N D WS W I T H;
EVENT: E V E N T;
EXIT_DO : E X I T WS D O;
EXIT_FOR : E X I T WS F O R;
EXIT_FUNCTION : E X I T WS F U N C T I O N;
EXIT_PROPERTY : E X I T WS P R O P E R T Y;
EXIT_SUB : E X I T WS S U B;
EXIT_WHILE : E X I T WS W H I L E;
FALSE: F A L S E;
FLOAT: F L O A T;
FOR: F O R;
FUNCTION: F U N C T I O N;
GET: G E T;
GOTO: G O T O;
IF: I F -> mode(INLINE_MODE);
IFDEF: I F D E F;
IFNDEF: I F N D E F;
INCLUDE: I N C L U D E;
INCLUDEPP: I N C L U D E P P;
INTEGER: I N T E G E R;
LONG: L O N G;
LOOP: L O O P;
MOD: M O D;
NEXT: N E X T;
NOT: N O T;
OR: O R;
PROPERTY: P R O P E R T Y;
PUBLIC: P U B L I C;
SELECT: S E L E C T;
SET: S E T;
SHL: S H L;
SHORT: S H O R T;
SHR: S H R;
SIZEOF: S I Z E O F;
STEP: S T E P;
STRING: S T R I N G;
SUB: S U B;
THEN: T H E N;
TO: T O;
TRUE: T R U E;
TYPE: T Y P E;
UNDEF: U N D E F;
UNTIL: U N T I L;
WEND: W E N D;
WHILE: W H I L E;
WORD: W O R D;
XOR: X O R;

// preprocessor

SHARP:                    '#'             -> channel(DIRECTIVE_CHANNEL), mode(DIRECTIVE_MODE);

// literals
STRINGLITERAL : ["`] (~["\r\n] | '""')* ["`];
TemplateStringLiteral:          '`' ('\\`' | ~'`')* '`';
HEXLITERAL : '&' H [0-9A-Fa-f]+;
BINLITERAL : '&' B [0-9A-F]+;
INTEGERLITERAL : DIGIT+;


// symbols
DIV: '\\' | '/';
EQ: '=';
GEQ: '>=';
GT: '>';
LEQ: '<=';
LPAREN: '(';
LT: '<';
MINUS: '-';
MULT: '*';
NEQ: '<>';
PLUS: '+';
RPAREN: ')';
L_SQUARE_BRACKET: '[';
R_SQUARE_BRACKET: ']';
L_CURLY_BRACKET: '{';
R_CURLY_BRACKET: '}';

//NEWLINE: [\r\n\u2028\u2029]+ -> channel(HIDDEN);
NEWLINE
   : ('\r'? '\n') -> skip
   ;
COMMENT
//: SINGLEQUOTE (LINE_CONTINUATION | ~[\r\n\u2028\u2029])*;
    : SINGLEQUOTE ~[\r\n]* -> channel(COMMENTS_CHANNEL)
    ;
SINGLEQUOTE: '\'';
COLON: ':';
SEMICOLON: ';';
COMMA: ',';
DOT: '.';
BANG: '!';
UNDERSCORE: '_';
SYSCALL: S Y S C A L L;
WS
    : [ \t]+ -> channel(HIDDEN)
    ;


// identifier
IDENTIFIER :  LETTER LETTERORDIGIT*;
// letters
fragment LETTER
    : [a-zA-Z_]
    ;
fragment DIGIT
    : [0-9]
    ;
fragment LETTERORDIGIT
    : [a-zA-Z0-9_]
    ;

// case insensitive chars
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

mode DIRECTIVE_MODE;

DIRECTIVE_INCLUDE:             INCLUDE [ \t]+ -> channel(DIRECTIVE_CHANNEL), mode(DIRECTIVE_TEXT_MODE);
DIRECTIVE_INCLUDEPP:             INCLUDEPP [ \t]+ -> channel(DIRECTIVE_CHANNEL), mode(DIRECTIVE_TEXT_MODE);

DIRECTIVE_DEFINE:              D E F I N E [ \t]+   -> channel(DIRECTIVE_CHANNEL), mode(DEFINE);
DIRECTIVE_IF:                  I F                  -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_ELIF:                E L I F              -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_ELSE:                E L S E              -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_UNDEF:               U N D E F            -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_IFDEF:               I F D E F            -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_IFNDEF:              I F N D E F          -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_ENDIF:               E N D WS I F         -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_ERROR:               E R R O R            -> channel(DIRECTIVE_CHANNEL), mode(DIRECTIVE_TEXT_MODE);

DIRECTIVE_BANG:                '!'              -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_LP:                  '('              -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_RP:                  ')'              -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_EQUAL:               '='             -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_NOTEQUAL:            '<>'             -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_AND:                 AND             -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_OR:                  OR             -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_LT:                  '<'              -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_GT:                  '>'              -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_LE:                  '<='             -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_GE:                  '>='             -> channel(DIRECTIVE_CHANNEL);

DIRECTIVE_WS:                  [ \t]+                           -> channel(HIDDEN), type(WS);
DIRECTIVE_ID:                  LETTER LETTERORDIGIT*            -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_DECIMAL_LITERAL:     DIGIT+                           -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_FLOAT:               (DIGIT+ '.' DIGIT* | '.' DIGIT+) -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_NEWLINE:             '\r'? '\n'                       -> channel(HIDDEN), mode(DEFAULT_MODE);
DIRECTIVE_SINGLE_COMMENT:      '\'' ~[\r\n]*                    -> channel(COMMENTS_CHANNEL);
DIRECTIVE_BACKSLASH_NEWLINE:   '\\' '\r'? '\n'                  -> skip;

mode DEFINE;

DIRECTIVE_DEFINE_ID: LETTER LETTERORDIGIT* ('(' (LETTERORDIGIT | [,. \t])* ')')? -> channel(DIRECTIVE_CHANNEL), type(DIRECTIVE_ID), mode(DIRECTIVE_TEXT_MODE);

mode DIRECTIVE_TEXT_MODE;

DIRECTIVE_TEXT_NEWLINE:           '\\' '\r'? '\n'  -> channel(DIRECTIVE_CHANNEL);
DIRECTIVE_BACKSLASH_ESCAPE:       '\\' .           -> channel(DIRECTIVE_CHANNEL), type(DIRECTIVE_TEXT);
DIRECTIVE_TEXT_BACKSLASH_NEWLINE: '\r'? '\n'       -> channel(HIDDEN), mode(DEFAULT_MODE);
DIRECTIVE_TEXT_MULTI_COMMENT:     '/*' .*? '*/'    -> channel(COMMENTS_CHANNEL);
DIRECTIVE_TEXT_SINGLE_COMMENT:    '//' ~[\r\n]*    -> channel(COMMENTS_CHANNEL);
DIRECTIVE_SLASH:                  '/'              -> channel(DIRECTIVE_CHANNEL), type(DIRECTIVE_TEXT);
DIRECTIVE_TEXT:                   ~[\r\n\\/]+      -> channel(DIRECTIVE_CHANNEL);

mode INLINE_MODE;

//keywords
AND2: A N D -> type(AND);
ELSE2: E L S E -> type(ELSE);
END2: E N D -> type(END);
EXIT_DO2 : E X I T WS D O -> type(EXIT_DO);
EXIT_FOR2 : E X I T WS F O R -> type(EXIT_FOR);
EXIT_FUNCTION2 : E X I T WS F U N C T I O N -> type(EXIT_FUNCTION);
EXIT_SUB2 : E X I T WS S U B -> type(EXIT_SUB);
EXIT_WHILE2 : E X I T WS W H I L E -> type(EXIT_WHILE);
FALSE2: F A L S E -> type(FALSE);
GOTO2: G O T O -> type(GOTO);
MOD2: M O D -> type(MOD);
NOT2: N O T -> type(NOT);
OR2: O R -> type(OR);
SHL2: S H L -> type(SHL);
SHR2: S H R -> type(SHR);
SIZEOF2: S I Z E O F -> type(SIZEOF);
THEN2: T H E N -> type(THEN);
TRUE2: T R U E -> type(TRUE);
XOR2: X O R -> type(XOR);

// literals
STRINGLITERAL2 : ["`] (~["\r\n] | '""')* ["`] -> type(STRINGLITERAL);
HEXLITERAL2 : '&' H [0-9A-Fa-f]+ -> type(HEXLITERAL);
BINLITERAL2 : '&' B [0-9A-F]+ -> type(BINLITERAL);
INTEGERLITERAL2 : DIGIT+ -> type(INTEGERLITERAL);


// symbols
DIV2: ('\\' | '/') -> type(DIV);
EQ2: '=' -> type(EQ);
GEQ2: '>=' -> type(GEQ);
GT2: '>' -> type(GT);
LEQ2: '<=' -> type(LEQ);
LPAREN2: '(' -> type(LPAREN);
LT2: '<' -> type(LT);
MINUS2: '-' -> type(MINUS);
MULT2: '*' -> type(MULT);
NEQ2: '<>' -> type(NEQ);
PLUS2: '+' -> type(PLUS);
RPAREN2: ')' -> type(RPAREN);

//NEWLINE: [\r\n\u2028\u2029]+ -> channel(HIDDEN);
NEWLINE2
   : ('\r'? '\n') -> mode(DEFAULT_MODE), type(NEWLINE)
   ;
COMMENT2
//: SINGLEQUOTE (LINE_CONTINUATION | ~[\r\n\u2028\u2029])*;
    : SINGLEQUOTE2 ~[\r\n]* -> channel(COMMENTS_CHANNEL)
    ;
SINGLEQUOTE2: '\'' -> type(SINGLEQUOTE);
COLON2: ':' -> type(COLON);
COMMA2: ',' -> type(COMMA);
DOT2: '.' -> type(DOT);
BANG2: '!' -> type(BANG);
UNDERSCORE2: '_' -> type(UNDERSCORE);
WS2
    : [ \t]+ -> channel(HIDDEN)
    ;


// identifier
IDENTIFIER2 :  LETTER LETTERORDIGIT* -> type(IDENTIFIER);

ANY: . ;