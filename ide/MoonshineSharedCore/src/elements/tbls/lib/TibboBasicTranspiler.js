"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TibboBasicTranspiler = void 0;
// import path = require('path');
// import ini = require('ini');
const TibboBasicErrorListener_1 = require("./TibboBasicErrorListener");
const path = require("path");
const md5 = require('md5');
const antlr4 = require('antlr4');
const TibboBasicLexer = require('../language/TibboBasic/lib/TibboBasicLexer').TibboBasicLexer;
const TibboBasicParser = require('../language/TibboBasic/lib/TibboBasicParser').TibboBasicParser;
const TibboBasicParserListener = require('../language/TibboBasic/lib/TibboBasicParserListener').TibboBasicParserListener;
const syscalls = require('../language/TibboBasic/syscalls.json');
class TibboBasicTranspiler {
    constructor() {
        this.output = '';
        this.lines = [];
        this.currentLine = '';
        this.objects = {};
        this.functions = {};
        this.variables = {};
        this.lineMappings = [];
    }
    parseFile(contents) {
        this.output = '';
        this.lines = [];
        this.lines = contents.split('\n');
        const reg = /\S/;
        this.lineMappings = [];
        for (let i = 0; i < this.lines.length; i++) {
            this.lineMappings.push(i);
            const match = reg.exec(this.lines[i]);
            let index = 0;
            if (match) {
                index = match.index;
                if (match[0] === '#') {
                    continue;
                }
            }
            this.lines[i] = this.lines[i].substr(0, index);
        }
        const chars = new antlr4.InputStream(contents);
        const lexer = new TibboBasicLexer(chars);
        const tokens = new antlr4.CommonTokenStream(lexer);
        const parser = new TibboBasicParser(tokens);
        parser.buildParseTrees = true;
        const errorListener = new TibboBasicErrorListener_1.TibboBasicErrorListener();
        lexer.removeErrorListeners();
        // lexer.addErrorListener(errorListener);
        parser.removeErrorListeners();
        parser.addErrorListener(errorListener);
        const tree = parser.startRule();
        const listener = new ParserListener(this);
        antlr4.tree.ParseTreeWalker.DEFAULT.walk(listener, tree);
        for (let i = 0; i < tokens.tokens.length; i++) {
            const token = tokens.tokens[i];
            if (token.channel == TibboBasicLexer.COMMENTS_CHANNEL) {
                // add comment to line
                const comment = token.text.substr(1);
                const line = token.line - 1;
                if (this.lines[line].indexOf("'") >= 0) {
                    // const res = this.lines[line].search(/\S|$/);
                    const res = this.lines[line].indexOf("'");
                    this.lines[line] = this.lines[line].substr(0, res) + '//' + comment;
                }
                else {
                    this.lines[line] += '//' + comment;
                }
            }
        }
        for (let i = 0; i < this.lines.length; i++) {
            if (this.lines[i].trim().indexOf('#') == 0) {
                const content = this.replaceDirective(this.lines[i]);
                this.lines[i] = content;
            }
        }
        for (let i = 0; i < listener.variables.length; i++) {
            if (listener.variables[i].parentScope === undefined) {
                this.variables[listener.variables[i].name] = listener.variables[i];
            }
        }
        this.output = this.lines.join('\r\n');
        return this.output;
    }
    replaceDirective(content) {
        let index = 0;
        while (index < content.length) {
            if (content.substr(index, 1) == '=') {
                content = content.substr(0, index) + ' == ' + content.substr(index + 1);
                index += 3;
            }
            else if (content.substr(index, 2) == '<>') {
                content = content.substr(0, index) + ' != ' + content.substr(index + 2);
                index += 3;
            }
            else if (content.substr(index, 4).toLowerCase() == ' or ') {
                content = content.substr(0, index) + ' || ' + content.substr(index + 4);
                index += 3;
            }
            else if (content.substr(index, 5).toLowerCase() == ' and ') {
                content = content.substr(0, index) + ' && ' + content.substr(index + 5);
                index += 3;
            }
            index++;
        }
        content = content.replace('&h', '0x');
        return content;
    }
    addCode(code, line) {
        this.currentLine += code;
        this.lines[this.lineMappings[line - 1]] += code;
    }
    writeLine(line) {
        const lineContent = this.lines[line - 1];
        const res = lineContent.search(/\S|$/);
        const exp = /^\s*[a-zA-Z][a-zA-Z0-9_]+:\s*$/;
        // if (lineContent.match(exp) !== null && this.currentLine.match(exp) == null) {
        //     this.lines[line - 1] += this.currentLine;
        // }
        // else {
        //     this.lines[line - 1] = lineContent.substr(0, res) + this.currentLine;
        // }
        this.currentLine = '';
    }
    appendLine(code, line) {
        const res = this.lines[line - 1].search(/\S|$/);
        this.lines[line - 1] += '\r\n' + this.lines[line - 1].substr(0, res) + code;
    }
}
exports.TibboBasicTranspiler = TibboBasicTranspiler;
class ParserListener extends TibboBasicParserListener {
    constructor(transpiler) {
        super();
        this.scopeStack = [];
        this.currentParams = [];
        this.isDeclaration = false;
        this.currentFunction = undefined;
        this.variables = [];
        this.isGlobalVariable = false;
        this.transpiler = transpiler;
    }
    convertVariableType(variableType) {
        let valueType = variableType;
        switch (variableType) {
            case 'byte':
                valueType = 'unsigned char'; //U8
                break;
            case 'integer':
                valueType = 'int'; //S16
                break;
            case 'word':
                valueType = 'unsigned int'; //U16
                break;
            case 'dword':
                valueType = 'unsigned long'; //U32
                break;
            case 'real':
                valueType = 'float'; //float
                break;
            case 'boolean':
                valueType = 'bool'; //bool
                break;
            default:
                if (valueType.indexOf('string') == 0) {
                    valueType = 'string';
                    // valueType = valueType.replace('(', '<');
                    // valueType = valueType.replace(')', '>');
                }
                break;
        }
        return valueType;
    }
    findVariable(name) {
        if (this.transpiler.variables[name] !== undefined) {
            return this.transpiler.variables[name];
        }
        for (let i = 0; i < this.variables.length; i++) {
            if (this.variables[i].name == name) {
                return this.variables[i];
            }
        }
        return undefined;
    }
    enterDoLoopStmt(ctx) {
        this.transpiler.addCode(`do {`, ctx.start.line);
    }
    exitDoLoopStmt(ctx) {
        const condition = this.parseExpression(ctx.condition);
        this.transpiler.addCode(`} while (${condition});`, ctx.stop.line);
    }
    enterIncludeStmt(ctx) {
        let fileName = ctx.children[1].getText();
        const parts = fileName.split('.');
        parts[1] = 'h"';
        fileName = parts.join('.');
        fileName = fileName.replace(/\\/g, path.sep);
        this.transpiler.addCode(`#include ${fileName}`, ctx.start.line);
        this.transpiler.writeLine(ctx.start.line);
    }
    assignsByrefVariable(ctx, paramName, isAssignment = false) {
        if (!ctx.children) {
            return isAssignment;
        }
        for (let i = 0; i < ctx.children.length; i++) {
            const child = ctx.children[i];
            if (child.ruleIndex === TibboBasicParser.RULE_statment) {
                const code = ctx.getText();
                const equalsCount = (code.match(/=/g) || []).length;
                if (equalsCount == 1) {
                    const parts = code.split('=');
                    if (parts[0].trim() == paramName) {
                        return true;
                    }
                }
            }
            if (!isAssignment) {
                if (child.children) {
                    for (let j = 0; j < child.children.length; j++) {
                        const tmp = this.assignsByrefVariable(child.children[j], paramName, isAssignment);
                        if (tmp) {
                            return true;
                        }
                    }
                }
            }
        }
        return isAssignment;
    }
    enterSubStmt(ctx) {
        const name = ctx.name.text;
        const returnType = this.getReturnType(ctx);
        this.transpiler.addCode(`${returnType} ${ctx.name.text}`, ctx.start.line);
        this.isDeclaration = false;
        this.currentFunction = {
            name: name,
            dataType: '',
            parameters: [],
            variables: [],
        };
        if (this.transpiler.functions[name] === undefined) {
            this.transpiler.functions[name] = this.currentFunction;
        }
    }
    enterParamList(ctx) {
        this.currentParams = [];
        if (this.currentFunction !== undefined) {
            this.currentFunction.parameters = [];
        }
    }
    enterParam(ctx) {
        if (!ctx.valueType) {
            return;
        }
        let valueType = this.convertVariableType(ctx.valueType.valueType.getText());
        let paramName = ctx.name.text;
        const param = {
            name: paramName,
            dataType: valueType,
            byRef: false
        };
        if (ctx.children[0].symbol.type == TibboBasicLexer.BYREF) {
            paramName = '*' + paramName;
            param.byRef = true;
            if (this.currentFunction && valueType === 'string') {
                // this.currentFunction.dataType = `template<class T> ${this.currentFunction.dataType ? this.currentFunction.dataType : 'void'}`;
                valueType = 'const string&';
                paramName = ctx.name.text;
                const hasAssignment = this.assignsByrefVariable(ctx.parentCtx.parentCtx, paramName, false);
                if (hasAssignment) {
                    valueType = 'string&';
                }
            }
        }
        if (this.currentFunction !== undefined) {
            this.currentFunction.parameters.push(param);
        }
        this.currentParams.push(`${valueType} ${paramName}`);
    }
    exitParamList(ctx) {
        if (!this.isDeclaration) {
            this.transpiler.addCode(`(${this.currentParams.join(', ')}) {`, ctx.start.line);
            if (this.currentFunction && this.currentFunction.dataType !== '') {
                this.transpiler.addCode(`\n${this.currentFunction.dataType} ${this.currentFunction.name};`, ctx.start.line);
            }
        }
        else {
            this.transpiler.addCode(`(${this.currentParams.join(', ')});`, ctx.start.line);
        }
        this.transpiler.writeLine(ctx.start.line);
        // if (this.currentFunction && this.currentFunction.returnType !== '') {
        //     let index = ctx.start.line;
        //     if (this.transpiler.lines[index].trim().indexOf('\'') != 0) {
        //         this.transpiler.appendLine(`    ${this.currentFunction.returnType} ${this.currentFunction.name};`, index);
        //     }
        //     else {
        //         while (index != -1) {
        //             if (this.transpiler.lines[index].trim().indexOf('\'') != 0) {
        //                 this.transpiler.appendLine(`    ${this.currentFunction.returnType} ${this.currentFunction.name};`, index + 1);
        //                 index = -1;
        //             }
        //             else {
        //                 index++;
        //             }
        //         }
        //     }
        // }
    }
    exitSubStmt(ctx) {
        this.transpiler.addCode('}', ctx.stop.line);
        this.transpiler.writeLine(ctx.stop.line);
        this.isDeclaration = false;
        this.currentFunction = undefined;
    }
    getReturnType(ctx) {
        let returnType = 'void';
        if (ctx.returnType) {
            returnType = this.convertVariableType(ctx.returnType.valueType.getText());
        }
        for (let i = 0; i < ctx.children.length; i++) {
            const child = ctx.children[i];
            if (child.ruleIndex === TibboBasicParser.RULE_paramList) {
                for (let j = 0; j < child.children.length; j++) {
                    const param = child.children[j];
                    if (param.ruleIndex !== TibboBasicParser.RULE_param) {
                        continue;
                    }
                    // if (param.valueType && param.valueType.valueType.getText().indexOf('string') === 0
                    //     && param.children[0].symbol.type == TibboBasicLexer.BYREF) {
                    //     returnType = `template<class T> ${returnType}`;
                    //     break;
                    // }
                }
            }
        }
        return returnType;
    }
    enterFunctionStmt(ctx) {
        this.isDeclaration = false;
        const name = ctx.name.text;
        const varType = this.convertVariableType(ctx.returnType.valueType.getText());
        const returnType = this.getReturnType(ctx);
        this.transpiler.addCode(`${returnType} ${ctx.name.text}`, ctx.start.line);
        this.currentFunction = {
            name: name,
            dataType: varType,
            parameters: [],
            variables: [],
        };
        if (this.transpiler.functions[name] === undefined) {
            this.transpiler.functions[name] = this.currentFunction;
        }
    }
    exitFunctionStmt(ctx) {
        var _a;
        this.transpiler.addCode('}', ctx.stop.line);
        this.transpiler.writeLine(ctx.stop.line);
        this.transpiler.appendLine(`return ${(_a = this.currentFunction) === null || _a === void 0 ? void 0 : _a.name};`, ctx.stop.line - 1);
        this.isDeclaration = false;
        this.currentFunction = undefined;
    }
    enterDeclareSubStmt(ctx) {
        this.isDeclaration = true;
        const name = ctx.name.text;
        const returnType = this.getReturnType(ctx);
        this.transpiler.addCode(`${returnType} ${name}`, ctx.start.line);
        this.currentFunction = {
            name: name,
            dataType: '',
            parameters: [],
            variables: [],
        };
        if (this.transpiler.functions[name] === undefined) {
            this.transpiler.functions[name] = this.currentFunction;
        }
    }
    enterDeclareFuncStmt(ctx) {
        this.isDeclaration = true;
        const name = ctx.name.text;
        const returnType = this.getReturnType(ctx);
        this.transpiler.addCode(`${returnType} ${name}`, ctx.start.line);
        this.currentFunction = {
            name: name,
            dataType: returnType,
            parameters: [],
            variables: [],
        };
        if (this.transpiler.functions[name] === undefined) {
            this.transpiler.functions[name] = this.currentFunction;
        }
    }
    enterDeclareVariableStmt(ctx) {
        this.isGlobalVariable = true;
    }
    exitDeclareVariableStmt(ctx) {
        this.isGlobalVariable = false;
    }
    enterVariableListStmt(ctx) {
        const variables = [];
        let initCode = '';
        for (let i = 0; i < ctx.children.length; i++) {
            const item = ctx.children[i];
            if (item.ruleIndex == TibboBasicParser.RULE_variableListItem) {
                const exp = item.children[0].getText();
                const variable = {
                    name: exp,
                    dataType: '',
                    length: '',
                    location: {
                        startToken: ctx.start,
                        stopToken: ctx.stop,
                    },
                    value: undefined,
                    references: [],
                    declaration: undefined,
                    parentScope: undefined,
                };
                if (item.children.length > 1) {
                    const size = item.children[2].getText();
                    variable.length = size;
                }
                variables.push(variable);
            }
            else if (item.symbol && item.symbol.text == '=') {
                initCode += ' = ';
            }
            if (item.ruleIndex == TibboBasicParser.RULE_expression) {
                initCode += this.parseExpression(item);
            }
        }
        const dataType = this.convertVariableType(ctx.variableType.valueType.getText());
        const variableList = variables.map((variable) => {
            variable.dataType = dataType;
            return variable.name + (variable.length != '' ? `[${variable.length}]` : '');
        }).join(', ');
        this.variables = this.variables.concat(variables);
        if (this.currentFunction) {
            this.currentFunction.variables = this.currentFunction.variables.concat(variables);
        }
        this.transpiler.addCode(`${this.isGlobalVariable ? 'extern ' : ''}${dataType} ${variableList}${initCode};`, ctx.start.line);
        this.transpiler.writeLine(ctx.start.line);
    }
    enterForNextStmt(ctx) {
        const startCondition = ctx.children[1].getText();
        let variable = '';
        variable = startCondition.split('=')[0];
        let stepExp = `${variable}++`;
        let comparisonOperator = '<=';
        if (ctx.step) {
            if (ctx.step[0] == '-') {
                stepExp = `${variable} -= ${ctx.step[0].substr(1)}`;
                comparisonOperator = '>=';
            }
            else {
                stepExp = `${variable} += ${ctx.step.start.text}`;
            }
        }
        const endCondition = `${variable} ${comparisonOperator} ${ctx.children[3].getText()}`;
        this.transpiler.addCode(`for (${startCondition}; ${endCondition}; ${stepExp}) {`, ctx.start.line);
        this.transpiler.writeLine(ctx.start.line);
    }
    exitForNextStmt(ctx) {
        this.transpiler.addCode('}', ctx.stop.line);
        this.transpiler.writeLine(ctx.stop.line);
    }
    parseExpression(ctx, isAssignment = false) {
        let result = '';
        let needsCast = false;
        for (let i = 0; i < ctx.children.length; i++) {
            const item = ctx.children[i];
            if (item.symbol) {
                switch (item.symbol.type) {
                    case TibboBasicLexer.EQ:
                        if (!isAssignment) {
                            result += ' == ';
                        }
                        else {
                            result += ' = ';
                        }
                        break;
                    case TibboBasicLexer.NEQ:
                        result += ' != ';
                        break;
                    case TibboBasicLexer.AND:
                        if (isAssignment) {
                            result += ' & ';
                        }
                        else {
                            result += ' && ';
                        }
                        break;
                    case TibboBasicLexer.OR:
                        if (isAssignment) {
                            result += ' | ';
                        }
                        else {
                            result += ' || ';
                        }
                        break;
                    case TibboBasicLexer.XOR:
                        result += ' ^ ';
                        break;
                    case TibboBasicLexer.SHL:
                        result += ' << ';
                        break;
                    case TibboBasicLexer.SHR:
                        result += ' >> ';
                        break;
                    case TibboBasicLexer.NOT:
                        result += ' ~ ';
                        break;
                    case TibboBasicLexer.MOD:
                        result += ' % ';
                        break;
                    default:
                        {
                            let expression = item.getText();
                            if (this.currentFunction && this.currentFunction.parameters.length > 0) {
                                if (item.parentCtx.ruleIndex != TibboBasicParser.RULE_postfixExpression) {
                                    for (let i = 0; i < this.currentFunction.parameters.length; i++) {
                                        if (this.currentFunction.parameters[i].byRef
                                            && expression == this.currentFunction.parameters[i].name) {
                                            if (this.currentFunction.parameters[i].dataType !== 'string') {
                                                expression = '*' + expression;
                                            }
                                        }
                                    }
                                }
                            }
                            expression = expression.replace(/&h/g, '0x');
                            result += `${expression}`;
                        }
                        break;
                }
            }
            // else if (item.children && item.children.length > 1) {
            //     result += this.parseExpression(item, isAssignment);
            // }
            else {
                let expression = item.getText();
                expression = expression.replace(/&h/g, '0x');
                if (i === 0) {
                    const referencedVariable = this.findVariable(expression);
                    if (referencedVariable) {
                        // if (referencedVariable.dataType === 'string') {
                        //     needsCast = true;
                        // }
                    }
                }
                let tmp = item;
                while (tmp.children.length == 1) {
                    if (tmp.children[0].children != undefined) {
                        tmp = tmp.children[0];
                    }
                    else {
                        break;
                    }
                }
                if (tmp.ruleIndex == TibboBasicParser.RULE_postfixExpression) {
                    if (expression.indexOf('()') == -1) {
                        for (let i = 0; i < syscalls.length; i++) {
                            if (syscalls[i].call == expression && syscalls[i].type == 'syscall') {
                                result += expression + '()';
                                return result;
                            }
                        }
                    }
                    if (tmp.children[1].children && tmp.children[1].children[0].ruleIndex == TibboBasicParser.RULE_argList) {
                        const primarySymbol = tmp.children[0].getText();
                        const symbols = tmp.children[1].children[0].children;
                        if (symbols.length > 2) {
                            const func = this.transpiler.functions[primarySymbol];
                            if (func) {
                                result += `${primarySymbol}`;
                                let count = 0;
                                const tmpParams = [];
                                for (let k = 0; k < symbols.length; k++) {
                                    let prefix = '';
                                    let isLiteral = false;
                                    let symbolText = symbols[k].getText();
                                    if ([',', '(', ')'].includes(symbolText)) {
                                        continue;
                                    }
                                    if ((symbols[k].children
                                        && symbols[k].children[0].children.length > 1)
                                        || symbols[k].children[0].children[0].ruleIndex === TibboBasicParser.RULE_unaryExpression) {
                                        symbolText = this.parseExpression(symbols[k]);
                                    }
                                    if (func.parameters[count].byRef
                                        && func.parameters[count].dataType !== 'string') {
                                        prefix = '&';
                                    }
                                    if (symbolText.indexOf('"') > -1) {
                                        isLiteral = true;
                                        // const tmpT = `string s${md5(symbolText)} = ${symbolText};`;
                                        // this.transpiler.addCode(tmpT, ctx.start.line);
                                        // symbolText = `s${md5(symbolText)}`;
                                    }
                                    if (isLiteral) {
                                        prefix = '';
                                        // const varName = md5(symbolText);
                                        // result = `string ${varName} = ${symbolText};\n${result}`;
                                        // symbolText = `&${varName}`;
                                    }
                                    if (this.currentFunction) {
                                        for (let z = 0; z < this.currentFunction.parameters.length; z++) {
                                            if (this.currentFunction.parameters[z].byRef
                                                && symbolText == this.currentFunction.parameters[z].name) {
                                                prefix = '';
                                            }
                                        }
                                    }
                                    count++;
                                    tmpParams.push(`${prefix}${symbolText}`);
                                }
                                result += `(${tmpParams.join(',')})`;
                                return result;
                            }
                            const referencedVariable = this.findVariable(primarySymbol);
                            if (referencedVariable !== undefined) {
                                result += `${primarySymbol}[${this.parseExpression(symbols[1], isAssignment)}]`;
                                continue;
                            }
                        }
                    }
                }
                result += this.parseExpression(tmp, isAssignment);
            }
        }
        return result;
    }
    exitInlineIfThenElse(ctx) {
        this.transpiler.addCode(`}`, ctx.stop.line);
        this.transpiler.writeLine(ctx.stop.line);
    }
    enterInlineIfThenElse(ctx) {
        const code = ctx.children[1].getText();
        const condition = this.parseExpression(ctx.children[1]);
        const exp1 = this.parseExpression(ctx.children[3], true);
        this.transpiler.addCode(`if (${condition}) { `, ctx.start.line);
        if (ctx.children.length > 5) {
            this.transpiler.addCode(`else { `, ctx.start.line);
        }
        // this.transpiler.addCode(`;`);
        // this.transpiler.writeLine(ctx.stop.line);
    }
    enterBlockIfThenElse(ctx) {
        const code = ctx.children[1].getText();
        const condition = this.parseExpression(ctx.children[1]);
        this.transpiler.addCode(`if (${condition}) {`, ctx.start.line);
        this.transpiler.writeLine(ctx.start.line);
    }
    exitBlockIfThenElse(ctx) {
        for (let i = 3; i < ctx.children.length; i++) {
            const child = ctx.children[i];
            if (child.symbol) {
                switch (child.symbol.type) {
                    case TibboBasicLexer.ELSE:
                        this.transpiler.addCode(`} else {`, child.symbol.line);
                        this.transpiler.writeLine(child.symbol.line);
                        break;
                    case TibboBasicLexer.ELSEIF:
                        this.transpiler.addCode(`} else if (${this.parseExpression(ctx.children[i + 1])}) {`, child.symbol.line);
                        this.transpiler.writeLine(child.symbol.line);
                        break;
                }
            }
        }
        this.transpiler.addCode(`}`, ctx.stop.line);
        this.transpiler.writeLine(ctx.stop.line);
    }
    enterStatement(ctx) {
        const code = ctx.getText();
        const item = ctx.children[0];
        if (item.ruleIndex == TibboBasicParser.RULE_expression
        // || item.ruleIndex == TibboBasicParser.RULE_variableListStmt
        // || item.ruleIndex == TibboBasicParser.RULE_variableStmt
        ) {
            let isAssignment = false;
            const equalsCount = (code.match(/=/g) || []).length;
            if (equalsCount == 1) {
                isAssignment = true;
            }
            this.transpiler.addCode(this.parseExpression(ctx.children[0], isAssignment), ctx.start.line);
            this.transpiler.addCode(';', ctx.start.line);
            this.transpiler.writeLine(ctx.start.line);
        }
    }
    enterLineLabel(ctx) {
        const label = ctx.getText();
        this.transpiler.addCode(`${label} `, ctx.start.line);
        this.transpiler.writeLine(ctx.start.line);
    }
    // exitStatement(ctx: any) {
    // }
    enterWhileWendStmt(ctx) {
        const condition = this.parseExpression(ctx.children[1]);
        this.transpiler.addCode(`while (${condition}) {`, ctx.start.line);
        this.transpiler.writeLine(ctx.start.line);
    }
    exitWhileWendStmt(ctx) {
        this.transpiler.addCode(`}`, ctx.stop.line);
        this.transpiler.writeLine(ctx.stop.line);
    }
    enterExitStmt(ctx) {
        var _a;
        switch (ctx.children[0].symbol.type) {
            case TibboBasicLexer.EXIT_DO:
            case TibboBasicLexer.EXIT_FOR:
            case TibboBasicLexer.EXIT_WHILE:
                this.transpiler.addCode('break;', ctx.start.line);
                this.transpiler.writeLine(ctx.start.line);
                break;
            case TibboBasicLexer.EXIT_SUB:
                this.transpiler.addCode('return;', ctx.start.line);
                this.transpiler.writeLine(ctx.start.line);
                break;
            case TibboBasicLexer.EXIT_FUNCTION:
                this.transpiler.addCode(`return ${(_a = this.currentFunction) === null || _a === void 0 ? void 0 : _a.name};`, ctx.start.line);
                this.transpiler.writeLine(ctx.start.line);
                break;
        }
    }
    enterExpression(ctx) {
        // const code = this.parseExpression(ctx);
        // console.log(code);
    }
    // exitExpression(ctx) {
    // }
    enterGoToStmt(ctx) {
        const code = `goto ${ctx.children[1].getText()};`;
        this.transpiler.addCode(code, ctx.start.line);
    }
    enterEnumerationStmt(ctx) {
        this.transpiler.addCode(`enum ${ctx.children[1].getText()} {`, ctx.start.line);
        this.transpiler.writeLine(ctx.start.line);
    }
    exitEnumerationStmt(ctx) {
        this.transpiler.addCode(`};`, ctx.stop.line);
        this.transpiler.writeLine(ctx.stop.line);
    }
    enterSelectCaseStmt(ctx) {
        this.transpiler.addCode(`switch (${this.parseExpression(ctx.children[2])}) {`, ctx.start.line);
        this.transpiler.writeLine(ctx.start.line);
    }
    enterSC_Case(ctx) {
        for (let i = 0; i < ctx.children.length; i++) {
            if (ctx.children[i].ruleIndex == TibboBasicParser.RULE_sC_Cond) {
                this.transpiler.addCode(`case ${this.parseExpression(ctx.children[i])}:\r\n`, ctx.start.line);
            }
        }
        this.transpiler.writeLine(ctx.start.line);
    }
    exitSC_Case(ctx) {
        this.transpiler.appendLine(`break;`, ctx.stop.line);
    }
    enterSC_Default(ctx) {
        this.transpiler.addCode('default:', ctx.start.line);
        this.transpiler.writeLine(ctx.start.line);
    }
    exitSC_Default(ctx) {
        this.transpiler.addCode('break;', ctx.stop.line);
        this.transpiler.writeLine(ctx.stop.line);
    }
    exitSelectCaseStmt(ctx) {
        this.transpiler.addCode(`}`, ctx.stop.line);
        this.transpiler.writeLine(ctx.stop.line);
    }
    enterConstSubStmt(ctx) {
        this.transpiler.addCode(`#define ${ctx.children[0].getText()} ${this.parseExpression(ctx.children[2])}`, ctx.stop.line);
        this.transpiler.writeLine(ctx.start.line);
    }
    enterTypeStmt(ctx) {
        this.transpiler.addCode(`struct ${ctx.name.text} {`, ctx.start.line);
        this.transpiler.writeLine(ctx.start.line);
    }
    exitTypeStmt(ctx) {
        this.transpiler.addCode(`};`, ctx.stop.line);
        this.transpiler.writeLine(ctx.stop.line);
    }
    enterTypeStmtElement(ctx) {
        const valueType = this.convertVariableType(ctx.valueType.valueType.getText());
        let name = ctx.children[0].getText();
        if (ctx.children.length > 2) {
            name += `[${ctx.children[2].getText()}]`;
        }
        this.transpiler.addCode(`${valueType} ${name};`, ctx.start.line);
        this.transpiler.writeLine(ctx.start.line);
    }
    enterEnumerationStmt_Constant(ctx) {
        let text = `${ctx.getText()}`;
        if (text.indexOf(',') < 0) {
            text += ',';
        }
        this.transpiler.addCode(text, ctx.start.line);
        this.transpiler.writeLine(ctx.start.line);
    }
    enterObjectDeclaration(ctx) {
        const name = ctx.children[1].symbol.text;
        if (this.transpiler.objects[name] === undefined) {
            this.transpiler.objects[name] = {
                name: name,
                location: {
                    startToken: ctx.start,
                    stopToken: ctx.start
                },
                properties: [],
                events: [],
                functions: [],
                comments: []
            };
        }
        this.transpiler.objects[name].location = {
            startToken: ctx.start,
            stopToken: ctx.start
        };
        // this.compiler.addCode(`const ${name} =  {}`, ctx.start.line);
    }
    enterPropertyDefineStmt(ctx) {
        const objectName = ctx.object.text;
        const propertyName = ctx.property.text;
        if (this.transpiler.objects[objectName] != undefined) {
            this.currentObject = objectName;
            this.currentProperty = propertyName;
            for (let i = 0; i < this.transpiler.objects[objectName].properties.length; i++) {
                if (this.transpiler.objects[objectName].properties[i].name === propertyName) {
                    return;
                }
            }
            this.transpiler.objects[objectName].properties.push({
                name: propertyName,
                dataType: '',
                location: {
                    startToken: ctx.start,
                    stopToken: ctx.start
                },
                comments: []
            });
        }
        this.isDeclaration = true;
    }
    enterPropertyGetStmt(ctx) {
        for (let i = 0; i < ctx.children.length; i++) {
            const item = ctx.children[i];
            if (item.ruleIndex === TibboBasicParser.RULE_asTypeClause) {
                const objectName = item.parentCtx.parentCtx.parentCtx.object.text;
                const propertyName = item.parentCtx.parentCtx.parentCtx.property.text;
                let obj = this.transpiler.objects[objectName];
                if (obj == undefined) {
                    this.transpiler.objects[objectName] = {
                        name: objectName,
                        location: {
                            startToken: ctx.start,
                            stopToken: ctx.start
                        },
                        properties: [],
                        events: [],
                        functions: [],
                        comments: []
                    };
                    obj = this.transpiler.objects[objectName];
                }
                for (let j = 0; j < obj.properties.length; j++) {
                    if (obj.properties[j].name === propertyName) {
                        obj.properties[j].dataType = this.convertVariableType(item.children[1].getText());
                        obj.properties[j].get = {
                            name: obj.properties[j].name,
                            dataType: obj.properties[j].dataType,
                            parameters: [],
                            location: {
                                startToken: ctx.start,
                                stopToken: ctx.start
                            },
                            comments: [],
                        };
                    }
                }
            }
        }
    }
    enterPropertySetStmt(ctx) {
        const objectName = ctx.parentCtx.parentCtx.object.text;
        const propertyName = ctx.parentCtx.parentCtx.property.text;
        let obj = this.transpiler.objects[objectName];
        if (obj == undefined) {
            this.transpiler.objects[objectName] = {
                name: objectName,
                location: {
                    startToken: ctx.start,
                    stopToken: ctx.start
                },
                properties: [],
                events: [],
                functions: [],
                comments: []
            };
            obj = this.transpiler.objects[objectName];
        }
        for (let j = 0; j < obj.properties.length; j++) {
            if (obj.properties[j].name === propertyName) {
                obj.properties[j].set = {
                    name: obj.properties[j].name,
                    dataType: obj.properties[j].dataType,
                    parameters: [],
                    location: {
                        startToken: ctx.start,
                        stopToken: ctx.start
                    },
                    comments: [],
                };
            }
        }
    }
    exitPropertyDefineStmt(ctx) {
        // 
    }
    enterSyscallDeclarationInner(ctx) {
        this.isDeclaration = false;
        if (ctx.object != null) {
            const objectName = ctx.object.text;
            const functionName = ctx.property.text;
            let dataType = '';
            for (let i = 0; i < ctx.children.length; i++) {
                if (ctx.children[i].ruleIndex === TibboBasicParser.RULE_asTypeClause) {
                    dataType = this.convertVariableType(ctx.children[i].children[1].getText());
                }
            }
            if (this.transpiler.objects[objectName] != undefined) {
                this.currentFunction = {
                    name: `${functionName}`,
                    location: {
                        startToken: ctx.start,
                        stopToken: ctx.start
                    },
                    dataType: dataType,
                    parameters: [],
                    comments: [],
                    variables: [],
                };
                this.transpiler.objects[objectName].functions.push(this.currentFunction);
                this.transpiler.addCode(`${objectName}.${functionName} = function`, ctx.start.line);
            }
        }
        else {
            //non object syscall
        }
    }
    exitSyscallDeclarationInner(ctx) {
        this.currentFunction = undefined;
    }
}
//# sourceMappingURL=TibboBasicTranspiler.js.map