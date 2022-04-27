parser grammar TibboBasicPreprocessorParser;

options { tokenVocab=TibboBasicPreprocessorLexer; }

preprocessor
    : line* (NEW_LINE* | EOF)
    ;

line
    : NEW_LINE* text
    ;

text
    : include_file
    | directive
    | codeLine
    ;

codeLine
    : CODE
    ;

directive
    : SHARP IF preprocessor_expression                      #preprocessorConditional
    | SHARP ELIF preprocessor_expression                    #preprocessorConditional
    | SHARP ELSE                                            #preprocessorConditional
    | SHARP ENDIF                                           #preprocessorEndConditional
    | SHARP IFDEF CONDITIONAL_SYMBOL                        #preprocessorDef
    | SHARP IFNDEF CONDITIONAL_SYMBOL                       #preprocessorDef
    | SHARP UNDEF CONDITIONAL_SYMBOL                        #preprocessorUndef
    | SHARP PRAGMA directive_text                           #preprocessorPragma
    | SHARP ERROR directive_text                            #preprocessorError
    | SHARP DEFINE CONDITIONAL_SYMBOL directive_text?       #preprocessorDefine
    ;

include_file
    : (INCLUDE | INCLUDEPP) INCLUDE_FILE                          #preprocessorInclude
    ;

directive_text
    : TEXT+
    ;

preprocessor_expression
    : DECIMAL_LITERAL                                                        #preprocessorConstant
    | DIRECTIVE_STRING                                                       #preprocessorConstant
    | CONDITIONAL_SYMBOL (LPAREN preprocessor_expression RPAREN)?            #preprocessorConditionalSymbol
//    | LPAREN preprocessor_expression RPAREN                                  #preprocessorParenthesis
//    | BANG preprocessor_expression                                           #preprocessorNot
    | preprocessor_item op=(EQUAL | NOTEQUAL) preprocessor_item            #preprocessorBinary
    | preprocessor_expression op=AND preprocessor_expression                 #preprocessorBinary
    | preprocessor_expression op=OR preprocessor_expression                  #preprocessorBinary
    | preprocessor_item op=(LT | GT | LE | GE) preprocessor_item           #preprocessorBinary
//    | DEFINED (CONDITIONAL_SYMBOL | LPAREN CONDITIONAL_SYMBOL RPAREN)         #preprocessorDefined
    ;

preprocessor_item: CONDITIONAL_SYMBOL | DECIMAL_LITERAL | DIRECTIVE_STRING ;