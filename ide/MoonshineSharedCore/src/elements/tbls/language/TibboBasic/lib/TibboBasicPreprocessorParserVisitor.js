// Generated from /Users/jimmyhu/Projects/TIDEDesktopService/language/TibboBasic/TibboBasicPreprocessorParser.g4 by ANTLR 4.8
// jshint ignore: start
var antlr4 = require('antlr4/index');

// This class defines a complete generic visitor for a parse tree produced by TibboBasicPreprocessorParser.

function TibboBasicPreprocessorParserVisitor() {
	antlr4.tree.ParseTreeVisitor.call(this);
	return this;
}

TibboBasicPreprocessorParserVisitor.prototype = Object.create(antlr4.tree.ParseTreeVisitor.prototype);
TibboBasicPreprocessorParserVisitor.prototype.constructor = TibboBasicPreprocessorParserVisitor;

// Visit a parse tree produced by TibboBasicPreprocessorParser#preprocessor.
TibboBasicPreprocessorParserVisitor.prototype.visitPreprocessor = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicPreprocessorParser#line.
TibboBasicPreprocessorParserVisitor.prototype.visitLine = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicPreprocessorParser#text.
TibboBasicPreprocessorParserVisitor.prototype.visitText = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicPreprocessorParser#codeLine.
TibboBasicPreprocessorParserVisitor.prototype.visitCodeLine = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicPreprocessorParser#preprocessorConditional.
TibboBasicPreprocessorParserVisitor.prototype.visitPreprocessorConditional = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicPreprocessorParser#preprocessorEndConditional.
TibboBasicPreprocessorParserVisitor.prototype.visitPreprocessorEndConditional = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicPreprocessorParser#preprocessorDef.
TibboBasicPreprocessorParserVisitor.prototype.visitPreprocessorDef = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicPreprocessorParser#preprocessorUndef.
TibboBasicPreprocessorParserVisitor.prototype.visitPreprocessorUndef = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicPreprocessorParser#preprocessorPragma.
TibboBasicPreprocessorParserVisitor.prototype.visitPreprocessorPragma = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicPreprocessorParser#preprocessorError.
TibboBasicPreprocessorParserVisitor.prototype.visitPreprocessorError = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicPreprocessorParser#preprocessorDefine.
TibboBasicPreprocessorParserVisitor.prototype.visitPreprocessorDefine = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicPreprocessorParser#preprocessorInclude.
TibboBasicPreprocessorParserVisitor.prototype.visitPreprocessorInclude = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicPreprocessorParser#directive_text.
TibboBasicPreprocessorParserVisitor.prototype.visitDirective_text = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicPreprocessorParser#preprocessorBinary.
TibboBasicPreprocessorParserVisitor.prototype.visitPreprocessorBinary = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicPreprocessorParser#preprocessorConstant.
TibboBasicPreprocessorParserVisitor.prototype.visitPreprocessorConstant = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicPreprocessorParser#preprocessorConditionalSymbol.
TibboBasicPreprocessorParserVisitor.prototype.visitPreprocessorConditionalSymbol = function(ctx) {
  return this.visitChildren(ctx);
};


// Visit a parse tree produced by TibboBasicPreprocessorParser#preprocessor_item.
TibboBasicPreprocessorParserVisitor.prototype.visitPreprocessor_item = function(ctx) {
  return this.visitChildren(ctx);
};



exports.TibboBasicPreprocessorParserVisitor = TibboBasicPreprocessorParserVisitor;