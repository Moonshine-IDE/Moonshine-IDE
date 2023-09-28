"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TibboBasicJavascriptCompiler = void 0;
/* eslint-disable @typescript-eslint/no-var-requires */
const fs = require("fs");
// import path = require('path');
// import ini = require('ini');
const TibboBasicErrorListener_1 = require("./TibboBasicErrorListener");
const path = require("path");
const antlr4 = require('antlr4');
const TibboBasicLexer = require('../language/TibboBasic/lib/TibboBasicLexer').TibboBasicLexer;
const TibboBasicParser = require('../language/TibboBasic/lib/TibboBasicParser').TibboBasicParser;
const TibboBasicParserListener = require('../language/TibboBasic/lib/TibboBasicParserListener').TibboBasicParserListener;
const syscalls = require('../language/TibboBasic/syscalls.json');
const events = require('../language/TibboBasic/events.json');
class TibboBasicJavascriptCompiler {
    constructor() {
        this.output = '';
        this.lines = [];
        this.currentLine = '';
        this.functions = [];
        this.variables = [];
        this.lineMappings = [];
        this.constants = {};
        this.types = {};
        this.objects = {};
        this.events = {};
        this.syscalls = {};
    }
    compile(files) {
        let output = '';
        for (let i = 0; i < files.length; i++) {
            output += this.parseFile(files[i].contents);
            if (files[i].name.indexOf('.xtxt') > -1) {
                const lines = files[i].contents.split('\r\n');
                for (let j = 0; j < lines.length; j++) {
                    lines[j] = lines[j] + `\\r\\n`;
                }
                output += `
romfile.files['${files[i].name}'] = \`${lines.join('')}\`;`;
            }
        }
        // const events: string[] = [];
        // Object.keys(this.events).forEach((key) => {
        //     events.push(key);
        // });
        // fs.writeFileSync(path.join(__dirname, '..', 'language', 'TibboBasic', 'events.json'), JSON.stringify(events));
        const finalConstants = Object.values(this.constants);
        finalConstants.sort((a, b) => {
            return b.index - a.index;
        });
        for (let i = 0; i < finalConstants.length; i++) {
            const constant = finalConstants[i];
            output = `const ${constant.name} = ${constant.value};\r\n` + output;
        }
        Object.keys(this.objects).forEach((key) => {
            output = `const ${key} = {};\r\n` + output;
        });
        output = `
        const app = new TiOS();
        ` + output;
        const tios = fs.readFileSync(path.join(__dirname, 'tios.js'), 'utf-8');
        output = tios + output;
        output += `
startSimulator(app);
`;
        return output;
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
                    const res = this.lines[line].search(/\S|$/);
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
                this.lines[i] = '';
                if (content.toLowerCase().indexOf('#define') > -1) {
                    const parts = content.split(' ');
                    // this.constants[parts[1]] = parts[2];
                    this.setConstant(parts[1], parts[2].trim());
                }
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
    setConstant(name, value) {
        let index = 0;
        if (this.constants[name] === undefined) {
            index = Object.keys(this.constants).length;
        }
        else {
            index = this.constants[name].index;
        }
        this.constants[name] = {
            index: index,
            name: name,
            value: value
        };
    }
}
exports.TibboBasicJavascriptCompiler = TibboBasicJavascriptCompiler;
class ParserListener extends TibboBasicParserListener {
    constructor(compiler) {
        super();
        this.scopeStack = [];
        this.currentParams = [];
        this.isDeclaration = false;
        this.currentFunction = undefined;
        this.isGlobalVariable = false;
        this.enumIndex = 0;
        this.compiler = compiler;
    }
    convertVariableType(variableType) {
        let valueType = variableType;
        valueType = '';
        switch (variableType) {
            // case 'byte':
            //     valueType = 'unsigned char';//U8
            //     break;
            // case 'integer':
            //     valueType = 'int';//S16
            //     break;
            // case 'word':
            //     valueType = 'unsigned int';//U16
            //     break;
            // case 'dword':
            //     valueType = 'unsigned long';//U32
            //     break;
            // case 'real':
            //     valueType = 'float';//float
            //     break;
            // case 'boolean':
            //     valueType = 'bool';//bool
            //     break;
            default:
                {
                    valueType = '';
                    if (valueType.indexOf('string') == 0) {
                        valueType = valueType.replace('(', '<');
                        valueType = valueType.replace(')', '>');
                    }
                    const exp = /^\s*([a-zA-Z][a-zA-Z0-9_]+)\([a-zA-Z][a-zA-Z0-9_]+\)?/;
                    if (variableType.match(exp) !== null) {
                        const varType = variableType.match(exp)[1];
                        if (this.compiler.types[varType] !== undefined) {
                            valueType = varType;
                        }
                    }
                    if (this.compiler.types[variableType] !== undefined) {
                        valueType = variableType;
                    }
                }
                break;
        }
        return valueType;
    }
    findVariable(name, ctx) {
        for (let i = 0; i < this.compiler.variables.length; i++) {
            if (this.compiler.variables[i].name == name) {
                return this.compiler.variables[i];
            }
        }
        return undefined;
    }
    enterDoLoopStmt(ctx) {
        this.compiler.addCode(`do {`, ctx.start.line);
    }
    exitDoLoopStmt(ctx) {
        const condition = this.parseExpression(ctx.condition);
        this.compiler.addCode(`} while (${condition});`, ctx.stop.line);
    }
    enterIncludeStmt(ctx) {
        let fileName = ctx.children[1].getText();
        const parts = fileName.split('.');
        parts[1] = 'th"';
        fileName = parts.join('.');
        fileName = fileName.replace(/\\/g, path.sep);
        // this.compiler.addCode(`#include ${fileName}`, ctx.start.line);
        this.compiler.addCode('', ctx.start.line);
        this.compiler.writeLine(ctx.start.line);
    }
    enterSubStmt(ctx) {
        const functionName = ctx.name.text;
        this.isDeclaration = false;
        // if (this.compiler.events[functionName] !== undefined) {
        if (events.includes(functionName)) {
            this.compiler.addCode(`app.${functionName} = function`, ctx.start.line);
        }
        else {
            this.compiler.addCode(`function ${functionName}`, ctx.start.line);
        }
        this.currentFunction = {
            name: ctx.name.text,
            returnType: '',
            params: [],
            returnValues: []
        };
    }
    enterParamList(ctx) {
        this.currentParams = [];
    }
    enterParam(ctx) {
        let valueType = this.convertVariableType(ctx.valueType.valueType.getText());
        const paramName = ctx.name.text;
        const param = {
            name: paramName,
            dataType: valueType,
            byRef: false,
            size: '0',
        };
        if (ctx.children[0].symbol.type == TibboBasicLexer.BYREF) {
            // paramName = '*' + paramName;
            param.byRef = true;
        }
        if (this.currentFunction !== undefined) {
            param.dataType = '';
            valueType = '';
            this.currentFunction.params.push(param);
        }
        this.currentParams.push(`${valueType} ${paramName}`);
    }
    exitParamList(ctx) {
        if (ctx.parentCtx.ruleIndex === TibboBasicParser.RULE_eventDeclaration
            || ctx.parentCtx.ruleIndex === TibboBasicParser.RULE_propertySetStmt) {
            return;
        }
        if (!this.isDeclaration) {
            this.compiler.addCode(`(${this.currentParams.join(', ')}) {`, ctx.start.line);
            if (ctx.parentCtx.parentCtx.ruleIndex === TibboBasicParser.RULE_syscallDeclaration
                || ctx.parentCtx.parentCtx.ruleIndex === TibboBasicParser.RULE_syscallDeclarationInner) {
                this.compiler.addCode(`}`, ctx.start.line);
            }
        }
        else {
            if (this.currentFunction !== undefined) {
                let initCode = '';
                for (let i = 0; i < this.currentFunction.params.length; i++) {
                    if (this.currentFunction.params[i].size) {
                        initCode += ` = new Array(${this.currentFunction.params[i].size})`;
                    }
                }
                this.compiler.addCode(`(${this.currentParams.join(', ')})${initCode};`, ctx.start.line);
            }
        }
        this.compiler.writeLine(ctx.start.line);
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
        this.compiler.addCode('}', ctx.stop.line);
        this.compiler.writeLine(ctx.stop.line);
        this.isDeclaration = false;
        this.currentFunction = undefined;
    }
    enterFunctionStmt(ctx) {
        this.isDeclaration = false;
        const name = ctx.name.text;
        const returnType = this.convertVariableType(ctx.returnType.valueType.getText());
        this.compiler.addCode(`function ${ctx.name.text}`, ctx.start.line);
        this.compiler.appendLine(`let ${name};`, ctx.start.line + 1);
        this.currentFunction = {
            name: name,
            returnType: returnType,
            params: [],
            returnValues: []
        };
    }
    exitFunctionStmt(ctx) {
        var _a;
        this.compiler.addCode('}', ctx.stop.line);
        this.compiler.writeLine(ctx.stop.line);
        this.compiler.appendLine(`return ${(_a = this.currentFunction) === null || _a === void 0 ? void 0 : _a.name};`, ctx.stop.line - 1);
        this.isDeclaration = false;
        this.currentFunction = undefined;
    }
    enterDeclareSubStmt(ctx) {
        this.isDeclaration = true;
        this.currentFunction = undefined;
        // this.compiler.addCode(`void ${ctx.name.text}`, ctx.start.line);
    }
    enterDeclareFuncStmt(ctx) {
        this.isDeclaration = true;
        this.currentFunction = undefined;
        // const returnType = this.convertVariableType(ctx.returnType.valueType.getText());
        // this.compiler.addCode(`${returnType} ${ctx.name.text}`, ctx.start.line);
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
        let dataType = '';
        for (let i = 0; i < ctx.children.length; i++) {
            const item = ctx.children[i];
            if (item.ruleIndex == TibboBasicParser.RULE_variableListItem) {
                const exp = item.children[0].getText();
                const variable = {
                    name: exp,
                    dataType: '',
                    size: '',
                    global: this.isGlobalVariable,
                    byref: false,
                };
                if (item.children.length > 1) {
                    const size = item.children[2].getText();
                    variable.size = size;
                }
                variables.push(variable);
            }
            else if (item.symbol && item.symbol.text == '=') {
                initCode += ' = ';
            }
            if (item.ruleIndex == TibboBasicParser.RULE_asTypeClause) {
                const tmpType = item.children[1].getText();
                dataType = this.convertVariableType(tmpType);
                const exp = /^\s*[a-zA-Z][a-zA-Z0-9_]+\(([a-zA-Z][a-zA-Z0-9_]+)\)/;
                if (tmpType.match(exp) !== null) {
                    const size = tmpType.match(exp)[1];
                    variables[variables.length - 1].size = size;
                }
            }
            if (item.ruleIndex == TibboBasicParser.RULE_expression) {
                initCode += this.parseExpression(item);
            }
            if (item.ruleIndex == TibboBasicParser.RULE_arrayLiteral) {
                let tmpCode = item.getText();
                tmpCode = tmpCode.replace(/\{/gm, "");
                tmpCode = tmpCode.replace(/\}/gm, "");
                const parts = tmpCode.split(',');
                for (let i = 0; i < parts.length; i++) {
                    parts[i] = parts[i].replace(/&h/g, '0x');
                }
                initCode += '[' + parts.join(', ') + ']';
            }
        }
        let dataSize;
        const variableList = variables.map((variable) => {
            variable.dataType = dataType;
            if (variable.size) {
                dataSize = variable.size;
            }
            this.compiler.variables.push(variable);
            return variable.name;
        }).join(', ');
        if (dataType !== '' && dataSize === undefined) {
            initCode += ` = new ${dataType}()`;
        }
        if (dataSize !== undefined) {
            if (dataType === '') {
                initCode += ` = new Array(${dataSize})`;
            }
            else {
                const tmp = [];
                let size = 0;
                try {
                    size = parseInt(dataSize);
                    if (this.compiler.constants[dataSize] !== undefined) {
                        size = parseInt(this.compiler.constants[dataSize].value);
                    }
                }
                catch (ex) {
                    // 
                }
                for (let i = 0; i < size; i++) {
                    tmp.push(`new ${dataType}()`);
                }
                initCode += ` = [${tmp.join(',')}]`;
            }
        }
        // this.compiler.addCode(`${this.isGlobalVariable ? 'extern ' : ''}${dataType} ${variableList}${initCode};`, ctx.start.line);
        if (!this.isGlobalVariable) {
            this.compiler.addCode(`let ${variableList}${initCode};`, ctx.start.line);
        }
        this.compiler.writeLine(ctx.start.line);
    }
    exitVariableListStmt(ctx) {
        // TODO
    }
    enterForNextStmt(ctx) {
        const startCondition = ctx.children[1].getText();
        let variable = '';
        variable = startCondition.split('=')[0];
        let stepExp = `${variable}++`;
        let comparisonOperator = '<=';
        if (ctx.step) {
            if (ctx.step.getText()[0] == '-') {
                stepExp = `${variable} -= ${ctx.step.getText().substr(1)}`;
                comparisonOperator = '>=';
            }
            else {
                stepExp = `${variable} += ${ctx.step.getText()}`;
            }
        }
        const endCondition = `${variable} ${comparisonOperator} ${ctx.children[3].getText()}`;
        this.compiler.addCode(`for (${startCondition}; ${endCondition}; ${stepExp}) {`, ctx.start.line);
        this.compiler.writeLine(ctx.start.line);
    }
    exitForNextStmt(ctx) {
        this.compiler.addCode('}', ctx.stop.line);
        this.compiler.writeLine(ctx.stop.line);
    }
    parseExpression(ctx, isAssignment = false) {
        let result = '';
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
                            if (this.currentFunction && this.currentFunction.params.length > 0) {
                                if (item.parentCtx.ruleIndex != TibboBasicParser.RULE_postfixExpression) {
                                    for (let i = 0; i < this.currentFunction.params.length; i++) {
                                        if (this.currentFunction.params[i].byRef && expression == this.currentFunction.params[i].name) {
                                            // expression = '*' + expression;
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
                        const args = tmp.children[1].children[0].children;
                        if (args.length > 2) {
                            const referencedVariable = this.findVariable(primarySymbol, tmp.children[0]);
                            if (referencedVariable !== undefined) {
                                result += `${primarySymbol}[${this.parseExpression(args[1], isAssignment)}]`;
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
        this.compiler.addCode(`}`, ctx.stop.line);
        this.compiler.writeLine(ctx.stop.line);
    }
    enterInlineIfThenElse(ctx) {
        const code = ctx.children[1].getText();
        const condition = this.parseExpression(ctx.children[1]);
        const exp1 = this.parseExpression(ctx.children[3], true);
        this.compiler.addCode(`if (${condition}) { `, ctx.start.line);
        if (ctx.children.length > 5) {
            this.compiler.addCode(`else { `, ctx.start.line);
        }
        // this.transpiler.addCode(`;`);
        // this.transpiler.writeLine(ctx.stop.line);
    }
    enterBlockIfThenElse(ctx) {
        const code = ctx.children[1].getText();
        const condition = this.parseExpression(ctx.children[1]);
        this.compiler.addCode(`if (${condition}) {`, ctx.start.line);
        this.compiler.writeLine(ctx.start.line);
    }
    exitBlockIfThenElse(ctx) {
        for (let i = 3; i < ctx.children.length; i++) {
            const child = ctx.children[i];
            if (child.symbol) {
                switch (child.symbol.type) {
                    case TibboBasicLexer.ELSE:
                        this.compiler.addCode(`} else {`, child.symbol.line);
                        this.compiler.writeLine(child.symbol.line);
                        break;
                    case TibboBasicLexer.ELSEIF:
                        this.compiler.addCode(`} else if (${this.parseExpression(ctx.children[i + 1])}) {`, child.symbol.line);
                        this.compiler.writeLine(child.symbol.line);
                        break;
                }
            }
        }
        this.compiler.addCode(`}`, ctx.stop.line);
        this.compiler.writeLine(ctx.stop.line);
    }
    enterStatement(ctx) {
        const code = ctx.getText();
        const item = ctx.children[0];
        if (item.ruleIndex == TibboBasicParser.RULE_expression
        // || item.ruleIndex == TibboBasicParser.RULE_variableListStmt
        // || item.ruleIndex == TibboBasicParser.RULE_variableStmt
        ) {
            let isAssignment = true;
            if (ctx.parentCtx.ruleIndex == TibboBasicParser.RULE_ifConditionStmt) {
                isAssignment = false;
            }
            // TODO handle more cases
            // const equalsCount = (code.match(/=/g) || []).length;
            // if (equalsCount == 1) {
            //     isAssignment = true;
            // }
            this.compiler.addCode(this.parseExpression(ctx.children[0], isAssignment), ctx.start.line);
            this.compiler.addCode(';', ctx.start.line);
            this.compiler.writeLine(ctx.start.line);
        }
    }
    enterLineLabel(ctx) {
        const label = ctx.getText();
        // this.compiler.addCode(`${label}`, ctx.start.line);
        this.compiler.writeLine(ctx.start.line);
    }
    // exitStatement(ctx: any) {
    // }
    enterWhileWendStmt(ctx) {
        const condition = this.parseExpression(ctx.children[1]);
        this.compiler.addCode(`while (${condition}) {`, ctx.start.line);
        this.compiler.writeLine(ctx.start.line);
    }
    exitWhileWendStmt(ctx) {
        this.compiler.addCode(`}`, ctx.stop.line);
        this.compiler.writeLine(ctx.stop.line);
    }
    enterExitStmt(ctx) {
        var _a;
        switch (ctx.children[0].symbol.type) {
            case TibboBasicLexer.EXIT_DO:
            case TibboBasicLexer.EXIT_FOR:
            case TibboBasicLexer.EXIT_WHILE:
                this.compiler.addCode('break;', ctx.start.line);
                this.compiler.writeLine(ctx.start.line);
                break;
            case TibboBasicLexer.EXIT_SUB:
                this.compiler.addCode('return;', ctx.start.line);
                this.compiler.writeLine(ctx.start.line);
                break;
            case TibboBasicLexer.EXIT_FUNCTION:
                this.compiler.addCode(`return ${(_a = this.currentFunction) === null || _a === void 0 ? void 0 : _a.name};`, ctx.start.line);
                this.compiler.writeLine(ctx.start.line);
                break;
        }
    }
    enterExpression(ctx) {
        // const code = ctx.getText();
        // const code = this.parseExpression(ctx);
        // console.log(code);
    }
    // exitExpression(ctx: any) {
    // }
    enterGoToStmt(ctx) {
        // const code = `goto ${ctx.children[1].getText()};`;
        // this.compiler.addCode(code, ctx.start.line);
    }
    enterEnumerationStmt(ctx) {
        // this.compiler.addCode(`enum ${ctx.children[1].getText().toLowerCase()} {`, ctx.start.line);
        this.enumIndex = 0;
        this.compiler.writeLine(ctx.start.line);
    }
    exitEnumerationStmt(ctx) {
        // this.compiler.addCode(`};`, ctx.stop.line);
        this.compiler.writeLine(ctx.stop.line);
    }
    enterSelectCaseStmt(ctx) {
        this.compiler.addCode(`switch (${this.parseExpression(ctx.children[2])}) {`, ctx.start.line);
        this.compiler.writeLine(ctx.start.line);
    }
    enterSC_Case(ctx) {
        for (let i = 0; i < ctx.children.length; i++) {
            if (ctx.children[i].ruleIndex == TibboBasicParser.RULE_sC_Cond) {
                this.compiler.addCode(`case ${this.parseExpression(ctx.children[i])}:\r\n`, ctx.start.line);
            }
        }
        this.compiler.writeLine(ctx.start.line);
    }
    exitSC_Case(ctx) {
        this.compiler.appendLine(`break;`, ctx.stop.line);
    }
    enterSC_Default(ctx) {
        this.compiler.addCode('default:', ctx.start.line);
        this.compiler.writeLine(ctx.start.line);
    }
    exitSC_Default(ctx) {
        this.compiler.addCode('break;', ctx.stop.line);
        this.compiler.writeLine(ctx.stop.line);
    }
    exitSelectCaseStmt(ctx) {
        this.compiler.addCode(`}`, ctx.stop.line);
        this.compiler.writeLine(ctx.stop.line);
    }
    enterConstSubStmt(ctx) {
        const constName = ctx.children[0].getText();
        // this.compiler.addCode(`const ${constName} = ${this.parseExpression(ctx.children[2])}`, ctx.stop.line);
        // this.compiler.constants[constName] = this.parseExpression(ctx.children[2]);
        this.compiler.setConstant(constName, this.parseExpression(ctx.children[2]));
        this.compiler.writeLine(ctx.start.line);
    }
    enterTypeStmt(ctx) {
        const typeName = ctx.name.text.toLowerCase();
        this.compiler.addCode(`function ${typeName}() {`, ctx.start.line);
        const name = ctx.children[1].getText();
        const members = [];
        for (let i = 0; i < ctx.children.length; i++) {
            if (ctx.children[i].ruleIndex == TibboBasicParser.RULE_typeStmtElement) {
                const item = ctx.children[i];
                const varName = item.children[0].getText();
                let dataType = '';
                const length = '';
                let asType = item.children[1];
                for (let j = 0; j < item.children.length; j++) {
                    if (item.children[j].ruleIndex && item.children[j].ruleIndex == TibboBasicParser.RULE_asTypeClause) {
                        asType = item.children[j];
                        break;
                    }
                }
                dataType = asType.children[1].getText();
                const variable = {
                    name: varName,
                    value: '',
                    length: length,
                    dataType: dataType,
                    location: {
                        startToken: item.start,
                        stopToken: item.start
                    },
                    references: [],
                    comments: []
                };
                members.push(variable);
            }
        }
        this.compiler.types[name] = {
            name: name,
            members: members,
            location: {
                startToken: ctx.start,
                stopToken: ctx.start
            },
            comments: []
        };
        this.compiler.writeLine(ctx.start.line);
    }
    exitTypeStmt(ctx) {
        this.compiler.addCode(`};`, ctx.stop.line);
        this.compiler.writeLine(ctx.stop.line);
    }
    enterTypeStmtElement(ctx) {
        const valueType = this.convertVariableType(ctx.valueType.valueType.getText());
        let name = ctx.children[0].getText();
        if (ctx.children.length > 2) {
            // name += `[${ctx.children[2]}]`;
            name += ` = new Array(${ctx.children[2].getText()})`;
        }
        this.compiler.addCode(`this.${name};`, ctx.start.line);
        this.compiler.writeLine(ctx.start.line);
    }
    enterEnumerationStmt_Constant(ctx) {
        let text = ctx.getText();
        if (text.indexOf(',') > -1) {
            text = text.substr(0, text.length - 1);
        }
        if (text.indexOf('=') > -1) {
            const parts = text.split('=');
            this.enumIndex = Number(parts[1]);
            text = parts[0];
        }
        // this.compiler.constants[text] = this.enumIndex.toString();
        this.compiler.setConstant(text, this.enumIndex.toString());
        // this.compiler.addCode(`const ${text} = ${this.enumIndex};`, ctx.start.line);
        this.enumIndex++;
        this.compiler.writeLine(ctx.start.line);
    }
    enterObjectDeclaration(ctx) {
        const name = ctx.children[1].symbol.text;
        this.compiler.objects[name] = {
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
        // this.compiler.addCode(`const ${name} =  {}`, ctx.start.line);
    }
    enterPropertyDefineStmt(ctx) {
        const objectName = ctx.object.text;
        const propertyName = ctx.property.text;
        if (this.compiler.objects[objectName] != undefined) {
            this.currentObject = objectName;
            this.currentProperty = propertyName;
            this.compiler.objects[objectName].properties.push({
                name: propertyName,
                dataType: '',
                location: {
                    startToken: ctx.start,
                    stopToken: ctx.start
                },
                comments: []
            });
        }
        this.compiler.addCode(`Object.defineProperty(${objectName}, '${propertyName}', { 
            get() { return 0; },
            set() {  } 
        });`, ctx.start.line);
        this.isDeclaration = true;
    }
    enterSyscallDeclarationInner(ctx) {
        this.isDeclaration = false;
        if (ctx.object != null) {
            const objectName = ctx.object.text;
            const functionName = ctx.property.text;
            if (this.compiler.objects[objectName] != undefined) {
                this.compiler.objects[objectName].functions.push({
                    name: functionName,
                    syscall: undefined,
                    location: {
                        startToken: ctx.start,
                        stopToken: ctx.start
                    },
                    parameters: [],
                    variables: [],
                    dataType: '',
                    comments: []
                });
                this.currentFunction = {
                    name: `${objectName}.${functionName}`,
                    returnType: '',
                    params: [],
                    returnValues: []
                };
                this.compiler.addCode(`${objectName}.${functionName} = function`, ctx.start.line);
            }
        }
        else {
            //non object syscall
            const name = ctx.property.text;
            let valueType = '';
            for (let i = 0; i < ctx.children.length; i++) {
                if (ctx.children[i].ruleIndex == TibboBasicParser.RULE_asTypeClause) {
                    valueType = ctx.children[i].valueType.getText();
                }
            }
            this.compiler.syscalls[name] = {
                name: name,
                parameters: [],
                location: {
                    startToken: ctx.start,
                    stopToken: ctx.start
                },
                dataType: valueType,
                comments: []
            };
            this.currentFunction = {
                name: name,
                returnType: '',
                params: [],
                returnValues: []
            };
            this.compiler.addCode(`function ${name}`, ctx.start.line);
        }
    }
    exitSyscallDeclarationInner(ctx) {
        if (this.currentFunction != undefined) {
            if (this.currentFunction.params.length === 0) {
                if (ctx.children.length === 3
                    || ctx.children[3].ruleIndex === TibboBasicParser.RULE_asTypeClause) {
                    this.compiler.addCode(`() {}`, ctx.stop.line);
                }
            }
        }
    }
    enterEventDeclaration(ctx) {
        const name = ctx.name.text;
        const params = [];
        this.isDeclaration = true;
        this.compiler.events[name] = {
            name: name,
            eventNumber: ctx.number,
            parameters: params,
            location: {
                startToken: ctx.start,
                stopToken: ctx.start
            },
            comments: []
        };
    }
}
//# sourceMappingURL=TibboBasicJavascriptCompiler.js.map