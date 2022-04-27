parser grammar TibboBasicParser;


options { tokenVocab=TibboBasicLexer; }

//parser rules

startRule
    : (topLevelDeclaration)* EOF
    ;

topLevelDeclaration
    : includeStmt
    | includeppStmt
    | enumerationStmt
    | constStmt
    | declareSubStmt
    | declareFuncStmt
    | declareVariableStmt
    | variableStmt
    | subStmt
    | functionStmt
    | objectDeclaration
    | propertyDefineStmt
    | eventDeclaration
    | syscallDeclaration
    | typeStmt
    ;

includeStmt
    : INCLUDE STRINGLITERAL
    ;

includeppStmt
    : INCLUDEPP STRINGLITERAL
    ;

// block ----------------------------------

block
    : (lineLabel? statement)*
    ;

statement
    : lineLabel
    | constStmt
    | doLoopStmt
    | forNextStmt
    | jumpStmt
    | ifThenElseStmt
    | selectCaseStmt
    | variableStmt
    | whileWendStmt
    | expression
    ;

// statements ----------------------------------



constStmt
    : CONST constSubStmt (COMMA constSubStmt)*
    ;

constSubStmt : name=IDENTIFIER (asTypeClause)? EQ value=expression;

declareVariableStmt : visibility? DECLARE variableListStmt;

declareSubStmt : DECLARE SUB (IDENTIFIER DOT)? name=IDENTIFIER paramList?;

declareFuncStmt : DECLARE FUNCTION (IDENTIFIER DOT)? name=IDENTIFIER paramList? returnType=asTypeClause;

doLoopStmt
    : DO block LOOP
	| DO (WHILE | UNTIL) condition=expression block LOOP
	| DO block LOOP (WHILE | UNTIL) condition=expression
;

enumerationStmt:
	ENUM IDENTIFIER
	enumerationStmt_Constant*
	END_ENUM
;

enumerationStmt_Constant : IDENTIFIER (EQ expression)? COMMA?;

exitStmt : EXIT_DO | EXIT_FOR | EXIT_FUNCTION | EXIT_PROPERTY | EXIT_SUB | EXIT_WHILE;

forNextStmt :
	FOR expression TO expression (STEP step=expression)?
	block
	NEXT expression?
;

functionStmt :
	visibility? FUNCTION (IDENTIFIER DOT)? name=IDENTIFIER paramList? returnType=asTypeClause
	block
	END_FUNCTION
;

jumpStmt
    : goToStmt
    | exitStmt
    ;

goToStmt : GOTO IDENTIFIER;

ifThenElseStmt
    : IF expression THEN (statement | jumpStmt) (ELSE (statement | jumpStmt))? NEWLINE # inlineIfThenElse
    | IF expression THEN NEWLINE+ block (ELSEIF ifConditionStmt THEN block)* (ELSE block)? END_IF # blockIfThenElse
    ;

ifConditionStmt : expression;

propertyDefineStmt:
    PROPERTY BANG? object=IDENTIFIER DOT property=IDENTIFIER

        propertyDefineStmt_InStmt*
    END_PROPERTY;


propertyDefineStmt_InStmt
	: propertyGetStmt
	| propertySetStmt;

propertyGetStmt: GET EQ SYSCALL LPAREN (INTEGERLITERAL (COMMA (STRINGLITERAL|IDENTIFIER) PLUS?)? )? RPAREN asTypeClause;

propertySetStmt: SET EQ SYSCALL LPAREN (INTEGERLITERAL (COMMA (STRINGLITERAL|IDENTIFIER) PLUS?)? )? RPAREN paramList;


//macroDefineStmt : MACRO_DEFINE ambiguousIdentifier ((ambiguousIdentifier | ambiguousKeyword | STRINGLITERAL | HEXLITERAL | INTEGERLITERAL | SHORTLITERAL))? endOfStatement;

//macroIfThenElseStmt
//    : macroIfBlockStmt macroElseIfBlockStmt* macroElseBlockStmt? MACRO_END_IF endOfStatement;

eventDeclaration
    : EVENT LPAREN number=INTEGERLITERAL RPAREN name=IDENTIFIER params=paramList?
    ;

syscallDeclaration
    : SYSCALL LPAREN (INTEGERLITERAL (COMMA (STRINGLITERAL|IDENTIFIER) PLUS?)? )? RPAREN (syscallDeclarationInner | syscallInternalDeclarationInner)
    ;

syscallDeclarationInner
    : (object=IDENTIFIER DOT)? property=IDENTIFIER paramList? asTypeClause?
    ;

syscallInternalDeclarationInner
    : BANG (object=IDENTIFIER DOT)? property=IDENTIFIER syscallInternalParamList? asTypeClause?
    ;

syscallInternalParamList
     : LPAREN (paramInternal (COMMA paramInternal)*)? RPAREN
     ;

paramInternal : (BYVAL | BYREF)? IDENTIFIER asTypeClause?;

selectCaseStmt :
	SELECT CASE expression COLON?
	sC_Case*
	sC_Default?
	END_SELECT
;

sC_Case :
	CASE sC_Cond (COMMA sC_Cond )* COLON?
	block
;

sC_Default :
    CASE_ELSE COLON? block
;

// ELSE first, so that it is not interpreted as a variable call
sC_Cond :
    expression
;

subStmt :
	visibility? SUB (IDENTIFIER DOT)? name=IDENTIFIER paramList?
	block
	END_SUB
;
typeStmt: visibility? TYPE name=IDENTIFIER
		typeStmtElement*
	END_TYPE;

typeStmtElement:
	IDENTIFIER (LPAREN literal RPAREN)? valueType=asTypeClause ;

// operator precedence is represented by rule order

//assignment: IDENTIFIER EQ expression;

//expression
//    : ('-' | NOT) expression
//    | expression op=(MULT | DIV | MOD) expression
//    | expression op=(PLUS | MINUS) expression
//    | expression op=(LEQ | GEQ | LT | GT) expression
//    | expression op=(NEQ | EQ) expression
//    | expression op=(SHL | SHR | NOT | AND | XOR | OR) expression
//    | literal
//    | literal argList
//    | LPAREN expression RPAREN
//    ;


expression
    : unaryExpression
    | expression op=(MULT | DIV | MOD) expression
    | expression op=(PLUS | MINUS) expression
    | expression op=(LEQ | GEQ | LT | GT) expression
    | expression op=(NEQ | EQ) expression
    | expression op=(SHL | SHR | NOT | AND | XOR | OR) expression
    | LPAREN expression RPAREN
    ;

unaryExpression
    : postfixExpression
    | unaryOperator primaryExpression
    ;

unaryOperator
    : '-'
    | NOT
    ;

postfixExpression
    : primaryExpression postfix*
    | postfixExpression DOT property=IDENTIFIER postfix*  // TODO: get rid of property and postfix expression.
    ;

postfix
    : argList
    ;

primaryExpression
    : literal
    | LPAREN expression RPAREN
    ;


variableStmt : visibility? DIM variableListStmt;

variableListStmt : variableListItem (COMMA variableListItem?)* variableType=asTypeClause (EQ (expression | arrayLiteral))?;

variableListItem: IDENTIFIER (LPAREN literal RPAREN)? ;

//variableSubStmt : ambiguousIdentifier (LPAREN ambiguousIdentifier RPAREN)? (asTypeClause)? (WS? EQ WS? expression)?;

whileWendStmt :
	WHILE expression 
	block
	WEND
;

objectDeclaration:
OBJECT IDENTIFIER
;

// atomic rules for statements

argList
    : LPAREN (arg (COMMA arg)*)? RPAREN
    ;

arg
    : expression
    ;

paramList
    : LPAREN (param (COMMA param)*)? RPAREN
    ;

param : (BYVAL | BYREF)? name=IDENTIFIER (LPAREN INTEGERLITERAL RPAREN)? valueType=asTypeClause? ;

// atomic rules ----------------------------------
asTypeClause : AS ENUM? valueType=type (fieldLength)?;

baseType : CHAR | SHORT | WORD | DWORD | FLOAT | REAL | BOOLEAN | BYTE | INTEGER | LONG | STRING (WS? MULT WS? expression)?;

complexType : IDENTIFIER ((DOT | BANG) IDENTIFIER)*;

fieldLength : MULT (INTEGERLITERAL | IDENTIFIER);

lineLabel : IDENTIFIER COLON;

literal
    : HEXLITERAL
    | BINLITERAL
    | ('+' | '-')? ( INTEGERLITERAL+ '.' )? INTEGERLITERAL
    | STRINGLITERAL
    | TemplateStringLiteral
    | TRUE
    | FALSE
    | IDENTIFIER ;

arrayLiteral
    : L_CURLY_BRACKET (literal | arrayLiteral) (COMMA (literal | arrayLiteral))* COMMA? R_CURLY_BRACKET
    ;

type : (baseType | complexType) (LPAREN (IDENTIFIER | INTEGERLITERAL) RPAREN)?;

//typeHint : '&' | '%' | '#' | '!' | '@' | '$';

visibility
    : PUBLIC
    ;


